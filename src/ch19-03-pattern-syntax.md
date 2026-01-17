## Mustersyntax

In diesem Abschnitt stellen wir die gesamte Syntax gültiger Muster zusammen und
erörtern, warum und wann du jedes einzelne Muster verwenden solltest.

### Literale abgleichen

Wie du in Kapitel 6 gesehen hast, kannst du Muster direkt mit Literalen
abgleichen. Der folgende Code enthält einige Beispiele:

```rust
let x = 1;

match x {
    1 => println!("eins"),
    2 => println!("zwei"),
    3 => println!("drei"),
    _ => println!("sonstige"),
}
```

Dieser Code gibt `eins` aus, weil `x` den Wert `1` hat. Diese Syntax ist
nützlich, wenn du willst, dass dein Code eine Aktion ausführt, wenn er einen
bestimmten konkreten Wert erhält.

### Benannte Variablen abgleichen

Benannte Variablen (named variables) sind unabweisbare Muster, die zu jedem
Wert passen, und wir haben sie in diesem Buch schon oft verwendet. Es gibt
jedoch eine Komplikation, wenn du benannte Variablen in `match`-, `if let`-
oder `while let`-Ausdrücken verwendest. Da mit jeder dieser Ausdrücke ein neuer
Gültigkeitsbereich beginnt, werden Variablen, die als Teil eines Musters
innerhalb dieser Ausdrücke deklariert sind, diejenigen Variablen mit dem
gleichen Namen außerhalb des Konstrukts verschatten (shadow), wie es bei allen
Variablen der Fall ist. In Codeblock 19-11 deklarieren wir eine Variable mit
dem Namen `x` mit dem Wert `Some(5)` und eine Variable `y` mit dem Wert `10`.
Dann erzeugen wir einen `match`-Ausdruck für den Wert `x`. Sieh dir die Muster
in den `match`-Zweigen und `println!` am Ende an und versuche herauszufinden,
was der Code ausgeben wird, bevor du diesen Code ausführst oder weiterliest.

<span class="filename">Dateiname: src/main.rs</span>

```rust
let x = Some(5);
let y = 10;

match x {
    Some(50) => println!("Habe 50 erhalten"),
    Some(y) => println!("Passt, y = {y}"),
    _ => println!("Standardfall, x = {x:?}"),
}

println!("Am Ende: x = {x:?}, y = {y}");
```

<span class="caption">Codeblock 19-11: Ein `match`-Ausdruck mit einem Zweig,
der eine neue Variable einführt, die die bereits existierende Variable `y`
verschattet</span>

Lass uns durchgehen, was passiert, wenn der `match`-Ausdruck ausgeführt wird.
Das Muster im ersten Zweig passt nicht zum definierten Wert von `x`, also setzt
der Code fort.

Das Muster im zweiten Zweig führt eine neue Variable namens `y` ein, die zu
jedem Wert innerhalb eines `Some`-Wertes passt. Da wir uns in einem neuen
Gültigkeitsbereich innerhalb des `match`-Ausdrucks befinden, ist dies eine neue
Variable `y`, nicht das `y`, das wir am Anfang mit dem Wert `10` deklariert
haben. Diese neue `y`-Bindung wird mit jedem Wert innerhalb eines `Some`
übereinstimmen, das ist das, was wir in `x` haben. Daher bindet dieses neue `y`
an den inneren Wert des `Some` in `x`. Dieser Wert ist `5`, sodass der Ausdruck
für diesen Zweig ausgeführt und `Passt, y = 5` ausgegeben wird.

Wäre `x` ein `None`-Wert anstelle von `Some(5)` gewesen, hätten die Muster in
den ersten beiden Zweigen nicht gepasst, sodass der Wert zum Unterstrich
gepasst hätte. Wir haben die Variable `x` nicht im Muster des
Unterstrich-Zweigs verwendet, sodass `x` im Ausdruck immer noch das äußere `x`
ist, das nicht verschattet wurde. In diesem hypothetischen Fall würde `match`
den Text `Standardfall, x = None` ausgeben.

Wenn der `match`-Ausdruck zu Ende ist, endet sein Gültigkeitsbereich und damit
auch der Gültigkeitsbereich des inneren `y`. Das letzte `println!` gibt `Am
Ende: x = Some(5), y = 10` aus.

Um einen `match`-Ausdruck zu erstellen, der die Werte der äußeren Variablen `x`
und `y` abgleicht, anstatt eine neue Variable einzuführen, die die existierende
Variable `y` verschattet, müssten wir stattdessen eine Abgleichsbedingung
(match guard conditional) verwenden. Wir werden über Abgleichsbedingungen
später im Abschnitt [„Abgleichsbedingungen hinzufügen“][extra-conditionals]
sprechen.

### Mehrfache Muster abgleichen

In `match`-Ausdrücken kannst du mehrere Muster mit der Syntax `|` abgleichen,
die das _oder_-Operator-Muster darstellt. Zum Beispiel gleicht der folgende
Code den Wert von `x` mit den `match`-Zweigen ab, wobei der erste davon eine
_oder_-Option hat, was bedeutet, wenn der Wert von `x` zu einem der Werte in
diesem Zweig passt, wird der Code dieses Zweigs ausgeführt:

