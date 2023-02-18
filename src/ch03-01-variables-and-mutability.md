## Variablen und Veränderbarkeit

Wie im Abschnitt [„Speichern von Werten mit
Variablen“][storing-values-with-variables] erwähnt, sind Variablen
standardmäßig unveränderbar. Dies ist einer der vielen Stupser, die Rust dir
gibt, um deinen Code so zu schreiben, dass du die Vorteile von Sicherheit
(safety) und einfacher Nebenläufigkeit (easy concurrency) nutzt, die Rust
bietet. Du hast jedoch immer noch die Möglichkeit, deine Variablen veränderbar
(mutable) zu machen. Lass uns untersuchen, wie und warum Rust dich dazu
ermutigt, die Unveränderbarkeit (immutability) zu bevorzugen, und warum du
manchmal vielleicht davon abweichen möchtest.

Wenn eine Variable unveränderbar ist, kannst du deren Wert nicht mehr ändern,
sobald ein Wert gebunden ist. Um dies zu veranschaulichen, lege ein neues
Projekt namens *variables* in deinem *projects*-Verzeichnis an, indem du
`cargo new variables` aufrufst.

Öffne dann in deinem neuen Verzeichnis *variables* die Datei *src/main.rs* und
ersetze dessen Code durch folgenden Code, der sich sich noch nicht kompilieren
lässt:

<span class="filename">Dateiname: src/main.rs</span>

```rust,does_not_compile
fn main() {
    let x = 5;
    println!("Der Wert von x ist: {x}");
    x = 6;
    println!("Der Wert von x ist: {x}");
}
```

Speichere und starte das Programm mit `cargo run`. Du solltest eine
Fehlermeldung über einen Unveränderbarkeitsfehler erhalten, wie in dieser
Ausgabe gezeigt:

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
  |         help: consider making this binding mutable: `mut x`
3 |     println!("Der Wert von x ist: {}", x);
4 |     x = 6;
  |     ^^^^^ cannot assign twice to immutable variable

