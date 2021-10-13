## Der Kontrollflussoperator `match`

Rust verfügt über einen extrem leistungsfähigen Kontrollflussoperator namens
`match`, der es dir ermöglicht, einen Wert mit einer Reihe von Mustern
abzugleichen und dann Code zum jeweils passenden Muster auszuführen. Muster
können sich aus Literalen, Variablennamen, Platzhaltern und vielen anderen
Dingen zusammensetzen. Kapitel 18 befasst sich mit all den verschiedenen
Musterarten und wie sie funktionieren. Die Mächtigkeit von `match` kommt von
der Ausdruckskraft der Muster und der Tatsache, dass der Compiler
sicherstellt, dass alle möglichen Fälle behandelt werden.

Stelle dir einen `match`-Ausdruck wie eine Münzsortiermaschine vor:  Die Münzen
rutschen eine Bahn mit unterschiedlich großen Löchern entlang, und jede Münze
fällt durch das erste Loch, in das sie hineinpasst. Auf die gleiche Weise
durchlaufen die Werte die Muster in einem `match`-Ausdruck und beim ersten
„passenden“ Muster fällt der Wert in den zugehörigen Codeblock, der ausgeführt
werden soll.

Da wir eben Münzen erwähnt haben, nehmen wir sie als Beispiel für die
Verwendung von `match`! Wir können eine Funktion schreiben, die eine unbekannte
Münze der Vereinigten Staaten nimmt und, ähnlich wie die Zählmaschine,
bestimmt, um welche Münze es sich handelt und ihren Wert in Cent zurückgibt,
wie hier in Codeblock 6-3 gezeigt.

```rust
enum Coin {
    Penny,
    Nickel,
    Dime,
    Quarter,
}

fn value_in_cents(coin: Coin) -> u8 {
    match coin {
        Coin::Penny => 1,
        Coin::Nickel => 5,
        Coin::Dime => 10,
        Coin::Quarter => 25,
    }
}
```

<span class="caption">Codeblock 6-3: Eine Aufzählung und ein `match`-Ausdruck,
der die Varianten der Aufzählung als Muster hat</span>

Lass uns den `match`-Ausdruck in der Funktion `value_in_cents` aufschlüsseln. 
Zuerst geben wir das Schlüsselwort `match` an, gefolgt von einem Ausdruck, der
in diesem Fall der Wert `coin` ist. Dies scheint einem Ausdruck sehr ähnlich zu
sein, der bei `if` verwendet wird, aber es gibt einen großen Unterschied: Bei
`if` muss der Ausdruck einen booleschen Wert zurückgeben, aber hier kann es
sich um einen beliebigen Typ handeln. Der Typ von `coin` ist in diesem Beispiel
die Aufzählung `Coin`, die wir in Zeile 1 definiert haben.

Als nächstes kommen die `match`-Zweige. Ein Zweig hat zwei Teile: Ein Muster
und etwas Code. Der erste Zweig hat als Muster den Wert `Coin::Penny`, dann den
Operator `=>`, der das Muster und den auszuführenden Code trennt. Der Code ist
in diesem Fall nur der Wert `1`. Jeder Zweig wird durch ein Komma vom nächsten
getrennt.

Wenn der `match`-Ausdruck ausgeführt wird, gleicht er den resultierenden Wert
mit dem Muster jedes Zweigs ab, und zwar der Reihe nach. Wenn ein Muster zum
Wert passt, wird der zu diesem Muster gehörende Code ausgeführt. Wenn das
Muster nicht zum Wert passt, wird die Ausführung beim nächsten Zweig
fortgesetzt, ähnlich wie bei einer Münzsortiermaschine. Wir können so viele
Zweige haben, wie wir brauchen: In Codeblock 6-3 hat unser `match`-Ausdruck
vier Zweige.

Der zu jedem Zweig gehörende Code ist ein Ausdruck, und der resultierende Wert
des Ausdrucks im zugehörenden Zweig ist der Wert, der für den gesamten
`match`-Ausdruck zurückgegeben wird. 

Geschweifte Klammern werden in der Regel nicht verwendet, wenn der Zweig-Code
kurz ist, so wie in Codeblock 6-3, wo jeder Zweig nur einen Wert zurückgibt.
Wenn du mehrere Codezeilen in einem Zweig ausführen möchtest, kannst du
geschweifte Klammern verwenden. Zum Beispiel würde der folgende Code jedes Mal
"Glückspfennig!" ausgeben, wenn die Methode mit `Coin::Penny` aufgerufen wird,
aber immer noch als letzten Wert des Blocks `1` zurückgeben:

```rust
# enum Coin {
#     Penny,
#     Nickel,
#     Dime,
#     Quarter,
# }
#
fn value_in_cents(coin: Coin) -> u8 {
    match coin {
        Coin::Penny => {
            println!("Glückspfennig!");
            1
        }
        Coin::Nickel => 5,
        Coin::Dime => 10,
        Coin::Quarter => 25,
    }
}
```

### Muster, die Werte binden