```rust
let x = 1;

match x {
    1 | 2 => println!("eins oder zwei"),
    3 => println!("drei"),
    _ => println!("sonstige"),
}
```

Dieser Code gibt `eins oder zwei` aus.

### Abgleichen von Wertebereichen mit `..=`

Die Syntax `..=` erlaubt es uns, einen inklusiven Wertebereich abzugleichen.
Wenn im folgenden Code ein Muster zu einem der Werte innerhalb des
vorgegebenen Bereichs passt, wird dieser Zweig ausgeführt:

```rust
let x = 5;

match x {
    1..=5 => println!("eins bis fünf"),
    _ => println!("etwas anderes"),
}
```

Wenn `x` einen der Werte `1`, `2`, `3`, `4` oder `5` hat, passt der erste
Zweig. Diese Syntax ist bequemer bei mehreren Abgleichswerten als das Verwenden
des `|`-Operators, um die gleiche Idee auszudrücken; wenn wir `|` verwenden
wollten, müssten wir `1 | 2 | 3 | 4 | 5` angeben. Die Angabe eines Bereichs ist
viel kürzer, besonders wenn wir beispielsweise eine beliebige Zahl zwischen 1
und 1.000 angeben wollen!

Der Compiler prüft zur Kompilierzeit, dass der Bereich nicht leer ist. Die
einzigen Typen, bei denen Rust erkennen kann, ob ein Bereich leer ist oder
nicht, sind `char` und numerische Werte, Bereiche sind nur mit numerischen oder
`char`-Werten zulässig.

Hier ist ein Beispiel mit Bereichen von `char`-Werten:

```rust
let x = 'c';

match x {
    'a'..='j' => println!("früher ASCII-Buchstabe"),
    'k'..='z' => println!("später ASCII-Buchstabe"),
    _ => println!("etwas anderes"),
}
```

Rust kann erkennen, dass `'c'` innerhalb des Bereichs des ersten Musters liegt
und gibt `früher ASCII-Buchstabe` aus.

### Destrukturieren, um Werte aufzuteilen

Wir können auch Muster verwenden, um Strukturen (structs), Aufzählungen (enums)
und Tupel zu destrukturieren, um verschiedene Teile dieser Werte zu verwenden.
Lass uns jeden Wert durchgehen.

#### Strukturen

Codeblock 19-12 zeigt eine Struktur `Point` mit zwei Feldern, `x` und `y`, die
wir mit einem Muster in einer `let`-Anweisung aufteilen können.

<span class="filename">Dateiname: src/main.rs</span>

```rust
struct Point {
    x: i32,
    y: i32,
}

fn main() {
    let p = Point { x: 0, y: 7 };

    let Point { x: a, y: b } = p;
    assert_eq!(0, a);
    assert_eq!(7, b);
}
```

<span class="caption">Codeblock 19-12: Destrukturieren der Felder einer
Struktur in separate Variablen</span>

Dieser Code erzeugt die Variablen `a` und `b`, die den Werten der Felder `x`
und `y` der Struktur `p` entsprechen. Dieses Beispiel zeigt, dass die Namen der
Variablen im Muster nicht mit den Feldnamen der Struktur übereinstimmen müssen.
Aber es ist üblich, dass die Variablennamen mit den Feldnamen übereinstimmen,
damit man sich leichter merken kann, welche Variablen aus welchen Feldern
stammen. Wegen dieser häufigen Verwendung und weil das Schreiben von `let Point
{ x: x, y: y } = p;` eine Menge Duplikation enthält, hat Rust eine Kurzform
für Muster, die mit Strukturfeldern übereinstimmen: Du musst nur die Namen des
Struktur-Felder auflisten, und die Variablen, die aus dem Muster erzeugt
werden, haben die gleichen Namen. Codeblock 19-13 zeigt Code, der sich gleich
verhält wie der Code in Codeblock 19-12, aber die Variablen, die im Muster
`let` erzeugt werden, sind `x` und `y` anstelle von `a` und `b`.

<span class="filename">Dateiname: src/main.rs</span>

```rust
struct Point {
    x: i32,
    y: i32,
}

fn main() {
    let p = Point { x: 0, y: 7 };

    let Point { x, y } = p;
    assert_eq!(0, x);
    assert_eq!(7, y);
}
```

<span class="caption">Codeblock 19-13: Destrukturieren von Strukturfeldern mit
Hilfe der Strukturfeldkurznotation (struct field shorthand)</span>

Dieser Code erzeugt die Variablen `x` und `y`, die mit den Feldern `x` und `y`
der Variablen `p` übereinstimmen. Das Ergebnis ist, dass die Variablen `x` und
`y` die Werte aus der Struktur `p` enthalten.

Wir können auch mit literalen Werten als Teil des Strukturmusters
destrukturieren, anstatt Variablen für alle Felder zu erstellen. Auf diese
Weise können wir einige der Felder auf bestimmte Werte testen, während wir
Variablen zum Destrukturieren der anderen Felder erstellen.

