## Referenzen validieren mit Lebensdauern

Ein Detail, das wir im Abschnitt [„Referenzen und Ausleihen
(borrowing)“][references-and-borrowing] in Kapitel 4 nicht erörtert haben, ist,
dass jede Referenz in Rust eine *Lebensdauer* (lifetime) hat, d.h. einen
Gültigkeitsbereich, in dem diese Referenz gültig ist. In den meisten Fällen
sind Lebensdauern implizit und abgeleitet, ebenso wie in den meisten Fällen
Typen abgeleitet werden. Wir müssen Typen mit Annotationen versehen, wenn
mehrere Typen möglich sind. In ähnlicher Weise müssen wir Lebensdauern
annotieren, wenn die Lebensdauern von Referenzen auf verschiedene Weise
miteinander in Beziehung gesetzt werden könnten. Rust verlangt von uns, die
Beziehungen mit generischen Lebensdauerparametern zu annotieren, um
sicherzustellen, dass die tatsächlich zur Laufzeit verwendeten Referenzen
definitiv gültig sind.

Das Konzept der Lebensdauer unterscheidet sich etwas von Werkzeugen in anderen
Programmiersprachen, was die Lebensdauer wohl zur charakteristischsten
Funktionalität von Rust macht. Auch wenn wir in diesem Kapitel die Lebensdauern
nicht in ihrer Gesamtheit behandeln werden, so werden wir doch allgemeine
Möglichkeiten erörtern, mit denen du dich mit der Syntax der Lebensdauer und
den Konzepten vertraut machen kannst.

### Verhindern hängender Referenzen mit Lebensdauern

Das Hauptziel der Lebensdauer ist es, hängende Referenzen zu verhindern, die
dazu führen, dass ein Programm auf andere Daten referenziert als die, auf die
es referenzieren soll. Betrachte das Programm in Codeblock 10-17, das einen
äußeren und einen inneren Gültigkeitsbereich hat.

```rust,does_not_compile
fn main() {
    {
        let r;

        {
            let x = 5;
            r = &x;
        }

        println!("r: {}", r);
    }
}
```

<span class="caption">Codeblock 10-17: Ein Versuch, eine Referenz zu verwenden,
deren Wert außerhalb des Gültigkeitsbereichs liegt</span>

> Hinweis: Die Beispiele in den Codeblöcken 10-17, 10-18 und 10-24 deklarieren
> Variablen ohne Initialwert, sodass der Variablenname im äußeren
> Gültigkeitsbereich existiert. Auf den ersten Blick mag dies im Widerspruch
> dazu stehen, dass Rust keine Nullwerte hat. Wenn wir jedoch versuchen, eine
> Variable zu verwenden, bevor wir ihr einen Wert geben, erhalten wir einen
> Kompilierfehler, der zeigt, dass Rust tatsächlich keine Nullwerte zulässt.

Der äußere Gültigkeitsbereich deklariert eine Variable `r` ohne Initialwert und
der innere Gültigkeitsbereich deklariert eine Variable `x` mit dem Initialwert
5. Im inneren Gültigkeitsbereich versuchen wir, den Wert von `r` als Referenz
auf `x` zu setzen. Dann endet der innere Gültigkeitsbereich und wir versuchen,
den Wert in `r` auszugeben. Dieser Code lässt sich nicht kompilieren, weil der
Wert, auf den sich `r` bezieht, den Gültigkeitsbereich verlassen hat, bevor wir
versuchen, ihn zu verwenden. Hier ist die Fehlermeldung:

```console
$ cargo run
   Compiling chapter10 v0.1.0 (file:///projects/chapter10)
error[E0597]: `x` does not live long enough
  --> src/main.rs:7:17
   |
7  |             r = &x;
   |                 ^^ borrowed value does not live long enough
8  |         }
   |         - `x` dropped here while still borrowed
9  | 
10 |         println!("r: {}", r);
   |                           - borrow later used here

error: aborting due to previous error

For more information about this error, try `rustc --explain E0597`.
error: could not compile `chapter10`.

To learn more, run the command again with --verbose.
```

Die Variable `x` lebt nicht „lange genug“. Der Grund dafür ist, dass `x` den
Gültigkeitsbereich verlässt, da der innere Gültigkeitsbereich bei Zeile 8
endet. Aber `r` ist im äußeren Gültigkeitsbereich immer noch gültig; da sein
Gültigkeitsbereich größer ist, sagen wir, dass es „länger lebt“. Wenn Rust
diesen Code funktionieren ließe, würde `r` auf Speicher verweisen, der
freigegeben wurde, als `x` den Gültigkeitsbereich verlassen hat, und alles, was
wir mit `r` tun würden, würde nicht korrekt funktionieren. Wie stellt Rust also
fest, dass dieser Code ungültig ist? Es verwendet einen Ausleihenprüfer (borrow
checker).

### Der Ausleihenprüfer

Der Rust-Compiler verfügt über einen *Ausleihenprüfer* (borrow checker), der
Gültigkeitsbereiche vergleicht, um festzustellen, ob alle Ausleihen gültig
sind. Codeblock 10-18 zeigt den gleichen Code wie Codeblock 10-17, jedoch mit
Annotationen, die die Lebensdauer der Variablen angeben.

```rust,does_not_compile
# fn main() {
    {
        let r;                // ---------+-- 'a
                              //          |
        {                     //          |
            let x = 5;        // -+-- 'b  |
            r = &x;           //  |       |
        }                     // -+       |
                              //          |
        println!("r: {}", r); //          |
    }                         // ---------+
# }
```

<span class="caption">Codeblock 10-18: Annotationen der Lebensdauern von `r`
und `x`, genannt `'a` bzw. `'b`</span>

