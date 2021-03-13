## Mustersyntax

Im ganzen Buch hast du Beispiele für viele Arten von Mustern gesehen. In diesem
Abschnitt stellen wir die gesamte Syntax gültiger Muster zusammen und erörtern,
wann du jedes einzelne Muster verwenden solltest.

### Passende Literale

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

Dieser Code gibt `eins` aus, weil der Wert in `x` 1 ist. Diese Syntax ist
nützlich, wenn du willst, dass dein Code eine Aktion ausführt, wenn er einen
bestimmten konkreten Wert erhält.

### Benannte Variablen abgleichen

Benannte Variablen (named variables) sind unabweisbare Muster, die zu jedem
Wert passen, und wir haben sie in diesem Buch schon oft verwendet. Es gibt
jedoch eine Komplikation, wenn du benannte Variablen in `match`-Ausdrücken
verwendest. Da `match` einen neuen Gültigkeitsbereich beginnt, werden
Variablen, die als Teil eines Musters innerhalb des `match`-Ausdrucks
deklariert sind, diejenigen mit dem gleichen Namen außerhalb des
`match`-Konstrukts beschatten (shadow), wie es bei allen Variablen der Fall
ist. In Codeblock 18-11 deklarieren wir eine Variable mit dem Namen `x` mit dem
Wert `Some(5)` und eine Variable `y` mit dem Wert `10`. Dann erzeugen wir einen
`match`-Ausdruck für den Wert `x`. Sieh dir die Muster in den `match`-Zweigen
und `println!` am Ende an und versuche herauszufinden, was der Code ausgeben
wird, bevor du diesen Code ausführst oder weiterliest.

<span class="filename">Dateiname: src/main.rs</span>

```rust
    let x = Some(5);
    let y = 10;

    match x {
        Some(50) => println!("Habe 50 erhalten"),
        Some(y) => println!("Passt, y = {:?}", y),
        _ => println!("Standardfall, x = {:?}", x),
    }

    println!("Am Ende: x = {:?}, y = {:?}", x, y);
```

<span class="caption">Codeblock 18-11: Ein `match`-Ausdruck mit einem Zweig,
der eine beschattete Variable `y` einführt</span>

Lass uns durchgehen, was passiert, wenn der `match`-Ausdruck ausgeführt wird.
Das Muster im ersten Zweig passt nicht zum definierten Wert von `x`, also setzt
der Code fort.

Das Muster im zweiten Zweig führt eine neue Variable namens `y` ein, die zu
jedem Wert innerhalb eines `Some`-Wertes passt. Da wir uns in einem neuen
Gültigkeitsbereich innerhalb des `match`-Ausdrucks befinden, ist dies eine neue
Variable `y`, nicht das `y`, das wir am Anfang mit dem Wert 10 deklariert
haben. Diese neue `y`-Bindung wird mit jedem Wert innerhalb eines `Some`
übereinstimmen, das ist das, was wir in `x` haben. Daher bindet dieses neue `y`
an den inneren Wert des `Some` in `x`. Dieser Wert ist `5`, sodass der Ausdruck
für diesen Zweig ausgeführt und `Passt, y = 5` ausgegeben wird.

Wäre `x` ein `None`-Wert anstelle von `Some(5)` gewesen, hätten die Muster in
den ersten beiden Zweigen nicht gepasst, sodass der Wert zum Unterstrich
gepasst hätte. Wir haben die Variable `x` nicht im Muster des
Unterstrich-Zweigs verwendet, sodass `x` im Ausdruck immer noch das äußere `x`
ist, das nicht beschattet wurde. In diesem hypothetischen Fall würde `match`
den Text `Standardfall, x = None` ausgeben.

Wenn der `match`-Ausdruck zu Ende ist, endet sein Gültigkeitsbereich und damit
auch der Gültigkeitsbereich des inneren `y`. Das letzte `println!` gibt `Am
Ende: x = Some(5), y = 10` aus.