In Codeblock 19-14 haben wir einen `match`-Ausdruck, der `Point`-Werte in drei
Fälle unterscheidet: Punkte, die direkt auf der `x`-Achse liegen (was zutrifft,
wenn `y = 0` ist), auf der `y`-Achse liegen (`x = 0`) oder auf keiner Achse.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# struct Point {
#     x: i32,
#     y: i32,
# }
#
fn main() {
    let p = Point { x: 0, y: 7 };

    match p {
        Point { x, y: 0 } => println!("Auf der x-Achse bei {x}"),
        Point { x: 0, y } => println!("Auf der y-Achse bei {y}"),
        Point { x, y } => println!("Auf keiner Achse: ({x}, {y})"),
    }
}
```

<span class="caption">Codeblock 19-14: Destrukturieren und Abgleichen literaler
Werte in einem Muster</span>

Der erste Zweig passt zu jedem Punkt, der auf der `x`-Achse liegt, indem er
angibt, dass der Wert des `y`-Felds zum Literal `0` passt. Das Muster erzeugt
immer noch eine Variable `x`, die wir im Code für diesen Zweig verwenden
können.

In ähnlicher Weise passt der zweite Zweig zu jedem Punkt auf der y-Achse, indem
er angibt, dass der Wert des `x`-Feldes 0 ist, und eine Variable `y`  für den
Wert des `y` -Feldes erzeugt. Der dritte Zweig spezifiziert keine Literale,
sodass er zu jedem anderen `Point` passt und Variablen für die Felder `x` und
`y` erzeugt.

In diesem Beispiel passt der Wert `p` zum zweiten Zweig, da `x` den Wert `0`
hat, sodass dieser Code `Auf der y-Achse bei 7` ausgeben wird.

Denke daran, dass ein `match`-Ausdruck aufhört, weitere Zweige zu prüfen,
sobald er das erste übereinstimmende Muster gefunden hat, d.h. auch wenn der
`Point { x: 0, y: 0}` auf der `x`-Achse und der `y`-Achse liegt, würde dieser
Code nur `Auf der x-Achse bei 0` ausgeben.

#### Aufzählungen

Wir haben in diesem Buch bereits Aufzählungen destrukturiert (z.B. Codeblock
6-5 in Kapitel 6), wir sind aber noch nicht explizit darauf eingegangen, dass
das Muster zur Destrukturierung einer Aufzählung der Art und Weise entspricht,
wie die in der Aufzählung gespeicherten Daten definiert sind. Als Beispiel
verwenden wir in Codeblock 19-15 die Aufzählung `Message` aus Codeblock 6-2 und
schreiben ein `match` mit Mustern, das jeden inneren Wert destrukturiert.

<span class="filename">Dateiname: src/main.rs</span>

```rust
enum Message {
    Quit,
    Move { x: i32, y: i32 },
    Write(String),
    ChangeColor(i32, i32, i32),
}

fn main() {
    let msg = Message::ChangeColor(0, 160, 255);

    match msg {
        Message::Quit => {
            println!("Die Quit-Variante hat keine Daten zu destrukturieren.")
        }
        Message::Move { x, y } => {
            println!("Bewege in x-Richtung {x} und in y-Richtung {y}");
        }
        Message::Write(text) => {
            println!("Textnachricht: {text}");
        }
        Message::ChangeColor(r, g, b) => {
            println!("Ändere Farbe in rot {r}, grün {g} und blau {b}");
        }
    }
}
```

<span class="caption">Codeblock 19-15: Destrukturieren von
Aufzählungsvarianten, die verschiedene Arten von Werten enthalten</span>

Dieser Code gibt `Ändere Farbe in rot 0, grün 160 und blau 255` aus. Versuche,
den Wert von `msg` zu ändern, um den Code der anderen Zweige laufen zu sehen.

Bei Aufzählungs-Varianten ohne Daten, wie `Message::Quit`, können wir den Wert
nicht weiter destrukturieren. Wir können nur mit dem Literalwert
`Message::Quit` abgleichen und es gibt keine Variablen in diesem Muster.

Für strukturähnliche Aufzählungsvarianten, z.B. `Message::Move`, können wir ein
Muster verwenden, das dem von uns angegebenen Muster ähnlich ist, um Strukturen
abzugleichen. Nach dem Variantennamen setzen wir geschweifte Klammern und
listen dann die Felder mit Variablen auf, sodass wir die Teile aufteilen, die
im Code für diesen Zweig verwendet werden sollen. Hier verwenden wir die
Kurznotation, wie wir es in Codeblock 19-13 getan haben.

Bei tupelähnlichen Aufzählungsvarianten wie `Message::Write`, die ein Tupel mit
einem Element enthält, und `Message::ChangeColor`, die ein Tupel mit drei
Elementen enthält, ähnelt das Muster dem Muster, das wir für den Abgleich von
Tupeln angeben. Die Anzahl der Variablen im Muster muss mit der Anzahl der
Elemente in der Variante, die wir abgleichen, übereinstimmen.

#### Verschachtelte Strukturen und Aufzählungen

Bis jetzt haben unsere Beispiele alle Strukturen oder Aufzählungen auf einer
Ebene abgeglichen, aber der Abgleich funktioniert auch bei verschachtelten
Elementen! Zum Beispiel können wir den Code in Codeblock 19-15 umstrukturieren,
um RGB- und HSV-Farben in der `ChangeColor`-Nachricht zu unterstützen, wie in
Codeblock 19-16 gezeigt.

```rust
enum Color {
    Rgb(i32, i32, i32),
    Hsv(i32, i32, i32),
}

