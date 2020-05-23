## Funktionen

Funktionen sind im Rust-Code allgegenwärtig. Du hast bereits eine der
wichtigsten Funktionen in der Sprache gesehen: die `Hauptfunktion` (`main`), die
der Einstiegspunkt vieler Programme ist. Du hast auch das Schlüsselwort `fn`
gesehen, mit dem du neue Funktionen deklarieren kannst.

Rust-Code verwendet die *Schlangenschrift*-Stil-Konvention (*snake case*) für
Funktions- und Variablennamen. In Schlangenschrift sind alle Buchstaben klein
geschrieben und Unterstriche separieren Wörter. Hier ist ein Programm, das eine
Beispiel-Funktionsdefinition enthält:

<span class="filename">Filename: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-16-functions/src/main.rs}}
```

Funktionsdefinitionen in Rust beginnen mit `fn` und haben einen Satz Klammern
nach dem Funktionsnamen. Die geschweiften Klammern teilen dem Compiler mit, wo
der Funktionskörper beginnt und endet.

Wir können jede Funktion, die wir definiert haben, aufrufen indem wir ihren
Namen gefolgt von einem Satz Klammern eingeben. Da `another_function`
im Programm definiert ist, kann sie von innerhalb der `main`-Funktion aufgerufen
werden. Beachten Sie, daß wir `another_function` *nach* der `main`-Funktion
im Quellcode definiert haben; wir hätten sie auch vorher definieren können. Rust
interessiert es nicht, wo Sie Ihre Funktionen definieren, nur dass sie irgendwo
definiert sind.

Lass uns ein neues Binärprojekt namens *Funktionen* starten, um Funktionen
weiter zu erforschen. Platzieren Sie das Beispiel `another_function` in
*src/main.rs* und lassen Sie es laufen. Sie sollten die folgende Ausgabe sehen:

```text
{{#include ../listings/ch03-common-programming-concepts/no-listing-16-functions/output.txt}}
```

Die Zeilen werden in der Reihenfolge ausgeführt, in der sie in der
`main`-Funktion erscheinen. Zuerst wird die Nachricht “Hello, world!” ausgegeben
und dann wird `another_function` aufgerufen und ihre Nachricht ausgegeben.

### Funktionsparameter

Funktionen können auch so definiert werden, dass sie *Parameter* haben, das sind
spezielle Variablen, die Teil der Signatur einer Funktion sind. Wenn eine
Funktion Parameter hat, kannst du sie mit konkreten Werten für diese Parameter
versehen. Technisch gesehen werden die konkreten Werte *Argumente* genannt, aber
in lockeren Gesprächen neigen Leute dazu, die Worte *Parameter* und *Argument*
entweder für die Variablen in der Definition einer Funktion oder für die
konkreten Werte, die beim Aufruf einer Funktion übergeben werden, austauschbar
zu verwenden.

Die folgende umgeschriebene Version von `another_function` zeigt, wie Parameter
in Rust aussehen:

<span class="filename">Filename: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-17-functions-with-parameters/src/main.rs}}
```

Versuche, dieses Programm auszuführen; du solltest die folgende Ausgabe
erhalten:

```text
{{#include ../listings/ch03-common-programming-concepts/no-listing-17-functions-with-parameters/output.txt}}
```

Die Deklaration `another_function` hat einen Parameter namens `x`. Der Typ von
`x` wird als `i32` angegeben. Wenn `5` an `another_function` übergeben wird,
setzt das Makro `println!` `5` an die Stelle, an der sich das Paar geschweifter
Klammern in der Formatierungszeichenkette befand.

In Funktionssignaturen *musst* du den Typ jedes Parameters deklarieren. Dies
ist eine bewußte Designentscheidung von Rust: Das Erfordernis von
Typ-Anmerkungen in Funktionsdefinitionen bedeutet, dass der Compiler sie fast
nie an anderer Stelle im Code benötigt, um herauszufinden, was du meinst.

Wenn eine Funktion mehrere Parameter haben soll, trenne die
Parameterdeklarationen mit Kommas, so wie hier:

<span class="filename">Filename: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-18-functions-with-multiple-parameters/src/main.rs}}
```

Dieses Beispiel erzeugt eine Funktion mit zwei Parametern, die beide vom Typ
`i32` sind. Die Funktion gibt dann die Werte in ihren beiden Parametern aus.
Beachte, dass Funktionsparameter nicht alle vom gleichen Typ sein müssen, das
ist in diesem Beispiel nur zufällig so.

Lass uns versuchen, diesen Code auszuführen. Ersetze das Programm, das sich
derzeit in der Datei *src/main.rs* deines *Funktionen*-Projekts befindet, durch
das vorhergehende Beispiel und führe es mit `cargo run` aus:

```text
{{#include ../listings/ch03-common-programming-concepts/no-listing-18-functions-with-multiple-parameters/output.txt}}
```

Da wir die Funktion mit `5` als Wert für `x` aufgerufen haben und `6` als Wert
für `y` übergeben wird, werden die beiden Zeichenketten mit diesen Werten
ausgegeben.

#### Funktionskörper enthalten Anweisungen und Ausdrücke

Funktionskörper bestehen aus einer Reihe von Anweisungen, die optional mit einem
Ausdruck enden können. Bisher haben wir nur Funktionen ohne einen endenden
Ausdruck behandelt, aber Sie haben einen Ausdruck als Teil einer Anweisung
gesehen. Da Rust eine auf Ausdrücken basierende Sprache ist, ist dies eine
wichtige Unterscheidung, die es zu verstehen gilt. Andere Sprachen haben nicht
dieselben Unterscheidungen, deshalb wollen wir uns ansehen, was Aussagen und
Ausdrücke sind und wie sich ihre Unterschiede auf die Funktionskörper auswirken.


Wir haben tatsächlich bereits Aussagen und Ausdrücke verwendet. *Anweisungen*
sind Instruktionen, die eine Aktion ausführen und keinen Wert zurückgeben.
*Ausdrücke* werten zu einem resultierenden Wert aus. Sehen wir uns einige
Beispiele an.

Eine Variable zu erstellen und ihr mit dem Schlüsselwort `let` einen Wert
zuzuweisen, ist eine Anweisung. In Listing 3-1 ist `let y = 6;` eine Anweisung.

<span class="filename">Filename: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/listing-03-01/src/main.rs}}
```

<span class="caption">Listing 3-1: Eine `main`-Funktionsdeklaration, die eine Anweisung enthält</span>

Auch Funktionsdefinitionen sind Anweisungen; das gesamte vorhergehende Beispiel
ist eine Anweisung für sich.

Anweisungen geben keine Werte zurück. Daher kannst du keine `let`-Anweisung
einer anderen Variablen zuweisen, wie es der folgende Code versucht; du wirst
einen Fehler erhalten:

<span class="filename">Filename: src/main.rs</span>

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-19-statements-vs-expressions/src/main.rs}}
```

Wenn du dieses Programm ausführst, wirst du einen ähnlichen Fehler wie folgenden
erhalten:

```text
{{#include ../listings/ch03-common-programming-concepts/no-listing-19-statements-vs-expressions/output.txt}}
```

Die Anweisung `let y = 6` gibt keinen Wert zurück, also gibt es für `x` nichts,
woran `x` gebunden werden kann. Dies unterscheidet sich von dem, was in anderen
Sprachen wie C und Ruby geschieht, wo die Zuweisung den Wert der Zuweisung
zurückgibt. In diesen Sprachen kannst du `x = y = 6` schreiben und sowohl
`x` als auch `y` haben den Wert `6`; das ist in Rust nicht der Fall.


Ausdrücke werten zu etwas aus und machen den größten Teil des restlichen Codes
aus, den du in Rust schreiben wirst. Betrachte eine einfache mathematische
Operation, wie z.B. `5 + 6`, die ein Ausdruck ist, der zum Wert `11` ausgewertet
wird. Ausdrücke können Teil von Anweisungen sein: In Listing 3-1 ist die `6` in der
Anweisung `let y = 6;` ein Ausdruck, der den Wert `6` ergibt.  Der Aufruf einer
Funktion ist ein Ausdruck. Der Aufruf eines Makros ist ein Ausdruck. Der Block,
den wir zum Erstellen neuer Bereiche verwenden, `{}`, ist ein Ausdruck, zum
Beispiel:

<span class="filename">Filename: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-20-blocks-are-expressions/src/main.rs}}
```

Der Ausdruck:

```rust,ignore
{
    let x = 3;
    x + 1
}
```

ist ein Block, der in diesem Fall zu `4` ausgewertet wird. Dieser Wert wird als
Teil der `let`-Anweisung an `y` gebunden. Beachte die Zeile `x + 1` ohne
Semikolon am Ende, was sich von den meisten Zeilen, die du bisher gesehen hast,
unterscheidet. Ausdrücke enthalten keine abschließenden Semikolons. Wenn Sie ein
Semikolon an das Ende eines Ausdrucks anfügen, machen Sie daraus eine Anweisung,
die dann keinen Wert zurückgibt.  Behalten Sie dies im Hinterkopf, wenn du als
nächstes die Rückgabewerte von Funktionen und Ausdrücken untersuchst.


### Funktionen mit Rückgabewerten


Funktionen können Werte an den Code zurückgeben, der sie aufruft. Wir benennen
keine Rückgabewerte, aber wir deklarieren ihren Typ nach einem Pfeil (`->`). In
Rust ist der Rückgabewert der Funktion gleichbedeutend mit dem Wert des letzten
Ausdrucks im Block des Körpers einer Funktion. Sie können frühzeitig von einer
Funktion zurückkehren, indem Sie das Schlüsselwort `return` verwenden und einen
Wert angeben, aber die meisten Funktionen geben den letzten Ausdruck implizit
zurück. Hier ist ein Beispiel für eine Funktion, die einen Wert zurückgibt:

<span class="filename">Filename: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-21-function-return-values/src/main.rs}}
```

Es gibt keine Funktionsaufrufe, Makros oder gar `let`-Anweisungen in der
`five`-Funktion - nur die Zahl `5` selbst. Das ist eine vollkommen gültige
Funktion in Rust. Beachte, dass der Rückgabetyp der Funktion ebenfalls
angegeben ist, als `-> i32`. Versuche diesen Code auszuführen; die Ausgabe
sollte wie folgt aussehen:

```text
{{#include ../listings/ch03-common-programming-concepts/no-listing-21-function-return-values/output.txt}}
```

Die `5` in `five` ist der Rückgabewert der Funktion, weshalb der Rückgabetyp
`i32` ist. Lass uns dies genauer untersuchen. Es gibt zwei wichtige Teile:
Erstens zeigt die Zeile `let x = five();`, dass wir den Rückgabewert einer
Funktion verwenden, um eine Variable zu initialisieren. Da die Funktion `five`
ein `5` zurückgibt, ist diese Zeile die gleiche wie die folgende:

```rust
let x = 5;
```

Zweitens hat die `five`-Funktion keine Parameter und definiert den Typ des
Rückgabewertes, aber der Körper der Funktion ist eine einsame `5` ohne
Semikolon, weil es ein Ausdruck ist, dessen Wert wir zurückgeben wollen.

Sehen wir uns ein weiteres Beispiel an:

<span class="filename">Filename: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-22-function-parameter-and-return/src/main.rs}}
```

Beim Ausführen dieses Codes wird `Der Wert von x ist: 6` (`The value of x is:
6`) ausgegeben. Wenn wir aber ein Semikolon an das Ende der Zeile mit `x + 1`
setzen und es von einem Ausdruck in eine Anweisung ändern, erhalten wir einen
Fehler.

<span class="filename">Filename: src/main.rs</span>

```rust,ignore,does_not_compile
{{#rustdoc_include ../listings/ch03-common-programming-concepts/no-listing-23-statements-dont-return-values/src/main.rs}}
```

Das Kompilieren dieses Codes führt zum folgenden Fehler:

```text
{{#include ../listings/ch03-common-programming-concepts/no-listing-23-statements-dont-return-values/output.txt}}
```


Die Hauptfehlermeldung, “nicht übereinstimmende Typen” (“mismatched types”),
offenbart das Kernproblem dieses Codes. Die Definition der Funktion `plus_one`
besagt, dass sie ein `i32` zurückgibt, aber Anweisungen werden nicht zu einem
Wert ausgewertet, was durch `()`, ein leeres Tupel, ausgedrückt wird. Daher wird
nichts zurückgegeben, was der Funktionsdefinition widerspricht und zu einem
Fehler führt. In dieser Ausgabe gibt Rust eine Meldung aus, die möglicherweise
helfen kann, dieses Problem zu beheben: Es wird vorgeschlagen, das Semikolon zu
entfernen, was den Fehler beheben würde.