Um einen `match`-Ausdruck zu erstellen, der die Werte der äußeren `x` und `y`
abgleicht anstatt eine beschattete Variable einzuführen, müssten wir
stattdessen eine Abgleichsbedingung (match guard conditional) verwenden. Wir
werden über Abgleichsbedingungen später im Abschnitt [„Extra-Bedingungen mit
Abgleichsbedingungen“](#extra-bedingungen-mit-abgleichsbedingungen) sprechen.

### Mehrfache Muster

In `match`-Ausdrücken kannst du mehrere Muster mit der Syntax `|` abgleichen,
die *oder* bedeutet. Zum Beispiel gleicht der folgende Code den Wert von `x`
mit den `match`-Zweigen ab, wobei der erste davon eine *oder*-Option hat, was
bedeutet, wenn der Wert von `x` zu einem der Werte in diesem Zweig passt, wird
der Code dieses Zweigs ausgeführt:

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
Wenn im folgenden Code ein Muster zu einem der Werte innerhalb des Bereichs
passt, wird dieser Zweig ausgeführt:

```rust
    let x = 5;

    match x {
        1..=5 => println!("eins bis fünf"),
        _ => println!("etwas anderes"),
    }
```

Wenn `x` 1, 2, 3, 4 oder 5 ist, passt der erste Zweig. Diese Syntax ist
bequemer als das Verwenden des `|`-Operators, um die gleiche Idee auszudrücken;
statt `1..=5` müssten wir `1 | 2 | 3 | 4 | 5` angeben, wenn wir `|` verwenden
würden. Die Angabe eines Bereichs ist viel kürzer, besonders wenn wir
beispielsweise eine beliebige Zahl zwischen 1 und 1.000 angeben wollen!

Bereiche sind nur mit numerischen Werten oder `char`-Werten erlaubt, da der
Compiler zur Kompilierzeit prüft, dass der Bereich nicht leer ist. Die einzigen
Typen, bei denen Rust erkennen kann, ob ein Bereich leer ist oder nicht, sind
`char` und numerische Werte.

Hier ist ein Beispiel mit Bereichen von `char`-Werten:

```rust
    let x = 'c';

    match x {
        'a'..='j' => println!("früher ASCII-Buchstabe"),
        'k'..='z' => println!("später ASCII-Buchstabe"),
        _ => println!("etwas anderes"),
    }
```

Rust kann erkennen, dass `c` innerhalb des Bereichs des ersten Musters liegt
und gibt `früher ASCII-Buchstabe` aus.

### Destrukturieren, um Werte aufzuteilen

Wir können auch Muster verwenden, um Strukturen (structs), Aufzählungen
(enums), Tupel und Referenzen zu destrukturieren, um verschiedene Teile dieser
Werte zu verwenden. Lass uns jeden Wert durchgehen.

#### Destrukturieren von Strukturen

Codeblock 18-12 zeigt eine Struktur `Point` mit zwei Feldern, `x` und `y`, die
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

<span class="caption">Codeblock 18-12: Destrukturieren der Felder einer
Struktur in separate Variablen</span>

Dieser Code erzeugt die Variablen `a` und `b`, die den Werten der Felder `x`
und `y` der Struktur `p` entsprechen. Dieses Beispiel zeigt, dass die Namen der
Variablen im Muster nicht mit den Feldnamen der Struktur übereinstimmen müssen.
Aber es ist üblich, dass die Variablennamen mit den Feldnamen übereinstimmen,
damit man sich leichter merken kann, welche Variablen aus welchen Feldern
stammen.

Weil es üblich ist, dass die Variablennamen mit den Feldnamen übereinstimmen,
und weil das Schreiben von `let Point { x: x, y: y } = p;` viel Duplikation
enthält, gibt es eine Kurzform für Muster, die mit Struktur-Feldern
übereinstimmen: Du musst nur die Namen des Struktur-Felder auflisten, und die
Variablen, die aus dem Muster erzeugt werden, haben die gleichen Namen.
Codeblock 18-13 zeigt Code, der sich gleich verhält wie der Code in Codeblock
18-12, aber die Variablen, die im Muster `let` erzeugt werden, sind `x` und `y`
anstelle von `a` und `b`.

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

<span class="caption">Codeblock 18-13: Destrukturieren von Strukturfeldern mit
Hilfe der Strukturfeldkurznotation (struct field shorthand)</span>

Dieser Code erzeugt die Variablen `x` und `y`, die mit den Feldern `x` und `y`
der Variablen `p` übereinstimmen. Das Ergebnis ist, dass die Variablen `x` und
`y` die Werte aus der Struktur `p` enthalten.

Wir können auch mit literalen Werten als Teil des Strukturmusters
destrukturieren, anstatt Variablen für alle Felder zu erstellen. Auf diese
Weise können wir einige der Felder auf bestimmte Werte testen, während wir
Variablen zum Destrukturieren der anderen Felder erstellen.

Codeblock 18-14 zeigt einen `match`-Ausdruck, der `Point`-Werte in drei Fälle
unterscheidet: Punkte, die direkt auf der `x`-Achse liegen (was zutrifft, wenn
`y = 0`), auf der `y`-Achse liegen (`x = 0`) oder keines von beiden.

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
        Point { x, y: 0 } => println!("Auf der x-Achse bei {}", x),
        Point { x: 0, y } => println!("Auf der y-Achse bei {}", y),
        Point { x, y } => println!("Auf keiner Achse: ({}, {})", x, y),
    }
}
```

<span class="caption">Codeblock 18-14: Destrukturieren und Abgleichen literaler
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

In diesem Beispiel passt der Wert `p` zum zweiten Zweig, da `x` eine 0 enthält,
sodass dieser Code `Auf der y-Achse bei 7` ausgeben wird.

#### Destrukturieren von Auszählungen

Wir haben früher Aufzählungen in diesem Buch destrukturiert, zum Beispiel, als
wir `Option<i32>` in Codeblock 6-5 in Kapitel 6 destrukturiert haben. Ein
Detail, das wir nicht explizit erwähnt haben, ist, dass das Muster zum
Destrukturieren einer Aufzählung mit der Art und Weise übereinstimmen sollte,
wie die in der Aufzählung gespeicherten Daten definiert sind. Als Beispiel
verwenden wir in Codeblock 18-15 die Aufzählung `Message` aus Codeblock 6-2 und
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
            println!(
                "Bewege in x-Richtung {} und in y-Richtung {}",
                x, y
            );
        }
        Message::Write(text) => println!("Textnachricht: {}", text),
        Message::ChangeColor(r, g, b) => println!(
            "Ändere die Farbe in rot {}, grün {} und blau {}",
            r, g, b
        ),
    }
}
```