For more information about this error, try `rustc --explain E0384`.
error: could not compile `variables` due to previous error
```

Dieses Beispiel zeigt, wie der Compiler dir hilft, Fehler in deinen Programmen
zu finden. Kompilierfehler können frustrierend sein, aber eigentlich bedeuten
sie nur, dass dein Programm noch nicht sicher das tut, was du willst; sie
bedeuten *nicht*, dass du kein guter Programmierer bist! Erfahrene
Rust-Entwickler bekommen ebenfalls noch Kompilierfehler.

Du hast die Fehlermeldung `cannot assign twice to immutable variable x`
erhalten, weil du versucht hast, der unveränderbaren Variablen `x` einen
zweiten Wert zuzuweisen.

Es ist wichtig, dass wir Kompilierzeitfehler erhalten, wenn wir versuchen,
einen Wert zu ändern, der als unveränderbar gekennzeichnet ist, denn genau
diese Situation kann zu Fehlern führen. Wenn ein Teil unseres Codes von der
Annahme ausgeht, dass sich ein Wert niemals ändern wird, und ein anderer Teil
unseres Codes diesen Wert ändert, ist es möglich, dass der erste Teil des Codes
nicht das tut, wozu er entwickelt wurde. Die Ursache für diese Art von Fehler
kann im Nachhinein schwer aufzuspüren sein, besonders wenn das zweite Stück
Code den Wert nur *gelegentlich* ändert. In Rust garantiert der Compiler, dass
sich ein Wert tatsächlich nicht ändert, wenn du angibst, dass er sich nicht
ändern darf, du musst also nicht selbst darauf achten. Dein Code ist somit
leichter zu durchschauen.

Veränderbarkeit kann jedoch sehr nützlich sein und das Erstellen von Code
erleichtern. Obwohl Variablen standardmäßig unveränderbar sind, kannst du sie
veränderbar machen, indem du vor den Variablennamen `mut` angibst, wie du es
in [Kapitel 2][storing-values-with-variables] getan hast. Das Hinzufügen von
`mut` vermittelt den zukünftigen Lesern des Codes die Absicht, dass andere
Teile des Codes den Wert dieser Variablen ändern werden.

Lass uns zum Beispiel *src/main.rs* wie folgt ändern:

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let mut x = 5;
    println!("Der Wert von x ist: {x}");
    x = 6;
    println!("Der Wert von x ist: {x}");
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
verwendet wird. Letztendlich ist es deine Entscheidung, ob du Veränderbarkeit
einsetzen willst oder nicht, und es hängt davon ab, was du in der jeweiligen
Situation für am sinnvollsten hältst.

### Konstanten

Wie unveränderbare Variablen sind *Konstanten* Werte, die an einen Namen
gebunden sind und sich nicht ändern dürfen, aber es gibt einige Unterschiede
zwischen Konstanten und Variablen.

Erstens ist es dir nicht erlaubt, `mut` mit Konstanten zu verwenden. Konstanten
sind nicht nur von vornherein unveränderbar &ndash; sie sind immer
unveränderbar. Du deklarierst Konstanten mit dem Schlüsselwort `const`
anstelle des Schlüsselworts `let` und der Typ des Wertes *muss* annotiert
werden. Wir sind dabei, Typen und Typ-Annotationen im nächsten Abschnitt
[„Datentypen“][data-types] zu behandeln, also mach dir jetzt keine Gedanken
über die Details. Du musst nur wissen, dass du den Typ immer annotieren musst.

Konstanten können in jedem Gültigkeitsbereich deklariert werden, auch im
globalen Gültigkeitsbereich, was sie für Werte nützlich macht, über die viele
Teile des Codes Bescheid wissen müssen.

Der letzte Unterschied besteht darin, dass Konstanten nur auf einen konstanten
Ausdruck gesetzt werden dürfen, nicht auf einen Wert, der nur zur Laufzeit
berechnet werden könnte.

Hier ist ein Beispiel für eine Konstantendeklaration:

```rust
const THREE_HOURS_IN_SECONDS: u32 = 60 * 60 * 3;
```

Der Name der Konstante lautet `THREE_HOURS_IN_SECONDS` und ihr Wert wird auf
das Ergebnis der Multiplikation von 60 (die Anzahl der Sekunden in einer
Minute) mal 60 (die Anzahl der Minuten in einer Stunde) mal 3 (die Anzahl der
Stunden, die wir in diesem Programm zählen wollen). Die Namenskonvention von
Rust für Konstanten ist die Verwendung von Großbuchstaben mit Unterstrichen
zwischen den Wörtern. Der Compiler ist in der Lage, eine begrenzte Anzahl von
Operationen zur Kompilierzeit auswerten, was uns die Möglichkeit gibt, diesen
Wert so zu schreiben, dass er leichter zu verstehen und zu überprüfen ist, als
wenn diese Konstante auf den Wert 10.800 gesetzt wäre. Siehe die
[Rust-Referenz, Abschnitt über die Auswertung von Konstanten][const-eval] für
weitere Informationen darüber, welche Operationen bei der Deklaration von
Konstanten verwendet werden können.

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

### Verschatten (shadowing)

Wie du in der Anleitung zum Ratespiel in [Kapitel
2][comparing-the-guess-to-the-secret-number] gesehen hast, kannst du eine neue
Variable mit dem gleichen Namen wie eine vorherige Variable deklarieren. Die
Rust-Entwickler sagen, dass die erste Variable von der zweiten *verschattet*
(shadowed) wird, was bedeutet, dass die zweite Variable das ist, was der
Compiler sieht, wenn du den Namen der Variable verwendest. Die zweite Variable
verschattet die erste und nimmt alle Verwendungen des Variablennamens auf sich,
bis sie entweder selbst verschattet wird oder der Gültigkeitsbereich endet. Wir
können eine Variable verschatten, indem wir denselben Variablenamen verwenden
und das Schlüsselwort `let` wie folgt wiederholen:

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let x = 5;

    let x = x + 1;

    {
        let x = x * 2;
        println!("Der Wert von x im inneren Gültigkeitsbereich ist: {x}");
    }

    println!("Der Wert von x ist: {x}");
}
```

