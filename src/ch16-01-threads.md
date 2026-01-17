## Mit Strängen (threads) Programmcode gleichzeitig ausführen

In den meisten aktuellen Betriebssystemen wird der Code eines ausgeführten
Programms in einem _Prozess_ ausgeführt und das Betriebssystem verwaltet
mehrere Prozesse gleichzeitig. Innerhalb eines Programms kannst du auch
unabhängige Teile haben, die gleichzeitig laufen. Die Funktionalitäten, die
diese unabhängigen Teile ausführen, werden _Stränge_ (threads) genannt. Ein
Webserver könnte beispielsweise mehrere Stränge haben, damit er auf mehrere
Anfragen gleichzeitig reagieren kann.

Das Aufteilen der Berechnung in deinem Programm in mehrere Stränge, um mehrere
Aufgaben gleichzeitig auszuführen, kann die Performanz erhöhen, aber es erhöht
auch die Komplexität. Da Stränge gleichzeitig laufen können, gibt es keine
inhärente Garantie für die Reihenfolge, in der Teile deines Codes in
verschiedenen Strängen ausgeführt werden. Dies kann zu Problemen führen wie:

- Wettlaufsituationen (race conditions), bei denen Stränge auf Daten oder
  Ressourcen in einer inkonsistenten Reihenfolge zugreifen.
- Deadlocks, bei denen zwei Stränge auf den jeweils anderen warten, sodass
  beide Stränge nicht fortgesetzt werden können.
- Fehler, die nur in bestimmten Situationen auftreten und schwer zu
  reproduzieren und zu beheben sind.

Rust versucht, die negativen Auswirkungen bei der Verwendung von Strängen zu
mildern, aber die Programmierung in einem mehrsträngigen Kontext erfordert
immer noch sorgfältige Überlegungen und benötigt eine andere Code-Struktur als
bei Programmen, die in einem einzigen Strang laufen.

Programmiersprachen implementieren Stränge auf verschiedene Weise, und viele
Betriebssysteme bieten eine API, die die Sprache aufrufen kann, um neue Stränge
zu erstellen. Die Rust-Standardbibliothek verwendet ein _1:1_-Modell der
Strang-Implementierung, bei dem ein Programm einen Betriebssystem-Strang für
einen Sprach-Strang verwendet. Es gibt Kisten, die andere Strang-Modelle
implementieren, die andere Kompromisse als das 1:1-Modell eingehen. (Das
async-System von Rust, das wir uns im nächsten Kapitel ansehen werden, bietet
ebenfalls einen anderen Ansatz der Nebenläufigkeit.)

### Erstellen eines neuen Strangs mit `spawn`

Um einen neuen Strang zu erstellen, rufen wir die Funktion `thread::spawn` auf
und übergeben ihr einen Funktionsabschluss (closure) (wir haben in Kapitel 13
über Funktionsabschlüsse gesprochen), der den Code enthält, den wir im neuen
Strang ausführen wollen. Das Beispiel in Codeblock 16-1 gibt einen Text im
Hauptstrang und anderen Text im neuen Strang aus:

<span class="filename">Dateiname: src/main.rs</span>

```rust
use std::thread;
use std::time::Duration;

fn main() {
    thread::spawn(|| {
        for i in 1..10 {
            println!("Hallo Zahl {i} aus dem erzeugten Strang!");
            thread::sleep(Duration::from_millis(1));
        }
    });

    for i in 1..5 {
        println!("Hallo Zahl {i} aus dem Hauptstrang!");
        thread::sleep(Duration::from_millis(1));
    }
}
```

<span class="caption">Codeblock 16-1: Erstellen eines neuen Strangs, um einen
Text auszugeben, während der Hauptstrang einen anderen Text ausgibt</span>

Beachte, dass bei der Beendigung des Hauptstrangs eines Rust-Programms alle
erzeugten Stränge beendet werden, unabhängig davon, ob sie zu Ende gelaufen
sind oder nicht. Die Ausgabe dieses Programms kann jedes Mal ein wenig anders
sein, aber sie wird in etwa wie folgt aussehen:

