## Methodensyntax

*Methoden* sind Funktionen recht ähnlich: Sie werden mit dem Schlüsselwort `fn`
und ihrem Namen deklariert, sie können Parameter und einen Rückgabewert haben,
und sie enthalten etwas Code, der ausgeführt wird, wenn sie aufgerufen werden. 
Methoden unterscheiden sich jedoch von Funktionen dadurch, dass sie im Kontext
einer Struktur (struct) (oder einer Aufzählung (enum) oder eines
Merkmalsobjektes (trait object), die wir in [Kapitel 6][enums] und [Kapitel
17][trait-objects] behandeln) definiert werden und ihr erster Parameter stets
`self` ist. `self` repräsentiert die Instanz der Struktur, zu der die Methode
aufgerufen wird.

### Definieren von Methoden

Lass uns die Funktion `area`, die eine `Rectangle`-Instanz als Parameter hat,
ändern und stattdessen eine Methode `area` auf der Struktur `Rectangle`
definieren, wie in Codeblock 5-13 zu sehen ist.

<span class="filename">Dateiname: src/main.rs</span>

```rust
#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32,
}

impl Rectangle {
    fn area(&self) -> u32 {
        self.width * self.height
    }
}

fn main() {
    let rect1 = Rectangle {
        width: 30,
        height: 50,
    };

    println!(
        "Die Fläche des Rechtecks ist {} Quadratpixel.",
        rect1.area()
    );
}
```

<span class="caption">Codeblock 5-13: Methode `area` der Struktur `Rectangle`</span>

Um die Funktion im Kontext von `Rectangle` zu definieren, beginnen wir mit dem
Block `impl` (Implementierung) für `Rectangle`. Alles in diesem Block wird mit
dem Typ `Rectangle` assoziiert. Dann verschieben wir die Funktion `area` in die
geschweiften Klammern von `impl`, ändern den ersten (und in diesem Fall
einzigen) Parameter zu `self` und passen den Methodenrumpf entsprechend an. In
`main`, wo wir die Funktion `area` aufrufen und `rect1` als Argument übergeben,
können wir stattdessen die *Methodensyntax* verwenden, um die Methode `area`
auf unserer `Rectangle`-Instanz aufzurufen. Die Methodensyntax bezieht sich auf
eine Instanz: Wir ergänzen einen Punkt, gefolgt vom Methodennamen, Klammern und
Argumenten.

In der Signatur von `area` verwenden wir `&self` anstelle von `rectangle:
&Rectangle`. Das `&self` ist eigentlich die Abkürzung für `self: &Self`.
Innerhalb eines `impl`-Blocks ist der Typ `Self` ein Alias für den Typ, für den
der `impl`-Block steht. Methoden müssen einen Parameter mit dem Namen `self`
vom Typ `Self` als ihren ersten Parameter haben, Rust lässt dich dies abkürzen,
indem du nur den Namen `self` an der Stelle des ersten Parameters angibst.
Beachte, dass wir immer noch das `&` vor der Abkürzung `self` verwenden müssen,
um anzuzeigen, dass diese Methode die Instanz `Self` ausleiht, genau wie in
`Rechteck: &Rechteck`. Methoden können die Eigentümerschaft von `self`
übernehmen, `self` unveränderbar ausleihen, wie wir es hier getan haben, oder
`self` veränderbar ausleihen, so wie bei jedem anderen Parameter auch.

Wir haben hier `&self` aus dem gleichen Grund gewählt wie `&Rectangle` in der
Funktionsvariante: Wir wollen keine Eigentümerschaft übernehmen, wir wollen die
Daten der Struktur nur lesen, nicht schreiben. Wenn wir die Instanzdaten ändern
wollten, müssten wir `&mut self` als ersten Parameter verwenden. Es kommt nur
selten vor, dass eine Methode die Eigentümerschaft der Instanz übernimmt, indem
sie `self` als ersten Parameter verwendet. Diese Technik wird typischerweise
dann verwendet, wenn die Methode `self` in etwas anderes transformiert und man
verhindern will, dass der Aufrufer nach der Transformation die ursprüngliche
Instanz verwendet.

Der Hauptgrund für Methoden gegenüber Funktionen liegt abgesehen davon, dass
bei jeder Methodendeklaration der Typ von `self` nicht ständig wiederholt
werden muss, in der Organisation. Wir haben alle Dinge, die wir mit einer
Instanz eines Typs tun können, in einen einzigen `impl` Block gepackt.
Zukünftige Nutzer unseres Codes müssen so nicht an verschiedenen Stellen in der
von uns bereitgestellten Bibliothek nach Fähigkeiten von `Rectangle` suchen.

