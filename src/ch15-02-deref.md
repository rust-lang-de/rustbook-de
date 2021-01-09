## Intelligente Zeiger wie normale Referenzen behandeln mit dem Merkmal (trait) `Deref`

Durch die Implementierung des Merkmals `Deref` kann man das Verhalten des
*Dereferenzierungsoperators* (dereference operator) `*` (im Gegensatz zum Multiplikations- oder
Stern-Operator (glob operator)) anpassen. Indem du `Deref` so implementierst, dass ein
intelligenter Zeiger wie eine reguläre Referenz behandelt werden kann, kannst du
Programmcode schreiben, der mit Referenzen arbeitet, und diesen Programmcode
auch mit intelligenten Zeigern verwenden.

Schauen wir uns zunächst an, wie der Dereferenzierungsoperator mit regulären
Referenzen arbeitet. Dann werden wir versuchen, einen benutzerdefinierten Typ zu
definieren, der sich wie `Box<T>` verhält, und herausfinden, warum der
Dereferenzierungsoperator nicht wie eine Referenz für unseren neu definierten
Typ funktioniert. Wir werden untersuchen, wie die Implementierung des Merkmals
`Deref` es intelligenten Zeigern ermöglicht, auf ähnliche Weise wie Referenzen
zu funktionieren, dann sehen wir uns an wie wir mit Rusts *automatischer
Umwandlung* (deref coercion) mit Referenzen oder
intelligenten Zeigern arbeiten können.

> Hinweis: Es gibt einen großen Unterschied zwischen dem Typ `MyBox<T>`, den wir
> gerade erstellen, und dem echten Typ `Box<T>`: Unsere Version speichert ihre
> Daten nicht auf dem Haldenspeicher (heap). In diesem Beispiel konzentrieren wir uns auf
> `Deref`, daher ist es weniger wichtig, wo die Daten tatsächlich gespeichert sind
> als das zeigerähnliche Verhalten.

### Dem Zeiger zum Wert folgen mit dem Dereferenzierungsoperator