Hier haben wir die Lebensdauer von `r` mit `'a` und die Lebensdauer von `x` mit
`'b` vermerkt. Wie du sehen kannst, ist der innere `'b`-Block viel kleiner als
der äußere `'a`-Lebensdauer-Block. Zur Kompilierzeit vergleicht Rust die Größe
der beiden Lebensdauern und stellt fest, dass `r` eine Lebensdauer von `'a`
hat, jedoch auf einen Speicherbereich mit Lebensdauern `'b` referenziert. Das
Programm wird abgelehnt, weil `'b` kürzer als `'a` ist: Der Referenzinhalt lebt
nicht so lange wie die Referenz selbst.

Mit Codeblock 10-19 wird der Code so korrigiert, dass er keine hängende
Referenz hat und fehlerfrei kompiliert werden kann.

```rust
fn main() {
    {
        let x = 5;            // ----------+-- 'b
                              //           |
        let r = &x;           // --+-- 'a  |
                              //   |       |
        println!("r: {}", r); //   |       |
                              // --+       |
    }                         // ----------+
}
```

<span class="caption">Codeblock 10-19: Eine gültige Referenz, da die Daten eine
längere Lebensdauer als die Referenz haben</span>

Hier hat `x` die Lebensdauer `'b`, die in diesem Fall größer ist als `'a`. Das
bedeutet, dass `r` auf `x` referenzieren kann, weil Rust weiß, dass die
Referenz in `r` immer gültig sein wird, solange `x` gültig ist.

Da du nun weißt, wo die Lebensdauern von Referenzen sind und wie Rust die
Lebensdauer analysiert, um sicherzustellen, dass Referenzen immer gültig sind,
lass uns die generischen Lebensdauern von Parametern und Rückgabewerten im
Kontext von Funktionen untersuchen.

### Generische Lebensdauern in Funktionen

Schreiben wir eine Funktion, die den längeren von zwei
Zeichenkettenanteilstypen zurückgibt. Diese Funktion nimmt zwei
Zeichenkettenanteilstypen entgegen und gibt einen
Zeichenkettenanteilstyp zurück. Nachdem wir die Funktion `longest`
implementiert haben, sollte der Code in Codeblock 10-20 `Die längere
Zeichenkette ist abcd` ausgeben.

<span class="filename">Datei: src/main.rs</span>

```rust,ignore
fn main() {
    let string1 = String::from("abcd");
    let string2 = "xyz";

    let result = longest(string1.as_str(), string2);
    println!("Die längere Zeichenkette ist {}", result);
}
```

<span class="caption">Codeblock 10-20: Eine Funktion `main`, die die Funktion
`longest` aufruft, um die längere von zwei Zeichenkettenanteilstypen zu
bestimmen</span>

Beachte, dass wir wollen, dass die Funktion Zeichenkettenanteilstypen nimmt,
die Referenzen sind, weil wir nicht wollen, dass die Funktion `longest` die
Eigentümerschaft ihrer Parameter übernimmt. Lies den Abschnitt
[„Zeichenkettenanteilstypen als Parameter“][string-slices-as-parameters] in
Kapitel 4, um mehr darüber zu erfahren, warum die Parameter, die wir in
Codeblock 10-20 verwenden, die von uns gewünschten sind.

Wenn wir versuchen, die Funktion `longest`, wie in Codeblock 10-21 gezeigt, zu
implementieren, wird sie sich nicht kompilieren lassen.

<span class="filename">Dateiname: src/main.rs</span>

```rust,does_not_compile
# fn main() {
#     let string1 = String::from("abcd");
#     let string2 = "xyz";
#
#     let result = longest(string1.as_str(), string2);
#     println!("Die längere Zeichenkette ist {}", result);
# }
#
fn longest(x: &str, y: &str) -> &str {
    if x.len() > y.len() {
        x
    } else {
        y
    }
}
```

<span class="caption">Codeblock 10-21: Eine Implementierung der Funktion
`longest`, die die längere von zwei Zeichenkettenanteilstypen zurückgibt, aber
noch nicht kompiliert</span>

Stattdessen erhalten wir folgenden Fehler, der von Lebensdauern spricht:

```console
$ cargo run
   Compiling chapter10 v0.1.0 (file:///projects/chapter10)
error[E0106]: missing lifetime specifier
 --> src/main.rs:9:33
  |
9 | fn longest(x: &str, y: &str) -> &str {
  |                                 ^ expected lifetime parameter
  |
  = help: this function's return type contains a borrowed value, but the signature does not say whether it is borrowed from `x` or `y`

error: aborting due to previous error

For more information about this error, try `rustc --explain E0106`.
error: could not compile `chapter10`.

To learn more, run the command again with --verbose.
```

Aus dem Hilfetext geht hervor, dass der Rückgabetyp einen generischen
Lebensdauer-Parameter benötigt, da Rust nicht sagen kann, ob sich die
zurückgegebene Referenz auf `x` oder auf `y` bezieht. Eigentlich wissen wir es
auch nicht, weil der `if`-Zweig im Funktionsrumpf eine Referenz auf `x` und der
`else`-Zweig eine Referenz auf `y` zurückgibt!

Wenn wir diese Funktion definieren, kennen wir die konkreten Werte nicht, die
an diese Funktion übergeben werden, also wissen wir nicht, ob der `if`-Zweig
oder der `else`-Zweig ausgeführt wird. Wir kennen auch nicht die konkreten
Lebensdauern der Referenzen, die weitergegeben werden, sodass wir nicht wie in
den Codeblöcken 10-18 und 10-19 die Gültigkeitsbereiche betrachten können, um
festzustellen, ob die von uns zurückgegebene Referenz immer gültig sein wird.
Der Ausleihenprüfer kann dies auch nicht feststellen, weil er nicht weiß, wie
die Lebensdauer von `x` und `y` mit der Lebensdauer des Rückgabewertes
zusammenhängt. Um diesen Fehler zu beheben, geben wir generische
Lebensdauerparameter an, die die Beziehung zwischen den Referenzen definieren,
damit der Ausleihenprüfer seine Analyse durchführen kann.