Beachte, dass wir einer Methode denselben Namen geben können wie einem der
Felder der Struktur. Zum Beispiel können wir eine Methode auf `Rectangle`
definieren, die ebenfalls `width` heißt:

<span class="filename">Dateiname: src/main.rs</span>

```rust
# #[derive(Debug)]
# struct Rectangle {
#     width: u32,
#     height: u32,
# }
#
impl Rectangle {
    fn width(&self) -> bool {
        self.width > 0
    }
}

fn main() {
    let rect1 = Rectangle {
        width: 30,
        height: 50,
    };

    if rect1.width() {
        println!("Das Rechteck hat eine Breite ungleich Null; sie ist {}", rect1.width);
    }
}
```

Hier entscheiden wir uns dafür, dass die Methode `width` den Wert `true`
zurückgibt, wenn der Wert im Feld `width` der Instanz größer als 0 ist, und
`false`, wenn der Wert 0 ist: Wir können ein Feld innerhalb einer gleichnamigen
Methode für jeden Zweck verwenden. Wenn wir in `main` nach `rect1.width` eine
Klammer setzen, weiß Rust, dass wir die Methode `width` meinen. Wenn wir keine
Klammern verwenden, weiß Rust, dass wir das Feld `width` meinen.

Oft, aber nicht immer, wird eine Methode mit demselben Namen wie ein Feld so
definiert, dass sie nur den Wert des Feldes zurückgeben und nichts anderes tun.
Methoden wie diese werden *getters* genannt, und Rust implementiert sie nicht
automatisch für Strukturfelder, wie es einige andere Sprachen tun. Getter sind
nützlich, weil man das Feld als privat, die Methode aber als öffentlich
kennzeichnen und so den Nur-Lese-Zugriff auf dieses Feld als Teil der
öffentlichen API des Typs erhält. Was öffentlich und privat bedeuten und wie
man ein Feld oder eine Methode als öffentlich oder privat kennzeichnet, werden
wir in [Kapitel 7][public] behandeln.

> ### Wo ist der Operator `->`?
>
> In C und C++ werden zwei verschiedene Operatoren für den Aufruf von Methoden
> verwendet: Man verwendet `.`, wenn eine Methode direkt auf dem Objekt
> aufgerufen wird, und `->`, wenn die Methode auf einem Zeiger auf das Objekt
> aufrufen und der Zeiger zuerst dereferenziert werden muss. Anders gesagt,
> wenn `object` ein Zeiger ist, ist `object->something()` ähnlich zu
> `(*object).something()`.
>
> Rust hat kein Äquivalent zum Operator `->`. Stattdessen hat Rust eine
> Funktionalität namens *automatische Referenzierung und Dereferenzierung*
> (automatic referencing and dereferencing). Der Aufruf von Methoden ist einer
> der wenigen Orte in Rust, der dieses Verhalten aufweist.
>
> Und so funktioniert es: Wenn du eine Methode mit `object.something()`
> aufrufst, fügt Rust automatisch `&`, `&mut` oder `*` hinzu, sodass `object`
> zur Signatur der Methode passt. Mit anderen Worten sind folgende Aufrufe
> gleich:
>
> ```rust
> # #[derive(Debug,Copy,Clone)]
> # struct Point {
> #     x: f64,
> #     y: f64,
> # }
> #
> # impl Point {
> #    fn distance(&self, other: &Point) -> f64 {
> #        let x_squared = f64::powi(other.x - self.x, 2);
> #        let y_squared = f64::powi(other.y - self.y, 2);
> #
> #        f64::sqrt(x_squared + y_squared)
> #    }
> # }
> # let p1 = Point { x: 0.0, y: 0.0 };
> # let p2 = Point { x: 5.0, y: 6.5 };
> p1.distance(&p2);
> (&p1).distance(&p2);
> ```
>
> Der erste Aufruf sieht viel sauberer aus. Die automatische Referenzierung
> funktioniert, weil Methoden einen eindeutigen Empfänger haben - den Typ von
> `self`. Wenn man den Empfänger und den Namen einer Methode angibt, kann Rust
> eindeutig herausfinden, ob die Methode lesend (`&self`), veränderbar
> (`&mut self`) oder konsumierend (`self`) ist. Die Tatsache, dass Rust das
> Ausleihen für die Methodenempfänger implizit macht, ist ein großer Beitrag
> zur Ergonomie der Eigentümerschaft in der Praxis.

