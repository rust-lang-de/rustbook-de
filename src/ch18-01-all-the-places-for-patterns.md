## Alle Stellen an denen Muster (patterns) verwendet werden können

Muster tauchen an vielen Stellen in Rust auf und du hast sie oft benutzt, ohne
es zu merken! In diesem Abschnitt werden alle Stellen besprochen, an denen
Muster gültig sind.

### `match`-Zweige

Wie in Kapitel 6 besprochen, verwenden wir Muster in den Zweigen von
`match`-Ausdrücken. Formal werden `match`-Ausdrücke definiert mit dem
Schlüsselwort `match`, einem Wert, mit dem verglichen wird, und einem oder
mehreren `match`-Zweigen, die aus einem Muster und einem Ausdruck bestehen, der
ausgeführt wird, wenn der Wert zum Muster dieses Zweigs passt, wie hier:

```text
match VALUE {
    PATTERN => EXPRESSION,
    PATTERN => EXPRESSION,
    PATTERN => EXPRESSION,
}
```

Hier ist zum Beispiel der `match`-Ausdruck aus Codeblock 6-5, der auf einen
`Option<i32>`-Wert in der Variablen `x` passt:

```rust,ignore
match x {
    None => None,
    Some(i) => Some(i + 1),
}
```

Die Muster in diesem `match`-Ausdruck sind `None` und `Some(i)` links von jedem
Pfeil.

Eine Anforderung für `match`-Ausdrücke ist, dass sie *erschöpfend* (exhaustive)
in dem Sinne sein müssen, dass alle Möglichkeiten für den Wert im
`match`-Ausdruck berücksichtigt sein müssen. Ein Weg, um sicherzustellen, dass
alle Möglichkeiten abgedeckt sind, ist ein Sammel-Muster (catchall pattern) für
den letzten Zweig: Zum Beispiel kann ein Variablenname, der zu einem beliebigen
Wert passt, niemals fehlschlagen und deckt somit jeden verbleibenden Fall ab.

Das spezielle Muster `_` wird auf alles passen, aber es bindet nie an eine
Variable, daher wird es oft im letzten `match`-Zweig verwendet. Das Muster `_`
kann zum Beispiel nützlich sein, wenn du jeden nicht angegebenen Wert
ignorieren willst. Wir werden das Muster `_` im Abschnitt [„Ignorieren von
Werten in einem Muster“][ignoring-values-in-a-pattern] später in diesem Kapitel
ausführlicher behandeln.

### Bedingte `if let`-Ausdrücke

In Kapitel 6 haben wir erörtert, wie man `if let`-Ausdrücke hauptsächlich als
kürzeren Weg verwendet, um das Äquivalent eines `match`-Ausdrucks zu schreiben,
der nur einen Fall prüft. Optional kann `if let` ein entsprechendes `else`
haben mit Code, der ausgeführt wird, wenn das Muster in `if let` nicht passt.

Codeblock 18-1 zeigt, dass es auch möglich ist, die Ausdrücke `if let`, `else
if` und `else if let` zu mischen und anzupassen. Dies gibt uns mehr
Flexibilität als ein `match`-Ausdruck, in dem wir nur einen Wert zum Abgleich
mit den Mustern haben können. Auch erfordert Rust nicht, dass die Bedingungen
in einer Reihe von `if let`-, `else if`- und `else if let`-Zweigen sich
notwendigerweise aufeinander beziehen.

