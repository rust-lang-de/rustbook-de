## Generische Datentypen

Wir verwenden generische Datentypen (generics), um Definitionen für Elemente
wie Funktionssignaturen oder Strukturen (structs) zu erstellen, die wir dann
mit vielen verschiedenen konkreten Datentypen verwenden können. Sehen wir uns
zunächst an, wie Funktionen, Strukturen, Aufzählungen und Methoden mithilfe von
generischen Datentypen definiert werden können. Danach werden wir uns ansehen,
wie generische Datentypen die Code-Performanz beeinflussen.

### In Funktionsdefinitionen

Bei der Definition einer Funktion, die generische Datentypen verwendet,
platzieren wir die generischen Datentypen in der Signatur der Funktion, wo wir
normalerweise die Datentypen der Parameter und des Rückgabewerts angeben
würden. Dadurch wird unser Code flexibler und bietet den Aufrufern unserer
Funktion mehr Funktionalität, während gleichzeitig Code-Duplikate verhindert
werden.

Um mit unserer Funktion `largest` fortzufahren, zeigt Codeblock 10-4 zwei
Funktionen, die beide den größten Wert in einem Anteilstyp finden. Wir werden
diese dann in einer einzigen Funktion kombinieren, die generische Typen
verwendet.

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn largest_i32(list: &[i32]) -> i32 {
    let mut largest = list[0];

    for &item in list {
        if item > largest {
            largest = item;
        }
    }

    largest
}

fn largest_char(list: &[char]) -> char {
    let mut largest = list[0];

    for &item in list {
        if item > largest {
            largest = item;
        }
    }

    largest
}