### Methoden mit mehreren Parametern

Lass uns den Umgang mit Methoden üben, indem wir eine zweite Methode zur
Struktur `Rectangle` implementieren. Diesmal soll eine zweite Instanz von
`Rectangle` entgegengenommen und `true` zurückgeben werden, wenn das zweite
`Rectangle` vollständig in `self` (dem ersten `Rectangle`) hineinpasst;
andernfalls soll `false` zurückgegeben werden. Das heißt, sobald wir die
Methode `can_hold` definiert haben, wollen wir in der Lage sein, das in
Codeblock 5-14 gezeigte Programm zu schreiben.

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore
fn main() {
    let rect1 = Rectangle {
        width: 30,
        height: 50,
    };
    let rect2 = Rectangle {
        width: 10,
        height: 40,
    };
    let rect3 = Rectangle {
        width: 60,
        height: 45,
    };

    println!("Umfasst rect1 rect2? {}", rect1.can_hold(&rect2));
    println!("Umfasst rect1 rect3? {}", rect1.can_hold(&rect3));
}
```

<span class="caption">Codeblock 5-14: Verwendung der noch nicht geschriebenen
Methode `can_hold`</span>

Die erwartete Ausgabe würde wie folgt aussehen, da beide Dimensionen von
`rect2` kleiner als die Dimensionen von `rect1` sind, aber `rect3` breiter als
`rect1` ist:

```text
Umfasst rect1 rect2? true
Umfasst rect1 rect3? false
```

Wir wissen, dass wir eine Methode definieren wollen, also wird sie innerhalb
des Blocks `impl Rectangle` liegen. Die Methode wird `can_hold` heißen und sie
wird einen weiteren Parameter vom Typ `Rectangle` unveränderbar ausleihen. Wir
können den Typ des Parameters erkennen, indem wir uns den Code ansehen, der die
Methode aufruft: `rect1.can_hold(&rect2)` nimmt `&rect2` entgegen, also eine
unveränderbare Ausleihe von `rect2` vom Typ `Rectangle`. Das macht Sinn, da
wir `rect2` nur lesen müssen (anstatt zu schreiben, wofür wir eine
veränderbare Ausleihe bräuchten) und `main` die Eigentümerschaft an `rect2`
zurückerhalten soll, sodass wir es nach dem Aufruf der Methode `can_hold`
weiter verwenden können. Der Rückgabewert von `can_hold` ist ein boolescher
Wert und die Implementierung prüft, ob Breite und Höhe von `self` jeweils
größer als von `Rectangle` sind. Fügen wir die neue Methode `can_hold` zum
Block `impl` aus Codeblock 5-13 hinzu, wie in Codeblock 5-15 gezeigt.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# #[derive(Debug)]
# struct Rectangle {
#     width: u32,
#     height: u32,
# }
#
impl Rectangle {
    fn area(&self) -> u32 {
        self.width * self.height
    }

    fn can_hold(&self, other: &Rectangle) -> bool {
        self.width > other.width && self.height > other.height
    }
}
#
# fn main() {
#     let rect1 = Rectangle {
#         width: 30,
#         height: 50,
#     };
#     let rect2 = Rectangle {
#         width: 10,
#         height: 40,
#     };
#     let rect3 = Rectangle {
#         width: 60,
#         height: 45,
#     };
#
#     println!("Umfasst rect1 rect2? {}", rect1.can_hold(&rect2));
#     println!("Umfasst rect1 rect3? {}", rect1.can_hold(&rect3));
# }
```

<span class="caption">Codeblock 5-15: Implementierung der Methode `can_hold`
auf `Rectangle`, die eine weitere `Rectangle`-Instanz als Parameter hat</span>

Wenn wir diesen Code mit der Funktion `main` in Codeblock 5-14 ausführen,
erhalten wir die gewünschte Ausgabe. Methoden können mehrere Parameter haben,
die wir in der Signatur nach dem Parameter `self` angeben. Diese Parameter
funktionieren genau wie Parameter in Funktionen.

### Assoziierte Funktionen

Alle Funktionen, die innerhalb eines `impl`-Blocks definiert sind, werden
*assoziierte Funktionen* genannt, weil sie mit dem Typ assoziiert sind, der
nach dem `impl` benannt ist. Wir können assoziierte Funktionen definieren, die
nicht `self` als ihren ersten Parameter haben (und somit keine Methoden sind),
weil sie keine Instanz des Typs benötigen, um damit zu arbeiten. Wir haben
bereits eine solche Funktion verwendet: Die Funktion `String::from`, die für
den Typ `String` definiert ist.

