## Merkmalsobjekte (trait objects) die Werte unterschiedlicher Typen erlauben

In Kapitel 8 haben wir erwähnt, dass eine Einschränkung von Vektoren darin
besteht, dass sie nur Elemente eines einzigen Typs speichern können. Wir haben
in Codeblock 8-10 eine Abhilfe geschaffen, indem wir eine
`SpreadsheetCell`-Aufzählung (enum) definiert haben, die Varianten zur Aufnahme
von Ganzzahlen, Fließkommazahlen und Text enthielt. Das bedeutete, dass wir in
jeder Zelle verschiedene Typen von Daten speichern konnten und trotzdem einen
Vektor hatten, der eine Reihe von Zellen darstellte. Dies ist eine perfekte
Lösung, wenn unsere austauschbaren Elemente ein fester Satz von Typen sind, die
wir kennen, wenn unser Code kompiliert wird.

Manchmal möchten wir jedoch, dass unsere Bibliotheksbenutzer in der Lage sind,
die Menge der Typen, die in einer bestimmten Situation erlaubt sind, zu
erweitern. Um zu zeigen, wie wir dies erreichen können, werden wir ein Beispiel
für ein GUI-Werkzeug (Graphical User Interface) erstellen, das über eine Liste
von Elementen iteriert, wobei auf jedem Element eine Methode `draw` aufgerufen
wird, um es auf den Bildschirm zu zeichnen &ndash; eine übliche Technik für
GUI-Werkzeuge. Wir werden eine Bibliothekskiste (library crate) namens `gui`
erstellen, die die Struktur einer GUI-Bibliothek enthält. Diese Kiste (crate)
könnte einige Typen enthalten, die Leute benutzen können, z.B. `Button` und
`TextField`. Darüber hinaus werden `gui`-Benutzer ihre eigenen Typen erstellen
wollen, die gezeichnet werden können: Zum Beispiel könnte ein Programmierer ein
`Image` und ein anderer eine `SelectBox` hinzufügen.

Wir werden für dieses Beispiel keine vollwertige GUI-Bibliothek implementieren,
aber wir werden zeigen, wie die Teile zusammenpassen würden. Zum Zeitpunkt des
Schreibens der Bibliothek können wir nicht alle Typen kennen und definieren,
die andere Programmierer vielleicht erstellen möchten. Aber wir wissen, dass
`gui` den Überblick über viele Werte unterschiedlicher Typen behalten muss, und
es muss für jeden dieser unterschiedlich typisierten Werte eine Methode `draw`
aufrufen. Es muss nicht genau wissen, was passieren wird, wenn wir die Methode
`draw` aufrufen, sondern nur, dass der Wert diese Methode für uns zum Aufruf
bereithält.

Um dies in einer Sprache mit Vererbung zu tun, könnten wir eine Klasse namens
`Component` definieren, die eine Methode namens `draw` enthält. Die anderen
Klassen, z.B. `Button`, `Image` und `SelectBox`, würden von `Component` erben
und somit die Methode `draw` erben. Sie könnten jeweils die `draw`-Methode
überschreiben, um ihr eigenes Verhalten zu definieren, aber das
Programmiergerüst (framework) könnte alle Typen so behandeln, als wären sie
`Component`-Instanzen, und `draw` aufrufen. Aber da Rust keine Vererbung hat,
brauchen wir einen anderen Weg, die `gui`-Bibliothek zu strukturieren, damit
die Benutzer sie um neue Typen erweitern können.

### Definieren eines Merkmals (trait) für allgemeines Verhalten

