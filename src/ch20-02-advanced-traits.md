## Fortgeschrittene Merkmale (traits)

Merkmale behandelten wir als Erstes im Abschnitt [„Gemeinsames Verhalten
definieren mit Merkmalen (traits)“][traits] in Kapitel 10, aber wir haben die
fortgeschrittenen Details nicht besprochen. Jetzt, da du mehr über Rust weißt,
können wir zum Kern der Sache kommen.

### Merkmale mit assoziierten Typen definieren

_Assoziierte Typen_ (associated types) verbinden einen Typ-Platzhalter mit
einem Merkmal, sodass die Definitionen der Merkmalsmethoden diese
Platzhaltertypen in ihren Signaturen verwenden können. Der Implementierer eines
Merkmals gibt den konkreten Typ an, der anstelle des Platzhaltertyps für die
jeweilige Implementierung verwendet werden soll. Auf diese Weise können wir ein
Merkmal definieren, das einige Typen verwendet, ohne dass wir genau wissen
müssen, um welche Typen es sich dabei handelt, bis das Merkmal implementiert
ist.

Wir haben die meisten der fortgeschrittenen Funktionalitäten in diesem Kapitel
als selten benötigt beschrieben. Assoziierte Typen liegen irgendwo dazwischen:
Sie werden seltener verwendet als die im Rest des Buches erläuterten
Funktionalitäten, aber häufiger als viele der anderen in diesem Kapitel
besprochenen Funktionalitäten.

Ein Beispiel für ein Merkmal mit einem assoziierten Typ ist das Merkmal
`Iterator`, das die Standardbibliothek zur Verfügung stellt. Der assoziierte
Typ wird `Item` genannt und steht für den Typ der Werte, über die der Typ, der
das Merkmal `Iterator` implementiert, iteriert. Die Definition des Merkmals
`Iterator` ist in Codeblock 20-13 zu sehen.

```rust
pub trait Iterator {
    type Item;

    fn next(&mut self) -> Option<Self::Item>;
}
```

<span class="caption">Codeblock 20-13: Definition des Merkmals `Iterator`, das
einen assoziierten Typ `Item` hat</span>

Der Typ `Item` ist ein Platzhalter und die Definition der Methode `next` zeigt,
dass sie Werte vom Typ `Option<Self::Item>` zurückgibt. Implementierungen des
Merkmals `Iterator` geben den konkreten Typ für `Item` an und die Methode
`next` gibt eine `Option` zurück, die einen Wert dieses konkreten Typs enthält.

Assoziierte Typen scheinen ein ähnliches Konzept wie generische Datentypen
(generics) zu sein, da letztere es uns ermöglichen, eine Funktion zu
definieren, ohne anzugeben, welche Typen sie handhaben kann. Um den Unterschied
zwischen den beiden Konzepten zu untersuchen, betrachten wir eine
Implementierung des Merkmals `Iterator` für einen Typ namens `Counter`, der
angibt, dass der `Item`-Typ `u32` ist:

<span class="filename">Dateiname: src/lib.rs</span>

```rust
# struct Counter {
#     count: u32,
# }
#
# impl Counter {
#     fn new() -> Counter {
#         Counter { count: 0 }
#     }
# }
#
impl Iterator for Counter {
    type Item = u32;

    fn next(&mut self) -> Option<Self::Item> {
        // --abschneiden--
#         if self.count < 5 {
#             self.count += 1;
#             Some(self.count)
#         } else {
#             None
#         }
#     }
# }
```

Diese Syntax scheint mit der von generischen Datentypen vergleichbar zu sein.
Warum also nicht einfach das Merkmal `Iterator` mit generischen Datentypen
definieren, wie in Codeblock 20-14 gezeigt?

```rust
pub trait Iterator<T> {
    fn next(&mut self) -> Option<T>;
}
```

<span class="caption">Codeblock 20-14: Eine hypothetische Definition des
Merkmals `Iterator` unter Verwendung eines generischen Datentyps</span>

Der Unterschied ist, dass wir beim Verwenden von generischen Datentypen, wie in
Codeblock 20-14, die Typen in jeder Implementierung annotieren müssen; da wir
auch `Iterator<String> for Counter` oder jeden anderen Typ implementieren
können, könnten wir mehrere Implementierungen von `Iterator` für `Counter`
haben. Mit anderen Worten, wenn ein Merkmal einen generischen Parameter hat,
kann es für einen Typ mehrfach implementiert werden, wobei die konkreten Typen
der generischen Typparameter jedes Mal geändert werden können. Wenn wir die
Methode `next` auf `Counter` verwenden, müssten wir Typ-Annotationen
bereitstellen, um anzugeben, welche Implementierung des `Iterators` wir
verwenden wollen.

