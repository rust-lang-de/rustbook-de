## Mit Strängen (threads) Programmcode gleichzeitig ausführen

In den meisten aktuellen Betriebssystemen wird der Code eines ausgeführten
Programms in einem *Prozess* ausgeführt und das Betriebssystem verwaltet
mehrere Prozesse gleichzeitig. Innerhalb deines Programms kannst du auch
unabhängige Teile haben, die gleichzeitig laufen. Die Funktionalitäten, die
diese unabhängigen Teile ausführen, werden *Stränge* (threads) genannt.

Das Aufteilen der Berechnung in deinem Programm in mehrere Stränge kann die
Performanz verbessern, da das Programm mehrere Aufgaben gleichzeitig ausführt,
aber es erhöht auch die Komplexität. Da Stränge gleichzeitig laufen können,
gibt es keine inhärente Garantie für die Reihenfolge, in der Teile deines Codes
in verschiedenen Strängen ausgeführt werden. Dies kann zu Problemen führen
wie:

* Wettlaufsituationen (race conditions), bei denen Stränge auf Daten oder
  Ressourcen in einer inkonsistenten Reihenfolge zugreifen.
* Deadlocks, bei denen zwei Stränge darauf warten, dass der jeweils andere
  Strang eine Ressource freigibt, sodass beide Stränge nicht fortgesetzt werden
  können.
* Fehler, die nur in bestimmten Situationen auftreten und schwer zu
  reproduzieren und zu beheben sind.

Rust versucht, die negativen Auswirkungen bei der Verwendung von Strängen zu
mildern, aber die Programmierung in einem mehrsträngigen Kontext erfordert
immer noch sorgfältige Überlegungen und benötigt eine andere Code-Struktur als
bei Programmen, die in einem einzigen Strang laufen.

Programmiersprachen implementieren Stränge auf verschiedene Weise. Viele
Betriebssysteme bieten eine API zum Erstellen neuer Stränge. Dieses Modell, bei
dem eine Sprache die API des Betriebssystems aufruft, um Stränge zu erstellen,
wird manchmal *1:1* genannt, das bedeutet einen Betriebssystem-Strang pro
Strang in der Sprache.

Viele Programmiersprachen bringen ihre eigene spezielle Implementierung von
Strängen mit. Von Programmiersprachen bereitgestellte Stränge sind als *grüne*
Stränge (green threads) bekannt und Sprachen, die diese grünen Stränge
verwenden, führen sie im Kontext einer verschiedenen Zahl von
Betriebssystem-Strängen aus. Aus diesem Grund wird das Modell mit grünen
Strängen als *M:N*-Modell bezeichnet: Es gibt `M` grüne Stränge auf `N`
Betriebssystem-Strängen, wobei `M` und `N` nicht notwendigerweise die gleiche
Zahl sind.

Jedes Modell hat seine eigenen Vorteile und Kompromisse und der wichtigste
Kompromiss für Rust ist die Laufzeitunterstützung. *Laufzeit* (runtime) ist ein
verwirrender Begriff und kann in verschiedenen Kontexten unterschiedliche
Bedeutungen haben.

In diesem Zusammenhang meinen wir mit *Laufzeit* Code, der von der Sprache in
jeder Binärdatei enthalten ist. Dieser Code kann groß oder klein sein, abhängig
von der Sprache, aber jede Nicht-Assembler-Sprache wird eine gewisse Menge an
Laufzeit-Code haben. Aus diesem Grund meinen Leute umgangssprachlich, wenn sie
sagen, eine Sprache habe „keine Laufzeit“, dass sie oft eine „kleine Laufzeit“
hat. Kleinere Laufzeiten haben weniger Funktionen, haben aber den Vorteil, dass
sie zu kleineren Binärdateien führen, die es leichter machen, die Sprache mit
anderen Sprachen in mehr Kontexten zu kombinieren. Obwohl viele Sprachen damit
einverstanden sind, die Laufzeitgröße im Tausch gegen mehr Funktionen zu
erhöhen, kann Rust fast keine Laufzeit haben und kann keine Kompromisse
eingehen, wenn es darum geht, C zur Aufrechterhaltung der Performanz
aufzurufen.
     
