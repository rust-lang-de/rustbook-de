## Datentypen

Jeder Wert in Rust ist von einem bestimmten Datentyp, der Rust mitteilt, welche
Art von Daten angegeben wird, damit es weiß, wie es mit diesen Daten arbeiten
soll. Wir werden uns zwei Datentyp-Untermengen ansehen: skalare und
zusammengesetzte.

Denk daran, dass Rust eine *statisch typisierte* Sprache ist, was bedeutet, dass
sie die Typen von allen Variablen zur Kompilierzeit kennen muss. Der Compiler
kann normalerweise auf der Grundlage des Wertes und wie wir ihn verwenden
ableiten, welchen Typ wir verwenden wollen. Wenn mehrere Typen möglich sind, wie
zum Beispiel als wir im Abschnitt [“Comparing the Guess to the Secret
Number”][comparing-the-guess-to-the-secret-number]<!-- ignore --> einen `String`
mittels `parse` zu einem numerischen Typ umwandelten, müssen wir den
Typ-Anmerkung hinzufügen, wie hier:

```rust
let guess: u32 = "42".parse().expect("Keine Zahl!");
```

Wenn wir diese Typ-Anmerkung nicht hinzufügen, zeigt Rust den folgenden Fehler
an, was bedeutet, dass der Compiler mehr Informationen von uns benötigt, um zu
wissen welchen Typ wir verwenden wollen:

```text
{{#include ../listings/ch03-common-programming-concepts/output-only-01-no-type-annotations/output.txt}}
```

Für andere Datentypen wirst du andere Typ-Anmerkungen sehen.

### Skalare-Typen

Ein *Skalar*-Typ stellt einen einzelnen Wert dar. Rust hat vier primäre
Skalartypen: ganze Zahlen, Fließkommazahlen, boolesche Werte (Wahrheitswerte) und Zeichen. Du
erkennst diese vielleicht aus anderen Programmiersprachen. Lass uns darüber
sprechen, wie sie in Rust funktionieren.

#### Ganzzahl-Typen

Eine *ganze Zahl* ist eine Zahl ohne gebrochene Komponente. Wir verwendeten eine
ganze Zahl in Kapitel 2, den `u32` Typ. Diese Typdeklaration gibt an, dass der
Wert, dem sie zugeordnet ist, eine 32 Bit große ganze Zahl ohne Vorzeichen ist
(vorzeichenbehaftete Ganzzahl-Typen beginnen mit `i` anstatt `u`). Tabelle 3-1
zeigt die in Rust eingebauten Ganzzahl-Typen.  Jede Variante in der
vorzeichenbehafteten und vorzeichenlosen Spalte (zum Beispiel `i16`) kann
benutzt werden, um den Typ eines ganzzahligen Wertes zu deklarieren.

<span class="caption">Tabelle 3-1: Ganzzahlige Typen in Rust</span>

| Länge   | Vorzeichenbehaftet  | Vorzeichenlos |
|---------|---------------------|---------------|
| 8-bit   | `i8`                | `u8`          |
| 16-bit  | `i16`               | `u16`         |
| 32-bit  | `i32`               | `u32`         |
| 64-bit  | `i64`               | `u64`         |
| 128-bit | `i128`              | `u128`        |
| arch    | `isize`             | `usize`       |