```text
Hallo Zahl 1 aus dem Hauptstrang!
Hallo Zahl 1 aus dem erzeugten Strang!
Hallo Zahl 2 aus dem Hauptstrang!
Hallo Zahl 2 aus dem erzeugten Strang!
Hallo Zahl 3 aus dem Hauptstrang!
Hallo Zahl 3 aus dem erzeugten Strang!
Hallo Zahl 4 aus dem Hauptstrang!
Hallo Zahl 4 aus dem erzeugten Strang!
Hallo Zahl 5 aus dem erzeugten Strang!
```

Aufrufe von `thread::sleep` zwingen einen Strang, seine Ausführung für eine
kurze Zeit anzuhalten, sodass ein anderer Strang laufen kann. Die Stränge
werden sich wahrscheinlich abwechseln, aber das ist nicht garantiert: Es hängt
davon ab, wie dein Betriebssystem die Stränge organisiert (schedule). In diesem
Lauf hat der Hauptstrang zuerst etwas ausgegeben, obwohl sich die
Ausgabeanweisung des erzeugten Strangs weiter oben im Code befindet. Und obwohl
wir dem erzeugten Strang gesagt haben, er solle solange etwas ausgeben, bis `i`
den Wert `9` hat, kam er nur bis `5`, als sich der Hauptstrang beendet hat.

Wenn du diesen Code ausführst und nur Ausgaben aus dem Hauptstrang siehst oder
keine Überschneidungen feststellst, versuche, die Zahlen in den Bereichen zu
erhöhen, um dem Betriebssystem mehr Gelegenheit zu geben, zwischen den Strängen
zu wechseln.

### Warten auf das Ende aller Stränge

Der Code in Codeblock 16-1 beendet nicht nur den erzeugten Strang meist
vorzeitig, weil der Hauptstrangs endet, sondern weil es keine Garantie für die
Reihenfolge gibt, in der Stränge laufen. Wir können auch nicht garantieren,
dass der erzeugte Strang überhaupt zum Laufen kommt!

Wir können das Problem, dass der erzeugte Strang nicht läuft oder vorzeitig
beendet wird, beheben, indem wir den Rückgabewert von `thread::spawn` in einer
Variable speichern. Der Rückgabetyp von `thread::spawn` ist `JoinHandle<T>`.
Ein `JoinHandle<T>` ist ein aneigenbarer (owned) Wert, der, wenn wir die
Methode `join` darauf aufrufen, darauf wartet, bis sich sein Strang beendet.
Codeblock 16-2 zeigt, wie der `JoinHandle<T>` des Strangs, den wir in Codeblock
16-1 erstellt haben, verwendet und wie `join` aufgerufen wird, um
sicherzustellen, dass der erzeugte Strang beendet wird, bevor `main` endet:

<span class="filename">Dateiname: src/main.rs</span>

```rust
use std::thread;
use std::time::Duration;

fn main() {
    let handle = thread::spawn(|| {
        for i in 1..10 {
            println!("Hallo Zahl {i} aus dem erzeugten Strang!");
            thread::sleep(Duration::from_millis(1));
        }
    });

    for i in 1..5 {
        println!("Hallo Zahl {i} aus dem Hauptstrang!");
        thread::sleep(Duration::from_millis(1));
    }

    handle.join().unwrap();
}
```

<span class="caption">Codeblock 16-2: Speichern des `JoinHandle<T>` von
`thread::spawn`, um zu garantieren, dass der Strang bis zum Ende ausgeführt
wird</span>

Aufrufen von `join` auf `JoinHandle` blockiert den gerade laufenden Strang, bis
der durch `JoinHandle` repräsentierte Strang beendet ist. _Blockieren_ eines
Strangs bedeutet, dass der Strang daran gehindert wird, Arbeit auszuführen oder
sich zu beenden. Da wir den Aufruf von `join` nach der `for`-Schleife im
Hauptstrang gesetzt haben, sollte das Ausführen von Codeblock 16-2 eine Ausgabe
wie folgt erzeugen:

```text
Hallo Zahl 1 aus dem Hauptstrang!
Hallo Zahl 2 aus dem Hauptstrang!
Hallo Zahl 1 aus dem erzeugten Strang!
Hallo Zahl 3 aus dem Hauptstrang!
Hallo Zahl 2 aus dem erzeugten Strang!
Hallo Zahl 4 aus dem Hauptstrang!
Hallo Zahl 3 aus dem erzeugten Strang!
Hallo Zahl 4 aus dem erzeugten Strang!
Hallo Zahl 5 aus dem erzeugten Strang!
Hallo Zahl 6 aus dem erzeugten Strang!
Hallo Zahl 7 aus dem erzeugten Strang!
Hallo Zahl 8 aus dem erzeugten Strang!
Hallo Zahl 9 aus dem erzeugten Strang!
```

Die beiden Stränge setzen abwechselnd fort, aber der Hauptstrang wartet wegen
des Aufrufs von `handle.join()` und endet nicht, bis der erzeugte Strang
beendet ist.

Aber lass uns sehen, was passiert, wenn wir stattdessen `handle.join()` vor die
`for`-Schleife in `main` schieben, etwa so:

<span class="filename">Dateiname: src/main.rs</span>

```rust
use std::thread;
use std::time::Duration;

fn main() {
    let handle = thread::spawn(|| {
        for i in 1..10 {
            println!("Hallo Zahl {i} aus dem erzeugten Strang!");
            thread::sleep(Duration::from_millis(1));
        }
    });

    handle.join().unwrap();

    for i in 1..5 {
        println!("Hallo Zahl {i} aus dem Hauptstrang!");
        thread::sleep(Duration::from_millis(1));
    }
}
```

Der Hauptstrang wartet auf das Ende des erzeugten Strangs und führt dann seine
`for`-Schleife aus, sodass die Ausgabe nicht mehr überlappend ist, wie hier
gezeigt:

```text
Hallo Zahl 1 aus dem erzeugten Strang!
Hallo Zahl 2 aus dem erzeugten Strang!
Hallo Zahl 3 aus dem erzeugten Strang!
Hallo Zahl 4 aus dem erzeugten Strang!
Hallo Zahl 5 aus dem erzeugten Strang!
Hallo Zahl 6 aus dem erzeugten Strang!
Hallo Zahl 7 aus dem erzeugten Strang!
Hallo Zahl 8 aus dem erzeugten Strang!
Hallo Zahl 9 aus dem erzeugten Strang!
Hallo Zahl 1 aus dem Hauptstrang!
Hallo Zahl 2 aus dem Hauptstrang!
Hallo Zahl 3 aus dem Hauptstrang!
Hallo Zahl 4 aus dem Hauptstrang!
```

Kleine Details, z.B. wo `join` aufgerufen wird, können beeinflussen, ob deine
Stränge zur gleichen Zeit laufen oder nicht.

### Verwenden von `move`-Funktionsabschlüssen mit Strängen

Wir werden oft das Schlüsselwort `move` mit Funktionsabschlüssen verwenden, die
an `thread::spawn` übergeben werden, weil der Funktionsabschluss dann die
Eigentümerschaft an den Werten, die sie benutzt, von der Umgebung übernimmt und
damit die Eigentümerschaft an diesen Werten von einem Strang auf einen anderen
überträgt. In [„Erfassen von Referenzen oder Verschieben der
Eigentümerschaft“][capture] in Kapitel 13 haben wir `move` im Zusammenhang mit
Funktionsabschlüssen besprochen. Jetzt werden wir uns mehr auf die Interaktion
zwischen `move` und `thread::spawn` konzentrieren.

Beachte in Codeblock 16-1, dass der Funktionsabschluss, den wir an
`thread::spawn` übergeben, keine Argumente erfordert: Wir verwenden keine Daten
aus dem Hauptstrang im Code des erzeugten Strangs. Um Daten aus dem Hauptstrang
im erzeugten Strang zu verwenden, muss der Funktionsabschluss des erzeugten
Strangs die benötigten Werte erfassen. Codeblock 16-3 zeigt einen Versuch,
einen Vektor im Hauptstrang zu erstellen und ihn im erzeugten Strang zu
verwenden. Dies wird jedoch noch nicht funktionieren, wie du gleich sehen
wirst.

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

<span class="caption">Codeblock 16-3: Versuch, einen im Hauptstrang erzeugten
Vektor in einem anderen Strang zu verwenden</span>

