## Das Kontrollflusskonstrukt `match`

Rust verfügt über ein extrem leistungsfähiges Kontrollflusskonstrukt namens
`match`, der es dir ermöglicht, einen Wert mit einer Reihe von Mustern
abzugleichen und dann Code zum jeweils passenden Muster auszuführen. Muster
können sich aus Literalen, Variablennamen, Platzhaltern und vielen anderen
Dingen zusammensetzen. [Kapitel 18][ch18-00-patterns] befasst sich mit all den
verschiedenen Musterarten und wie sie funktionieren. Die Mächtigkeit von
`match` kommt von der Ausdruckskraft der Muster und der Tatsache, dass der
Compiler sicherstellt, dass alle möglichen Fälle behandelt werden.

Stelle dir einen `match`-Ausdruck wie eine Münzsortiermaschine vor:  Die Münzen
rutschen eine Bahn mit unterschiedlich großen Löchern entlang, und jede Münze
fällt durch das erste Loch, in das sie hineinpasst. Auf die gleiche Weise
durchlaufen die Werte die Muster in einem `match`-Ausdruck und beim ersten
„passenden“ Muster fällt der Wert in den zugehörigen Codeblock, der ausgeführt
werden soll.

Apropos Münzen, nehmen wir sie als Beispiel für die Verwendung von `match`! Wir
können eine Funktion schreiben, die eine unbekannte US-Münze nimmt und, ähnlich
wie die Zählmaschine, bestimmt, um welche Münze es sich handelt und ihren Wert
in Cent zurückgibt, wie in Codeblock 6-3 gezeigt.

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
in diesem Fall der Wert `coin` ist. Dies scheint einem bedingten Ausdruck sehr
ähnlich zu sein, der bei `if` verwendet wird, aber es gibt einen großen
Unterschied: Bei `if` muss die Bedingung einen booleschen Wert ergeben, aber
hier kann ein beliebiger Typ zurückgegeben werden. Der Typ von `coin` ist in
diesem Beispiel die Aufzählung `Coin`, die wir in der ersten Zeile definiert
haben.

Als nächstes kommen die `match`-Zweige. Ein Zweig hat zwei Teile: Ein Muster
und etwas Code. Der erste Zweig hat als Muster den Wert `Coin::Penny`, dann den
Operator `=>`, der das Muster und den auszuführenden Code trennt. Der Code ist
in diesem Fall nur der Wert `1`. Jeder Zweig wird durch ein Komma vom nächsten
getrennt.

Wenn der `match`-Ausdruck ausgeführt wird, gleicht er den Ergebniswert mit dem
Muster jedes Zweigs ab, und zwar der Reihe nach. Wenn ein Muster zum Wert
passt, wird der zu diesem Muster gehörende Code ausgeführt. Wenn das Muster
nicht zum Wert passt, wird die Ausführung beim nächsten Zweig fortgesetzt,
ähnlich wie bei einer Münzsortiermaschine. Wir können so viele Zweige haben,
wie wir brauchen: In Codeblock 6-3 hat unser `match`-Ausdruck vier Zweige.

Der zu jedem Zweig gehörende Code ist ein Ausdruck, und der Ergebniswert des
Ausdrucks im zugehörenden Zweig ist der Wert, der für den gesamten
`match`-Ausdruck zurückgegeben wird. 

Wir verwenden üblicherweise keine geschweiften Klammern, wenn der Zweig-Code
kurz ist, so wie in Codeblock 6-3, wo jeder Zweig nur einen Wert zurückgibt.
Wenn du mehrere Codezeilen in einem Zweig ausführen möchtest, musst du
geschweifte Klammern verwenden, und das Komma nach dem Zweig ist dann optional.
Zum Beispiel gibt der folgende Code jedes Mal „Glückspfennig!“ aus, wenn die
Methode mit `Coin::Penny` aufgerufen wird, er gibt aber immer noch den letzten
Wert `1` des Blocks zurück:

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

Stellen wir uns vor, dass ein Freund versucht, 25-Cent-Münzen aller 50
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
Wert `Some(5)` haben. Dann vergleichen wir das mit jedem `match`-Zweig:

```rust,ignore
None => None,
```

Der Wert `Some(5)` passt nicht zum Muster `None`, also fahren wir mit dem
nächsten Zweig fort:

```rust,ignore
Some(i) => Some(i + 1),
```

Passt `Some(5)` zu `Some(i)`? Das tut es! Wir haben die gleiche Variante. `i`
bindet den in `Some` enthaltenen Wert, sodass `i` den Wert `5` annimmt. Dann
wird der Code im `match`-Zweig ausgeführt, also fügen wir 1 zum Wert von `i`
hinzu und erzeugen einen neuen `Some`-Wert mit der Summe `6` darin.

Betrachten wir nun den zweiten Aufruf von `plus_one` in Codeblock 6-5, wo `x`
den Wert `None` hat. Wir betreten den `match`-Block und vergleichen mit dem
ersten Zweig:

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
Sprachen zu haben. Es ist durchweg ein beliebtes Werkzeug.

### Abgleiche sind vollständig

Es gibt noch einen weiteren Aspekt von `match`, den wir besprechen müssen: Die
Muster der Zweige müssen alle Möglichkeiten abdecken. Betrachte folgende
Version unserer Funktion `plus_one`, die einen Fehler hat und sich nicht
kompilieren lässt:

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