Um das Verhalten zu implementieren, das wir in `gui` haben wollen, werden wir ein
Merkmal namens `Draw` definieren, das eine Methode namens `draw` haben wird.
Dann können wir einen Vektor definieren, der ein *Merkmalsobjekt* (trait
object) annimmt. Ein Merkmalsobjekt verweist sowohl auf eine Instanz eines
Typs, der das von uns spezifizierte Merkmal implementiert, als auch auf eine
Tabelle, in der Merkmalsmethoden dieses Typs zur Laufzeit nachgeschlagen werden
können. Wir erstellen ein Merkmalsobjekt, indem wir eine Art Zeiger angeben,
z.B. eine Referenz `&` oder einen intelligenten Zeiger `Box<T>`, dann das
Schlüsselwort `dyn` und dann das relevante Merkmal. (Wir werden über den Grund,
warum Merkmalsobjekte einen Zeiger verwenden müssen, in Kapitel 19 im Abschnitt
[„Dynamisch große Typen und das Merkmal `Sized`“][dynamically-sized]) sprechen.
Wir können Merkmalsobjekte an Stelle eines generischen oder konkreten Typs
verwenden. Wo immer wir ein Merkmalsobjekt verwenden, stellt Rusts Typsystem
zur Kompilierzeit sicher, dass jeder in diesem Kontext verwendete Wert das
Merkmal des Merkmalsobjekts implementiert. Folglich müssen wir zur
Kompilierzeit nicht alle möglichen Typen kennen.

Wir haben erwähnt, dass wir in Rust davon absehen, Strukturen (structs) und
Aufzählungen „Objekte“ zu nennen, um sie von den Objekten anderer Sprachen zu
unterscheiden. In einer Struktur oder Aufzählung sind die Daten in den
Struktur-Feldern vom Verhalten in `impl`-Blöcken getrennt, während in anderen
Sprachen die Daten und das Verhalten, die in einem Konzept zusammengefasst
sind, oft als ein Objekt bezeichnet werden. Merkmalsobjekte *sind* jedoch eher
wie Objekte in anderen Sprachen in dem Sinne, dass sie Daten und Verhalten
kombinieren. Aber Merkmalsobjekte unterscheiden sich von traditionellen
Objekten dadurch, dass wir einem Merkmalsobjekt keine Daten hinzufügen können.
Merkmalsobjekte sind nicht so allgemein einsetzbar wie Objekte in anderen
Sprachen: Ihr spezifischer Zweck besteht darin, Abstraktion über allgemeines
Verhalten zu ermöglichen.

In Codeblock 17-3 wird gezeigt, wie ein Merkmal namens `Draw` mit einer Methode
namens `draw` definiert werden kann:

<span class="filename">Dateiname: src/lib.rs</span>

```rust
pub trait Draw {
    fn draw(&self);
}
```

<span class="caption">Codeblock 17-3: Definition des Merkmals `Draw`</span>

Diese Syntax sollte uns aus unseren Diskussionen über die Definition von
Merkmalen in Kapitel 10 bekannt vorkommen. Als nächstes kommt eine neue Syntax:
Codeblock 17-4 definiert eine Struktur namens `Screen`, die einen Vektor namens
`components` enthält. Dieser Vektor ist vom Typ `Box<dyn Draw>`, der ein
Merkmalsobjekt ist; er ist ein Stellvertreter für jeden Typ innerhalb einer
`Box`, der das Merkmal `Draw` implementiert.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
# pub trait Draw {
#     fn draw(&self);
# }
#
pub struct Screen {
    pub components: Vec<Box<dyn Draw>>,
}
```

<span class="caption">Codeblock 17-4: Definition der Struktur `Screen` mit
einem Feld `components`, das einen Vektor von Merkmalsobjekten enthält, die das
`Draw`-Merkmal implementieren</span>

Auf der Struktur `Screen` definieren wir eine Methode namens `run`, die die
`draw`-Methode auf jeder ihrer `components` aufruft, wie in Codeblock 17-5 gezeigt:


<span class="filename">Dateiname: src/lib.rs</span>

```rust
# pub trait Draw {
#     fn draw(&self);
# }
#
# pub struct Screen {
#     pub components: Vec<Box<dyn Draw>>,
# }
#
impl Screen {
    pub fn run(&self) {
        for component in self.components.iter() {
            component.draw();
        }
    }
}
```

<span class="caption">Codeblock 17-5: Eine Methode `run` auf `Screen`, die die
`draw`-Methode jeder Komponente aufruft</span>

Dies funktioniert anders als die Definition einer Struktur, die einen
generischen Typparameter mit Merkmalsabgrenzungen (trait bounds) verwendet. Ein
generischer Typparameter kann jeweils nur durch einen konkreten Typ ersetzt
werden, während Merkmalsobjekte die Möglichkeit bieten, zur Laufzeit mehrere
konkrete Typen für das Merkmalsobjekt einzusetzen. Beispielsweise hätten wir
die Struktur `Screen` mit einem generischen Typ und einer Merkmalsabgrenzung
wie in Codeblock 17-6 definieren können:

<span class="filename">Dateiname: src/lib.rs</span>

```rust
# pub trait Draw {
#     fn draw(&self);
# }
#
pub struct Screen<T: Draw> {
    pub components: Vec<T>,
}