Assoziierte Funktionen, die keine Methoden sind, werden oft als Konstruktoren
verwendet, die eine neue Instanz der Struktur zurückgeben. Diese werden oft als
`new` bezeichnet, aber `new` ist kein spezieller Name und ist nicht in die
Sprache eingebaut. Wir könnten zum Beispiel eine assoziierte Funktion mit dem
Namen `square` bereitstellen, die einen eindimensionalen Parameter hat und
diesen sowohl für die Breite als auch für die Höhe verwendet, sodass es
einfacher ist, ein quadratisches `Rectangle` zu erstellen, anstatt denselben
Wert zweimal angeben zu müssen:

<span class="filename">Dateiname: src/main.rs</span>

```rust
# #[derive(Debug)]
# struct Rectangle {
#     width: u32,
#     height: u32,
# }
#
impl Rectangle {
    fn square(size: u32) -> Self {
        Rectangle {
            width: size,
            height: size,
        }
    }
}
#
# fn main() {
#     let sq = Rectangle::square(3);
# }
```

Die Schlüsselwörter `Self` im Rückgabetyp und im Rumpf der Funktion sind Aliase
für den Typ, der nach dem Schlüsselwort `impl` steht, in diesem Fall
`Rectangle`.

Um diese assoziierte Funktion aufzurufen, verwenden wir die Syntax `::` mit dem
Strukturnamen, z.B. `let sq = Rectangle::square(3);`. Diese Funktion gehört zum
Namensraum der Struktur: Die Syntax `::` wird sowohl für assoziierte Funktionen
als auch für Namensräume, die von Modulen erzeugt werden, verwendet. Wir werden
die Module in [Kapitel 7][modules] besprechen.

### Mehrere `impl`-Blöcke

Jede Struktur darf mehrere `impl`-Blöcke haben. Beispielsweise entspricht
Codeblock 5-15 dem in Codeblock 5-16 gezeigten Code, bei dem jede Methode in
einem eigenen `impl`-Block steht.

```rust
# #[derive(Debug)]
# struct Rectangle {
#     width: u32,
#     height: u32,
# }
#
impl Rectangle {
    fn area(&self) -> u32 {
        self.width * self.height
    }
}

impl Rectangle {
    fn can_hold(&self, other: &Rectangle) -> bool {
        self.width > other.width && self.height > other.height
    }
}
#
# fn main() {
#     let rect1 = Rectangle {
#         width: 30,
#         height: 50,
#     };
#     let rect2 = Rectangle {
#         width: 10,
#         height: 40,
#     };
#     let rect3 = Rectangle {
#         width: 60,
#         height: 45,
#     };
#
#     println!("Umfasst rect1 rect2? {}", rect1.can_hold(&rect2));
#     println!("Umfasst rect1 rect3? {}", rect1.can_hold(&rect3));
# }
```

<span class="caption">Codeblock 5-16: Neuschreiben von Codeblock 5-15 unter
Verwendung mehrerer `impl`-Blöcke</span>

Es ist nicht nötig, diese Methoden hier auf mehrere `impl`-Blöcke zu verteilen,
aber es handelt sich um eine gültige Syntax. Wir werden in Kapitel 10 einen
Fall sehen, bei dem mehrere `impl`-Blöcke hilfreich sind, wenn wir generische
Typen und Merkmale behandeln.

## Zusammenfassung

Mit Strukturen kannst du benutzerdefinierte Typen erstellen, die in deiner
Domäne eine Bedeutung haben. Durch die Verwendung von Strukturen kannst du
zusammengehörige Datenteile miteinander verbunden halten und jedes Teil
benennen, um deinen Code verständlich zu machen. In `impl`-Blöcken kannst du
Funktionen definieren, die mit deinem Typ assoziiert sind, und Methoden sind
eine Art assoziierte Funktion, mit der du das Verhalten von Instanzen deiner
Strukturen festlegen kannst.

Aber Strukturen sind nicht die einzige Möglichkeit, benutzerdefinierte Typen zu
definieren: Wenden wir uns der Rust-Funktionalität Aufzählung zu, um ein
weiteres Werkzeug in deinen Werkzeugkasten zu legen.

[enums]: ch06-00-enums.html
[modules]: ch07-02-defining-modules-to-control-scope-and-privacy.html
[public]: ch07-03-paths-for-referring-to-an-item-in-the-module-tree.html#pfade-mit-dem-schlüsselwort-pub-öffnen
[trait-objects]: ch17-02-trait-objects.md
