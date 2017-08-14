# Iteratoren

Redern wir doch mal über Schleifen.

Erinnerst du dich noch an Rusts `for`-Schleifen?
Hier nochmal zur Erinnerung:

```rust
for x in 0..10 {
    println!("{}", x);
}
```

Nun da du schon etwas mehr Rust kennst können wir ja mal etwas genauer darauf eingehen, wie das so funktioniert.
Ranges (wie `0..10`) sind "Iteratoren".
Ein Iterator ist etwas auf dem man `.next()` aufrufen kann und das uns dann eine Sequenz an Dingen gibt.

So wie in diesem Beispiel:

```rust
let mut range = 0..10;

loop {
    match range.next() {
        Some(x) => {
            println!("{}", x);
        },
        None => { break }
    }
}
```

Hier erstellen wir ein ***mutable binding*** zu einer Range.
Jetzt können wir mit `loop` darüber iterieren.
Das innere `match` entscheidet anhand der Ausgabe von `range.next()` ob wir weitermachen.
`.next()` gibt ein `Option<i32>` aus, also entweder ein `Some(i32)`, dann machen wir weiter, oder ein `None`, dann brechen wir mit `break` ab.

**Nein**, dass musst du nicht jedes mal so machen, dafür gibt es `for`!

`for` ist eigentlich nur syntaktischer Zucker für dieses `loop`/`match`/`break`-Konstrukt.
`for`-Schleifen sind allerdings nicht das einzige was Iteratoren benutzt.
Um seine eigenen Iteratoren verwenden zu können muss man das `Iterator` Trait implementieren.
Wie man das macht liegt etwas außerhalb des Rahmens dieses Kapitels.
Rust bietet eine ganze Reihe nützlicher Iterator für unterschiedliche Aufgaben.
Bevor wir allerdings auf diese genauer eingehen noch ein Anti-Pattern, welches du unbedingt vermeiden solltest. Und zwar solltest du eine Range nicht zum Zählen verwenden, zum Beispiel so:


```rust
let nums = vec![1, 2, 3];

for i in 0..nums.len() {
    println!("{}", nums[i]);
}
```

Das ist zwar möglich, aber unnötig kompliziert, denn Vektoren bringen ihre eigenen Iteratoren mit:

```rust
let nums = vec![1, 2, 3];

for num in &nums {
    println!("{}", num);
}
```

Das ist besser aus zwei Gründen.
Ersten drückt das besser aus worum es hier geht, es ist semantisch sinnvoller.
Und zweitens ist es effizienter und sicherer,
die erste Variante muss extra checken ob die Indexe überhaupt valide sind.
Das ist allgemein der Vorteil von Iteratoren, sie sind auch ohne bound checks sicher.

Es gibt noch eine kleine Unklarheit aufgrund der Tatsache wie `println!` funktioniert.
`num` ist eigentlich ein `&i32`, also nur eine Referenz auf ein `i32`.
`println!` übernimmt hier das Dereferenzieren für uns, wir sehen das also gar nicht.
Dementsprechend funktioniert auch dieser Code hier:

```rust
let nums = vec![1, 2, 3];

for num in &nums {
    println!("{}", *num);
}
```

Hier dereferenzieren wir `num` explizit.
Warum gibt uns `&nums` Referenzen?
Erstens, weil wir explizit mit `&` danach gefragt haben.
Zweitens, wenn es uns die Daten direkt geben würde müssten wir deren Besitzer werden, das heißt es müsste implizit kopieren.
Mit `&` leihen wir nur Referenzen zu den Elementen aus, ohne kopieren oder verschieben zu müssen.

Nun da wir festgestellt haben, dass Ranges nicht das tun was wir wollen,
reden wir mal darüber was wir eigentlich wollen.

Es gibt drei Kategorien von Dingen die hier wichtig sind:
**Iteratoren**, **Iterator-Adapter** und **Konsumenten**.

* *Iteratoren* geben uns eine Sequenz von Werten, einen nach dem anderen.
* *Iterator-Adapter* operieren auf Iteratoren und produzieren andere Iteratoren
* *Konsumenten* nehmen Iteratoren und produzieren daraus finale Werte oder Mengen.

Reden wir als erstes mal über die Konsumenten, da wir ja schon einen Iterator gesehen haben, Ranges.

## Konsumenten

