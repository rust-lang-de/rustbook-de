## Variablen und Veränderlichkeit

Wie in Kapitel 2 erwähnt, sind Variablen standardmäßig unveränderlich. Dies ist
einer der vielen Stupser, die Rust dir gibt, um deinen Code so zu schreiben,
dass du die Vorteile von Sicherheit (safety) und einfacher Nebenläufigkeit
(easy concurrency) nutzt, die Rust bietet. Du hast jedoch immer noch die
Möglichkeit, deine Variablen veränderlich (mutable) zu machen. Lass uns
untersuchen, wie und warum Rust dich dazu ermutigt, die Unveränderlichkeit
(immutability) zu bevorzugen, und warum du manchmal vielleicht aussteigen
möchtest.

Wenn eine Variable unveränderlich ist, kannst du deren Wert nicht mehr ändern,
sobald ein Wert gebunden ist. Um dies zu veranschaulichen, lass uns ein neues
Projekt namens *variables* in deinem *projects*-Verzeichnis anlegen, indem wir
`cargo new variables` aufrufen.

Öffne dann in deinem neuen *variables*-Verzeichnis die Datei *src/main.rs* und
ersetze dessen Code durch folgenden Code, der sich noch nicht kompilieren
lässt:

<span class="filename">Dateiname: src/main.rs</span>

```rust,does_not_compile
fn main() {
    let x = 5;
    println!("Der Wert von x ist: {}", x);
    x = 6;
    println!("Der Wert von x ist: {}", x);
}
```

Speichere und starte das Programm mit `cargo run`. Du solltest eine
Fehlermeldung erhalten, wie in dieser Ausgabe gezeigt:

```console
$ cargo run
   Compiling variables v0.1.0 (file:///projects/variables)
error[E0384]: cannot assign twice to immutable variable `x`
 --> src/main.rs:4:5
  |
2 |     let x = 5;
  |         -
  |         |
  |         first assignment to `x`
  |         help: make this binding mutable: `mut x`
3 |     println!("Der Wert von x ist: {}", x);
4 |     x = 6;
  |     ^^^^^ cannot assign twice to immutable variable

error: aborting due to previous error

For more information about this error, try `rustc --explain E0384`.
error: could not compile `variables`

To learn more, run the command again with --verbose.
```

Dieses Beispiel zeigt, wie der Compiler dir hilft, Fehler in deinen Programmen
zu finden. Auch wenn Kompilierfehler frustrierend sein können, bedeuten sie
nur, dass dein Programm noch nicht sicher das tut, was du willst; sie bedeuten
*nicht*, dass du kein guter Programmierer bist! Erfahrene Rust-Entwickler
bekommen ebenfalls noch Kompilierfehler.

Die Fehlermeldung `cannot assign twice to immutable variable x` weist darauf
hin, dass du versucht hast, der unveränderlichen Variablen `x` einen zweiten
Wert zuzuweisen.

Es ist wichtig, dass wir Fehler zur Kompilierzeit erhalten, wenn wir versuchen,
einen Wert zu ändern, den wir zuvor als unveränderlich bezeichnet haben, weil
genau diese Situation zu Fehlern führen kann. Wenn ein Teil unseres Codes von
der Annahme ausgeht, dass sich ein Wert niemals ändern wird, und ein anderer
Teil unseres Codes diesen Wert ändert, ist es möglich, dass der erste Teil des
Codes nicht das tut, wozu er entwickelt wurde. Die Ursache für diese Art von
Fehler kann im Nachhinein schwer aufzuspüren sein, besonders wenn das zweite
Stück Code den Wert nur *gelegentlich* ändert.

In Rust garantiert der Compiler, dass sich ein Wert tatsächlich nicht ändert,
wenn du angibst, dass er sich nicht ändern darf. Das bedeutet, dass du beim
Lesen und Schreiben von Code nicht darauf achten musst, wie und wo sich ein
Wert ändern könnte. Dein Code ist somit leichter zu durchdenken.

Aber Veränderlichkeit kann sehr nützlich sein. Variablen sind nur standardmäßig
unveränderlich; wie du es in Kapitel 2 gemacht hast, kannst du sie veränderlich
machen, indem du vor den Variablennamen `mut` angibst. Zusätzlich zur
Möglichkeit, diesen Wert zu ändern, vermittelt `mut` den zukünftigen Lesern des
Codes die Absicht, indem es anzeigt, dass andere Teile des Codes den Wert
dieser Variablen ändern werden.

