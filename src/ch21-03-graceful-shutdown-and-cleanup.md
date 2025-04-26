## Kontrolliertes Beenden und Aufräumen

Der Code in Codeblock 21-20 antwortet auf Anfragen asynchron durch die
Verwendung eines Strang-Vorrats (thread pool), wie von uns beabsichtigt. Wir
erhalten einige Warnungen über die Felder `workers`, `id` und `thread`, die wir
nicht direkt benutzen, was uns daran erinnert, dass wir nichts aufräumen. Wenn
wir die weniger elegante Methode <kbd>Strg</kbd>+<kbd>c</kbd> verwenden, um den
Hauptstrang (main thread) anzuhalten, werden auch alle anderen Stränge sofort
gestoppt, selbst wenn sie gerade dabei sind, eine Anfrage zu bedienen.

Als Nächstes werden wir das Merkmal (trait) `Drop` implementieren, um `join`
für jeden der Stränge im Vorrat aufzurufen, damit sie die Anfragen, an denen
sie arbeiten, vor dem Schließen beenden können. Dann werden wir einen Weg
implementieren, um den Strängen mitzuteilen, dass sie keine neuen Anfragen mehr
annehmen und herunterfahren sollen. Um diesen Code in Aktion zu sehen, werden
wir unseren Server so modifizieren, dass er nur zwei Anfragen annimmt, bevor er
seinen Strang-Vorrat kontrolliert herunterfährt.

### Implementieren des Merkmals `Drop` auf `ThreadPool`

Lass uns damit beginnen, `Drop` auf unseren Strang-Vorrat zu implementieren.
Wenn der Vorrat aufgeräumt wird, sollten wir auf das Ende unsere Stränge
warten, um sicherzustellen, dass sie ihre Arbeit beenden. Codeblock 21-22 zeigt
einen ersten Versuch einer `Drop`-Implementierung; dieser Code wird noch nicht
ganz funktionieren.

<span class="filename">Dateiname: src/lib.rs</span>

```rust,does_not_compile
# use std::{
#     sync::{mpsc, Arc, Mutex},
#     thread,
# };
#
# pub struct ThreadPool {
#     workers: Vec<Worker>,
#     sender: mpsc::Sender<Job>,
# }
#
# type Job = Box<dyn FnOnce() + Send + 'static>;
#
# impl ThreadPool {
#     /// Erzeuge einen neuen ThreadPool.
#     ///
#     /// Die Größe ist die Anzahl der Stränge im Vorrat.
#     ///
#     /// # Panics
#     ///
#     /// Die Funktion `new` stürzt ab, wenn die Größe Null ist.
#     pub fn new(size: usize) -> ThreadPool {
#         assert!(size > 0);
#
#         let (sender, receiver) = mpsc::channel();
#
#         let receiver = Arc::new(Mutex::new(receiver));
#
#         let mut workers = Vec::with_capacity(size);
#
#         for id in 0..size {
#             workers.push(Worker::new(id, Arc::clone(&receiver)));
#         }
#
#         ThreadPool { workers, sender }
#     }
#
#     pub fn execute<F>(&self, f: F)
#     where
#         F: FnOnce() + Send + 'static,
#     {
#         let job = Box::new(f);
#
#         self.sender.send(job).unwrap();
#     }
# }
#
impl Drop for ThreadPool {
    fn drop(&mut self) {
        for worker in &mut self.workers {
            println!("Worker {} herunterfahren", worker.id);

            worker.thread.join().unwrap();
        }
    }
}
#
# struct Worker {
#     id: usize,
#     thread: thread::JoinHandle<()>,
# }
#
# impl Worker {
#     fn new(id: usize, receiver: Arc<Mutex<mpsc::Receiver<Job>>>) -> Worker {
#         let thread = thread::spawn(move || loop {
#             let job = receiver.lock().unwrap().recv().unwrap();
#
#             println!("Worker {id} hat einen Auftrag erhalten; führe ihn aus.");
#
#             job();
#         });
#
#         Worker { id, thread }
#     }
# }
```