Jede Variante kann entweder vorzeichenbehaftet oder vorzeichenlos sein und hat
eine explizite Größe. *Vorzeichenbehaftet* und *vorzeichenlos* bezieht sich
darauf, ob es möglich ist, dass die Zahl negativ oder positiv - in anderen
Worten, ob die Zahl ein Vorzeichen haben muss (vorzeichenbehaftet) oder ob sie
immer nur positiv sein wird und daher ohne Vorzeichen dargestellt werden kann
(vorzeichenlos). Es ist wie das Schreiben von Zahlen auf Papier: wenn das
Vorzeichen eine Rolle spielt, wird die Zahl mit einem Plus- oder Minuszeichen
geschrieben; wenn man jedoch davon ausgehen kann, dass die Zahl positiv ist,
wird sie ohne Vorzeichen geschrieben. Vorzeichenbehaftete Zahlen werden unter
Verwendung der [Zweierkomplementdarstellung](https://de.wikipedia.org/wiki/Zweierkomplement) gespeichert

Jede vorzeichenbehaftete Variante kann Zahlen von -(2<sup>n - 1</sup>) bis
einschließlich 2<sup>n - 1</sup> - 1 speichern, wobei *n* die Anzahl an Bits
ist, die diese Variante benutzt. Ein `i8` kann also Zahlen von -(2<sup>7</sup>)
bis 2<sup>7</sup> - 1 speichern, was -128 bis 127 entspricht. Vorzeichenlose
Varianten können Zahlen von 0 bis 2<sup>n</sup> - 1 speichern, also kann ein
`u8` Zahlen von 0 bis 2<sup>8</sup> - 1, speichern, was 0 bis 255 entspricht.

Zusätzlich hängen die Typen `isize` und `usize` von der Art des Computers ab,
auf dem dein Programm läuft: 64 Bit wenn du dich auf einer 64-Bit Architektur
befindest und 32 Bit auf einer 32-Bit Architektur.

Du kannst ganzzahlige Literale in jeder in Tabelle 3-2 gezeigten Form
schreiben. Beachte, dass alle Zahlenliterale mit Ausnahme des Byte-Literals
einen Typ-Suffix erlauben, z.B. `57u8` und `_` als visuelles Trennzeichen, wie
z.B. `1_000`.


<span class="caption">Tabelle 3-2: Ganzzahl-Literale in Rust</span>

| Ganzahl-Literal  | Beispiel       |
|------------------|---------------|
| Dezimal          | `98_222`      |
| Hex              | `0xff`        |
| Oktal            | `0o77`        |
| Binär            | `0b1111_0000` |
| Byte (nur `u8`)  | `b'A'`        |

Woher weist du also, welche Art von Ganzzahl zu verwenden ist? Wenn du dir
unsicher bist, sind Rusts Standards im Allgemeinen eine gute Wahl, und
ganzzahlige Typen sind standardmäßig `i32`: dieser Typ ist im Allgemeinen am
schnellsten, selbst auf 64-Bit Systemen. Die primäre Situation in der du `isize`
oder `usize` benutzen würdest, ist die Indizierung irgendeiner Art von
Kollektion.

> ##### Ganzzahlüberlauf
>
> Nehmen wir an, du hast eine Variable vom Typ `u8`, die Werte zwischen 0 und
> 255 annehmen kann. Wenn du versuchst, die Variable auf einen Wert außerhalb
> dieses Bereiches zu ändern, z.B. auf 256, tritt ein Ganzzahlüberlauf auf. Rust
> hat einige Interessante Regeln, die dieses Verhalten betreffen. Wenn du im
> Debug-Modus kompilierst, fügt Rust eine Prüfungen auf Ganzzahlüberläufe ein,
> was dazu führt, dass dein Programm zur Laufzeit *panisch* wird, falls dieses
> Verhalten auftritt. Rust verwendet den Begriff panisch, wenn ein Programm durch
> einen Fehler beendet wird; wir werden panisch im Abschnitt [“Unrecoverable
> Errors with `panic!`”][unrecoverable-errors-with-panic]<!-- ignore --> in
> Kapitel 9 näher betrachten.
>
> Wenn du mit dem `--release`-Flag im Release-Modus kompilierst, fügt Rust
> *keine* Prüfungen auf Ganzzahlüberläufe, die eine Panik verursachen, ein.
> Stattdessen, wenn ein Überlauf auftritt, führt Rust einen
> *Zweier-Komplement-Umbruch* durch. Kurz gesagt, Werte die größer als der
> Maximalwert den der Typ enthalten kann sind, werden umgebrochen zum kleinsten
> Wert den der Typ enthalten kann. Im Falle eines `u8`, 256 wird 0, 257 wird 1,
> und so weiter. Das Programm wird nicht panisch, aber die Variable wird
> wahrscheinlich einen anderen Wert annehmen, als du erwartest. Sich auf das
> Verhalten von Ganzzahlüberläufen zu verlassen wird als Fehler angesehen. Wenn
> du explizit umbrechen willst, kannst du den Typ [`Wrapping`][wrapping] aus der
> Standardbibliothek verwenden.

#### Fließkomma-Typen

Rust hat auch zwei primitive Typen für *Fließkommazahlen*, das sind Zahlen mit
Dezimalkomma. Die Fließkomma-Typen von Rust sind `f32` und `f64`, die 32 Bit
bzw. 64 Bit groß sind. Der Standardtyp ist `f64`, da er auf modernen CPUs
ungefähr die gleiche Geschwindigkeit wie `f32` hat, aber zu mehr Präzision fähig
ist.

Hier ist ein Beispiel, das Fließkommazahlen in Aktion zeigt:

<span class="filename">Filename: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-06-floating-point/src/main.rs}}
```

Fließkommazahlen werden nach dem IEEE-754-Standard dargestellt. Der Typ `f32`
ist eine Fließkommazahl mit einfacher Genauigkeit, und `f64` hat doppelte Genauigkeit.

#### Numerische Operationen

Rust unterstützt die grundlegenden mathematischen Operationen, die man für alle
Zahlentypen erwartet: Addition, Subtraktion, Multiplikation, Division und
Restberechnung. Der folgende Code zeigt, wie du die einzelnen Typen in einer
`let`-Anweisung verwenden würdest:

<span class="filename">Filename: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-07-numeric-operations/src/main.rs}}
```

