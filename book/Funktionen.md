# Funktionen

Jedes Rust Programm hat mindestens eine Funktion,
die `main` Funktion:

```rust
fn main() {
}
```

Das ist die simpelste Funktionsdeklaration. Wie wir zuvor schon erwähnt haben,
leitet `fn` eine Funktion ein. Darauf folgt der Name und
ein leeres paar Klammern, da diese Funktion keine Argumente hat,
und ein paar geschweifte Klammern, die den Funktionskörper repräsentieren.
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
Obwohl das Herleiten der Typen eines kompletten Programmes möglich ist,
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
Du wirst sehen, dass hier das Semikolon fehlt. Wenn wir es hinzufügen:

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
Lass uns zuerst über *Deklarations-Anweisungen* sprechen.

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
haben kann und einen anderen Wert zurückzugeben wäre zu überraschend:

```rust
let mut y = 5;

let x = (y = 6);  // x has the value `()`, not `6`
```

[ownership]: Besitz.md

Die zweite Art von Anweisung in Rust ist die *Ausdrucks-Anweisung*.
Ihr Zweck ist es jeden Ausdruck in eine Anweisung zu verwandeln.
In praktischer Hinsicht erwartet Rusts Grammatik, dass Anweisungen
aufeinander folgen. Das bedeutet, dass man Semikolons nutzt um
Ausdrücke voneinander zu trennen. Das bedeutet auch,
dass Rust anderen Sprachen, welche auch ein Semikolon am Ende einer Zeile
haben, sehr ähnlich sieht und man in Rust fast an jedem Ende einer Zeile ein
Semikolon sieht.

Wegen welcher Ausnahme sagen wir "fast"?.
Du hast sie bereits gesehen und zwar in diesem Code:

```rust
fn add_one(x: i32) -> i32 {
    x + 1
}
```

Unsere Funktion gibt an ein `i32` zurückzugeben, aber mit einem Semikolon
würden wir stattdessen `()` zurückgeben.
Rust versteht, dass wir das wahrscheinlich nicht wollten und schlägt uns in
der Fehlermeldung, die wir sahen, vor das Semikolon zu entfernen.

## Frühzeitige Rückgabe

Was ist mit frühzeitiger Rückgabe [early returns]?
Rust hat dafür ein Schlpsselwort namens `return`:

```rust
fn foo(x: i32) -> i32 {
    return x;

    // we never run this code!
    x + 1
}
```

`return` in der letzten Zeile einer Funktion zu verwenden funktioniert zwar,
aber wird als schlechter Stil angesehen:

```rust
fn foo(x: i32) -> i32 {
    return x + 1;
}
```

Die vorherige Definition ohne `return` sieht vielleicht etwas komisch für dich
aus, falls du noch nicht mit ausdrucksorientierten Sprachen gearbeitet hast,
aber du wirst dich mit der Zeit daran gewöhnen.

## Divergierende Funktionde

Rust hat eine spezielle Syntax für sogennannte ‘divergierende Funktionen’
[diverging functions], also Funktionen, die niemals zurückkehren:

```rust
fn diverges() -> ! {
    panic!("This function never returns!");
}
```

`panic!()` ist ein Makro, ähnlich wie `println!()`, was wir bereits kennen.
Anders jedoch als `println!()` sorgt `panic!()` dafür, dass der aktuelle
Thread mit einer Fehlermeldung abstürzt. Weil diese Funktion einen Crash hervorruft, kehrt sie niemals zurück, deswegen hat sie den Typ ‘`!`’,
was man als ‘divergiert’ liest.

Wenn du zu einer main Funktion einen `diverges()` Aufruf hinzufügst
und das Programm ausführst, dann sieht die Ausgabe in etwa so aus:

```text
thread ‘<main>’ panicked at ‘This function never returns!’, hello.rs:2
```

Wenn du mehr Informationen haben willst, dann kannst du einen Backtrace durch
Setzen der `RUST_BACKTRACE` Umgebungsvariable erhalten:

```text
$ RUST_BACKTRACE=1 ./diverges
thread '<main>' panicked at 'This function never returns!', hello.rs:2
stack backtrace:
   1:     0x7f402773a829 - sys::backtrace::write::h0942de78b6c02817K8r
   2:     0x7f402773d7fc - panicking::on_panic::h3f23f9d0b5f4c91bu9w
   3:     0x7f402773960e - rt::unwind::begin_unwind_inner::h2844b8c5e81e79558Bw
   4:     0x7f4027738893 - rt::unwind::begin_unwind::h4375279447423903650
   5:     0x7f4027738809 - diverges::h2266b4c4b850236beaa
   6:     0x7f40277389e5 - main::h19bb1149c2f00ecfBaa
   7:     0x7f402773f514 - rt::unwind::try::try_fn::h13186883479104382231
   8:     0x7f402773d1d8 - __rust_try
   9:     0x7f402773f201 - rt::lang_start::ha172a3ce74bb453aK5w
  10:     0x7f4027738a19 - main
  11:     0x7f402694ab44 - __libc_start_main
  12:     0x7f40277386c8 - <unknown>
  13:                0x0 - <unknown>
```

`RUST_BACKTRACE` funktioniert auch mit Cargos `run` Befehl:

```text
$ RUST_BACKTRACE=1 cargo run
     Running `target/debug/diverges`
thread '<main>' panicked at 'This function never returns!', hello.rs:2
stack backtrace:
   1:     0x7f402773a829 - sys::backtrace::write::h0942de78b6c02817K8r
   2:     0x7f402773d7fc - panicking::on_panic::h3f23f9d0b5f4c91bu9w
   3:     0x7f402773960e - rt::unwind::begin_unwind_inner::h2844b8c5e81e79558Bw
   4:     0x7f4027738893 - rt::unwind::begin_unwind::h4375279447423903650
   5:     0x7f4027738809 - diverges::h2266b4c4b850236beaa
   6:     0x7f40277389e5 - main::h19bb1149c2f00ecfBaa
   7:     0x7f402773f514 - rt::unwind::try::try_fn::h13186883479104382231
   8:     0x7f402773d1d8 - __rust_try
   9:     0x7f402773f201 - rt::lang_start::ha172a3ce74bb453aK5w
  10:     0x7f4027738a19 - main
  11:     0x7f402694ab44 - __libc_start_main
  12:     0x7f40277386c8 - <unknown>
  13:                0x0 - <unknown>
```

Divergierende Funktionen passen mit jedem Typen zusammen:

```rust
let x: i32 = diverges();
let x: String = diverges();
```

## Funktionszeiger

Wir können auch eine Variablenbindung erzeugen, die auf eine Funktion zeigt:

```rust
let f: fn(i32) -> i32;
```

`f` ist eine Variable, die auf eine Funktion zeigt, welche ein `i32` als
Argument entgegennimmt und ein `i32` zurückgibt. Zum Beispiel:

```rust
fn plus_one(i: i32) -> i32 {
    i + 1
}

// without type inference
let f: fn(i32) -> i32 = plus_one;

// with type inference
let f = plus_one;
```

Wir können dann `f` benutzen um die Funktion aufzurufen:

```rust
let six = f(5);
```
