## UTF-8-kodierten Text in Zeichenketten (strings) ablegen

Wir haben in Kapitel 4 über Zeichenketten (strings) gesprochen, aber wir werden
uns jetzt eingehender damit befassen. Neue Rust-Entwickler haben gewöhnlich aus
einer Kombination von drei Gründen Probleme mit Zeichenketten: Rusts Neigung,
mögliche Fehler aufzudecken, Zeichenketten als eine kompliziertere
Datenstruktur, als viele Programmierer ihnen zugestehen, und UTF-8. Diese
Faktoren kombinieren sich in einer Weise, die schwierig erscheinen kann, wenn
man von anderen Programmiersprachen kommt.

Wir besprechen Zeichenketten im Kontext von Kollektionen, da Zeichenketten als
Byte-Kollektion implementiert sind, sowie einige Methoden, die nützliche
Funktionalitäten bieten, wenn diese Bytes als Text interpretiert werden. In
diesem Abschnitt werden wir über `String`-Operationen sprechen, die jeder
Kollektionstyp hat, wie das Erstellen, Aktualisieren und Lesen. Wir werden auch
die Art und Weise besprechen, in der sich `String` von den anderen Kollektionen
unterscheidet, nämlich warum die Indexierung bei einem `String` kompliziert
ist, weil Menschen und Computer `String`-Daten unterschiedlich interpretieren.

### Was ist eine Zeichenkette?

Zuerst werden wir definieren, was wir mit dem Begriff *Zeichenkette* (string)
meinen. Rust hat nur einen einzigen Zeichenkettentyp in der Kernsprache,
nämlich den Zeichenkettenanteilstyp `str`, der üblicherweise in seiner
Ausleihenform `&str` zu sehen ist. In Kapitel 4 sprachen wir über
*Zeichenkettenanteilstypen* (string slices), die Referenzen auf einige
UTF-8-kodierte Zeichenkettendaten sind, die anderswo gespeichert sind.
Zeichenkettenliterale werden beispielsweise in der Binärdatei des Programms
gespeichert und sind daher Zeichenkettenanteilstypen.

Der Typ `String`, der von Rusts Standardbibliothek zur Verfügung gestellt wird
und nicht in die Kernsprache kodiert ist, ist ein größenänderbarer,
veränderlicher, aneigenbarer, UTF-8-kodierter Zeichenkettentyp. Wenn
Rust-Entwickler von Zeichenketten in Rust sprechen, meinen sie normalerweise
den Typ `String` sowie den Zeichenkettenanteilstyp `&str`, nicht nur einen
dieser Typen. Obwohl es in diesem Abschnitt weitgehend um `String` geht, werden
beide Typen in Rusts Standardbibliothek stark verwendet, und sowohl `String`
als auch Zeichenkettenanteilstypen sind UTF-8-kodiert.

Die Standardbibliothek von Rust enthält auch eine Reihe anderer
Zeichenkettentypen wie `OsString`, `OsStr`, `CString` und `CStr`.
Bibliothekskisten (library crates) können noch weitere Möglichkeiten zum
Speichern von Zeichenkettendaten bieten. Fällt dir auf, dass diese Namen alle
auf `String` oder `Str` enden? Sie beziehen sich auf aneigenbare und
ausgeliehene Varianten, genau wie die Typen `String` und `str`, die du zuvor
gesehen hast. Diese Zeichenkettentypen können z.B. Text in verschiedenen
Kodierungen speichern oder unterschiedliche Speicherdarstellungen haben. Diese
anderen Zeichenkettentypen werden in diesem Kapitel nicht besprochen; in ihrer
API-Dokumentation erfährst du mehr darüber, wie sie zu verwenden sind und wozu
jeder einzelne geeignet ist.

### Erstellen einer neuen Zeichenkette

Viele der gleichen Operationen, die mit `Vec<T>` verfügbar sind, sind auch mit
`String` verfügbar, weil `String` eigentlich als Hülle um einen Vektor von
Bytes mit einigen zusätzlichen Garantien, Einschränkungen und Fähigkeiten
implementiert ist. Ein Beispiel für eine Funktion, die auf die gleiche Weise
mit `Vec<T>` und `String` arbeitet, ist die Funktion `new` zum Erstellen einer
Instanz, die in Codeblock 8-11 gezeigt wird.

