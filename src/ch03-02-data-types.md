## Datentypen

Jeder Wert in Rust ist von einem bestimmten *Datentyp*, der Rust mitteilt,
welche Art von Daten angegeben wird, damit es weiß, wie es mit diesen Daten
arbeiten soll. Wir werden uns zwei Datentyp-Untermengen ansehen: Skalar (scalar) und
Verbund (compound).

Denk daran, dass Rust eine *statisch typisierte* Sprache ist, was bedeutet,
dass es die Typen von allen Variablen zur Kompilierzeit kennen muss. Der
Compiler kann normalerweise auf der Grundlage des Wertes und wie wir ihn
verwenden ableiten, welchen Typ wir verwenden wollen. Wenn mehrere Typen
möglich sind, wie zum Beispiel als wir im Abschnitt [„Vergleichen der Schätzung
mit der Geheimzahl“][comparing-the-guess-to-the-secret-number] eine
Zeichenkette (`String`) mittels `parse` zu einem numerischen Typ umwandelten,
müssen wir eine Typ-Annotation ergänzen, wie hier:

```rust
let guess: u32 = "42".parse().expect("Keine Zahl!");
```

Wenn wir diese Typ-Annotation nicht angeben, zeigt Rust den folgenden Fehler
an, was bedeutet, dass der Compiler mehr Informationen von uns benötigt, um
zu wissen welchen Typ wir verwenden wollen:

```console
$ cargo build
   Compiling no_type_annotations v0.1.0 (file:///projects/no_type_annotations)
error[E0284]: type annotations needed
 --> src/main.rs:2:9
  |
2 |     let guess = "42".parse().expect("Keine Zahl!");
  |         ^^^^^        ----- type must be known at this point
  |
  = note: cannot satisfy `<_ as FromStr>::Err == _`
help: consider giving `guess` an explicit type
  |
2 |     let guess: /* Type */ = "42".parse().expect("Keine Zahl!");
  |              ++++++++++++

For more information about this error, try `rustc --explain E0284`.
error: could not compile `no_type_annotations` (bin "no_type_annotations") due to 1 previous error
```

Für andere Datentypen wirst du andere Typ-Annotationen sehen.

### Skalare Typen

Ein *skalarer* Typ stellt einen einzelnen Wert dar. Rust hat vier primäre
skalare Typen: Ganze Zahlen, Fließkommazahlen, boolesche Werte (Wahrheitswerte)
und Zeichen. Du erkennst diese vielleicht aus anderen Programmiersprachen. Lass
uns darüber sprechen, wie sie in Rust funktionieren.

#### Ganzzahl-Typen

Eine *ganze Zahl* ist eine Zahl ohne Bruchteilkomponente. Wir verwendeten eine
ganze Zahl in Kapitel 2, den Typ `u32`. Diese Typdeklaration gibt an, dass der
Wert, dem sie zugeordnet ist, eine 32 Bit große ganze Zahl ohne Vorzeichen ist
(vorzeichenbehaftete Ganzzahl-Typen beginnen mit `i` anstatt `u`). Tabelle 3-1
zeigt die in Rust eingebauten Ganzzahl-Typen. Wir können jede dieser Varianten
verwenden, um den Typ eines ganzzahligen Wertes zu deklarieren.

<span class="caption">Tabelle 3-1: Ganzzahlige Typen in Rust</span>

| Länge   | Vorzeichenbehaftet  | Vorzeichenlos |
|--------:|---------------------|---------------|
| 8 Bit   | `i8`                | `u8`          |
| 16 Bit  | `i16`               | `u16`         |
| 32 Bit  | `i32`               | `u32`         |
| 64 Bit  | `i64`               | `u64`         |
| 128 Bit | `i128`              | `u128`        |
| arch    | `isize`             | `usize`       |

