# Traits

Ein Trait ist ein Sprachkonstrukt in Rust, welches dem Kompiler sagt welche Funktionalität ein Typ implementiert.

Kannst du dich noch an das Keyword `impl` erinnern, mit dem man [Methoden][methodsyntax] zu einem Typ implementiert?

```rust
struct Circle {
    x: f64,
    y: f64,
    radius: f64,
}

impl Circle {
    fn area(&self) -> f64 {
        std::f64::consts::PI * (self.radius * self.radius)
    }
}
```
[methodsyntax]: Methoden-Syntax.html

Traits sind ähnlich, nur dass wir hier nur die Signaturen der Methoden angeben und dann erst später implementieren:

```rust
struct Circle {
    x: f64,
    y: f64,
    radius: f64,
}

trait HasArea {
    fn area(&self) -> f64;
}

impl HasArea for Circle {
    fn area(&self) -> f64 {
        std::f64::consts::PI * (self.radius * self.radius)
    }
}
```

Wie man hier erkennt, sieht der `trait` Block fast genau so aus wie der `impl` Block,
aber wir definieren den Körper der Funktionen nicht, nur deren Signatur.
Wenn wir dann mit `impl` einen Trait implementieren schreiben wir `imple Trait for Item` anstatt nur `impl Item`.

## Trait-Schranken für generische Funktionen

Traits sind sehr nützlich, denn sie erlauben es uns bestimmte Zusagen über das Verhalten von Typen zu machen.
Generische Funktionen können somit Voraussetzungen für Typen die sie annehmen einfordern.
Nehmen wir mal folgendes Beispiel an:

```rust,ignore
fn print_area<T>(shape: T) {
    println!("This shape has an area of {}", shape.area());
}
```

Rust beschwert sich jetzt:

```text
error: no method named `area` found for type `T` in the current scope
```

Weil `T` jeder Typ sein könnte, können wir nicht sicher sein dass `area` auch wirklich eine implementierte Methode ist.
Aber wir können eine "Trait-Schranke" zu unserem Generischen `T` hinzufügen, um das sicher zu stellen:

```rust
# trait HasArea {
#     fn area(&self) -> f64;
# }
fn print_area<T: HasArea>(shape: T) {
    println!("This shape has an area of {}", shape.area());
}
```

Die Syntax `<T: HasArea>` bedeutet "jeder Typ der das Trait `HasArea` implementiert".
Weil Traits Funktionssignaturen definieren können wir sicher sein, dass jeder Typ der `HasArea` implementiert auch die Methode `.area()` haben wird.

Hier ist ein erweitertes Beispiel wie das geht:


```rust
trait HasArea {
    fn area(&self) -> f64;
}

struct Circle {
    x: f64,
    y: f64,
    radius: f64,
}

impl HasArea for Circle {
    fn area(&self) -> f64 {
        std::f64::consts::PI * (self.radius * self.radius)
    }
}

struct Square {
    x: f64,
    y: f64,
    side: f64,
}

impl HasArea for Square {
    fn area(&self) -> f64 {
        self.side * self.side
    }
}

fn print_area<T: HasArea>(shape: T) {
    println!("This shape has an area of {}", shape.area());
}

fn main() {
    let c = Circle {
        x: 0.0f64,
        y: 0.0f64,
        radius: 1.0f64,
    };

    let s = Square {
        x: 0.0f64,
        y: 0.0f64,
        side: 1.0f64,
    };

    print_area(c);
    print_area(s);
}
```

Das gibt aus

```text
This shape has an area of 3.141593
This shape has an area of 1
```

Wie du siehst ist `print_area` jetzt generisch, aber stellt außerdem Sicher, dass es die korrekten Typen annimmt.
Wenn wir falsche Typen übergeben:

```rust,ignore
print_area(5);
```

Bekommen wir einen Kompilerfehler:

```text
error: the trait `HasArea` is not implemented for the type `_` [E0277]
```

## Trait-Schranken für generische Structs

Deine generischen Structs können auch von Trait-Schranken profitieren.
Alles was du machen musst ist die Schranke an deinen Typparameter anhängen.
Hier ist ein neues `Rectangle<T>` und seine Methode `is_square()`:


```rust
struct Rectangle<T> {
    x: T,
    y: T,
    width: T,
    height: T,
}

impl<T: PartialEq> Rectangle<T> {
    fn is_square(&self) -> bool {
        self.width == self.height
    }
}

fn main() {
    let mut r = Rectangle {
        x: 0,
        y: 0,
        width: 47,
        height: 47,
    };

    assert!(r.is_square());

    r.height = 42;
    assert!(!r.is_square());
}
```