Ein *Konsument* "konsumiert" einen Iterator, das heißt, dass er daraus eine feste  Menge Werte oder einen einzelnen Wert daraus erstellt.
Der gebräuchlichste Konsument ist `collect()`.
Dieser Code hier kompiliert nicht, zeigt aber die Verwendung von `collect()`:

```rust
let one_to_one_hundred = (1..101).collect();
```

Wie du siehst rufen wir `collect()` auf unseren Iterator auf.
`collect()` nimmt so viele Elemente wie ein Iterator ihm gibt und gibt eine Sammlung an Resultaten aus.
Warum kompiliert dieser Code also nicht?
Rust kann hier nicht erkennen, welchen Type die Elemente von `(0..101)` haben.
Die Sammlung muss aber einen Bestimmten Typ haben, also geben wir hier einfach einen an:

```rust
let one_to_one_hundred = (1..101).collect::<Vec<i32>>();
```

Falls du die `::<>` Syntax noch vor Augen hast, sie erlaubt es uns einen Hinweis auf den Typ zu geben, denn eigentlich ist `collect()` als `fn collect<B: FromIterator<Self::Item>>(self)` implementiert.
Mit `_` können wir einen partiellen tipp geben:

```rust
let one_to_one_hundred = (1..101).collect::<Vec<_>>();
```

Das sagt so viel wie "Sammel in einen `Vec<T>`, aber inferiere bitte was `T` für mich."
`_` heißt deshalb manchmal auch "Typeplatzhalter".

Neben `collect()` gibt es auch noch `find()`.

```rust
let greater_than_forty_two = (0..100)
                             .find(|x| *x > 42);

match greater_than_forty_two {
    Some(_) => println!("Found a match!"),
    None => println!("No match found :("),
}
```

`find()` nimmt eine Closure und gibt das erste Elemente zurück, für das die Closure `true` zurückgibt.
`find()` gibt ein `Option<T>` zurück, anstatt dem Element selbst, da es ja auch nichts, `None`, finden könnte.

Ein weiterer Konsument ist `fold()`:

```rust
let sum = (1..4).fold(0, |sum, x| sum + x);
```

`fold(basis, |akkumulator, element| ...)` nimmt zwei Argumente:
Das erste ist ein Element, genannt *Basis*.
Das zweite ist eine Closure, die selbst zwei Argumente annimmt: den *Akkumulator* und ein *Element*.
Bei jeder Iteration wird die Closure aufgerufen und das Resultat ist bei der nächsten Iteration der Akkumulator.
Beim erstenmal ist die Basis noch der Akkumulator.

Verwirrt? Schon klar.

Machen wir das mal an einem Beispiel etwas deutlicher:

| Basis | Akkumulator | Element | Closure Ergebnis |
|-------|-------------|---------|------------------|
| 0     | 0           | 1       | 1                |
| 0     | 1           | 2       | 3                |
| 0     | 3           | 3       | 6                |


```rust
# (1..4)
.fold(0, |sum, x| sum + x);
```

`0` ist unsere Basis hier, `sum` ist unser Akkumulator und `x` das Element.
Beim ersten Mal ist `sum` `0` und `x` ist `1`, das erste Element von `nums`.
Dann addieren wir `sum` und `x`, also `0 + 1 = 1`.
Das Ergebnis ist beim zweiten Mal ist dann der Akkumulator, also `sum` und das nächste Element, `2`, ist nun unser `x`.
`1 + 2 = 3`, und dann ist das wieder `sum`.
Im letzten Durchgang ist `x` nun `3`, also `3 + 3 = 6`, fertig.

`fold()` sieht auf den ersten Blick etwas komisch aus, aber danach siehst du dass du es überall brauchen wirst, immer wenn du eine Liste an Dingen hast, die du zu einem einzigen Ergebnis zusammenfassen musst.

Konsumenten sind vor allem aufgrund einer Eigenschaft von Iteratoren wichtig, die wir noch gar nicht besprochen hatten, Iteratoren sind faul oder "lazy".
Was bedeutet das? Das sehen wir gleich wenn wir über Iteratoren reden.

## Iteratoren