Jede Variante kann entweder vorzeichenbehaftet oder vorzeichenlos sein und hat
eine explizite Größe. *Vorzeichenbehaftet* (signed) und *vorzeichenlos*
(unsigned) beziehen sich darauf, ob es möglich ist, dass die Zahl negativ ist
&ndash; in anderen Worten, ob die Zahl ein Vorzeichen haben muss
(vorzeichenbehaftet) oder ob sie immer nur positiv sein wird und daher ohne
Vorzeichen dargestellt werden kann (vorzeichenlos). Es ist wie das Schreiben
von Zahlen auf Papier: Wenn das Vorzeichen eine Rolle spielt, wird die Zahl mit
einem Plus- oder Minuszeichen geschrieben; wenn man jedoch davon ausgehen kann,
dass die Zahl positiv ist, wird sie ohne Vorzeichen geschrieben.
Vorzeichenbehaftete Zahlen werden unter Verwendung der
[Zweierkomplementdarstellung][twos-complement] gespeichert.

Jede vorzeichenbehaftete Variante kann Zahlen von -(2<sup>n - 1</sup>) bis
einschließlich 2<sup>n - 1</sup> - 1 speichern, wobei *n* die Anzahl an Bits
ist, die diese Variante benutzt. Ein `i8` kann also Zahlen von -(2<sup>7</sup>)
bis 2<sup>7</sup> - 1 speichern, was -128 bis 127 entspricht. Vorzeichenlose
Varianten können Zahlen von 0 bis 2<sup>n</sup> - 1 speichern, also kann ein
`u8` Zahlen von 0 bis 2<sup>8</sup> - 1 speichern, was 0 bis 255 entspricht.

Zusätzlich hängen die Typen `isize` und `usize` von der Architektur des
Computers ab, auf dem dein Programm läuft, die in der Tabelle als „arch“
bezeichnet wird: 64 Bit wenn du dich auf einer 64-Bit-Architektur befindest und
32 Bit auf einer 32-Bit-Architektur.

Du kannst ganzzahlige Literale in jeder der in Tabelle 3-2 gezeigten Formen
schreiben. Beachte, dass Zahlenliterale, die mehrere numerische Typen sein
können, ein Typ-Suffix wie `57u8` zur Bezeichnung des Typs erlauben.
Zahlenliterale können auch `_` als visuelles Trennzeichen verwenden, um die
Zahl leichter lesbar zu machen, z.B. `1_000`, das den gleichen Wert hat, wie
wenn du `1000` angegeben hättest.

<span class="caption">Tabelle 3-2: Ganzzahl-Literale in Rust</span>

| Ganzahl-Literal  | Beispiel      |
|------------------|---------------|
| Dezimal          | `98_222`      |
| Hex              | `0xff`        |
| Oktal            | `0o77`        |
| Binär            | `0b1111_0000` |
| Byte (nur `u8`)  | `b'A'`        |

Woher weist du also, welcher Ganzzahltyp zu verwenden ist? Wenn du dir unsicher
bist, sind Rusts Standards im Allgemeinen ein guter Ausgangspunkt: Ganzzahlige
Typen sind standardmäßig `i32`. Die primäre Situation, in der du `isize` oder
`usize` verwendest, ist beim Indizieren einer Art Sammlung.