`is_square()` muss checken das die Seiten gleich sind, also müssen die Seiten einen Typen haben der [`core::cmp::PartialEq`][PartialEq] implementiert:

```ignore
impl<T: PartialEq> Rectangle<T> { ... }
```

[PartialEq]: http://doc.rust-lang.org/stable/std/cmp/trait.PartialEq.html

Hier haben wir also ein Struct `Rectangle` definiert, das alle Typen als Höhe und Breite akzeptiert die sich auf Gleichheit vergleichen lassen.
Geht das auch mit `HasArea` Structs, wie `Square` und `Circle`?
Ja, aber sie benötigen Multiplikation, dafür müssen wir wissen wie man mittels [Operatoren-Traits][operators-and-overloading] Operatoren überlädt.

[operators-and-overloading]: operators-and-overloading.html

# Regeln für Trait Implementierung

Bis lang haben wir nur Traits für Structs implementiert, aber das geht auch für andere Typen.
Theoretisch könnten wir auch `HasArea` für `i32` implementieren:

```rust
trait HasArea {
    fn area(&self) -> f64;
}

impl HasArea for i32 {
    fn area(&self) -> f64 {
        println!("this is silly");

        *self as f64
    }
}

5.area();
```

Es wird allerdings allgemein als schlechter Stil angesehen für primitive Typen solche Methoden zu implementieren, auch wenn es prinzipiell möglich ist.

Es gibt allerdings zwei Einschränkungen was die Implementierung von Traits angeht.
Die erste ist, dass Traits nur gelten, wenn sie im aktuellen Geltungsbereich sichtbar sind.
An einem Beispiel: die Standardbibliothek enthält das Trait [`Write`][write],
welches extra Funktionalität zu `File` hinzufügt.
Standardmäßig haben `File`s diese Methoden aber nicht:

[write]: http://doc.rust-lang.org/stable/std/io/trait.Write.html


```rust,ignore
let mut f = std::fs::File::open("foo.txt").ok().expect("Couldn’t open foo.txt");
let buf = b"whatever"; // byte string literal. buf: &[u8; 8]
let result = f.write(buf);
# result.unwrap(); // ignore the error
```

Hier kommt folgender Fehler:


```text
error: type `std::fs::File` does not implement any method in scope named `write`
let result = f.write(buf);
               ^~~~~~~~~~
```

Wir müssen also mittels `use` das Trait `Write` einbinden:


```rust,ignore
use std::io::Write;

let mut f = std::fs::File::open("foo.txt").ok().expect("Couldn’t open foo.txt");
let buf = b"whatever";
let result = f.write(buf);
# result.unwrap(); // ignore the error
```

Jetzt kompiliert es ohne Fehler.

Das heißt, dass selbst wenn jemand etwas "so schlimmes" macht wie Methoden zu `i32` hinzufügen, dann hat das nicht zwangsläufig Auswirkungen auf andere.

Eine weitere Einschränkungen ist, dass 
entweder der Trait oder der Typ für den du den Trait mit `impl` implementierst, Mindestens eins von beiden, von dir stammen muss.
Es ist nicht erlaubt externe Traits für externe Typen zu implementieren.

Wir könnten also `HasArea` für `i32` implementieren, da `HasArea` von uns stammt.
Aber wenn wir versuchen würden `ToString`, einen Traits aus der Rust Standardbibliothek, für `i32` zu implementieren, würde uns rustc das nicht erlauben.

Eine Sache noch über Traits: generische Funktionen mit Trait-Schranken müssen "monomorphization" (mono: eine, morph: Form )verwenden, also statisch dispatchen.
Was heißt das?
Das erfährst du im Kapitel zu [Trait Objekten](Trait Objekte.html).

# Mehrere Trait-Schranken

Du weißt jetzt, dass man generische Typparameter mit Traits beschränken kann:

```rust
fn foo<T: Clone>(x: T) {
    x.clone();
}
```

Wenn du mehr als eine Beschränkung brachst nutze `+`:

```rust
use std::fmt::Debug;

fn foo<T: Clone + Debug>(x: T) {
    x.clone();
    println!("{:?}", x);
}
```

`T` muss nun sowohl `Clone`, als auch `Debug` implementieren.

# Das `where` Keyword

Funktionen mit nur wenigen generischen Typen und nur wenigen Traits geht noch einigermaßen, aber sobald die Anzahl wächst, wird die Syntax zunehmend seltsamer:

```rust
fn foo<T: Clone, K: Clone + Debug>(x: T, y: K) {
    x.clone();
    y.clone();
    println!("{:?}", y);
}
```

Der Name der Funktion ist ganz links und die Parameter die sie annimmt ist ganz ganz rechts.
Die Schranken sind hier etwas störend.

Rust hat dafür eine syntaktische Lösung: `where`:

```rust
use std::fmt::Debug;

fn foo<T: Clone, K: Clone + Debug>(x: T, y: K) {
    x.clone();
    y.clone();
    println!("{:?}", y);
}

fn bar<T, K>(x: T, y: K) where T: Clone, K: Clone + Debug {
    x.clone();
    y.clone();
    println!("{:?}", y);
}

fn main() {
    foo("Hello", "world");
    bar("Hello", "world");
}
```
`foo()` benutzt die erste Syntax und `bar()` benutzt `where`.
Alles was du machen musst ist die Schranken an den Parametern weglassen und dann ein `where` nach der Parameterliste anfügen.
Bei längeren Listen kannst du auch Leerzeichen benutzen:

```rust
use std::fmt::Debug;

fn bar<T, K>(x: T, y: K)
    where T: Clone,
          K: Clone + Debug {

    x.clone();
    y.clone();
    println!("{:?}", y);
}
```

Das ist eine relative flexible Methode um komplexe Situationen übersichtlicher zu machen.
Davon abgesehen ist `where` aber auch mächtiger also die einfachere Syntax:


```rust
trait ConvertTo<Output> {
    fn convert(&self) -> Output;
}

impl ConvertTo<i64> for i32 {
    fn convert(&self) -> i64 { *self as i64 }
}

// can be called with T == i32
fn normal<T: ConvertTo<i64>>(x: &T) -> i64 {
    x.convert()
}

// can be called with T == i64
fn inverse<T>() -> T
        // this is using ConvertTo as if it were "ConvertTo<i64>"
        where i32: ConvertTo<T> {
    42.convert()
}
```

Das hier verdeutlicht das zusätzliche Feature von `where`: es erlaubt Schranken, bei denen die linke Seite ein beliebiger Typ ist (z.b. `i32`), nicht einfach ein Typparameter wie `T`.

# Default Methoden

Wenn du bereits weißt wie eine typische Implementation einer Methode auszusehen hat, kannst du die konkrete Implementation schon vorgeben:

```rust
trait Foo {
    fn is_valid(&self) -> bool;

    fn is_invalid(&self) -> bool { !self.is_valid() }
}
```

Typen die `Foo` implementieren, müssen `is_valid()` implementieren, aber nicht `is_invalid()`.
Hier wird das Standardverhalten verwendet.
Es lässt sich allerdings trotzdem noch überschreiben:

```rust
# trait Foo {
#     fn is_valid(&self) -> bool;
#
#     fn is_invalid(&self) -> bool { !self.is_valid() }
# }
struct UseDefault;

impl Foo for UseDefault {
    fn is_valid(&self) -> bool {
        println!("Called UseDefault.is_valid.");
        true
    }
}

struct OverrideDefault;

impl Foo for OverrideDefault {
    fn is_valid(&self) -> bool {
        println!("Called OverrideDefault.is_valid.");
        true
    }

    fn is_invalid(&self) -> bool {
        println!("Called OverrideDefault.is_invalid!");
        true // this implementation is a self-contradiction!
    }
}

let default = UseDefault;
assert!(!default.is_invalid()); // prints "Called UseDefault.is_valid."

let over = OverrideDefault;
assert!(over.is_invalid()); // prints "Called OverrideDefault.is_invalid!"
```

# Vererbung

Manchmal setzt die Implementierung eines Traits die Implementierung eines anderen voraus:

```rust
trait Foo {
    fn foo(&self);
}

trait FooBar : Foo {
    fn foobar(&self);
}
```

Typen die `FooBar` implementieren müssen also auch `Foo` implementieren:

```rust
# trait Foo {
#     fn foo(&self);
# }
# trait FooBar : Foo {
#     fn foobar(&self);
# }
struct Baz;

impl Foo for Baz {
    fn foo(&self) { println!("foo"); }
}

impl FooBar for Baz {
    fn foobar(&self) { println!("foobar"); }
}
```

Aber wenn wir das mal vergessen, wird der Compiler uns das schon vorwerfen:

```text
error: the trait `main::Foo` is not implemented for the type `main::Baz` [E0277]
```

# Ableiten

Das Implementieren von Traits wie `Debug` und `Default` kann mitunter recht eintönig und nervig werden.
Aus diesem Grund lässt uns Rust mittels [Attributen][attribute] bestimmte Traits automatisch zu implementieren:

```rust
#[derive(Debug)]
struct Foo;

fn main() {
    println!("{:?}", Foo);
}
```

Das ist jedoch momentan auf bestimmte Traits beschränkt:

- `Clone`
- `Copy`
- `Debug`
- `Default`
- `Eq`
- `Hash`
- `Ord`
- `PartialEq`
- `PartialOrd`

[attribute]: attribute.html