enum Message {
    Quit,
    Move { x: i32, y: i32 },
    Write(String),
    ChangeColor(Color),
}

fn main() {
    let msg = Message::ChangeColor(Color::Hsv(0, 160, 255));

    match msg {
        Message::ChangeColor(Color::Rgb(r, g, b)) => {
            println!("Ändere Farbe in rot {r}, grün {g} und blau {b}");
        }
        Message::ChangeColor(Color::Hsv(h, s, v)) => {
            println!("Ändere Farbe in Farbwert {h}, Sättigung {s} und Hellwert {v}")
        }
        _ => (),
    }
}
```

<span class="caption">Codeblock 19-16: Abgleich bei verschachtelten
Aufzählungen</span>

Das Muster des ersten Zweigs im `match`-Ausdruck passt zu einer
`Message::ChangeColor`-Aufzählungsvariante, die eine `Color::Rgb`-Variante
enthält; dann bindet das Muster an die drei inneren `i32`-Werte. Das Muster des
zweiten Zweigs passt ebenfalls mit einer
`Message::ChangeColor`-Aufzählungsvariante, aber die innere Aufzählung passt
stattdessen zur `Color::Hsv`-Variante. Wir können diese komplexen Bedingungen
in einem einzigen `match`-Ausdruck angeben, auch wenn es sich um zwei
Aufzählungen handelt.

#### Strukturen und Tupel

Wir können das Abgleichen und Destrukturieren verschachtelter Muster auf noch
komplexere Weise mischen. Das folgende Beispiel zeigt eine komplizierte
Destrukturierung, bei der wir Strukturen und Tupel innerhalb eines Tupels
verschachteln und alle primitiven Werte herausdestrukturieren:

```rust
# struct Point {
#     x: i32,
#     y: i32,
# }
#
let ((feet, inches), Point { x, y }) = ((3, 10), Point { x: 3, y: -10 });
```

Dieser Code ermöglicht es uns, komplexe Typen in ihre Bestandteile zu zerlegen,
sodass wir die Werte, an denen wir interessiert sind, separat verwenden können.

Das Destrukturieren mit Mustern ist eine bequeme Möglichkeit, Wertteile, z.B.
Werte aus den Feldern in einer Struktur, getrennt voneinander zu verwenden.

### Ignorieren von Werten in einem Muster

Du hast gesehen, dass es manchmal nützlich ist, Werte in einem Muster zu
ignorieren, z.B. im letzten Zweig eines `match`, um einen Sammelzweig zu
erhalten, der eigentlich nichts tut, aber alle verbleibenden möglichen Werte
berücksichtigt. Es gibt ein paar Möglichkeiten, ganze Werte oder Teile von
Werten in einem Muster zu ignorieren: Verwenden des Musters `_` (das du gesehen
hast), Verwenden des Musters `_` innerhalb eines anderen Musters, Verwenden
eines Namens, der mit einem Unterstrich beginnt, oder Verwenden von `..`, um
verbleibende Teile eines Wertes zu ignorieren. Lass uns untersuchen, wie und
wann jedes dieser Muster zu verwenden ist.

#### Gesamtwert mit `_`

Wir haben den Unterstrich (`_`) als Platzhalter verwendet, der zu jedem Wert
passt, aber nicht an den Wert gebunden ist. Dies ist besonders nützlich als
letzter Zweig in einem `match`-Ausdruck ist, aber wir können es in jedem Muster
verwenden, einschließlich Funktionsparameter, wie in Codeblock 19-17 gezeigt.

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn foo(_: i32, y: i32) {
    println!("Dieser Code verwendet nur den Parameter y: {y}");
}

fn main() {
    foo(3, 4);
}
```

<span class="caption">Codeblock 19-17: Verwenden von `_` in einer
Funktionssignatur</span>

Dieser Code ignoriert den als erstes Argument übergebenen Wert `3` vollständig
und gibt `Dieser Code verwendet nur den Parameter y: 4` aus.

In den meisten Fällen, wenn du einen bestimmten Funktionsparameter nicht mehr
benötigst, würdest du die Signatur so ändern, dass sie den unbenutzten
Parameter nicht mehr enthält. Das Ignorieren eines Funktionsparameters kann in
einigen Fällen besonders nützlich sein, z.B. bei der Implementierung eines
Merkmals (trait), wenn du eine bestimmte Typsignatur benötigst, der
Funktionsrumpf in deiner Implementierung jedoch keinen der Parameter benötigt.
Du kannst dann vermeiden, dass der Compiler vor unbenutzten Funktionsparametern
warnt, wie es der Fall wäre, wenn du stattdessen einen Namen verwenden würdest.