Bei assoziierten Typen brauchen wir Typen nicht zu annotieren, weil wir ein
Merkmal auf einem Typ nicht mehrfach implementieren können. In Codeblock 20-13
mit der Definition, die assoziierte Typen verwendet, können wir nur einmal
wählen, was der Typ von `Item` sein wird, weil es nur einen `impl Iterator for
Counter` geben kann. Wir müssen nicht angeben, dass wir einen Iterator von
`u32`-Werten überall dort haben wollen, wo wir `next` auf `Counter` aufrufen.

Assoziierte Typen werden auch Teil des Merkmal-Vertrags: Implementierer des
Merkmals müssen einen Typ bereitstellen, der für den Platzhalter des
assoziierten Typs steht. Assoziierte Typen haben oft einen Namen, der
beschreibt, wie der Typ verwendet werden soll, und das Dokumentieren des
assoziierten Typs in der API-Dokumentation ist eine gute Praxis.

### Generische Standardparameter und Operatorüberladung verwenden

Wenn wir generische Typparameter verwenden, können wir einen konkreten
Standardtyp für den generischen Typ angeben. Dadurch entfällt die Notwendigkeit
für Implementierer des Merkmals, einen konkreten Typ anzugeben, wenn der
Standardtyp passt. Du gibst einen Standardtyp an, wenn du einen generischen Typ
mit der Syntax `<PlaceholderType=ConcreteType>` deklarierst.

Ein gutes Beispiel für eine Situation, in der diese Technik nützlich ist, ist
die _Operatorüberladung_ (operator overloading), bei der du das Verhalten eines
Operators (wie `+`) in bestimmten Situationen anpasst.

Rust erlaubt es dir nicht, eigene Operatoren zu erstellen oder beliebige
Operatoren zu überladen. Aber du kannst die in `std::ops` aufgeführten
Operationen und entsprechenden Merkmale überladen, indem du die mit dem
Operator assoziierten Merkmale implementierst. Beispielsweise überladen wir in
Codeblock 20-15 den Operator `+`, um zwei `Point`-Instanzen zu addieren. Wir
tun dies, indem wir das Merkmal `Add` auf eine `Point`-Struktur implementieren.

<span class="filename">Dateiname: src/main.rs</span>

```rust
use std::ops::Add;

#[derive(Debug, Copy, Clone, PartialEq)]
struct Point {
    x: i32,
    y: i32,
}

impl Add for Point {
    type Output = Point;

    fn add(self, other: Point) -> Point {
        Point {
            x: self.x + other.x,
            y: self.y + other.y,
        }
    }
}

fn main() {
    assert_eq!(
        Point { x: 1, y: 0 } + Point { x: 2, y: 3 },
        Point { x: 3, y: 3 }
    );
}
```

<span class="caption">Codeblock 20-15: Implementieren des Merkmals `Add`, um
den Operator `+` für `Point`-Instanzen zu überladen</span>

Die Methode `add` addiert die `x`-Werte zweier `Point`-Instanzen und die
`y`-Werte zweier `Point`-Instanzen, um einen neuen `Point` zu erzeugen. Das
Merkmal `Add` hat einen assoziierten Typ namens `Output`, der den von der
Methode `add` zurückgegebenen Typ bestimmt.

Der generische Standardtyp in diesem Code befindet sich innerhalb des Merkmals
`Add`. Hier ist seine Definition:

```rust
trait Add<Rhs=Self> {
    type Output;

    fn add(self, rhs: Rhs) -> Self::Output;
}
```

Dieser Code sollte allgemein bekannt aussehen: Ein Merkmal mit einer Methode
und einem assoziierten Typ. Der neue Teil ist `Rhs=Self`: Diese Syntax heißt
_Standardtypparameter_ (default type parameters). Der generische Typparameter
`Rhs` (kurz für „right hand side“, engl. „rechte Seite“) definiert den Typ des
Parameters `rhs` in der Methode `add`. Wenn wir keinen konkreten Typ für `Rhs`
angeben, wenn wir das Merkmal `Add` implementieren, wird der Typ `Rhs`
standardmäßig auf `Self` gesetzt, was der Typ sein wird, auf dem wir `Add`
implementieren.