Jeder Ausdruck in diesen Anweisungen verwendet einen mathematischen Operator und
wird zu einem einzelnen Wert ausgewertet, der dann an eine Variable gebunden
wird. Anhang B enthält eine Liste aller Operatoren, die Rust anbietet.

#### Der boolesche Type

Wie in den meisten anderen Programmiersprachen hat ein Boolescher Typ in Rust
zwei mögliche Werte: `true` (`wahr`) und `false` (`falsch`). Booleans sind ein
Byte groß. In Rust wird der Boolesche Typ mit `bool` spezifiziert. Zum Beispiel:


<span class="filename">Filename: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-08-boolean/src/main.rs}}
```

Hauptsächlich werden boolesche Werte in Bedingungen verwendet, wie z.B. im
`if`-Ausdruck. Wie `if`-Ausdrücke in Rust funktionieren werden wir im Abschnitt
[“Control Flow”][control-flow]<!-- ignore --> erläutern.

#### Der Zeichen-Typ

Bislang haben wir nur mit Zahlen gearbeitet, aber Rust unterstützt auch
Buchstaben. Rusts `Zeichentyp` ist der primitivste Alphabettyp der Sprache, der
folgende Code zeigt eine Möglichkeit, ihn zu verwenden. (Beachten Sie, dass
`Zeichen`-Literale mit einfachen Anführungszeichen angegeben werden, im
Gegensatz zu Zeichenketten-Literalen, die doppelte Anführungszeichen verwenden).

<span class="filename">Filename: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-09-char/src/main.rs}}
```

Der `Zeichen`-Typ von Rust ist vier Bytes groß und stellt einen Unicode-Skalarwert
dar, was bedeutet, dass er viel mehr als nur ASCII darstellen kann. Akzentuierte
Buchstaben; Chinesische, japanische und koreanische Zeichen, Emoji und
Leerzeichen mit Null-Breite sind gültige `Zeichen`-Werte in Rust.
Unicode-Skalarwerte reichen von `U+0000` bis `U+D7FF` und `U+E000` bis
einschließlich `U+10FFFF`. Ein “Zeichen” ist jedoch nicht wirklich ein Konzept
in Unicode, deine menschliche Intuition dafür, was ein “Zeichen” ist stimmt
möglicherweise nicht mit dem überein, was in Rust ein `Zeichen` ist. Wir werden
dieses Thema in [“Storing UTF-8 Encoded Text with Strings”][strings]<!--
ignorieren --> in Kapitel 8 im Detail diskutieren.


### Verbund-Typen