<span class="caption">Codeblock 21-22: Warten auf das Ende der einzelnen
Stränge, wenn der Strang-Vorrat den Gültigkeitsbereich verlässt</span>

Zuerst iterieren wir über alle `workers` im Strang-Vorrat. Wir verwenden dafür
`&mut`, weil `self` eine veränderbare Referenz ist und wir auch in der Lage
sein müssen, `worker` zu verändern. Für jeden `worker` geben wir eine Nachricht
aus, die besagt, dass diese bestimmte `worker`-Instanz heruntergefahren wird,
und dann rufen wir auf dem Strang dieser `worker`-Instanz `join` auf. Wenn der
Aufruf von `join` fehlschlägt, benutzen wir `unwrap`, um das Programm abstürzen
zu lassen.

Hier ist der Fehler, den wir erhalten, wenn wir diesen Code kompilieren:

```console
$ cargo check
    Checking hello v0.1.0 (file:///projects/hello)
error[E0507]: cannot move out of `worker.thread` which is behind a mutable reference
  --> src/lib.rs:52:13
   |
52 |             worker.thread.join().unwrap();
   |             ^^^^^^^^^^^^^ ------ `worker.thread` moved due to this method call
   |             |
   |             move occurs because `worker.thread` has type `JoinHandle<()>`, which does not implement the `Copy` trait
   |
note: `JoinHandle::<T>::join` takes ownership of the receiver `self`, which moves `worker.thread`
  --> /rustc/07dca489ac2d933c78d3c5158e3f43be/library/std/src/thread/mod.rs:1649:17

For more information about this error, try `rustc --explain E0507`.
error: could not compile `hello` (lib) due to 1 previous error
```

Der Fehler sagt uns, dass wir `join` nicht aufrufen können, weil wir nur eine
veränderbare Ausleihe von jedem `worker` haben und `join` die Eigentümerschaft
für sein Argument übernimmt. Um dieses Problem zu lösen, müssen wir den Strang
`thread` aus der `Worker`-Instanz herausnehmen, damit `join` den Strang
konsumieren kann. Eine Möglichkeit, dies zu tun, besteht darin, den gleichen
Ansatz wie in Codeblock 18-15 zu verfolgen. Wenn `Worker` ein
`Option<Thread::JoinHandle<()>>` hielte, könnten wir die Methode `take` auf
`Option` aufrufen, um den Wert aus der Variante `Some` herauszuverschieben und
eine Variante `None` an ihrer Stelle zu belassen. Mit anderen Worten, ein
`Worker`, der läuft, würde eine Variante `Some` in `thread` haben, und wenn wir
einen `Worker` aufräumen wollten, würden wir `Some` durch `None` ersetzen,
sodass der `Worker` keinen Strang zum Laufen haben würde.

Das _einzige_ Mal, dass dies der Fall wäre, wäre, wenn man den `Worker`
aufräumt. Im Gegenzug müssten wir überall, wo wir auf `Worker.thread`
zugreifen, mit einer `Option<thread::JoinHandle<()>>` umgehen. Idiomatisch
verwendet Rust `Option` ziemlich oft, aber wenn du etwas in `Option` einpackst,
von dem du weißt dass es immer vorhanden sein wird, ist es eine gute Idee, nach
alternativen Ansätzen zu suchen. Du könntest deinen Code sauberer und weniger
fehleranfällig machen.

In diesem Fall gibt es eine bessere Alternative: Die Methode `Vec::drain`. Sie
akzeptiert einen Bereichsparameter, um anzugeben, welche Elemente aus dem `Vec`
entfernt werden sollen, und gibt einen Iterator dieser Elemente zurück. Die
Angabe der Bereichssyntax `..` entfernt _alle_ Werte aus dem `Vec`.

Wir müssen also die `drop`-Implementierung von `ThreadPool` wie folgt
aktualisieren:

<span class="filename">Dateiname: src/lib.rs</span>

```rust
# #![allow(unused)]
# fn main() {
# use std::{
#     sync::{Arc, Mutex, mpsc},
#     thread,
# };
#
# pub struct ThreadPool {
#     workers: Vec<Worker>,
#     sender: mpsc::Sender<Job>,
# }
#
# type Job = Box<dyn FnOnce() + Send + 'static>;
#
# impl ThreadPool {
#     /// Erzeuge einen neuen ThreadPool.
#     ///
#     /// Die Größe ist die Anzahl der Stränge im Vorrat.
#     ///
#     /// # Panics
#     ///
#     /// Die Funktion `new` stürzt ab, wenn die Größe Null ist.
#     pub fn new(size: usize) -> ThreadPool {
#         assert!(size > 0);
#
#         let (sender, receiver) = mpsc::channel();
#
#         let receiver = Arc::new(Mutex::new(receiver));
#
#         let mut workers = Vec::with_capacity(size);
#
#         for id in 0..size {
#             workers.push(Worker::new(id, Arc::clone(&receiver)));
#         }
#
#         ThreadPool { workers, sender }
#     }
#
#     pub fn execute<F>(&self, f: F)
#     where
#         F: FnOnce() + Send + 'static,
#     {
#         let job = Box::new(f);
#
#         self.sender.send(job).unwrap();
#     }
# }
#
impl Drop for ThreadPool {
    fn drop(&mut self) {
        for worker in self.workers.drain(..) {
            println!("Worker {} herunterfahren", worker.id);

            worker.thread.join().unwrap();
        }
    }
}
#
# struct Worker {
#     id: usize,
#     thread: thread::JoinHandle<()>,
# }
#
# impl Worker {
#     fn new(id: usize, receiver: Arc<Mutex<mpsc::Receiver<Job>>>) -> Worker {
#         let thread = thread::spawn(move || {
#             loop {
#                 let job = receiver.lock().unwrap().recv().unwrap();
#
#                 println!("Worker {id} hat einen Auftrag erhalten; führe ihn aus.");
#
#                 job();
#             }
#         });
#
#         Worker { id, thread }
#     }
# }
```

Dadurch wird der Compilerfehler behoben, und es sind keine weiteren Änderungen
an unserem Code erforderlich.

### Den Strängen signalisieren, nicht mehr nach Aufträgen zu lauschen

Mit all den Änderungen, die wir vorgenommen haben, lässt sich unser Code ohne
jede Warnung kompilieren. Aber die schlechte Nachricht ist, dass dieser Code
noch nicht so funktioniert, wie wir es uns wünschen. Der Schlüssel ist die
Logik in den Funktionsabschlüssen, die von den Strängen der `Worker`-Instanzen
ausgeführt werden: Im Moment rufen wir `join` auf, aber das wird die Stränge
nicht herunterfahren, weil sie sich in einer Endlosschleife auf der Suche nach
Aufträgen befinden. Wenn wir versuchen, unseren `ThreadPool` mit unserer
aktuellen Implementierung von `Drop` aufräumen zu lassen, wird der Hauptstrang
für immer blockieren und auf das Beenden des ersten Strangs warten.

Um dieses Problem zu beheben, brauchen wir eine Änderung in der Implementierung
von `drop` in `ThreadPool` und dann eine Änderung in der `Worker`-Schleife.