<span class="caption">Codeblock 18-15: Destrukturieren von
Aufzählungsvarianten, die verschiedene Arten von Werten enthalten</span>

Dieser Code gibt `Ändere die Farbe in rot 0, grün 160 und blau 255` aus.
Versuche, den Wert von `msg` zu ändern, um den Code der anderen Zweige laufen
zu sehen.

Bei Aufzählungs-Varianten ohne Daten, wie `Message::Quit`, können wir den Wert
nicht weiter destrukturieren. Wir können nur mit dem Literalwert
`Message::Quit` abgleichen und es gibt keine Variablen in diesem Muster.

Für strukturähnliche Aufzählungsvarianten, z.B. `Message::Move`, können wir ein
Muster verwenden, das dem von uns angegebenen Muster ähnlich ist, um Strukturen
abzugleichen. Nach dem Variantennamen setzen wir geschweifte Klammern und
listen dann die Felder mit Variablen auf, sodass wir die Teile aufteilen, die
im Code für diesen Zweig verwendet werden sollen. Hier verwenden wir die
Kurznotation, wie wir es in Codeblock 18-13 getan haben.

Bei tupelähnlichen Aufzählungsvarianten wie `Message::Write`, die ein Tupel mit
einem Element enthält, und `Message::ChangeColor`, die ein Tupel mit drei
Elementen enthält, ähnelt das Muster dem Muster, das wir für den Abgleich von
Tupeln angeben. Die Anzahl der Variablen im Muster muss mit der Anzahl der
Elemente in der Variante, die wir abgleichen, übereinstimmen.

#### Destrukturieren verschachtelter Strukturen und Aufzählungen

Bis jetzt haben all unsere Beispiele zu Strukturen oder Aufzählungen gepasst,
die eine Ebene tief waren. Der Abgleich kann auch auf verschachtelte Elemente
angewendet werden!

