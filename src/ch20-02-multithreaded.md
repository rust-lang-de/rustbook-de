## Unseren einsträngigen (single-threaded) Webserver in einen mehrsträngigen (multi-threaded) Webserver verwandeln

Im Moment verarbeitet der Server jede Anfrage der Reihe nach, d.h. er wird erst
dann eine zweite Verbindung verarbeiten, wenn die erste abgeschlossen ist.
Würde der Server mehr und mehr Anfragen erhalten, wäre diese serielle
Ausführung immer weniger optimal. Wenn der Server eine Anfrage erhält, deren
Bearbeitung sehr lange dauert, müssen nachfolgende Anfragen warten, bis die
lange dauernde Anfrage beendet ist, auch wenn die neuen Anfragen schnell
bearbeitet werden können. Das müssen wir beheben, aber zuerst werden wir uns
das Problem in Aktion ansehen.

### Simulieren einer langsamen Anfrage in der aktuellen Server-Implementierung

Wir werden untersuchen, wie sich eine Anfrage mit langsamer Verarbeitung auf
andere Anfragen an unsere aktuelle Server-Implementierung auswirken kann.
Codeblock 20-10 implementiert die Behandlung einer Anfrage an */sleep* mit
einer simulierten langsamen Antwort, die den Server veranlasst, 5 Sekunden lang
zu schlafen, bevor er antwortet.

<span class="filename">Dateiname: src/main.rs</span>

```rust,no_run
# use std::fs;
# use std::io::prelude::*;
# use std::net::TcpListener;
# use std::net::TcpStream;
use std::thread;
use std::time::Duration;
// --abschneiden--

# fn main() {
#     let listener = TcpListener::bind("127.0.0.1:7878").unwrap();
#
#     for stream in listener.incoming() {
#         let stream = stream.unwrap();
#
#         handle_connection(stream);
#     }
# }
#
fn handle_connection(mut stream: TcpStream) {
    // --abschneiden--

#     let mut buffer = [0; 1024];
#     stream.read(&mut buffer).unwrap();
#
    let get = b"GET / HTTP/1.1\r\n";
    let sleep = b"GET /sleep HTTP/1.1\r\n";

    let (status_line, filename) = if buffer.starts_with(get) {
        ("HTTP/1.1 200 OK\r\n\r\n", "hello.html")
    } else if buffer.starts_with(sleep) {
        thread::sleep(Duration::from_secs(5));
        ("HTTP/1.1 200 OK\r\n\r\n", "hello.html")
    } else {
        ("HTTP/1.1 404 NOT FOUND\r\n\r\n", "404.html")
    };

    // --abschneiden--
#
#     let contents = fs::read_to_string(filename).unwrap();
#
#     let response = format!("{}{}", status_line, contents);
#
#     stream.write(response.as_bytes()).unwrap();
#     stream.flush().unwrap();
}
```

<span class="caption">Codeblock 20-10: Simulieren einer langsamen Anfrage durch
Erkennen von */sleep* und 5 Sekunden Schlafen</span>

Dieser Code ist etwas unordentlich, aber für Simulationszwecke gut genug. Wir
haben eine zweite Anfrage `sleep` erstellt, deren Daten unser Server erkennt.
Wir haben nach dem `if`-Block ein `else if` hinzugefügt, um die Anfrage auf
*/sleep* zu prüfen. Wenn diese Anfrage empfangen wird, wird der Server für 5
Sekunden schlafen, bevor er die Erfolgs-HTML-Seite rendert.

Du kannst sehen, wie primitiv unser Server ist: Echte Bibliotheken würden das
Erkennen mehrerer Anfragen viel weniger wortreich handhaben!

Starte den Server mit `cargo run`. Öffne dann zwei Browser-Fenster: Eines für
*http://127.0.0.1:7878/* und das andere für *http://127.0.0.1:7878/sleep*. Wenn
du die URI `/` wie bisher ein paar Mal eingibst, wirst du sehen, dass er
schnell reagiert. Aber wenn du */sleep* eingibst und dann `/` lädst, wirst du
sehen, dass `/` wartet, bis `sleep` für volle 5 Sekunden geschlafen hat, bevor
es geladen wird.

Es gibt mehrere Möglichkeiten, wie wir die Funktionsweise unseres Webservers
ändern könnten, um zu vermeiden, dass hinter einer langsamen Anfrage weitere
Anfragen warten müssen; die eine, die wir implementieren werden, ist ein
Strang-Vorrat (thread pool).

### Verbessern des Durchsatzes mit einem Strang-Vorrat

Ein *Strang-Vorrat* (thread pool) ist eine Gruppe von erzeugten Strängen, die
warten und bereit sind, eine Aufgabe zu bearbeiten. Wenn das Programm eine neue
Aufgabe erhält, ordnet es einen der Stränge im Pool der Aufgabe zu, und dieser
Strang wird die Aufgabe bearbeiten. Die verbleibenden Stränge im Pool stehen
für alle anderen Aufgaben zur Verfügung, die während der Verarbeitung des
ersten Strangs hereinkommen. Wenn der erste Strang mit der Verarbeitung seiner
Aufgabe fertig ist, kehrt er in den Vorrat der unbeschäftigten Stränge zurück
und ist bereit, eine neue Aufgabe zu bearbeiten. Ein Strang-Vorrat ermöglicht
es dir, Verbindungen gleichzeitig zu verarbeiten und so den Durchsatz deines
Servers zu erhöhen.

Wir beschränken die Anzahl der Stränge im Vorrat auf eine kleine Anzahl, um uns
vor Dienstverweigerungsangriffen (Denial-of-Service, kurz DoS) zu schützen;
wenn unser Programm für jede eingehende Anfrage einen neuen Strang erstellen
würde, könnte jemand, der 10 Millionen Anfragen an unseren Server stellt, ein
Chaos anrichten, indem er alle Ressourcen unseres Servers aufbraucht und die
Bearbeitung der Anfragen zum Erliegen bringt.

Anstatt unbegrenzt viele Stränge zu erzeugen, werden wir eine feste Anzahl von
Strängen im Vorrat warten lassen. Wenn Anfragen eingehen, werden sie zur
Verarbeitung an den Vorrat geschickt. Der Vorrat verwaltet eine Warteschlange
für eingehende Anfragen. Jeder der Stränge im Vorrat wird eine Anfrage aus
dieser Warteschlange holen, die Anfrage bearbeiten und dann die Warteschlange
um eine weitere Anfrage fragen. Mit diesem Design können wir `N` Anfragen
gleichzeitig bearbeiten, wobei `N` die Anzahl der Stränge ist. Wenn jeder
Strang auf eine lang laufende Anfrage antwortet, können sich nachfolgende
Anfragen immer noch in der Warteschlange rückstauen, aber wir haben die Anzahl
der lang laufenden Anfragen erhöht, die wir bearbeiten können, bevor wir diesen
Punkt erreichen.

Diese Technik ist nur eine von vielen Möglichkeiten, den Durchsatz eines
Webservers zu verbessern. Weitere Optionen, die du untersuchen könntest, sind
das Fork/Join-Modell und das asynchrone E/A-Modell mit einem Strang. Wenn du an
diesem Thema interessiert bist, kannst du mehr über andere Lösungen lesen und
versuchen, sie in Rust zu implementieren; mit einer systemnahen Sprache wie
Rust sind alle diese Optionen möglich.

