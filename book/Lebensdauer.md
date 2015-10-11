# Lebensdauer

Dieser Guide ist einer von dreien, der Rusts Ownership-System.
präsentiert. Dies ist eines von Rusts einzigartigen und verlockenden
Features mit denen Rust Entwickler vertraut sein sollten.
Durch Ownership [engl.: Besitz] erreicht Rust sein größtes Ziel,
die Speichersicherheit.
Es gibt ein paar verschiedene Konzepte, jedes mit seinem eigenen Kapitel:

* [Besitz][ownership], das Schlüsselkonzept.
* [Ausleihen][borrowing], und das assozierte Feature ‘Referenzen’
* Lebensdauer, das was du gerade liest.

Diese drei Kapitel sind verwandt und deswegen in dieser Reihenfolge zu lesen.
Du wirst alle drei benötigen um das Ownership-System vollständig zu verstehen.

[ownership]: Besitz.md
[borrowing]: Referenzen_Und_Ausleihen.md

# Meta

Bevor wir in die Details gehen gibt es zwei wichtige Hinweise über das
Ownership-System.

Rust hat einen Fokus auf Sicherheit und Geschwindigkeit.
Es erfüllt diese Ziele durch viele "kostenfreie Abstraktionen"
[‘zero-cost abstractions’], was bedeutet, dass in Rust die Kosten so niedrig
wie möglich sind um diese Abstraktionen funktionieren zu lassen.
Jegliche Analyse über die wie in diesem Guide sprechen wird
_zur Kompilierzeit_ ausgeführt. Du zahlst für diese Features
keine Extrakosten zur Laufzeit.

Jedoch hat dieses System einen gewissen Preis: Die Lernkurve.
Viele neue Rust Nutzer erleben etwas,
was wir "mit dem *borrow checker* kämpfen" nennen,
wobei dann Rust verweigert ein Programm zu kompilieren
bei dem der Author denkt, dass es korrekt ist.
Das passiert häufig, da das mentale Modell des Programmierers von Ownership
nicht den eigentlichen Regeln entspricht, die Rust implementiert.
Du wirst wahrscheinlich zuerst etwas ähnliches erleben.
Die guten Nachricht ist aber:
Erfahrenere Rust Entwickler berichten, dass, sobald sie eine Zeit
mit den Regeln des Ownership-Systems gearbeitet haben, sie immer weniger
mit dem *borrow checker* kämpfen müssen. 

Mit diesem Wissen, lass uns über Lebensdauer lernen.

# Lebensdauer

Eine Referenz auf eine Ressource, die jemand anderes besitzt, auszuleihen
kann kompliziert sein. Stell dir zum Beispiel diese Folge von
Vorgängen vor:

- Ich erhalte ein Handle für irgendeine Ressource.
- Ich leihe dir eine Referenz zu dieser Ressource.
- Ich entscheide mich, dass ich die Ressource nicht mehr brauch und
  gebe sie frei, während du immernoch deine Referenz hast.
- Du entscheidest dich die Ressource zu verwenden.

Oh-oh! Deine Referenz zeigt auf eine ungültige Ressource.
Dies wird "baumelnder Zeiger" oder "use after free" genannt.

Um das zu beheben müssen wir sicherstellen, dass Schritt Drei nie nach
Schritt Vier passiert. Das Ownership-System in Rust macht dies durch ein
Konzept namens Lebensdauer [lifetimes], welches den Scope beschreibt
für den eine Referenz gültig ist.

Wenn wir eine Funktion haben, die eine Referenz als Argument nimmt,
dann ist die Lebenszeit dieser Referenz entweder implizit oder explizit:

```rust
// implicit
fn foo(x: &i32) {
}

// explicit
fn bar<'a>(x: &'a i32) {
}
```

Das `'a` wird als "die Lebenszeit a" gelesen. Technisch gesehen hat jedee
Referenz eine zugehörige Lebenszeit, aber der Compiler erlaubt es diese in
üblichen Fällen wegzulassen.
Bevor wir jedoch darauf eingehen gehen wir noch das explizite Beispiel durch:

```rust
fn bar<'a>(...)
```

Dieser Teil deklariert unsere Lebenszeit. Er besagt, dass `bar` eine Lebenszeit
namens `'a` hat. Hätten wir zwei Referenz, dann würde das so aussehen:

```rust
fn bar<'a, 'b>(...)
```

I unserer Parameterlist benutzen wir dann die benannten Lebenszeiten:

```rust
...(x: &'a i32)
```

Wenn wir eine `&mut` Referenz haben wollten,
dann würden wir folgendes schreiben:

```rust
...(x: &'a mut i32)
```