Zuerst ändern wir die Implementierung von `drop` in `ThreadPool`, um den
`sender` explizit zu aufzuräumen, bevor wir auf das Ende der Stränge warten.
Codeblock 21-23 zeigt die Änderungen an `ThreadPool`, um den `sender` explizit
aufzuräumen. Anders als beim Strang, _müssen_ wir hier eine `Option` verwenden,
um den `sender` mit `Option::take` aus dem `ThreadPool` herausnehmen zu können.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
# use std::{
#     sync::{mpsc, Arc, Mutex},
#     thread,
# };
#
pub struct ThreadPool {
    workers: Vec<Worker>,
    sender: mpsc::Sender<Message>,
}
// --abschneiden--
#
# type Job = Box<dyn FnOnce() + Send + 'static>;
#
impl ThreadPool {
#     /// Erzeuge einen neuen ThreadPool.
#     ///
#     /// Die Größe ist die Anzahl der Stränge im Vorrat.
#     ///
#     /// # Panics
#     ///
#     /// Die Funktion `new` stürzt ab, wenn die Größe Null ist.
#     pub fn new(size: usize) -> ThreadPool {
          // --abschneiden--

#         assert!(size > 0);
#
#         let (sender, receiver) = mpsc::channel();
#
#         let receiver = Arc::new(Mutex::new(receiver));
#
#         let mut workers = Vec::with_capacity(size);
#
#         for id in 0..size {
#             workers.push(Worker::new(id, Arc::clone(&receiver)));
#         }
#
        ThreadPool {
            workers,
            sender: Some(sender),
        }
#     }
#
    pub fn execute<F>(&self, f: F)
    where
        F: FnOnce() + Send + 'static,
    {
        let job = Box::new(f);

        self.sender.send(Message::NewJob(job)).unwrap();
    }
}