```rust
let mut s = String::new();
```

<span class="caption">Codeblock 8-11: Erstellen einer neuen, leeren
Zeichenkette</span>

Diese Zeile erzeugt eine neue, leere Zeichenkette namens `s`, in die wir dann
Daten aufnehmen können. Oft werden wir einige initiale Daten haben, mit denen
wir die Zeichenkette füllen wollen. Dazu verwenden wir die Methode `to_string`,
die für jeden Typ verfügbar ist, der das Merkmal `Display` implementiert, wie
es bei Zeichenkettenliteralen der Fall ist. Codeblock 8-12 zeigt zwei
Beispiele.

```rust
let data = "initialer Inhalt";

let s = data.to_string();

// die Methode funktioniert auch direkt für ein Literal:
let s = "initialer Inhalt".to_string();
```

<span class="caption">Codeblock 8-12: Verwenden der Methode `to_string` zum
Erzeugen eines `String` aus einem Zeichenkettenliteral</span>

Dieser Code erzeugt eine Zeichenkette mit dem Inhalt `initialer Inhalt`.

Wir können auch die Funktion `String::from` verwenden, um einen `String` aus
einem Zeichenkettenliteral zu erzeugen. Der Code in Codeblock 8-13 ist
äquivalent zum Code in Codeblock 8-12, der `to_string` verwendet.

```rust
let s = String::from("initialer Inhalt");
```

<span class="caption">Codeblock 8-13: Verwenden der Funktion `String::from` zum
Erzeugen eines `String` aus einem Zeichenkettenliteral</span>

Da Zeichenketten für so viele Dinge verwendet werden, können wir viele
verschiedene generische Programmierschnittstellen (APIs) für Zeichenketten
verwenden, was uns viele Möglichkeiten bietet. Einige von ihnen können
überflüssig erscheinen, aber sie alle haben ihren Platz! In diesem Fall machen
`String::from` und `to_string` dasselbe, also ist die Wahl eine Frage des
Stils und der Lesbarkeit.

Denke daran, dass Zeichenketten UTF-8-kodiert sind, sodass sie alle
ordnungsgemäß kodierten Daten aufnehmen können, wie in Codeblock 8-14 gezeigt.

```rust
let hello = String::from("السلام عليكم");
let hello = String::from("Dobrý den");
let hello = String::from("Hallo");
let hello = String::from("Hello");
let hello = String::from("שָׁלוֹם");
let hello = String::from("नमस्ते");
let hello = String::from("こんにちは");
let hello = String::from("안녕하세요");
let hello = String::from("你好");
let hello = String::from("Olá");
let hello = String::from("Здравствуйте");
let hello = String::from("Hola");
```

<span class="caption">Codeblock 8-14: Speichern von Begrüßungstexten in
verschiedenen Sprachen in Zeichenketten</span>

All dies sind gültige `String`-Werte.

### Aktualisieren einer Zeichenkette

Ein `String` kann an Größe zunehmen und sein Inhalt kann sich ändern, genau wie
der Inhalt eines `Vec<T>`, wenn du mehr Daten hineinschiebst. Darüber hinaus
kannst du bequem den Operator `+` oder das Makro `format!` verwenden, um
`String`-Werte aneinanderzuhängen.

#### Anhängen an eine Zeichenkette mit `push_str` und `push`

Wir können einen `String` wachsen lassen, indem wir die Methode `push_str`
verwenden, um einen Zeichenkettenanteilstyp anzuhängen, wie in Codeblock 8-15
zu sehen ist.

```rust
let mut s = String::from("foo");
s.push_str("bar");
```

<span class="caption">Codeblock 8-15: Anhängen eines Zeichenkettenanteilstyps
an einen `String` mit der Methode `push_str`</span>

Nach diesen beiden Zeilen enthält `s` den Wert `foobar`. Die Methode `push_str`
nimmt einen Zeichenkettenanteilstyp, weil wir nicht unbedingt die
Eigentümerschaft des Parameters übernehmen wollen. Zum Beispiel wollen wir im
Code in Codeblock 8-16 in der Lage sein, `s2` zu verwenden, nachdem wir seinen
Inhalt an `s1` angehängt haben.

```rust
let mut s1 = String::from("foo");
let s2 = "bar";
s1.push_str(s2);
println!("s2 ist {}", s2);
```

