## Funktionen

Funktionen sind im Rust-Code weit verbreitet. Du hast bereits eine der
wichtigsten Funktionen in der Sprache gesehen: Die Funktion `main`, die der
Einstiegspunkt vieler Programme ist. Du hast auch das Schlüsselwort `fn`
gesehen, mit dem du neue Funktionen deklarieren kannst.

Rust-Code verwendet die *Schlangenschrift*-Stil-Konvention (snake case) für
Funktions- und Variablennamen, bei der alle Buchstaben klein geschrieben sind
und Unterstriche Wörter separieren. Hier ist ein Programm, das eine
Beispiel-Funktionsdefinition enthält:

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    println!("Hallo Welt!");

    another_function();
}

fn another_function() {
    println!("Eine andere Funktion.");
}
```

Wir definieren eine Funktion in Rust durch die Eingabe von `fn`, gefolgt von
einem Funktionsnamen und einem Satz Klammern. Die geschweiften Klammern teilen
dem Compiler mit, wo der Funktionsrumpf beginnt und endet.

Wir können jede Funktion, die wir definiert haben, aufrufen, indem wir ihren
Namen gefolgt von einem Satz Klammern eingeben. Da `another_function` im
Programm definiert ist, kann sie von innerhalb der `main`-Funktion aufgerufen
werden. Beachte, dass wir `another_function` *nach* der `main`-Funktion im
Quellcode definiert haben; wir hätten sie auch vorher definieren können. Rust
interessiert es nicht, wo du deine Funktionen definierst, nur dass sie irgendwo
definiert sind.

Lass uns ein neues Binärprojekt namens „functions“ anfangen, um Funktionen
weiter zu erforschen. Platziere das Beispiel `another_function` in
*src/main.rs* und lass es laufen. Du solltest die folgende Ausgabe sehen:

```console
$ cargo run
   Compiling functions v0.1.0 (file:///projects/functions)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.28s
     Running `target/debug/functions`
Hallo Welt!
Eine andere Funktion.
```

Die Zeilen werden in der Reihenfolge ausgeführt, in der sie in der
`main`-Funktion erscheinen. Zuerst wird die Nachricht „Hallo Welt!“ ausgegeben
und dann wird `another_function` aufgerufen und ihre Nachricht ausgegeben.

### Parameter

Wir können Funktionen auch so definieren, dass sie *Parameter* haben, das
sind spezielle Variablen, die Teil der Funktionssignatur sind. Wenn eine
Funktion Parameter hat, kannst du sie mit konkreten Werten für diese Parameter
versehen. Technisch gesehen werden die konkreten Werte *Argumente* genannt,
aber in lockeren Gesprächen neigen Leute dazu, die Worte *Parameter* und
*Argument* entweder für die Variablen in der Definition einer Funktion oder für
die konkreten Werte, die beim Aufruf einer Funktion übergeben werden,
synonym zu verwenden.

In dieser Version von `another_function` fügen wir einen Parameter hinzu:

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    another_function(5);
}

fn another_function(x: i32) {
    println!("Der Wert von x ist: {x}");
}
```

Versuche, dieses Programm auszuführen; du solltest die folgende Ausgabe
erhalten:

```console
$ cargo run
   Compiling functions v0.1.0 (file:///projects/functions)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 1.21s
     Running `target/debug/functions`
Der Wert von x ist: 5
```

Die Deklaration `another_function` hat einen Parameter namens `x`. Der Typ von
`x` wird als `i32` angegeben. Wenn wir `5` an `another_function` übergeben,
setzt das Makro `println!` den Wert `5` an die Stelle, an der sich das Paar
geschweifter Klammern mit dem `x` darin in der Formatierungszeichenkette
befand.

In Funktionssignaturen *musst* du den Typ jedes Parameters deklarieren. Dies
ist eine bewusste Designentscheidung von Rust: Das Erfordernis von
Typ-Annotationen in Funktionsdefinitionen bedeutet, dass der Compiler sie
fast nie an anderer Stelle im Code benötigt, um herauszufinden, welchen Typ du
meinst. Der Compiler ist auch in der Lage, hilfreichere Fehlermeldungen zu
geben, wenn er weiß, welche Typen die Funktion erwartet.

Wenn wir mehrere Parameter definieren, trennen wir die Parameterdeklarationen
mit Kommas, so wie hier:

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    print_labeled_measurement(5, 'h');
}