impl<T> Screen<T>
where
    T: Draw,
{
    pub fn run(&self) {
        for component in self.components.iter() {
            component.draw();
        }
    }
}
```

<span class="caption">Codeblock 17-6: Eine alternative Implementierung der
Struktur `Screen` und ihrer `run`-Methode unter Verwendung generischer Typen
und Merkmalsabgrenzungen</span>

Dies schränkt uns auf eine `Screen`-Instanz ein, die eine Liste von Komponenten
hat, die alle vom Typ `Button` oder alle vom Typ `TextField` sind. Wenn du
immer nur homogene Kollektionen haben wirst, ist das Verwenden von generischen
Typen und Merkmalsabgrenzungen vorzuziehen, da die Definitionen zur
Kompilierszeit monomorphisiert werden, um die konkreten Typen zu verwenden.

Andererseits kann bei der Methode mit Merkmalsobjekten eine `Screen`-Instanz
einen `Vec<T>` enthalten, der sowohl eine `Box<Button>` als auch eine
`Box<TextField>` enthält. Schauen wir uns an, wie dies funktioniert, und dann
werden wir über die Auswirkungen auf die Laufzeitperformanz sprechen.

### Implementieren des Merkmals

Nun fügen wir einige Typen hinzu, die das Merkmal `Draw` implementieren. Wir
werden den Typ `Button` zur Verfügung stellen. Auch hier liegt die eigentliche
Implementierung einer GUI-Bibliothek jenseits des Rahmens dieses Buches, sodass
die `draw`-Methode keine nützliche Implementierung in ihrem Rumpf haben wird.
Um sich vorzustellen, wie die Implementierung aussehen könnte, könnte eine
Struktur `Button` Felder für `width`, `height` und `label` haben, wie in
Codeblock 17-7 gezeigt:

<span class="filename">Dateiname: src/lib.rs</span>

```rust,noplayground
# pub trait Draw {
#     fn draw(&self);
# }
#
# pub struct Screen {
#     pub components: Vec<Box<dyn Draw>>,
# }
#
# impl Screen {
#     pub fn run(&self) {
#         for component in self.components.iter() {
#             component.draw();
#         }
#     }
# }
#
pub struct Button {
    pub width: u32,
    pub height: u32,
    pub label: String,
}

impl Draw for Button {
    fn draw(&self) {
        // Code zum tatsächlichen Zeichnen einer Schaltfläche
    }
}
```

<span class="caption">Codeblock 17-7: Eine Struktur `Button`, die das Merkmal
`Draw` implementiert</span>

Die Felder `width`, `height` und `label` in `Button` unterscheiden sich von den
Feldern anderer Komponenten, z.B. dem Typ `TextField`, die diese Felder und
zusätzlich ein `placeholder` haben könnte. Jeder der Typen, die wir auf dem
Bildschirm zeichnen wollen, wird das Merkmal `Draw` implementieren, aber
unterschiedlichen Code in der `draw`-Methode verwenden, um zu definieren, wie
dieser bestimmte Typ gezeichnet werden soll, wie es hier bei `Button` der Fall
ist (ohne den eigentlichen GUI-Code, der den Rahmen dieses Kapitels sprengt).
Der Typ `Button` könnte zum Beispiel einen zusätzlichen `impl`-Block haben, der
Methoden enthält, die sich darauf beziehen, was passiert, wenn ein Benutzer auf
die Schaltfläche klickt. Diese Art von Methoden trifft nicht auf Typen wie
`TextField` zu.

Wenn sich jemand, der unsere Bibliothek benutzt, dazu entschließt, eine
Struktur `SelectBox` zu implementieren, die die Felder `width`, `height` und
`options` enthält, implementiert er ebenfalls das Merkmal `Draw` für den Typ
`SelectBox`, wie in Codeblock 17-8 gezeigt:

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore
use gui::Draw;

struct SelectBox {
    width: u32,
    height: u32,
    options: Vec<String>,
}

impl Draw for SelectBox {
    fn draw(&self) {
        // Code zum tatsächlichen Zeichnen eines Auswahlfeldes
    }
}
```