### Lebensdauer-Annotationssyntax

Lebensdauer-Annotationen ändern nichts daran, wie lange eine Referenz lebt.
Genauso wie Funktionen jeden Typ entgegennehmen können, wenn die Signatur einen
generischen Typparameter angibt, können Funktionen Referenzen mit beliebiger
Lebensdauer akzeptieren, indem sie einen generischen Lebensdauerparameter
angeben. Lebensdauer-Annotationen beschreiben die Beziehungen der Lebensdauern
mehrerer Referenzen zueinander, ohne die Lebensdauern zu beeinflussen.

Lebensdauer-Annotationen haben eine etwas ungewöhnliche Syntax: Die Namen der
Lebensdauer-Parameter müssen mit einem Apostroph (`'`) beginnen und sind
normalerweise kleingeschrieben und sehr kurz, wie generische Typen. Die meisten
Menschen verwenden den Namen `'a`. Wir platzieren
Lebensdauer-Parameter-Annotationen hinter dem `&` einer Referenz, wobei wir ein
Leerzeichen verwenden, um die Annotation vom Typ der Referenz zu trennen.

Hier sind einige Beispiele: Eine Referenz auf einen `i32` ohne
Lebensdauer-Parameter, eine Referenz auf einen `i32`, die einen
Lebensdauer-Parameter namens `'a` hat, und eine veränderlicher Referenz auf
einen `i32`, die ebenfalls die Lebensdauer `'a` hat.

```rust,ignore
&i32        // eine Referenz
&'a i32     // eine Referenz mit expliziter Lebensdauer
&'a mut i32 // eine veränderliche Referenz mit expliziter Lebensdauer
```

Eine Lebensdauer-Annotation an sich hat nicht viel Bedeutung, da die
Annotationen Rust mitteilen sollen, wie sich generische
Lebensdauer-Parameter mehrerer Referenzen zueinander verhalten. Nehmen wir zum
Beispiel an, wir haben eine Funktion mit dem Parameter `first`, die eine
Referenz auf einen `i32` mit Lebensdauer `'a` ist. Die Funktion hat noch einen
weiteren Parameter namens `second`, der eine weitere Referenz auf einen `i32`
ist, die ebenfalls die Lebensdauer `'a` hat. Die Lebensdauer-Annotationen
weisen darauf hin, dass die Referenzen `first` und `second` beide so lange
leben müssen wie diese generische Lebensdauer.

### Lebensdauer-Annotationen in Funktionssignaturen

Lass uns nun Lebensdauer-Annotationen im Kontext der Funktion `longest`
untersuchen. Wie bei generischen Typparametern müssen wir generische
Lebensdauerparameter innerhalb spitzer Klammern zwischen dem Funktionsnamen und
der Parameterliste deklarieren. Die Beschränkung, die wir mit dieser Signatur
zum Ausdruck bringen wollen, besteht darin, dass alle Referenzen in den
Parametern und dem Rückgabewert die gleiche Lebensdauer haben müssen. Wir
nennen die Lebensdauer `'a` und fügen sie dann jeder Referenz hinzu, wie in
Codeblock 10-22 gezeigt.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# fn main() {
#     let string1 = String::from("abcd");
#     let string2 = "xyz";
#
#     let result = longest(string1.as_str(), string2);
#     println!("Die längere Zeichenkette ist {}", result);
# }
#
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() {
        x
    } else {
        y
    }
}
```

<span class="caption">Codeblock 10-22: Die Funktionsdefinition `longest` gibt
an, dass alle Referenzen in der Signatur die gleiche Lebensdauer `'a` haben
müssen</span>

Die Funktionssignatur sagt Rust, dass die Funktion für eine gewisse Lebensdauer
`'a` zwei Parameter benötigt, die beide den Zeichenkettenanteilstyp haben und
mindestens so lange leben wie die Lebensdauer `'a`. Die Funktionssignatur sagt
Rust auch, dass der von der Funktion zurückgegebene Zeichenkettenanteilstyp
mindestens so lange leben wird wie die Lebensdauer `'a`. In der Praxis bedeutet
dies, dass die Lebensdauer der von der Funktion `longest` zurückgegebenen
Referenz identisch mit der kürzeren der Lebensdauern der entgegengenommenen
Referenzen ist. Diese Bedingung wollen wir durch Rust sicherstellen lassen.
Denke daran, indem wir die Lebensdauerparameter in dieser Funktionssignatur
angeben, ändern wir nicht die Lebensdauer der übergebenen oder zurückgegebenen
Werte. Vielmehr legen wir fest, dass der Ausleihenprüfer alle Werte ablehnen
soll, die sich nicht an diese Bedingung halten. Beachte, dass die Funktion
`longest` nicht genau wissen muss, wie lange `x` und `y` leben werden, nur dass
ein gewisser Gültigkeitsbereich für `'a` eingesetzt werden kann, der dieser
Signatur genügt.

Wenn Funktionen mit Lebensdauern annotiert werden, gehören die Annotationen zur
Funktionssignatur, nicht zum Funktionsrumpf. Rust kann den Code innerhalb der
Funktion ohne jede Hilfe analysieren. Wenn eine Funktion jedoch Referenzen auf
oder von Code außerhalb dieser Funktion hat, wird es für Rust fast unmöglich,
die Lebensdauer der Parameter oder Rückgabewerte allein herauszufinden. Die
Lebensdauer kann bei jedem Aufruf der Funktion unterschiedlich sein. Aus diesem
Grund müssen wir die Lebensdauern manuell angeben.