> ##### Ganzzahlüberlauf
>
> Nehmen wir an, du hast eine Variable vom Typ `u8`, die Werte zwischen 0 und
> 255 annehmen kann. Wenn du versuchst, die Variable auf einen Wert außerhalb
> dieses Bereiches zu ändern, z.B. auf 256, tritt ein Ganzzahlüberlauf auf, was
> zu einem von zwei Verhaltensweisen führen kann. Wenn du im Fehlersuchmodus
> (debug mode) kompilierst, fügt Rust Prüfungen auf Ganzzahlüberläufe ein, was
> dazu führt, dass dein Programm zur Laufzeit *abbricht* (panic), falls dieses
> Verhalten auftritt. Rust verwendet den Begriff „panic“, wenn ein Programm
> durch einen Fehler abgebrochen wird; wir werden Programmabbrüche im Abschnitt
> [„Nicht behebbare Fehler mit `panic!`“][unrecoverable-errors-with-panic] in
> Kapitel 9 näher betrachten.
>
> Wenn du mit dem Schalter `--release` im Freigabemodus (release mode)
> kompilierst, fügt Rust *keine* Prüfungen auf Ganzzahlüberläufe, die das
> Programm abbrechen, ein. Wenn ein Überlauf auftritt, führt Rust stattdessen
> einen *Zweier-Komplement-Umbruch* durch. Kurz gesagt, Werte die größer als
> der Maximalwert den der Typ enthalten kann sind, werden umgebrochen zum
> kleinsten Wert den der Typ enthalten kann. Im Falle eines `u8` wird der Wert
> 256 zu 0, der Wert 257 zu 1 und so weiter. Das Programm wird nicht abbrechen,
> aber die Variable wird wahrscheinlich einen anderen Wert annehmen, als du
> erwartest. Sich auf das Verhalten von Ganzzahlüberläufen zu verlassen wird
> als Fehler angesehen.
> 
> Um die Möglichkeit eines Überlaufs explizit zu behandeln, kannst du diese
> Methodenfamilien verwenden, die die Standardbibliothek für primitive
> numerische Typen bereitstellt:
> 
> * Umbrechen (wrap) aller Fälle mit den Methoden `wrapping_*`, z.B.
>   `wrapping_add`
> * Zurückgeben des Wertes `None`, wenn es einen Überlauf mit einer
>   `checked_*`-Methode gibt.
> * Zurückgeben des Wertes und eines booleschen Wertes, der angibt, ob ein
>   Überlauf mit einer `overflowing_*`-Methode stattgefunden hat.
> * Gewährleisten der Minimal- oder Maximalwerte des Wertes mit den
>   `saturating_*`-Methoden.

#### Fließkomma-Typen

Rust hat auch zwei primitive Typen für *Fließkommazahlen*, das sind Zahlen mit
Dezimalkomma. Die Fließkomma-Typen in Rust sind `f32` und `f64`, die 32 Bit
bzw. 64 Bit groß sind. Der Standardtyp ist `f64`, da er auf modernen CPUs
ungefähr die gleiche Geschwindigkeit wie `f32` hat, aber eine höhere Präzision
ermöglicht. Alle Fließkomma-Typen sind vorzeichenbehaftet.

Hier ist ein Beispiel, das Fließkommazahlen in Aktion zeigt:

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let x = 2.0; // f64

    let y: f32 = 3.0; // f32
}
```

Fließkommazahlen werden nach dem IEEE-754-Standard dargestellt.

#### Numerische Operationen

Rust unterstützt grundlegende mathematische Operationen, die man bei allen
Zahlentypen erwartet: Addition, Subtraktion, Multiplikation, Division und
Restberechnung. Die Ganzzahldivision rundet auf die nächste Ganzzahl ab. Der
folgende Code zeigt, wie du die einzelnen Typen in einer `let`-Anweisung
verwenden würdest:

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    // Addition
    let sum = 5 + 10;

    // Subtraktion
    let difference = 95.5 - 4.3;

    // Multiplikation
    let product = 4 * 30;

    // Division
    let quotient = 56.7 / 32.2;
    let truncated = -5 / 3; // Ergibt -1

    // Restberechnung
    let remainder = 43 % 5;
}
```

Jeder Ausdruck in diesen Anweisungen verwendet einen mathematischen Operator
und wird zu einem einzelnen Wert ausgewertet, der dann an eine Variable
gebunden wird. [Anhang B][appendix_b] enthält eine Liste aller Operatoren, die
Rust anbietet.

#### Der boolesche Typ