Beispielsweise können wir den Code in Codeblock 18-15 so umformulieren, dass
RGB- und HSV-Farben in der `ChangeColor`-Nachricht unterstützt werden, wie in
Codeblock 18-16 gezeigt.

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
        Message::ChangeColor(Color::Rgb(r, g, b)) => println!(
            "Ändere die Farbe in rot {}, grün {} und blau {}",
            r, g, b
        ),
        Message::ChangeColor(Color::Hsv(h, s, v)) => println!(
            "Ändere die Farbe in Farbwert {}, Sättigung {} und Hellwert {}",
            h, s, v
        ),
        _ => (),
    }
}
```

<span class="caption">Codeblock 18-16: Abgleich bei verschachtelten
Aufzählungen</span>

Das Muster des ersten Zweigs im `match`-Ausdruck passt zu einer
`Message::ChangeColor`-Aufzählungsvariante, die eine `Color::Rgb`-Variante
enthält; dann bindet das Muster an die drei inneren `i32`-Werte. Das Muster des
zweiten Zweigs passt ebenfalls mit einer
`Message::ChangeColor`-Aufzählungsvariante, aber die innere Aufzählung passt
stattdessen zur `Color::Hsv`-Variante. Wir können diese komplexen Bedingungen
in einem einzigen `match`-Ausdruck angeben, auch wenn es sich um zwei
Aufzählungen handelt.

#### Destrukturieren von Strukturen und Tupeln

Wir können das Abgleichen und Destrukturieren verschachtelter Muster auf noch
komplexere Weise mischen. Das folgende Beispiel zeigt eine komplizierte
Destrukturierung, bei der wir Strukturen und Tupel innerhalb eines Tupels
verschachteln und alle primitiven Werte herausdestrukturieren:

```rust
# fn main() {
#     struct Point {
#         x: i32,
#         y: i32,
#     }
#
    let ((feet, inches), Point { x, y }) = ((3, 10), Point { x: 3, y: -10 });
# }
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

#### Ignorieren eines Gesamtwertes mit `_`

Wir haben den Unterstrich (`_`) als Platzhalter verwendet, der zu jedem Wert
passt, aber nicht an den Wert gebunden ist. Obwohl das Unterstrichmuster `_`
besonders nützlich als letzter Zweig in einem `match`-Ausdruck ist, können wir
es in jedem Muster verwenden, einschließlich Funktionsparameter, wie in
Codeblock 18-17 gezeigt.

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn foo(_: i32, y: i32) {
    println!("Dieser Code verwendet nur den Parameter y: {}", y);
}

fn main() {
    foo(3, 4);
}
```

<span class="caption">Codeblock 18-17: Verwenden von `_` in einer
Funktionssignatur</span>

Dieser Code ignoriert den als erstes Argument übergebenen Wert `3` vollständig
und gibt `Dieser Code verwendet nur den Parameter y: 4` aus.

In den meisten Fällen, wenn du einen bestimmten Funktionsparameter nicht mehr
benötigst, würdest du die Signatur so ändern, dass sie den unbenutzten
Parameter nicht mehr enthält. Das Ignorieren eines Funktionsparameters kann in
einigen Fällen besonders nützlich sein, z.B. bei der Implementierung eines
Merkmals (trait), wenn du eine bestimmte Typsignatur benötigst, der
Funktionsrumpf in deiner Implementierung jedoch keinen der Parameter benötigt.
Der Compiler wird dann nicht vor unbenutzten Funktionsparametern warnen, wie es
der Fall wäre, wenn du stattdessen einen Namen verwenden würdest.

#### Ignorieren von Teilen eines Wertes mit einem verschachtelten `_`

Wir können `_` auch innerhalb eines anderen Musters verwenden, um nur einen
Teil eines Wertes zu ignorieren, z.B. wenn wir nur auf einen Teil eines Wertes
testen wollen, aber keine Verwendung für die anderen Teile in dem
entsprechenden Code haben, den wir ausführen wollen. Der Codeblock 18-18 zeigt
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

    println!("Einstellung ist {:?}", setting_value);
```

<span class="caption">Codeblock 18-18: Das Verwenden eines Unterstrichs
innerhalb von Mustern, die zu `Some`-Varianten passen, wenn wir den Wert
innerhalb `Some` nicht benötigen</span>