For more information about this error, try `rustc --explain E0004`.
error: could not compile `enums` due to previous error
```

Rust weiß, dass wir nicht alle möglichen Fälle abgedeckt haben, und es weiß
sogar, welches Muster wir vergessen haben! Abgleiche in Rust sind
*vollständig*: Wir müssen jede letzte Möglichkeit ausschöpfen, damit der Code
gültig ist! Speziell im Fall `Option<T>` schützt uns Rust davor, den Fall
`None` zu übersehen, und davon auszugehen, dass wir einen Wert haben, obwohl
vielleicht null vorliegt, und macht so den zuvor besprochenen Milliardenfehler
unmöglich.

### Auffangmuster und der Platzhalter `_`

Mit Aufzählungen können wir auch spezielle Aktionen für ausgewählte Werte
durchführen und für alle anderen Werte eine Standardaktion. Stell dir vor, wir
implementieren ein Spiel, bei dem ein Spieler bei einem Würfelwurf von 3 einen
schicken Hut bekommt anstatt sich zu bewegen. Wenn du eine 7 würfelst, verliert
dein Spieler einen schicken Hut. Bei allen anderen Werten zieht der Spieler die
entsprechende Anzahl an Feldern auf dem Spielfeld. Hier ist ein `match`, das
diese Logik implementiert, wobei das Ergebnis des Würfelwurfs anstelle eines
Zufallswerts fest kodiert ist, und alle weitere Logik wird durch Funktionen ohne
Rumpf dargestellt, da die tatsächliche Implementierung für dieses Beispiel den
Rahmen sprengen würde:

```rust
let dice_roll = 9;
match dice_roll {
    3 => add_fancy_hat(),
    7 => remove_fancy_hat(),
    other => move_player(other),
}

fn add_fancy_hat() {}
fn remove_fancy_hat() {}
fn move_player(num_spaces: u8) {}
```

Bei den ersten beiden Zweigen sind die Muster die literalen Werte `3` und `7`.
Beim letzten Zweig, der alle anderen möglichen Werte abdeckt, ist das Muster
die Variable die wir als `other` bezeichnet haben. Der Code, der für den
`other`-Zweig läuft, verwendet die Variable, indem er sie an die Funktion
`move_player` übergibt.

Dieser Code lässt sich kompilieren, auch wenn wir nicht alle möglichen Werte
aufgelistet haben, die ein `u8` haben kann, weil das letzte Muster zu allen
nicht explizit aufgeführten Werte passt. Dieses Auffangmuster (catch-all
pattern) erfüllt die Anforderung, dass `match` vollständig sein muss. Beachte,
dass wir den Auffangzweig an letzter Stelle angeben müssen, da die Muster der
Reihe nach ausgewertet werden. Wenn wir den Auffangzweig früher einfügen
würden, würden die anderen Zweige nie ausgeführt werden, also warnt uns Rust,
wenn wir Zweige nach einem Auffangzweig hinzufügen!

Rust hat auch ein Muster, das wir verwenden können, wenn wir einen Auffangzweig
wollen, aber den Wert im Auffangmuster *nicht* verwenden wollen: `_` ist ein
spezielles Muster, das zu jedem Wert passt und nicht an diesen Wert bindet.
Dies sagt Rust, dass wir den Wert nicht verwenden werden, damit Rust uns nicht
vor einer unbenutzten Variable warnt.

Ändern wir die Spielregeln: Wenn du jetzt etwas anderes als eine 3 oder eine 7
würfelst, musst du erneut würfeln. Wir brauchen den Auffangwert nicht mehr zu
verwenden, also können wir unseren Code so ändern, dass wir `_` anstelle der
Variable namens `other` verwenden:

```rust
let dice_roll = 9;
match dice_roll {
    3 => add_fancy_hat(),
    7 => remove_fancy_hat(),
    _ => reroll(),
}

fn add_fancy_hat() {}
fn remove_fancy_hat() {}
fn reroll() {}
```

Dieses Beispiel erfüllt auch die Bedingung der Vollständigkeit, weil wir
ausdrücklich alle anderen Werte im letzten Zweig ignorieren; wir haben nichts
vergessen.

Zu Schluss ändern wir die Spielregeln noch einmal, sodass bei deinem Zug nichts
anderes passiert, wenn du etwas anderes als eine 3 oder eine 7 würfelst. Wir
können das ausdrücken, indem wir den Einheitswert (den leeren Tupel-Typ, den
wir im Abschnitt [„Der Tupel-Typ“][tuples] erwähnt haben) als Code im `_`-Zweig
angeben:

```rust
let dice_roll = 9;
match dice_roll {
    3 => add_fancy_hat(),
    7 => remove_fancy_hat(),
    _ => (),
}

fn add_fancy_hat() {}
fn remove_fancy_hat() {}
```

Hier teilen wir Rust explizit mit, dass wir keinen anderen Wert verwenden
werden, der nicht mit einem Muster in einem früheren Zweig übereinstimmt, und
dass wir in diesem Fall keinen Code ausführen wollen.

Weitere Informationen zu Mustern und Abgleich findest du in [Kapitel
18][ch18-00-patterns]. Für den Moment machen wir mit der `if let`-Syntax
weiter, die in Situationen nützlich sein kann, in denen der `match`-Ausdruck
etwas wortreich ist.

[ch18-00-patterns]: ch18-00-patterns.html
[tuples]: ch03-02-data-types.html#der-tupel-typ
