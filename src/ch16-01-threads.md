## Mit Threads Programmcode gleichzeitig ausführen

In den meisten aktuellen Betriebssystemen wird der Code eines ausgeführten
Programms in einem _Prozess_ ausgeführt und das Betriebssystem verwaltet mehrere
Prozesse gleichzeitig. Innerhalb eines Programms kannst du auch unabhängige
Teile haben, die gleichzeitig laufen. Die Funktionalitäten, die diese
unabhängigen Teile ausführen, werden _Threads_ (engl. Stränge) genannt. Ein
Webserver könnte beispielsweise mehrere Threads haben, damit er auf mehrere
Anfragen gleichzeitig reagieren kann.

Das Aufteilen der Berechnung in deinem Programm in mehrere Threads, um mehrere
Aufgaben gleichzeitig auszuführen, kann die Performanz erhöhen, aber es erhöht
auch die Komplexität. Da Threads gleichzeitig laufen können, gibt es keine
inhärente Garantie für die Reihenfolge, in der Teile deines Codes in
verschiedenen Threads ausgeführt werden. Dies kann zu Problemen führen wie:

- Wettlaufsituationen (race conditions), bei denen Threads auf Daten oder
  Ressourcen in einer inkonsistenten Reihenfolge zugreifen.
- Deadlocks, bei denen zwei Threads auf den jeweils anderen warten, sodass
  beide Threads nicht fortgesetzt werden können.
- Fehler, die nur in bestimmten Situationen auftreten und schwer zu
  reproduzieren und zu beheben sind.

Rust versucht, die negativen Auswirkungen bei der Verwendung von Threads zu
mildern, aber die Programmierung in einem multi-threaded Kontext erfordert immer
noch sorgfältige Überlegungen und benötigt eine andere Code-Struktur als bei
Programmen, die in einem einzigen Thread laufen.

Programmiersprachen implementieren Threads auf verschiedene Weise, und viele
Betriebssysteme bieten eine API, die die Sprache aufrufen kann, um neue Threads
zu erstellen. Die Rust-Standardbibliothek verwendet ein _1:1_-Modell der
Thread-Implementierung, bei dem ein Programm einen Betriebssystem-Thread für
einen Sprach-Thread verwendet. Es gibt Crates, die andere Thread-Modelle
implementieren, die andere Kompromisse als das 1:1-Modell eingehen. (Das
async-System von Rust, das wir uns im nächsten Kapitel ansehen werden, bietet
ebenfalls einen anderen Ansatz der Nebenläufigkeit.)

### Erstellen eines neuen Threads mit `spawn`

Um einen neuen Thread zu erstellen, rufen wir die Funktion `thread::spawn` auf
und übergeben ihr einen Closure (wir haben in Kapitel 13 über Closures
gesprochen), der den Code enthält, den wir im neuen Thread ausführen wollen. Das
Beispiel in Codeblock 16-1 gibt einen Text im Haupt-Thread und anderen Text im
neuen Thread aus:

<span class="filename">Dateiname: src/main.rs</span>

```rust
use std::thread;
use std::time::Duration;

fn main() {
    thread::spawn(|| {
        for i in 1..10 {
            println!("Hallo Zahl {i} aus dem erzeugten Thread!");
            thread::sleep(Duration::from_millis(1));
        }
    });

    for i in 1..5 {
        println!("Hallo Zahl {i} aus dem Haupt-Thread!");
        thread::sleep(Duration::from_millis(1));
    }
}
```

<span class="caption">Codeblock 16-1: Erstellen eines neuen Threads, um einen
Text auszugeben, während der Haupt-Thread einen anderen Text ausgibt</span>

Beachte, dass bei der Beendigung des Haupt-Threads eines Rust-Programms alle
erzeugten Threads beendet werden, unabhängig davon, ob sie zu Ende gelaufen sind
oder nicht. Die Ausgabe dieses Programms kann jedes Mal ein wenig anders sein,
aber sie wird in etwa wie folgt aussehen:

```text
Hallo Zahl 1 aus dem Haupt-Thread!
Hallo Zahl 1 aus dem erzeugten Thread!
Hallo Zahl 2 aus dem Haupt-Thread!
Hallo Zahl 2 aus dem erzeugten Thread!
Hallo Zahl 3 aus dem Haupt-Thread!
Hallo Zahl 3 aus dem erzeugten Thread!
Hallo Zahl 4 aus dem Haupt-Thread!
Hallo Zahl 4 aus dem erzeugten Thread!
Hallo Zahl 5 aus dem erzeugten Thread!
```

Aufrufe von `thread::sleep` zwingen einen Thread, seine Ausführung für eine
kurze Zeit anzuhalten, sodass ein anderer Thread laufen kann. Die Threads werden
sich wahrscheinlich abwechseln, aber das ist nicht garantiert: Es hängt davon
ab, wie dein Betriebssystem die Threads organisiert (schedule). In diesem Lauf
hat der Haupt-Thread zuerst etwas ausgegeben, obwohl sich die Ausgabeanweisung
des erzeugten Threads weiter oben im Code befindet. Und obwohl wir dem erzeugten
Thread gesagt haben, er solle solange etwas ausgeben, bis `i` den Wert `9` hat,
kam er nur bis `5`, als sich der Haupt-Thread beendet hat.

Wenn du diesen Code ausführst und nur Ausgaben aus dem Haupt-Thread siehst oder
keine Überschneidungen feststellst, versuche, die Zahlen in den Bereichen zu
erhöhen, um dem Betriebssystem mehr Gelegenheit zu geben, zwischen den Threads
zu wechseln.

### Warten auf das Ende aller Threads

Der Code in Codeblock 16-1 beendet nicht nur den erzeugten Thread meist
vorzeitig, weil der Haupt-Threads endet, sondern weil es keine Garantie für die
Reihenfolge gibt, in der Threads laufen. Wir können auch nicht garantieren, dass
der erzeugte Thread überhaupt zum Laufen kommt!

Wir können das Problem, dass der erzeugte Thread nicht läuft oder vorzeitig
beendet wird, beheben, indem wir den Rückgabewert von `thread::spawn` in einer
Variable speichern. Der Rückgabetyp von `thread::spawn` ist `JoinHandle<T>`. Ein
`JoinHandle<T>` ist ein aneigenbarer (owned) Wert, der, wenn wir die Methode
`join` darauf aufrufen, darauf wartet, bis sich sein Thread beendet. Codeblock
16-2 zeigt, wie der `JoinHandle<T>` des Threads, den wir in Codeblock 16-1
erstellt haben, verwendet und wie `join` aufgerufen wird, um sicherzustellen,
dass der erzeugte Thread beendet wird, bevor `main` endet:

<span class="filename">Dateiname: src/main.rs</span>

```rust
use std::thread;
use std::time::Duration;

fn main() {
    let handle = thread::spawn(|| {
        for i in 1..10 {
            println!("Hallo Zahl {i} aus dem erzeugten Thread!");
            thread::sleep(Duration::from_millis(1));
        }
    });

    for i in 1..5 {
        println!("Hallo Zahl {i} aus dem Haupt-Thread!");
        thread::sleep(Duration::from_millis(1));
    }

    handle.join().unwrap();
}
```

<span class="caption">Codeblock 16-2: Speichern des `JoinHandle<T>` von
`thread::spawn`, um zu garantieren, dass der Thread bis zum Ende ausgeführt
wird</span>

Aufrufen von `join` auf `JoinHandle` blockiert den gerade laufenden Thread, bis
der durch `JoinHandle` repräsentierte Thread beendet ist. _Blockieren_ eines
Threads bedeutet, dass der Thread daran gehindert wird, Arbeit auszuführen oder
sich zu beenden. Da wir den Aufruf von `join` nach der `for`-Schleife im
Haupt-Thread gesetzt haben, sollte das Ausführen von Codeblock 16-2 eine Ausgabe
wie folgt erzeugen:

```text
Hallo Zahl 1 aus dem Haupt-Thread!
Hallo Zahl 2 aus dem Haupt-Thread!
Hallo Zahl 1 aus dem erzeugten Thread!
Hallo Zahl 3 aus dem Haupt-Thread!
Hallo Zahl 2 aus dem erzeugten Thread!
Hallo Zahl 4 aus dem Haupt-Thread!
Hallo Zahl 3 aus dem erzeugten Thread!
Hallo Zahl 4 aus dem erzeugten Thread!
Hallo Zahl 5 aus dem erzeugten Thread!
Hallo Zahl 6 aus dem erzeugten Thread!
Hallo Zahl 7 aus dem erzeugten Thread!
Hallo Zahl 8 aus dem erzeugten Thread!
Hallo Zahl 9 aus dem erzeugten Thread!
```

Die beiden Threads setzen abwechselnd fort, aber der Haupt-Thread wartet wegen
des Aufrufs von `handle.join()` und endet nicht, bis der erzeugte Thread beendet
ist.

Aber lass uns sehen, was passiert, wenn wir stattdessen `handle.join()` vor die
`for`-Schleife in `main` schieben, etwa so:

<span class="filename">Dateiname: src/main.rs</span>

```rust
use std::thread;
use std::time::Duration;

fn main() {
    let handle = thread::spawn(|| {
        for i in 1..10 {
            println!("Hallo Zahl {i} aus dem erzeugten Thread!");
            thread::sleep(Duration::from_millis(1));
        }
    });

    handle.join().unwrap();

    for i in 1..5 {
        println!("Hallo Zahl {i} aus dem Haupt-Thread!");
        thread::sleep(Duration::from_millis(1));
    }
}
```

Der Haupt-Thread wartet auf das Ende des erzeugten Threads und führt dann seine
`for`-Schleife aus, sodass die Ausgabe nicht mehr überlappend ist, wie hier
gezeigt:

```text
Hallo Zahl 1 aus dem erzeugten Thread!
Hallo Zahl 2 aus dem erzeugten Thread!
Hallo Zahl 3 aus dem erzeugten Thread!
Hallo Zahl 4 aus dem erzeugten Thread!
Hallo Zahl 5 aus dem erzeugten Thread!
Hallo Zahl 6 aus dem erzeugten Thread!
Hallo Zahl 7 aus dem erzeugten Thread!
Hallo Zahl 8 aus dem erzeugten Thread!
Hallo Zahl 9 aus dem erzeugten Thread!
Hallo Zahl 1 aus dem Haupt-Thread!
Hallo Zahl 2 aus dem Haupt-Thread!
Hallo Zahl 3 aus dem Haupt-Thread!
Hallo Zahl 4 aus dem Haupt-Thread!
```

Kleine Details, z.B. wo `join` aufgerufen wird, können beeinflussen, ob deine
Threads zur gleichen Zeit laufen oder nicht.

### Verwenden von `move`-Closures mit Threads

Wir werden oft das Schlüsselwort `move` mit Closures verwenden, die an
`thread::spawn` übergeben werden, weil der Closure dann die Eigentümerschaft an
den Werten, die sie benutzt, von der Umgebung übernimmt und damit die
Eigentümerschaft an diesen Werten von einem Thread auf einen anderen überträgt.
In [„Erfassen von Referenzen oder Verschieben der Eigentümerschaft“][capture] in
Kapitel 13 haben wir `move` im Zusammenhang mit Closures besprochen. Jetzt
werden wir uns mehr auf die Interaktion zwischen `move` und `thread::spawn`
konzentrieren.