Wenn wir der Funktion `longest` konkrete Referenzen übergeben, ist die konkrete
Lebensdauer, die an die Stelle von `'a` tritt, der Teil des Gültigkeitsbereichs
von `x`, der sich mit dem Gültigkeitsbereich von `y` überschneidet. Mit anderen
Worten bekommt die generische Lebensdauer `'a` die konkrete Lebensdauer, die
der kürzeren der Lebensdauern von `x` und `y` entspricht. Da wir die
zurückgegebene Referenz mit dem gleichen Lebensdauer-Parameter `'a` annotiert
haben, wird die zurückgegebene Referenz auch für die Dauer der kürzeren
Lebensdauer von `x` und `y` gültig sein.

Schauen wir uns an, wie die Lebensdauer-Annotationen die Funktion `longest`
beschränken, indem wir Referenzen mit unterschiedlichen konkreten Lebensdauern
übergeben. Codeblock 10-23 ist ein einfaches Beispiel.

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let string1 = String::from("lange Zeichenkette ist lang");

    {
        let string2 = String::from("xyz");
        let result = longest(string1.as_str(), string2.as_str());
        println!("Die längere Zeichenkette ist {}", result);
    }
}
#
# fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
#     if x.len() > y.len() {
#         x
#     } else {
#         y
#     }
# }
```

<span class="caption">Codeblock 10-23: Verwenden der Funktion `longest` mit
Referenzen auf Zeichenketten, die unterschiedliche konkrete Lebensdauern
haben</span>

In diesem Beispiel ist `string1` bis zum Ende des äußeren Gültigkeitsbereichs
gültig, `string2` ist bis zum Ende des inneren Gültigkeitsbereichs gültig, und
`result` referenziert auf etwas, das bis zum Ende des inneren
Gültigkeitsbereichs gültig ist. Führe diesen Code aus und du wirst sehen, dass
der Ausleihenprüfer diesen Code akzeptiert; er kompiliert und gibt `Die längere
Zeichenkette ist lange Zeichenkette ist lang`.

Versuchen wir als nächstes ein Beispiel, das zeigt, dass die Lebensdauer der
Referenz in `result` die kürzere Lebensdauer der beiden Argumente sein muss. 
Wir verschieben die Deklaration der Variable `result` oberhalb des inneren
Gültigkeitsbereichs, lassen aber die Zuweisung des Wertes an die Variable
`result` innerhalb des Gültigkeitsbereichs mit `string2`. Dann verschieben wir
`println!`, das `result` verwendet, unterhalb des inneren Gültigkeitsbereichs.
Der Code in Codeblock 10-24 lässt sich nicht kompilieren.

<span class="filename">Dateiname: src/main.rs</span>

```rust,does_not_compile
fn main() {
    let string1 = String::from("lange Zeichenkette ist lang");
    let result;
    {
        let string2 = String::from("xyz");
        result = longest(string1.as_str(), string2.as_str());
    }
    println!("Die längere Zeichenkette ist {}", result);
}
#
# fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
#     if x.len() > y.len() {
#         x
#     } else {
#         y
#     }
# }
```

<span class="caption">Codeblock 10-24: Der Versuch, `result` zu verwenden,
nachdem `string2` den Gültigkeitsbereich verlassen hat</span>

Wenn wir versuchen, diesen Code zu kompilieren, erhalten wir folgenden Fehler:

```console
$ cargo run
   Compiling chapter10 v0.1.0 (file:///projects/chapter10)
error[E0597]: `string2` does not live long enough
 --> src/main.rs:6:44
  |
6 |         result = longest(string1.as_str(), string2.as_str());
  |                                            ^^^^^^^ borrowed value does not live long enough
7 |     }
  |     - `string2` dropped here while still borrowed
8 |     println!("Die längere Zeichenkette ist {}", result);
  |                                                 ------ borrow later used here

error: aborting due to previous error

For more information about this error, try `rustc --explain E0597`.
error: could not compile `chapter10`.

To learn more, run the command again with --verbose.
```

Der Fehler zeigt, dass `string2` bis zum Ende des äußeren Gültigkeitsbereichs
gültig sein müsste, damit `result` in der Anweisung `println!` noch gültig ist. 
Rust weiß das, weil wir die Lebensdauer der Funktionsparameter und
Rückgabewerte mit dem gleichen Lebensdauerparameter `'a` annotiert haben.

Als Menschen können wir uns diesen Code ansehen und erkennen, dass `string1`
länger als `string2` ist und deshalb wird `result` eine Referenz auf `string1`
enthalten. Da `string1` den Gültigkeitsbereich noch nicht verlassen hat, wird
eine Referenz auf `string1` in der `println!`-Anweisung noch gültig sein. Der
Compiler kann jedoch nicht sehen, dass die Referenz in diesem Fall gültig
ist. Wir haben Rust gesagt, dass die Lebensdauer der Referenz, die von der
Funktion `longest` zurückgegeben wird, die gleiche ist wie die kürzere der
Lebensdauern der entgegengenommenen Referenzen. Daher lehnt der Ausleihenprüfer
den Code in Codeblock 10-24 als möglicherweise ungültige Referenz ab.

Versuche, dir weitere Experimente auszudenken, die die Werte und die
Lebensdauern der an die Funktion `longest` übergebenen Referenzen variieren und
wie die zurückgegebene Referenz verwendet wird. Stelle Hypothesen darüber auf,
ob deine Experimente den Ausleihenprüfer bestehen oder nicht, bevor du
kompilierst; prüfe dann, ob du Recht hast!

### Denken in Lebensdauern

Die Art und Weise, in der du Lebensdauerparameter angeben musst, hängt davon
ab, was deine Funktion tut. Wenn wir zum Beispiel die Implementierung der
Funktion `longest` so ändern würden, dass sie immer den ersten Parameter
zurückgibt und nicht den längsten Zeichenkettenanteilstyp, bräuchten wir keine
Lebensdauer für den Parameter `y` anzugeben. Der folgende Code wird
kompilieren:

<span class="filename">Dateiname: src/main.rs</span>

```rust
# fn main() {
#     let string1 = String::from("abcd");
#     let string2 = "efghijklmnopqrstuvwxyz";
#
#     let result = longest(string1.as_str(), string2);
#     println!("Die längere Zeichenkette ist {}", result);
# }
#
fn longest<'a>(x: &'a str, y: &str) -> &'a str {
    x
}
```

In diesem Beispiel haben wir einen Lebensdauer-Parameter `'a` für den Parameter
`x` und den Rückgabetyp angegeben, aber nicht für den Parameter `y`, weil die
Lebensdauer von `y` in keiner Beziehung zur Lebensdauer von `x` oder dem
Rückgabewert steht.

Wenn eine Funktion eine Referenz zurückgibt, muss der Lebensdauerparameter für
den Rückgabetyp mit dem Lebensdauerparameter für einen der Parameter
übereinstimmen. Wenn sich die zurückgegebene Referenz *nicht* auf einen der
Parameter bezieht, muss er sich auf einen innerhalb dieser Funktion erzeugten
Wert beziehen, was eine hängende Referenz wäre, da der Wert am Ende der
Funktion den Gültigkeitsbereich verlässt. Betrachte diesen Versuch einer
Implementierung der Funktion `longest`, die sich nicht kompilieren lässt:

<span class="filename">Dateiname: src/main.rs</span>

```rust,does_not_compile
# fn main() {
#     let string1 = String::from("abcd");
#     let string2 = "xyz";
#
#     let result = longest(string1.as_str(), string2);
#     println!("Die längere Zeichenkette ist {}", result);
# }
#
fn longest<'a>(x: &str, y: &str) -> &'a str {
    let result = String::from("wirklich lange Zeichenkette");
    result.as_str()
}
```

Auch wenn wir hier einen Lebensdauer-Parameter `'a` für den Rückgabetyp
angegeben haben, wird diese Implementierung nicht kompilieren, weil die
Lebensdauer des Rückgabewerts überhaupt nicht mit der Lebensdauer der Parameter
zusammenhängt. Hier ist die Fehlermeldung, die wir erhalten:

```console
$ cargo run
   Compiling chapter10 v0.1.0 (file:///projects/chapter10)
error[E0515]: cannot return value referencing local variable `result`
  --> src/main.rs:11:5
   |
11 |     result.as_str()
   |     ------^^^^^^^^^
   |     |
   |     returns a value referencing data owned by the current function
   |     `result` is borrowed here

error: aborting due to previous error

For more information about this error, try `rustc --explain E0515`.
error: could not compile `chapter10`.

To learn more, run the command again with --verbose.
```

Das Problem ist, dass `result` den Gültigkeitsbereich verlässt und am Ende der
Funktion `longest` aufgeräumt wird. Wir versuchen auch, eine Referenz auf den
Wert in `result` zurückzugeben. Es gibt keine Möglichkeit, Lebensdauerparameter
so anzugeben, dass die hängende Referenz beseitigt wird, Rust lässt uns also
keine hängende Referenz erstellen. In diesem Fall wäre die beste Lösung, einen
eigenen Datentyp statt einer Referenz zurückzugeben, sodass die aufrufende
Funktion dann für das Aufräumen des Wertes verantwortlich ist.

Letztlich geht es bei der Lebensdauersyntax darum, die Lebensdauern
verschiedener Parameter und Rückgabewerte von Funktionen miteinander zu
verbinden. Sobald sie verbunden sind, verfügt Rust über genügend Informationen,
um speichersichere Operationen zu ermöglichen und Operationen zu unterbinden,
die hängende Zeiger erzeugen oder anderweitig die Speichersicherheit verletzen
würden.

### Lebensdauer-Annotationen in Struktur-Definitionen

Bisher haben wir nur Strukturen (structs) definiert, die aneigenbare Typen
enthalten. Es ist möglich, dass Strukturen Referenzen enthalten, aber in diesem
Fall müssten wir Lebensdauer-Annotationen zu jeder Referenz in der
Strukturdefinition angeben. Codeblock 10-25 hat eine Struktur namens
`ImportantExcerpt`, die einen Zeichenkettenanteilstyp enthält.

<span class="filename">Dateiname: src/main.rs</span>

```rust
struct ImportantExcerpt<'a> {
    part: &'a str,
}

fn main() {
    let novel = String::from("Nennen Sie mich Ishmael. Vor einigen Jahren ...");
    let first_sentence = novel.split('.').next().expect("Konnte keinen '.' finden.");
    let i = ImportantExcerpt {
        part: first_sentence,
    };
}
```

<span class="caption">Codeblock 10-25: Eine Struktur, die eine Referenz
enthält, sodass ihre Definition eine Lebensdauer-Annotationen benötigt</span>

Diese Struktur hat ein Feld `part`, das einen Zeichenkettenanteilstyp enthält,
der eine Referenz ist. Wie bei generischen Datentypen deklarieren wir den Namen
des generischen Lebensdauerparameters innerhalb spitzer Klammern hinter dem
Strukturnamen, damit wir den Lebensdauerparameter im Rumpf der
Strukturdefinition verwenden können. Diese Annotation bedeutet, dass eine
Instanz von `ImportantExcerpt` die Referenz, die sie in ihrem Feld `part`
enthält, nicht überleben kann.

Die Funktion `main` erzeugt hier eine Instanz der Struktur `ImportantExcerpt`,
die eine Referenz auf den ersten Satz des `String` enthält, der der Variablen
`novel` gehört. Die Daten in `novel` existieren, bevor die Instanz
`ImportantExcerpt` erzeugt wird. Darüber hinaus verlässt `novel` den
Gültigkeitsbereich erst, nachdem `ImportantExcerpt` den Gültigkeitsbereich
verlassen hat, sodass die Referenz in der `ImportantExcerpt`-Instanz gültig
ist.