Lass uns zum Beispiel *src/main.rs* wie folgt ändern:

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let mut x = 5;
    println!("Der Wert von x ist: {}", x);
    x = 6;
    println!("Der Wert von x ist: {}", x);
}
```

Wenn wir das Programm jetzt ausführen, bekommen wir dies:

```console
$ cargo run
   Compiling variables v0.1.0 (file:///projects/variables)
    Finished dev [unoptimized + debuginfo] target(s) in 0.30s
     Running `target/debug/variables`
Der Wert von x ist: 5
Der Wert von x ist: 6
```

Wir dürfen den Wert, an den sich `x` bindet, von `5` auf `6` ändern, wenn `mut`
verwendet wird. In einigen Fällen wirst du eine Variable veränderlich machen
wollen, weil es den Code bequemer zu schreiben macht, als wenn er nur
unveränderliche Variablen hätte.

Es gibt mehrere Kompromisse, die zusätzlich zur Vermeidung von Fehlern in
Betracht gezogen werden müssen. In Fällen, in denen du beispielsweise große
Datenstrukturen verwendest, kann es schneller sein, eine vorhandene Instanz zu
mutieren, als neu zugewiesene Instanzen zu kopieren und zurückzugeben. Bei
kleineren Datenstrukturen kann es einfacher sein, neue Instanzen zu erstellen
und in einem funktionelleren Programmierstil zu schreiben, sodass eine
geringere Performanz ein lohnender Nachteil sein kann, um diese Klarheit zu
erlangen.

### Unterschiede zwischen Variablen und Konstanten

Den Wert einer Variable nicht ändern zu können, könnte dich an ein anderes
Programmierkonzept erinnert haben, das die meisten anderen Sprachen haben:
*Konstanten*. Wie unveränderliche Variablen sind Konstanten Werte, die an einen
Namen gebunden sind und sich nicht ändern dürfen, aber es gibt einige
Unterschiede zwischen Konstanten und Variablen.

Erstens ist es dir nicht erlaubt, `mut` mit Konstanten zu verwenden. Konstanten
sind nicht nur von vornherein unveränderlich &ndash; sie sind immer
unveränderlich.

Du deklarierst Konstanten mit dem Schlüsselwort `const` anstelle des
Schlüsselworts `let` und der Typ des Wertes *muss* annotiert werden. Wir sind
dabei, Typen und Typ-Annotationen im nächsten Abschnitt
[„Datentypen“][data-types] zu behandeln, also mach dir jetzt keine Gedanken
über die Details. Du musst nur wissen, dass du den Typ immer annotieren musst.

Konstanten können in jedem Gültigkeitsbereich deklariert werden, auch im
globalen Gültigkeitsbereich, was sie für Werte nützlich macht, über die viele
Teile des Codes Bescheid wissen müssen.

Der letzte Unterschied besteht darin, dass Konstanten nur auf einen konstanten
Ausdruck gesetzt werden dürfen, nicht auf das Ergebnis eines Funktionsaufrufs
oder einen anderen Wert, der nur zur Laufzeit berechnet werden könnte.

Hier ist ein Beispiel für eine Konstantendeklaration, bei der der Name der
Konstanten `MAX_POINTS` lautet und ihr Wert auf 100.000 gesetzt ist. (Rusts
Namenskonvention für Konstanten ist, nur Großbuchstaben mit Unterstrichen
zwischen den Wörtern zu verwenden, und Unterstriche können in numerische
Literale eingefügt werden, um die Lesbarkeit zu verbessern.)

```rust
const MAX_POINTS: u32 = 100_000;
```

Konstanten sind für die gesamte Laufzeit eines Programms in dem
Gültigkeitsbereich gültig, in dem sie deklariert wurden. Damit sind sie eine
nützliche Wahl für Werte in deiner Anwendungsdomäne, über die mehrere Teile des
Programms Bescheid wissen müssen, z.B. die maximale Punktzahl, die jeder
Spieler eines Spiels erhalten darf, oder die Lichtgeschwindigkeit.

Das Benennen von hartkodierten Werten, die im gesamten Programm als Konstanten
verwendet werden, ist nützlich, um die Bedeutung dieses Wertes zukünftigen
Code-Betreuern zu vermitteln. Es ist auch hilfreich, nur eine Stelle in deinem
Code zu haben, die du ändern musst, wenn der hartkodierte Wert in Zukunft
aktualisiert werden müsste.

### Beschatten (shadowing)

Wie du in der Anleitung zum Ratespiel im Abschnitt [„Vergleichen der Schätzung
mit der Geheimzahl“][comparing-the-guess-to-the-secret-number] in Kapitel 2
gesehen hast, kannst du eine neue Variable mit dem gleichen Namen wie eine
vorherige Variable deklarieren, und die neue Variable beschattet die vorherige
Variable. Die Rust-Entwickler sagen, dass die erste Variable von der zweiten
*beschattet* (shadowed) wird, was bedeutet, dass der Wert der zweiten Variable
das ist, was erscheint, wenn die Variable verwendet wird. Wir können eine
Variable beschatten, indem wir denselben Variablenamen verwenden und das
Schlüsselwort `let` wie folgt wiederholen:

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let x = 5;

    let x = x + 1;

    let x = x * 2;

    println!("Der Wert von x ist: {}", x);
}
```

Dieses Programm bindet zunächst `x` an den Wert `5`. Dann beschattet es `x`,
indem es `let x =` wiederholt, den ursprünglichen Wert nimmt und `1` addiert,
sodass der Wert von `x` dann `6` ist. Die dritte Anweisung `let` beschattet
ebenfalls `x`, indem sie den vorherigen Wert mit `2` multipliziert, um für `x`
den Endwert `12` zu erhalten. Wenn wir dieses Programm ausführen, wird es
folgendes ausgeben:

```console
$ cargo run
   Compiling variables v0.1.0 (file:///projects/variables)
    Finished dev [unoptimized + debuginfo] target(s) in 0.31s
     Running `target/debug/variables`
Der Wert von x ist: 12
```

Beschatten unterscheidet sich vom Markieren einer Variable mit `mut`, weil wir
einen Kompilierfehler erhalten, wenn wir versehentlich versuchen, diese
Variable neu zuzuweisen, ohne das Schlüsselwort `let` zu verwenden. Durch das
Verwenden von `let` können wir einige wenige Transformationen an einem Wert
durchführen, aber die Variable ist unveränderlich, nachdem diese
Transformationen abgeschlossen sind.

Der andere Unterschied zwischen `mut` und Beschatten besteht darin, dass wir,
weil wir effektiv eine neue Variable erstellen, wenn wir das Schlüsselwort
`let` erneut verwenden, den Typ des Wertes ändern können, aber denselben Namen
wiederverwenden. Nehmen wir zum Beispiel an, unser Programm bittet einen
Benutzer, durch Eingeben von Leerzeichen zu zeigen, wie viele Leerzeichen er
zwischen irgendeinem Text haben möchte, aber wir möchten diese Eingabe in
Wirklichkeit als Zahl speichern:

```rust
let spaces = "   ";
let spaces = spaces.len();
```

Dieses Konstrukt ist erlaubt, weil die erste Variable `spaces` ein String-Typ
ist und die zweite Variable `spaces`, die eine brandneue Variable ist, die
zufällig den gleichen Namen wie die erste hat, ein Zahlentyp ist. Das
Beschatten erspart es uns also, uns verschiedene Namen auszudenken, z.B.
`spaces_str` und `spaces_num`; stattdessen können wir den einfacheren Namen
`spaces` wiederverwenden. Wenn wir jedoch versuchen, dafür `mut` zu verwenden,
wie hier gezeigt, erhalten wir einen Kompilierfehler:

```rust,does_not_compile
let mut spaces = "   ";
spaces = spaces.len();

```

Der Fehler besagt, dass es uns nicht erlaubt ist, den Typ einer Variable zu
mutieren:

```console
$ cargo run
   Compiling variables v0.1.0 (file:///projects/variables)
error[E0308]: mismatched types
 --> src/main.rs:3:14
  |
3 |     spaces = spaces.len();
  |              ^^^^^^^^^^^^ expected `&str`, found `usize`

error: aborting due to previous error

For more information about this error, try `rustc --explain E0308`.
error: could not compile `variables`

To learn more, run the command again with --verbose.
```

Nachdem wir nun untersucht haben, wie Variablen funktionieren, wollen wir uns
weitere Datentypen ansehen, die sie haben können.

[comparing-the-guess-to-the-secret-number]:
ch02-00-guessing-game-tutorial.html#vergleichen-der-schätzung-mit-der-geheimzahl
[data-types]: ch03-02-data-types.html