Das M:N-Modell bei grünen Strängen erfordert eine größere Sprachlaufzeit zur
Verwaltung von Strängen. Daher bietet die Rust-Standardbibliothek nur eine
Implementierung von 1:1-Strängen. Da Rust solch eine Sprache auf niedriger
Ebene ist, gibt es Kisten (crates), die M:N-Stränge implementieren, wenn du den
Mehraufwand (overhead) lieber gegen Aspekte wie mehr Kontrolle darüber, welche
Stränge wann laufen, und geringere Kosten für den Kontextwechsel (context
switching) eintauschen möchtest.

Nachdem wir nun Stränge in Rust definiert haben, wollen wir untersuchen, wie
die Strang-bezogene API, die von der Standardbibliothek bereitgestellt wird,
verwendet werden kann.

### Erstellen eines neuen Strangs mit `spawn`

Um einen neuen Strang zu erstellen, rufen wir die Funktion `thread::spawn` auf
und übergeben ihr einen Funktionsabschluss (closure) (wir haben in Kapitel 13
über Funktionsabschlüsse gesprochen), der den Code enthält, den wir im neuen
Strang ausführen wollen. Das Beispiel in Codeblock 16-1 gibt etwas Text im
Hauptstrang und anderen Text im neuen Strang aus:

<span class="filename">Dateiname: src/main.rs</span>

```rust
use std::thread;
use std::time::Duration;

fn main() {
    thread::spawn(|| {
        for i in 1..10 {
            println!("Hallo Zahl {} aus dem erzeugten Strang!", i);
            thread::sleep(Duration::from_millis(1));
        }
    });

    for i in 1..5 {
        println!("Hallo Zahl {} aus dem Hauptstrang!", i);
        thread::sleep(Duration::from_millis(1));
    }
}
```

<span class="caption">Codeblock 16-1: Erstellen eines neuen Strangs, um eine
Sache auszugeben, während der Hauptstrang etwas anderes ausgibt</span>

Beachte, dass mit dieser Funktion der neue Strang beendet wird, wenn der
Hauptstrang endet, unabhängig davon, ob er zu Ende gelaufen ist oder nicht. Die
Ausgabe dieses Programms kann jedes Mal ein wenig anders sein, aber sie wird
ähnlich wie die folgende aussehen:

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
davon ab, wie dein Betriebssystem die Stränge organisiert (schedules). In
diesem Lauf wurde der Hauptstrang zuerst ausgegeben, obwohl die
Ausgabeanweisung aus dem erzeugten Strang zuerst im Code erscheint. Und obwohl
wir dem erzeugten Strang gesagt haben, er solle ausgeben, bis `i` 9 ist, kam er
nur bis 5, bis sich der Hauptstrang beendet hat.

Wenn du diesen Code ausführst und nur Ausgaben aus dem Hauptstrang siehst oder
keine Überschneidungen feststellst, versuche, die Zahlen in den Bereichen zu
erhöhen, um dem Betriebssystem mehr Gelegenheit zu geben, zwischen den Strängen
zu wechseln.

### Warten auf das Ende aller Stränge mit `join`

Der Code in Codeblock 16-1 beendet nicht nur den erzeugten Strang meist
vorzeitig aufgrund des Endes des Hauptstrangs, sondern kann auch nicht
garantieren, dass der erzeugte Strang überhaupt zum Laufen kommt. Der Grund
dafür ist, dass es keine Garantie für die Reihenfolge gibt, in der die Stränge
laufen!

Wir können das Problem, dass der erzeugte Strang nicht oder nicht vollständig
ausgeführt wird, beheben, indem wir den Rückgabewert von `thread::spawn` in
einer Variablen speichern. Der Rückgabetyp von `thread::spawn` ist
`JoinHandle`. Ein `JoinHandle` ist ein aneigenbarer (owned) Wert, der, wenn wir
die Methode `join` darauf aufrufen, darauf wartet, bis sich sein Strang
beendet. Codeblock 16-2 zeigt, wie der `JoinHandle` des Strangs, den wir in
Codeblock 16-1 erstellt haben, verwendet und `join` aufgerufen wird, um
sicherzustellen, dass der erzeugte Strang beendet wird, bevor `main` endet:

<span class="filename">Dateiname: src/main.rs</span>

```rust
use std::thread;
use std::time::Duration;

fn main() {
    let handle = thread::spawn(|| {
        for i in 1..10 {
            println!("Hallo Zahl {} aus dem erzeugten Strang!", i);
            thread::sleep(Duration::from_millis(1));
        }
    });

    for i in 1..5 {
        println!("Hallo Zahl {} aus dem Hauptstrang!", i);
        thread::sleep(Duration::from_millis(1));
    }

    handle.join().unwrap();
}
```

<span class="caption">Codeblock 16-2: Speichern eines `JoinHandle` von
`thread::spawn`, um zu garantieren, dass der Strang bis zum Ende ausgeführt
wird</span>

Aufrufen von `join` auf `JoinHandle` blockiert den gerade laufenden Strang, bis
der durch `JoinHandle` repräsentierte Strang beendet ist. *Blockieren* eines
Strangs bedeutet, dass der Strang daran gehindert wird, Arbeit auszuführen oder
sich zu beenden. Da wir den Aufruf von `join` nach der `for`-Schleife im
Hauptstrang gesetzt haben, sollte das Ausführen von Codeblock 16-2 eine
ähnliche Ausgabe erzeugen:

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
            println!("Hallo Zahl {} aus dem erzeugten Strang!", i);
            thread::sleep(Duration::from_millis(1));
        }
    });

    handle.join().unwrap();

    for i in 1..5 {
        println!("Hallo Zahl {} aus dem Hauptstrang!", i);
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

Der `move`-Funktionsabschluss wird oft zusammen mit `thread::spawn` verwendet,
weil es dir erlaubt, Daten von einem Strang in einem anderen Strang zu
verwenden.

In Kapitel 13 haben wir erwähnt, dass wir das Schlüsselwort `move` vor der
Parameterliste eines Funktionsabschlusses verwenden können, um den
Funktionsabschluss dazu zu zwingen, die Eigentümerschaft der Werte zu
übernehmen, die er aus der Umgebung verwendet. Diese Technik ist besonders
nützlich, wenn neue Stränge erstellt werden, um die Eigentümerschaft an Werten
von einem Strang auf einen anderen zu übertragen.

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
        println!("Hier ist ein Vektor: {:?}", v);
    });

    handle.join().unwrap();
}
```

<span class="caption">Codeblock 16-3: Versuch, einen durch den Hauptstrang
erzeugten Vektor in einem anderen Strang zu verwenden</span>

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
7 |         println!("Hier ist ein Vektor: {:?}", v);
  |                                               - `v` is borrowed here
  |
note: function requires argument type to outlive `'static`
 --> src/main.rs:6:18
  |
6 |       let handle = thread::spawn(|| {
  |  __________________^
7 | |         println!("Hier ist ein Vektor: {:?}", v);
8 | |     });
  | |______^
help: to force the closure to take ownership of `v` (and any other referenced variables), use the `move` keyword
  |