Dieser Code gibt `Kann einen vorhandenen benutzerdefinierten Wert nicht
überschreiben.` aus und dann `Einstellung ist Some(5)`. Im ersten
`match`-Zweig müssen wir nicht die Werte innerhalb der beiden `Some`-Varianten
abgleichen oder diese verwenden, aber wir müssen den Fall prüfen, dass
`setting_value` und `new_setting_value` jeweils `Some`-Varianten sind. In
diesem Fall geben wir aus, warum wir `setting_value` nicht ändern, und es wird
nicht geändert.

In allen anderen Fällen (wenn entweder `setting_value` oder `new_setting_value`
den Wert `None` hat), die durch das Muster `_` im zweiten Zweig ausgedrückt
werden, wollen wir erlauben, dass `setting_value` den Wert von
`new_setting_value` erhält.

Wir können Unterstriche auch an mehreren Stellen innerhalb eines Musters
verwenden, um bestimmte Werte zu ignorieren. Codeblock 18-19 zeigt ein Beispiel
für das Ignorieren des zweiten und vierten Wertes in einem Tupel von fünf
Elementen.

```rust
    let numbers = (2, 4, 8, 16, 32);

    match numbers {
        (first, _, third, _, fifth) => {
            println!("Einige Zahlen: {}, {}, {}", first, third, fifth)
        }
    }
```

<span class="caption">Codeblock 18-19: Ignorieren mehrerer Teile eines
Tupels</span>

Dieser Code gibt `Einige Zahlen: 2, 8, 32` aus und die Werte 4 und 16 werden
ignoriert.

#### Ignorieren einer unbenutzten Variable, indem ihr Name mit `_` beginnt

Wenn du eine Variable erstellst, sie aber nirgendwo verwendest, wird Rust
normalerweise eine Warnung ausgeben, weil das ein Fehler sein könnte. Aber
manchmal ist es nützlich, eine Variable zu erstellen, die du noch nicht
verwenden wirst, z.B. wenn du einen Prototyp erstellst oder gerade ein Projekt
beginnst. In dieser Situation kannst du Rust anweisen, dich nicht vor der
unbenutzten Variablen zu warnen, indem du den Namen der Variablen mit einem
Unterstrich beginnst. In Codeblock 18-20 erstellen wir zwei unbenutzte
Variablen, aber wenn wir diesen Code kompilieren, sollten wir nur vor einer von
ihnen eine Warnung erhalten.

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let _x = 5;
    let y = 10;
}
```

<span class="caption">Codeblock 18-20: Beginnen eines Variablennamens mit einem
Unterstrich, um Warnungen zu unbenutzten Variablen zu vermeiden</span>

Hier erhalten wir eine Warnung zur unbenutzten Variablen `y`, aber wir erhalten
keine Warnung zur unbenutzten Variablen mit vorangestelltem Unterstrich.

Beachte, dass es einen feinen Unterschied gibt zwischen dem Verwenden von `_`
und dem Verwenden eines Namens, der mit einem Unterstrich beginnt. Die Syntax
`_x` bindet immer noch den Wert an die Variable, während `_` überhaupt nicht
bindet. Um einen Fall zu zeigen, in dem diese Unterscheidung von Bedeutung ist,
wird uns Codeblock 18-21 einen Fehler liefern.

```rust,does_not_compile
    let s = Some(String::from("Hallo!"));

    if let Some(_s) = s {
        println!("Zeichenkette gefunden");
    }

    println!("{:?}", s);
```

<span class="caption">Codeblock 18-21: Eine unbenutzte Variable, die mit einem
Unterstrich beginnt, bindet immer noch den Wert, der die Eigentümerschaft des
Wertes übernehmen könnte</span>

Wir werden einen Fehler erhalten, weil der Wert `s` immer noch in `_s`
verschoben wird, was uns daran hindert, `s` wieder zu verwenden. Das Verwenden
des Unterstrichs an sich bindet jedoch niemals einen Wert. Codeblock 18-22 wird
ohne Fehler kompilieren, weil `s` nicht in `_` verschoben wird.

```rust
    let s = Some(String::from("Hallo!"));

    if let Some(_) = s {
        println!("Zeichenkette gefunden");
    }

    println!("{:?}", s);