Als wir `Add` für `Point` implementiert haben, haben wir den Standardwert für
`Rhs` verwendet, weil wir zwei `Point`-Instanzen addieren wollten. Schauen wir
uns ein Beispiel für die Implementierung des Merkmals `Add` an, bei dem wir den
Typ `Rhs` anpassen wollen, anstatt den Standardwert zu verwenden.

Wir haben zwei Strukturen `Millimeters` und `Meters`, die Werte in
verschiedenen Einheiten enthalten. Diese dünne Umhüllung eines bestehenden Typs
in einer anderen Struktur ist als _Newtype-Muster_ bekannt, das wir im
Abschnitt [„Externe Merkmale mit dem Newtype-Muster implementieren“][newtype]
ausführlicher beschreiben. Wir wollen Werte in Millimeter zu Werten in Meter
addieren und die Implementierung von `Add` die Umrechnung korrekt durchführen
lassen. Wir können `Add` für `Millimeters` mit `Meters` als `Rhs`
implementieren, wie in Codeblock 20-16 gezeigt.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
use std::ops::Add;

struct Millimeters(u32);
struct Meters(u32);

impl Add<Meters> for Millimeters {
    type Output = Millimeters;

    fn add(self, other: Meters) -> Millimeters {
        Millimeters(self.0 + (other.0 * 1000))
    }
}
```

<span class="caption">Codeblock 20-16: Implementieren des Merkmals `Add` auf
`Millimeters`, um `Millimeters` zu `Meters` zu addieren</span>

Um `Millimeters` und `Meters` zu addieren, geben wir `impl Add<Meters>` an, um
den Wert des Parameters vom Typ `Rhs` zu setzen, anstatt den Standardwert
`Self` zu verwenden.

Du wirst Standardtypparameter auf zwei Arten verwenden:

1. Um einen Typ zu erweitern, ohne bestehenden Code zu brechen.
2. Um eine Anpassung in bestimmten Fällen zu ermöglichen, die die meisten
   Benutzer nicht benötigen.

Das Merkmal `Add` der Standardbibliothek ist ein Beispiel für den zweiten
Zweck: Normalerweise addierst du zwei ähnliche Typen, aber das Merkmal `Add`
bietet die Möglichkeit, darüber hinausgehende Anpassungen vorzunehmen. Das
Verwenden eines Standardtypparameters in der Merkmalsdefinition `Add` bedeutet,
dass du den zusätzlichen Parameter die meiste Zeit nicht angeben musst. Mit
anderen Worten kann etwas Implementierungscode eingespart werden, was das
Verwenden des Merkmals erleichtert.

Der erste Zweck ist ähnlich zum zweiten, nur umgekehrt: Wenn du einem
vorhandenen Merkmal einen Typparameter hinzufügen möchtest, kannst du ihm einen
Standardwert geben, um eine Erweiterung der Funktionalität des Merkmals zu
ermöglichen, ohne den vorhandenen Implementierungscode zu brechen.

### Eindeutiger Aufruf von Methoden mit identischen Namen

Nichts in Rust hindert ein Merkmal daran, eine Methode mit demselben Namen wie
die Methode eines anderen Merkmals zu haben, und Rust hindert dich auch nicht
daran, beide Merkmale auf einem Typ zu implementieren. Es ist auch möglich,
eine Methode direkt auf dem Typ mit dem gleichen Namen wie Methoden von
Merkmalen zu implementieren.

Wenn du Methoden mit dem gleichen Namen aufrufst, musst du Rust mitteilen,
welche du verwenden willst. Betrachte den Code in Codeblock 20-17, wo wir zwei
Merkmale `Pilot` und `Wizard` definiert haben, die beide eine Methode namens
`fly` haben. Wir implementieren dann beide Merkmale auf einem Typ `Human`, der
bereits eine Methode namens `fly` implementiert hat. Jede Methode `fly` macht
etwas anderes.

<span class="filename">Dateiname: src/main.rs</span>

```rust
trait Pilot {
    fn fly(&self);
}

trait Wizard {
    fn fly(&self);
}

struct Human;

impl Pilot for Human {
    fn fly(&self) {
        println!("Hier spricht Ihr Kapitän.");
    }
}

impl Wizard for Human {
    fn fly(&self) {
        println!("Hoch!");
    }
}