6 |     let handle = thread::spawn(move || {
  |                                ^^^^^^^

error: aborting due to previous error

For more information about this error, try `rustc --explain E0373`.
error: could not compile `threads`

To learn more, run the command again with --verbose.
```

Rust *folgert*, wie man `v` erfasst, und weil `println!` nur eine Referenz auf
`v` benötigt, versucht der Funktionsabschluss, `v` auszuleihen. Es gibt jedoch
ein Problem: Rust kann nicht sagen, wie lange der erzeugte Strang laufen wird,
sodass es nicht weiß, ob die Referenz auf `v` immer gültig sein wird.

Codeblock 16-4 zeigt ein Szenario, das eine Referenz auf `v` hat, die eher
nicht gültig ist:

<span class="filename">Dateiname: src/main.rs</span>

```rust,does_not_compile
use std::thread;

fn main() {
    let v = vec![1, 2, 3];

    let handle = thread::spawn(|| {
        println!("Hier ist ein Vektor: {:?}", v);
    });

    drop(v); // Oh nein!

    handle.join().unwrap();
}
```

<span class="caption">Codeblock 16-4: Ein Strang mit einem Funktionsabschluss,
der versucht, eine Referenz auf `v` vom Hauptstrang zu erfassen, der `v`
aufräumt</span>

Wenn wir diesen Code ausführen dürften, bestünde die Möglichkeit, dass der
erzeugte Strang sofort in den Hintergrund gestellt wird, ohne überhaupt zu
laufen. Der erzeugte Strang hat eine Referenz auf `v` im Inneren, aber der
Hauptstrang räumt `v` sofort auf, indem er die Funktion `drop` benutzt, die wir
in Kapitel 15 besprochen haben. Wenn der erzeugte Strang dann mit der
Ausführung beginnt, ist `v` nicht mehr gültig, sodass eine Referenz darauf
ebenfalls ungültig ist. Oh nein!

Um den Kompilierfehler in Codeblock 16-3 zu beheben, können wir die Hinweise
der Fehlermeldung verwenden:

```text
help: to force the closure to take ownership of `v` (and any other referenced variables), use the `move` keyword
  |
6 |     let handle = thread::spawn(move || {
  |                                ^^^^^^^
```

Indem wir vor dem Funktionsabschluss das Schlüsselwort `move` hinzufügen,
zwingen wir den Funktionsabschluss dazu, die Eigentümerschaft der Werte zu
übernehmen, die er benutzt, anstatt zuzulassen, dass Rust daraus ableitet, dass
er sich die Werte ausleihen sollte. Die in Codeblock 16-5 gezeigte Änderung an
Codeblock 16-3 wird wie von uns beabsichtigt kompilieren und ausgeführt:

<span class="filename">Dateiname: src/main.rs</span>

```rust
use std::thread;

fn main() {
    let v = vec![1, 2, 3];

    let handle = thread::spawn(move || {
        println!("Hier ist ein Vektor: {:?}", v);
    });

    handle.join().unwrap();
}
```

<span class="caption">Codeblock 16-5: Durch Verwenden des Schlüsselwortes
`move` zwigen wir den Funktionsabschluss, die Eigentümerschaft der von ihm
verwendeten Werte zu übernehmen</span>

Was würde mit dem Code in Codeblock 16-4 geschehen, bei dem der Hauptstrang
`drop` aufruft, wenn wir einen `move`-Funktionsabschluss verwenden? Würde
`move` den Fall lösen? Leider nein; wir würden einen anderen Fehler erhalten,
weil das, was in Codeblock 16-4 versucht wird, aus einem anderen Grund nicht
erlaubt ist. Wenn wir dem Funktionsabschluss `move` hinzufügen würden, würden
wir `v` in die Umgebung des Funktionsabschlusses verschieben, und wir könnten im
Hauptstrang nicht mehr `drop` darauf aufrufen. Wir würden stattdessen diesen
Kompilierfehler erhalten:

```console
$ cargo run
   Compiling threads v0.1.0 (file:///projects/threads)
error[E0382]: use of moved value: `v`
  --> src/main.rs:10:10
   |
4  |     let v = vec![1, 2, 3];
   |         - move occurs because `v` has type `Vec<i32>`, which does not implement the `Copy` trait
5  | 
6  |     let handle = thread::spawn(move || {
   |                                ------- value moved into closure here
7  |         println!("Hier ist ein Vektor: {:?}", v);
   |                                               - variable moved due to use in closure
...
10 |     drop(v); // Oh nein!
   |          ^ value used here after move

error: aborting due to previous error

For more information about this error, try `rustc --explain E0382`.
error: could not compile `threads`

To learn more, run the command again with --verbose.
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

Mit einem grundlegenden Verständnis von Strängen und der Strang-API wollen wir
uns ansehen, was wir mit Strängen noch machen können.