fn main() {
    let number_list = vec![34, 50, 25, 100, 65];

    let result = largest_i32(&number_list);
    println!("Die größte Zahl ist {}", result);
#     assert_eq!(result, 100);

    let char_list = vec!['y', 'm', 'a', 'q'];

    let result = largest_char(&char_list);
    println!("Das größte Zeichen ist {}", result);
#     assert_eq!(result, 'y');
}
```

<span class="caption">Codeblock 10-4: Zwei Funktionen, die sich nur in ihren
Namen und den Typen in ihren Signaturen unterscheiden</span>

Die Funktion `largest_i32` ist diejenige, die wir in Codeblock 10-3 extrahiert
haben und die den größten `i32` in einem Anteilstyp findet. Die Funktion
`largest_char` findet das größte `char` in einem Anteilstyp. Die
Funktionsrümpfe haben den gleichen Code, also lass uns die Duplizierung
eliminieren, indem wir einen generischen Typparameter in einer einzigen
Funktion einführen.

Um die Typen in einer neuen, einzigen Funktion zu parametrisieren, müssen wir
den Typparameter benennen, so wie wir es für die Wertparameter einer Funktion
tun. Du kannst jeden beliebigen Bezeichner als Typparametername verwenden. Aber
wir werden `T` verwenden, weil die Typparameternamen gemäß Konvention in Rust
kurz sind, oft nur ein Buchstabe, und Rusts Typbezeichnungskonvention verwendet
Binnenmajuskel (UpperCamelCase). Als Abkürzung für „Typ“ ist `T` die
Standardwahl der meisten Rust-Programmierer.

Wenn wir einen Parameter im Funktionsrumpf verwenden, müssen wir den
Parameternamen in der Signatur deklarieren, damit der Compiler weiß, was
dieser Name bedeutet. In ähnlicher Weise müssen wir den Typ-Parameternamen
deklarieren, bevor wir ihn in einer Funktionssignatur verwenden können. Um die
generische Funktion `largest` zu definieren, platzieren wir die
Typnamen-Deklarationen innerhalb spitzer Klammern `<>`, zwischen dem
Funktionsnamen und der Parameterliste, so wie hier:

```rust,ignore
fn largest<T>(list: &[T]) -> &T {
```

Wir lesen diese Definition wie folgt: Die Funktion `largest` ist generisch über
einen Typ `T`. Sie hat einen Parameter namens `list`, der ein Anteilstyp von
Werten des Typs `T` ist. Die Funktion `largest` gibt eine Referenz auf denn
Wert des gleichen Typs `T` zurück.

Codeblock 10-5 zeigt die kombinierte Funktionsdefinition `largest`, die den
generischen Datentyp in ihrer Signatur verwendet. Der Codeblock zeigt auch, wie
wir die Funktion entweder mit einem Anteilstyp von `i32`-Werten oder
`char`-Werten aufrufen können. Beachte, dass sich dieser Code noch nicht
kompilieren lässt, aber wir werden das Problem später in diesem Kapitel
beheben.

<span class="filename">Dateiname: src/main.rs</span>

```rust,does_not_compile
fn largest<T>(list: &[T]) -> &T {
    let mut largest = &list[0];

    for item in list {
        if item > largest {
            largest = item;
        }
    }

    largest
}

fn main() {
    let number_list = vec![34, 50, 25, 100, 65];

    let result = largest(&number_list);
    println!("Die größte Zahl ist {}", result);

    let char_list = vec!['y', 'm', 'a', 'q'];

    let result = largest(&char_list);
    println!("Das größte Zeichen ist {}", result);
}
```

<span class="caption">Codeblock 10-5: Die Funktion `largest` mit generischen
Typparametern; diese kompiliert aber noch nicht</span>

Wenn wir diesen Code kompilieren, erhalten wir diesen Fehler:

```console
$ cargo run
   Compiling chapter10 v0.1.0 (file:///projects/chapter10)
error[E0369]: binary operation `>` cannot be applied to type `&T`
 --> src/main.rs:5:17
  |
5 |         if item > largest {
  |            ---- ^ ------- &T
  |            |
  |            &T
  |
help: consider restricting type parameter `T`
  |
1 | fn largest<T: std::cmp::PartialOrd>(list: &[T]) -> &T {
  |             ++++++++++++++++++++++

For more information about this error, try `rustc --explain E0369`.
error: could not compile `chapter10` due to previous error
```

Der Hilfetext erwähnt `std::cmp::PartialOrd`, was ein *Merkmal* (trait) ist,
und wir werden im nächsten Abschnitt über Merkmale sprechen. Vorerst bedeutet
dieser Fehler, dass der Rumpf von `largest` nicht für alle möglichen Typen
funktioniert, die `T` sein könnten. Da wir Werte des Typs `T` im Rumpf
vergleichen wollen, können wir nur Typen verwenden, deren Werte sortiert werden
können. Um Vergleiche zu ermöglichen, hat die Standardbibliothek das Merkmal
`std::cmp::PartialOrd`, das du auf Typen implementieren kannst (siehe Anhang C
für weitere Informationen zu diesem Merkmal). Indem wir dem Vorschlag des
Hilfetextes folgen, schränken wir die für `T` gültigen Typen auf diejenigen
ein, die `PartialOrd` implementieren und dieses Beispiel kompiliert, weil die
Standardbibliothek `PartialOrd` sowohl auf `i32` als auch auf `char`
implementiert.

### In Struktur-Definitionen

Wir können auch Strukturen definieren, um einen generischen Typparameter in
einem oder mehreren Feldern mit der `<>` Syntax zu verwenden. Codeblock 10-6
definiert eine Struktur `Point<T>`, um Koordinatenwerte `x` und `y` eines
beliebigen Typs aufzunehmen.

<span class="filename">Dateiname: src/main.rs</span>

```rust
struct Point<T> {
    x: T,
    y: T,
}

fn main() {
    let integer = Point { x: 5, y: 10 };
    let float = Point { x: 1.0, y: 4.0 };
}
```

<span class="caption">Codeblock 10-6: Eine Struktur `Point<T>`, die Werte `x`
und `y` vom Typ `T` enthält</span>

Die Syntax zum Verwenden von generischen Datentypen in Strukturdefinitionen
ähnelt der Syntax, die in Funktionsdefinitionen verwendet wird. Zuerst
deklarieren wir den Namen des Typparameters innerhalb spitzer Klammern direkt
nach dem Namen der Struktur. Dann verwenden wir den generischen Typ in der
Strukturdefinition, wo wir sonst konkrete Datentypen angeben würden.

Beachte, da wir nur einen generischen Typ zur Definition von `Point<T>`
verwendet haben, besagt diese Definition, dass die Struktur `Point<T>`
generisch über einen Typ `T` ist, und die beiden Felder `x` und `y` *denselben*
Typ haben, welcher Typ das auch immer sein mag. Wenn wir eine Instanz von
`Point<T>` erzeugen, die Werte unterschiedlichen Typs hat, wie in Codeblock
10-7, wird sich unser Code nicht kompilieren lassen.

<span class="filename">Dateiname: src/main.rs</span>

```rust,does_not_compile
struct Point<T> {
    x: T,
    y: T,
}

fn main() {
    let wont_work = Point { x: 5, y: 4.0 };
}
```

<span class="caption">Codeblock 10-7: Die Felder `x` und `y` müssen vom
gleichen Typ sein, da beide den gleichen generischen Datentyp `T` haben.</span>

Wenn wir in diesem Beispiel `x` den Integer-Wert 5 zuweisen, lassen wir den
Compiler wissen, dass der generische Typ `T` für diese Instanz von
`Point<T>` ein Integer sein wird. Wenn wir dann 4.0 für `y` angeben, das wir so
definiert haben, dass es den gleichen Typ wie `x` hat, erhalten wir einen
Typfehler wie diesen:

```console
$ cargo run
   Compiling chapter10 v0.1.0 (file:///projects/chapter10)
error[E0308]: mismatched types
 --> src/main.rs:7:38
  |
7 |     let wont_work = Point { x: 5, y: 4.0 };
  |                                      ^^^ expected integer, found floating-point number

For more information about this error, try `rustc --explain E0308`.
error: could not compile `chapter10` due to previous error
```

Um eine Struktur `Point` zu definieren, bei der `x` und `y` generische, aber
unterschiedliche, Typen haben können, können wir mehrere generische
Typparameter verwenden. Zum Beispiel ändern wir in Codeblock 10-8 die
Definition von `Point` so, dass sie über den Typen `T` und `U` generisch ist,
wobei `x` vom Typ `T` und `y` vom Typ `U` ist.

<span class="filename">Dateiname: src/main.rs</span>

```rust
struct Point<T, U> {
    x: T,
    y: U,
}

fn main() {
    let both_integer = Point { x: 5, y: 10 };
    let both_float = Point { x: 1.0, y: 4.0 };
    let integer_and_float = Point { x: 5, y: 4.0 };
}
```

<span class="caption">Codeblock 10-8: `Point<T, U>` ist generisch über zwei
Typen, sodass `x` und `y` Werte unterschiedlichen Typs haben können</span>

Jetzt sind alle gezeigten Instanzen von `Point` erlaubt! Du kannst so viele
generische Typparameter in einer Definition verwenden, wie du willst, aber das
Verwenden von mehr als einigen wenigen macht deinen Code schwer lesbar. Wenn du
denkst, dass du in deinem Code viele generische Typen benötigst, könnte dies
darauf hinweisen, dass dein Code in kleinere Teile zerlegt werden muss.

### In Aufzählungsdefinitionen

Wie wir es bei Strukturen gemacht haben, können wir Aufzählungen definieren, um
generische Datentypen in ihren Varianten zu verwenden. Werfen wir noch einmal
einen Blick auf die Aufzählung `Option<T>`, die die Standardbibliothek bietet
und die wir in Kapitel 6 verwendet haben:

```rust
enum Option<T> {
    Some(T),
    None,
}
```

Diese Definition dürfte für dich jetzt mehr Sinn machen. Wie du sehen kannst,
ist die Aufzählung `Option<T>` über dem Typ `T` generisch und hat zwei
Varianten: `Some`, die einen Wert vom Typ `T` enthält, und `None`, die keinen
Wert enthält. Durch das Verwenden der Aufzählung `Option<T>` können wir das
abstrakte Konzept eines optionalen Wertes ausdrücken und da `Option<T>`
generisch ist, können wir diese Abstraktion unabhängig vom Typ des
optionalen Wertes verwenden.

Aufzählungen können auch mehrere generische Typen verwenden. Die Definition der
Aufzählung `Result`, die wir in Kapitel 9 verwendet haben, ist ein Beispiel
dafür:

```rust
enum Result<T, E> {
    Ok(T),
    Err(E),
}
```

Die Aufzählung `Result` ist generisch über zwei Typen `T` und `E` und hat zwei
Varianten: `Ok`, die einen Wert vom Typ `T` enthält, und `Err`, die einen Wert
vom Typ `E` enthält. Diese Definition macht es bequem, die Aufzählung `Result`
überall dort zu verwenden, wo wir eine Operation haben, die erfolgreich sein
(gibt einen Wert vom Typ `T` zurück) oder fehlschlagen (gibt einen Fehler vom
Typ `E` zurück) könnte. Tatsächlich haben wir dies beim Öffnen einer Datei in
Codeblock 9-3 verwendet, wobei für `T` der Typ `std::fs::File` verwendet wurde,
wenn die Datei erfolgreich geöffnet wurde, und für `E` der Typ
`std::io::Error`, wenn es Probleme beim Öffnen der Datei gab.

Wenn du in deinem Code Situationen mit mehreren Struktur- oder
Aufzählungsdefinitionen erkennst, die sich nur in den Typen der darin
enthaltenen Werte unterscheiden, kannst du doppelten Code vermeiden, indem du
stattdessen generische Typen verwendest.

### In Methodendefinitionen

Wir können Methoden auf Strukturen und Aufzählungen implementieren (wie wir es
in Kapitel 5 getan haben) und auch generische Typen in ihren Definitionen
verwenden. Codeblock 10-9 zeigt die Struktur `Point<T>`, die wir in Codeblock
10-6 definiert haben, mit einer darauf implementierten Methode namens `x`.

<span class="filename">Dateiname: src/main.rs</span>

```rust
struct Point<T> {
    x: T,
    y: T,
}

impl<T> Point<T> {
    fn x(&self) -> &T {
        &self.x
    }
}

fn main() {
    let p = Point { x: 5, y: 10 };

    println!("p.x = {}", p.x());
}
```

<span class="caption">Codeblock 10-9: Implementierung einer Methode `x` auf der
Struktur `Point<T>`, die eine Referenz auf das Feld `x` vom Typ `T`
zurückgibt</span>

Hier haben wir eine Methode `x` auf `Point<T>` definiert, die eine Referenz auf
den Wert im Feld `x` zurückgibt.

Beachte, dass wir `T` direkt nach `impl` deklarieren müssen, damit wir Methoden
zum Typ `Point<T>` implementieren können. Durch das Deklarieren von `T` als
generischen Typ hinter `impl` kann Rust erkennen, dass der Typ in spitzen
Klammern in `Point` ein generischer und kein konkreter Typ ist. Wir hätten
einen anderen Namen für den generischen Parameter wählen können als den in der
Strukturdefinition deklarierten generischen Parameter, aber die Verwendung
desselben Namens ist üblich. Methoden, die innerhalb eines `impl` geschrieben
werden, das den generischen Typ deklariert, werden auf jeder Instanz des Typs
definiert, unabhängig davon, welcher konkrete Typ am Ende den generischen Typ
ersetzt.

Wir können auch Einschränkungen für generische Typen angeben, wenn wir Methoden
auf dem Typ definieren. Wir könnten zum Beispiel Methoden nur auf
`Point<f32>`-Instanzen implementieren und nicht auf `Point<T>`-Instanzen mit
einem beliebigen generischen Typ. In Codeblock 10-10 verwenden wir den
konkreten Typ `f32`, d.h. wir deklarieren keinen Typ hinter `impl`.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# struct Point<T> {
#     x: T,
#     y: T,
# }
#
# impl<T> Point<T> {
#     fn x(&self) -> &T {
#         &self.x
#     }
# }
#
impl Point<f32> {
    fn distance_from_origin(&self) -> f32 {
        (self.x.powi(2) + self.y.powi(2)).sqrt()
    }
}
#
# fn main() {
#     let p = Point { x: 5, y: 10 };
#
#     println!("p.x = {}", p.x());
# }
```

<span class="caption">Codeblock 10-10: Ein `impl`-Block, der nur für eine
Struktur mit einem bestimmten konkreten Typ für den generischen Typparameter
`T` gilt</span>

Dieser Code bedeutet, dass der Typ `Point<f32>` eine Methode
`distance_from_origin` hat und andere Instanzen von `Point<T>`, bei denen `T`
nicht vom Typ `f32` ist, haben diese Methode nicht. Die Methode misst, wie weit
unser Punkt vom Punkt mit den Koordinaten (0,0, 0,0) entfernt ist, und
verwendet mathematische Operationen, die nur für Fließkomma-Typen zur Verfügung
stehen.

Generische Typparameter in einer Strukturdefinition sind nicht immer die
gleichen wie die, die du in denselben Methodensignaturen für diese Struktur
verwendest. In Codeblock 10-11 werden die generischen Typen `X1` und `Y1` für
die Struktur `Point` und `X2` und `Y2` für die Signatur der Methode `mixup`
verwendet, um das Beispiel zu verdeutlichen. Die Methode erzeugt eine neue
`Point`-Instanz mit dem Wert `x` aus `self` (vom Typ `X1`) und dem Wert `y` aus
dem übergebenen `Point` (vom Typ `Y2`).

<span class="filename">Dateiname: src/main.rs</span>

```rust
struct Point<X1, Y1> {
    x: X1,
    y: Y1,
}

impl<X1, Y1> Point<X1, Y1> {
    fn mixup<X2, Y2>(self, other: Point<X2, Y2>) -> Point<X1, Y2> {
        Point {
            x: self.x,
            y: other.y,
        }
    }
}

fn main() {
    let p1 = Point { x: 5, y: 10.4 };
    let p2 = Point { x: "Hallo", y: 'c' };

    let p3 = p1.mixup(p2);

    println!("p3.x = {}, p3.y = {}", p3.x, p3.y);
}
```

<span class="caption">Codeblock 10-11: Eine Methode, die generische Typen aus
der Definition ihrer Struktur anders verwendet</span>

In `main` haben wir einen `Point` definiert, bei dem `x` den Typ `i32` (mit dem
Wert `5`) und `y` den Typ `f64` (mit dem Wert `10.4`) hat. Die Variable `p2`
ist eine Struktur `Point`, bei der `x` einen Zeichenkettenanteilstyp (mit dem
Wert `"Hallo"`) und `y` den Typ `char` (mit dem Wert `c`) hat. Wenn wir `mixup`
auf `p1` mit dem Argument `p2` aufrufen, erhalten wir `p3`, das ein `i32` für
`x` haben wird, weil `x` von `p1` kam. Die Variable `p3` wird ein `char` für
`y` haben, weil `y` von `p2` stammt. Der Makroaufruf `println!` gibt
`p3.x = 5, p3.y = c` aus.

Der Zweck dieses Beispiels ist es, eine Situation zu demonstrieren, in der
einige generische Parameter mit `impl` und einige mit der Methodendefinition
deklariert werden. Hier werden die generischen Parameter `X1` und `Y1` nach
`impl` deklariert, weil sie zur Strukturdefinition gehören. Die generischen
Parameter `X2` und `Y2` werden nach `fn mixup` deklariert, da sie nur für die
Methode relevant sind.

### Code-Performanz beim Verwenden generischer Datentypen

Du fragst dich vielleicht, ob beim Verwenden generischer Typparameter
Laufzeitkosten anfallen. Die gute Nachricht ist, dass die Verwendung
generischer Typen die Ausführung deines Programms nicht langsamer macht als bei
konkreten Typen.

Rust erreicht dies durch Duplizierung von Code mit generischen Datentypen zur
Kompilierzeit. *Codeduplizierung* (monomorphization) ist der Vorgang der
Umwandlung von generischem Code in spezifischen Code durch Ausfüllen der
konkreten Typen, die bei der Kompilierung verwendet werden. Bei diesem Vorgang
führt der Compiler das Gegenteil der Schritte aus, die wir beim Erstellen der
generischen Funktion in Codeblock 10-5 angewendet haben: Der Compiler schaut
sich alle Stellen an, an denen generischer Code aufgerufen wird, und generiert
Code für die konkreten Typen, mit denen der generische Code aufgerufen wird.

Betrachten wir die Funktionsweise bei der Aufzählung `Option<T>` der
Standardbibliothek:

```rust
let integer = Some(5);
let float = Some(5.0);
```

Wenn Rust diesen Code kompiliert, führt es eine Codeduplizierung durch. Während
dieses Vorgangs liest der Compiler die Werte ein, die in
`Option<T>`-Instanzen verwendet wurden, und identifiziert zwei Arten von
`Option<T>`: Eine verwendet den Typ `i32` und die andere `f64`. Als solches
erweitert es die allgemeine Definition von `Option<T>` in zwei auf `i32` und
`f64` spezialisierte Definitionen, wodurch die allgemeine Definition durch die
spezifische ersetzt wird.

Die duplizierte Codeversion sieht ähnlich aus wie die folgende (der Compiler
verwendet andere Namen als die, die wir hier zur Veranschaulichung verwenden):

<span class="filename">Dateiname: src/main.rs</span>

```rust
enum Option_i32 {
    Some(i32),
    None,
}

enum Option_f64 {
    Some(f64),
    None,
}

fn main() {
    let integer = Option_i32::Some(5);
    let float = Option_f64::Some(5.0);
}
```

Der generische Typ `Option<T>` wird durch die vom Compiler erstellten
spezifischen Definitionen ersetzt. Da Rust generischen Code in Code kompiliert,
der den Typ in jedem Fall spezifiziert, zahlen wir keine Laufzeitkosten beim
Verwenden von generischen Datentypen. Wenn der Code läuft, verhält er sich
genauso, wie wenn wir jede Definition von Hand dupliziert hätten. Der Vorgang
der Codeduplizierung macht Rusts generische Datentypen zur Laufzeit äußerst
effizient.

[traits-as-parameters]: ch10-02-traits.html#merkmale-als-parameter