#### Teile eines Wertes mit einem verschachtelten `_`

Wir können `_` auch innerhalb eines anderen Musters verwenden, um nur einen
Teil eines Wertes zu ignorieren, z.B. wenn wir nur auf einen Teil eines Wertes
testen wollen, aber keine Verwendung für die anderen Teile in dem
entsprechenden Code haben, den wir ausführen wollen. Der Codeblock 19-18 zeigt
den Code, der für die Verwaltung des Wertes einer Einrichtung verantwortlich
ist. Die Geschäftsanforderungen bestehen darin, dass es dem Benutzer nicht
erlaubt sein soll, eine bestehende Anpassung einer Einstellung zu
überschreiben, sondern dass er die Einstellung rückgängig machen kann und ihr
einen Wert zuweisen kann, wenn sie derzeit nicht gesetzt ist.

```rust
let mut setting_value = Some(5);
let new_setting_value = Some(10);

match (setting_value, new_setting_value) {
    (Some(_), Some(_)) => {
        println!("Kann einen vorhandenen benutzerdefinierten Wert nicht überschreiben.");
    }
    _ => {
        setting_value = new_setting_value;
    }
}

println!("Einstellung ist {setting_value:?}");
```

<span class="caption">Codeblock 19-18: Das Verwenden eines Unterstrichs
innerhalb von Mustern, die zu `Some`-Varianten passen, wenn wir den Wert
innerhalb `Some` nicht benötigen</span>

Dieser Code gibt `Kann einen vorhandenen benutzerdefinierten Wert nicht
überschreiben.` aus und dann `Einstellung ist Some(5)`. Im ersten
`match`-Zweig müssen wir nicht die Werte innerhalb der beiden `Some`-Varianten
abgleichen oder diese verwenden, aber wir müssen den Fall prüfen, dass
`setting_value` und `new_setting_value` jeweils `Some`-Varianten sind. In
diesem Fall geben wir den Grund aus, warum wir `setting_value` nicht ändern,
und es wird nicht geändert.

In allen anderen Fällen (wenn entweder `setting_value` oder `new_setting_value`
den Wert `None` hat), die durch das Muster `_` im zweiten Zweig ausgedrückt
werden, wollen wir erlauben, dass `setting_value` den Wert von
`new_setting_value` erhält.

Wir können Unterstriche auch an mehreren Stellen innerhalb eines Musters
verwenden, um bestimmte Werte zu ignorieren. Codeblock 19-19 zeigt ein Beispiel
für das Ignorieren des zweiten und vierten Wertes in einem Tupel von fünf
Elementen.

```rust
let numbers = (2, 4, 8, 16, 32);

match numbers {
    (first, _, third, _, fifth) => {
        println!("Einige Zahlen: {first}, {third}, {fifth}")
    }
}
```

<span class="caption">Codeblock 19-19: Ignorieren mehrerer Teile eines
Tupels</span>

Dieser Code gibt `Einige Zahlen: 2, 8, 32` aus und die Werte `4` und `16`
werden ignoriert.

#### Eine unbenutzte Variable mit `_` am Namensanfang

Wenn du eine Variable erstellst, sie aber nirgendwo verwendest, wird Rust
normalerweise eine Warnung ausgeben, weil eine unbenutzte Variable ein Fehler
sein könnte. Aber manchmal ist es nützlich, eine Variable erstellen zu können,
die du noch nicht verwenden wirst, z.B. wenn du einen Prototyp erstellst oder
gerade ein Projekt beginnst. In dieser Situation kannst du Rust anweisen, dich
nicht vor der unbenutzten Variablen zu warnen, indem du den Namen der Variablen
mit einem Unterstrich beginnst. In Codeblock 19-20 erstellen wir zwei
unbenutzte Variablen, aber wenn wir diesen Code kompilieren, sollten wir nur
vor einer von ihnen eine Warnung erhalten.

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let _x = 5;
    let y = 10;
}
```

<span class="caption">Codeblock 19-20: Beginnen eines Variablennamens mit einem
Unterstrich, um Warnungen zu unbenutzten Variablen zu vermeiden</span>

Hier erhalten wir eine Warnung zur unbenutzten Variablen `y`, aber wir erhalten
keine Warnung zur unbenutzten Variablen `_x`.

Beachte, dass es einen feinen Unterschied gibt zwischen dem Verwenden von `_`
und dem Verwenden eines Namens, der mit einem Unterstrich beginnt. Die Syntax
`_x` bindet immer noch den Wert an die Variable, während `_` überhaupt nicht
bindet. Um einen Fall zu zeigen, in dem diese Unterscheidung von Bedeutung ist,
wird uns Codeblock 19-21 einen Fehler liefern.

```rust,does_not_compile
let s = Some(String::from("Hallo!"));

if let Some(_s) = s {
    println!("Zeichenkette gefunden");
}

