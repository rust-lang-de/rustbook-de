## Kontrollfluss

Die Entscheidung, ob ein Code ausgeführt werden soll oder nicht, je nachdem, ob
eine Bedingung erfüllt ist, und die Entscheidung, einen Code wiederholt
auszuführen, solange eine Bedingung erfüllt ist, sind grundlegende Bausteine in
den meisten Programmiersprachen. Die gebräuchlichsten Konstrukte, mit denen du
den Kontrollfluss von Rust-Code kontrollieren kannst, sind `if`-Ausdrücke und
Schleifen.

### `if`-Ausdrücke

Ein `if`-Ausdruck erlaubt es dir, deinen Code abhängig von Bedingungen zu
verzweigen. Du gibst eine Bedingung an und legst dann fest: „Wenn diese
Bedingung erfüllt ist, führe diesen Codeblock aus. Wenn die Bedingung nicht
erfüllt ist, darf dieser Codeblock nicht ausgeführt werden.“

Erstelle in deinem *projects*-Verzeichnis ein neues Projekt namens *branches*,
um den `if`-Ausdruck zu erforschen. Gibt in der Datei *src/main.rs* folgendes
ein:

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let number = 3;

    if number < 5 {
        println!("Bedingung war wahr");
    } else {
        println!("Bedingung war falsch");
    }
}
```

Alle `if`-Ausdrücke beginnen mit dem Schlüsselwort `if`, auf das eine Bedingung
folgt. In diesem Fall prüft die Bedingung, ob die Variable `number` einen Wert
kleiner als 5 hat oder nicht. Der Codeblock, den wir ausführen wollen, wenn die
Bedingung wahr ist, wird unmittelbar nach der Bedingung in geschweifte Klammern
gesetzt. Codeblöcke, die mit den Bedingungen in `if`-Ausdrücken verbunden sind,
werden manchmal auch als *Zweige* (arms) bezeichnet, genau wie die Zweige in
`match`-Ausdrücken, die wir im Abschnitt [„Vergleichen der Schätzung mit der
Geheimzahl“][comparing-the-guess-to-the-secret-number] in Kapitel 2 besprochen
haben.

Optional können wir auch einen `else`-Ausdruck angeben, was wir hier gemacht
haben, um dem Programm einen alternativen Codeblock zur Ausführung zu geben,
falls die Bedingung als falsch ausgewertet wird. Wenn du keinen `else`-Ausdruck
angibst und die Bedingung falsch ist, überspringt das Programm einfach den
`if`-Block und geht zum nächsten Codeteil über.

Versuche, diesen Code auszuführen; du solltest die folgende Ausgabe sehen:

```console
$ cargo run
   Compiling branches v0.1.0 (file:///projects/branches)
    Finished dev [unoptimized + debuginfo] target(s) in 0.31s
     Running `target/debug/branches`
Bedingung war wahr
```

Lass uns versuchen, den Wert von `number` in einen Wert zu ändern, der die
Bedingung `falsch` macht, um zu sehen, was passiert:

```rust
# fn main() {
    let number = 7;
#
#     if number < 5 {
#         println!("Bedingung war wahr");
#     } else {
#         println!("Bedingung war falsch");
#     }
# }
```

Führe das Programm erneut aus und sieh dir die Ausgabe an:

```console
$ cargo run
   Compiling branches v0.1.0 (file:///projects/branches)
    Finished dev [unoptimized + debuginfo] target(s) in 0.31s
     Running `target/debug/branches`
Bedingung war falsch
```

Es ist auch erwähnenswert, dass die Bedingung in diesem Code ein `bool` sein
*muss*. Wenn die Bedingung kein `bool` ist, erhalten wir einen Fehler. Versuche
zum Beispiel, den folgenden Code auszuführen:

<span class="filename">Dateiname: src/main.rs</span>

```rust,does_not_compile
fn main() {
    let number = 3;

    if number {
        println!("Zahl war drei");
    }
}
```

Die `if`-Bedingung wird diesmal zum Wert `3` ausgewertet und Rust wirft einen
Fehler:

```console
$ cargo run
   Compiling branches v0.1.0 (file:///projects/branches)
error[E0308]: mismatched types
 --> src/main.rs:4:8
  |
4 |     if number {
  |        ^^^^^^ expected `bool`, found integer

error: aborting due to previous error

For more information about this error, try `rustc --explain E0308`.
error: could not compile `branches`

To learn more, run the command again with --verbose.
```

Der Fehler gibt an, dass Rust ein `bool` erwartet, aber eine ganze Zahl
erhalten hat. Im Gegensatz zu Sprachen wie Ruby und JavaScript wird Rust nicht
automatisch versuchen, nicht-boolsche Typen in ein Boolean zu konvertieren. Du
musst explizit sein und immer `if` mit einer Booleschen Bedingung versehen.
Wenn wir beispielsweise wollen, dass der `if`-Codeblock nur ausgeführt wird,
wenn eine Zahl ungleich `0` ist, können wir den `if`-Ausdruck wie folgt ändern:

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let number = 3;

    if number != 0 {
        println!("Zahl war etwas anderes als Null");
    }
}
```

Wenn du diesen Code ausführst, wird `Zahl war etwas anderes als Null`
ausgegeben.

#### Behandeln mehrerer Bedingungen mit `else if`

Du kannst mehrere Bedingungen verwenden, indem du `if` und `else` in einem
`else if`-Ausdruck kombinierst. Zum Beispiel:

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let number = 6;

    if number % 4 == 0 {
        println!("Zahl ist durch 4 teilbar");
    } else if number % 3 == 0 {
        println!("Zahl ist durch 3 teilbar");
    } else if number % 2 == 0 {
        println!("Zahl ist durch 2 teilbar");
    } else {
        println!("Zahl ist nicht durch 4, 3 oder 2 teilbar");
    }
}
```

Dieses Programm hat vier mögliche Wege, die es nehmen kann. Nachdem du es
ausgeführt hast, solltest du folgende Ausgabe sehen:

```console
$ cargo run
   Compiling branches v0.1.0 (file:///projects/branches)
    Finished dev [unoptimized + debuginfo] target(s) in 0.31s
     Running `target/debug/branches`
Zahl ist durch 3 teilbar
```

Wenn dieses Programm ausgeführt wird, prüft es der Reihe nach jeden
`if`-Ausdruck und führt den ersten Block aus, für den die Bedingung wahr ist. 
Beachte, dass, obwohl 6 durch 2 teilbar ist, wir weder die Ausgabe `Zahl ist
durch 2 teilbar` sehen, noch sehen wir den Text `Zahl ist nicht durch 4, 3 oder
2 teilbar` aus dem `else`-Block. Das liegt daran, dass Rust den Block nur für
die erste wahre Bedingung ausführt, und wenn es eine findet, prüft es den Rest
nicht mehr.

Das Verwenden von zu vielen `else if`-Ausdrücken kann deinen Code
unübersichtlich machen. Wenn du also mehr als einen Ausdruck hast, solltest du
deinen Code vielleicht überarbeiten. Kapitel 6 beschreibt ein leistungsfähiges
Rust-Verzweigungskonstrukt namens `match` für solche Fälle.

#### Verwenden von `if` in einer `let`-Anweisung

Weil `if` ein Ausdruck ist, können wir ihn auf der rechten Seite einer
`let`-Anweisung verwenden, wie in Codeblock 3-2.

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let condition = true;
    let number = if condition { 5 } else { 6 };

    println!("Der Wert der Zahl ist: {}", number);
}
```

<span class="caption">Codeblock 3-2: Zuweisen des Ergebnisses eines
`if`-Ausdrucks an eine Variable</span>

Die Variable `number` wird an einen Wert gebunden, der auf dem Ergebnis des
`if`-Ausdrucks basiert. Führe diesen Code aus, um zu sehen, was passiert:

```console
$ cargo run
   Compiling branches v0.1.0 (file:///projects/branches)
    Finished dev [unoptimized + debuginfo] target(s) in 0.30s
     Running `target/debug/branches`
Der Wert der Zahl ist: 5
```

Denke daran, dass Codeblöcke bis zum letzten Ausdruck in ihnen ausgewertet
werden, und auch Zahlen an sich sind Ausdrücke. In diesem Fall hängt der Wert
des gesamten `if`-Ausdrucks davon ab, welcher Codeblock ausgeführt wird. Dies
bedeutet, dass die Werte, die potentielle Ergebnisse eines `if`-Zweigs sein
können, vom gleichen Typ sein müssen; in Codeblock 3-2 waren die Ergebnisse
sowohl des `if`-Zweigs als auch des `else`-Zweigs `i32`-Ganzzahlen. Wenn die
Typen nicht übereinstimmen, wie im folgenden Beispiel, erhalten wir einen
Fehler:

<span class="filename">Dateiname: src/main.rs</span>

```rust,does_not_compile
fn main() {
    let condition = true;

    let number = if condition { 5 } else { "sechs" };

    println!("Der Wert der Zahl ist: {}", number);
}
```

Wenn wir versuchen, diesen Code zu kompilieren, erhalten wir einen Fehler. Die
`if`- und `else`-Zweige haben Werttypen, die inkompatibel sind, und Rust zeigt
genau an, wo das Problem im Programm zu finden ist:

```console
$ cargo run
   Compiling branches v0.1.0 (file:///projects/branches)
error[E0308]: `if` and `else` have incompatible types
 --> src/main.rs:4:44
  |
4 |     let number = if condition { 5 } else { "sechs" };
  |                                 -          ^^^^^^^ expected integer, found `&str`
  |                                 |
  |                                 expected because of this

error: aborting due to previous error

For more information about this error, try `rustc --explain E0308`.
error: could not compile `branches`

To learn more, run the command again with --verbose.
```

Der Ausdruck im `if`-Block wird zu einer ganzen Zahl und der Ausdruck im
`else`-Block zu einer Zeichenkette ausgewertet. Dies wird nicht funktionieren,
da Variablen einen einzigen Typ haben müssen. Rust muss zur Kompilierzeit
definitiv wissen, welchen Typ die Variable `number` hat, damit es zur
Kompilierzeit überprüfen kann, ob ihr Typ überall gültig ist, wo wir `number`
verwenden. Rust wäre dazu nicht in der Lage, wenn der Typ von `number` erst zur
Laufzeit bestimmt würde; der Compiler wäre komplexer und würde weniger
Garantien über den Code geben, wenn er mehrere hypothetische Typen für jede
Variable verfolgen müsste.

### Wiederholung mit Schleifen

Es ist oft hilfreich, einen Codeblock mehr als einmal auszuführen. Für diese
Aufgabe stellt Rust mehrere *Schleifen* (loops) zur Verfügung. Eine Schleife
durchläuft den Code innerhalb des Schleifenrumpfs bis zum Ende und beginnt dann
sofort wieder am Anfang. Um mit Schleifen zu experimentieren, machen wir ein
neues Projekt namens *loops*.

Rust hat drei Arten von Schleifen: `loop`, `while` und `for`. Probieren wir
jede einzelne aus.

#### Wiederholen von Code mit `loop`

Das Schlüsselwort `loop` weist Rust an, einen Codeblock immer und immer wieder
auszuführen, und zwar für immer oder bis du ihm explizit sagst, dass er
aufhören soll.

Als Beispiel änderst du die Datei *src/main.rs* in deinem *loops*-Verzeichnis
so, dass sie wie folgt aussieht:

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore
fn main() {
    loop {
        println!("nochmal!");
    }
}
```

Wenn wir dieses Programm ausführen, werden wir sehen, dass es immer und immer
wieder `nochmal!` ausgibt, bis wir das Programm manuell stoppen. Die meisten
Terminals unterstützen das Tastaturkürzel <span
class="keystroke">Strg+c</span>, um ein Programm zu unterbrechen, das in einer
Endlosschleife feststeckt. Probiere es aus:

```console
$ cargo run
   Compiling loops v0.1.0 (file:///projects/loops)
    Finished dev [unoptimized + debuginfo] target(s) in 0.29s
     Running `target/debug/loops`
nochmal!
nochmal!
nochmal!
nochmal!
^Cnochmal!
```

Das Symbol `^C` steht für die Stelle, an der du <span
class="keystroke">Strg+c</span> gedrückt hast. Je nachdem, wo sich der Code in
der Schleife befand, als er das Unterbrechungssignal empfing, siehst du nach
dem `^C` das Wort `nochmal!` oder nicht.

Glücklicherweise bietet Rust eine Möglichkeit, aus einer Schleife auszubrechen.
Du kannst das Schlüsselwort `break` innerhalb der Schleife platzieren, um dem
Programm mitzuteilen, wann es die Ausführung der Schleife beenden soll.
Erinnere dich, dass wir dies im Ratespiel im Abschnitt [„Beenden nach einer
korrekten Schätzung“][quitting-after-a-correct-guess] in Kapitel 2 getan haben,
um das Programm zu beenden, wenn der Benutzer das Spiel durch Erraten der
richtigen Zahl gewonnen hat.

Wir haben im Ratespiel auch `continue` verwendet. Das Schlüsselwort `continue`
innerhalb einer Schleife weist das Programm an, jeden restlichen Code in dieser
Iteration der Schleife zu überspringen und mit der nächsten Iteration
fortzufahren.

Wenn du Schleifen innerhalb Schleifen hast, beziehen sich `break` und
`continue` auf die innerste Schleife an diesem Punkt. Du kannst einer Schleife
optional einen *Schleifennamen* (loop label) geben und dann den Namen mit
`break` oder `continue` verwenden, damit sich diese Schlüsselwörter auf die
bezeichnete Schleife anstelle der innersten Schleife beziehen. Hier ist ein
Beispiel mit zwei geschachtelten Schleifen:

```rust
fn main() {
    let mut count = 0;
    'counting_up: loop {
        println!("count = {}", count);
        let mut remaining = 10;

        loop {
            println!("remaining = {}", remaining);
            if remaining == 9 {
                break;
            }
            if count == 2 {
                break 'counting_up;
            }
            remaining -= 1;
        }

        count += 1;
    }
    println!("count am Ende = {}", count);
}
```

Die äußere Schleife hat den Namen `'counting_up` und sie zählt von 0 bis 2
aufwärts. Die innere Schleife ohne Name zählt von 10 bis 9 herunter. Das erste
`break`, das keinen Namen angibt, beendet nur die innere Schleife. Mit der
Anweisung `break 'counting_up;` wird die äußere Schleife verlassen. Dieser Code
gibt folgendes aus:

```console
$ cargo run
   Compiling loops v0.1.0 (file:///projects/loops)
    Finished dev [unoptimized + debuginfo] target(s) in 0.58s
     Running `target/debug/loops`
count = 0
remaining = 10
remaining = 9
count = 1
remaining = 10
remaining = 9
count = 2
remaining = 10
count am Ende = 2
```

#### Rückgabe von Werten aus Schleifen

Eine der Verwendungen von `loop` besteht darin, eine Operation, von der du
weißt, dass sie fehlschlagen könnte, erneut zu versuchen, z.B. um zu prüfen, ob
ein Strang (thread) seine Arbeit abgeschlossen hat. Möglicherweise musst du
jedoch das Ergebnis dieser Operation an den Rest deines Codes weitergeben. Dazu
kannst du den Wert, der zurückgegeben werden soll, hinter dem `break`-Ausdruck
angeben, den du zum Beenden der Schleife verwendest; dieser Wert wird aus der
Schleife zurückgegeben, sodass du ihn verwenden kannst, wie hier gezeigt:

```rust
fn main() {
    let mut counter = 0;

    let result = loop {
        counter += 1;

        if counter == 10 {
            break counter * 2;
        }
    };

    println!("Das Ergebnis ist {}", result);
}
```

Vor der Schleife deklarieren wir eine Variable namens `counter` und
initialisieren sie mit `0`. Dann deklarieren wir eine Variable namens `result`,
die den von der Schleife zurückgegebenen Wert enthält. Bei jeder Iteration der
Schleife addieren wir `1` zur Variable `counter` und prüfen dann, ob der Zähler
gleich `10` ist. Wenn dies der Fall ist, verwenden wir das Schlüsselwort
`break` mit dem Wert `counter * 2`. Nach der Schleife verwenden wir ein
Semikolon, um die Anweisung zu beenden, die `result` den Wert zuweist.
Schließlich geben wir den Wert in `result` aus, der in diesem Fall `20`
beträgt.

#### Bedingte Schleifen mit `while`

Oft ist es für ein Programm nützlich, eine Bedingung innerhalb einer Schleife
auszuwerten. Solange die Bedingung wahr ist, wird die Schleife durchlaufen.
Wenn die Bedingung nicht mehr wahr ist, ruft das Programm `break` auf und
stoppt die Schleife. Dieser Schleifentyp könnte durch eine Kombination von
`loop`, `if`, `else` und `break` implementiert werden; du kannst das jetzt in
einem Programm versuchen, wenn du möchtest.

Dieses Muster ist jedoch so weit verbreitet, dass Rust ein eingebautes
Sprachkonstrukt dafür hat, die sogenannte `while`-Schleife. In Codeblock 3-3
wird `while` verwendet: Das Programm durchläuft dreimal eine Schleife, in der
es jedes Mal abwärts zählt, und dann nach dem Ende der Schleife eine weitere
Nachricht ausgibt und sich beendet.

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let mut number = 3;

    while number != 0 {
        println!("{}!", number);

        number -= 1;
    }

    println!("ABHEBEN!!!");
}
```

<span class="caption">Codeblock 3-3: Verwenden einer `while`-Schleife, um Code
auszuführen, solange eine Bedingung wahr ist</span>

Dieses Konstrukt eliminiert eine Menge von Verschachtelungen, die notwendig
wären, wenn du `loop`, `if`, `else` und `break` verwenden würdest, und es ist
klarer. Solange eine Bedingung wahr ist, läuft der Code ab; andernfalls wird
die Schleife verlassen.

#### Wiederholen anhand einer Kollektion mit `for`

Du kannst das `while`-Konstrukt verwenden, um die Elemente einer Kollektion,
z.B. ein Array, in einer Schleife zu durchlaufen. Sehen wir uns zum Beispiel
Codeblock 3-4 an.

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let a = [10, 20, 30, 40, 50];
    let mut index = 0;

    while index < 5 {
        println!("Der Wert ist: {}", a[index]);

        index += 1;
    }
}
```

<span class="caption">Codeblock 3-4: Wiederholen anhand aller Elemente einer
Kollektion unter Verwendung einer `while`-Schleife</span>

Hier zählt der Code die Elemente im Array aufwärts. Er beginnt bei Index `0`
und wiederholt bis er den letzten Index im Array erreicht (d.h. wenn
`index < 5` nicht mehr wahr ist). Wenn du diesen Code ausführst, wird jedes
Element im Array ausgegeben:

```console
$ cargo run
   Compiling loops v0.1.0 (file:///projects/loops)
    Finished dev [unoptimized + debuginfo] target(s) in 0.32s
     Running `target/debug/loops`
Der Wert ist: 10
Der Wert ist: 20
Der Wert ist: 30
Der Wert ist: 40
Der Wert ist: 50
```

Alle fünf Array-Werte erscheinen erwartungsgemäß im Terminal. Wenn `index` den
Wert `5` erreicht hat, stoppt die Schleife ihre Ausführung, bevor sie versucht,
einen sechsten Wert aus dem Array zu holen.

Aber dieser Ansatz ist fehleranfällig; wir könnten das Programm zum Abstürzen
bringen, wenn der Indexwert oder die Testbedingung falsch ist. Er ist zudem
langsam, weil der Compiler Laufzeitcode erzeugt, der die Bedingungsprüfung, ob
der Index innerhalb der Arraygrenzen liegt, bei jeder Schleifeniteration
durchführt.

Als prägnantere Alternative kannst du eine `for`-Schleife verwenden und für
jedes Element einer Kollektion etwas Code ausführen. Eine `for`-Schleife sieht
wie der Code in Codeblock 3-5 aus.

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let a = [10, 20, 30, 40, 50];

    for element in a {
        println!("Der Wert ist: {}", element);
    }
}
```

<span class="caption">Codeblock 3-5: Wiederholen anhand aller Elemente einer
Kollektion unter Verwendung einer `for`-Schleife</span>

Wenn wir diesen Code ausführen, werden wir die gleiche Ausgabe wie in Codeblock
3-4 sehen. Noch wichtiger ist, dass wir jetzt die Sicherheit des Codes erhöht
und die Möglichkeit von Fehlern eliminiert haben, die dadurch entstehen
könnten, dass wir über das Ende des Arrays hinausgehen oder nicht weit genug
gehen und einige Elemente übersehen.

Wenn du beispielsweise im Code in Codeblock 3-4 die Definition des Arrays `a`
so geändert hast, dass es vier Elemente hat, aber vergessen hast, die Bedingung
auf `while index < 4` zu aktualisieren, würde der Code abstürzen. Wenn du die
`for`-Schleife verwendest, brauchst du nicht daran zu denken, irgendeinen
anderen Code zu ändern, wenn du die Anzahl der Werte im Array änderst.

Die Sicherheit und Prägnanz der `for`-Schleifen machen sie zum am häufigsten
verwendeten Schleifenkonstrukt in Rust. Sogar in Situationen, in denen du einen
Code bestimmt oft laufen lassen willst, wie im Countdown-Beispiel, das in
Codeblock 3-3 eine `while`-Schleife verwendet hat, würden die meisten
Rust-Entwickler eine `for`-Schleife verwenden. Der Weg, dies zu erreichen, wäre
das Verwenden eines `Range`, ein von der Standardbibliothek zur Verfügung
gestellter Typ, der alle Zahlen in Folge generiert, beginnend mit einer Zahl
und endend vor einer anderen Zahl.

So würde der Countdown aussehen, wenn man eine `for`-Schleife und die Methode
`rev`, über die wir noch nicht gesprochen haben und die den `Range` umkehrt,
verwenden würde:

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    for number in (1..4).rev() {
        println!("{}!", number);
    }
    println!("ABHEBEN!!!");
}
```

Dieser Code ist ein bisschen schöner, nicht wahr?

## Zusammenfassung

Du hast es geschafft! Das war ein beachtliches Kapitel: Du lerntest etwas über
Variablen, skalare und zusammengesetzte Datentypen, Funktionen, Kommentare,
`if`-Ausdrücke und Schleifen! Wenn du mit den in diesem Kapitel besprochenen
Konzepten üben willst, versuche, Programme zu bauen, um Folgendes zu tun:

* Temperaturen zwischen Fahrenheit und Celsius umrechnen.
* Die n-te Fibonacci-Zahl berechnen.
* Den Text des Weihnachtsliedes „Die Zwölf Weihnachtstage“ (The Twelve Days of
  Christmas) ausgeben und dabei die Wiederholung im Lied nutzen.

Wenn du bereit bist, weiterzumachen, werden wir in Rust über ein Konzept
sprechen, das es in anderen Programmiersprachen üblicherweise *nicht* gibt:
Eigentümerschaft (ownership).

[comparing-the-guess-to-the-secret-number]:
ch02-00-guessing-game-tutorial.html#vergleichen-der-schätzung-mit-der-geheimzahl
[quitting-after-a-correct-guess]:
ch02-00-guessing-game-tutorial.html#beenden-nach-einer-korrekten-schätzung
