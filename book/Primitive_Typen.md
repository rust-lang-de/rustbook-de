# Primitive Typen

Die Rust Programmiersprache hat eine Reihe von Typen die als "primitiv"
angesehen werden. Das bedeutet, dass sie in die Sprache eingebaut sind.
Rust ist so strukturiert, dass die Standardbibliothek auch eine Menge
nützlicher Typen zur Verfügung stellt,
auch welche auf primitiven Typen aufbauen, aber diese hier sind am
"primitivsten".

# Booleans

Rust hat einen boolschen Typ namens `bool`. Er hat zwei mögliche Werte,
`true` und `false`:

```rust
let x = true;

let y: bool = false;
```

Eine übliche Nutzung ist in [`if` Bedingungen][if].

[if]: book/If.md

Du findest mehr Dokumentation zu `bool`s
[in der Dokumentation der Standardbibliothek][bool].

[bool]: https://doc.rust-lang.org/std/primitive.bool.html

# `char`

Der `char` Typ stellt einen einzelnen Unicode Skalarwert dar.
Du kannst `char`s mit einzelnen Anführungsszeichen erzeugen: (`'`)

```rust
let x = 'x';
let smiley = '😀';
```

Anders als in manch anderen Spachen bedeutet das, dass `char`s
kein einzelnes byte, sondern vier bytes sind.

Du findest mehr Dokumentation zu `char`s
[in der Dokumentation der Standardbibliothk][char].

[char]: https://doc.rust-lang.org/std/primitive.char.html

# Numerische Type

Rust hat eine Vielzahl an numerischen Typen in ein paar Kategorien:
Vorzeichenbehaftet und Vorzeichenlos, feste und variable Größe,
Fließkomma- und Ganzzahl.

Diese Typen bestehen aus zwei Teilen: Der Kategorie und ihrer Größe.
Zum Beispiel ist `u16` ein vorzeichenloser Typ, der 16 bit groß ist.
Mehr bits erlauben größere Zahlen.

Wenn ein Zahlenliteral keinen Typ durch etwas zugewiesen bekommt, dann
sind das hier die Standards:

```rust
let x = 42; // x hat den Typ i32

let y = 1.0; // y hat den Typ f64
```

Hier ist eine Liste der verschiedenen numerischen Typen, inklusive Links
zu ihrer jeweiligen Dokumentation in der Standardbibliothek:

* [i8](https://doc.rust-lang.org/std/primitive.i8.html)
* [i16](https://doc.rust-lang.org/std/primitive.i16.html)
* [i32](https://doc.rust-lang.org/std/primitive.i32.html)
* [i64](https://doc.rust-lang.org/std/primitive.i64.html)
* [u8](https://doc.rust-lang.org/std/primitive.u8.html)
* [u16](https://doc.rust-lang.org/std/primitive.u16.html)
* [u32](https://doc.rust-lang.org/std/primitive.u32.html)
* [u64](https://doc.rust-lang.org/std/primitive.u64.html)
* [isize](https://doc.rust-lang.org/std/primitive.isize.html)
* [usize](https://doc.rust-lang.org/std/primitive.usize.html)
* [f32](https://doc.rust-lang.org/std/primitive.f32.html)
* [f64](https://doc.rust-lang.org/std/primitive.f64.html)

Lass sie uns nach Kategorie durchgehen:

## Vorzeichenbehaftet und Vorzeichenlos

Ganzzahlige Typen kommen in zwei Ausführungen daher:
Vorzeichenbehaftet und Vorzeichenlos. Lass uns eine 4-bit Zahl betrachten
um den Unterschied zu verstehen. Eine Vorzeichenbehaftete 4-bit Zahl würde
dir erlauben Zahlen von `-8` bis `+7` zu speichern. Vorzeichenbehaftete Zahlen
verwenden die Zweierkomplementdarstellung. Eine vorzeichenlose 4-bit Zahl
braucht keine negativen Zahlen speichern und kann deswegen Werte von
`0` bis `+15` annehmen.

Vorzeichenlose Typen nutzen ein `u` für ihre Kategorie,
und vorzeichenbehaftete Typen nutzen ein `i`.
Das `i` steht für "integer" (Ganzzahl).
Also ist `u8` eine vorzeichenlose 8-bit Ganzzahl und
`i8` ist eine vorzeichenbehaftete 8-bit Ganzzahl.

## Typen fester Größe

Typen fester Größe enthalten eine speziefische Anzahl an Bits in
ihrer Darstellung. Gültige Bitgrößen sind `8`, `16`, `32 und `64`.
Also ist `u32` eine vorzeichenlose Ganzzahl mit 32 Bits und
`i64` eine vorzeichenbehaftete Ganzzahl mit 64 Bits.

## Fließkommatypen

Rust besitzt auch zwei Fließkommatypen: `f32` und `f64`.
Diese entsprechen dem IEEE-754 Standard für Fließkommazahlen
einfacher und doppelter Genauigkeit.

# Arrays

Wie die meisten Programmiersprachen hat Rust Listentypen
um Sequenzen von Dingen darzustellen.
Die grundlegenste ist das *Array*, eine Liste fester Größe von Elementen
des selben Typs. Standardmäßig sind Arrays *immutable*.

```rust
let a = [1, 2, 3]; // a: [i32; 3]
let mut m = [1, 2, 3]; // m: [i32; 3]
```

Arrays haben den Typ `[T; N]`. Wir werden über diese `T` Notation
[im Generics Abschnitt][generics] rede. Das `N` ist eine Konstante zur
Kompilierzeit um die Länge des Arrays anzuzeigen.

Es gibt eine abkürzende Schreibweise um jedes Element des Arrays mit dem
selben Wert zu initialisieren. In diesem Beispiel wird jedes Element von
`a` mit `0` initialisiert:

```rust
let a = [0; 20]; // a: [i32; 20]
```

Du kannst die Anzahl der Elemente eines Array `a` via `a.len()` ermitteln:

```rust
let a = [1, 2, 3];

println!("a hat {} Elemente", a.len());
```

Du kannst auf ein bestimmtes Element des Arrays
mithilfe eckiger Klammern (`[]`) zugreifen:

```rust
let namen = ["Graydon", "Brian", "Niko"]; // namen: [&str; 3]

println!("Der zweite Name ist: {}", namen[1]);
```

Die Indizes beginnen bei 0, wie in den meisten Programmiersprachen.
Somit ist der erste Name `namen[0]` und der zweite Name `namen[1]`.
Das vorherige Beispiel gibt `Der zweite Name ist: Brian` aus.
Wenn du versucht einen Index zu verwenden, der nicht im Array liegt,
dann wirst du einen Fehler bekommen: Arrayzugriffe werden zur Laufzeit
auf Gültigkeit geprüft. Solch ein fehlerhafter Zugriff ist die Quelle
vieler Bugs in anderen Systemsprachen.

Du findest mehr Dokumentation über `Arrays`s
[in der Dokumentation der Standardbibliothek][array].

[array]: https://doc.rust-lang.org/std/primitive.array.html

# Slices

Ein *slice* [engl.: Scheibe/Stück] ist eine Referenz (oder eine "Ansicht") auf
eine andere Datenstruktur. Sie erlauben einen sicheren und effizienten Zugriff
auf einen Teil eines Arrays ohne zu kopieren.
Zum Beispiel möchtest du vielleicht einfach nur auf eine Zeile einer
Datei im Speicher verweisen.
Aufgrund seiner Natur lässt sich ein *slice* nicht einfach so direkt erzeugen,
sondern nur aus einer existierenden Variable. Slices haben eine Länge,
können *mutable* oder *immutable* sein, und verhalten sich wie Arrays:

```rust
let a = [0, 1, 2, 3, 4];
let middle = &a[1..4]; // Ein Slice von a: Nur die Elemente 1, 2, und 3
let complete = &a[..]; // Ein Slice mit allen Elementen von a
```

Slices haben den Typ `&[T]`. Wir werden über dieses `T` sprechen, wenn wir
[Generics][generics] behandeln.

[generics]: book/Generics.md

Du findest mehr Dokumentation über `Slice`s
[in der Dokumentation der Standardbibliothek][slice].

[slice]: https://doc.rust-lang.org/std/primitive.slice.html

# `str`

Rusts `str` Typ ist der primitivste String Typ.
Als ein [größenloser Typ][dst] ist er alleine nicht sehr nützlich,
aber er wird sehr nützlich in Kombination mit einer Referenz, wie
zum Beispiel [`&str`][strings]. Von daher belassen wir es dabei.

[dst]: book/Größenlose_Typen.md
[strings]: book/Strings.md

Du findest mehr Dokumentation über `str`s
[in der Dokumentation der Standardbibliothek][str].

[str]: https://doc.rust-lang.org/std/primitive.str.html

# Tupel

Ein Tupel ist eine geordnete Liste fester Größe. Zum Beispiel:

```rust
let x = (1, "hallo");
```

Wie du sehen kannst sehen kannst, sieht der Typ eins Tupels genaus aus wie
das jeweilige Tupel, aber mit den jeweiligen Typen anstatt Werten.
Aufmerksame Leser werden auch feststellen, dass Tupel heterogen sind:
Wir haben ein `i32` und ein `&str` in diesem Tupel.
(In Systemprogrammiersprachen sind Strings ein wenig Komplexer als in anderen
Sprachen. Fürs erste lies `&str` als ein *string slice*.
Wir werden bald noch mehr darüber lernen.)

Tupel können einander zugewiesen werden, wenn die enthaltenen Typen und
die [Stelligkeit][arity] identisch sind. Tupel haben die gleiche Stelligkeit,
wenn sie dieselbe Länge haben.

[arity]: book/Gloassar.md#stelligkeit

```rust
let mut x = (1, 2); // x: (i32, i32)
let y = (2, 3); // y: (i32, i32)

x = y;
```

Du kannst auf die Felder eines Tupels durch *let Destrukturierung* zugreifen.
Hier ist ein Beispiel:

```rust
let (x, y, z) = (1, 2, 3);

println!("x ist {}", x);
```

Erinnerst du dich an [zuvor][let], als wir sagten, dass die linke Seite
etwas mächtiger ist als einfach nur eine Variablenbindung zuzuweisen?
Dabei sind wir nun. Wir können auf der linken Seite des `let` ein Muster
verwenden und, wenn es zu der rechten Seite passt, mehrere Variablenbindungen
gleichzeitig zuweisen. In diesem Fall "destrukturiert" `let` das Tupel bzw.
"nimmt es auseinander" und bindet die Teilstücke an Variablen.

[let]: book/Variablenbindung.md

Dieses Muster ist sehr mächtig und wir werden es später noch öfters sehen.

Du kannst ein Tupel mit einem einzelnen Element von einem Wert in Klammern durch
ein Komma unterscheiden:

```rust
(0,); // Tupel mit einem Element
(0); // 0 in Klammern
```

## Tupel Indizierung

Du kannst auf die Felder eines Tupel auch durch die "Indizierungssyntax"
zugreifen:

```rust
let tupel = (1, 2, 3);

let x = tupel.0;
let y = tupel.1;
let z = tupel.2;

println!("x ist {}", x);
```

Wie auch bei der Array Indizierung wird bei 0 begonnen, aber anders als
bei der Array Indizierung verwendet man ein `.` anstatt `[]`.

Du findest mehr Dokumentation über Tupel
[in der Dokumentation der Standardbibliothek][tuple].

[tuple]: https://doc.rust-lang.org/std/primitive.tuple.html

# Funktionen

Funktionen haben auch einen Typ! Er sieht so aus:

```rust
fn foo(x: i32) -> i32 { x }

let x: fn(i32) -> i32 = foo;
```

In diesem Fall ist `x` ein ‘Funktionszeiger’ auf eine Funktion,
welche ein `i32` akzeptiert und ein `i32` zurückgibt.