<span class="caption">Codeblock 8-16: Verwenden eines Zeichenkettenanteilstyps
nach dem Anhängen seines Inhalts an eine Zeichenkette</span>

Wenn die Methode `push_str` die Eigentümerschaft von `s2` übernehmen würde,
könnten wir ihren Wert nicht in der letzten Zeile ausgeben. Dieser Code
funktioniert jedoch wie erwartet!

Die Methode `push` nimmt ein einzelnes Zeichen als Parameter und fügt es dem
`String` hinzu. Codeblock 8-17 fügt den Buchstaben `l` mit der Methode `push`
zu einem `String` hinzu.

```rust
let mut s = String::from("lo");
s.push('l');
```

<span class="caption">Codeblock 8-17: Hinzufügen eines Zeichens zu einem
`String`-Wert mit `push`</span>

Als Ergebnis wird `s` den Wert `lol` enthalten.

#### Aneinanderhängen mit dem Operator `+` und dem Makro `format!`

Häufig möchtest du zwei vorhandene Zeichenketten kombinieren. Eine Möglichkeit
das zu tun ist, den Operator `+` zu verwenden, wie in Codeblock 8-18 gezeigt.

```rust
let s1 = String::from("Hallo ");
let s2 = String::from("Welt!");
let s3 = s1 + &s2; // Beachte, s1 wurde hierher verschoben und
                   // kann nicht mehr verwendet werden
```

<span class="caption">Codeblock 8-18: Verwenden des Operators `+`, um zwei
Zeichenketten zu einer neuen zu kombinieren</span>

Die Zeichenkette `s3` wird `Hallo Welt!` enthalten. Der Grund, warum `s1` nach
der Addition nicht mehr gültig ist und warum wir eine Referenz auf `s2`
verwendet haben, hat mit der Signatur der Methode zu tun, die aufgerufen wird,
wenn wir den Operator `+` verwenden. Der Operator `+` benutzt die Methode
`add`, deren Signatur ungefähr so aussieht:

```rust,ignore
fn add(self, s: &str) -> String {
```

In der Standardbibliothek wird `add` mittels generischer Datentypen und
assoziierter Typen definiert. Hier haben wir konkrete Typen ersetzt, was
geschieht, wenn wir diese Methode mit `String`-Werten aufrufen. Wir werden
generische Datentypen in Kapitel 10 besprechen. Diese Signatur gibt uns den
entscheidenden Hinweis, um die kniffligen Stellen des Operators `+` zu
verstehen.

Erstens hat `s2` ein `&`, was bedeutet, dass wir eine *Referenz* der zweiten
Zeichenkette an die erste Zeichenkette anhängen. Der Grund dafür ist der
Parameter `s` in der Funktion `add`: Wir können nur einen `&str` zu einem
`String` hinzufügen; wir können nicht zwei `String`-Werte aneinanderhängen.
Aber warte &ndash; der Typ von `&s2` ist `&String`, nicht `&str`, wie im
zweiten Parameter von `add` spezifiziert. Warum kompiliert also Codeblock 8-18?

Der Grund, warum wir `&s2` im Aufruf von `add` verwenden können, ist, dass der
Compiler das Argument `&String` in einen `&str` umwandeln (coerce) kann.
Wenn wir die Methode `add` aufrufen, benutzt Rust eine *automatische
Umwandlung* (deref coercion), die hier `&s2` in `&s2[...]` umwandelt. Auf die
automatische Umwandlung werden wir in Kapitel 15 tiefer eingehen. Da `add`
nicht die Eigentümerschaft des Parameters `s` übernimmt, ist `s2` auch nach
dieser Operation immer noch ein gültiger `String`.

Zweitens können wir in der Signatur sehen, dass `add` die Eigentümerschaft von
`self` übernimmt, weil `self` *kein* `&` hat. Das bedeutet, dass `s1` in
Codeblock 8-18 in den Aufruf von `add` verschoben wird und danach nicht mehr
gültig ist. Obwohl also `let s3 = s1 + &s2;` so aussieht, als ob beide
Zeichenketten kopiert und eine neue erzeugt wird, übernimmt diese Anweisung
tatsächlich die Eigentümerschaft von `s1`, hängt eine Kopie des Inhalts von
`s2` an und gibt dann die Eigentümerschaft des Ergebnisses zurück. In anderen
Worten sieht es so aus, als würde es viele Kopien erstellen, das ist aber nicht
so; die Implementierung ist effizienter als Kopieren.