<span class="caption">Codeblock 17-8: Eine weitere Kiste, die `gui` verwendet
und das Merkmal `Draw` auf einer `SelectBox`-Struktur implementiert</span>

Der Benutzer unserer Bibliothek kann nun seine Funktion `main` schreiben, um
eine `Screen`-Instanz zu erzeugen. Der `Screen`-Instanz kann er eine
`SelectBox` und einen `Button` hinzufügen, indem er jede in eine `Box<T>`
setzt, um ein Merkmalsobjekt zu werden. Er kann dann die `run`-Methode auf der
`Screen`-Instanz aufrufen, die dann `draw` auf jeder der Komponenten aufruft.
Der Codeblock 17-9 zeigt diese Umsetzung:

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore
# use gui::Draw;
#
# struct SelectBox {
#     width: u32,
#     height: u32,
#     options: Vec<String>,
# }
#
# impl Draw for SelectBox {
#     fn draw(&self) {
#         // Code zum tatsächlichen Zeichnen eines Auswahlfeldes
#     }
# }
#
use gui::{Button, Screen};

fn main() {
    let screen = Screen {
        components: vec![
            Box::new(SelectBox {
                width: 75,
                height: 10,
                options: vec![
                    String::from("Ja"),
                    String::from("Vielleicht"),
                    String::from("Nein"),
                ],
            }),
            Box::new(Button {
                width: 50,
                height: 10,
                label: String::from("OK"),
            }),
        ],
    };

    screen.run();
}
```

<span class="caption">Codeblock 17-9: Verwenden von Merkmalsobjekten zum
Speichern von Werten verschiedener Typen, die das gleiche Merkmal
implementieren</span>

Als wir die Bibliothek schrieben, wussten wir nicht, dass jemand den Typ
`SelectBox` hinzufügen könnte, aber unsere `Screen`-Implementierung war in der
Lage, mit dem neuen Typ umzugehen und ihn zu zeichnen, weil `SelectBox` das
Merkmal `Draw` implementiert, was bedeutet, dass sie die `draw`-Methode
implementiert.

Dieses Konzept &ndash; sich nur mit den Nachrichten zu befassen, auf die ein
Wert reagiert, und nicht mit dem konkreten Typ des Wertes &ndash; ähnelt dem
Konzept des *Duck-Typing* in dynamisch typisierten Sprachen: Wenn es wie eine
Ente läuft und wie eine Ente quakt, dann muss es eine Ente sein! Bei der
Implementierung von `run` auf `Screen` in Codeblock 17-5 braucht `run` nicht zu
wissen, was der konkrete Typ jeder Komponente ist. Es prüft nicht, ob eine
Komponente eine Instanz eines `Buttons` oder einer `SelectBox` ist, es ruft nur
die `draw`-Methode auf der Komponente auf. Durch die Spezifikation von
`Box<dyn Draw>` als Typ der Werte im `components`-Vektor haben wir `Screen` so
definiert, dass wir Werte benötigen, auf denen wir die `draw`-Methode aufrufen
können.

Der Vorteil der Verwendung von Merkmalsobjekten und des Rust-Typsystems zum
Schreiben von Code, der dem Code mit Duck-Typing ähnelt, besteht darin, dass
wir nie prüfen müssen, ob ein Wert eine bestimmte Methode zur Laufzeit
implementiert, oder uns Sorgen machen müssen, Fehler zu bekommen, wenn ein Wert
eine Methode nicht implementiert, wir sie aber trotzdem aufrufen. Rust wird
unseren Code nicht kompilieren, wenn die Werte nicht die Merkmale
implementieren, die die Merkmalsobjekte benötigen.

Beispielsweise zeigt Codeblock 17-10, was passiert, wenn wir versuchen, einen
`Screen` mit einem `String` als Komponente zu erstellen:

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore,does_not_compile
use gui::Screen;

fn main() {
    let screen = Screen {
        components: vec![Box::new(String::from("Hallo"))],
    };

    screen.run();
}
```