impl Drop for ThreadPool {
    fn drop(&mut self) {
        drop(self.sender.take());

        for worker in &mut self.workers {
            println!("Worker {} herunterfahren", worker.id);

            if let Some(thread) = worker.thread.take() {
                thread.join().unwrap();
            }
        }
    }
}
#
# struct Worker {
#     id: usize,
#     thread: Option<thread::JoinHandle<()>>,
# }
#
# impl Worker {
#     fn new(id: usize, receiver: Arc<Mutex<mpsc::Receiver<Message>>>) -> Worker {
#         let thread = thread::spawn(move || loop {
#             let job = receiver.lock().unwrap().recv().unwrap();
#          
#             println!("Worker {id} got a job; executing.");
#          
#             job();
#         });
#
#         Worker {
#             id,
#             thread: Some(thread),
#         }
#     }
# }
```

<span class="caption">Codeblock 21-23: `sender` vor dem Warten auf die
`Worker`-Stränge explizit aufräumen</span>

Das Aufräumen von `sender` schließt den Kanal, was bedeutet, dass keine
weiteren Nachrichten gesendet werden. Wenn das passiert, geben alle Aufrufe
von `recv`, die die `Worker`-Instanzen in der Endlosschleife machen, einen
Fehler zurück. In Codeblock 21-24 ändern wir die `Worker`-Schleife so, dass die
Schleife in diesem Fall ordnungsgemäß beendet wird, was bedeutet, dass die
Stränge beendet werden, wenn die Implementierung von `drop` in `ThreadPool`
`join` für sie aufruft.

<span class="filename">Dateiname: src/lib.rs</span>

```rust,noplayground
# use std::{
#     sync::{mpsc, Arc, Mutex},
#     thread,
# };
#
# pub struct ThreadPool {
#     workers: Vec<Worker>,
#     sender: mpsc::Sender<Message>,
# }
#
# type Job = Box<dyn FnOnce() + Send + 'static>;
#
# impl ThreadPool {
#     /// Erzeuge einen neuen ThreadPool.
#     ///
#     /// Die Größe ist die Anzahl der Stränge im Vorrat.
#     ///
#     /// # Panics
#     ///
#     /// Die Funktion `new` stürzt ab, wenn die Größe Null ist.
#     pub fn new(size: usize) -> ThreadPool {
#         assert!(size > 0);
#
#         let (sender, receiver) = mpsc::channel();
#
#         let receiver = Arc::new(Mutex::new(receiver));
#
#         let mut workers = Vec::with_capacity(size);
#
#         for id in 0..size {
#             workers.push(Worker::new(id, Arc::clone(&receiver)));
#         }
#
#         ThreadPool {
#             workers,
#             sender: Some(sender),
#         }
#     }
#
#     pub fn execute<F>(&self, f: F)
#     where
#         F: FnOnce() + Send + 'static,
#     {
#         let job = Box::new(f);
#
#         self.sender.send(Message::NewJob(job)).unwrap();
#     }
# }
#
# impl Drop for ThreadPool {
#     fn drop(&mut self) {
#         drop(self.sender.take());
#
#         for worker in &mut self.workers {
#             println!("Worker {} herunterfahren", worker.id);
#
#             if let Some(thread) = worker.thread.take() {
#                 thread.join().unwrap();
#             }
#         }
#     }
# }
#
# struct Worker {
#     id: usize,
#     thread: Option<thread::JoinHandle<()>>,
# }
#
impl Worker {
    fn new(id: usize, receiver: Arc<Mutex<mpsc::Receiver<Job>>>) -> Worker {
        let thread = thread::spawn(move || loop {
            match receiver.lock().unwrap().recv() {
                Ok(job) => {
                    println!("Worker {id} hat einen Auftrag erhalten; führe ihn aus.");

                    job();
                }
                Err(_) => {
                    println!("Worker {id} nicht mehr verbunden, wird beendet.");
                    break;
                }
            }
        });

        Worker {
            id,
            thread: Some(thread),
        }
    }
}
```

<span class="caption">Codeblock 21-24: Explizites Verlassen der Schleife, wenn
`recv` einen Fehler zurückgibt</span>

Um diesen Code in Aktion zu sehen, modifizieren wir `main` so, dass nur zwei
Anfragen akzeptiert werden, bevor der Server kontrolliert heruntergefahren
wird, wie in Codeblock 21-25 gezeigt.

<span class="filename">Dateiname: src/main.rs</span>

```rust,noplayground
# use hello::ThreadPool;
# use std::fs;
# use std::io::prelude::*;
# use std::net::TcpListener;
# use std::net::TcpStream;
# use std::thread;
# use std::time::Duration;
#
fn main() {
    let listener = TcpListener::bind("127.0.0.1:7878").unwrap();
    let pool = ThreadPool::new(4);

    for stream in listener.incoming().take(2) {
        let stream = stream.unwrap();

        pool.execute(|| {
            handle_connection(stream);
        });
    }

    println!("Fahre herunter.");
}
# 
# fn handle_connection(mut stream: TcpStream) {
#     let buf_reader = BufReader::new(&mut stream);
#     let request_line = buf_reader.lines().next().unwrap().unwrap();
#
#     let (status_line, filename) = match &request_line[..] {
#         "GET / HTTP/1.1" => ("HTTP/1.1 200 OK", "hello.html"),
#         "GET /sleep HTTP/1.1" => {
#             thread::sleep(Duration::from_secs(5));
#             ("HTTP/1.1 200 OK", "hello.html")
#         }
#         _ => ("HTTP/1.1 404 NOT FOUND", "404.html"),
#     };
#
#     let contents = fs::read_to_string(filename).unwrap();
#     let length = contents.len();
#
#     let response =
#         format!("{status_line}\r\nContent-Length: {length}\r\n\r\n{contents}");
#
#     stream.write_all(response.as_bytes()).unwrap();
# }
```

<span class="caption">Codeblock 21-25: Herunterfahren des Servers, nachdem er
zwei Anfragen bearbeitet hat, durch Verlassen der Schleife</span>

Du würdest nicht wollen, dass ein Webserver aus der realen Welt
heruntergefahren wird, nachdem er nur zwei Anfragen bearbeitet hat. Dieser Code
zeigt nur, dass das kontrollierte Herunterfahren und Aufräumen funktioniert.

Die Methode `take` ist im Merkmal `Iterator` definiert und beschränkt die
Iteration auf die ersten beiden Elemente. Der `ThreadPool` wird am Ende von
`main` den Gültigkeitsbereich verlassen und die `drop`-Implementierung
ausgeführt werden.

Starte den Server mit `cargo run` und stelle drei Anfragen. Die dritte Anfrage
sollte fehlerhaft sein und in deinem Terminal solltest du eine ähnliche Ausgabe
wie diese sehen:

```console
$ cargo run
   Compiling hello v0.1.0 (file:///projects/hello)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 1.0s
     Running `target/debug/hello`
Worker 0 hat einen Auftrag erhalten; führe ihn aus.
Fahre herunter.
Worker 0 herunterfahren
Worker 3 hat einen Auftrag erhalten; führe ihn aus.
Worker 1 nicht mehr verbunden, wird beendet.
Worker 2 nicht mehr verbunden, wird beendet.
Worker 3 nicht mehr verbunden, wird beendet.
Worker 0 nicht mehr verbunden, wird beendet.
Worker 1 herunterfahren
Worker 2 herunterfahren
Worker 3 herunterfahren
```

Möglicherweise siehst du eine andere Reihenfolge der `Worker`-IDs und der
ausgegebenen Nachrichten. Wir können anhand der Nachrichten sehen, wie dieser
Code funktioniert: Die `Worker` 0 und 3 haben die ersten beiden Anfragen
erhalten. Der Server hat nach der zweiten Verbindung aufgehört, Verbindungen
anzunehmen, und die `Drop`-Implementierung auf `ThreadPool` beginnt mit der
Ausführung, bevor `Worker` 3 überhaupt seinen Job beginnt. Wenn man den
`sender` aufräumt, werden alle `Worker`-Instanzen getrennt und angewiesen, sich
zu beenden. Die `Worker`-Instanzen geben jeweils eine Nachricht aus, wenn sie
die Verbindung trennen, und dann ruft der Strang-Vorrat `join` auf, um das Ende
jedes `Worker`-Strangs zu warten.

Beachte einen interessanten Aspekt diesem speziellen Programmlauf: Der
`ThreadPool` hat den `sender` aufgeräumt, und bevor ein `Worker` einen Fehler
erhalten hat, haben wir versucht, auf `Worker` 0 zu warten. `Worker` 0 hatte
noch keinen Fehler von `recv` erhalten, also blockierte der Hauptstrang und
wartete darauf, dass `Worker` 0 fertig wird. In der Zwischenzeit erhielt
`Worker` 3 einen Auftrag, und dann erhielten alle Stränge einen Fehler. Als
`Worker` 0 fertig war, wartete der Hauptstrang darauf, dass die restlichen
`Worker`-Instanzen fertig wurden. Zu diesem Zeitpunkt hatten sie alle ihre
Schleifen verlassen und konnten sich beenden.

Herzlichen Glückwunsch! Wir haben jetzt unser Projekt abgeschlossen; wir haben
einen einfachen Webserver, der einen Strang-Vorrat verwendet, um asynchron zu
antworten. Wir sind in der Lage, den Server kontrolliert herunterzufahren,
wodurch alle Stränge im Vorrat aufgeräumt werden.

Hier ist der vollständige Code als Referenz:

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore
use hello::ThreadPool;
use std::fs;
use std::io::prelude::*;
use std::net::TcpListener;
use std::net::TcpStream;
use std::thread;
use std::time::Duration;

fn main() {
    let listener = TcpListener::bind("127.0.0.1:7878").unwrap();
    let pool = ThreadPool::new(4);

    for stream in listener.incoming() {
        let stream = stream.unwrap();

        pool.execute(|| {
            handle_connection(stream);
        });
    }

    println!("Fahre herunter.");
}

fn handle_connection(mut stream: TcpStream) {
    let buf_reader = BufReader::new(&mut stream);
    let request_line = buf_reader.lines().next().unwrap().unwrap();

    let (status_line, filename) = match &request_line[..] {
        "GET / HTTP/1.1" => ("HTTP/1.1 200 OK", "hello.html"),
        "GET /sleep HTTP/1.1" => {
            thread::sleep(Duration::from_secs(5));
            ("HTTP/1.1 200 OK", "hello.html")
        }
        _ => ("HTTP/1.1 404 NOT FOUND", "404.html"),
    };

    let contents = fs::read_to_string(filename).unwrap();
    let length = contents.len();

    let response =
        format!("{status_line}\r\nContent-Length: {length}\r\n\r\n{contents}");

    stream.write_all(response.as_bytes()).unwrap();
}
```

<span class="filename">Dateiname: src/lib.rs</span>

```rust
use std::{
    sync::{mpsc, Arc, Mutex},
    thread,
};

pub struct ThreadPool {
    workers: Vec<Worker>,
    sender: mpsc::Sender<Message>,
}

type Job = Box<dyn FnOnce() + Send + 'static>;

impl ThreadPool {
    /// Erzeuge einen neuen ThreadPool.
    ///
    /// Die Größe ist die Anzahl der Stränge im Vorrat.
    ///
    /// # Panics
    ///
    /// Die Funktion `new` stürzt ab, wenn die Größe Null ist.
    pub fn new(size: usize) -> ThreadPool {
        assert!(size > 0);

        let (sender, receiver) = mpsc::channel();

        let receiver = Arc::new(Mutex::new(receiver));

        let mut workers = Vec::with_capacity(size);

        for id in 0..size {
            workers.push(Worker::new(id, Arc::clone(&receiver)));
        }

        ThreadPool {
            workers,
            sender: Some(sender),
        }
    }

    pub fn execute<F>(&self, f: F)
    where
        F: FnOnce() + Send + 'static,
    {
        let job = Box::new(f);

        self.sender.send(Message::NewJob(job)).unwrap();
    }
}

impl Drop for ThreadPool {
    fn drop(&mut self) {
        drop(self.sender.take());

        for worker in &mut self.workers {
            println!("Worker {} herunterfahren", worker.id);

            if let Some(thread) = worker.thread.take() {
                thread.join().unwrap();
            }
        }
    }
}

struct Worker {
    id: usize,
    thread: Option<thread::JoinHandle<()>>,
}

impl Worker {
    fn new(id: usize, receiver: Arc<Mutex<mpsc::Receiver<Message>>>) -> Worker {
        let thread = thread::spawn(move || loop {
            let message = receiver.lock().unwrap().recv().unwrap();

            match message {
                Ok(job) => {
                    println!("Worker {id} hat einen Auftrag erhalten; führe ihn aus.");

                    job();
                }
                Err(_) => {
                    println!("Worker {id} nicht mehr verbunden, wird beendet.");
                    break;
                }
            }
        });

        Worker {
            id,
            thread: Some(thread),
        }
    }
}
```

Wir könnten hier mehr tun! Wenn du dieses Projekt weiter verbessern willst,
findest du hier einige Ideen:

- Füge weitere Dokumentation zu `ThreadPool` und seinen öffentlichen Methoden
  hinzu.
- Füge Tests der Funktionalität der Bibliothek hinzu.
- Ändere Aufrufe von `unwrap` in eine robustere Fehlerbehandlung.
- Verwende `ThreadPool`, um eine andere Aufgabe als das Beantworten von
  Web-Anfragen durchzuführen.
- Suche eine Strang-Vorrats-Kiste auf [crates.io](https://crates.io/) und
  implementiere damit einen ähnlichen Webserver unter Verwendung der Kiste.
  Vergleiche dann dessen API und Robustheit mit dem von uns implementierten
  Strang-Vorrat.

## Zusammenfassung

Gut gemacht! Du hast es bis ans Ende des Buchs geschafft! Wir möchten dir
danken, dass du uns auf dieser Tour durch Rust begleitet hast. Du bist nun
bereit, deine eigenen Rust-Projekte umzusetzen und bei den Projekten anderer zu
helfen. Denke daran, dass es eine gastfreundliche Gemeinschaft von anderen
Rust-Entwicklern gibt, die dir bei allen Herausforderungen, denen du auf deiner
Rust-Reise begegnest, gerne helfen würden.