```

<span class="caption">Codeblock 18-22: Das Verwenden eines Unterstrichs bindet
den Wert nicht</span>

Dieser Code funktioniert prima, weil wir `s` nie an etwas binden; es wird nicht
verschoben.

#### Ignorieren der verbleibenden Teile eines Wertes mit `..`

Bei Werten, die viele Teile haben, können wir die Syntax `..` verwenden, um nur
einige wenige Teile zu verwenden und den Rest zu ignorieren, sodass es nicht
notwendig ist, für jeden ignorierten Wert Unterstriche aufzulisten. Das Muster
`..` ignoriert alle Teile eines Wertes, die wir im Rest des Musters nicht
explizit zugeordnet haben. In Codeblock 18-23 haben wir eine Struktur `Point`,
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
        Point { x, .. } => println!("x ist {}", x),
    }
```

<span class="caption">Codeblock 18-23: Ignorieren aller Felder eines `Point`
mit Ausnahme von `x` durch Verwenden von `..`</span>

Wir listen den Wert `x` auf und fügen dann einfach das Muster `..` ein. Das
geht schneller, als `y: _` und `z: _` anzugeben, insbesondere wenn wir mit
Strukturen arbeiten, die viele Felder haben, in Situationen, in denen nur ein
oder zwei Felder relevant sind.

Die Syntax `..` wird auf so viele Werte wie nötig erweitert. Codeblock 18-24
zeigt, wie man `..` mit einem Tupel verwendet.

<span class="filename">Dateiname: src/main.rs</span>

```rust
    let numbers = (2, 4, 8, 16, 32);

    match numbers {
        (first, .., last) => {
            println!("Einige Zahlen: {}, {}", first, last);
        }
    }
```

<span class="caption">Codeblock 18-24: Nur den ersten und letzten Wert in einem
Tupel abgleichen und alle anderen Werte ignorieren</span>

In diesem Code werden der erste und der letzte Wert mit `first` und `last`
abgeglichen. Das `..` passt zu allem in der Mitte und ignoriert es.

Das Verwenden von `..` muss jedoch eindeutig sein. Wenn unklar ist, welche
Werte zum Abgleich vorgesehen sind und welche ignoriert werden sollten, gibt
uns Rust einen Fehler. Codeblock 18-25 zeigt ein Beispiel für die mehrdeutige
Verwendung von `..`, sodass es sich nicht kompilieren lässt.

<span class="filename">Dateiname: src/main.rs</span>

```rust,does_not_compile
# fn main() {
    let numbers = (2, 4, 8, 16, 32);

    match numbers {
        (.., second, ..) => {
            println!("Einige Zahlen: {}", second)
        },
    }
# }
```

<span class="caption">Codeblock 18-25: Ein Versuch, `..` auf mehrdeutige Weise
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

error: aborting due to previous error

error: could not compile `patterns`

To learn more, run the command again with --verbose.
```

Es ist für Rust unmöglich zu bestimmen, wie viele Werte im Tupel zu ignorieren
sind, bevor ein Wert zu `second` passt, und wie viele weitere Werte danach zu
ignorieren sind. Dieser Code könnte bedeuten, dass wir `2` ignorieren wollen,
`second` an `4` binden und dann `8`, `16` und `32` ignorieren wollen; oder dass
wir `2` und `4` ignorieren wollen, `second` an `8` binden und dann `16` und
`32` ignorieren wollen; und so weiter. Der Variablenname `second` bedeutet für
Rust nichts Besonderes, sodass wir einen Kompilierfehler erhalten, weil das
Verwenden von `..` an zwei Stellen wie dieser mehrdeutig ist.

### Extra-Bedingungen mit Abgleichsbedingungen

Eine *Abgleichsbedingung* (match guard) ist eine zusätzliche `if`-Bedingung,
die nach dem Muster in einem `match`-Zweig angegeben wird und die zusammen mit
dem Musterabgleich ebenfalls übereinstimmen muss, damit dieser Zweig ausgewählt
wird. Abgleichsbedingungen sind nützlich, um komplexere Ideen auszudrücken, als
es ein Muster allein erlaubt.

Die Bedingung kann Variablen verwenden, die im Muster erstellt wurden.
Codeblock 18-26 zeigt ein `match`, wobei der erste Zweig das Muster `Some(x)`
und die Abgleichsbedingung `if x < 5` hat.

```rust
    let num = Some(4);

    match num {
        Some(x) if x < 5 => println!("kleiner als fünf: {}", x),
        Some(x) => println!("{}", x),
        None => (),
    }