Wie in den meisten anderen Programmiersprachen hat ein boolescher Typ in Rust
zwei mögliche Werte: `true` (wahr) und `false` (falsch). Boolesche Werte sind
ein Byte groß. In Rust wird der boolesche Typ mit `bool` spezifiziert. Zum
Beispiel:

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let t = true;

    let f: bool = false; // mit expliziter Typ-Annotation
}
```

Hauptsächlich werden boolesche Werte in Bedingungen verwendet, z.B. im
`if`-Ausdruck. Wie `if`-Ausdrücke in Rust funktionieren werden wir im Abschnitt
[„Kontrollfluss“][control-flow] erläutern.

#### Der Zeichen-Typ

Rusts Typ `char` ist der primitivste alphabetische Typ der Sprache. Hier sind
einige Beispiele für die Deklaration von `char`-Werten:

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let c = 'z';
    let z: char = 'ℤ'; // mit expliziter Typannotation
    let heart_eyed_cat = '😻';
}
```

Beachte, dass wir `char`-Literale mit einfachen Anführungszeichen angeben, im
Gegensatz zu Zeichenketten-Literalen, die doppelte Anführungszeichen verwenden.
Der Typ `char` von Rust ist vier Bytes groß und stellt einen Unicode-Skalarwert
dar, was bedeutet, dass er viel mehr als nur ASCII darstellen kann.
Akzentuierte Buchstaben, chinesische, japanische und koreanische Zeichen, Emoji
und Leerzeichen mit Null-Breite sind gültige `char`-Werte in Rust.
Unicode-Skalarwerte reichen von `U+0000` bis `U+D7FF` und von `U+E000` bis
einschließlich `U+10FFFF`. Ein „Zeichen“ ist jedoch nicht wirklich ein Konzept
in Unicode, deine menschliche Intuition dafür, was ein „Zeichen“ ist, stimmt
möglicherweise nicht mit dem überein, was ein `char` in Rust ist. Wir werden
dieses Thema in [„UTF-8-kodierten Text in Zeichenketten (strings)
ablegen“][strings] in Kapitel 8 im Detail besprechen.

### Verbund-Typen

*Verbund-Typen* (compound types) können mehrere Werte zu einem Typ gruppieren.
Rust hat zwei primitive Verbund-Typen: Tupel (tuples) und Arrays (arrays).

#### Der Tupel-Typ

Ein *Tupel* ist eine allgemeine Möglichkeit, eine Reihe von Werten mit einer
Vielzahl von Typen zu einem Verbund-Typ zusammenzufassen. Tupel haben eine
feste Länge: Einmal deklariert, können sie weder wachsen noch schrumpfen.

Wir erzeugen ein Tupel, indem wir eine durch Kommata getrennte Liste von Werten
innerhalb von Klammern schreiben. Jede Position im Tupel hat einen Typ und die
Typen der verschiedenen Werte im Tupel müssen nicht gleich sein. In diesem
Beispiel haben wir optionale Typ-Annotationen angegeben:

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let tup: (i32, f64, u8) = (500, 6.4, 1);
}
```

Die Variable `tup` bindet das gesamte Tupel, da ein Tupel als ein einziges
Verbundelement betrachtet wird. Um die einzelnen Werte aus einem Tupel
herauszubekommen, können wir den Musterabgleich verwenden, um einen Tupelwert
zu destrukturieren, etwa so:

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let tup = (500, 6.4, 1);

    let (x, y, z) = tup;

    println!("Der Wert von y ist: {y}");
}
```

Dieses Programm erzeugt zunächst ein Tupel und bindet es an die Variable `tup`.
Dann benutzt es ein Muster mit `let`, um `tup` zu nehmen und in drei separate
Variablen `x`, `y` und `z` umzuwandeln. Dies nennt man *destrukturieren*
(destructuring), weil es das einzelne Tupel in drei Teile zerlegt. Schließlich
gibt das Programm den Wert von `y` aus, der `6.4` ist.