*Verbund-Typen* können mehrere Werte zu einem Typ gruppieren. Rust hat zwei
primitive Verbund-Typen: Tupel und Arrays.

#### Der Tupel-Type

Ein Tupel ist eine allgemeine Möglichkeit, eine Anzahl von Werten mit einer
Vielzahl von Typen zu einem Verbund-Typ zusammenzufassen. Tupel haben
eine feste Länge: einmal deklariert, können sie weder wachsen noch schrumpfen.


Wir erzeugen ein Tupel, indem wir eine durch Kommata getrennte Liste von Werten
innerhalb von Klammern schreiben. Jede Position in dem Tupel hat einen Typ und
die Typen der verschiedenen Werte in dem Tupel müssen nicht gleich sein. In
diesem Beispiel haben wir optionale Typ-Anmerkungen hinzugefügt:

<span class="filename">Filename: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-10-tuples/src/main.rs}}
```

Die Variable `tup` bindet das gesamte Tupel, da ein Tupel als ein einziges
Verbundelement betrachtet wird. Um die einzelnen Werte aus einem Tupel
herauszubekommen, können wir den Musterabgleich verwenden, um einen Tupelwert
zu destrukturieren, etwa so

<span class="filename">Filename: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-11-destructuring-tuples/src/main.rs}}
```

Dieses Programm erzeugt zunächst ein Tupel und bindet es an die Variable `tup`.
Dann benutzt es ein Muster mit `let`, um `tup` zu nehmen und es in drei separate
Variablen, `x`, `y` und `z`, umzuwandeln. Dies nennt man *destrukturieren*,
weil es das einzelne Tupel in drei Teile zerlegt. Schließlich gibt das Programm
den Wert von `y` aus, der `6.4` ist.

Zusätzlich zur Destrukturierung durch Musterabgleiche können wir direkt auf ein
Tupelelement zugreifen, indem wir einen Punkt (`.`) gefolgt von dem Index des
Wertes, auf den wir zugreifen wollen, verwenden. Zum Beispiel:

<span class="filename">Filename: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-12-tuple-indexing/src/main.rs}}
```

Dieses Programm erzeugt ein Tupel, `x`, und erstellt dann neue Variablen für
jedes Element, indem es ihre jeweiligen Indizes verwendet. Wie bei den meisten
Programmiersprachen ist der erste Index in einem Tupel 0.

#### Der Array-Type

Eine andere Möglichkeit, eine Sammlung von mehreren Werten zu haben, ist mit
einem *Array*. Im Gegensatz zu einem Tupel muss jedes Element eines Arrays den
gleichen Typ haben. Arrays in Rust unterscheiden sich von Arrays in einigen
anderen Sprachen, weil Arrays in Rust eine feste Länge haben, wie Tupel.

In Rust werden die in ein Array eingehenden Werte als kommagetrennte Liste in
eckige Klammern geschrieben:

<span class="filename">Filename: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-13-arrays/src/main.rs}}
```

Arrays sind nützlich, wenn du deine Daten eher auf dem Stapelspeicher als im
dynamischen Speicher angelegt haben möchtest (auf den Stapelspeicher und den
dynamischen Speicher gehen wir in Kapitel 4 näher ein) oder wenn du
sicherstellen willst, dass du immer eine feste Anzahl von Elementen hast. Ein
Array ist jedoch nicht so flexibel wie der Vektortyp. Ein Vektor ist ein
ähnlicher Kollektion-Typ, der von der Standardbibliothek zur Verfügung gestellt
wird und der in seiner Größe wachsen oder schrumpfen *kann*. Wenn du dir nicht
sicher bist, ob du ein Array oder einen Vektor verwenden sollst, solltest du
wahrscheinlich einen Vektor verwenden. In Kapitel 8 werden Vektoren
ausführlicher besprochen.


Ein Beispiel dafür, wann du ein Array statt eines Vektors verwenden möchtest,
ist in einem Programm, das die Namen der Monate des Jahres kennen muss. Es ist
sehr unwahrscheinlich, dass ein solches Programm Monate hinzufügen oder
entfernen muss, sodass du ein Array verwenden kannst, weil du weist, dass es
immer 12 Elemente enthalten wird:

```rust
let months = ["January", "February", "March", "April", "May", "June", "July",
              "August", "September", "October", "November", "December"];
```

Du würdest den Typ eines Arrays mit eckigen Klammern schreiben und innerhalb der
Klammern den Typ jedes Elements, ein Semikolon und dann die Anzahl der Elemente
im Array angeben, etwa so:

```rust
let a: [i32; 5] = [1, 2, 3, 4, 5];
```

Hier ist `i32` der Typ jedes Elements. Nach dem Semikolon gibt die Zahl `5` an,
dass das Array fünf Elemente enthält.


Das Angeben eines Array-Typs auf diese Weise ähnelt einer alternativen Syntax
für die Initialisierung eines Arrays: Wenn du ein Array erstellen möchtest, das
für jedes Element den gleichen Wert enthält, kannst du den Anfangswert, gefolgt
von einem Semikolon und dann die Länge des Arrays in eckigen Klammern angeben,
wie hier gezeigt:

```rust
let a = [3; 5];
```

Das Array mit dem Namen `a` wird `5` Elemente enthalten, die alle anfänglich auf
den Wert `3` gesetzt werden. Dies ist dasselbe wie das Schreiben von `let a =
[3, 3, 3, 3, 3, 3];`, aber in einer prägnanteren Weise.

##### Zugriff auf Array-Elemente

Ein Array ist ein einzelnes Stück Speicher, das auf dem Stapelspeicher angelegt
wird. Du kannst auf Elemente eines Arrays mit Hilfe der Indizierung wie folgt
zugreifen:

<span class="filename">Filename: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-14-array-indexing/src/main.rs}}
```

In diesem Beispiel erhält die Variable mit dem Namen `first` den Wert `1`, weil
das der Wert am Index `[0]` im Array ist. Die Variable mit dem Namen `second`
wird den Wert `2` vom Index `[1]` im Array erhalten.

##### Ungültiger Array-Element-Zugriff

Was passiert, wenn du versuchst, auf ein Element eines Arrays zuzugreifen, das
sich hinter dem Ende des Arrays befindet? Angenommen, du änderst das Beispiel in
den folgenden Code, der sich kompilieren lässt, aber mit einem Fehler beendet
wird, wenn er ausgeführt wird:

<span class="filename">Filename: src/main.rs</span>

```rust,ignore,panics
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-15-invalid-array-access/src/main.rs}}
```

Die Ausführung dieses Codes mit `cargo run` ergibt folgendes Ergebnis:

```text
{{#include ../listings/ch03-common-programming-concepts/no-listing-15-invalid-array-access/output.txt}}
```


Die Kompilierung ergab keine Fehler, aber das Programm führte zu einem
*Laufzeitfehler* und wurde nicht erfolgreich beendet. Wenn du versuchst, auf
ein Element über die Indizierung zuzugreifen, wird Rust prüfen, ob der von dir
angegebene Index kleiner als die Array-Länge ist. Wenn der Index größer oder
gleich der Array-Länge ist, wird Rust eine Panik auslösen.

Dies ist das erste Beispiel für die Umsetzung der Sicherheitsprinzipien von
Rust. In vielen Low-Level-Sprachen wird diese Art der Überprüfung nicht
durchgeführt und wenn du einen falschen Index angibst, kann auf ungültigen
Speicher zugegriffen werden. Rust schützt dich vor dieser Art von Fehlern, indem
es das Programm sofort beendet, anstatt den Speicherzugriff zuzulassen und
fortzusetzen. In Kapitel 9 wird mehr über die Fehlerbehandlung von Rust
besprochen.

[comparing-the-guess-to-the-secret-number]:
ch02-00-guessing-game-tutorial.html#comparing-the-guess-to-the-secret-number
[control-flow]: ch03-05-control-flow.html#control-flow
[strings]: ch08-02-strings.html#storing-utf-8-encoded-text-with-strings
[unrecoverable-errors-with-panic]: ch09-01-unrecoverable-errors-with-panic.html
[wrapping]: ../std/num/struct.Wrapping.html