Wenn wir mehrere Zeichenketten aneinanderhängen wollen, wird das Verhalten des
Operators `+` unhandlich:

```rust
let s1 = String::from("tic");
let s2 = String::from("tac");
let s3 = String::from("toe");

let s = s1 + "-" + &s2 + "-" + &s3;
```

An diesem Punkt wird `s` den Wert `tic-tac-toe` haben. Bei all den Zeichen `+`
und `"` ist es schwer zu erkennen, was vor sich geht. Für kompliziertere
String-Kombinationen können wir stattdessen das Makro `format!` verwenden:

```rust
let s1 = String::from("tic");
let s2 = String::from("tac");
let s3 = String::from("toe");

let s = format!("{}-{}-{}", s1, s2, s3);
```

Auch bei diesem Code wird `s` den Wert `tic-tac-toe` haben. Das Makro `format!`
funktioniert wie `println!`, aber anstatt das Ergebnis auf den Bildschirm
auszugeben, gibt es einen `String` mit dem Inhalt zurück. Die Codevariante, die
`format!` verwendet, ist viel leichter zu lesen, und der durch das Makro
`format!` erzeugte Code verwendet Referenzen sodass dieser Aufruf keine
Eigentümerschaft seiner Parameter übernimmt.

### Indexierung von Zeichenketten

In vielen anderen Programmiersprachen ist das Zugreifen auf einzelne Zeichen in
einer Zeichenkette mittels Index eine gültige und gängige Operation. Wenn du
jedoch in Rust versuchst, mittels Indexierungssyntax auf Teile einer
Zeichenkette zuzugreifen, wirst du einen Fehler erhalten. Betrachte den
ungültigen Code in Codeblock 8-19.

```rust,does_not_compile
let s1 = String::from("Hallo");
let h = s1[0];


```

<span class="caption">Codeblock 8-19: Versuch, die Indexierungssyntax bei einer
Zeichenkette zu verwenden</span>

Dieser Code führt zu folgendem Fehler:

```console
$ cargo run
   Compiling collections v0.1.0 (file:///projects/collections)
error[E0277]: the type `String` cannot be indexed by `{integer}`
 --> src/main.rs:3:13
  |
3 |     let h = s1[0];
  |             ^^^^^ `String` cannot be indexed by `{integer}`
  |
  = help: the trait `Index<{integer}>` is not implemented for `String`

For more information about this error, try `rustc --explain E0277`.
error: could not compile `collections` due to previous error
```

Die Fehlermeldung und der Hinweis erzählen die Geschichte: Zeichenketten in
Rust unterstützen keine Indexierung. Aber warum nicht? Um diese Frage zu
beantworten, müssen wir uns ansehen, wie Rust Zeichenketten im Speicher ablegt.

#### Interne Darstellung

Ein `String` ist eine Hülle um einen `Vec<u8>`. Sehen wir uns einige unserer
korrekt kodierten UTF-8-Beispielzeichenketten aus Codeblock 8-14 an. Zuerst
diese:

```rust
let hello = String::from("Hola");
```

In diesem Fall wird `hello.len()` gleich 4 sein, was bedeutet, dass der Vektor,
der die Zeichenkette „Hola“ speichert, 4 Bytes lang ist. Jeder dieser
Buchstaben benötigt 1 Byte in UTF-8-Kodierung. Die folgende Zeile mag dich
jedoch überraschen. (Beachte, dass diese Zeichenkette mit dem kyrillischen
Großbuchstaben „Ze“ beginnt, nicht mit der arabischen Zahl 3.)

```rust
let hello = String::from("Здравствуйте");
```

Auf die Frage, wie lang die Zeichenkette ist, könnte man sagen: 12. Die Antwort
von Rust lautet jedoch 24: Das ist die Anzahl der Bytes, die benötigt wird, um
„Здравствуйте“ in UTF-8 zu kodieren, da jeder Unicode-Skalarwert in dieser
Zeichenkette 2 Bytes Speicherplatz benötigt. Daher wird ein Index auf die Bytes
der Zeichenkette nicht immer mit einem gültigen Unicode-Skalarwert korrelieren.
Um das zu erläutern, betrachte diesen ungültigen Rust-Code:

```rust,does_not_compile
let hello = "Здравствуйте";
let answer = &hello[0];


```

Du weißt bereits, dass `answer` nicht `З`, der erste Buchstabe, sein wird. In
der UTF-8-Kodierung von `З` ist das erste Byte `208` und das zweite `151`,
sodass `answer` eigentlich `208` sein müsste, aber `208` ist kein eigenständig
gültiges Zeichen. Die Rückgabe von `208` ist wahrscheinlich nicht das, was ein
Nutzer wünschen würde, wenn er nach dem ersten Buchstaben dieser Zeichenkette
fragte; das sind jedoch die einzigen Daten, die Rust beim Byte-Index 0 hat.
Nutzer wollen im Allgemeinen nicht, dass der Byte-Wert zurückgegeben wird,
selbst wenn die Zeichenkette nur lateinische Buchstaben enthält: Wenn
`&"hallo"[0]` gültiger Code wäre, der den Byte-Wert zurückgibt, würde er `104`
zurückgeben, nicht `h`.

Um zu vermeiden, dass ein unerwarteter Wert zurückgegeben wird und dadurch
Fehler entstehen, die möglicherweise nicht sofort entdeckt werden, kompiliert
Rust diesen Code überhaupt nicht und verhindert so Missverständnisse in einem
frühen Stadium des Entwicklungsprozesses.

#### Bytes, skalare Werte und Graphemgruppen (grapheme clusters)! Oje!

Ein weiterer Punkt bei UTF-8 ist, dass es eigentlich drei relevante
Möglichkeiten gibt, Zeichenketten aus Rusts Perspektive zu betrachten: Als
Bytes, als skalare Werte und als Graphemgruppen (das, was wir am ehesten als
*Buchstaben* bezeichnen würden).

Wenn wir uns das in der Devanagari-Schrift geschriebene Hindi-Wort „नमस्ते“
ansehen, wird es als ein Vektor von `u8`-Werten gespeichert, der wie folgt
aussieht:

```text
[224, 164, 168, 224, 164, 174, 224, 164, 184, 224, 165, 141, 224, 164, 164,
224, 165, 135]
```

Das sind 18 Bytes, so wie ein Computer diese Daten letztendlich speichert. Wenn
wir sie als Unicode-Skalarwerte betrachten, also als das, was der Typ `char` in
Rust ist, sehen diese Bytes wie folgt aus:

```text
['न', 'म', 'स', '्', 'त', 'े']
```

Es gibt hier sechs `char`-Werte, aber der vierte und der sechste sind keine
Buchstaben: Sie sind diakritische Zeichen, die für sich allein genommen keinen
Sinn ergeben. Wenn wir sie schließlich als Graphemgruppen betrachten, erhalten
wir das, was eine Person die vier Buchstaben nennen würde, aus denen das
Hindi-Wort besteht:

```text
["न", "म", "स्", "ते"]
```

Rust bietet verschiedene Möglichkeiten zur Interpretation von rohen
Zeichenkettendaten, die von Computern gespeichert werden, sodass jedes Programm
die Interpretation wählen kann, die es benötigt, unabhängig davon, in welcher
menschlichen Sprache die Daten vorliegen. Ein letzter Grund, warum Rust uns
nicht erlaubt, eine Zeichenkette zu indexieren, um ein Zeichen zu erhalten,
ist, dass von Indexoperationen erwartet wird, dass sie immer in konstanter Zeit
(O(1)) erfolgen. Es ist jedoch nicht möglich, diese Zeitgarantie bei einem
`String` einzuhalten, da Rust den Inhalt von Anfang an bis zum Index durchgehen
müsste, um festzustellen, wie viele gültige Zeichen es gibt.

### Anteilige Zeichenketten

Die Indexierung einer Zeichenkette ist oft eine schlechte Idee, weil nicht klar
ist, was der Rückgabetyp der Zeichenketten-Indexoperation sein soll: Ein
Byte-Wert, ein Zeichen, eine Graphemgruppe oder ein Zeichenkettenanteilstyp.
Wenn du wirklich Indizes verwenden musst, um Zeichenkettenanteilstypen zu
erstellen, bittet Rust dich daher, genauer zu sein.