fn print_labeled_measurement(value: i32, unit_label: char) {
    println!("Das Maß ist: {value}{unit_label}");
}
```

Dieses Beispiel erzeugt eine Funktion namens `print_labeled_measurement` mit
zwei Parametern. Der erste Parameter heißt `value` und ist ein `i32`. Der
zweite heißt `unit_label` und ist vom Typ `char`. Die Funktion gibt dann einen
Text aus, der sowohl `value` als auch `unit_label` enthält.

Lass uns versuchen, diesen Code auszuführen. Ersetze das Programm, das sich
derzeit in der Datei *src/main.rs* deines „functions“-Projekts befindet, durch
das vorhergehende Beispiel und führe es mit `cargo run` aus:

```console
$ cargo run
   Compiling functions v0.1.0 (file:///projects/functions)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.31s
     Running `target/debug/functions`
Das Maß ist: 5h
```

Da wir die Funktion mit `5` als Wert für `value` und `'h'` als Wert für
`unit_label` aufgerufen haben, enthält die Programmausgabe diese Werte.

#### Anweisungen und Ausdrücke

Funktionsrümpfe bestehen aus einer Reihe von Anweisungen, die optional mit
einem Ausdruck enden können. Bisher haben wir nur Funktionen ohne einen
endenden Ausdruck behandelt, aber du hast einen Ausdruck als Teil einer
Anweisung gesehen. Da Rust eine auf Ausdrücken basierende Sprache ist, ist dies
eine wichtige Unterscheidung, die es zu verstehen gilt. Andere Sprachen haben
nicht dieselben Unterscheidungen, deshalb wollen wir uns ansehen, was
Anweisungen und Ausdrücke sind und wie sich ihre Unterschiede auf die
Funktionsrümpfe auswirken.

* **Anweisungen** (statements) sind Instruktionen, die eine Aktion ausführen
  und keinen Wert zurückgeben.
* **Ausdrücke** (expressions) werden zu einem Ergebniswert ausgewertet.
  Schauen wir uns einige Beispiele an.

Eine Variable zu erstellen und ihr mit dem Schlüsselwort `let` einen Wert
zuzuweisen, ist eine Anweisung. In Codeblock 3-1 ist `let y = 6;` eine
Anweisung.

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let y = 6;
}
```

<span class="caption">Codeblock 3-1: Eine Funktionsdeklaration `main`, die eine
Anweisung enthält</span>

Auch Funktionsdefinitionen sind Anweisungen; das gesamte vorhergehende Beispiel
ist eine Anweisung für sich. (Wie wir weiter unten sehen werden, ist der
*Aufruf* einer Funktion keine Anweisung.)

Anweisungen geben keine Werte zurück. Daher kannst du keine `let`-Anweisung
einer anderen Variablen zuweisen, wie es der folgende Code versucht; du wirst
einen Fehler erhalten:

<span class="filename">Dateiname: src/main.rs</span>

```rust,does_not_compile
fn main() {
    let x = (let y = 6);
}
```

Wenn du dieses Programm ausführst, wirst du in etwa folgenden Fehler erhalten:

```console
$ cargo run
   Compiling functions v0.1.0 (file:///projects/functions)
error: expected expression, found `let` statement
 --> src/main.rs:2:14
  |
2 |     let x = (let y = 6);
  |              ^^^
  |
  = note: only supported directly in conditions of `if` and `while` expressions

warning: unnecessary parentheses around assigned value
 --> src/main.rs:2:13
  |
2 |     let x = (let y = 6);
  |             ^         ^
  |
  = note: `#[warn(unused_parens)]` on by default
help: remove these parentheses
  |
2 -     let x = (let y = 6);
2 +     let x = let y = 6;
  |

warning: `functions` (bin "functions") generated 1 warning
error: could not compile `functions` (bin "functions") due to 1 previous error; 1 warning emitted
```

Die Anweisung `let y = 6` gibt keinen Wert zurück, also gibt es für `x` nichts,
woran `x` gebunden werden kann. Dies unterscheidet sich von dem, was in anderen
Sprachen wie C und Ruby geschieht, wo die Zuweisung den Wert der Zuweisung
zurückgibt. In diesen Sprachen kannst du `x = y = 6` schreiben und sowohl `x`
als auch `y` haben den Wert `6`; das ist in Rust nicht der Fall.

Ausdrücke werten zu einem Wert aus und machen den größten Teil des restlichen
Codes aus, den du in Rust schreiben wirst. Betrachte eine mathematische
Operation, z.B. `5 + 6`, die ein Ausdruck ist, der zum Wert `11` ausgewertet
wird. Ausdrücke können Teil von Anweisungen sein: In Codeblock 3-1 ist die `6`
in der Anweisung `let y = 6;` ein Ausdruck, der den Wert `6` ergibt. Der Aufruf
einer Funktion ist ein Ausdruck. Der Aufruf eines Makros ist ein Ausdruck. Ein
neuer Gültigkeitsbereichsblock, der mit geschweiften Klammern erstellt wird,
ist ein Ausdruck, zum Beispiel:

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let y = {
        let x = 3;
        x + 1
    };

    println!("Der Wert von y ist: {y}");
}
```

Der Ausdruck

```rust,ignore
{
    let x = 3;
    x + 1
}
```

ist ein Block, der in diesem Fall zu `4` ausgewertet wird. Dieser Wert wird als
Teil der `let`-Anweisung an `y` gebunden. Beachte, dass die Zeile `x + 1` am
Ende kein Semikolon hat, was sich von den meisten Zeilen, die du bisher gesehen
hast, unterscheidet. Ausdrücke enthalten keine abschließenden Semikolons. Wenn
du ein Semikolon an das Ende eines Ausdrucks anfügst, machst du daraus eine
Anweisung, und sie gibt keinen Wert zurück.  Behalte dies im Hinterkopf, wenn
du als nächstes die Rückgabewerte von Funktionen und Ausdrücken untersuchst.

### Funktionen mit Rückgabewerten

Funktionen können Werte an den Code zurückgeben, der sie aufruft. Wir benennen
keine Rückgabewerte, aber wir müssen ihren Typ nach einem Pfeil (`->`)
deklarieren. In Rust ist der Rückgabewert der Funktion gleichbedeutend mit dem
Wert des letzten Ausdrucks im Block des Funktionsrumpfs. Du kannst frühzeitig
von einer Funktion zurückkehren, indem du das Schlüsselwort `return` verwendest
und einen Wert angibst, aber die meisten Funktionen geben den letzten Ausdruck
implizit zurück. Hier ist ein Beispiel für eine Funktion, die einen Wert
zurückgibt:

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn five() -> i32 {
    5
}

fn main() {
    let x = five();

    println!("Der Wert von x ist: {x}");
}
```

Es gibt keine Funktionsaufrufe, Makros oder gar `let`-Anweisungen in der
`five`-Funktion &ndash; nur die Zahl `5` selbst. Das ist eine vollkommen
gültige Funktion in Rust. Beachte, dass der Rückgabetyp der Funktion ebenfalls
angegeben ist, mit `-> i32`. Versuche diesen Code auszuführen; die Ausgabe
sollte wie folgt aussehen:

```console
$ cargo run
   Compiling functions v0.1.0 (file:///projects/functions)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.30s
     Running `target/debug/functions`
Der Wert von x ist: 5
```

Die `5` in `five` ist der Rückgabewert der Funktion, weshalb der Rückgabetyp
`i32` ist. Lass uns dies genauer untersuchen. Es gibt zwei wichtige Teile:
Erstens zeigt die Zeile `let x = five();`, dass wir den Rückgabewert einer
Funktion verwenden, um eine Variable zu initialisieren. Da die Funktion `five`
den Wert `5` zurückgibt, ist diese Zeile die gleiche wie die folgende:

```rust
let x = 5;
```

Zweitens hat die Funktion `five` keine Parameter und definiert den Typ des
Rückgabewertes, aber der Funktionsrumpf ist eine einsame `5` ohne Semikolon,
weil es ein Ausdruck ist, dessen Wert wir zurückgeben wollen.

Sehen wir uns ein weiteres Beispiel an:

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let x = plus_one(5);

    println!("Der Wert von x ist: {x}");
}

fn plus_one(x: i32) -> i32 {
    x + 1
}
```

Beim Ausführen dieses Codes wird `Der Wert von x ist: 6` ausgegeben. Wenn wir
aber ein Semikolon an das Ende der Zeile mit `x + 1` setzen und es von einem
Ausdruck in eine Anweisung ändern, erhalten wir einen Fehler:

<span class="filename">Dateiname: src/main.rs</span>

```rust,does_not_compile
fn main() {
    let x = plus_one(5);

    println!("Der Wert von x ist: {x}");
}

fn plus_one(x: i32) -> i32 {
    x + 1;
}
```

Das Kompilieren dieses Codes führt zum folgenden Fehler:

```console
$ cargo run
   Compiling functions v0.1.0 (file:///projects/functions)
error[E0308]: mismatched types
 --> src/main.rs:7:24
  |
7 | fn plus_one(x: i32) -> i32 {
  |    --------            ^^^ expected `i32`, found `()`
  |    |
  |    implicitly returns `()` as its body has no tail or `return` expression
8 |     x + 1;
  |          - help: remove this semicolon to return this value

For more information about this error, try `rustc --explain E0308`.
error: could not compile `functions` (bin "functions") due to 1 previous error
```

Die Hauptfehlermeldung `mismatched types` offenbart das Kernproblem dieses
Codes. Die Definition der Funktion `plus_one` besagt, dass sie ein `i32`
zurückgibt, aber Anweisungen werden nicht zu einem Wert ausgewertet, was durch
den Einheitstyp `()` ausgedrückt wird. Daher wird nichts zurückgegeben, was der
Funktionsdefinition widerspricht und zu einem Fehler führt. In dieser Ausgabe
gibt Rust eine Meldung aus, die möglicherweise helfen kann, dieses Problem zu
beheben: Es wird vorgeschlagen, das Semikolon zu entfernen, was den Fehler
beheben würde.