Wir können direkt auf ein Tupelelement zugreifen, indem wir einen Punkt (`.`)
gefolgt vom Index des Wertes, auf den wir zugreifen wollen, verwenden. Zum
Beispiel:

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let x: (i32, f64, u8) = (500, 6.4, 1);

    let five_hundred = x.0;

    let six_point_four = x.1;

    let one = x.2;
}
```

Dieses Programm erstellt das Tupel `x` und greift dann auf jedes Element des
Tupels über die jeweiligen Indizes zu. Wie bei den meisten Programmiersprachen
ist der erste Index in einem Tupel 0.

Das Tupel ohne Werte hat einen speziellen Namen: *Einheitswert* (unit value).
Dieser Wert und der zugehörige Typ (*Einheitstyp* (unit type)) werden beide mit
`()` geschrieben und stellen einen leeren Wert oder einen leeren Rückgabetyp
dar. Ausdrücke geben implizit den Einheitswert zurück, wenn sie keinen anderen
Wert zurückgeben.

#### Der Array-Typ

Eine andere Möglichkeit, eine Kollektion mit mehreren Werten zu haben, ist mit
einem *Array*. Im Gegensatz zu einem Tupel muss jedes Element eines Arrays den
gleichen Typ haben. Anders als Arrays in einigen anderen Sprachen haben Arrays
in Rust eine feste Länge.

Wir schreiben die Werte in einem Array als kommagetrennte Liste in eckigen
Klammern:

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let a = [1, 2, 3, 4, 5];
}
```

Arrays sind nützlich, wenn du deine Daten eher auf dem Stapelspeicher als im
Haldenspeicher abgelegt haben möchtest, wie bei den anderen Typen, die wir
bisher gesehen haben, (auf den Stapelspeicher und den Haldenspeicher gehen wir
in [Kapitel 4][stack-and-heap] näher ein) oder wenn du sicherstellen willst,
dass du immer eine feste Anzahl von Elementen hast. Ein Array ist jedoch nicht
so flexibel wie der Vektortyp. Ein *Vektor* ist ein ähnlicher Kollektionstyp,
der von der Standardbibliothek zur Verfügung gestellt wird und der in seiner
Größe wachsen oder schrumpfen kann. Wenn du dir nicht sicher bist, ob du ein
Array oder einen Vektor verwenden sollst, ist es wahrscheinlich, dass du einen
Vektor verwenden solltest. In [Kapitel 8][vectors] werden Vektoren
ausführlicher besprochen.

Arrays sind jedoch hilfreicher, wenn du weißt, dass sich die Anzahl der
Elemente nicht ändern wird. Wenn du z.B. die Monatsnamen in einem Programm
verwendest, würdest du wahrscheinlich eher ein Array als einen Vektor
verwenden, weil du weißt, dass es immer 12 Elemente enthalten wird:

```rust
let months = ["Januar", "Februar", "März", "April", "Mai", "Juni", "Juli",
              "August", "September", "Oktober", "November", "Dezember"];
```

Der Typ eines Arrays wird in eckigen Klammern mit dem Typ der einzelnen
Elemente angegeben, ein Semikolon und dann die Anzahl der Elemente im Array,
etwa so:

```rust
let a: [i32; 5] = [1, 2, 3, 4, 5];
```

Hier ist `i32` der Typ aller Elemente. Nach dem Semikolon gibt die Zahl `5` an,
dass das Array fünf Elemente enthält.

Du kannst ein Array auch so initialisieren, dass es für jedes Element denselben
Wert enthält, indem du den Anfangswert, gefolgt von einem Semikolon, und dann
die Länge des Arrays in eckigen Klammern angibst, wie hier gezeigt:

```rust
let a = [3; 5];
```

Das Array mit dem Namen `a` wird `5` Elemente enthalten, die alle anfänglich
auf den Wert `3` gesetzt werden. Dies ist dasselbe wie das Schreiben von
`let a = [3, 3, 3, 3, 3];`, aber in einer prägnanteren Weise.

##### Zugriff auf Array-Elemente

