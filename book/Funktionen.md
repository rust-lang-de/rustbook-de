# Funktionen

Jedes Rust Programm hat mindestens eine Funktion,
die `main`:

```rust
fn main() {
}
```

Das ist die simpelste Funktionsdeklaration. Wie wir zuvor schon erwähnt haben,
leitet `fn` eine Funktion ein. Darauf folgt der Name und
ein leeres paar Klammern, da diese Funktion keine Argumente hat,
und ein Paar geschweifte Klammern, die den Funktionskörper repräsentieren.
Hier ist eine Funktion namens `foo`:

```rust
fn foo() {
}
```

Ok, wie funktioniert das nun mit Argumenten? Hier eine Funktion,
die eine Zahl ausgibt:

```rust
fn print_number(x: i32) {
    println!("x is: {}", x);
}
```

Hier ist ein vollständiges Programm, welches `print_number` verwendet:

```rust
fn main() {
    print_number(5);
}

fn print_number(x: i32) {
    println!("x is: {}", x);
}
```

Wie du sehen kannst funktionieren Funktionsargumente
ähnlich wie `let` Deklarationen:
Man fügt dem Namen einen Typ durch ein Doppelpunkt hinzu.

Hier ist ein vollständiges Programm,
welches zwei Zahlen addiert und dann ausgibt:

```rust
fn main() {
    print_sum(5, 6);
}

fn print_sum(x: i32, y: i32) {
    println!("sum is: {}", x + y);
}
```

Wie du siehst werden Argumente durch ein Komma getrennt.
Das gilt sowohl für den Aufruf als auch für die Deklaration von Funktionen.

Anders als bei `let`, __musst__ du die Typen von Funktionsargumenten angeben.
Das hier funktioniert nicht:

```rust
fn print_sum(x, y) {
    println!("sum is: {}", x + y);
}
```
```

Man bekommt diesen Fehler:

```text
expected one of `!`, `:`, or `@`, found `)`
fn print_number(x, y) {
```

Das ist eine bewusste Designentscheidung.
Obwohl das herleiten der Typen eines kompletten Programmes möglich ist,
wie zum Beispiel in Sprachen wie Haskell, wird dennoch häufig dazu geraten
die Typen ausdrücklich zu dokumentieren.
Wir stimmen zu, dass ausdrückliche Typvermerke in Funktionssignaturen
und Typherleitung innerhalb von Funktionskörpern
wundervoller Mittelweg ist.

Wie gibt man einen Wert zurück?
Hier ist eine Funktion, die einen Wert inkrementiert.

```rust
fn add_one(x: i32) -> i32 {
    x + 1
}
```

Rust Funktionen geben genau einen Wert zurück. Diesen gibt man nach einem
"Pfeil" an, welcher aus einem Bindestrich (`-`), gefolgt von einem
Größer-Gleich Zeichen (`>`) besteht.
Die letzte Zeile der Funktion ist automatisch der Rückgabewert der Funktion.
Du wirst das hier das Semikolon fehlt. Wenn wir es hinzufügen:

```rust
fn add_one(x: i32) -> i32 {
    x + 1;
}
```

Würden wir einen Fehler bekommen:

```text
error: not all control paths return a value
fn add_one(x: i32) -> i32 {
     x + 1;
}

help: consider removing this semicolon:
     x + 1;
          ^
```

Dies offenbart zwei interessante Aspekte von Rust:
Rust ist eine ausdrucksorientierte Sprache [expression-based language].
Es gibt nur zwei Arten von Anweisungen, alles andere ist ein Ausdruck.

Also worin liegt der Unterschied? Ausdrücke geben einen Wert zurück,
Anweisungen nicht. Deswegen bekommen wir hier eine
‘not all control paths return a value’ Meldung:
Die Anweisung `x + 1;` gibt keinen Wert zurück.
Es gibt zwei Arten von Anweisungen in Rust:
`Deklarations-Anweisungen` und `Ausdrucks-Anweisungen`.
Alles andere ist ein Ausdruck.
Lass uns zuerst über Deklarations-Anweisungen sprechen.

In manchen Sprachen können Variablenbindungen auch als Ausdruck geschrieben
werden. Wie z.B. in Ruby:

```ruby
x = y = 5
```

In Rust jedoch ist die Variablenbindung mit `let` _kein_ Ausdruck.
Das Folgende erzeugt einen Fehler beim Kompilieren:

```text
let x = (let y = 5); // expected identifier, found keyword `let`
```

Der Compiler sagt uns hier, dass er den Beginn eines Ausdrucks erwartet hat,
denn ein `let` kann nur eine Anweisung einleiten, aber keinen Ausdruck.

Beachte, dass eine Zuweisung an eine bereits gebundene Variable (z.B. `y = 5`)
trotzdem ein Ausdruck ist, auch wenn dieser nicht besonders nützlich ist.
Anders als in anderen Sprachen, wo der zugewiesene Wert zurückgegeben
werden würde, wird in Rust stattdessen das leere Tupel `()` zurückgegeben.
Der Grund dafür ist, dass der zugewiesene Wert [nur einen Besitzer][ownership]
haben kann. Einen anderen Wert zurückzugeben wäre zu überraschend:

```rust
let mut y = 5;

let x = (y = 6);  // x has the value `()`, not `6`
```

[ownershipBesitz.md