Der Funktionsabschluss verwendet `v`, sodass er `v` erfasst und zum Teil der
Umgebung des Funktionsabschlusses macht. Da `thread::spawn` diesen
Funktionsabschluss in einem neuen Strang ausführt, sollten wir in der Lage
sein, auf `v` innerhalb dieses neuen Strangs zuzugreifen. Aber wenn wir dieses
Beispiel kompilieren, erhalten wir den folgenden Fehler:

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
auf `v` benötigt, versucht der Funktionsabschluss, `v` auszuleihen. Es gibt
jedoch ein Problem: Rust kann nicht sagen, wie lange der erzeugte Strang laufen
wird, sodass es nicht weiß, ob die Referenz auf `v` immer gültig sein wird.

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

<span class="caption">Codeblock 16-4: Ein Strang mit einem Funktionsabschluss,
der versucht, eine Referenz auf `v` vom Hauptstrang zu erfassen, der `v`
aufräumt</span>

Wenn Rust uns erlauben würde, diesen Code auszuführen, bestünde die
Möglichkeit, dass der erzeugte Strang sofort in den Hintergrund gestellt wird,
ohne überhaupt zu laufen. Der erzeugte Strang hat eine Referenz auf `v` im
Inneren, aber der Hauptstrang räumt `v` sofort auf, indem er die Funktion
`drop` benutzt, die wir in Kapitel 15 besprochen haben. Wenn der erzeugte
Strang dann mit der Ausführung beginnt, ist `v` nicht mehr gültig, sodass eine
Referenz darauf ebenfalls ungültig ist. Oh nein!

Um den Kompilierfehler in Codeblock 16-3 zu beheben, können wir die Hinweise
der Fehlermeldung verwenden:

```text
help: to force the closure to take ownership of `v` (and any other referenced variables), use the `move` keyword
  |
6 |     let handle = thread::spawn(move || {
  |                                ++++
```

Indem wir vor dem Funktionsabschluss das Schlüsselwort `move` hinzufügen,
zwingen wir den Funktionsabschluss dazu, die Eigentümerschaft der Werte zu
übernehmen, die er benutzt, anstatt zuzulassen, dass Rust daraus ableitet, dass
er sich die Werte ausleihen sollte. Die in Codeblock 16-5 gezeigte Änderung an
Codeblock 16-3 wird wie von uns beabsichtigt kompilieren und ausgeführt.

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

<span class="caption">Codeblock 16-5: Durch Verwenden des Schlüsselwortes
`move` zwigen wir den Funktionsabschluss, die Eigentümerschaft der von ihm
verwendeten Werte zu übernehmen</span>

Wir könnten versuchen, den Code in Codeblock 16-4 auf diesselbe Weise zu
reparieren, wo der Hauptstrang `drop` aufruft, während wir einen
`move`-Funktionsabschluss verwenden. Diese Lösung wird jedoch nicht
funktionieren, weil das, was Codeblock 16-4 versucht, aus einem anderen Grund
nicht erlaubt ist. Wenn wir dem Funktionsabschluss `move` hinzufügen, würden
wir `v` in die Umgebung des Funktionsabschlusses verschieben, und wir könnten
im Hauptstrang nicht mehr `drop` darauf aufrufen. Wir würden stattdessen diesen
Kompilierfehler erhalten:

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
Fehler im Code in Codeblock 16-3 erhalten, weil Rust konservativ war und nur
`v` für den Strang auslieh, was bedeutete, dass der Hauptstrang theoretisch die
Referenz des erzeugte Strangs ungültig machen konnte. Indem wir Rust anweisen,
die Eigentümerschaft von `v` in den erzeugte Strang zu verlagern, garantieren
wir Rust, dass der Hauptstrang `v` nicht mehr benutzen wird. Wenn wir Codeblock
16-4 auf die gleiche Weise ändern, verletzen wir die Eigentumsregeln, wenn wir
versuchen, `v` im Hauptstrang zu benutzen. Das Schlüsselwort `move` setzt Rusts
konservative Standardausleihe außer Kraft; es lässt uns nicht gegen die
Eigentumsregeln verstoßen.

Nachdem wir uns nun damit beschäftigt haben, was Stränge sind und welche
Methoden die Strang-API bietet, wollen wir uns nun einige Situationen ansehen,
in denen wir Stränge verwenden können.

[capture]: ch13-01-closures.html#erfassen-von-referenzen-oder-verschieben-der-eigentümerschaft