<span class="caption">Codeblock 17-10: Versuch, einen Typ zu verwenden, der das
Merkmal des Merkmalsobjekts nicht implementiert</span>

Wir werden diesen Fehler erhalten, weil `String` das Merkmal `Draw` nicht
implementiert:

```console
$ cargo run
   Compiling gui v0.1.0 (file:///projects/gui)
error[E0277]: the trait bound `String: Draw` is not satisfied
 --> src/main.rs:5:26
  |
5 |         components: vec![Box::new(String::from("Hallo"))],
  |                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ the trait `Draw` is not implemented for `String`
  |
  = note: required for the cast to the object type `dyn Draw`

For more information about this error, try `rustc --explain E0277`.
error: could not compile `gui` due to previous error
```

Dieser Fehler lässt uns wissen, dass wir entweder etwas an `Screen` übergeben,
das wir nicht übergeben wollten und einen anderen Typ übergeben sollten, oder
wir sollten `Draw` auf `String` implementieren, sodass `Screen` in der Lage
ist, `Draw` darauf aufzurufen.

### Merkmalsobjekte führen dynamischen Aufruf durch

Erinnere dich im Abschnitt [„Code-Performanz beim Verwenden generischer
Datentypen“][performance-of-code-using-generics] in Kapitel 10 an unsere
Diskussion über den Monomorphisierungsprozess, den der Compiler durchführt,
wenn wir bei generischen Typen Merkmalsabgrenzungen verwenden: Der Compiler
generiert nicht-generische Implementierungen von Funktionen und Methoden für
jeden konkreten Typ, den wir anstelle eines generischen Typparameters
verwenden. Der Code, der sich aus der Monomorphisierung ergibt, macht
*statische Aufrufe* (static dispatch), d.h. wenn der Compiler weiß, welche
Methode du zur Kompilierzeit aufrufst. Dies steht im Gegensatz zum *dynamischen
Aufruf* (dynamic dispatch), bei dem der Compiler zur Kompilierzeit nicht weiß,
welche Methode du aufrufst. In Fällen von dynamischem Aufruf erzeugt der
Compiler Code, der zur Laufzeit herausfindet, welche Methode aufzurufen ist.

Wenn wir Merkmalsobjekte verwenden, muss Rust dynamische Aufrufe verwenden. Der
Compiler kennt nicht alle Typen, die mit dem Code verwendet werden könnten, der
Merkmalsobjekte verwendet, sodass er nicht weiß, welche Methode auf welchem Typ
implementiert ist, um sie aufzurufen. Stattdessen verwendet Rust zur Laufzeit
die Zeiger innerhalb des Merkmalsobjekts, um zu wissen, welche Methode
aufgerufen werden soll. Durch dieses Nachschlagen entstehen Laufzeitkosten, die
beim statischen Aufruf nicht anfallen. Der dynamische Aufruf verhindert auch,
dass der Compiler sich dafür entscheiden kann, den Code einer Methode inline zu
verwenden, was wiederum einige Optimierungen verhindert. Wir haben jedoch
zusätzliche Flexibilität im Code erhalten, den wir in Codeblock 17-5
geschrieben haben und in Codeblock 17-9 unterstützen konnten, sodass es sich um
einen Kompromiss handelt, den es zu berücksichtigen gilt.

### Objektsicherheit ist für Merkmalsobjekte erforderlich

Du kannst nur *objektsichere* (object-safe) Merkmale zu Merkmalsobjekten
machen. Einige komplexe Regeln bestimmen alle Eigenschaften, die ein
Merkmalsobjekt sicher machen, aber in der Praxis sind nur zwei Regeln relevant.
Ein Merkmal ist objektsicher, wenn alle im Merkmal definierten Methoden die
folgenden Eigenschaften haben:

* Der Rückgabetyp ist nicht `Self`.
* Es gibt keine generischen Typparameter.

Das Schlüsselwort `Self` ist ein Alias für den Typ, auf dem wir das Merkmal
oder Methoden implementieren. Merkmalsobjekte müssen objektsicher sein, denn
sobald du ein Merkmalsobjekt verwendet hast, kennt Rust nicht mehr den
konkreten Typ, der dieses Merkmal implementiert. Wenn eine Merkmalsmethode den
konkreten `Self`-Typ zurückgibt, aber ein Merkmalsobjekt den genauen Typ
vergisst, der `Self` ist, gibt es keine Möglichkeit, dass die Methode den
ursprünglichen konkreten Typ verwenden kann. Dasselbe gilt für generische
Typparameter, die bei der Verwendung des Merkmals mit konkreten Typparametern
ausgefüllt werden: Die konkreten Typen werden Teil des Typs, der das Merkmal
implementiert. Wenn der Typ durch das Verwenden eines Merkmalsobjekts vergessen
wird, gibt es keine Möglichkeit zu wissen, mit welchen Typen die generischen
Typparameter zu füllen sind.

Ein Beispiel für ein Merkmal, dessen Methoden nicht objektsicher sind, ist das
Merkmal `Clone` der Standardbibliothek. Die Signatur für die Methode `clone` im
Merkmal `Clone` sieht wie folgt aus:

```rust
pub trait Clone {
    fn clone(&self) -> Self;
}
```

Der Typ `String` implementiert das Merkmal `Clone`, und wenn wir die Methode
`clone` auf einer Instanz von `String` aufrufen, erhalten wir eine Instanz von
`String` zurück. In ähnlicher Weise erhalten wir eine Instanz von `Vec<T>`
zurück, wenn wir die Methode `clone` für eine Instanz von `Vec<T>` aufrufen.
Die Signatur von `clone` muss wissen, welcher Typ für `Self` steht, denn das
ist der Rückgabetyp.

Der Compiler zeigt an, wenn du versuchst, etwas zu tun, das gegen die Regeln
der Objektsicherheit in Bezug auf Merkmalsobjekte verstößt. Nehmen wir zum
Beispiel an, wir würden versuchen, die Struktur `Screen` in Codeblock 17-4 zu
implementieren, um Typen zu halten, die das Merkmal `Clone` statt dem Merkmal
`Draw` implementieren, so wie hier:

```rust,does_not_compile
pub struct Screen {
    pub components: Vec<Box<dyn Clone>>,
}
```

Wir würden diesen Fehler bekommen:

```console
$ cargo build
   Compiling gui v0.1.0 (file:///projects/gui)
error[E0038]: the trait `Clone` cannot be made into an object
 --> src/lib.rs:2:29
  |
2 |     pub components: Vec<Box<dyn Clone>>,
  |                             ^^^^^^^^^ `Clone` cannot be made into an object
  |
  = note: the trait cannot be made into an object because it requires `Self: Sized`
  = note: for a trait to be "object safe" it needs to allow building a vtable to allow the call to be resolvable dynamically; for more information visit <https://doc.rust-lang.org/reference/items/traits.html#object-safety>

For more information about this error, try `rustc --explain E0038`.
error: could not compile `gui` due to previous error
```

Dieser Fehler bedeutet, dass du dieses Merkmal auf diese Weise nicht als
Merkmalsobjekt verwenden kannst. Wenn du an weiteren Details zur
Objektsicherheit interessiert bist, lies [Rust RFC 255][rfc-255] oder schaue
dir die [Objektsicherheits-Referenz][object-safety-reference] an.

[dynamically-sized]:
ch19-04-advanced-types.html#dynamisch-große-typen-und-das-merkmal-sized
[performance-of-code-using-generics]:
ch10-01-syntax.html#code-performanz-beim-verwenden-generischer-datentypen
[rfc-255]:
https://github.com/rust-lang/rfcs/blob/master/text/0255-object-safety.md
[object-safety-reference]:
https://doc.rust-lang.org/reference/items/traits.html#object-safety
