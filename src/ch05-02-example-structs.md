## Beispielprogramm mit Strukturen (structs)

Um besser zu verstehen, wann wir Strukturen verwenden können, schreiben wir ein
Programm, das die Fläche eines Rechtecks berechnet. Wir beginnen mit einzelnen
Variablen und schreiben das Programm dann um, bis wir stattdessen Strukturen
einsetzen.

Legen wir mit Cargo ein neues Binärprojekt namens *rectangles* an, das die
Breite und Höhe eines in Pixeln angegebenen Rechtecks nimmt und die Fläche des
Rechtecks berechnet.

Codeblock 5-8 zeigt ein kurzes Programm, das genau das in *src/main.rs* unseres
Projekts macht.

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let width1 = 30;
    let height1 = 50;

    println!(
        "Die Fläche des Rechtecks ist {} Quadratpixel.",
        area(width1, height1)
    );
}

fn area(width: u32, height: u32) -> u32 {
    width * height
}
```

<span class="caption">Codeblock 5-8: Berechnen der Fläche eines Rechtecks, das
durch separate Breiten- und Höhenvariablen beschrieben wird</span>

Nun führe dieses Programm mit `cargo run` aus:

```console
$ cargo run
   Compiling structs v0.1.0 (file:///projects/structs)
    Finished dev [unoptimized + debuginfo] target(s) in 0.42s
     Running `target/debug/structs`
Die Fläche des Rechtecks ist 1500 Quadratpixel.
```

Auch wenn Codeblock 5-8 funktioniert und die Fläche des Rechtecks durch
Aufrufen der Funktion `area` mit jeder Dimension herausfindet, können wir es
besser machen. Breite und Höhe hängen zusammen, sie beschreiben zusammen ein
Rechteck.

Das Problem dieses Codes wird bei der Signatur von `area` deutlich:

```rust
# fn main() {
#     let width1 = 30;
#     let height1 = 50;
#
#     println!(
#         "Die Fläche des Rechtecks ist {} Quadratpixel.",
#         area(width1, height1)
#     );
# }
#
fn area(width: u32, height: u32) -> u32 {
#     width * height
# }
```

Die Funktion `area` soll die Fläche eines Rechtecks berechnen, aber die von uns
geschriebene Funktion hat zwei Parameter. Dass die Parameter zusammenhängen,
wird aber nirgendwo in unserem Programm ausgedrückt. Es wäre besser lesbar und
überschaubarer, Breite und Höhe zusammenzufassen. Eine Möglichkeit dazu haben
wir bereits im Abschnitt [„Der Tupel-Typ“][the-tuple-type] in Kapitel 3
vorgestellt: Der Einsatz von Tupeln.

### Refaktorierung mit Tupeln

Codeblock 5-9 zeigt eine weitere Version unseres Programms, die Tupel
verwendet.

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let rect1 = (30, 50);

    println!(
        "Die Fläche des Rechtecks ist {} Quadratpixel.",
        area(rect1)
    );
}

fn area(dimensions: (u32, u32)) -> u32 {
    dimensions.0 * dimensions.1
}
```

<span class="caption">Codeblock 5-9: Breite und Höhe des Rechtecks werden mit
einem Tupel beschrieben</span>

In einem Punkt ist dieses Programm besser. Das Tupel bringt etwas Struktur
hinein und wir geben jetzt nur noch ein Argument weiter. Andererseits ist
dieser Ansatz weniger deutlich: Tupel benennen ihre Elemente nicht, so dass
unsere Berechnung noch unübersichtlicher geworden ist, weil wir die Teile des
Tupels indizieren müssen.

Es spielt zwar keine Rolle, wenn wir bei der Flächenberechnung Breite und Höhe
verwechseln, aber wenn wir das Rechteck auf dem Bildschirm zeichnen wollten,
würde es eine Rolle spielen! Wir müssten berücksichtigen, dass `width` den
Tupelindex `0` und `height` den Tupelindex `1` hat. Wenn eine andere Person an
diesem Code arbeiten würde, müsste er das herausfinden und sich das ebenfalls
merken. Es wäre leicht, diese Werte zu vergessen oder zu verwechseln und Fehler
zu verursachen, weil wir die Bedeutung unserer Daten in unserem Code nicht
hinterlegt haben.

### Refaktorierung mit Strukturen: Mehr Semantik

Verwenden wir Strukturen, um durch die Benennung der Daten deren Bedeutung
anzugeben. Wir können das verwendete Tupel in einen Datentyp mit einem Namen
für das Ganze sowie mit Namen für die Einzelteile umwandeln, wie in Codeblock
5-10 gezeigt.

<span class="filename">Dateiname: src/main.rs</span>

```rust
struct Rectangle {
    width: u32,
    height: u32,
}

fn main() {
    let rect1 = Rectangle {
        width: 30,
        height: 50,
    };

    println!(
        "Die Fläche des Rechtecks ist {} Quadratpixel.",
        area(&rect1)
    );
}

fn area(rectangle: &Rectangle) -> u32 {
    rectangle.width * rectangle.height
}
```

<span class="caption">Codeblock 5-10: Definieren der Struktur `Rectangle`</span>

Hier haben wir eine Struktur definiert und sie `Rectangle` genannt. Innerhalb
der geschweiften Klammern haben wir die Felder `width` und `height` definiert,
die beide den Typ `u32` haben. Dann erzeugten wir in `main` eine Instanz von
`Rectangle` mit der Breite 30 und Höhe 50.

Unsere Funktion `area` hat nun einen Parameter, den wir `rectangle` genannt
haben und dessen Typ eine unveränderliche Ausleihe (immutable borrow) einer
Strukturinstanz `Rectangle` ist. Wie in Kapitel 4 erwähnt, wollen wir die
Struktur nur ausleihen, nicht aber deren Eigentümerschaft (ownership)
übernehmen. Auf diese Weise behält `main` seine Eigentümerschaft und kann
weiterhin `rect1` verwenden, weshalb wir `&` in der Funktionssignatur und an
der Aufrufstelle verwenden.

Die Funktion `area` greift auf die Felder `width` und `height` der Instanz
`Rectangle` zu. Unsere Funktionssignatur für `area` sagt jetzt genau was wir
meinen: Berechne die Fläche von `Rectangle` unter Verwendung seiner Felder
`width` und `height`. Dies drückt aus, dass Breite und Höhe in Beziehung
zueinander stehen, und gibt den Werten beschreibende Namen, ohne die
Tupelindexwerte `0` und `1` zu verwenden. Das erhöht die Lesbarkeit.

### Hilfreiche Funktionalität mit abgeleiteten Merkmalen (derived traits)

Es wäre schön, eine Instanz von `Rectangle` samt der Werte seiner Felder
ausgeben zu können, während wir unser Programm debuggen. In Codeblock 5-11
versuchen wir das Makro `println!` zu verwenden, das wir in den vorangegangenen
Kapiteln verwendet haben. Dies wird jedoch nicht funktionieren.

<span class="filename">Dateiname: src/main.rs</span>

```rust,does_not_compile
struct Rectangle {
    width: u32,
    height: u32,
}

fn main() {
    let rect1 = Rectangle {
        width: 30,
        height: 50,
    };

    println!("rect1 ist {}", rect1);
}
```

<span class="caption">Codeblock 5-11: Versuch, eine `Rectangle`-Instanz
auszugeben</span>

Wenn wir diesen Code kompilieren, erhalten wir folgende Fehlermeldung:

```text
error[E0277]: `Rectangle` doesn't implement `std::fmt::Display`
```
Das Makro `println!` kann diverse Formatierungen vornehmen. Die geschweiften
Klammern weisen `println!` an, die Formatierung `Display` zu verwenden, bei der
die Ausgabe direkt für den Endbenutzer bestimmt ist. Die primitiven Typen, die
wir bisher gesehen haben, implementieren `Display` standardmäßig, denn es gibt
nur eine Möglichkeit, dem Benutzer eine `1` oder einen anderen primitiven Typ
zu zeigen. Aber bei Strukturen ist die Formatierung, die `println!` verwenden
soll, weniger klar, da es mehrere Darstellungsmöglichkeiten gibt: Möchtest du
Kommas oder nicht? Möchtest du die geschweiften Klammern ausgeben? Sollen alle
Felder angezeigt werden? Aufgrund der vielen Möglichkeiten versucht Rust nicht
zu erraten, was wir wollen. Strukturen haben daher keine
Standardimplementierung von `Display`.

Wenn wir die Fehlerausgabe weiterlesen, werden wir diesen hilfreichen Hinweis
finden:

```text
   = help: the trait `std::fmt::Display` is not implemented for `Rectangle`
   = note: in format strings you may be able to use `{:?}` (or {:#?} for pretty-print) instead
```

Lass es uns versuchen! Der Makroaufruf `println!` wird geändert in
`println!("rect1 ist {:?}", rect1);`. Wenn wir das Symbol `:?` innerhalb der
geschweiften Klammern angeben, teilen wir `println!` mit, dass wir das
Ausgabeformat `Debug` verwenden wollen. Das Merkmal `Debug` ermöglicht es, die
Struktur so auszugeben, dass Entwickler ihren Wert erkennen können, während sie
den Code debuggen.

Kompiliere den Code mit dieser Änderung. Verflixt! Wir erhalten immer noch
einen Fehler:

```text
error[E0277]: `Rectangle` doesn't implement `Debug`
```

Aber auch hier gibt uns der Compiler einen hilfreichen Hinweis:

```text
   = help: the trait `std::fmt::Debug` is not implemented for `Rectangle`
   = note: add `#[derive(Debug)]` or manually implement `std::fmt::Debug`
```

Rust enthält durchaus eine Funktionalität zum Ausgeben von Debug-Informationen,
aber wir müssen diese explizit für unsere Struktur aktivieren. Dazu fügen wir
die Annotation `#[derive(Debug)]` unmittelbar vor der Strukturdefinition ein,
wie in Codeblock 5-12 gezeigt.

<span class="filename">Dateiname: src/main.rs</span>

```rust
#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32,
}

fn main() {
    let rect1 = Rectangle {
        width: 30,
        height: 50,
    };

    println!("rect1 ist {:?}", rect1);
}
```

<span class="caption">Codeblock 5-12: Annotation zum Verwenden des Merkmals
`Debug` und Ausgeben der Instanz `Rectangle` mittels Debug-Formatierung</span>

Wenn wir das Programm nun ausführen, werden wir keinen Fehler mehr erhalten und
folgende Ausgabe sehen:

```console
$ cargo run
   Compiling structs v0.1.0 (file:///projects/structs)
    Finished dev [unoptimized + debuginfo] target(s) in 0.48s
     Running `target/debug/structs`
rect1 ist Rectangle { width: 30, height: 50 }
```

Toll! Es ist nicht die schönste Ausgabe, aber sie zeigt die Werte aller Felder
dieser Instanz, was bei der Fehlersuche definitiv hilfreich ist. Bei größeren
Strukturen ist es hilfreich eine Ausgabe zu haben, die etwas leichter zu lesen
ist. In diesen Fällen können wir `{:#?}` anstelle von `{:?}` in der
`println!`-Meldung verwenden. Die Ausgabe sieht dann wie folgt aus:

```console
$ cargo run
   Compiling structs v0.1.0 (file:///projects/structs)
    Finished dev [unoptimized + debuginfo] target(s) in 0.48s
     Running `target/debug/structs`
rect1 ist Rectangle {
    width: 30,
    height: 50,
}
```

Rust stellt uns eine Reihe von Merkmalen zur Verfügung, die wir mit der
Annotation `derive` verwenden können, um damit unseren benutzerdefinierten
Typen nützliches Verhalten zu verleihen. Diese Merkmale und ihr Verhalten sind
in Anhang C aufgeführt. In Kapitel 10 werden wir behandeln, wie man diese
Merkmale mit benutzerdefiniertem Verhalten implementiert und wie man eigene
Merkmale erstellt.

Unsere Funktion `area` ist sehr spezifisch: Sie berechnet nur die Fläche von
Rechtecken. Es wäre hilfreich, dieses Verhalten enger mit unserer Struktur
`Rectangle` zu verbinden, da es zu keinem anderen Typ passt. Schauen wir uns
an, wie wir den Code weiter umgestalten und unsere Funktion `area` in eine
*Methode* `area` unseres Typs `Rectangle` verwandeln können.

[the-tuple-type]: ch03-02-data-types.html#der-tupel-typ
