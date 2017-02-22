# Schleifen

Rust bietet drei verschiedene Herangehensweisen eine iterative
Tätigkeit auszuführen. Es gibt: `loop`, `while` und `for`.
Jede dieser Herangehensweisen hat seine eigenen Anwendungsfälle.

## loop

Die Endlosschleife `loop` ist die simpelste Schleifenform, die es in Rust gibt.
Mithilfe des `loop` Schlüsselwortes bietet uns Rust einen Weg an für eine
unbestimmte Zeit zu iterieren, bis wir irgendwann eine terminierende Anweisung
erreichen.

```rust
loop {
    println!("Loop forever!");
}
```

## while

Rust hat auch eine `while` Schleife. Sie sieht zum Beispiel so aus:

```rust
let mut x = 5; // mut x: i32
let mut done = false; // mut done: bool

while !done {
    x += x - 3;

    println!("{}", x);

    if x % 5 == 0 {
        done = true;
    }
}
```

`while` Schleifen sind die richtige Wahl, wenn du nicht sicher bist,
wie häufig etwas wiederholt werden muss.

Wenn du eine Endlosschleife benötigst,
dann bist du vielleicht dazu verleitet das hier zu schreiben:

```rust
while true {
```

Es ist jedoch besser in diesem Fall `loop` zu verwenden:

```rust
loop {
```

Rusts Kontrollflussanalyse behandelt diese Konstrukt anders als `while true`,
da es weiß, dass die Schleife endlos ist. Allgemein gilt, je mehr
Informationen wir dem Compiler geben können, umso bessere Sicherheit und
Code-Erzeugung erhalten wir. Deswegen solltest du immer `loop` vorziehen,
falls du planst endlos zu iterieren.

## for

Die `for` Schleife wird benutzt um eine bestimmte Anzahl von Iterationen
auszuführen. Rusts `for` Schleifen arbeiten jedoch ein wenig anders als in
anderen Systemsprachen. Rusts `for` Schleifen sehen *nicht* aus wie "C-Style"
`for` Schleifen:

```c
for (x = 0; x < 10; x++) {
    printf( "%d\n", x );
}
```

Stattdessen sehen sie so aus:

```rust
for x in 0..10 {
    println!("{}", x); // x: i32
}
```

In etwas abstrakteren Begriffen:

```
for var in expression {
    code
}
```

Der Ausdruck ist ein [Iterator][iterator]. Der Iterator gibt eine Reihe von
Elementen zurück. Jedes Element ist eine Iteration der Schleife. Dieses Element
wird an den Namen `var` gebunden, welcher für den Schleifenkörper gültig ist.
Sobald der Körper beendet ist, wird der nächste Wert aus dem Iterator geholt
und der Schleifenkörper damit erneut ausgefürt. Wenn es keine weiteren
Werte mehr gibt, dann ist die `for` Schleife vorbei.

[iterator]: Iteratoren.md

In unserem Beispiel ist `0..10` ein Ausdruck, welche eine Start- und eine
Endposition hat und einen Iterator über diese Werte zurückgibt.
Das obere Ende ist jedoch exklusiv, also gibt unsere Schleife nur
`0` bis `9`, jedoch nicht `10` aus.

Rust hat bewusst keine "C-Style" `for` Schleifen.
Jedes Element der Schleife manuell zu kontrollieren ist kompliziert und
fehleranfällig, sogar für erfahrene C-Entwickler.

### Enumerate

Wenn du gerne wüsstest wie oft du schon iteriert hast, kannst du die
`.enumerate()` Funktion verwenden.

#### Bei `range`s:

```rust
for (i,j) in (5..10).enumerate() {
    println!("i = {} and j = {}", i, j);
}
```

Ausgabe:

```text
i = 0 and j = 5
i = 1 and j = 6
i = 2 and j = 7
i = 3 and j = 8
i = 4 and j = 9
```

Vergiss nicht die Klammern um den `Range`

#### Bei Iteratoren:

```rust
for (linenumber, line) in lines.enumerate() {
    println!("{}: {}", linenumber, line);
}
```

<!-- Original:
# let lines = "hello\nworld".lines();
for (linenumber, line) in lines.enumerate() {
    println!("{}: {}", linenumber, line);
}
-->

Ausgabe:

```text
0: Content of line one
1: Content of line two
2: Content of line three
3: Content of line four
```

## Die Iteration frühzeitig beenden

Lass uns einen Blick auf die `while` Schleife von zuvor werfen:

```rust
let mut x = 5;
let mut done = false;

while !done {
    x += x - 3;

    println!("{}", x);

    if x % 5 == 0 {
        done = true;
    }
}
```

Wir mussten eine boolsche `mut` Variable `done` verwenden um die Schleife
zu beenden. Rust hat zwei Schüsselwörter, die uns helfen eine Iteration zu
modifizieren: `break` und `continue`.

In diesem Fall können wir die Schleife mittels `break` verbessern:

```rust
let mut x = 5;

loop {
    x += x - 3;

    println!("{}", x);

    if x % 5 == 0 { break; }
}
```

Wir iterieren nun endlos und benutzen `break` um frühzeitig aus der Schleife
auszubrechen. Eine explizite `return` Anweisung würde die Schleife ebenso
frühzeitig beenden.

`continue` ist ähnlich, aber anstatt die Schleife zu beenden,
geht man damit zur nächsten Iteration.
Das hier wird nur ungerade Zahlen ausgeben:

```rust
for x in 0..10 {
    if x % 2 == 0 { continue; }

    println!("{}", x);
}
```

## Schleifen Label

Es könnte sein, dass du in bestimmten Situationen verschachtelte Schleifen
hast und festlegen willst für welche dein `break` oder `continue` gelten soll.
Wir bei den meisten anderen Sprache, gelten `break` und `continue`
standardmäßig nur für die innerste Schleife.
Wenn du allerdings `break` oder `continue` auf eine äußere Schleife anwenden
möchtest, dann kannst du Label verwenden um das festzulegen.
Der folgende Code wird nur etwas ausgeben,
wenn sowohl `x` als auch `y` ungerade sind.

```rust
'outer: for x in 0..10 {
    'inner: for y in 0..10 {
        if x % 2 == 0 { continue 'outer; } // continues the loop over x
        if y % 2 == 0 { continue 'inner; } // continues the loop over y
        println!("x: {}, y: {}", x, y);
    }
}
```