Der Code in Codeblock 18-1 bestimmt die Farbe des Hintergrunds auf der
Grundlage einer Reihe von Prüfungen mehrerer Bedingungen. Für dieses Beispiel
haben wir Variablen mit hartkodierten Werten erstellt, die ein reales Programm
von Benutzereingaben erhalten könnte.

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let favorite_color: Option<&str> = None;
    let is_tuesday = false;
    let age: Result<u8, _> = "34".parse();

    if let Some(color) = favorite_color {
        println!("Verwende deine Lieblingsfarbe {color} als Hintergrund");
    } else if is_tuesday {
        println!("Dienstag ist grüner Tag!");
    } else if let Ok(age) = age {
        if age > 30 {
            println!("Verwende violett als Hintergrundfarbe");
        } else {
            println!("Verwende orange als Hintergrundfarbe");
        }
    } else {
        println!("Verwende blau als Hintergrundfarbe");
    }
}
```

<span class="caption">Codeblock 18-1: Mischen von `if let`, `else if`, `else if
let` und `else`</span>

Wenn der Benutzer eine Lieblingsfarbe angibt, ist diese Farbe die
Hintergrundfarbe. Wenn keine Lieblingsfarbe angegeben wurde und heute Dienstag
ist, ist die Hintergrundfarbe grün. Ansonsten, wenn der Benutzer sein Alter als
Zeichenkette angibt und wir es erfolgreich als Zahl parsen können, ist die
Farbe entweder violett oder orange, je nach dem Wert der Zahl. Wenn keine
dieser Bedingungen zutrifft, ist die Hintergrundfarbe blau.

Mit dieser bedingten Struktur können wir komplexe Anforderungen unterstützen.
Mit den hartkodierten Werten, die wir hier haben, wird dieses Beispiel
`Verwende violett als Hintergrundfarbe` ausgeben.

Du kannst sehen, dass `if let` auch verschattete Variablen (shadowed variables)
auf die gleiche Weise einführen kann wie bei `match`-Zweigen: Die Zeile `if let
Ok(age) = age` führt eine neue verschattete Variable `age` ein, die den Wert
innerhalb der `Ok`-Variante enthält. Das bedeutet, dass wir die Bedingung `if
age > 30` innerhalb dieses Blocks platzieren müssen: Wir können diese beiden
Bedingungen nicht in `if let Ok(age) = age && age > 30` kombinieren. Das
verschattete `age`, das wir mit 30 vergleichen wollen, ist erst gültig, wenn der
neue Gültigkeitsbereich mit der geschweiften Klammer beginnt.

Der Nachteil der Verwendung von `if let`-Ausdrücken ist, dass der Compiler die
Vollständigkeit nicht prüft, während er dies bei `match`-Ausdrücken tut. Wenn
wir den letzten `else`-Block weglassen und daher einige Fälle nicht behandelt
haben, würde uns der Compiler nicht auf den möglichen Logikfehler hinweisen.

### `while let`-bedingte Schleifen

Ähnlich konstruiert wie `if let` erlaubt die `while let`-bedingte Schleife,
dass eine `while`-Schleife so lange läuft, wie ein Muster weiterhin passt. In
Codeblock 18-2 haben wir eine `while let`-Schleife geschrieben, die einen
Vektor als Stapel (stack) verwendet und die Werte im Vektor in der umgekehrten
Reihenfolge ausgibt, in der sie auf den Stapel gelegt wurden.

```rust
    let mut stack = Vec::new();

    stack.push(1);
    stack.push(2);
    stack.push(3);

    while let Some(top) = stack.pop() {
        println!("{}", top);
    }
```

<span class="caption">Codeblock 18-2: Das Verwenden einer `while let`-Schleife,
um Werte so lange auszugeben, wie `stack.pop()` ein `Some` zurückgibt</span>

Dieses Beispiel gibt 3, 2 und 1 aus. Die `pop`-Methode nimmt das letzte Element
aus dem Vektor und gibt `Some(value)` zurück. Wenn der Vektor leer ist, gibt
`pop` den Wert `None` zurück. Die `while`-Schleife führt den Code in ihrem
Block so lange aus, wie `pop` ein `Some` zurückgibt. Wenn `pop` den Wert `None`
zurückgibt, stoppt die Schleife. Wir können `while let` benutzen, um jedes
Element von unserem Stapel zu holen.

### `for`-Schleifen

In einer `for`-Schleife ist der Wert, der direkt auf das Schlüsselwort `for`
folgt, ein Muster. Zum Beispiel ist in `for x in y` das `x` das Muster.
Codeblock 18-3 zeigt, wie man ein Muster in einer `for`-Schleife verwendet, um
ein Tupel als Teil der `for`-Schleife zu destrukturieren oder zu zerlegen.

```rust
    let v = vec!['a', 'b', 'c'];

    for (index, value) in v.iter().enumerate() {
        println!("{} ist beim Index {}", value, index);
    }