println!("{s:?}");
```

<span class="caption">Codeblock 19-21: Eine unbenutzte Variable, die mit einem
Unterstrich beginnt, bindet immer noch den Wert, der die Eigentümerschaft des
Wertes übernehmen könnte</span>

Wir werden einen Fehler erhalten, weil der Wert `s` immer noch in `_s`
verschoben wird, was uns daran hindert, `s` wieder zu verwenden. Das Verwenden
des Unterstrichs an sich bindet jedoch niemals einen Wert. Codeblock 19-22 wird
ohne Fehler kompilieren, weil `s` nicht in `_` verschoben wird.

```rust
let s = Some(String::from("Hallo!"));

if let Some(_) = s {
    println!("Zeichenkette gefunden");
}

println!("{s:?}");
```

<span class="caption">Codeblock 19-22: Das Verwenden eines Unterstrichs bindet
den Wert nicht</span>

Dieser Code funktioniert prima, weil wir `s` nie an etwas binden; es wird nicht
verschoben.

#### Verbleibende Teile eines Wertes mit `..`

Bei Werten, die viele Teile haben, können wir die Syntax `..` verwenden, um nur
spezifische Teile zu verwenden und den Rest zu ignorieren, sodass es nicht
notwendig ist, für jeden ignorierten Wert Unterstriche aufzulisten. Das Muster
`..` ignoriert alle Teile eines Wertes, die wir im Rest des Musters nicht
explizit zugeordnet haben. In Codeblock 19-23 haben wir eine Struktur `Point`,
die eine Koordinate im dreidimensionalen Raum enthält. Im `match`-Ausdruck
wollen wir nur mit der Koordinate `x` operieren und die Werte in den Feldern
`y` und `z` ignorieren.

```rust
struct Point {
    x: i32,
    y: i32,
    z: i32,
}

let origin = Point { x: 0, y: 0, z: 0 };

match origin {
    Point { x, .. } => println!("x ist {x}"),
}
```

<span class="caption">Codeblock 19-23: Ignorieren aller Felder eines `Point`
mit Ausnahme von `x` durch Verwenden von `..`</span>

Wir listen den Wert `x` auf und fügen dann einfach das Muster `..` ein. Das
geht schneller, als `y: _` und `z: _` anzugeben, insbesondere wenn wir mit
Strukturen arbeiten, die viele Felder haben, in Situationen, in denen nur ein
oder zwei Felder relevant sind.

Die Syntax `..` wird auf so viele Werte wie nötig erweitert. Codeblock 19-24
zeigt, wie man `..` mit einem Tupel verwendet.

<span class="filename">Dateiname: src/main.rs</span>

```rust
let numbers = (2, 4, 8, 16, 32);

match numbers {
    (first, .., last) => {
        println!("Einige Zahlen: {first}, {last}");
    }
}
```

<span class="caption">Codeblock 19-24: Nur den ersten und letzten Wert in einem
Tupel abgleichen und alle anderen Werte ignorieren</span>

In diesem Code werden der erste und der letzte Wert mit `first` und `last`
abgeglichen. Das `..` passt zu allem in der Mitte und ignoriert es.

Das Verwenden von `..` muss jedoch eindeutig sein. Wenn unklar ist, welche
Werte zum Abgleich vorgesehen sind und welche ignoriert werden sollten, gibt
uns Rust einen Fehler. Codeblock 19-25 zeigt ein Beispiel für die mehrdeutige
Verwendung von `..`, sodass es sich nicht kompilieren lässt.

<span class="filename">Dateiname: src/main.rs</span>

```rust,does_not_compile
let numbers = (2, 4, 8, 16, 32);