Beachte in Codeblock 16-1, dass der Closure, den wir an `thread::spawn`
übergeben, keine Argumente erfordert: Wir verwenden keine Daten aus dem
Haupt-Thread im Code des erzeugten Threads. Um Daten aus dem Haupt-Thread im
erzeugten Thread zu verwenden, muss der Closure des erzeugten Threads die
benötigten Werte erfassen. Codeblock 16-3 zeigt einen Versuch, einen Vektor im
Haupt-Thread zu erstellen und ihn im erzeugten Thread zu verwenden. Dies wird
jedoch noch nicht funktionieren, wie du gleich sehen wirst.

<span class="filename">Dateiname: src/main.rs</span>

```rust,does_not_compile
use std::thread;

fn main() {
    let v = vec![1, 2, 3];

    let handle = thread::spawn(|| {
        println!("Hier ist ein Vektor: {v:?}");
    });

    handle.join().unwrap();
}
```

<span class="caption">Codeblock 16-3: Versuch, einen im Haupt-Thread erzeugten
Vektor in einem anderen Thread zu verwenden</span>

Der Closure verwendet `v`, sodass er `v` erfasst und zum Teil der Umgebung des
Closures macht. Da `thread::spawn` diesen Closure in einem neuen Thread
ausführt, sollten wir in der Lage sein, auf `v` innerhalb dieses neuen Threads
zuzugreifen. Aber wenn wir dieses Beispiel kompilieren, erhalten wir den
folgenden Fehler:

```console
$ cargo run
   Compiling threads v0.1.0 (file:///projects/threads)
error[E0373]: closure may outlive the current function, but it borrows `v`, which is owned by the current function
 --> src/main.rs:6:32
  |
6 |     let handle = thread::spawn(|| {
  |                                ^^ may outlive borrowed value `v`
7 |         println!("Hier ist ein Vektor: {v:?}");
  |                                         - `v` is borrowed here
  |
note: function requires argument type to outlive `'static`
 --> src/main.rs:6:18
  |
6 |       let handle = thread::spawn(|| {
  |  __________________^
7 | |         println!("Hier ist ein Vektor: {v:?}");
8 | |     });
  | |______^
help: to force the closure to take ownership of `v` (and any other referenced variables), use the `move` keyword
  |