```

<span class="caption">Codeblock 18-3: Verwenden eines Musters in einer
`for`-Schleife zum Destrukturieren eines Tupels</span>

Der Code in Codeblock 18-3 wird Folgendes ausgeben:

```console
$ cargo run
   Compiling patterns v0.1.0 (file:///projects/patterns)
    Finished dev [unoptimized + debuginfo] target(s) in 0.52s
     Running `target/debug/patterns`
a ist beim Index 0
b ist beim Index 1
c ist beim Index 2
```

Wir passen einen Iterator mit der Methode `enumerate` so an, dass er einen
Wert und den Index für diesen Wert erzeugt, die in einem Tupel abgelegt sind.
Der erste Aufruf von `enumerate` erzeugt das Tupel `(0, 'a')`. Wenn dieser Wert
zum Muster `(index, value)` passt, ist `index` gleich `0` und `value` gleich
`'a'`, wodurch die erste Zeile der Ausgabe ausgegeben wird.

### `let`-Anweisungen

Vor diesem Kapitel hatten wir das Verwenden von Mustern nur explizit mit
`match` und `if let` besprochen, aber tatsächlich haben wir Muster auch an
anderen Stellen verwendet, auch in `let`-Anweisungen. Betrachte zum Beispiel
diese einfache Variablenzuweisung mit `let`:

```rust
let x = 5;
```

Jedes Mal, wenn die eine `let`-Anweisung wie diese verwendet hast, hast du
Muster verwendet, auch wenn du es vielleicht nicht bemerkt hast! Formal sieht
eine `let`-Anweisung wie folgt aus:

```text
let PATTERN = EXPRESSION;
```

In Anweisungen wie `let x = 5;` mit einem Variablennamen an der Stelle
`PATTERN` ist der Variablenname nur eine besonders einfache Form eines Musters.
Rust vergleicht den Ausdruck mit dem Muster und weist alle gefundenen Namen zu.
Im Beispiel `let x = 5;` ist `x` also ein Muster, das bedeutet: „Binde das, was
hier passt, an die Variable `x`.“ Da der Name `x` das gesamte Muster ist,
bedeutet dieses Muster effektiv „Binde alles an die Variable `x`, was auch
immer der Wert ist.“.

Um den Aspekt des Musterabgleichs (pattern matching) von `let` deutlicher zu
sehen, betrachte Codeblock 18-4, der ein Muster mit `let` verwendet, um ein
Tupel zu destrukturieren.

```rust
    let (x, y, z) = (1, 2, 3);
```

<span class="caption">Codeblock 18-4: Verwenden eines Musters zum
Destrukturieren eines Tupels und zum gleichzeitigen Erzeugen von drei
Variablen</span>

Hier vergleichen wir ein Tupel mit einem Muster. Rust vergleicht den Wert `(1,
2, 3)` mit dem Muster `(x, y, z)` und sieht, dass der Wert zum Muster passt,
also bindet Rust `1` an `x`, `2` an `y` und `3` an `z`. Man kann sich dieses
Tupelmuster als Verschachtelung von drei einzelnen Variablen-Mustern darin
vorstellen.

Wenn die Anzahl der Elemente im Muster nicht mit der Anzahl der Elemente im
Tupel übereinstimmt, passt der Gesamttyp nicht, und wir erhalten einen
Kompilierfehler. Beispielsweise zeigt Codeblock 18-5 einen Versuch, ein Tupel
mit drei Elementen in zwei Variablen zu destrukturieren, was nicht
funktioniert.

```rust,does_not_compile
    let (x, y) = (1, 2, 3);
```

<span class="caption">Codeblock 18-5: Fehlerhaft aufgebautes Musters, dessen
Variablen nicht mit der Anzahl der Elemente im Tupel übereinstimmen</span>

Der Versuch, diesen Code zu kompilieren, führt zu diesem Typfehler:

```console
$ cargo run
   Compiling patterns v0.1.0 (file:///projects/patterns)
error[E0308]: mismatched types
 --> src/main.rs:2:9
  |
2 |     let (x, y) = (1, 2, 3);
  |         ^^^^^^   --------- this expression has type `({integer}, {integer}, {integer})`
  |         |
  |         expected a tuple with 3 elements, found one with 2 elements
  |
  = note: expected tuple `({integer}, {integer}, {integer})`
             found tuple `(_, _)`

For more information about this error, try `rustc --explain E0308`.
error: could not compile `patterns` due to previous error
```

Um den Fehler zu beheben, könnten wir einen oder mehrere der Werte im Tupel
mittels `_` oder `..` ignorieren, wie du im Abschnitt [„Ignorieren von Werten
in einem Muster“][ignoring-values-in-a-pattern] sehen wirst. Wenn das Problem
darin besteht, dass wir zu viele Variablen im Muster haben, besteht die Lösung
darin, die Typen aufeinander abzustimmen, indem Variablen entfernt werden,
sodass die Anzahl der Variablen gleich der Anzahl der Elemente im Tupel ist.

### Funktionsparameter

Funktionsparameter können auch Muster sein. Der Code in Codeblock 18-6, der
eine Funktion namens `foo` deklariert, die einen Parameter namens `x` vom Typ
`i32` benötigt, sollte inzwischen bekannt aussehen.

```rust
fn foo(x: i32) {
    // Code kommt hierher
}
#
# fn main() {}
```

<span class="caption">Codeblock 18-6: Eine Funktionssignatur verwendet Muster
in den Parametern</span>

Der Teil `x` ist ein Muster! Wie wir es mit `let` taten, konnten wir ein Tupel
in den Argumenten einer Funktion dem Muster zuordnen. Codeblock 18-7 teilt die
Werte in einem Tupel auf, wenn wir es an eine Funktion übergeben.

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn print_coordinates(&(x, y): &(i32, i32)) {
    println!("Aktuelle Position: ({}, {})", x, y);
}

fn main() {
    let point = (3, 5);
    print_coordinates(&point);
}
```

<span class="caption">Codeblock 18-7: Eine Funktion mit Parametern, die ein
Tupel destrukturieren</span>

Dieser Code gibt `Aktuelle Position: (3, 5)` aus. Die Werte `&(3, 5)` passen
zum Muster `&(x, y)`, sodass `x` den Wert `3` und `y` den Wert `5` hat.

Wir können auch Muster in Funktionsabschlussparameterlisten (closure parameter
lists) auf die gleiche Weise wie in Funktionsparameterlisten verwenden, da
Funktionsabschlüsse ähnlich wie Funktionen sind, wie in Kapitel 13 besprochen.

An diesem Punkt hast du verschiedene Möglichkeiten der Verwendung von Mustern
gesehen, aber Muster funktionieren nicht an allen Stellen, an denen wir sie
verwenden können, gleich. An manchen Stellen müssen die Muster unabweisbar
(irrefutable) sein, unter anderen Umständen können sie abweisbar (refutable)
sein. Wir werden diese beiden Konzepte als Nächstes besprechen.

[ignoring-values-in-a-pattern]:
ch18-03-pattern-syntax.html#ignorieren-von-werten-in-einem-muster