impl Human {
    fn fly(&self) {
        println!("*Wütend mit den Armen wedeln*");
    }
}
#
# fn main() {}
```

<span class="caption">Codeblock 20-17: Zwei Merkmale sind so definiert, dass
sie eine Methode `fly` haben und auf dem Typ `Human` implementiert sind, und
eine Methode `fly` ist direkt auf dem Typ `Human` implementiert</span>

Wenn wir `fly` auf einer Instanz von `Human` aufrufen, ruft der Compiler
standardmäßig die Methode auf, die direkt auf dem Typ implementiert ist, wie in
Codeblock 20-18 gezeigt.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# trait Pilot {
#     fn fly(&self);
# }
#
# trait Wizard {
#     fn fly(&self);
# }
#
# struct Human;
#
# impl Pilot for Human {
#     fn fly(&self) {
#         println!("Hier spricht Ihr Kapitän.");
#     }
# }
#
# impl Wizard for Human {
#     fn fly(&self) {
#         println!("Hoch!");
#     }
# }
#
# impl Human {
#     fn fly(&self) {
#         println!("*Wütend mit den Armen wedeln*");
#     }
# }
#
fn main() {
    let person = Human;
    person.fly();
}
```

<span class="caption">Codeblock 20-18: Aufrufen von `fly` auf einer Instanz von
`Human`</span>

Wenn man diesen Code ausführt, wird `*Wütend mit den Armen wedeln*` ausgegeben,
was zeigt, dass Rust die Methode `fly`, die direkt auf `Human` implementiert
wurde, aufgerufen hat.