```

<span class="caption">Codeblock 18-26: Hinzufügen einer Abgleichsbedingung zu
einem Muster</span>

In diesem Beispiel wird `kleiner als fünf: 4` ausgegeben. Wenn `num` mit dem
Muster im ersten Zweig abgeglichen wird, passt es, weil `Some(4)` zu `Some(x)`
passt. Dann prüft die Abgleichsbedingung, ob der Wert in `x` kleiner als `5`
ist, und weil dies der Fall ist, wird der erste Zweig ausgewählt.

Hätte `num` stattdessen den Wert `Some(10)` gehabt, wäre die Abgleichsbedingung
im ersten Zweig falsch gewesen, denn 10 ist nicht weniger als 5. Rust würde
dann zum zweiten Zweig gehen, der passen würde, weil der zweite Zweig keine
Abgleichsbedingung hat und daher zu allen `Some`-Varianten passt.

Es gibt keine Möglichkeit, die Bedingung `if x < 5` innerhalb eines Musters
auszudrücken, also gibt uns die Abgleichsbedingung die Möglichkeit, diese Logik
anzugeben.

In Codeblock 18-11 haben wir erwähnt, dass wir zur Lösung unseres
Musterbeschattungsproblems (pattern-shadowing problem) Abgleichsbedingungen
verwenden könnten. Erinnere dich daran, dass eine neue Variable innerhalb des
Musters im `match`-Ausdruck erstellt wurde, anstatt die Variable außerhalb von
`match` zu verwenden. Diese neue Variable bedeutete, dass wir nicht gegen den
Wert der äußeren Variable testen konnten. Codeblock 18-27 zeigt, wie wir eine
Abgleichsbedingung verwenden können, um dieses Problem zu beheben.

<span class="filename">Dateiname: src/main.rs</span>

```rust
    let x = Some(5);
    let y = 10;

    match x {
        Some(50) => println!("Habe 50 erhalten"),
        Some(n) if n == y => println!("Passt, n = {}", n),
        _ => println!("Standardfall, x = {:?}", x),
    }

    println!("Am Ende: x = {:?}, y = {}", x, y);
```

<span class="caption">Codeblock 18-27: Verwenden einer Abgleichsbedingung zum
Testen der Gleichheit mit einer äußeren Variablen</span>

Dieser Code gibt nun `Standardfall, x = Some(5)` aus. Das Muster im zweiten
`match`-Zweig führt keine neue Variable `y` ein, die das äußere `y` beschatten
würde, was bedeutet, dass wir das äußere `y` in der Abgleichsbedingung
verwenden können. Anstatt das Muster mit `Some(y)` zu spezifizieren, was das
äußere `y` beschattet hätte, spezifizieren wir `Some(n)`. Dies erzeugt eine
neue Variable `n`, die nichts beschattet, weil es keine Variable `n` außerhalb
von `match` gibt.

Die Abgleichsbedingung `if n == y` ist kein Muster und führt daher keine neuen
Variablen ein. Dieses `y` *ist* das äußere `y` und nicht ein neues beschattetes
`y`, und wir können nach einem Wert suchen, der den gleichen Wert wie das
äußere `y` hat, indem wir `n` mit `y` vergleichen.

Du kannst auch den *oder*-Operator `|` in einer Abgleichsbedingung verwenden,
um mehrere Muster anzugeben; die Abgleichsbedingung gilt dann für alle Muster.
Codeblock 18-28 zeigt den Vorrang der Kombination einer Abgleichsbedingung mit
einem Muster, das `|` verwendet. Der wichtige Teil dieses Beispiels ist, dass
die Abgleichsbedingung `if y` auf `4`, `5` *und* `6` zutrifft, auch wenn es so
aussehen mag, als ob `if y` nur auf `6` zutrifft.

```rust
    let x = 4;
    let y = false;

    match x {
        4 | 5 | 6 if y => println!("ja"),
        _ => println!("nein"),
    }