Wie wir bereits festgestellt haben sind Iteratoren etwas auf dem wir wiederholt `.next()` aufrufen können und das uns dann eine Sequenz von Dingen gibt.
Weil du `.next()` aufrufen musst können sich Iteratoren die Arbeit sparen,
alle Elemente im Voraus zu generieren.
Dieser Code hier zum Beispiel generiert nicht wirklich die zahlen von `1` bis `99`, sondern repräsentiert nur Sequenz:

```rust
let nums = 1..100;
```

Da wir mit der Range nicht wirklich irgendwas gemacht haben, hat es auch keine Sequenz generiert.
Wenn wir sie allerdings konsumieren:


```rust
let nums = (1..100).collect::<Vec<i32>>();
```

dann verlangt `collect()` von unserer Range der Reihe nach jede Zahl und somit wird die Sequenz erst erzeugt.

Ranges sind einer von zwei grundlegenden Iteratoren wie wir kennen lernen werden.
Der andere ist `iter()`.
`iter()` macht aus einem `Vector` einen einfachen Iterator der uns jedes Element gibt:

```rust
let nums = vec![1, 2, 3];

for num in nums.iter() {
   println!("{}", num);
}
```

Diese zwei Iteratoren sollten am Anfang reichen, es gibt aber noch fortgeschrittenere Iteratoren, inklusive unendlichen.

Das reicht aber erstmal. Iterator-Adapter sind das letzte Konzept dem wir uns hier widmen wollen. Also...

## Iterator-Adapter

*Iterator-Adapter* nehmen Iteratoren und modifizieren sie um daraus neue Iteratoren zu machen. Der einfachste ist `map`:

```rust,ignore
(1..100).map(|x| x + 1);
```

`map` ruft auf jedes Element eines Iterators eine Closure auf.
Das oben genannte Beispiel gibt uns also `2-100`.
Zumindest fast, wenn du das Beispiel kompilierst bekommst du eine Warnung:

```text
warning: unused result which must be used: iterator adaptors are lazy and
         do nothing unless consumed, #[warn(unused_must_use)] on by default
(1..100).map(|x| x + 1);
 ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
```

Hier schlägt die Faulheit zu!
Die Closure wird nie ausgeführt werden.
Genau wie im nächsten Beispiel, welches **keine** Zahlen ausgibt:

```rust,ignore
(1..100).map(|x| println!("{}", x));
```

Wenn du einen Iterator mit Nebeneffekten verwenden willst, dann nimm lieber `for`.

Es gibt tonnenweise interessante Iterator-Adapter.
`take()` gibt einen Iterator über die nächsten 5 Elemente von dem original Iterator zurück.
Probieren wir das doch mal an einer unendlichen Range aus:

```rust
for i in (1..).take(5) {
    println!("{}", i);
}
```

Hier bekommen wir:

```text
1
2
3
4
5
```

`filter()` ist ein Adapter der eine Closure nimmt, die `true` oder `false` zurück gibt.
Der neue Iterator enthält dann nur Element für die die Closure `true` zurück gegeben hat:

```rust
for i in (1..100).filter(|&x| x % 2 == 0) {
    println!("{}", i);
}
```

Hier kriegen wir alle geraden Zahlen zwischen 1 und hundert.
Wichtig: `filter()` konsumiert die Elemente nicht, es gibt nur Referenzen weiter, deshalb nimmt die Closure auch nur `&x` an.

Du kannst alle drei Sachen hintereinander hängen, angefangen mit einem Iterator als "Quelle" ein paar Adaptern als "Filter" und einem Konsumenten zum Schluss:

```rust
(1..)
    .filter(|&x| x % 2 == 0)
    .filter(|&x| x % 3 == 0)
    .take(5)
    .collect::<Vec<i32>>();
```


Das hier ergibt einen `Vector` der `6`, `12`, `18`, `24` und `30` enthält.

Das ist nur ein kleiner Vorgeschmack darauf was man mit Iteratoren, Iterator-Adaptern und Konsumenten alles tun kann.
Es gibt eine Menge richtig nützlicher Iteratoren und du kannst auch deine eigenen schreiben.
Iteratoren bieten eine sichere und effiziente Methode um all möglichen Listen zu manipulieren.
Am Anfang ist das vielleicht etwas ungewohnt, aber nach einer Weile will man gar nicht mehr zurück.
Eine vollständige Liste aller Iteratoren und Konsumenten lies die [Moduldokumentation](http://doc.rust-lang.org/stable/std/iter/index.html) für Iterator.