match numbers {
    (.., second, ..) => {
        println!("Einige Zahlen: {second}")
    },
}
```

<span class="caption">Codeblock 19-25: Ein Versuch, `..` auf mehrdeutige Weise
zu verwenden</span>

Wenn wir dieses Beispiel kompilieren, erhalten wir diesen Fehler:

```console
$ cargo run
   Compiling patterns v0.1.0 (file:///projects/patterns)
error: `..` can only be used once per tuple pattern
 --> src/main.rs:5:22
  |
5 |         (.., second, ..) => {
  |          --          ^^ can only be used once per tuple pattern
  |          |
  |          previously used here

error: could not compile `patterns` (bin "patterns") due to 1 previous error
```

Es ist für Rust unmöglich zu bestimmen, wie viele Werte im Tupel zu ignorieren
sind, bevor ein Wert zu `second` passt, und wie viele weitere Werte danach zu
ignorieren sind. Dieser Code könnte bedeuten, dass wir `2` ignorieren wollen,
`second` an `4` binden und dann `8`, `16` und `32` ignorieren wollen; oder dass
wir `2` und `4` ignorieren wollen, `second` an `8` binden und dann `16` und
`32` ignorieren wollen; und so weiter. Der Variablenname `second` bedeutet für
Rust nichts Besonderes, sodass wir einen Kompilierfehler erhalten, weil das
Verwenden von `..` an zwei Stellen wie dieser mehrdeutig ist.

### Abgleichsbedingungen hinzufügen

Eine _Abgleichsbedingung_ (match guard) ist eine zusätzliche `if`-Bedingung,
die nach dem Muster in einem `match`-Zweig angegeben wird und die zusammen mit
dem Musterabgleich ebenfalls übereinstimmen muss, damit dieser Zweig ausgewählt
wird. Abgleichsbedingungen sind nützlich, um komplexere Ideen auszudrücken, als
es ein Muster allein erlaubt. Beachte jedoch, dass sie nur in
`match`-Ausdrücken verfügbar sind, nicht in `if let`- oder `while
 let`-Ausdrücken.

Die Bedingung kann Variablen verwenden, die im Muster erstellt wurden.
Codeblock 19-26 zeigt ein `match`, wobei der erste Zweig das Muster `Some(x)`
und die Abgleichsbedingung `if x % 2 == 0` (die `true` ist, wenn die Zahl
gerade ist) hat.

```rust
let num = Some(4);

match num {
    Some(x) if x % 2 == 0 => println!("Die Zahl {x} ist gerade"),
    Some(x) => println!("Die Zahl {x} ist ungerade"),
    None => (),
}
```

<span class="caption">Codeblock 19-26: Hinzufügen einer Abgleichsbedingung zu
einem Muster</span>

In diesem Beispiel wird `Die Zahl 4 ist gerade` ausgegeben. Wenn `num` mit dem
Muster im ersten Zweig abgeglichen wird, passt es, weil `Some(4)` zu `Some(x)`
passt. Dann prüft die Abgleichsbedingung, ob der Rest der Division von `x`
durch 2 gleich 0 ist, und weil dies der Fall ist, wird der erste Zweig ausgewählt.

Wenn `num` stattdessen `Some(5)` gewesen wäre, wäre die Abgleichsbedingung im
ersten Zweig `false` gewesen, weil der Rest von 5 geteilt durch 2 den Wert 1
ergibt, was ungleich 0 ist. Rust würde dann zum zweiten Zweig gehen, der passen
würde, weil der zweite Zweig keine Abgleichsbedingung hat und daher zu allen
`Some`-Varianten passt.

Es gibt keine Möglichkeit, die Bedingung `if x % 2 == 0` innerhalb eines Musters
auszudrücken, also gibt uns die Abgleichsbedingung die Möglichkeit, diese Logik
anzugeben. Der Nachteil dieser zusätzlichen Ausdruckskraft ist, dass der
Compiler nicht versucht, die Vollständigkeit zu prüfen, wenn
Abgleichsbedingungs-Ausdrücke beteiligt sind.

Als wir Codeblock 19-11 besprochen haben, haben wir erwähnt, dass wir zur
Lösung unseres Musterverschattungsproblems (pattern-shadowing problem)
Abgleichsbedingungen verwenden könnten. Erinnere dich daran, dass eine neue
Variable innerhalb des Musters im `match`-Ausdruck erstellt wurde, anstatt die
Variable außerhalb von `match` zu verwenden. Diese neue Variable bedeutete,
dass wir nicht gegen den Wert der äußeren Variable testen konnten. Codeblock
19-27 zeigt, wie wir eine Abgleichsbedingung verwenden können, um dieses
Problem zu beheben.

<span class="filename">Dateiname: src/main.rs</span>

```rust
let x = Some(5);
let y = 10;

match x {
    Some(50) => println!("Habe 50 erhalten"),
    Some(n) if n == y => println!("Passt, n = {n}"),
    _ => println!("Standardfall, x = {x:?}"),
}

println!("Am Ende: x = {x:?}, y = {y}");
```

<span class="caption">Codeblock 19-27: Verwenden einer Abgleichsbedingung zum
Testen der Gleichheit mit einer äußeren Variablen</span>

Dieser Code gibt nun `Standardfall, x = Some(5)` aus. Das Muster im zweiten
`match`-Zweig führt keine neue Variable `y` ein, die das äußere `y` verschatten
würde, was bedeutet, dass wir das äußere `y` in der Abgleichsbedingung
verwenden können. Anstatt das Muster mit `Some(y)` zu spezifizieren, was das
äußere `y` verschattet hätte, spezifizieren wir `Some(n)`. Dies erzeugt eine
neue Variable `n`, die nichts verschattet, weil es keine Variable `n` außerhalb
von `match` gibt.

Die Abgleichsbedingung `if n == y` ist kein Muster und führt daher keine neuen
Variablen ein. Dieses `y` _ist_ das äußere `y` und nicht ein neues `y`, das es
verschattet, und wir können nach einem Wert suchen, der den gleichen Wert wie
das äußere `y` hat, indem wir `n` mit `y` vergleichen.

Du kannst auch den _oder_-Operator `|` in einer Abgleichsbedingung verwenden,
um mehrere Muster anzugeben; die Abgleichsbedingung gilt dann für alle Muster.
Codeblock 19-28 zeigt den Vorrang der Kombination einer Abgleichsbedingung mit
einem Muster, das `|` verwendet. Der wichtige Teil dieses Beispiels ist, dass
die Abgleichsbedingung `if y` auf `4`, `5` _und_ `6` zutrifft, auch wenn es so
aussehen mag, als ob `if y` nur auf `6` zutrifft.

```rust
let x = 4;
let y = false;

match x {
    4 | 5 | 6 if y => println!("ja"),
    _ => println!("nein"),
}
```

<span class="caption">Codeblock 19-28: Kombinieren mehrerer Muster mit einer
Abgleichsbedingung</span>

Die Abgleichsbedingung besagt, dass der Zweig nur dann passt, wenn der Wert von
`x` gleich `4`, `5` oder `6` ist _und_ wenn `y` `wahr` ist. Wenn dieser Code
ausgeführt wird, passt das Muster des ersten Zweigs, weil `x` gleich `4` ist,
allerdings ist die Abgleichsbedingung `if y` falsch, sodass der erste Zweig
nicht ausgewählt wird. Der Code geht weiter zum zweiten Zweig, der passt, und
dieses Programm gibt `nein` aus. Der Grund dafür ist, dass die `if`-Bedingung
für das gesamte Muster `4 | 5 | 6` gilt, nicht nur für den letzten Wert `6`.
Mit anderen Worten, der Vorrang einer Abgleichsbedingung in Bezug auf ein
Muster verhält sich wie folgt:

```rust,ignore
(4 | 5 | 6) if y => ...
```

und nicht so:

```rust,ignore
4 | 5 | (6 if y) => ...
```

Nach dem Ausführen des Codes ist das Vorrangsverhalten offensichtlich: Würde
die Abgleichsbedingung nur auf den Endwert in der mit dem `|`-Operator
angegebenen Werteliste angewendet, hätte der Zweig gepasst und das Programm
hätte `ja` ausgegeben.

### `@`-Bindungen verwenden

Mit dem _at_-Operator `@` können wir eine Variable erstellen, die einen Wert
enthält, während wir gleichzeitig diesen Wert testen, um festzustellen, ob er
zu einem Muster passt. Codeblock 19-29 zeigt ein Beispiel, bei dem wir testen
wollen, dass ein `Message::Hello`-Feld `id` innerhalb des Bereichs `3..=7`
liegt. Wir wollen den Wert auch an die Variable `id` binden, damit wir ihn in
dem mit dem Zweig verbundenen Code verwenden können.

```rust
enum Message {
    Hello { id: i32 },
}

let msg = Message::Hello { id: 5 };

match msg {
    Message::Hello {
        id: id_variable @ 3..=7,
    } => println!("id im Bereich gefunden: {id_variable}"),
    Message::Hello { id: 10..=12 } => {
        println!("id in einem anderen Bereich gefunden")
    }
    Message::Hello { id } => println!("Eine andere id gefunden: {id}"),
}
```

<span class="caption">Codeblock 19-29: Verwenden von `@`, um an einen Wert in
einem Muster zu binden und ihn gleichzeitig zu testen</span>

In diesem Beispiel wird `id im Bereich gefunden: 5` ausgegeben. Durch das
Angeben von `id @` vor dem Bereich `3..=7` erfassen wir den Wert, der mit dem
Bereich übereinstimmt, in einer Variable namens `id` und testen gleichzeitig,
ob der Wert zum Bereichsmuster passt.

Im zweiten Zweig, wo wir im Muster nur einen Bereich spezifiziert haben, hat
der zum Zweig gehörende Code keine Variable, die den tatsächlichen Wert des
`id`-Feldes enthält. Der Wert des `id`-Feldes hätte 10, 11 oder 12 sein können,
aber der Code, der zu diesem Muster gehört, weiß nicht, welcher es ist. Der
Code des Musters ist nicht in der Lage, den Wert des `id`-Feldes zu verwenden,
weil wir den `id`-Wert nicht in einer Variablen gespeichert haben.

Im letzten Zweig, in dem wir eine Variable ohne Bereich angegeben haben, haben
wir den Wert, der im Code des Zweigs verfügbar ist, in einer Variablen namens
`id`. Der Grund dafür ist, dass wir die Syntax des Struktur-Feldes in
Kurznotation verwendet haben. Aber wir haben keinen Test auf den Wert im Feld
`id` in diesem Zweig angewandt, wie wir es bei den ersten beiden Zweigen getan
haben: Jeder Wert würde zu diesem Muster passen.

Mit `@` können wir einen Wert testen und ihn in einer Variablen innerhalb eines
Musters speichern.

## Zusammenfassung

Die Muster in Rust sind sehr nützlich, um zwischen verschiedenen Arten von
Daten zu unterscheiden. Wenn sie in `match`-Ausdrücken verwendet werden, stellt
Rust sicher, dass deine Muster jeden möglichen Wert abdecken oder dein Programm
sich nicht kompilieren lässt. Muster in `let`-Anweisungen und
Funktionsparametern machen diese Konstrukte nützlicher und ermöglichen das
Destrukturieren von Werten in kleinere Teile und das Zuweisen dieser Teile an
Variablen. Wir können einfache oder komplexe Muster erstellen, die unseren
Bedürfnissen entsprechen.

Als nächstes werden wir uns im vorletzten Kapitel des Buches mit einigen
fortgeschrittenen Aspekten einer Vielzahl von Rusts Funktionalitäten befassen.

[extra-conditionals]: #abgleichsbedingungen-hinzufügen