Anstatt `[]` mit einer einzelnen Zahl zu indizieren, kannst du `[]` mit einem
Bereich verwenden, um ein Zeichenkettenanteilstyp zu erstellen, der bestimmte
Bytes enthält:

```rust
let hello = "Здравствуйте";

let s = &hello[0..4];
```

Hier wird `s` ein `&str` sein, das die ersten 4 Bytes der Zeichenkette enthält.
Vorhin haben wir bereits erwähnt, dass jedes dieser Zeichen 2 Bytes lang ist,
was bedeutet, dass `s` gleich `Зд` ist.

Wenn wir versuchen würden, nur einen Teil der Bytes eines Zeichens mit etwas
wie `&hello[0..1]` zu zerschneiden, würde Rust das Programm zur Laufzeit
abbrechen, genauso als wenn mit einem ungültigen Index auf einen Vektor
zugegriffen würde:

```console
$ cargo run
   Compiling collections v0.1.0 (file:///projects/collections)
    Finished dev [unoptimized + debuginfo] target(s) in 0.43s
     Running `target/debug/collections`
thread 'main' panicked at 'byte index 1 is not a char boundary; it is inside 'З' (bytes 0..2) of `Здравствуйте`', src/libcore/str/mod.rs:2069:5
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
```

Bei der Verwendung von Bereichen zum Erstellen von Zeichenkettenanteilstypen
ist Vorsicht geboten, da dies zum Absturz deines Programms führen kann.

### Methoden zum Iterieren über Zeichenketten

Der beste Weg, um mit Teilen von Zeichenketten zu arbeiten, besteht darin,
explizit anzugeben, ob du Zeichen oder Bytes benötigst. Für einzelne
Unicode-Skalarwerte ist die Methode `chars` zu verwenden. Der Aufruf von
`chars` auf „Зд“ trennt zwei Werte vom Typ `char` heraus und gibt sie
zurück, und du kannst über das Ergebnis iterieren, um auf jedes Element
zuzugreifen:

```rust
for c in "Зд".chars() {
    println!("{}", c);
}
```

Dieser Code wird folgendes ausgeben:

```text
З
д
```

Die Methode `bytes` gibt jedes rohe Byte zurück, das für deinen
Verwendungszweck benötigt wird:

```rust
for b in "Зд".bytes() {
    println!("{}", b);
}
```

Dieser Code gibt die vier Bytes aus, aus denen diese Zeichenkette besteht:

```text
208
151
208
180
```

Aber denke daran, dass gültige Unicode-Skalarwerte aus mehr als 1 Byte bestehen
können.

Die Ermittlung von Graphemgruppen aus Zeichenketten wie bei der
Devanagari-Schrift ist komplex, sodass diese Funktionalität nicht von der
Standardbibliothek bereitgestellt wird. Kisten (crates) sind unter
[crates.io](https://crates.io/) verfügbar, falls du diese Funktionalität
benötigst.

### Zeichenketten sind nicht so einfach

Zusammenfassend kann man sagen, dass Zeichenketten kompliziert sind.
Verschiedene Programmiersprachen treffen unterschiedliche Entscheidungen
darüber, wie diese Komplexität dem Programmierer angezeigt wird. Rust hat sich
dafür entschieden, den korrekten Umgang mit Zeichenkettendaten zum
Standardverhalten für alle Rust-Programme zu machen, was bedeutet, dass
Programmierer sich im Vorfeld mehr Gedanken über den Umgang mit UTF-8-Daten
machen müssen. Dieser Zielkonflikt macht die Komplexität von Zeichenketten
größer als in anderen Programmiersprachen, aber er verhindert, dass du später
in deinem Entwicklungslebenszyklus mit Fehlern umgehen musst, wenn
Nicht-ASCII-Zeichen vorkommen.

Die gute Nachricht ist, dass die Standardbibliothek eine Vielzahl von
Funktionen bietet, die auf den Typen `String` und `&str` aufbauen, um diese
komplexen Situationen korrekt zu behandeln. In der Dokumentation findest du
nützliche Methoden wie `contains` zum Suchen in einer Zeichenkette und
`replace` zum Ersetzen von Teilen einer Zeichenkette durch eine andere
Zeichenkette.

Lass uns zu etwas weniger Kompliziertem übergehen: Hashtabellen!