### Lebensdauer-Elision

Du hast gelernt, dass jede Referenz eine Lebensdauer hat und dass du
Lebensdauerparameter für Funktionen oder Strukturen angeben musst, die
Referenzen verwenden. In Kapitel 4 hatten wir jedoch eine Funktion in Codeblock
4-9, die wiederum in Codeblock 10-26 gezeigt wird, die ohne
Lebensdauer-Annotationen kompiliert.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
fn first_word(s: &str) -> &str {
    let bytes = s.as_bytes();

    for (i, &item) in bytes.iter().enumerate() {
        if item == b' ' {
            return &s[0..i];
        }
    }

    &s[..]
}
#
# fn main() {
#     let my_string = String::from("Hallo Welt");
#
#     // first_word funktioniert mit Anteilstypen von `String`
#     let word = first_word(&my_string[..]);
#
#     let my_string_literal = "Hallo Welt";
#
#     // first_word funktioniert mit Anteilstypen von Zeichenkettenliteralen
#     let word = first_word(&my_string_literal[..]);
#
#     // Da Zeichenkettenliterale bereits Zeichenkettenanteilstypen sind,
#     // funktioniert dies auch ohne die Anteilstypensyntax!
#     let word = first_word(my_string_literal);
# }
```

<span class="caption">Codeblock 10-26: Eine Funktion, die wir in Codeblock 4-9
definiert haben und die ohne Lebensdauer-Annotationen kompiliert, obwohl
Parameter und Rückgabetyp Referenzen sind</span>

Der Grund, warum diese Funktion ohne Lebensdauer-Annotationen kompiliert, ist
historisch bedingt: In frühen Versionen (vor 1.0) von Rust hätte sich dieser
Code nicht kompilieren lassen, da jede Referenz eine explizite Lebensdauer
benötigte. Damals wäre die Funktionssignatur so geschrieben worden:

```rust,ignore
fn first_word<'a>(s: &'a str) -> &'a str {
```

Nachdem jede Menge Rust-Code geschrieben wurde, stellte das Rust-Team fest,
dass die Rust-Programmierer in bestimmten Situationen immer wieder die gleichen
Lebensdauer-Annotationen angaben. Diese Situationen waren vorhersehbar und
folgten einigen wenigen deterministischen Mustern. Die Entwickler
programmierten diese Muster in den Code des Compilers, sodass der
Ausleihenprüfer in diesen Situationen auf die Lebensdauer schließen konnte und
keine expliziten Annotationen benötigte.

Dieses Stück Rust-Geschichte ist relevant, weil es möglich ist, dass weitere
deterministische Muster auftauchen und dem Compiler hinzugefügt werden. In
Zukunft könnten noch weniger Lebensdauer-Annotationen erforderlich sein.

Die Muster, die in Rusts Referenzanalyse programmiert sind, werden die
*Lebensdauer-Elisionsregeln* (lifetime elision rules) genannt. Dies sind keine
Regeln, die Programmierer befolgen müssen; es handelt sich um eine Reihe
besonderer Fälle, die der Compiler berücksichtigt, und wenn dein Code zu
einem dieser Fälle passt, brauchst du die Lebensdauer nicht explizit anzugeben.

Die Elisionsregeln bieten keine vollständige Schlussfolgerung. Wenn Rust die
Regeln deterministisch anwendet, aber immer noch Unklarheit darüber besteht,
welche Lebensdauer die Referenzen haben, wird der Compiler nicht erraten,
wie lang die Lebensdauer der verbleibenden Referenzen sein sollte. In diesem
Fall gibt dir der Compiler statt einer Vermutung einen Fehler an, den du
beheben kannst, indem du die Lebensdauer-Annotationen angibst, die festlegen,
wie sich die Referenzen zueinander verhalten.

Die Lebensdauern der Funktions- oder Methodenparameter werden als
*Eingangslebensdauern* (input lifetimes) bezeichnet, und die Lebensdauern der
Rückgabewerte als *Ausgangslebensdauern* (output lifetimes) bezeichnet.

Der Compiler verwendet drei Regeln, um herauszufinden, welche Lebensdauer
Referenzen haben, wenn keine expliziten Annotationen vorhanden sind. Die erste
Regel gilt für Eingangslebensdauern und die zweite und dritte Regel gelten für
Ausgangslebensdauern. Wenn der Compiler das Ende der drei Regeln erreicht
und es immer noch Referenzen gibt, für die er keine Lebensdauern ermitteln
kann, bricht der Compiler mit einem Fehler ab. Diese Regeln gelten sowohl
für `fn`-Definitionen als auch für `impl`-Blöcke.

Die erste Regel ist, dass jeder Parameter, der eine Referenz ist, seinen
eigenen Lebensdauerparameter erhält. Mit anderen Worten, eine Funktion mit
einem Parameter erhält einen Lebensdauerparameter: `fn foo<'a>(x: &'a i32)`;
eine Funktion mit zwei Parametern erhält zwei separate Lebensdauerparameter:
`fn foo<'a, 'b>(x: &'a i32, y: &'b i32)`; und so weiter.

Die zweite Regel lautet: Wenn es genau einen Eingangslebensdauer-Parameter
gibt, wird diese Lebensdauer allen Ausgangslebensdauer-Parametern zugewiesen:
`fn foo<'a>(x: &'a i32) -> &'a i32`.

Die dritte Regel lautet: Wenn es mehrere Eingangslebensdauer-Parameter gibt,
aber einer davon `&self` oder `&mut self` ist, weil dies eine Methode ist, wird
die Lebensdauer von `self` allen Ausgangslebensdauer-Parametern zugewiesen.
Diese dritte Regel macht Methoden viel angenehmer zu lesen und zu schreiben,
weil weniger Symbole erforderlich sind.