Ein Array ist ein einzelner Speicherbereich mit einer bekannten, festen Größe,
der auf den Stapelspeicher gelegt wird. Du kannst auf Elemente eines Arrays mit
Hilfe der Indizierung wie folgt zugreifen:

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let a = [1, 2, 3, 4, 5];

    let first = a[0];
    let second = a[1];
}
```

In diesem Beispiel erhält die Variable mit dem Namen `first` den Wert `1`, weil
das der Wert am Index `[0]` im Array ist. Die Variable mit dem Namen `second`
wird den Wert `2` vom Index `[1]` im Array erhalten.

##### Ungültiger Array-Element-Zugriff

Sehen wir uns an was passiert, wenn du versuchst, auf ein Element eines Arrays
zuzugreifen, das sich hinter dem Ende des Arrays befindet. Angenommen, du
führst diesen Code aus, ähnlich zum Ratespiel in Kapitel 2, um einen
Array-Index vom Benutzer zu erhalten:

<span class="filename">Dateiname: src/main.rs</span>

```rust,panics
use std::io;

fn main() {
    let a = [1, 2, 3, 4, 5];

    println!("Bitte gib einen Array-Index ein.");

    let mut index = String::new();

    io::stdin()
        .read_line(&mut index)
        .expect("Fehler beim Lesen der Zeile");

    let index: usize = index
        .trim()
        .parse()
        .expect("Eingegebener Index war keine Zahl");

    let element = a[index];

    println!(
        "Der Wert von element beim Index {index} ist: {element}");
}
```

Dieser Code kompiliert erfolgreich. Wenn du diesen Code mit `cargo run`
ausführst und `0`, `1`, `2`, `3` oder `4` eingibst, wird das Programm den
entsprechenden Wert an diesem Index im Array ausgeben. Wenn du stattdessen eine
Zahl hinter dem Ende des Arrays eingibst, z.B. `10`, erhältst du eine Ausgabe
wie diese:

```text
thread 'main' panicked at src/main.rs:19:19:
index out of bounds: the len is 5 but the index is 10
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
```

Das Programm führte zu einem *Laufzeitfehler* an der Stelle, an der ein
ungültiger Wert in der Index-Operation verwendet wurde. Das Programm wurde mit
einer Fehlermeldung beendet und hat die abschließende `println!`-Anweisung
nicht ausgeführt. Wenn du versuchst, mit Hilfe der Indizierung auf ein Element
zuzugreifen, prüft Rust, ob der angegebene Index kleiner als die Array-Länge
ist. Wenn der Index größer oder gleich der Länge ist, wird Rust das Programm
abbrechen. Diese Prüfung muss zur Laufzeit erfolgen, insbesondere in diesem
Fall, weil der Compiler unmöglich wissen kann, welchen Wert ein Benutzer später
eingeben wird, wenn er den Code ausführt.

Dies ist ein Beispiel für die Umsetzung der Speichersicherheitsprinzipien von
Rust. In vielen Low-Level-Sprachen wird diese Art der Überprüfung nicht
durchgeführt und wenn du einen falschen Index angibst, kann auf ungültigen
Speicher zugegriffen werden. Rust schützt dich vor dieser Art von Fehlern,
indem es das Programm sofort beendet, anstatt den Speicherzugriff zuzulassen
und fortzusetzen. Kapitel 9 behandelt die Fehlerbehandlung in Rust und wie du
lesbaren, sicheren Code schreiben kannst, der weder abstürzt noch ungültige
Speicherzugriffe zulässt.

[appendix_b]: appendix-02-operators.html
[comparing-the-guess-to-the-secret-number]:
ch02-00-guessing-game-tutorial.html#vergleichen-der-schätzung-mit-der-geheimzahl
[control-flow]: ch03-05-control-flow.html
[stack-and-heap]: ch04-01-what-is-ownership.html#stapelspeicher-stack-und-haldenspeicher-heap
[strings]: ch08-02-strings.html
[twos-complement]: https://de.wikipedia.org/wiki/Zweierkomplement
[unrecoverable-errors-with-panic]: ch09-01-unrecoverable-errors-with-panic.html
[vectors]: ch08-01-vectors.html