Bevor wir mit der Implementierung eines Strang-Vorrats beginnen, lass uns
darüber sprechen, wie die Verwendung des Vorrats aussehen sollte. Wenn du
versuchst, Code zu entwerfen, kann das Schreiben der Client-Benutzeroberfläche
beim Entwurf helfen. Schreibe die API des Codes so, dass sie so strukturiert
ist, wie du sie aufrufen möchtest; implementiere dann die Funktionalität
innerhalb dieser Struktur, anstatt zuerst die Funktionalität zu implementieren
und danach die öffentliche API zu entwerfen.

Ähnlich wie wir die testgetriebene Entwicklung im Projekt in Kapitel 12
angewendet haben, werden wir hier die compilergetriebene Entwicklung verwenden.
Wir werden den Code schreiben, der die von uns gewünschten Funktionen aufruft,
und dann schauen wir uns Fehler des Compilers an, um zu bestimmen, was wir als
Nächstes ändern sollten, damit der Code funktioniert.

#### Code-Struktur, wenn wir für jede Anfrage einen Strang erstellen könnten

Lass uns zunächst untersuchen, wie unser Code aussehen könnte, wenn er für jede
Verbindung einen neuen Strang erstellen würde. Wie bereits erwähnt, ist dies
nicht unser endgültiger Plan aufgrund der Probleme, eine unbegrenzte Anzahl von
Threads zu erzeugen, aber es ist ein Ausgangspunkt. Codeblock 20-11 zeigt die
Änderungen, die an `main` vorzunehmen sind, um einen neuen Strang zu erzeugen,
der jeden Strom innerhalb der `for`-Schleife behandelt.

<span class="filename">Dateiname: src/main.rs</span>

```rust,no_run
# use std::fs;
# use std::io::prelude::*;
# use std::net::TcpListener;
# use std::net::TcpStream;
# use std::thread;
# use std::time::Duration;
#
fn main() {
    let listener = TcpListener::bind("127.0.0.1:7878").unwrap();

    for stream in listener.incoming() {
        let stream = stream.unwrap();

        thread::spawn(|| {
            handle_connection(stream);
        });
    }
}
#
# fn handle_connection(mut stream: TcpStream) {
#     let mut buffer = [0; 1024];
#     stream.read(&mut buffer).unwrap();
#
#     let get = b"GET / HTTP/1.1\r\n";
#     let sleep = b"GET /sleep HTTP/1.1\r\n";
#
#     let (status_line, filename) = if buffer.starts_with(get) {
#         ("HTTP/1.1 200 OK\r\n\r\n", "hello.html")
#     } else if buffer.starts_with(sleep) {
#         thread::sleep(Duration::from_secs(5));
#         ("HTTP/1.1 200 OK\r\n\r\n", "hello.html")
#     } else {
#         ("HTTP/1.1 404 NOT FOUND\r\n\r\n", "404.html")
#     };
#
#     let contents = fs::read_to_string(filename).unwrap();
#
#     let response = format!("{}{}", status_line, contents);
#
#     stream.write(response.as_bytes()).unwrap();
#     stream.flush().unwrap();
# }
```

<span class="caption">Codeblock 20-11: Erstellen eines neuen Strangs für jeden
Strom</span>

Wie du in Kapitel 16 gelernt hast, wird `thread::spawn` einen neuen Strang
erstellen und dann den Code im Funktionsabschluss (closure) im neuen Strang
ausführen. Wenn du diesen Code ausführst und */sleep* in deinem Browser lädst,
dann `/` in zwei weiteren Browser-Tabs, wirst du in der Tat sehen, dass die
Anfragen an `/` nicht auf die Beendigung von */sleep* warten müssen. Aber wie
wir bereits erwähnt haben, wird dies letztendlich das System überfordern, weil
du neue Stränge ohne jede Begrenzung erstellen würdest.

#### Erstellen einer ähnlichen Schnittstelle für eine endliche Anzahl von Strängen