Dieses Programm bindet zunächst `x` an den Wert `5`. Dann wird eine neue
Variable `x` erzeugt, indem `let x =` wiederholt wird, wobei der ursprüngliche
Wert genommen und `1` hinzugefügt wird, sodass der Wert von `x` dann `6` ist.
Innerhalb eines inneren Gültigkeitsbereichs, der durch die geschweiften
Klammern geschaffen wird, verschattet die dritte `let`-Anweisung dann ebenfalls
`x` und erzeugt eine neue Variable, wobei der vorherige Wert mit `2`
multipliziert wird, um `x` einen Wert von `12` zu geben. Wenn dieser
Gültigkeitsbereich zu Ende ist, endet die innere Verschattung und `x` wird
wieder zu `6`. Wenn wir dieses Programm ausführen, wird es folgendes ausgeben:

```console
$ cargo run
   Compiling variables v0.1.0 (file:///projects/variables)
    Finished dev [unoptimized + debuginfo] target(s) in 0.31s
     Running `target/debug/variables`
Der Wert von x im inneren Gültigkeitsbereich ist: 12
Der Wert von x ist: 6
```

Verschatten unterscheidet sich vom Markieren einer Variable mit `mut`, weil wir
einen Kompilierfehler erhalten, wenn wir versehentlich versuchen, diese
Variable neu zuzuweisen, ohne das Schlüsselwort `let` zu verwenden. Durch das
Verwenden von `let` können wir einige wenige Transformationen an einem Wert
durchführen, aber die Variable ist unveränderbar, nachdem diese
Transformationen abgeschlossen sind.

Der andere Unterschied zwischen `mut` und Verschatten besteht darin, dass wir,
weil wir effektiv eine neue Variable erstellen, wenn wir das Schlüsselwort
`let` erneut verwenden, den Typ des Wertes ändern können, aber denselben Namen
wiederverwenden. Nehmen wir zum Beispiel an, unser Programm bittet einen
Benutzer, durch Eingeben von Leerzeichen zu zeigen, wie viele Leerzeichen er
zwischen irgendeinem Text haben möchte, und wir möchten diese Eingabe als Zahl
speichern:

```rust
let spaces = "   ";
let spaces = spaces.len();
```

Die erste Variable `spaces` ist ein String-Typ und die zweite Variable `spaces`
ist ein Zahlentyp Integer. Das Verschatten erspart es uns also, uns verschiedene
Namen auszudenken, z.B. `spaces_str` und `spaces_num`; stattdessen können wir
den einfacheren Namen `spaces` wiederverwenden. Wenn wir jedoch versuchen,
dafür `mut` zu verwenden, wie hier gezeigt, erhalten wir einen Kompilierfehler:

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
2 |     let mut spaces = "   ";
  |                      ----- expected due to this value
3 |     spaces = spaces.len();
  |              ^^^^^^^^^^^^ expected `&str`, found `usize`

For more information about this error, try `rustc --explain E0308`.
error: could not compile `variables` due to previous error
```

Nachdem wir nun untersucht haben, wie Variablen funktionieren, wollen wir uns
weitere Datentypen ansehen, die sie haben können.

[comparing-the-guess-to-the-secret-number]:
ch02-00-guessing-game-tutorial.html#vergleichen-der-schätzung-mit-der-geheimzahl
[const-eval]: https://doc.rust-lang.org/reference/const_eval.html
[data-types]: ch03-02-data-types.html
[storing-values-with-variables]: ch02-00-guessing-game-tutorial.html#speichern-von-werten-mit-variablen