Ein weitere nützliche Funktionalität von `match`-Zweigen ist, dass sie Teile
der Werte binden können, die dem Muster entsprechen. Auf diese Weise können wir
Werte aus Aufzählungsvarianten extrahieren.

Lass uns als Beispiel eine unserer Aufzählungsvarianten so ändern, dass sie
Daten enthält. Von 1999 bis 2008 prägten die Vereinigten Staaten 25-Cent-Münzen
mit unterschiedlichem Aussehen auf einer Seite für jeden der 50 Staaten. Keine
andere Münze hatte ein Staaten-spezifisches Aussehen, sodass nur 25-Cent-Münzen
diese zusätzliche Eigenschaft haben. Wir können diese Information in unserer
Aufzählung unterbringen, indem wir die Variante `Quarter` so ändern, dass sie
einen `UsState`-Wert enthält, wie in Codeblock 6-4 umgesetzt.

```rust
enum UsState {
    Alabama,
    Alaska,
    // --abschneiden--
}

enum Coin {
    Penny,
    Nickel,
    Dime,
    Quarter(UsState),
}
```

<span class="caption">Codeblock 6-4: Aufzählung `Coin`, bei der die Variante
`Quarter` zusätzlich einen `UsState`-Wert enthält</span>

Stellen wir uns vor, dass ein Freund von uns versucht, 25-Cent-Münzen aller 50
Staaten zu sammeln. Während wir unser Kleingeld nach Münzsorten sortieren,
geben wir auch den Namen des Staates der 25-Cent-Münze aus, sodass es unser
Freund in seine Sammlung aufnehmen kann, falls er es nicht hat. Im
`match`-Ausdruck für diesen Code fügen wir zum Muster der Variante
`Coin::Quarter` eine Variable `state` hinzu. Wenn der Zweig für `Coin::Quarter`
passt, wird die Variable `state` an den Wert der Eigenschaft der 25-Cent-Münze
gebunden. Dann können wir `state` im Code für diesen Zweig etwa so verwenden:

```rust
# #[derive(Debug)] // um den Staat mit println! ausgeben zu können
# enum UsState {
#     Alabama,
#     Alaska,
#     // --abschneiden--
# }
#
# enum Coin {
#     Penny,
#     Nickel,
#     Dime,
#     Quarter(UsState),
# }
#
fn value_in_cents(coin: Coin) -> u8 {
    match coin {
        Coin::Penny => 1,
        Coin::Nickel => 5,
        Coin::Dime => 10,
        Coin::Quarter(state) => {
            println!("25-Cent-Münze aus {:?}!", state);
            25
        }
    }
}
#
# fn main() {
#     value_in_cents(Coin::Quarter(UsState::Alaska));
# }
```

Wenn wir `value_in_cents(Coin::Quarter(UsState::Alaska))` aufrufen würden,
hätte `coin` den Wert `Coin::Quarter(UsState::Alaska)`. Gleichen wir den Wert
mit jedem der `match`-Zweige ab, passt keiner von ihnen, bis wir
`Coin::Quarter(state)` erreichen. An diesem Punkt wird `state` an den Wert
`UsState::Alaska` gebunden. Wir können dann diese Bindung im
`println!`-Ausdruck verwenden und so den inneren Zustandswert aus der
`Coin`-Aufzählungsvariante für `Quarter` herausholen.

### Abgleich mit `Option<T>`

Im vorigen Abschnitt wollten wir den inneren `T`-Wert aus dem Fall `Some`
herausholen, als wir `Option<T>` verwendet haben. Wir können `Option<T>` ebenso
mit `match` handhaben, wie wir es mit der Aufzählung `Coin` getan haben! Statt
Münzen zu vergleichen, werden wir die Varianten von `Option<T>` vergleichen,
aber die Art und Weise, wie der `match`-Ausdruck funktioniert, bleibt die
gleiche.

Nehmen wir an, wir wollen eine Funktion schreiben, die eine `Option<i32>` nimmt
und, falls ein Wert darin enthalten ist, zu diesem Wert 1 addiert. Wenn darin
kein Wert enthalten ist, soll die Funktion den Wert `None` zurückgeben und
nicht versuchen, irgendwelche Operationen durchzuführen.

Diese Funktion ist dank `match` sehr einfach zu schreiben und wird wie in
Codeblock 6-5 aussehen.

```rust
fn plus_one(x: Option<i32>) -> Option<i32> {
    match x {
        None => None,
        Some(i) => Some(i + 1),
    }
}

let five = Some(5);
let six = plus_one(five);
let none = plus_one(None);
```

<span class="caption">Codeblock 6-5: Eine Funktion, die einen `match`-Ausdruck
auf einer `Option<i32>` verwendet</span>

Lass uns die erste Ausführung von `plus_one` näher betrachten. Wenn wir
`plus_one(five)` aufrufen, wird die Variable `x` im Rumpf von `plus_one` den
Wert `Some(5)` haben. Dann vergleichen wir das mit jedem `match`-Zweig.

```rust,ignore
None => None,
```

Der Wert `Some(5)` passt nicht zum Muster `None`, also fahren wir mit dem
nächsten Zweig fort.