Tun wir so, als wären wir der Compiler. Wir werden diese Regeln anwenden, um
herauszufinden, wie lang die Lebensdauer der Referenzen in der Signatur der
Funktion `first_word` in Codeblock 10-26 ist. Die Signatur beginnt ohne
Lebensdauern:

```rust,ignore
fn first_word(s: &str) -> &str {
```

Dann wendet der Compiler die erste Regel an, die festlegt, dass jeder
Parameter seine eigene Lebensdauer erhält. Wir nennen sie wie üblich `'a`, also
sieht die Signatur jetzt so aus:

```rust,ignore
fn first_word<'a>(s: &'a str) -> &str {
```

Die zweite Regel trifft zu, weil es genau eine Eingangslebensdauer gibt. Die
zweite Regel legt fest, dass die Lebensdauer des einen Eingabeparameters der
Ausgangslebensdauer zugeordnet wird, sodass die Signatur nun wie folgt
aussieht:

```rust,ignore
fn first_word<'a>(s: &'a str) -> &'a str {
```

Jetzt haben alle Referenzen in dieser Funktionssignatur eine Lebensdauer und
der Compiler kann seine Analyse fortsetzen, ohne dass der Programmierer die
Lebensdauer in dieser Funktionssignatur annotieren muss.

Schauen wir uns ein anderes Beispiel an, diesmal mit der Funktion `longest`,
die keine Lebensdauerparameter hatte, als wir in Codeblock 10-21 mit ihr zu
arbeiten begannen:

```rust,ignore
fn longest(x: &str, y: &str) -> &str {
```

Wenden wir die erste Regel an: Jeder Parameter erhält seine eigene Lebensdauer.
Diesmal haben wir zwei Parameter anstelle von einem, also haben wir zwei
Lebensdauern:

```rust,ignore
fn longest<'a, 'b>(x: &'a str, y: &'b str) -> &str {
```

Du siehst, dass die zweite Regel nicht gilt, weil es mehr als eine
Eingangslebensdauer gibt. Auch die dritte Regel trifft nicht zu, weil `longest`
eine Funktion ist, keine Methode, sodass keiner der Parameter `self` ist.
Nachdem wir alle drei Regeln durchgearbeitet haben, haben wir immer noch nicht
herausgefunden, wie lang die Lebensdauer des Rückgabetyps ist. Aus diesem Grund
haben wir beim Versuch, den Code in Codeblock 10-21 zu kompilieren, einen
Fehler erhalten: Der Compiler arbeitete die Lebensdauer-Elisionsregeln
durch, konnte aber immer noch nicht alle Lebensdauern der Referenzen in der
Signatur ermitteln.

Da die dritte Regel eigentlich nur für Methodensignaturen gilt, werden wir uns
als nächstes die Lebensdauern in diesem Zusammenhang ansehen, um zu sehen,
warum die dritte Regel bedeutet, dass wir die Lebensdauer in Methodensignaturen
nicht sehr oft annotieren müssen.

### Lebensdauer-Annotationen in Methodendefinitionen

Wenn wir Methoden auf einer Struktur mit Lebensdauer implementieren, verwenden
wir die gleiche Syntax wie die in Codeblock 10-11 gezeigten generischen
Typparameter. Wo wir die Lebensdauerparameter deklarieren und verwenden, hängt
davon ab, ob sie sich auf die Strukturfelder oder auf die Methodenparameter und
Rückgabewerte beziehen.

Lebensdauer-Namen für Struktur-Felder müssen immer nach dem
`impl`-Schlüsselwort deklariert und dann hinter dem Namen der Struktur verwendet
werden, da diese Lebensdauern Teil des Typs der Struktur sind.

In Methodensignaturen innerhalb des `impl`-Blocks können Referenzen an die
Lebensdauern der Referenzen in den Feldern der Struktur gebunden sein oder sie
können unabhängig sein. Darüber hinaus sorgen die Lebensdauer-Elisionsregeln
oft dafür, dass Lebensdauer-Annotationen in Methodensignaturen nicht
erforderlich sind. Betrachten wir einige Beispiele mit der Struktur
`ImportantExcerpt` an, die wir in Codeblock 10-25 definiert haben.

Zuerst werden wir eine Methode namens `level` verwenden, deren einziger
Parameter eine Referenz auf `self` ist und deren Rückgabewert ein `i32` ist,
was keine Referenz ist:

```rust
# struct ImportantExcerpt<'a> {
#     part: &'a str,
# }
#
impl<'a> ImportantExcerpt<'a> {
    fn level(&self) -> i32 {
        3
    }
}
#
# impl<'a> ImportantExcerpt<'a> {
#     fn announce_and_return_part(&self, announcement: &str) -> &str {
#         println!("Bitte um Aufmerksamkeit: {}", announcement);
#         self.part
#     }
# }
#
# fn main() {
#     let novel = String::from("Nennen Sie mich Ishmael. Vor einigen Jahren ...");
#     let first_sentence = novel.split('.').next().expect("Konnte keinen '.' finden.");
#     let i = ImportantExcerpt {
#         part: first_sentence,
#     };
# }
```

Die Lebensdauer-Parameter-Deklaration nach `impl` und ihre Verwendung hinter dem
Typnamen sind erforderlich, aber wir sind nicht verpflichtet, die Lebensdauer der
Referenz auf `self` wegen der ersten Elisionsregel zu annotieren.

Hier ist ein Beispiel, bei dem die dritte Lebensdauer-Elisionsregel gilt:

```rust
# struct ImportantExcerpt<'a> {
#     part: &'a str,
# }
#
# impl<'a> ImportantExcerpt<'a> {
#     fn level(&self) -> i32 {
#         3
#     }
# }
#
impl<'a> ImportantExcerpt<'a> {
    fn announce_and_return_part(&self, announcement: &str) -> &str {
        println!("Bitte um Aufmerksamkeit: {}", announcement);
        self.part
    }
}
#
# fn main() {
#     let novel = String::from("Nennen Sie mich Ishmael. Vor einigen Jahren ...");
#     let first_sentence = novel.split('.').next().expect("Konnte keinen '.' finden.");
#     let i = ImportantExcerpt {
#         part: first_sentence,
#     };
# }
```

Es gibt zwei Eingangslebensdauern, sodass Rust die erste
Lebensdauer-Elisionsregel anwendet und sowohl `&self` als auch `announcement`
ihre eigene Lebensdauer gibt. Da einer der Parameter `&self` ist, erhält der
Rückgabetyp die Lebensdauer von `&self`, und alle Lebensdauern sind
berücksichtigt worden.

### Statische Lebensdauer

Eine besondere Lebensdauer, die wir besprechen müssen, ist `'static`, was
bedeutet, dass diese Referenz während der gesamten Dauer des Programms leben
kann. Alle Zeichenkettenliterale haben die Lebensdauer `'static`, die wir wie
folgt annotieren können:

```rust
let s: &'static str = "Ich habe eine statische Lebensdauer.";
```

Der Text dieser Zeichenkette wird direkt in der Binärdatei des Programms
gespeichert, die immer verfügbar ist. Daher ist die Lebensdauer aller
Zeichenkettenliterale `'static`.

Möglicherweise siehst du Hinweise zur Verwendung der Lebensdauer `'static` in
Fehlermeldungen. Aber bevor du `'static` als Lebensdauer für eine Referenz
angibst, denke darüber nach, ob deine Referenz tatsächlich während der gesamten
Lebensdauer deines Programms lebt oder nicht. Du könntest überlegen, ob du
willst, dass sie so lange lebt, selbst wenn sie das könnte. Meistens ergibt
sich das Problem aus dem Versuch, eine hängende Referenz zu erstellen oder eine
Unvereinbarkeit zwischen den verfügbaren Lebensdauern zu beheben. In solchen
Fällen besteht die Lösung darin, diese Probleme zu beheben und nicht darin, die
Lebensdauer als `'static` festzulegen.

## Generische Typparameter, Merkmalsabgrenzungen und Lebensdauern zusammen

Schauen wir uns kurz die Syntax zu Angabe generischer Typparameter,
Merkmalsabgrenzungen und Lebensdauern in einer Funktion an!

```rust
# fn main() {
#     let string1 = String::from("abcd");
#     let string2 = "xyz";
#
#     let result = longest_with_an_announcement(
#         string1.as_str(),
#         string2,
#         "Heute hat jemand Geburtstag!",
#     );
#     println!("Die längere Zeichenkette ist {}", result);
# }
#
use std::fmt::Display;

fn longest_with_an_announcement<'a, T>(
    x: &'a str,
    y: &'a str,
    ann: T,
) -> &'a str
where
    T: Display,
{
    println!("Bekanntmachung! {}", ann);
    if x.len() > y.len() {
        x
    } else {
        y
    }
}
```

Dies ist die Funktion `longest` aus Codeblock 10-22, die die längere von zwei
Zeichenkettenanteilstypen zurückgibt. Aber jetzt hat sie einen zusätzlichen
Parameter namens `ann` vom generischen Typ `T`, der jeder beliebige Typ sein
kann, der das Merkmal `Display` implementiert, wie in der `where`-Klausel
spezifiziert ist. Dieser zusätzliche Parameter wird ausgegeben, bevor die
Funktion die Längen der Zeichenkettenanteilstypen vergleicht, weshalb die
Merkmalsabgrenzung `Display` notwendig ist. Da die Lebensdauer ein generischer
Typ ist, stehen die Deklarationen des Lebensdauer-Parameters `'a` und des
generischen Typ-Parameters `T` in der gleichen Liste innerhalb spitzer Klammern
hinter dem Funktionsnamen.

## Zusammenfassung

Wir haben in diesem Kapitel viel behandelt! Jetzt, da du über generische
Typparameter, Merkmale und Merkmalsabgrenzungen sowie generische
Lebensdauerparameter Bescheid weißt, bist du bereit, Code ohne Wiederholungen
zu schreiben, der in vielen verschiedenen Situationen funktioniert. Merkmale
und Merkmalsabgrenzungen stellen sicher, dass die Typen, auch wenn sie
generisch sind, das Verhalten haben, das der Code benötigt. Du hast gelernt,
wie man Lebensdauer-Annotationen verwendet, um sicherzustellen, dass dieser
flexible Code keine hängenden Referenzen hat. Und all diese Analysen finden zur
Kompilierzeit statt, was die Laufzeitperformanz nicht beeinträchtigt!

Ob du es glaubst oder nicht, es gibt zu den Themen, die wir in diesem Kapitel
besprochen haben, noch viel mehr zu sagen: In Kapitel 17 werden Merkmalsobjekte
erörtert, die eine weitere Möglichkeit zur Verwendung von Merkmalen darstellen.
Es gibt auch komplexere Szenarien mit Lebensdauer-Annotationen, die du nur in
sehr fortgeschrittenen Szenarien benötigst; für diese solltest du die
[Rust-Referenz][reference] lesen. Aber als Nächstes wirst du lernen, wie man
Tests in Rust schreibt, damit du sicherstellen kannst, dass dein Code so
funktioniert, wie er sollte.

[references-and-borrowing]: ch04-02-references-and-borrowing.html
[string-slices-as-parameters]:
ch04-03-slices.html#zeichenkettenanteilstypen-als-parameter
[reference]: https://doc.rust-lang.org/reference/index.html