Eine reguläre Referenz ist eine Art Zeiger, und eine Möglichkeit, sich einen
Zeiger vorzustellen, ein Pfeil der auf einen Wert zeigt der an einer anderen
Stelle gespeichert ist. In Codeblock 15-6 erstellen wir eine Referenz auf einen
`i32`-Wert und verwenden dann den Dereferenzierungsoperator, um der Referenz zu
den Daten zu folgen:

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let x = 5;
    let y = &x;

    assert_eq!(5, x);
    assert_eq!(5, *y);
}
```

<span class="caption">Codeblock 15-6: Einen Dereferenzierungsoperator verwenden
um einer Referenz auf einen `i32`-Wert zu folgen </span>

Die Variable `x` enthält den `i32`-Wert `5`. Wir setzen `y` gleich einer
Referenz auf `x`. Wir können sicherstellen, das `x`
gleich `5` ist. Wenn wir jedoch eine Aussage über den Wert `y` machen möchten,
auf den er zeigt, müssen wir `*y` verwenden, um der Referenz auf den Wert zu
folgen, auf den sie zeigt (daher *Dereferenzierung*). Sobald wir `y`
dereferenzieren, haben wir Zugriff auf den Zahlenwert auf den `y` zeigt und 
können ihn mit `5` vergleichen.

Wenn wir stattdessen versuchen würden, `assert_eq!(5, y);` zu schreiben, würden
wir diesen Fehler beim Kompilieren erhalten:

```console
$ cargo run
   Compiling deref-example v0.1.0 (file:///projects/deref-example)
error[E0277]: can't compare `{integer}` with `&{integer}`
 --> src/main.rs:6:5
  |
6 |     assert_eq!(5, y);
  |     ^^^^^^^^^^^^^^^^^ no implementation for `{integer} == &{integer}`
  |
  = help: the trait `PartialEq<&{integer}>` is not implemented for `{integer}`
  = note: this error originates in a macro outside of the current crate (in Nightly builds, run with -Z external-macro-backtrace for more info)

error: aborting due to previous error

For more information about this error, try `rustc --explain E0277`.
error: could not compile `deref-example`

To learn more, run the command again with --verbose.
```

Das Vergleichen einer Zahl mit einer Referenz auf eine Zahl ist nicht zulässig,
da es sich um verschiedene Typen handelt. Wir müssen den Dereferenzierungsoperator
verwenden um der Referenz auf den Wert zu folgen, auf den sie zeigt.


### `Box<T>` wie eine Referenz verwenden

Wir können den Programmcode in Codeblock 15-6 neu schreiben, um anstelle einer
Referenz `Box<T>` zu verwenden. Wie Codeblock 15-7 zeigt, funktioniert der
Dereferenzierungsoperator:


<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let x = 5;
    let y = Box::new(x);

    assert_eq!(5, x);
    assert_eq!(5, *y);
}
```

<span class="caption">Codeblock 15-7: Using the dereference operator on a
`Box<i32>`</span>

Der einzige Unterschied zwischen Codeblock 15-7 und 15-6 besteht darin, dass wir 
hier `y` als Instanz eines Feldes festlegen, das auf einen kopierten Wert von `x`
zeigt, und nicht als Referenz, die auf den Wert `x` zeigt. In der letzten
Zusicherung (assertion) können wir den Dereferenzierungsoperator verwenden um dem Zeiger
der Box auf die gleiche Weise zu folgen, wie wir es getan haben, als `y` eine
Referenz war. Als Nächstes werden wir ergründen, was das Besondere an `Box<T>`
ist, das es uns ermöglicht, den Dereferenzierungsoperator zu verwenden, indem
wir unseren eigenen Box-Typ definieren.

### Einen eigenen intelligenten Zeiger definieren

Erstellen wir einen intelligenten Zeiger, der dem von der Standardbibliothek
bereitgestellten Typ `Box<T>` ähnelt, um zu erfahren, wie sich intelligente
Zeiger standardmäßig anders als Referenzen verhalten. Anschließend sehen wir
uns an, wie man die Möglichkeit zur Verwendung des Dereferenzierungsoperators
hinzufügen können.

Der Typ `Box<T>` wird letztendlich als Tupel-Struktur (tuple struct) mit einem
Element definiert, sodass Codeblock 15-8 einen Typ `MyBox<T>` auf die gleiche
Weise definiert. Wir werden auch eine `new`-Funktion definieren, die mit der in
der `Box<T>` definierten übereinstimmt.

<span class="filename">Dateiname: src/main.rs</span>

```rust
struct MyBox<T>(T);

impl<T> MyBox<T> {
    fn new(x: T) -> MyBox<T> {
        MyBox(x)
    }
}
```

<span class="caption">Codeblock 15-8: Einen `MyBox<T>`-Typ definieren</span>

Wir definieren eine Struktur mit dem Namen `MyBox` und deklarieren einen
generischen Parameter `T`, da unser Typ Werte eines beliebigen Typs enthalten
soll. Der Typ `MyBox` ist eine Tupelstruktur mit einem Element vom Typ `T`. Die
Funktion `MyBox::new` verwendet einen Parameter vom Typ `T` und gibt eine 
`MyBox`-Instanz zurück, die den übergebenen Wert enthält.

Versuchen wir, die `main`-Funktion in Codeblock 15-7 zu Codeblock 15-8
hinzuzufügen und sie so zu ändern, dass der von uns definierte Typ `MyBox<T>`
anstelle von `Box<T>` verwendet wird. Der Programmcode in Codeblock 15-9 wird
nicht kompilieren, da Rust nicht weiß, wie er `MyBox` dereferenzieren kann.

<span class="filename">Dateiname: src/main.rs</span>

```rust,does_not_compile
# struct MyBox<T>(T);
#
# impl<T> MyBox<T> {
#     fn new(x: T) -> MyBox<T> {
#         MyBox(x)
#     }
#  }
#
fn main() {
    let x = 5;
    let y = MyBox::new(x);

    assert_eq!(5, x);
    assert_eq!(5, *y);
}
```

<span class="caption">Codeblock 15-9: Versuch, `MyBox<T>` auf die gleiche Weise
wie `Box<T>` und Referenzen zu benutzen</span>

Hier ist der Kompilierfehler den wir erhalten:

```console
$ cargo run
   Compiling deref-example v0.1.0 (file:///projects/deref-example)
error[E0614]: type `MyBox<{integer}>` cannot be dereferenced
  --> src/main.rs:14:19
   |
14 |     assert_eq!(5, *y);
   |                   ^^

error: aborting due to previous error

For more information about this error, try `rustc --explain E0614`.
error: could not compile `deref-example`

To learn more, run the command again with --verbose.
```

Unser Typ `MyBox<T>` kann nicht dereferenziert werden, da wir diese
Fähigkeit für unseren Typ nicht implementiert haben. Um eine
Dereferenzierung mit dem Operator `*` zu ermöglichen, implementieren wir das
Merkmal `Deref`.

### Einen Typ wie eine Referenz behandeln durch Implementierens des `Deref`-Merkmals

Wie in Kapitel 10 besprochen, müssen wir zur Implementierung eines Merkmals
Implementierungen für die erforderlichen Methoden des Merkmals bereitstellen.
Das von der Standardbibliothek bereitgestellte Merkmal `Deref` erfordert die
Implementierung einer Methode namens `deref`, die `self` ausleiht (borrow) und
eine Referenz auf die beinhalteten Daten zurückgibt. Codeblock 15-10 enthält
eine Implementierung von `Deref`, um die Definition von `MyBox` zu ergänzen:

<span class="filename">Dateiname: src/main.rs</span>

```rust
use std::ops::Deref;

impl<T> Deref for MyBox<T> {
    type Target = T;

    fn deref(&self) -> &T {
        &self.0
    }
}
# 
# struct MyBox<T>(T);
# 
# impl<T> MyBox<T> {
#     fn new(x: T) -> MyBox<T> {
#         MyBox(x)
#     }
# }
# 
# fn main() {
#     let x = 5;
#     let y = MyBox::new(x);
# 
#     assert_eq!(5, x);
#     assert_eq!(5, *y);
# }
```

<span class="caption">Codeblock 15-10: `Deref` auf `MyBox<T>` implementieren</span>

Die Syntax `type Target = T;` definiert einen assoziierten Typ, den das Merkmal
`Deref` verwenden soll. Assoziierte Typen sind eine andere Art, einen
generischen Parameter zu deklarieren, aber darüber musst du dir vorerst noch
keine Gedanken machen, in Kapitel 19 werden wir sie ausführlicher behandeln.

Wir füllen den Rumpf der `deref`-Methode mit `&self.0`, und `deref` gibt
eine Referenz auf den Wert zurück, auf den wir mit dem `*`-Operator zugreifen
möchten. Die `main`-Funktion in Codeblock 15-9, die `*` für den Wert `MyBox<T>`
aufruft, kompiliert nun und die Zusicherungen werden bestanden!

Ohne das Merkmal `Deref` kann der Compiler nur `&`-Referenzen dereferenzieren.
Die `deref`-Methode gibt dem Compiler die Möglichkeit, einen Wert eines
beliebigen Typs zu verwenden, der `Deref` implementiert, und die `deref`-Methode
aufzurufen, um eine `&`-Referenz zu erhalten, die er dereferenzieren kann.

Als wir in Codeblock 15-9 `*y` eingegeben haben, hat Rust hinter den Kulissen
tatsächlich diesen Programmcode ausgeführt:

```rust,ignore
*(y.deref())
```

Rust ersetzt den Operator `*` durch einen Aufruf der `deref`-Methode und dann
durch eine einfache Dereferenzierung, sodass wir nicht darüber nachdenken
müssen, ob wir die `deref`-Methode aufrufen müssen oder nicht. Mit dieser
Rust-Funktionalität können wir Code schreiben, der unabhängig davon, ob wir eine reguläre
Referenz oder einen Typ haben der `Deref` implementiert, identisch funktioniert.

Der Grund, warum die `deref`-Methode eine Referenz auf einen Wert zurückgibt und
die einfache Dereferenzierung außerhalb der Klammern in `*(y.deref())`
weiterhin erforderlich ist, ist die Eigentümerschaft (ownership). Wenn die
`deref`-Methode den Wert direkt anstelle einer Referenz auf den Wert zurückgibt,
wird der Wert aus `self` herausverschoben. Meistens wenn wir den
Dereferenzierungsoperator verwenden, wollen wir, so wie auch in diesem Fall,
nicht die Eigentümerschaft des inneren Wertes von `MyBox<T>` übernehmen.

Beachte, dass der `*`-Operator durch einen Aufruf der `deref`-Methode und dann
nur einmal durch einen Aufruf des `*`-Operators ersetzt wird, jedes Mal, wenn
wir ein `*` in unserem Programmcode verwenden. Da die Ersetzung des 
`*`-Operator nicht unendlich rekursiv ist, erhalten wir Daten vom Typ
`i32`, die mit der `5` in `assert_eq!` in Codeblock 15-9 übereinstimmen.

### Implizite automatische Umwandlung mit Funktionen und Methoden

*Automatische Umwandlung* (deref coercion) ist eine bequeme Funktionalität die Rust bei Argumenten für
Funktionen und Methoden ausführt. Die automatische Umwandlung funktioniert nur bei Typen,
die das Merkmal `Deref` implementieren. Die automatische Umwandlung wandelt einen solchen
Typ in eine Referenz auf einen anderen Typ um. Zum Beispiel kann die automatische
Umwandlung `&String` in `&str` konvertieren, da `String` das Merkmal `Deref`
implementiert, sodass `str` zurückgegeben wird. Die automatische Umwandlung erfolgt
automatisch, wenn wir eine Referenz auf den Wert eines bestimmten Typs als Argument an
eine Funktion oder Methode übergeben, die nicht dem Parametertyp in der Funktion
oder Methodendefinition übereinstimmt. Eine Folge von Aufrufen der
`deref`-Methode konvertiert den von uns angegebenen Typ in den Typ, den der
Parameter benötigt.

Rust wurde um die automatische Umwandlung erweitert, damit Programmierer, die Funktions- und
Methodenaufrufe schreiben, nicht so viele explizite Referenzierungen und Dereferenzierungen
mit `&` und `*` angeben müssen. Mit der Funktionalität der automatischen Umwandlung
können wir auch mehr Programmcode schreiben, der sowohl für Referenzen als auch
für intelligente Zeiger geeignet ist.

Um die automatische Umwandlung in Aktion zu sehen, verwenden wir den in Codeblock 15-8
definierten Typ `MyBox<T>` sowie die Implementierung von `Deref`, die wir in
Codeblock 15-10 hinzugefügt haben. Codeblock 15-11 zeigt die Definition einer
Funktion mit einen Zeichenketten-Anteilstyp (string slice) Parameter:

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn hello(name: &str) {
    println!("Hallo {}!", name);
}
```

<span class="caption">Codeblock 15-11: Eine `hello`-Funktion mit dem Parameter
`name` vom Typ `&str`</span>

Wir können die Funktion `hello` mit einem Zeichenketten-Anteilstyp als Argument
aufrufen, wie zum Beispiel `hello("Rust");`. Die automatischer Umwandlung ermöglicht es,
`hello` mit einer Referenz auf einen Wert vom Typ `MyBox<String>` aufzurufen,
wie es in Codeblock 15-12 gezeigt wird:

<span class="filename">Dateiname: src/main.rs</span>

```rust
# use std::ops::Deref;
# 
# impl<T> Deref for MyBox<T> {
#     type Target = T;
# 
#     fn deref(&self) -> &T {
#         &self.0
#     }
# }
# 
# struct MyBox<T>(T);
# 
# impl<T> MyBox<T> {
#     fn new(x: T) -> MyBox<T> {
#         MyBox(x)
#     }
# }
# 
# fn hello(name: &str) {
#     println!("Hallo {}!", name);
# }
#
fn main() {
    let m = MyBox::new(String::from("Rust"));
    hello(&m);
}
```

<span class="caption">Codeblock 15-12: `hello` mit einer Referenz auf einen
`MyBox<String>`-Wert, der aufgrund automatischer Umwandlung funktioniert</span>

Hier rufen wir die Funktion `hello` mit dem Argument `&m` auf, das auf einen
`MyBox<String>`-Wert verweist. Da wir in Codeblock 15-10 das Merkmal `Deref` für
`MyBox<T>` implementiert haben, kann Rust `&MyBox<String>` durch Aufrufen von
`deref` in `&String` verwandeln. Die Standardbibliothek bietet eine
Implementierung von `Deref` auf `String`, die einen Zeichenketten-Anteilstyp
zurückgibt. Dies kann man in der API-Dokumentation für `Deref` nachlesen. Rust
ruft erneut `deref` auf, um `&String` in `&str` umzuwandeln, was der Definition
der Funktion `hello` entspricht.

Wenn Rust keine automatische Umwandlung implementiert hätte, müssten wir den
Programmcode in Codeblock 15-13 anstelle des Programmcodes in 15-12 schreiben,
um `hello` mit einem Wert vom Typ `&MyBox<String>` aufzurufen.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# use std::ops::Deref;
# 
# impl<T> Deref for MyBox<T> {
#     type Target = T;
# 
#     fn deref(&self) -> &T {
#         &self.0
#     }
# }
# 
# struct MyBox<T>(T);
# 
# impl<T> MyBox<T> {
#     fn new(x: T) -> MyBox<T> {
#         MyBox(x)
#     }
# }
# 
# fn hello(name: &str) {
#     println!("Hallo {}!", name);
# }
# 
fn main() {
    let m = MyBox::new(String::from("Rust"));
    hello(&(*m)[..]);
}
```

<span class="caption">Codeblock 15-13: Programmcode den wir schreiben
müssten wenn Rust keine automatische Umwandlung hätte</span>

Das `(*m)` dereferenziert `Mybox<String>` in einen `String`. Dann nehmen die `&`
und `[..]` einen Anteilstyp des `String`, der gleich der gesamten Zeichenkette ist, um der
Signatur von `hello` zu entsprechen. Der Programmcode ohne automatische Umwandlung ist
mit allen Symbolen schwerer zu lesen, zu schreiben und zu verstehen. Durch
die automatische Umwandlung kann Rust diese Konvertierung automatisch für uns abwickeln.

Wenn das Merkmal `Deref` für die beteiligten Typen definiert ist, analysiert
Rust die Typen und verwendet `Deref::deref` so oft wie nötig, um eine Referenz
zu erhalten, die dem Typ des Parameters entspricht. Die Häufigkeit, mit der
`Deref::deref` eingefügt werden muss, wird zur Kompilierzeit aufgelöst,
sodass kein Nachteil zur Laufzeit bei der Nutzung der automatischen Umwandlung
entsteht!

### Wie die automatische Umwandlung mit Veränderlichkeit umgeht

Ähnlich wie du das Merkmal `Deref` verwendest, um den `*`-Operator bei
unveränderlichen Referenzen zu überschreiben, kannst du das Merkmal `DerefMut`
verwenden, um den `*`-Operator bei veränderlichen Referenzen zu überschreiben.

Rust wendet die automatische Umwandlung an, wenn Typen und Merkmalsimplementierungen in
folgenden drei Fällen gefunden werden:

* Von `&T` zu `&U`, wenn `T:Deref<Target=U>`
* Von `&mutT` zu `&mutU`, wenn `T:DerefMut<Target=U>`
* Von `&mutT` zu `&U`, wenn `T:Deref<Target=U>`

Die ersten beiden Fälle sind bis auf die Veränderlichkeit gleich. Der erste Fall
besagt, dass wenn man einen `&T` hat und `T` `Deref` für einen Typ `U` 
implementiert hat, man transparent einen `&U` erhalten kann. Der zweite Fall
besagt, dass die gleiche automatische Umwandlung bei veränderlichen Referenzen
erfolgt.

Der dritte Fall ist schwieriger: Rust wird auch eine veränderliche Referenz in
eine unveränderliche umwandeln. Das Gegenteil ist jedoch *nicht* möglich:
Unveränderliche Referenzen werden niemals zu veränderlichen gemacht. Wenn man
eine veränderliche Referenz hat, muss diese veränderliche Referenz aufgrund der
Ausleihregeln (borrowing rules) die einzige Referenz auf diese Daten sein
(anderenfalls würde das Programm nicht kompilieren). Das Konvertieren einer
veränderlichen Referenz in eine unveränderliche verstößt niemals gegen die
Ausleihregeln. Das Konvertieren einer unveränderlichen Referenz in eine
veränderliche Referenz, würde erfordern, dass die ursprüngliche unveränderliche
Referenz die einzige unveränderliche Referenz auf diese Daten ist, aber die
Ausleihregeln garantieren dies nicht.
Daher kann Rust nicht davon ausgehen, dass die Konvertierung einer
unveränderlichen Referenz in eine veränderbare Referenz möglich ist.