```rust,ignore
Some(i) => Some(i + 1),
```

Passt `Some(5)` zu `Some(i)`? Aber ja, das tut es! Wir haben die gleiche
Variante. `i` bindet den in `Some` enthaltenen Wert, sodass `i` den Wert `5`
annimmt. Dann wird der Code im `match`-Zweig ausgeführt, also fügen wir 1 zum
Wert von `i` hinzu und erzeugen einen neuen `Some`-Wert mit der Summe `6`
darin.

Betrachten wir nun den zweiten Aufruf von `plus_one` in Codeblock 6-5, wo `x`
den Wert `None` hat. Wir betreten den `match`-Block und vergleichen mit dem
ersten Zweig.

```rust,ignore
None => None,
```

Er passt! Es gibt keinen Wert zum Hinzufügen, also stoppt das Programm und gibt
den Wert `None` auf der rechten Seite von `=>` zurück. Da der erste Zweig
passt, werden keine anderen Zweige abgeglichen.

Die Kombination von `match` und Aufzählungen ist in vielen Situationen
nützlich. Du wirst dieses Muster häufig in Rust-Code sehen: `match` mit einer
Aufzählung, eine Variable an die darin enthaltenen Daten binden und dann
dazugehörenden Code ausführen. Am Anfang ist es etwas knifflig, aber wenn man
sich erst einmal daran gewöhnt hat, wird man sich wünschen, es in allen
Sprachen zu haben. Es ist durchweg ein Benutzerfavorit.

### Abgleiche sind vollständig

Es gibt noch einen weiteren Aspekt von `match`, den wir besprechen müssen.
Betrachte folgende Version unserer Funktion `plus_one`, die einen Fehler hat
und sich nicht kompilieren lässt:

```rust,does_not_compile
fn plus_one(x: Option<i32>) -> Option<i32> {
    match x {
        Some(i) => Some(i + 1),
    }
}

let five = Some(5);
let six = plus_one(five);
let none = plus_one(None);
```

Wir haben den Fall `None` nicht behandelt, daher wird dieser Code einen Fehler
verursachen. Glücklicherweise ist es ein Fehler, von dem Rust weiß, wie er
zu lösen ist. Wenn wir versuchen, diesen Code zu kompilieren, werden wir
diese Fehlermeldung bekommen:

```console
$ cargo run
   Compiling enums v0.1.0 (file:///projects/enums)
error[E0004]: non-exhaustive patterns: `None` not covered
   --> src/main.rs:3:15
    |
3   |         match x {
    |               ^ pattern `None` not covered
    |
    = help: ensure that all possible cases are being handled, possibly by adding wildcards or more match arms
    = note: the matched value is of type `Option<i32>`

error: aborting due to previous error

For more information about this error, try `rustc --explain E0004`.
error: could not compile `enums`

To learn more, run the command again with --verbose.
```

Rust weiß, dass wir nicht alle möglichen Fälle abgedeckt haben, und es weiß
sogar, welches Muster wir vergessen haben! Abgleiche in Rust sind
*vollständig*: Wir müssen jede letzte Möglichkeit ausschöpfen, damit der Code
gültig ist! Speziell im Fall `Option<T>` schützt uns Rust davor, den Fall
`None` zu übersehen, und davon auszugehen, dass wir einen Wert haben, obwohl
vielleicht null vorliegt, und macht so den zuvor besprochenen Milliardenfehler
unmöglich.

### Der Platzhalter `_`

Rust hat auch ein Muster, das wir verwenden können, wenn wir nicht alle möglichen
Werte auflisten wollen. Zum Beispiel kann ein `u8` gültige Werte von 0 bis 255
haben. Wenn wir uns nur um die Werte 1, 3, 5 und 7 kümmern, wollen wir nicht 0,
2, 4, 6, 8, 9 bis hin zu 255 aufzählen müssen. Zum Glück müssen wir das nicht:
Wir können stattdessen das spezielle Muster `_` verwenden:

```rust
let some_u8_value = 0u8;
match some_u8_value {
    1 => println!("eins"),
    3 => println!("drei"),
    5 => println!("fünf"),
    7 => println!("sieben"),
    _ => (),
}
```

Das Muster `_` passt zu jedem Wert. Wenn wir es unter unsere anderen Zweige
setzen, wird `_` auf alle möglichen Fälle passen, die davor nicht angegeben
wurden. `()` ist nur der leere Wert (das leere Tupel, das wir im Abschnitt
[„Der Tupel-Typ“][tuples] erwähnt haben), sodass im Fall `_` nichts passieren
wird. Damit können wir sagen, dass wir für alle möglichen Werte, die wir nicht
vor dem Platzhalter `_` auflisten, nichts tun wollen.

Der `match`-Ausdruck kann jedoch etwas wortreich sein, wenn wir uns nur um
*einen* der Fälle kümmern. Für diesen Fall bietet Rust `if let`.

Mehr über Muster und Abgleich findest du in [Kapitel 18][ch18-00-patterns].

[tuples]: ch03-02-data-types.html#der-tupel-typ
[ch18-00-patterns]: ch18-00-patterns.html