Wir möchten, dass unser Strang-Vorrat in einer ähnlichen, vertrauten Weise
arbeitet, sodass der Wechsel von Strängen zu einem Strang-Vorrat keine großen
Änderungen am Code erfordert, der unsere API verwendet. Codeblock 20-12 zeigt
die hypothetische Schnittstelle für eine Struktur (struct) `ThreadPool`, die
wir anstelle von `thread::spawn` verwenden wollen.

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore,does_not_compile
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

    for stream in listener.incoming() {
        let stream = stream.unwrap();

        pool.execute(|| {
            handle_connection(stream);
        });
    }
}
#
# fn handle_connection(mut stream: TcpStream) {
#     let mut buffer = [0; 1024];
#     stream.read(&mut buffer).unwrap();
#
#     let get = b"GET / HTTP/1.1\r\n";
#     let sleep = b"GET /sleep HTTP/1.1\r\n";
#
#     let (status_line, filename) = if buffer.starts_with(get) {
#         ("HTTP/1.1 200 OK\r\n\r\n", "hello.html")
#     } else if buffer.starts_with(sleep) {
#         thread::sleep(Duration::from_secs(5));
#         ("HTTP/1.1 200 OK\r\n\r\n", "hello.html")
#     } else {
#         ("HTTP/1.1 404 NOT FOUND\r\n\r\n", "404.html")
#     };
#
#     let contents = fs::read_to_string(filename).unwrap();
#
#     let response = format!("{}{}", status_line, contents);
#
#     stream.write(response.as_bytes()).unwrap();
#     stream.flush().unwrap();
# }
```

<span class="caption">Codeblock 20-12: Unsere ideale
`ThreadPool`-Schnittstelle</span>

Wir verwenden `ThreadPool::new`, um einen neuen Strang-Vorrat mit einer
konfigurierbaren Anzahl von Strängen zu erstellen, in diesem Fall vier. In der
`for`-Schleife hat `pool.execute` eine ähnliche Schnittstelle wie
`thread::spawn`, indem es einen Funktionsabschluss entgegennimmt, den der
Vorrat für jeden Strom ausführen soll. Wir müssen `pool.execute`
implementieren, sodass es den Funktionsabschluss entgegennimmt und ihn einem
Strang im Vorrat zur Ausführung übergibt. Dieser Code lässt sich noch nicht
kompilieren, aber wir werden es versuchen, damit der Compiler uns anleiten
kann, wie wir das Problem beheben können.

#### Aufbau der Struktur `ThreadPool` mit compilergetriebener Entwicklung

Nimm die Änderungen in Codeblock 20-12 an *src/main.rs* vor und lass uns dann
die Kompilierfehler von `cargo check` verwenden, um unsere Entwicklung
voranzutreiben. Hier ist der erste Fehler, den wir erhalten:

```console
$ cargo check
    Checking hello v0.1.0 (file:///projects/hello)
error[E0433]: failed to resolve: use of undeclared type or module `ThreadPool`
  --> src/main.rs:10:16
   |
10 |     let pool = ThreadPool::new(4);
   |                ^^^^^^^^^^ use of undeclared type or module `ThreadPool`

error: aborting due to previous error

For more information about this error, try `rustc --explain E0433`.
error: could not compile `hello`.

To learn more, run the command again with --verbose.
```

Großartig! Dieser Fehler sagt uns, dass wir einen Typ oder ein Modul
`ThreadPool` benötigen, also werden wir jetzt eines bauen. Unsere
`ThreadPool`-Implementierung wird unabhängig von der Art der Arbeit unseres
Webservers sein. Lass uns also die Kiste (crate) `hello` von einer Binär-Kiste
(binary crate) auf eine Bibliotheks-Kiste (library crate) umstellen, um unsere
`ThreadPool`-Implementierung aufzunehmen. Nachdem wir zu einer Bibliothekskiste
umgestellt haben, könnten wir die separate Strang-Vorrats-Bibliothek auch für
alle Arbeiten verwenden, die wir mit einem Strang-Vorrat durchführen wollen,
nicht nur für die Bedienung von Webanfragen.

Erstelle eine Datei *src/lib.rs*, die das Folgende enthält, was die einfachste
Definition einer `ThreadPool`-Struktur ist, die wir im Moment haben können:

<span class="filename">Dateiname: src/lib.rs</span>

```rust
pub struct ThreadPool;
```

Erstelle dann ein neues Verzeichnis *src/bin* und verschiebe die Binärkiste,
die in *src/main.rs* enthalten ist, in *src/bin/main.rs*. Dadurch wird die
Bibliothekskiste zur primären Kiste im Verzeichnis *hello*; wir können die
Binärdatei in *src/bin/main.rs* immer noch unter Verwendung von `cargo run`
ausführen. Nachdem du die Datei *main.rs* verschoben hast, editiere sie, um die
Bibliothekskiste einzubinden und `ThreadPool` in den Gültigkeitsbereich zu
bringen, indem du den folgenden Code am Anfang von *src/bin/main.rs*
hinzufügst:

<span class="filename">Dateiname: src/bin/main.rs</span>

```rust,ignore
use hello::ThreadPool;
# use std::fs;
# use std::io::prelude::*;
# use std::net::TcpListener;
# use std::net::TcpStream;
# use std::thread;
# use std::time::Duration;
#
# fn main() {
#     let listener = TcpListener::bind("127.0.0.1:7878").unwrap();
#     let pool = ThreadPool::new(4);
#
#     for stream in listener.incoming() {
#         let stream = stream.unwrap();
#
#         pool.execute(|| {
#             handle_connection(stream);
#         });
#     }
# }
#
# fn handle_connection(mut stream: TcpStream) {
#     let mut buffer = [0; 1024];
#     stream.read(&mut buffer).unwrap();
#
#     let get = b"GET / HTTP/1.1\r\n";
#     let sleep = b"GET /sleep HTTP/1.1\r\n";
#
#     let (status_line, filename) = if buffer.starts_with(get) {
#         ("HTTP/1.1 200 OK\r\n\r\n", "hello.html")
#     } else if buffer.starts_with(sleep) {
#         thread::sleep(Duration::from_secs(5));
#         ("HTTP/1.1 200 OK\r\n\r\n", "hello.html")
#     } else {
#         ("HTTP/1.1 404 NOT FOUND\r\n\r\n", "404.html")
#     };
#
#     let contents = fs::read_to_string(filename).unwrap();
#
#     let response = format!("{}{}", status_line, contents);
#
#     stream.write(response.as_bytes()).unwrap();
#     stream.flush().unwrap();
# }
```

Dieser Code wird immer noch nicht funktionieren, aber lass uns ihn noch einmal
überprüfen, um den nächsten Fehler zu erhalten, den wir beheben müssen:

```console
$ cargo check
    Checking hello v0.1.0 (file:///projects/hello)
error[E0599]: no function or associated item named `new` found for type `hello::ThreadPool` in the current scope
  --> src/bin/main.rs:11:28
   |
11 |     let pool = ThreadPool::new(4);
   |                            ^^^ function or associated item not found in `hello::ThreadPool`

error: aborting due to previous error

For more information about this error, try `rustc --explain E0599`.
error: could not compile `hello`.

To learn more, run the command again with --verbose.
```

Dieser Fehler deutet darauf hin, dass wir als Nächstes eine zugehörige Funktion
namens `new` für `ThreadPool` erstellen müssen. Wir wissen auch, dass `new`
einen Parameter haben muss, der `4` als Argument akzeptieren kann und eine
`ThreadPool`-Instanz zurückgeben sollte. Lass uns die einfachste Funktion `new`
implementieren, die diese Eigenschaften haben wird:

<span class="filename">Dateiname: src/lib.rs</span>

```rust
pub struct ThreadPool;

impl ThreadPool {
    pub fn new(size: usize) -> ThreadPool {
        ThreadPool
    }
}
#
# fn main() {}
```

Wir haben `usize` als Typ des Parameters `size` gewählt, weil wir wissen, dass
eine negative Anzahl von Strängen keinen Sinn macht. Wir wissen auch, dass wir
diese 4 als die Anzahl der Elemente in einer Kollektion von Strängen verwenden
werden, wofür der Typ `usize` gedacht ist, wie im Abschnitt
[„Ganzzahl-Typen“][integer-types] in Kapitel 3 besprochen.

Lass uns den Code noch einmal überprüfen:

```console
$ cargo check
    Checking hello v0.1.0 (file:///projects/hello)
error[E0599]: no method named `execute` found for type `hello::ThreadPool` in the current scope
  --> src/bin/main.rs:16:14
   |
16 |         pool.execute(|| {
   |              ^^^^^^^ method not found in `hello::ThreadPool`

error: aborting due to previous error

For more information about this error, try `rustc --explain E0599`.
error: could not compile `hello`.

To learn more, run the command again with --verbose.
```

Der Fehler tritt jetzt auf, weil wir keine Methode `execute` auf `ThreadPool`
haben. Erinnere dich an den Abschnitt [„Erstellen einer ähnlichen Schnittstelle
für eine endliche Anzahl von Strängen“][similar-interface], dass wir
beschlossen haben, dass unser Strang-Vorrat eine ähnliche Schnittstelle wie
`thread::spawn` haben sollte. Zusätzlich werden wir die Funktion `execute`
implementieren, sodass sie den Funktionsabschluss, der ihr gegeben wird, nimmt
und sie einem unbeschäftigten Strang im Vorrat zur Ausführung übergibt.

Wir werden die Methode `execute` auf `ThreadPool` definieren, um einen
Funktionsabschluss als Parameter zu nehmen. Aus dem Abschnitt [„Speichern von
Funktionsabschlüssen unter Verwendung generischer Parameter und Fn-Merkmalen
(traits)“][storing-closures] in Kapitel 13 erinnern wir uns, dass wir
Funktionsabschlüsse als Parameter mit drei verschiedenen Merkmalen nehmen
können: `Fn`, `FnMut` und `FnOnce`. Wir müssen entscheiden, welche Art von
Funktionsabschluss wir hier verwenden. Wir wissen, dass wir am Ende etwas
Ähnliches wie die Implementierung `thread::spawn` der Standardbibliothek tun
werden, sodass wir uns ansehen können, welche Abgrenzungen die Signatur von
`thread::spawn` in ihrem Parameter hat. Die Dokumentation zeigt uns Folgendes:

```rust,ignore
pub fn spawn<F, T>(f: F) -> JoinHandle<T>
    where
        F: FnOnce() -> T + Send + 'static,
        T: Send + 'static
```

Der Parameter vom Typ `F` ist derjenige, um den es hier geht; der Parameter vom
Typ `T` bezieht sich auf den Rückgabewert, und darum geht es uns nicht. Wir
können sehen, dass `spawn` `FnOnce` als Merkmal (trait) verwendet, das an `F`
gebunden ist. Das ist wahrscheinlich auch das, was wir wollen, denn wir werden
das Argument, das wir bei `execute` bekommen, letztendlich an `spawn`
weitergeben. Wir können weiterhin zuversichtlich sein, dass `FnOnce` das
Merkmal ist, das wir verwenden wollen, weil der Strang zum Ausführen einer
Anfrage den Funktionsabschluss dieser Anfrage nur einmal ausführt, was zu
`Once` in `FnOnce` passt.

Der Parameter vom Typ `F` hat auch die Merkmalsabgrenzung `Send` und die
Lebensdauer `'static`, die in unserer Situation nützlich sind: Wir brauchen
`Send`, um die Merkmalsabgrenzung von einem Strang zu einem anderen zu
übertragen und `'static`, weil wir nicht wissen, wie lange die Ausführung des
Strangs dauern wird. Lass uns eine Methode `execute` auf `ThreadPool`
erstellen, die einen generischen Parameter vom Typ `F` mit diesen Abgrenzungen
annimmt:

<span class="filename">Dateiname: src/lib.rs</span>

```rust
# pub struct ThreadPool;
#
impl ThreadPool {
    // --abschneiden--
#     pub fn new(size: usize) -> ThreadPool {
#         ThreadPool
#     }
#
    pub fn execute<F>(&self, f: F)
    where
        F: FnOnce() + Send + 'static,
    {
    }
}
#
# fn main() {}
```

Wir verwenden immer noch `()` nach `FnOnce`, weil dieses `FnOnce` einen
Funktionsabschluss darstellt, der keine Parameter benötigt und den Einheitstyp
`()` zurückgibt. Genau wie bei Funktionsdefinitionen kann der Rückgabetyp in
der Signatur weggelassen werden, aber selbst wenn wir keine Parameter haben,
benötigen wir immer noch die Klammern.

Auch hier handelt es sich um die einfachste Implementierung der Methode
`execute`: Sie tut nichts, aber wir versuchen nur, unseren Code kompilieren zu
lassen. Lass es uns noch einmal überprüfen:

```console
$ cargo check
    Checking hello v0.1.0 (file:///projects/hello)
    Finished dev [unoptimized + debuginfo] target(s) in 0.24s
```

Er kompiliert! Aber beachte, dass du, wenn du `cargo run` versuchst und eine
Anfrage im Browser stellst, die Fehler im Browser sehen wirst, die wir am
Anfang des Kapitels gesehen haben. Unsere Bibliothek ruft den
Funktionsabschluss, den wir an `execute` übergeben, noch nicht wirklich auf!

> Hinweis: Ein Sprichwort, das man möglicherweise über Sprachen mit strengen
> Compilern wie Haskell und Rust hört, lautet: „Wenn der Code kompiliert,
> funktioniert er.“ Aber dieses Sprichwort ist nicht universell wahr. Unser
> Projekt kompiliert, aber es tut absolut nichts! Wenn wir ein echtes,
> vollständiges Projekt aufbauen würden, wäre dies ein guter Zeitpunkt, mit dem
> Schreiben von Unit-Tests zu beginnen, um zu überprüfen, ob der Code
> kompiliert *und* das von uns gewünschte Verhalten aufweist.

#### Validieren der Anzahl der Stränge in `new`

Wir tun nichts mit den Parametern von `new` und `execute`. Lass uns die Rümpfe
dieser Funktionen mit dem Verhalten implementieren, das wir wollen. Lass uns
zunächst über `new` nachdenken. Früher wählten wir einen vorzeichenlosen Typ
für den Parameter `size`, weil ein Vorrat mit einer negativen Anzahl von
Strängen keinen Sinn ergibt. Ein Vorrat mit null Strängen ergibt jedoch auch
keinen Sinn, dennoch ist null ein vollkommen gültiges `usize`. Wir fügen Code
hinzu, um zu prüfen, ob `size` größer als null ist, bevor wir eine
`ThreadPool`-Instanz zurückgeben, und das Programm abstürzen lassen, wenn er
eine Null erhält, indem wir das Makro `assert!` verwenden, wie in Codeblock
20-13 gezeigt.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
# pub struct ThreadPool;
#
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

        ThreadPool
    }

    // --abschneiden--
#
#     pub fn execute<F>(&self, f: F)
#     where
#         F: FnOnce() + Send + 'static,
#     {
#     }
}
#
# fn main() {}
```

<span class="caption">Codeblock 20-13: Implementierung von `ThreadPool::new`
stürzt ab, wenn `size` gleich Null ist</span>

Wir haben etwas Dokumentation für unseren `ThreadPool` mit
Dokumentationskommentaren (doc comments) hinzugefügt. Beachte, dass wir uns an
gute Dokumentationspraktiken gehalten haben, indem wir einen Abschnitt
hinzugefügt haben, der die Situationen aufzeigt, in denen unsere Funktion
abstürzen kann, wie in Kapitel 14 besprochen. Versuche, `cargo doc --open`
auszuführen und die Struktur `ThreadPool` anzuklicken, um zu sehen, wie die
generierte Dokumentation für `new` aussieht!

Anstatt das Makro `assert!` hinzuzufügen, wie wir es hier getan haben, könnten
wir `new` ein `Result` zurückgeben lassen, wie wir es mit `Config::new` im
E/A-Projekt in Codeblock 12-9 getan haben. Aber wir haben in diesem Fall
entschieden, dass der Versuch, einen Strang-Vorrat ohne Stränge zu erstellen,
ein nicht behebbarer Fehler sein sollte. Wenn du ehrgeizig bist, versuche, eine
Version von `new` mit der folgenden Signatur zu schreiben, um beide Versionen
zu vergleichen:

```rust,ignore
pub fn new(size: usize) -> Result<ThreadPool, PoolCreationError> {
```

#### Platz zum Speichern der Stränge schaffen

Jetzt, da wir eine Möglichkeit haben, zu wissen, dass wir eine gültige Anzahl
von Strängen im Vorrat haben, können wir diese Stränge erstellen und sie in der
Struktur `ThreadPool` speichern, bevor wir sie zurückgeben. Aber wie
„speichern“ wir einen Strang? Werfen wir noch einmal einen Blick auf die
Signatur von `Thread::spawn`:

```rust,ignore
pub fn spawn<F, T>(f: F) -> JoinHandle<T>
    where
        F: FnOnce() -> T + Send + 'static,
        T: Send + 'static
```

Die Funktion `spawn` gibt einen `JoinHandle<T>` zurück, wobei `T` der Typ ist,
den der Funktionsabschluss zurückgibt. Lass uns versuchen, auch `JoinHandle` zu
benutzen und sehen, was passiert. In unserem Fall werden die
Funktionsabschlüsse, die wir an den Strang-Vorrat übergeben, die Verbindung
behandeln und nichts zurückgeben, also wird `T` der Unit-Typ `()` sein.

Der Code in Codeblock 20-14 lässt sich kompilieren, erzeugt aber noch keine
Stränge. Wir haben die Definition von `ThreadPool` so geändert, dass sie einen
Vektor von `thread::JoinHandle<()>`-Instanzen enthält, den Vektor mit der
Kapazität `size` initialisiert, eine `for`-Schleife eingerichtet, die etwas
Code zum Erzeugen der Stränge ausführt, und eine `ThreadPool`-Instanz
zurückgibt, die diese enthält.

<span class="filename">Dateiname: src/lib.rs</span>

```rust,ignore,not_desired_behavior
use std::thread;

pub struct ThreadPool {
    threads: Vec<thread::JoinHandle<()>>,
}

impl ThreadPool {
    // --abschneiden--
#     /// Erzeuge einen neuen ThreadPool.
#     ///
#     /// Die Größe ist die Anzahl der Stränge im Vorrat.
#     ///
#     /// # Panics
#     ///
#     /// Die Funktion `new` stürzt ab, wenn die Größe Null ist.
    pub fn new(size: usize) -> ThreadPool {
        assert!(size > 0);

        let mut threads = Vec::with_capacity(size);

        for _ in 0..size {
            // einige Stränge erstellen und im Vektor speichern
        }

        ThreadPool { threads }
    }

    // --abschneiden--
#
#     pub fn execute<F>(&self, f: F)
#     where
#         F: FnOnce() + Send + 'static,
#     {
#     }
}
```

<span class="caption">Codeblock 20-14: Erstellen eines Vektors für `ThreadPool`
zum Aufnehmen der Stränge</span>

Wir haben `std::thread` in der Bibliothekskiste in den Gültigkeitsbereich
gebracht, weil wir `thread::JoinHandle` als den Typ der Elemente im Vektor in
`ThreadPool` verwenden.

Sobald wir eine gültige Größe erhalten haben, erzeugt unser `ThreadPool` einen
neuen Vektor, der `size` Elemente aufnehmen kann. Wir haben in diesem Buch noch
nicht die Funktion `with_capacity` verwendet, die die gleiche Aufgabe wie
`Vec::new` erfüllt, aber mit einem wichtigen Unterschied: Sie weist dem Vektor
Platz im Voraus zu. Da wir wissen, dass wir `size` Elemente im Vektor speichern
müssen, ist diese Allokation im Voraus etwas effizienter als die Verwendung von
`Vec::new`, das sich selbst in der Größe verändert, wenn Elemente eingefügt
werden.

Wenn du `cargo check` erneut ausführst, wirst du einige weitere Warnungen
erhalten, aber es sollte gelingen.

#### Struktur `Worker` zum Senden von Code vom `ThreadPool` an einen Strang

Wir haben einen Kommentar in der `for`-Schleife in Codeblock 20-14 bezüglich
der Erstellung von Strängen hinterlassen. Hier werden wir uns ansehen, wie wir
tatsächlich Stränge erstellen. Die Standardbibliothek bietet `thread::spawn`
als eine Möglichkeit, Stränge zu erstellen, und `thread::spawn` erwartet, dass
es Code erhält, den der Strang ausführen soll, sobald der Strang erstellt ist.
In unserem Fall wollen wir jedoch die Stränge erstellen und sie auf Code
*warten* lassen, den wir später senden werden. Die Implementierung von Strängen
in der Standardbibliothek enthält keine Möglichkeit, dies zu tun; wir müssen
sie manuell implementieren.

Wir werden dieses Verhalten implementieren, indem wir eine neue Datenstruktur
zwischen dem `ThreadPool` und den Strängen, die dieses neue Verhalten verwalten
werden, einführen. Wir nennen diese Datenstruktur `Worker`, was ein gängiger
Begriff in Vorrats-Implementierungen ist. Denke an Menschen, die in der Küche
eines Restaurants arbeiten: Die Arbeiter warten, bis Bestellungen von Kunden
eingehen, und dann sind sie dafür verantwortlich, diese Bestellungen
entgegenzunehmen und auszuführen.

Anstatt einen Vektor von `JoinHandle<()>`-Instanzen im Strang-Vorrat zu
speichern, werden wir Instanzen der `Worker`-Struktur speichern. Jeder `Worker`
wird eine einzelne `JoinHandle<()>`-Instanz speichern. Dann werden wir eine
Methode auf `Worker` implementieren, die einen Funktionsabschluss zur
Ausführung benötigt und ihn zur Ausführung an den bereits laufenden Strang
sendet. Wir werden auch jedem `Worker` eine `id` geben, damit wir beim
Protokollieren oder Debuggen zwischen den verschiedenen `Worker` im Vorrat
unterscheiden können.

Lass uns die folgenden Änderungen daran vornehmen, was passiert, wenn wir einen
`ThreadPool` erstellen. Wir implementieren den Code, der den Funktionsabschluss
an den Strang sendet, nachdem wir `Worker` auf diese Weise eingerichtet haben:

1. Definiere eine Struktur `Worker`, die eine `id` und einen `JoinHandle<()>`
   enthält.
2. Ändere `ThreadPool`, um einen Vektor von `Worker`-Instanzen zu halten.
3. Definiere eine Funktion `Worker::new`, die eine `id`-Nummer nimmt und eine
   `Worker`-Instanz zurückgibt, die die `id` enthält, sowie einen Strang, der
    mit einem leeren Funktionsabschluss erzeugt wurde.
4. Verwende in `ThreadPool::new` den `for`-Schleifenzähler, um eine `id` zu
   erzeugen, erzeuge einen neuen `Worker` mit dieser `id` und speichere den
   `Worker` im Vektor.

Wenn du zu einer Herausforderung bereit bist, versuche, diese Änderungen selbst
zu implementieren, bevor du dir den Code in Codeblock 20-15 ansiehst.

Bereit? Hier ist Codeblock 20-15 mit einer Möglichkeit, die vorhergehenden
Änderungen vorzunehmen.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
use std::thread;

pub struct ThreadPool {
    workers: Vec<Worker>,
}

impl ThreadPool {
    // --abschneiden--
#     /// Erzeuge einen neuen ThreadPool.
#     ///
#     /// Die Größe ist die Anzahl der Stränge im Vorrat.
#     ///
#     /// # Panics
#     ///
#     /// Die Funktion `new` stürzt ab, wenn die Größe Null ist.
    pub fn new(size: usize) -> ThreadPool {
        assert!(size > 0);

        let mut workers = Vec::with_capacity(size);

        for id in 0..size {
            workers.push(Worker::new(id));
        }

        ThreadPool { workers }
    }
    // --abschneiden--
#
#     pub fn execute<F>(&self, f: F)
#     where
#         F: FnOnce() + Send + 'static,
#     {
#     }
}

struct Worker {
    id: usize,
    thread: thread::JoinHandle<()>,
}

impl Worker {
    fn new(id: usize) -> Worker {
        let thread = thread::spawn(|| {});

        Worker { id, thread }
    }
}
# 
# fn main() {}
```

<span class="caption">Codeblock 20-15: Modifizieren von `ThreadPool`, um
`Worker`-Instanzen zu halten, anstatt Stränge direkt zu halten</span>

Wir haben den Namen des Feldes in `ThreadPool` von `threads` in `workers`
geändert, weil es jetzt `Worker`-Instanzen statt `JoinHandle<()>`-Instanzen
enthält. Wir benutzen den Zähler in der `for`-Schleife als Argument für
`Worker::new` und wir speichern jeden neuen `Worker` im Vektor mit dem Namen
`workers`.

Externer Code (wie unser Server in *src/bin/main.rs*) muss die
Implementierungsdetails bezüglich der Verwendung einer `Worker`-Struktur
innerhalb von `ThreadPool` nicht kennen, also machen wir die `Worker`-Struktur
und ihre Funktion `new` privat. Die Funktion `Worker::new` verwendet die `id`,
die wir ihr geben, und speichert eine `JoinHandle<()>`-Instanz, die durch das
Erzeugen eines neuen Strangs unter Verwendung eines leeren Funktionsabschlusses
erzeugt wird.

Dieser Code kompiliert und speichert die Anzahl der `Worker`-Instanzen, die wir
als Argument für `ThreadPool::new` angegeben haben. Aber wir *verarbeiten* noch
nicht den Funktionsabschluss, den wir in `execute` erhalten. Schauen wir uns
als Nächstes an, wie wir das machen.

#### Senden von Anfragen an Stränge über Kanäle

Nun werden wir das Problem angehen, dass die Funktionsabschlüsse bei
`thread::spawn` absolut nichts bewirken. Gegenwärtig erhalten wir den
Funktionsabschluss, den wir ausführen wollen, mit der Methode `execute`. Aber
wir müssen `thread::spawn` einen Funktionsabschluss geben, der ausgeführt
werden soll, wenn wir jeden `Worker` während der Erstellung des `ThreadPool`
erstellen.

Wir möchten, dass die Struktur `Worker`, die wir gerade erstellt haben, um Code
aus einer Warteschlange im `ThreadPool` zu holen, diesen Code zur Ausführung
an seinen Strang sendet.

In Kapitel 16 hast du etwas über *Kanäle* (channels) gelernt &ndash; eine
einfache Art der Kommunikation zwischen zwei Strängen &ndash;, die für diesen
Anwendungsfall perfekt geeignet ist. Wir verwenden einen Kanal, der als
Warteschlange von Aufträgen fungiert, und `execute` sendet einen Auftrag aus
dem `ThreadPool` an die `Worker`-Instanzen, die den Auftrag an ihren Strang
sendet. Hier ist der Plan:

1. Der `ThreadPool` erstellt einen Kanal und hält die Sendeseite des Kanals.
2. Jeder `Worker` hält die Empfangsseite des Kanals.
3. Wir werden eine neue Struktur `Job` erstellen, die den Funktionsabschluss
   aufnimmt, den wir über den Kanal senden wollen.
4. Die Methode `execute` sendet den Auftrag, der ausgeführt werden soll, in
   die Sendeseite des Kanals.
5. In seinem Strang wird der `Worker` an der Empfangsseite des Kanals warten
   und die Funktionsabschlüsse aller Aufträge, die er erhält, ausführen.

Beginnen wir damit, einen Kanal in `ThreadPool::new` zu erstellen und die
Sendeseite in der `ThreadPool`-Instanz zu halten, wie in Codeblock 20-16
gezeigt. Die Struktur `Job` enthält vorerst nichts, aber sie wird die Art von
Element sein, die wir in den Kanal senden.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
# use std::thread;
// --abschneiden--
use std::sync::mpsc;

pub struct ThreadPool {
    workers: Vec<Worker>,
    sender: mpsc::Sender<Job>,
}

struct Job;

impl ThreadPool {
    // --abschneiden--
#     /// Erzeuge einen neuen ThreadPool.
#     ///
#     /// Die Größe ist die Anzahl der Stränge im Vorrat.
#     ///
#     /// # Panics
#     ///
#     /// Die Funktion `new` stürzt ab, wenn die Größe Null ist.
    pub fn new(size: usize) -> ThreadPool {
        assert!(size > 0);

        let (sender, receiver) = mpsc::channel();

        let mut workers = Vec::with_capacity(size);

        for id in 0..size {
            workers.push(Worker::new(id));
        }

        ThreadPool { workers, sender }
    }
    // --abschneiden--
#
#     pub fn execute<F>(&self, f: F)
#     where
#         F: FnOnce() + Send + 'static,
#     {
#     }
}
#
# struct Worker {
#     id: usize,
#     thread: thread::JoinHandle<()>,
# }
#
# impl Worker {
#     fn new(id: usize) -> Worker {
#         let thread = thread::spawn(|| {});
#
#         Worker { id, thread }
#     }
# }
#
# fn main() {}
```

<span class="caption">Codeblock 20-16: Ändern von `ThreadPool`, um das sendende
Ende eines Kanals zu speichern, der `Job`-Instanzen sendet</span>

In `ThreadPool::new` erstellen wir unseren neuen Kanal und lassen den Pool das
sendende Ende halten. Dies wird erfolgreich kompiliert, immer noch mit
Warnungen.

Lass uns versuchen, ein empfangendes Ende des Kanals an jeden `Worker`
weiterzugeben, während der Strang-Vorrat den Kanal erstellt. Wir wissen, dass
wir das empfangende Ende in dem Strang verwenden wollen, den der `Worker` hat,
also werden wir den Parameter `receiver` im Funktionsabschluss referenzieren.
Der Code in Codeblock 20-17 lässt sich noch nicht ganz kompilieren.

<span class="filename">Dateiname: src/lib.rs</span>

```rust,ignore,does_not_compile
# use std::sync::mpsc;
# use std::thread;
#
# pub struct ThreadPool {
#     workers: Vec<Worker>,
#     sender: mpsc::Sender<Job>,
# }
#
# struct Job;
#
impl ThreadPool {
    // --abschneiden--
#     /// Erzeuge einen neuen ThreadPool.
#     ///
#     /// Die Größe ist die Anzahl der Stränge im Vorrat.
#     ///
#     /// # Panics
#     ///
#     /// Die Funktion `new` stürzt ab, wenn die Größe Null ist.
    pub fn new(size: usize) -> ThreadPool {
        assert!(size > 0);

        let (sender, receiver) = mpsc::channel();

        let mut workers = Vec::with_capacity(size);

        for id in 0..size {
            workers.push(Worker::new(id, receiver));
        }

        ThreadPool { workers, sender }
    }
    // --abschneiden--
#
#     pub fn execute<F>(&self, f: F)
#     where
#         F: FnOnce() + Send + 'static,
#     {
#     }
}

// --abschneiden--

# struct Worker {
#     id: usize,
#     thread: thread::JoinHandle<()>,
# }
#
impl Worker {
    fn new(id: usize, receiver: mpsc::Receiver<Job>) -> Worker {
        let thread = thread::spawn(|| {
            receiver;
        });

        Worker { id, thread }
    }
}
```

<span class="caption">Codeblock 20-17: Übergeben des Empfangsteils des Kanals
an die `Worker`</span>

Wir haben einige kleine und unkomplizierte Änderungen vorgenommen: Wir geben
das empfangende Ende des Kanals an `Worker::new` und dann verwenden wir es
innerhalb des Funktionsabschlusses.

Wenn wir versuchen, diesen Code zu überprüfen, erhalten wir diesen Fehler:

```console
$ cargo check
    Checking hello v0.1.0 (file:///projects/hello)
error[E0382]: use of moved value: `receiver`
  --> src/lib.rs:27:42
   |
22 |         let (sender, receiver) = mpsc::channel();
   |                      -------- move occurs because `receiver` has type `std::sync::mpsc::Receiver<Job>`, which does not implement the `Copy` trait
...
27 |             workers.push(Worker::new(id, receiver));
   |                                          ^^^^^^^^ value moved here, in previous iteration of loop

error: aborting due to previous error

For more information about this error, try `rustc --explain E0382`.
error: could not compile `hello`.

To learn more, run the command again with --verbose.
```

Der Code versucht, `receiver` an mehrere `Worker`-Instanzen weiterzugeben. Das
wird nicht funktionieren, wie du dich aus Kapitel 16 erinnern wirst: Die
Kanalimplementierung, die Rust bietet, erlaubt mehrere *Produzenten* und einen
einzigen *Konsumenten*. Das bedeutet, dass wir nicht einfach das konsumierende
Ende des Kanals klonen können, um diesen Code zu reparieren. Selbst wenn wir
das könnten, ist das nicht die Technik, die wir anwenden wollen; stattdessen
wollen wir die Aufträge auf mehrere Stränge verteilen, indem wir den einzigen
`receiver` unter allen `Worker` aufteilen.

Außerdem erfordert das Entfernen eines Auftrags aus der Warteschlange des
Kanals eine Mutation von `receiver`, sodass die Stränge einen sicheren Weg
benötigen, um `receiver` gemeinsam zu nutzen und zu modifizieren; andernfalls
könnten wir Wettlaufsituationen (race conditions) erhalten (wie in Kapitel 16
behandelt).

Erinnere dich an die Strang-sicheren intelligenten Zeiger, die in Kapitel 16
besprochen wurden: Um die Eigentümerschaft über mehrere Stränge zu teilen und
den Strängen zu erlauben, den Wert zu mutieren, müssen wir `Arc<Mutex<T>>`
verwenden. Der Typ `Arc` ermöglicht es mehreren `Worker`, den Empfänger zu
besitzen, und `Mutex` stellt sicher, dass immer nur ein `Worker` zur gleichen
Zeit einen Auftrag vom Empfänger erhält. Der Codeblock 20-18 zeigt die
Änderungen, die wir vornehmen müssen.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
# use std::sync::mpsc;
# use std::thread;
use std::sync::Arc;
use std::sync::Mutex;
// --abschneiden--

# pub struct ThreadPool {
#     workers: Vec<Worker>,
#     sender: mpsc::Sender<Job>,
# }
#
# struct Job;
#
impl ThreadPool {
    // --abschneiden--
#     /// Erzeuge einen neuen ThreadPool.
#     ///
#     /// Die Größe ist die Anzahl der Stränge im Vorrat.
#     ///
#     /// # Panics
#     ///
#     /// Die Funktion `new` stürzt ab, wenn die Größe Null ist.
    pub fn new(size: usize) -> ThreadPool {
        assert!(size > 0);

        let (sender, receiver) = mpsc::channel();

        let receiver = Arc::new(Mutex::new(receiver));

        let mut workers = Vec::with_capacity(size);

        for id in 0..size {
            workers.push(Worker::new(id, Arc::clone(&receiver)));
        }

        ThreadPool { workers, sender }
    }

    // --abschneiden--
#
#     pub fn execute<F>(&self, f: F)
#     where
#         F: FnOnce() + Send + 'static,
#     {
#     }
}

// --abschneiden--

# struct Worker {
#     id: usize,
#     thread: thread::JoinHandle<()>,
# }
#
impl Worker {
    fn new(id: usize, receiver: Arc<Mutex<mpsc::Receiver<Job>>>) -> Worker {
        // --abschneiden--
#         let thread = thread::spawn(|| {
#             receiver;
#         });
#
#         Worker { id, thread }
    }
}
#
# fn main() {}
```

<span class="caption">Codeblock 20-18: Das empfangende Ende des Kanals unter
den `Worker` teilen, die `Arc` und `Mutex` benutzen</span>

In `ThreadPool::new` setzen wir das empfangende Ende des Kanals in einen `Arc`
und einen `Mutex`. Für jeden neuen `Worker` klonen wir den `Arc`, um die
Referenzzählung zu erhöhen, sodass die `Worker` die Eigentümerschaft am
empfangenden Ende teilen können.

Mit diesen Änderungen kompiliert der Code! Wir haben es geschafft!

#### Implementieren der Methode `execute`

Lass uns endlich die Methode `execute` auf `ThreadPool` implementieren. Wir
werden auch `Job` von einer Struktur in einen Typ-Alias für ein Merkmalsobjekt
(trait object) ändern, das den Typ des Funktionsabschlusses enthält, den
`execute` erhält. Wie im Abschnitt [„Erstellen von Typ-Synonymen mit
Typ-Alias“][type-synonyms] in Kapitel 19 besprochen, ermöglichen uns
Typ-Aliase, lange Typen kürzer zu machen. Siehe Codeblock 20-19.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
# use std::sync::mpsc;
# use std::sync::Arc;
# use std::sync::Mutex;
# use std::thread;
#
# pub struct ThreadPool {
#     workers: Vec<Worker>,
#     sender: mpsc::Sender<Job>,
# }
#
// --abschneiden--

type Job = Box<dyn FnOnce() + Send + 'static>;

impl ThreadPool {
    // --abschneiden--
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
    pub fn execute<F>(&self, f: F)
    where
        F: FnOnce() + Send + 'static,
    {
        let job = Box::new(f);

        self.sender.send(job).unwrap();
    }
}

// --abschneiden--
#
# struct Worker {
#     id: usize,
#     thread: thread::JoinHandle<()>,
# }
#
# impl Worker {
#     fn new(id: usize, receiver: Arc<Mutex<mpsc::Receiver<Job>>>) -> Worker {
#         let thread = thread::spawn(|| {
#             receiver;
#         });
#
#         Worker { id, thread }
#     }
# }
#
# fn main() {}
```

<span class="caption">Codeblock 20-19: Erstellen eines Alias vom Typ `Job` für
eine `Box`, die jeden Funktionsabschluss enthält, und danach Senden des
Auftrags in den Kanal</span>

Nachdem wir eine neue `Job`-Instanz unter Verwendung des Funktionsabschlusses,
den wir in `execute` erhalten, erstellt haben, senden wir diesen Auftrag an das
sendende Ende des Kanals. Wir rufen `unwrap` auf `send` auf für den Fall, dass
das Senden fehlschlägt. Das kann zum Beispiel passieren, wenn wir alle unsere
Stränge von der Ausführung abhalten, was bedeutet, dass das empfangende Ende
keine neuen Nachrichten mehr empfängt. Im Moment können wir die Ausführung
unserer Stränge nicht stoppen: Unsere Stränge werden so lange ausgeführt, wie
der Vorrat existiert. Der Grund, warum wir `unwrap` verwenden, ist, dass wir
wissen, dass der Fehlerfall nicht passieren wird, aber der Compiler das nicht
weiß.

Aber wir sind noch nicht ganz fertig! Im `Worker` wird unser Funktionsabschluss
an `thread::spawn` weitergereicht, der immer noch nur auf das empfangende Ende
des Kanals *referenziert*. Stattdessen müssen wir den Funktionsabschluss für
immer in einer Schleife laufen lassen, indem wir das empfangende Ende des
Kanals um einen Auftrag bitten und den Auftrag ausführen, wenn er einen
bekommt. Lass uns die in Codeblock 20-20 gezeigte Änderung in `Worker::new`
vornehmen.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
# use std::sync::mpsc;
# use std::sync::Arc;
# use std::sync::Mutex;
# use std::thread;
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
# struct Worker {
#     id: usize,
#     thread: thread::JoinHandle<()>,
# }
#
// --abschneiden--

impl Worker {
    fn new(id: usize, receiver: Arc<Mutex<mpsc::Receiver<Job>>>) -> Worker {
        let thread = thread::spawn(move || loop {
            let job = receiver.lock().unwrap().recv().unwrap();

            println!("Worker {} hat einen Auftrag erhalten; führe ihn aus.", id);

            job();
        });

        Worker { id, thread }
    }
}
```

<span class="caption">Codeblock 20-20: Empfangen und Ausführen der Aufträge im
Strang des `Worker`</span>

Hier rufen wir zuerst `lock` auf `receiver` auf, um den Mutex zu erwerben, und
dann rufen wir `unwrap` auf, um das Programm bei eventuellen Fehlern abstürzen
zu lassen. Das Akquirieren einer Sperre kann fehlschlagen, wenn sich der Mutex
in einem *vergifteten* Zustand befindet, was passieren kann, wenn ein anderer
Strang abstürzt, während er die Sperre hält, anstatt sie freizugeben. In dieser
Situation ist der Aufruf von `unwrap`, damit dieser Strang abstürzt, die
richtige Maßnahme. Fühle dich frei, dieses `unwrap` in ein `expect` mit einer
Fehlermeldung zu ändern, die für dich von Bedeutung ist.

Wenn wir die Sperre auf dem Mutex erhalten, rufen wir `recv` auf, um einen
`Job` vom Kanal zu empfangen. Ein abschließendes `unwrap` geht auch hier an
eventuellen Fehlern vorbei, die auftreten könnten, wenn sich der Strang, der
die sendende Seite des Kanals hält, beendet hat, ähnlich wie die `send`-Methode
`Err` zurückgibt, wenn die empfangende Seite abschaltet.

Der Aufruf von `recv` blockiert, wenn also noch kein Auftrag vorhanden ist,
wartet der aktuelle Strang, bis ein Auftrag verfügbar wird. Der `Mutex<T>`
stellt sicher, dass immer nur ein `Worker`-Strang zur gleichen Zeit versucht,
einen Auftrag anzufordern.

Mit der Umsetzung dieses Tricks ist unser Strang-Vorrat in einem
funktionierenden Zustand! Führe `cargo run` aus und stelle einige Anfragen:

```console
$ cargo run
   Compiling hello v0.1.0 (file:///projects/hello)
warning: field is never read: `workers`
 --> src/lib.rs:7:5
  |
7 |     workers: Vec<Worker>,
  |     ^^^^^^^^^^^^^^^^^^^^
  |
  = note: `#[warn(dead_code)]` on by default

warning: field is never read: `id`
  --> src/lib.rs:48:5
   |
48 |     id: usize,
   |     ^^^^^^^^^

warning: field is never read: `thread`
  --> src/lib.rs:49:5
   |
49 |     thread: thread::JoinHandle<()>,
   |     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    Finished dev [unoptimized + debuginfo] target(s) in 1.40s
     Running `target/debug/main`
Worker 0 hat einen Auftrag erhalten; führe ihn aus.
Worker 2 hat einen Auftrag erhalten; führe ihn aus.
Worker 1 hat einen Auftrag erhalten; führe ihn aus.
Worker 3 hat einen Auftrag erhalten; führe ihn aus.
Worker 0 hat einen Auftrag erhalten; führe ihn aus.
Worker 2 hat einen Auftrag erhalten; führe ihn aus.
Worker 1 hat einen Auftrag erhalten; führe ihn aus.
Worker 3 hat einen Auftrag erhalten; führe ihn aus.
Worker 0 hat einen Auftrag erhalten; führe ihn aus.
Worker 2 hat einen Auftrag erhalten; führe ihn aus.
```

Erfolg! Wir haben jetzt einen Strang-Vorrat, der Verbindungen asynchron
ausführt. Es werden nie mehr als vier Stränge erzeugt, sodass unser System
nicht überlastet wird, wenn der Server viele Anfragen erhält. Wenn wir eine
Anfrage an */sleep* stellen, ist der Server immer noch in der Lage, andere
Anfragen zu bedienen, indem er sie von einem anderen Strang ausführen lässt.

> Hinweis: Wenn du */sleep* in mehreren Browser-Fenstern gleichzeitig öffnest,
> werden diese möglicherweise in 5-Sekunden-Intervallen nacheinander geladen.
> Einige Web-Browser führen aus Gründen der Zwischenspeicherung mehrere
> Instanzen der gleichen Anfrage nacheinander aus. Diese Beschränkung wird
> nicht durch unseren Webserver verursacht.

Nachdem du die `while let`-Schleife in Kapitel 18 kennengelernt hast, fragst du
dich vielleicht, warum wir den Code für den `Worker`-Strang nicht geschrieben
haben, wie in Codeblock 20-21 gezeigt.

<span class="filename">Dateiname: src/lib.rs</span>

```rust,ignore,not_desired_behavior
# use std::sync::mpsc;
# use std::sync::Arc;
# use std::sync::Mutex;
# use std::thread;
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
# struct Worker {
#     id: usize,
#     thread: thread::JoinHandle<()>,
# }
// --abschneiden--

impl Worker {
    fn new(id: usize, receiver: Arc<Mutex<mpsc::Receiver<Job>>>) -> Worker {
        let thread = thread::spawn(move || {
            while let Ok(job) = receiver.lock().unwrap().recv() {
                println!("Worker {} hat einen Auftrag erhalten; führe ihn aus.", id);

                job();
            }
        });

        Worker { id, thread }
    }
}
```

<span class="caption">Codeblock 20-21: Eine alternative Implementierung von
`Worker::new` unter Verwendung von `while let`</span>

Dieser Code wird kompiliert und ausgeführt, führt aber nicht zum gewünschten
Strang-Verhalten: Eine langsame Anfrage führt immer noch dazu, dass andere
Anfragen auf ihre Bearbeitung warten. Der Grund dafür ist etwas subtil: Die
Struktur `Mutex` hat keine öffentliche Methode `unlock`, weil die
Eigentümerschaft der Sperre auf der Lebensdauer von `MutexGuard<T>` innerhalb
von `LockResult<MutexGuard<T>>` basiert, die die Methode `lock` zurückgibt. Zur
Kompilierzeit kann der Ausleihenprüfer (borrow checker) dann die Regel
durchsetzen, dass auf eine von einem `Mutex` bewachte Ressource nicht
zugegriffen werden kann, wenn wir die Sperre nicht halten. Diese
Implementierung kann aber auch dazu führen, dass die Sperre länger als
beabsichtigt gehalten wird, wenn wir nicht sorgfältig über die Lebensdauer von
`MutexGuard<T>` nachdenken. Da die Werte im `while let`-Ausdruck für die Dauer
der Sperre im Gültigkeitsbereich bleiben, bleibt die Sperre für die Dauer des
Aufrufs von `job()` bestehen, was bedeutet, dass andere `Worker` keine Aufträge
erhalten können.

Wenn du stattdessen `loop` verwendest und die Sperre erwirbst, ohne sie einer
Variablen zuzuweisen, wird der temporäre `MutexGuard`, der von der Methode
`lock` zurückgegeben wird, verworfen, sobald die Anweisung `let job` endet.
Dies stellt sicher, dass die Sperre während des Aufrufs von `recv` gehalten
wird, aber sie wird vor dem Aufruf von `job()` freigegeben, sodass mehrere
Anfragen gleichzeitig bedient werden können.

[type-synonyms]:
ch19-04-advanced-types.html#erstellen-von-typ-synonymen-mit-typ-alias
[integer-types]: ch03-02-data-types.html#ganzzahl-typen
[similar-interface]:
#erstellen-einer-ähnlichen-schnittstelle-für-eine-endliche-anzahl-von-strängen
[storing-closures]:
ch13-01-closures.html#speichern-von-funktionsabschlüssen-unter-verwendung-generischer-parameter-und-fn-merkmalen-traits