Wenn du `&mut i32` und `&'a mut i32` miteinander vergleichst,
dann siehst du, dass sie eigentlich identisch sind, bis auf den Unterschied,
dass sich ein `'a` zwischen dem `&` und dem `mut i32` eingeschlichen hat.
Wir lesen `&mut i32` als "eine veränderbare Referenz auf ein i32" und
`&'a mut i32` als "eine veränderbare Referenz auf ein i32
mit der Lebenszeit `'a`".

# In `struct`s

Du wirst auch explizite Lebenszeiten brauchen,
wenn du mit [`struct`][structs]s arbeitest:

```rust
struct Foo<'a> {
    x: &'a i32,
}

fn main() {
    let y = &5; // this is the same as `let _y = 5; let y = &_y;`
    let f = Foo { x: y };

    println!("{}", f.x);
}
```

[structs]: Structs.md

Wie du sehen kannst können `struct`s auch Lebenszeiten haben.
Auf eine ähnliche Art und Weise wie Funktionen deklariert

```rust
struct Foo<'a> {
```

eine Lebenszeit und

```rust
x: &'a i32,
```

benutzt sie. Also warum brauchen wir eine Lebenszeit hier?
Wir müssen sicherstellen, dass keine Referenz auf `Foo` länger lebt,
als die enthaltene Referenz auf das `i32`.

## `impl` Blöcke

Lass uns eine Methode auf dem Typen `Foo` implementieren:

```rust
struct Foo<'a> {
    x: &'a i32,
}

impl<'a> Foo<'a> {
    fn x(&self) -> &'a i32 { self.x }
}

fn main() {
    let y = &5; // this is the same as `let _y = 5; let y = &_y;`
    let f = Foo { x: y };

    println!("x is: {}", f.x());
}
```

Wie du sehen kannst müssen wir eine Lebensdauer für `Foo` in der `impl` Zeile
deklarieren. Wir wiederholen `'a` zweimal, genau wie bei Funktionen: `impl<'a>`
deklariert eine Lebensdauer `'a` und `Foo<'a>` benutzt sie.

## Mehr als eine Lebensdauer

Wenn du mehrere Referenzen hast, dann kannst du die gleiche Lebensdauer mehrmals
verwenden:

```rust
fn x_or_y<'a>(x: &'a str, y: &'a str) -> &'a str {
```

Dieser code besagt, dass `x`, `y` und
der Rückgabewert die gleiche Lebenszeit haben.
Wenn du wolltest, dass `x` und `y` verschiedene Lebenszeiten haben,
dann kannst du mehrere Lebenszeit-Parameter verwenden:

```rust
fn x_or_y<'a, 'b>(x: &'a str, y: &'b str) -> &'a str {
```

In diesem Beispiel haben `x` und `y` also verschiedene gültige Scopes,
aber der Rückgabewert hat dieselbe Lebenszeit wie `x`.

## In Scopes denken

Ein Weg über Lebenszeiten zu nachzudenken ist den Scope, indem eine Referenz
gültig ist, zu visualisieren. Zum Beispiel:

```rust
fn main() {
    let y = &5;     // -+ y goes into scope
                    //  |
    // stuff        //  |
                    //  |
}                   // -+ y goes out of scope
```

Mit unserem `Foo` hinzugefügt:

```rust
struct Foo<'a> {
    x: &'a i32,
}

fn main() {
    let y = &5;           // -+ y goes into scope
    let f = Foo { x: y }; // -+ f goes into scope
    // stuff              //  |
                          //  |
}                         // -+ f and y go out of scope
```

Unser `f` lebt im Scope von `y`, also funktioniert alles.
Aber was wenn nicht? Dieser Code Funktioniert nicht:

```rust
struct Foo<'a> {
    x: &'a i32,
}

fn main() {
    let x;                    // -+ x goes into scope
                              //  |
    {                         //  |
        let y = &5;           // ---+ y goes into scope
        let f = Foo { x: y }; // ---+ f goes into scope
        x = &f.x;             //  | | error here
    }                         // ---+ f and y go out of scope
                              //  |
    println!("{}", x);        //  |
}                             // -+ x goes out of scope
```

Uff! Wie du hier siehst ist der Scope von `f` und `y` kleiner als der von `x`.
Aber wenn wir `x = &f.x` ausführen, erzeugen wir eine Referenz auf etwas, was
kurz davor steht den Scope zu verlassen.

## 'static

Die Lebenszeit namens ‘static’ ist eine besondere Lebenszeit. Sie signalisiert,
dass etwas dieselbe Lebenszeit wie das ganze Programm hat.
Die meisten Rust Programmierer treffen das erste mal auf `'static`,
wenn sie mit Strings arbeiten:

```rust
let x: &'static str = "Hello, world.";
```

Stringliterale haben den Typ `&'static str`, da die Referenz immer gültig ist:
Sie sind in das Datensegment der Binärdatei integriert.
Ein anderes Beispiel sind *globals* (globale Variablen):

```rust
static FOO: i32 = 5;
let x: &'static i32 = &FOO;
```

Dies fügt dem Datensegment der Binärdatei eine `i32` hinzu und `x` ist eine
Referenz darauf.

## Weglassen von Lebenszeiten

Rust unterstützt mächtige lokale Typinferenz in Funktionskörpern, aber es ist
verboten in Signaturen aus der jeweiligen Signatur allein Sachen abzuleiten.
Es gibt jedoch aus ergonomischen Gründen eine sehr Eingeschränkte Form von
Inferenz namens *lifetime elision* ("Weglassen von Lebenszeiten"), welche
das erlaubt. Sie leitet ausschließlich basierend aus der Signatur einer
Komponente (also nicht dem Körper) etwas ab und zwar nur Lebenszeit-Parameter.
Außerdem geschieht *lifetime elision* gemäß nur drei einfahc zu merkenden und
deutlichen Regeln. Dies erlaubt der *lifetime elision* eine Kurzschreibweise
für Signaturen zu ermöglichen und gleichzeitig nicht die eigentlichen
involvierten Typen zu verstecken, wie es eine vollständig Inferenz machen würde.

Wenn wir über *lifetime elision* reden, dann benutzen wir den Begriff
*input lifetime* und *output lifetime*. Eine *input lifetime* ist eine
Lebenszeit, die mit einem Parameter einer Funktion assoziiert ist,
und eine *output lifetime* ist eine Lebenszeit, die mit dem Rückgabewert einer
Funktion assoziiert ist. Zum Beispiel hat diese Funktion eine *input lifetime*:

```rust
fn foo<'a>(bar: &'a str)
```

Diese hier hat eine *output lifetime*:

```rust
fn foo<'a>() -> &'a str
```

Und diese hier hat eine Lebenszeit in beiden Positionen:

```rust
fn foo<'a>(bar: &'a str) -> &'a str
```

Hier sind die drei Regeln:

* Jede weggelassene Lebenszeit bei den Argumenten einer Funktion bekommt einen
  individuellen Lebenszeit-Paramter.

* Wenn es genau eine *input lifetime* gibt, ob weggelassen oder nicht,
  dann wird diese Lebenszeit aller ausgelassenen Lebenszeiten im Rückgabewert
  der Funktion zugewiesen.

* Wenn es mehrere *input lifetime* gibt und eines der Argumente `&self`,
  `&mut self` oder `self` ist, dann wird die Lebenszeit von `self`
  allen weggelassenen *output lifetimes* zugewiesen.

Andernfalls ist es einen Fehler eine Lebenszeit wegzulassen.

### Beispiele

Hier sind ein paar Beispiel-Funktionen mit weggelassenen Lebenszeiten.
Wir haben jedes Beispiel einer ausgelassenen Lebenszeit mit ihrer
expandierten Form gepaart.

```rust
fn print(s: &str); // elided
fn print<'a>(s: &'a str); // expanded

fn debug(lvl: u32, s: &str); // elided
fn debug<'a>(lvl: u32, s: &'a str); // expanded

// In dem vorangehenden Beispiel benötigt `lvl` keine eigene Lebenszeit,
// da es keine Referenz (`&`) ist. Nur Sachen, die mit Referenzen zu tun haben
// (wie z.B. `struct`s, die Referenzen enthalten) benötigen Lebenszeiten.

fn substr(s: &str, until: u32) -> &str; // elided
fn substr<'a>(s: &'a str, until: u32) -> &'a str; // expanded

fn get_str() -> &str; // ILLEGAL, no inputs

fn frob(s: &str, t: &str) -> &str; // ILLEGAL, two inputs
fn frob<'a, 'b>(s: &'a str, t: &'b str) -> &str; // Expanded: Output lifetime is ambiguous

fn get_mut(&mut self) -> &mut T; // elided
fn get_mut<'a>(&'a mut self) -> &'a mut T; // expanded

fn args<T:ToCStr>(&mut self, args: &[T]) -> &mut Command // elided
fn args<'a, 'b, T:ToCStr>(&'a mut self, args: &'b [T]) -> &'a mut Command // expanded

fn new(buf: &mut [u8]) -> BufWriter; // elided
fn new<'a>(buf: &'a mut [u8]) -> BufWriter<'a> // expanded
```