6 |     let handle = thread::spawn(move || {
  |                                ++++

For more information about this error, try `rustc --explain E0373`.
error: could not compile `playground` (bin "playground") due to 1 previous error
```

Rust _folgert_, wie `v` zu erfassen ist, und weil `println!` nur eine Referenz
auf `v` benötigt, versucht der Closure, `v` auszuleihen. Es gibt jedoch ein
Problem: Rust kann nicht sagen, wie lange der erzeugte Thread laufen wird,
sodass es nicht weiß, ob die Referenz auf `v` immer gültig sein wird.

Codeblock 16-4 zeigt ein Szenario, das eine Referenz auf `v` hat, die eher
nicht gültig ist:

<span class="filename">Dateiname: src/main.rs</span>

```rust,does_not_compile
use std::thread;

fn main() {
    let v = vec![1, 2, 3];

    let handle = thread::spawn(|| {
        println!("Hier ist ein Vektor: {v:?}");
    });

    drop(v); // Oh nein!

    handle.join().unwrap();
}
```

<span class="caption">Codeblock 16-4: Ein Thread mit einem Closure, der
versucht, eine Referenz auf `v` vom Haupt-Thread zu erfassen, der `v`
aufräumt</span>

Wenn Rust uns erlauben würde, diesen Code auszuführen, bestünde die
Möglichkeit, dass der erzeugte Thread sofort in den Hintergrund gestellt wird,
ohne überhaupt zu laufen. Der erzeugte Thread hat eine Referenz auf `v` im
Inneren, aber der Haupt-Thread räumt `v` sofort auf, indem er die Funktion
`drop` benutzt, die wir in Kapitel 15 besprochen haben. Wenn der erzeugte
Thread dann mit der Ausführung beginnt, ist `v` nicht mehr gültig, sodass eine
Referenz darauf ebenfalls ungültig ist. Oh nein!

Um den Kompilierfehler in Codeblock 16-3 zu beheben, können wir die Hinweise
der Fehlermeldung verwenden:

```text
help: to force the closure to take ownership of `v` (and any other referenced variables), use the `move` keyword
  |
6 |     let handle = thread::spawn(move || {
  |                                ++++
```

Indem wir vor dem Closure das Schlüsselwort `move` hinzufügen, zwingen wir den
Closure dazu, die Eigentümerschaft der Werte zu übernehmen, die er benutzt,
anstatt zuzulassen, dass Rust daraus ableitet, dass er sich die Werte ausleihen
sollte. Die in Codeblock 16-5 gezeigte Änderung an Codeblock 16-3 wird wie von
uns beabsichtigt kompilieren und ausgeführt.

<span class="filename">Dateiname: src/main.rs</span>

```rust
use std::thread;

fn main() {
    let v = vec![1, 2, 3];

    let handle = thread::spawn(move || {
        println!("Hier ist ein Vektor: {v:?}");
    });

    handle.join().unwrap();
}
```

<span class="caption">Codeblock 16-5: Durch Verwenden des Schlüsselwortes `move`
zwigen wir den Closure, die Eigentümerschaft der von ihm verwendeten Werte zu
übernehmen</span>

Wir könnten versuchen, den Code in Codeblock 16-4 auf diesselbe Weise zu
reparieren, wo der Haupt-Thread `drop` aufruft, während wir einen `move`-Closure
verwenden. Diese Lösung wird jedoch nicht funktionieren, weil das, was Codeblock
16-4 versucht, aus einem anderen Grund nicht erlaubt ist. Wenn wir dem Closure
`move` hinzufügen, würden wir `v` in die Umgebung des Closures verschieben, und
wir könnten im Haupt-Thread nicht mehr `drop` darauf aufrufen. Wir würden
stattdessen diesen Kompilierfehler erhalten:

```console
$ cargo run
   Compiling threads v0.1.0 (file:///projects/threads)
error[E0382]: use of moved value: `v`
  --> src/main.rs:10:10
   |
 4 |     let v = vec![1, 2, 3];
   |         - move occurs because `v` has type `Vec<i32>`, which does not implement the `Copy` trait
 5 |
 6 |     let handle = thread::spawn(move || {
   |                                ------- value moved into closure here
 7 |         println!("Here's a vector: {v:?}");
   |                                     - variable moved due to use in closure
...
10 |     drop(v); // oh no!
   |          ^ value used here after move
   |
help: consider cloning the value before moving it into the closure
   |
 6 ~     let value = v.clone();
 7 ~     let handle = thread::spawn(move || {
 8 ~         println!("Here's a vector: {value:?}");
   |

For more information about this error, try `rustc --explain E0382`.
error: could not compile `threads` (bin "threads") due to 1 previous error
```

Die Eigentumsregeln von Rust haben uns wieder einmal gerettet! Wir haben einen
Fehler im Code in Codeblock 16-3 erhalten, weil Rust konservativ war und nur `v`
für den Thread auslieh, was bedeutete, dass der Haupt-Thread theoretisch die
Referenz des erzeugte Threads ungültig machen konnte. Indem wir Rust anweisen,
die Eigentümerschaft von `v` in den erzeugte Thread zu verlagern, garantieren
wir Rust, dass der Haupt-Thread `v` nicht mehr benutzen wird. Wenn wir Codeblock
16-4 auf die gleiche Weise ändern, verletzen wir die Eigentumsregeln, wenn wir
versuchen, `v` im Haupt-Thread zu benutzen. Das Schlüsselwort `move` setzt Rusts
konservativen Borrowing-Standard außer Kraft; es lässt uns nicht gegen die
Eigentumsregeln verstoßen.

Nachdem wir uns nun damit beschäftigt haben, was Threads sind und welche
Methoden die Thread-API bietet, wollen wir uns nun einige Situationen ansehen,
in denen wir Threads verwenden können.

[capture]: ch13-01-closures.html#erfassen-von-referenzen-oder-verschieben-der-eigentümerschaft