Um die Methoden `fly` entweder vom Merkmal `Pilot` oder vom Merkmal `Wizard`
aufzurufen, müssen wir eine explizitere Syntax verwenden, um anzugeben, welche
Methode `fly` wir meinen. Codeblock 20-19 demonstriert diese Syntax.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# trait Pilot {
#     fn fly(&self);
# }
#
# trait Wizard {
#     fn fly(&self);
# }
#
# struct Human;
#
# impl Pilot for Human {
#     fn fly(&self) {
#         println!("Hier spricht Ihr Kapitän.");
#     }
# }
#
# impl Wizard for Human {
#     fn fly(&self) {
#         println!("Hoch!");
#     }
# }
#
# impl Human {
#     fn fly(&self) {
#         println!("*Wütend mit den Armen wedeln*");
#     }
# }
#
fn main() {
    let person = Human;
    Pilot::fly(&person);
    Wizard::fly(&person);
    person.fly();
}
```

<span class="caption">Codeblock 20-19: Angeben, welche Methode `fly` wir
aufrufen wollen</span>

Das Angeben des Merkmalsnamens vor dem Methodennamen verdeutlicht Rust, welche
Implementierung von `fly` wir aufrufen wollen. Wir könnten auch
`Human::fly(&person)` schreiben, was äquivalent zu `person.fly()` ist, das wir
in Codeblock 20-19 verwendet haben, aber das ist etwas länger zu schreiben, wenn
wir nicht vereindeutigen müssen.

Beim Ausführen dieses Codes wird Folgendes ausgegeben:

```console
$ cargo run
   Compiling traits-example v0.1.0 (file:///projects/traits-example)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.46s
     Running `target/debug/traits-example`
Hier spricht Ihr Kapitän.
Hoch!
*Wütend mit den Armen wedeln*
```

Da die Methode `fly` einen Parameter `self` benötigt, könnte Rust, wenn wir
zwei _Typen_ hätten, die beide ein _Merkmal_ implementieren, herausfinden,
welche Implementierung eines Merkmals basierend auf dem Typ von `self` zu
verwenden ist.

Assoziierte Funktionen, die keine Methoden sind, haben jedoch keinen
`self`-Parameter. Wenn es mehrere Typen oder Merkmale gibt, die
Nicht-Methodenfunktionen mit demselben Funktionsnamen definieren, weiß Rust
nicht immer, welchen Typ du meinst, es sei denn, du verwendest eine
voll-qualifizierte Syntax. In Codeblock 20-20 erstellen wir zum Beispiel ein
Merkmal für ein Tierheim, das alle Hundebabys Spot nennen möchte. Wir erstellen
ein Merkmal `Animal` mit einer assoziierten Nicht-Methodenfunktion `baby_name`.
Das Merkmal `Animal` ist für die Struktur `Dog` implementiert, für die wir auch
direkt eine assoziierte Nicht-Methodenfunktionen `baby_name` bereitstellen.

<span class="filename">Dateiname: src/main.rs</span>

```rust
trait Animal {
    fn baby_name() -> String;
}

struct Dog;

impl Dog {
    fn baby_name() -> String {
        String::from("Spot")
    }
}

impl Animal for Dog {
    fn baby_name() -> String {
        String::from("Welpe")
    }
}

fn main() {
    println!("Ein Hundebaby wird {} genannt.", Dog::baby_name());
}
```

<span class="caption">Codeblock 20-20: Ein Merkmal mit einer assoziierten
Funktion und ein Typ mit einer assoziierten Funktion desselben Namens, der das
Merkmal ebenfalls implementiert</span>

Wir implementieren den Code für die Benennung aller Welpen Spot in der
assoziierten Funktion `baby_name`, die auf `Dog` definiert ist. Der Typ `Dog`
implementiert auch das Merkmal `Animal`, das Charakteristiken beschreibt, die
alle Tiere haben. Hundebabys werden Welpen genannt und das drückt sich in der
Implementierung des Merkmals `Animal` auf `Dog` in der Funktion `baby_name`
aus, die mit dem Merkmal `Animal` assoziiert ist.

In `main` rufen wir die Funktion `Dog::baby_name` auf, die die assoziierte
Funktion, die auf `Dog` definiert ist, direkt aufruft. Dieser Code gibt
Folgendes aus:

```console
$ cargo run
   Compiling traits-example v0.1.0 (file:///projects/traits-example)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.54s
     Running `target/debug/traits-example`
Ein Hundebaby wird Spot genannt.
```

Diese Ausgabe ist nicht das, was wir wollten. Wir wollen die Funktion
`baby_name` aufrufen, die Teil des Merkmals `Animal` ist, das wir auf `Dog`
implementiert haben, sodass der Code `Ein Hundebaby wird Welpe genannt`
ausgibt. Die Technik der Angabe des Merkmalsnamens, die wir in Codeblock 20-19
verwendet haben, hilft hier nicht weiter; wenn wir `main` in den Code in
Codeblock 20-21 ändern, erhalten wir einen Kompilierfehler.

<span class="filename">Dateiname: src/main.rs</span>

```rust,does_not_compile
# trait Animal {
#     fn baby_name() -> String;
# }
#
# struct Dog;
#
# impl Dog {
#     fn baby_name() -> String {
#         String::from("Spot")
#     }
# }
#
# impl Animal for Dog {
#     fn baby_name() -> String {
#         String::from("Welpe")
#     }
# }
#
fn main() {
    println!("Ein Hundebaby wird {} genannt.", Animal::baby_name());
}

```

<span class="caption">Codeblock 20-21: Versuch, die Funktion `baby_name` des
Merkmals `Animal` aufzurufen, aber Rust weiß nicht, welche Implementierung es
verwenden soll</span>

Da `Animal::baby_name` keinen `self`-Parameter hat, und es andere Typen geben
könnte, die das Merkmal `Animal` implementieren, kann Rust nicht herausfinden,
welche Implementierung von `Animal::baby_name` wir wollen. Wir werden diesen
Kompilierfehler erhalten:

```console
$ cargo run
   Compiling traits-example v0.1.0 (file:///projects/traits-example)
error[E0790]: cannot call associated function on trait without specifying the corresponding `impl` type
  --> src/main.rs:20:43
   |
 2 |     fn baby_name() -> String;
   |     ------------------------- `Animal::baby_name` defined here
...
20 |     println!("Ein Hundebaby wird {} genannt.", Animal::baby_name());
   |                                                ^^^^^^^^^^^^^^^^^^^ cannot call associated function of trait
   |
help: use the fully-qualified path to the only available implementation
   |
20 |     println!("Ein Hundebaby wird {} genannt.", <Dog as Animal>::baby_name());
   |                                                +++++++       +

For more information about this error, try `rustc --explain E0790`.
error: could not compile `traits-example` (bin "traits-example") due to 1 previous error
```

Um zu vereindeutigen und Rust zu sagen, dass wir die Implementierung von
`Animal` für `Dog` verwenden wollen und nicht die Implementierung von `Animal`
für einen anderen Typ, müssen wir eine vollständig qualifizierte Syntax
verwenden. Codeblock 20-22 zeigt, wie man eine vollständig qualifizierte Syntax
verwendet.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# trait Animal {
#     fn baby_name() -> String;
# }
#
# struct Dog;
#
# impl Dog {
#     fn baby_name() -> String {
#         String::from("Spot")
#     }
# }
#
# impl Animal for Dog {
#     fn baby_name() -> String {
#         String::from("Welpe")
#     }
# }
#
fn main() {
    println!("Ein Hundebaby wird {} genannt.", <Dog as Animal>::baby_name());
}
```

<span class="caption">Codeblock 20-22: Verwenden einer vollständig
qualifizierten Syntax, um anzugeben, dass wir die Funktion `baby_name` des
Merkmals `Animal` aufrufen wollen, wie sie auf `Dog` implementiert ist</span>

Wir geben Rust mit einer Typ-Annotation innerhalb spitzer Klammern an, dass wir
die Methode `baby_name` des Merkmals `Animal`, die auf `Dog` implementiert ist,
aufrufen wollen, indem wir sagen, dass wir den Typ `Dog` für diesen
Funktionsaufruf als `Animal` behandeln wollen. Dieser Code wird nun ausgeben,
was wir wollen:

```console
$ cargo run
   Compiling traits-example v0.1.0 (file:///projects/traits-example)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.48s
     Running `target/debug/traits-example`
Ein Hundebaby wird Welpe genannt.
```

Im Allgemeinen wird die vollständig qualifizierte Syntax wie folgt definiert:

```rust,ignore
<Type as Trait>::function(receiver_if_method, next_arg, ...);
```

Für assoziierte Funktionen, die keine Methoden sind, gäbe es keinen `receiver`:
Es gäbe nur die Liste der anderen Argumente. Du könntest eine vollständig
qualifizierte Syntax überall dort verwenden, wo du Funktionen oder Methoden
aufrufst. Du darfst jedoch jeden Teil dieser Syntax weglassen, den Rust aus
anderen Informationen im Programm herausfinden kann. Du musst diese
ausführlichere Syntax nur in Fällen verwenden, in denen es mehrere
Implementierungen gibt, die denselben Namen verwenden, und Rust Hilfe benötigt,
um herauszufinden, welche Implementierung du aufrufen möchtest.

### Verwenden von Supermerkmalen

Manchmal kann es vorkommen, dass man eine Merkmals-Definition schreibt, die von
einem anderen Merkmal abhängt: Damit ein Typ das erste Merkmal implementieren
kann, muss dieser Typ auch das zweite Merkmal implementieren. Du würdest dies
tun, damit deine Merkmalsdefinition die zugehörigen Elemente des zweiten
Merkmals verwenden kann. Das Merkmal, auf das sich deine Merkmalsdefinition
stützt, wird als _Supermerkmal_ (supertrait) deines Merkmals bezeichnet.

Nehmen wir zum Beispiel an, wir wollen ein Merkmal `OutlinePrint` mit einer
Methode `outline_print` erstellen, das einen bestimmten Wert so formatiert,
dass er in Sternchen eingerahmt ausgegeben wird. Das heißt, wenn wir eine
Struktur `Point` haben, die `Display` so implementiert, dass sie `(x, y)`
ausgibt, dann gibt der Aufruf von `outline_print` einer `Point`-Instanz, die
`1` für `x` und `3` für `y` hat, folgendes aus:

```text
**********
*        *
* (1, 3) *
*        *
**********
```

Bei der Implementierung der Methode `outline_print` wollen wir die
Funktionalität des Merkmals `Display` nutzen. Daher müssen wir festlegen, dass
das Merkmal `OutlinePrint` nur bei Typen funktioniert, die auch `Display`
implementieren und die Funktionalität bieten, die `OutlinePrint` benötigt. Wir
können dies in der Merkmalsdefinition tun, indem wir `OutlinePrint: Display`
angeben. Diese Technik ähnelt dem Angeben einer Merkmalsabgrenzung (trait
bound) bei einem Merkmal. Codeblock 20-23 zeigt eine Implementierung des
Merkmals `OutlinePrint`.

<span class="filename">Dateiname: src/main.rs</span>

```rust
use std::fmt;

trait OutlinePrint: fmt::Display {
    fn outline_print(&self) {
        let output = self.to_string();
        let len = output.len();
        println!("{}", "*".repeat(len + 4));
        println!("*{}*", " ".repeat(len + 2));
        println!("* {output} *");
        println!("*{}*", " ".repeat(len + 2));
        println!("{}", "*".repeat(len + 4));
    }
}
#
# fn main() {}
```

<span class="caption">Codeblock 20-23: Implementieren des Merkmals
`OutlinePrint`, das die Funktionalität von `Display` erfordert</span>

Da wir festgelegt haben, dass `OutlinePrint` das Merkmal `Display` erfordert,
können wir die Funktion `to_string` verwenden, die automatisch für jeden Typ
implementiert wird, der `Display` implementiert. Wenn wir versuchen würden,
`to_string` zu verwenden, ohne einen Doppelpunkt und das Merkmal `Display` nach
dem Merkmalsnamen anzugeben, würden wir eine Fehlermeldung erhalten, die
besagt, dass keine Methode mit dem Namen `to_string` für den Typ `&Self` im
aktuellen Gültigkeitsbereich gefunden wurde.

Lass uns sehen, was passiert, wenn wir versuchen, `OutlinePrint` auf einem Typ
zu implementieren, der `Display` nicht implementiert, z.B. die Struktur
`Point`:

<span class="filename">Dateiname: src/main.rs</span>

```rust,does_not_compile
# use std::fmt;
#
# trait OutlinePrint: fmt::Display {
#     fn outline_print(&self) {
#         let output = self.to_string();
#         let len = output.len();
#         println!("{}", "*".repeat(len + 4));
#         println!("*{}*", " ".repeat(len + 2));
#         println!("* {output} *");
#         println!("*{}*", " ".repeat(len + 2));
#         println!("{}", "*".repeat(len + 4));
#     }
# }
#
struct Point {
    x: i32,
    y: i32,
}

impl OutlinePrint for Point {}
#
# fn main() {
#     let p = Point { x: 1, y: 3 };
#     p.outline_print();
# }
```

Wir erhalten einen Fehler, der besagt, dass `Display` erforderlich, aber nicht
implementiert ist:

```console
$ cargo run
   Compiling traits-example v0.1.0 (file:///projects/traits-example)
error[E0277]: `Point` doesn't implement `std::fmt::Display`
  --> src/main.rs:20:23
   |
20 | impl OutlinePrint for Point {}
   |                       ^^^^^ `Point` cannot be formatted with the default formatter
   |
   = help: the trait `std::fmt::Display` is not implemented for `Point`
   = note: in format strings you may be able to use `{:?}` (or {:#?} for pretty-print) instead
note: required by a bound in `OutlinePrint`
  --> src/main.rs:3:21
   |
3  | trait OutlinePrint: fmt::Display {
   |                     ^^^^^^^^^^^^ required by this bound in `OutlinePrint`

error[E0277]: `Point` doesn't implement `std::fmt::Display`
  --> src/main.rs:24:7
   |
24 |     p.outline_print();
   |       ^^^^^^^^^^^^^ `Point` cannot be formatted with the default formatter
   |
   = help: the trait `std::fmt::Display` is not implemented for `Point`
   = note: in format strings you may be able to use `{:?}` (or {:#?} for pretty-print) instead
note: required by a bound in `OutlinePrint::outline_print`
  --> src/main.rs:3:21
   |
3  | trait OutlinePrint: fmt::Display {
   |                     ^^^^^^^^^^^^ required by this bound in `OutlinePrint::outline_print`
4  |     fn outline_print(&self) {
   |        ------------- required by a bound in this associated function

For more information about this error, try `rustc --explain E0277`.
error: could not compile `traits-example` (bin "traits-example") due to 2 previous errors
```

Um dies zu beheben, implementieren wir `Display` auf `Point` und erfüllen die
Bedingung, die `OutlinePrint` erfordert, in etwa so:

<span class="filename">Dateiname: src/main.rs</span>

```rust
# trait OutlinePrint: fmt::Display {
#     fn outline_print(&self) {
#         let output = self.to_string();
#         let len = output.len();
#         println!("{}", "*".repeat(len + 4));
#         println!("*{}*", " ".repeat(len + 2));
#         println!("* {output} *");
#         println!("*{}*", " ".repeat(len + 2));
#         println!("{}", "*".repeat(len + 4));
#     }
# }
#
# struct Point {
#     x: i32,
#     y: i32,
# }
#
# impl OutlinePrint for Point {}
#
use std::fmt;

impl fmt::Display for Point {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "({}, {})", self.x, self.y)
    }
}
#
# fn main() {
#     let p = Point { x: 1, y: 3 };
#     p.outline_print();
# }
```

Dann wird die Implementierung des Merkmals `OutlinePrint` auf `Point`
erfolgreich kompilieren und wir können `outline_print` auf einer
`Point`-Instanz aufrufen, um sie in Sternchen eingerahmt anzuzeigen.

### Externe Merkmale mit dem Newtype-Muster implementieren

In [„Ein Merkmal für einen Typ implementieren“][implementing-a-trait-on-a-type]
in Kapitel 10 erwähnten wir die Waisenregel, bei der wir ein Merkmal nur dann
auf einem Typ implementieren dürfen, wenn entweder das Merkmal oder der Typ
oder beides lokal in unserer Kiste (crate) vorhanden ist. Es ist möglich, diese
Einschränkung zu umgehen, indem man das _Newtype-Muster_ (newtype pattern)
verwendet, bei dem ein neuer Typ in einer Tupelstruktur erzeugt wird. (Wir
haben Tupelstrukturen in [„Mit Tupel-Strukturen verschiedene Typen
erzeugen“][tuple-structs] in Kapitel 5 behandelt.) Die Tupelstruktur wird ein
Feld haben und eine dünne Verpackung um den Typ sein, für den wir ein Merkmal
implementieren wollen. Dann ist der Verpackungstyp lokal in unserer Kiste und
wir können das Merkmal auf dem Verpackungstyp (wrapper type) implementieren.
_Newtype_ ist ein Begriff, der aus der Programmiersprache Haskell stammt. Beim
Verwenden dieses Musters gibt es keine Beeinträchtigung der Laufzeitperformanz
und der Verpackungstyp wird zur Kompilierzeit elidiert.

Nehmen wir als Beispiel an, wir wollen `Display` auf `Vec<T>` implementieren,
was uns die Waisenregel direkt verbietet, weil das Merkmal `Display` und der
Typ `Vec<T>` außerhalb unserer Kiste definiert sind. Wir können eine Struktur
`Wrapper` erstellen, die eine Instanz von `Vec<T>` enthält; dann können wir
`Display` auf `Wrapper` implementieren und den Wert `Vec<T>` verwenden, wie in
Codeblock 20-24 gezeigt.

<span class="filename">Dateiname: src/main.rs</span>

```rust
use std::fmt;

struct Wrapper(Vec<String>);

impl fmt::Display for Wrapper {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "[{}]", self.0.join(", "))
    }
}

fn main() {
    let w = Wrapper(vec![String::from("Hallo"), String::from("Welt")]);
    println!("w = {w}");
}
```

<span class="caption">Codeblock 20-24: Erstellen eines Typs `Wrapper` um
`Vec<String>` zur Implementierung von `Display`</span>

Die Implementierung von `Display` verwendet `self.0`, um auf den inneren
`Vec<T>` zuzugreifen, da `Wrapper` eine Tupelstruktur ist und `Vec<T>` das
Element mit dem Index 0 im Tupel ist. Dann können wir die Funktionalität des
`Display`-Typs auf `Wrapper` verwenden.

Der Nachteil der Verwendung dieser Technik ist, dass `Wrapper` ein neuer Typ
ist, sodass er nicht die Methoden des Wertes hat, den er hält. Wir müssten alle
Methoden von `Vec<T>` direkt auf `Wrapper` implementieren, sodass die Methoden
an `self.0` delegieren, was uns erlauben würde, `Wrapper` genau wie einen
`Vec<T>` zu behandeln. Wenn wir wollten, dass der neue Typ jede Methode des
inneren Typs hat, wäre die Implementierung des Merkmals `Deref` auf dem
`Wrapper` eine Lösung, um den inneren Typ zurückzugeben (wir haben die
Implementierung des Merkmals `Deref` in [„Intelligente Zeiger wie normale
Referenzen behandeln“][smart-pointer-deref] in Kapitel 15 besprochen). Wenn wir
nicht wollten, dass der `Wrapper`-Typ alle Methoden des inneren Typs hat
&ndash; zum Beispiel, um das Verhalten des `Wrapper`-Typs einzuschränken
&ndash; müssten wir nur die Methoden, die wir wollen, manuell implementieren.

Dieses Newtype-Muster ist auch dann nützlich, wenn keine Merkmale beteiligt
sind. Wechseln wir den Fokus und schauen wir uns einige fortgeschrittene
Möglichkeiten an, mit dem Typsystem von Rust zu interagieren.

[implementing-a-trait-on-a-type]: ch10-02-traits.html#ein-merkmal-für-einen-typ-implementieren
[newtype]: #externe-merkmale-mit-dem-newtype-muster-implementieren
[smart-pointer-deref]: ch15-02-deref.html
[traits]: ch10-02-traits.html
[tuple-structs]: ch05-01-defining-structs.html#mit-tupel-strukturen-verschiedene-typen-erzeugen
