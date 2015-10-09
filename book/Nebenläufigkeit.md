# Nebenläufigkeit

Nebenläufigkeit und Parallelismus sind heutzutage unglaublich wichtige Themen in der Informatik genauso wie in der Industrie.
Prozessoren haben mehr und mehr Kerne und dennoch sind Programmierer nicht gut darauf vorbereitet die vielen Kerne voll auszunutzen.

Rusts Speichersicherheit hat einen großen Einfluß auf dessen Verhalten bei Nebenläufigkeit.
Das Typsystem garantiert bereits zur Kompilierzeit dass keine Speicherveletzungen oder Raceconditions auftreten können.

Bevor wir auf Nebenläufigkeit genauer eingehen ist eine Sache erwähnenswert:
Rust ist systemnah genug, dass ein Großteil der hier genannten Funktionalität von der Standardbibliothek zur Verfügung gestellt werden kann, nicht von der Sprache selbst.
Das heißt dass wenn man eine bestimmte Art und Weise wie Rust mit Nebenläufigkeit umgeht nicht mag, dann kann man einfach eine Alternative implementieren.
[mio](https://github.com/carllerche/mio) ist ein gutes Beispiel dafür.

## Hintergrund: `Send` und `Sync`

Über Verhalten bei Nebenläufigkeit lässt sich häufig nur schwer eine Aussage treffen.
In Rust haben wir jedoch ein strenges, statisches Typsystem, welches uns genau das erleichtert.
Zum Beispiel gibt uns Rust zwei Traits, die uns dabei helfen zu Entscheiden, ob Code potentiell Nebenläufigkeit enthalten kann oder nicht.

### `Send`

Das erste Trait über das wir reden ist [`Send`](http://doc.rust-lang.org/stable/std/marker/trait.Send.html).
Wenn ein Typ `T` `Send` implementiert, dann heißt das, dass es möglich ist den Besitzer dieses Typs sicher zwischen zwei Threads zu wechseln.

Das ist wichtig um bestimmte Restriktionen durchzusetzen.
Wenn wir zum Beispiel einen `Channel` haben der zwei Threads verbindet, und gerne Daten durch diesen `Channel` zu einem anderen Thread senden möchten, dann müssen wir sichergehen, dass der Datentyp den wir senden wollen auch `Send` implementiert.

Eine andere Möglichkeit ist, wenn wir zum Beispiel eine FFI-Bibliothek anbinden, die nicht threadsicher ist, dann wollen wir explizit nicht `Send` implementieren, damit der Kompiler bereits verbietet, dass ein Objekt jemals den Thread wechselt.

### `Sync`

Das zweite Trait heißt
[`Sync`](http://doc.rust-lang.org/stable/std/marker/trait.Sync.html).
Wenn ein Typ `T` `Sync` implementiert, dann heißt das, dass es möglich ist diesen Typen sicher von zwei Threads aus über mehrere Referenzen zu nutzen, ohne Speichersicherheit zu verletzen.
Das impliziert dass Typen die *keine* [interne Mutabilität](Mutabilität.html) haben inhärent `Sync` sind, inklusive der primitiven Typen (wie `u8`) und daraus zusammengesetzte Typen.

Um Referenzen zwischen Threads zu teilen bietet einen Wrapper namens `Arc<T>`.
`Arc<T>` implementiert sowohl `Send` als auch `Sync` wenn,
und nur wenn, `T` ebenfalls sowohl `Send` als auch `Sync` implementiert.
So kann zum Beispiel ein Objekt vom Typ `Arc<RefCell<U>>` nicht von einem Thread zum anderen übertragen werden da
[`RefCell`
](choosing-your-guarantees.html#refcell%3Ct%3E) nicht `Sync` implementiert, dementsprechend kann `Arc<RefCell<U>>` nicht `Send` implementieren.


## Threads

Rusts Standardbibliothek enthält auch eine Bibliothek für Threads,
`std::thread`, die es dir erlaubt Code parallel auszuführen.
Hier mal ein Beispiel:

```rust
use std::thread;

fn main() {
    thread::spawn(|| {
        println!("Hello from a thread!");
    });
}
```

Die Methode `thread::spawn()` nimmt eine [Closure](Closures.html) an,
die dann im neuen Thread ausgeführt wird.
Der Handle den sie zurück gibt,
kann benutzt werden um zu warten bis der Kind-Thread fertig ist und dessen Ergebnis zu erhalten:

```rust
use std::thread;

fn main() {
    let handle = thread::spawn(|| {
        "Hello from a thread!"
    });

    println!("{}", handle.join().unwrap());
}
```

Es bieten zwar viele Sprachen Möglichkeiten an Threads zu starten,
das ist allerdings sehr unsicher.
Es gibt ganze Bücher darüber, wie man Fehler,
die dabei auftreten können, wenn zwei Threads auf den gleichen Speicher zugreifen, verhindern kann.
Rust hilft hier mit seinem Typsystem, indem es Raceconditions bereits beim Kompilieren verhindert.
Wie teilt man also nun eigentlich Sachen zwischen Threads?

## sicherer geteilter und veränderbarer Speicher

Rusts Typsystem biete ein Konzept an,
das zu gut klingt um wahr zu sein: "Sicherer geteilter, veränderbarer Speicher".
Unter Programmierern ist es allgemein bekannt, dass von mehreren Threads aus schreibbarer Speicher die Wurzel allen Übels ist.

> Shared mutable state is the root of all evil. Most languages attempt to deal
> with this problem through the 'mutable' part, but Rust deals with it by
> solving the 'shared' part.

Das gleiche [Besitz System](Besitz.html) das uns dabei hilft Zeiger richtig zu benutzen hilft uns auch dabei Raceconditions zu vermeiden,
die schlimmste Art von Bugs bei Nebenläufigkeit.

```ignore
use std::thread;

fn main() {
    let mut data = vec![1, 2, 3];

    for i in 0..3 {
        thread::spawn(move || {
            data[i] += 1;
        });
    }

    thread::sleep_ms(50);
}
```

führt zu diesem Fehler:

```text
8:17 error: capture of moved value: `data`
        data[i] += 1;
        ^~~~
```

Rust weiß dass das nicht sicher wäre.
Wenn wir eine Referenz auf `data` in jedem Thread haben,
dann müßte auch jeder Thread Besitzer von `data` sein.
Das geht in Rust nicht.

Also brauchen wir einen Typen, der es uns erlaubt mehrere Referenzen auf einen Wert zu haben, die wir auf mehrere Threads verteilen können.
Sprich, einen Typen der `Sync` implementiert.

Dafür benutzen wir `Arc<T>`, *Atomarer Referenz Count* (atomarer Referenzzähler).
`Arc<T>` ist ähnlich wie `Box<T>`,
nur dass es erlaubt Zugriff auf seinen Inhalt von mehreren Referenzen aus zu haben.
Es können sich quasi mehrere Threads den Besitz teilen.
Reference Counting bedeutet in diesem Zusammenhang,
dass gezählt wird, wieviele Referenzen zu einem Wert existieren.
Atomar bedeutet, dass Raceconditions nicht möglich sind.

```ignorele
use std::thread;
use std::sync::Arc;

fn main() {
    let mut data = Arc::new(vec![1, 2, 3]);

    for i in 0..3 {
        let data = data.clone();
        thread::spawn(move || {
            data[i] += 1;
        });
    }

    thread::sleep_ms(50);
}
```

Wenn wir hier `clone()` auf unser `Arc<T>` aufrufen,
wird intern ein Counter inkrementiert und ein Handle an den Thread weitergegeben.

Und... immer noch ein Fehler:

```text
<anon>:11:24 error: cannot borrow immutable borrowed content as mutable
<anon>:11                    data[i] += 1;
                             ^~~~
```

`Arc<T>` geht davon aus, dass sein Inhalt sicher geteilt werden kann, also auch `Sync` implementiert.
Das gilt für unseren Wert nur solange er unveränderlich ist.
Aber wir wollen ja etwas verändern, also müssen wir irgendwie sicherstellen, dass immer nur ein Thread gleichzeitig unseren Wert verändern kann.
Sie müssen sich gegenseitig ausschließen oder *mutually exclude* another.

Dafür gibt es den Typ `Mutex<T>`!
Hier also endlich die funktionierende Variante:

```rust
use std::sync::{Arc, Mutex};
use std::thread;

fn main() {
    let data = Arc::new(Mutex::new(vec![1, 2, 3]));

    for i in 0..3 {
        let data = data.clone();
        thread::spawn(move || {
            let mut data = data.lock().unwrap();
            data[i] += 1;
        });
    }

    thread::sleep_ms(50);
}
```

Beachte dass der Wert von `i` in die Closure kopiert wird und nicht zwischen den Threads geteilt wird.
Beachte außerdem, dass [`lock`](http://doc.rust-lang.org/stable/std/sync/struct.Mutex.html#method.lock) eine Methode von
[`Mutex`](http://doc.rust-lang.org/stable/std/sync/struct.Mutex.html) folgende Signatur hat:

```ignore
fn lock(&self) -> LockResult<MutexGuard<T>>
```

und weil `Send` für `MutexGuard<T>` nicht implementiert ist kann der Guard keine Threadgrenze überschreiten, wodurch Locks nur threadlokal akquiriert und freigegeben werden können.

Schauen wir uns das doch mal genauer an:

```rust
# use std::sync::{Arc, Mutex};
# use std::thread;
# fn main() {
#     let data = Arc::new(Mutex::new(vec![1, 2, 3]));
#     for i in 0..3 {
#         let data = data.clone();
thread::spawn(move || {
    let mut data = data.lock().unwrap();
    data[i] += 1;
});
#     }
#     thread::sleep_ms(50);
# }
```

Erst rufen wir `lock()` auf, wodurch wir das Lock auf das Mutex akquirieren.
Weil das fehlschlagen könnte gibt `lock()` ein `Result<T, E>` zurück.
Das `unwrap()` ist nur hier im Beispiel angemessen.
Sobald wir das Lock haben dürfen wir endlich den Wert verändern.

Zum Schluss warten wir noch mit einem Timer, das ist nicht ideal,
weil wir die Zeit genau abschätzen müssten.
Besser wäre einer der Mechanismen den Rusts Standardbibliothek zum Synchronisieren von Threads bereithält: Channels.

## Channels

Hier ist eine Variante des obigen Beispiels in der wir Channels zur Synchronisation verwenden, anstatt eine bestimmte Zeit zu warten:


```rust
use std::sync::{Arc, Mutex};
use std::thread;
use std::sync::mpsc;

fn main() {
    let data = Arc::new(Mutex::new(0));

    let (tx, rx) = mpsc::channel();

    for _ in 0..10 {
        let (data, tx) = (data.clone(), tx.clone());

        thread::spawn(move || {
            let mut data = data.lock().unwrap();
            *data += 1;

            tx.send(());
        });
    }

    for _ in 0..10 {
        rx.recv();
    }
}
```

Wir nutzen die Methode `mpsc::channel()` um einen Channel zu erzeugen.
Dann `send`en wir einfach `()` hindurch und warten darauf bis Zehn davon zurückgekommen sind.

Dieser Channel sendet zwar nur einfache Signale, aber wir alles was `Send` implementiert durch den Channel senden!

```rust
use std::thread;
use std::sync::mpsc;

fn main() {
    let (tx, rx) = mpsc::channel();

    for i in 0..10 {
        let tx = tx.clone();

        thread::spawn(move || {
            let answer = i * i;

            tx.send(answer);
        });
    }

    for _ in 0..10 {
        println!("{}", rx.recv().unwrap());
    }
}
```


Hier erzeugen wir 10 Threads und lassen jeden das Quadrat einer Zahl berechnen (`i` zum Zeitpunkt von `spawn()`) und dann mit `send()` zurücksenden.

## Panics

Eine `panic!` crasht den aktuellen Thread, deshalb kann man in Rust Threads als Mechanismus zur Isolation verwenden:

```rust
use std::thread;

let handle = thread::spawn(move || {
    panic!("oops!");
});

let result = handle.join();

assert!(result.is_err());
```

`Thread.join()` gibt uns ein `Result`, welches zeigt, ob der Thread erfolgreich war oder ob eine `panic!` aufgetreten ist.