```

<span class="caption">Codeblock 18-28: Kombinieren mehrerer Muster mit einer
Abgleichsbedingung</span>

Die Abgleichsbedingung besagt, dass der Zweig nur dann passt, wenn der Wert von
`x` gleich `4`, `5` oder `6` ist *und* wenn `y` `wahr` ist. Wenn dieser Code
ausgeführt wird, passt das Muster des ersten Zweigs, weil `x` gleich `4` ist,
allerdings ist die Abgleichsbedingung `if y` falsch, sodass der erste Zweig
nicht ausgewählt wird. Der Code geht weiter zum zweiten Zweig, der passt, und
dieses Programm gibt `nein` aus. Der Grund dafür ist, dass die `if`-Bedingung
für das gesamte Muster `4 | 5 | 6` gilt, nicht nur für den letzten Wert `6`.
Mit anderen Worten, der Vorrang einer Abgleichsbedingung in Bezug auf ein
Muster verhält sich wie folgt:

```text
(4 | 5 | 6) if y => ...
```

und nicht so:

```text
4 | 5 | (6 if y) => ...
```

Nach dem Ausführen des Codes ist das Vorrangsverhalten offensichtlich: Würde
die Abgleichsbedingung nur auf den Endwert in der mit dem `|`-Operator
angegebenen Werteliste angewendet, hätte der Zweig gepasst und das Programm
hätte `ja` ausgegeben.

### `@`-Bindungen

Mit dem *at*-Operator (`@`) können wir eine Variable erstellen, die einen Wert
enthält, während wir gleichzeitig diesen Wert testen, um festzustellen, ob er
zu einem Muster passt. Codeblock 18-29 zeigt ein Beispiel, bei dem wir testen
wollen, dass ein `Message::Hello`-Feld `id` innerhalb des Bereichs `3..=7`
liegt. Aber wir wollen den Wert auch an die Variable `id_variable` binden,
damit wir ihn in dem mit dem Zweig verbundenen Code verwenden können. Wir
könnten diese Variable `id` nennen, so wie das Feld, aber für dieses Beispiel
werden wir einen anderen Namen verwenden.

```rust
    enum Message {
        Hello { id: i32 },
    }

    let msg = Message::Hello { id: 5 };

    match msg {
        Message::Hello {
            id: id_variable @ 3..=7,
        } => println!("id im Bereich gefunden: {}", id_variable),
        Message::Hello { id: 10..=12 } => {
            println!("id in einem anderen Bereich gefunden")
        }
        Message::Hello { id } => println!("Eine andere id gefunden: {}", id),
    }
```

<span class="caption">Codeblock 18-29: Verwenden von `@`, um an einen Wert in
einem Muster zu binden und ihn gleichzeitig zu testen</span>

In diesem Beispiel wird `id im Bereich gefunden: 5` ausgegeben. Durch das
Angeben von `id_variable @` vor dem Bereich `3..=7` erfassen wir den Wert, der
mit dem Bereich übereinstimmt, und testen gleichzeitig, ob der Wert zum
Bereichsmuster passt.

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

Die Muster in Rust sind sehr nützlich, da sie helfen, zwischen verschiedenen
Arten von Daten zu unterscheiden. Wenn sie in `match`-Ausdrücken verwendet
werden, stellt Rust sicher, dass deine Muster jeden möglichen Wert abdecken
oder dein Programm sich nicht kompilieren lässt. Muster in `let`-Anweisungen
und Funktionsparametern machen diese Konstrukte nützlicher und ermöglichen das
Destrukturieren von Werten in kleinere Teile und gleichzeitig das Zuweisen an
Variablen. Wir können einfache oder komplexe Muster erstellen, die unseren
Bedürfnissen entsprechen.

Als nächstes werden wir uns im vorletzten Kapitel des Buches mit einigen
fortgeschrittenen Aspekten einer Vielzahl von Rusts Funktionalitäten befassen.
