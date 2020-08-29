## Schlüssel mit zugehörigen Werten in Hashtabellen ablegen

Die letzte unserer allgemeinen Kollektionen ist die *Hashtabelle* (hash map).
Der Typ `HashMap<K, V>` speichert eine Zuordnung von Schlüsseln vom Typ `K` zu
Werten vom Typ `V`. Er tut dies über eine *Hashfunktion* (hash function), die
bestimmt, wie er diese Schlüssel und Werte im Speicher ablegt. Viele
Programmiersprachen unterstützen diese Art Datenstruktur, aber sie verwenden
oft einen anderen Namen, z.B. Hash, Abbildung (map), Objekt, Hashtabelle (hash
table), Wörterbuch (dictionary) oder assoziatives Array (associative array), um
nur einige zu nennen. Hashtabellen sind nützlich, wenn du Daten nicht wie bei
Vektoren über einen Index nachschlagen willst, sondern über einen Schlüssel,
der ein beliebiger Typ sein kann. Beispielsweise könntest du in einem Spiel den
Spielstand jedes Teams in einer Hashtabelle vermerken, in der die Schlüssel den
Teamnamen und die Werte den Spielstand des jeweiligen Teams darstellen. Wenn du
den Namen eines Teams angibst, kannst du seine Punktzahl abrufen.

In diesem Abschnitt gehen wir die grundlegende Programmierschnittstelle (API)
von Hashtabellen durch, aber viele weitere Leckerbissen verbergen sich in den
Funktionen, die in der Standardbibliothek für `HashMap<K, V>` definiert sind.
Weitere Informationen findest du wie immer in der
Standardbibliotheksdokumentation.

### Erstellen einer neuen Hashtabelle

Du kannst eine leere Hashtabelle mit `new` erstellen und Elemente mit `insert`
hinzufügen. In Codeblock 8-20 verfolgen wir die Ergebnisse zweier Mannschaften
mit den Namen Blau und Gelb. Das Team Blau startet mit 10 Punkten, das Team
Gelb mit 50 Punkten.

```rust
use std::collections::HashMap;

let mut scores = HashMap::new();

scores.insert(String::from("Blau"), 10);
scores.insert(String::from("Gelb"), 50);
```

<span class="caption">Codeblock 8-20: Erstellen einer neuen Hashtabelle und
Einfügen einiger Schlüssel und Werte</span>

Beachte, dass wir zuerst mit `use` die `HashMap` aus dem Kollektionsteil der
Standardbibliothek einbinden müssen. Von unseren drei allgemeinen Kollektionen
wird diese am seltensten verwendet, sodass sie nicht zu den Funktionalitäten
gehört, die automatisch in den Gültigkeitsbereich aufgenommen werden.
Hashtabellen werden auch weniger von der Standardbibliothek unterstützt; es
gibt zum Beispiel kein eingebautes Makro, um sie zu erzeugen.

Genau wie Vektoren speichern Hashtabellen ihre Daten im dynamischen Speicher. 
Obige `HashMap` hat Schlüssel vom Typ `String` und Werte vom Typ `i32`.
Hashtabellen sind wie Vektoren homogen: Alle Schlüssel müssen den gleichen Typ
haben und alle Werte müssen den gleichen Typ haben.

Eine andere Möglichkeit, eine Hashtabelle zu erstellen, besteht im Verwenden
von Iteratoren und der Methode `collect` für einen Vektor von Tupeln, wobei
jedes Tupel aus einem Schlüssel und seinem Wert besteht. Auf Iteratoren und die
dazu gehörenden Methoden werden wir im Abschnitt [„Eine Reihe von Elementen
verarbeiten mit Iteratoren“][iterators] in Kapitel 13 ausführlicher eingehen.
Die Methode `collect` sammelt Daten für zahlreiche Kollektionstypen,
einschließlich `HashMap`. Wenn wir z.B. die Teamnamen und Anfangsspielstände in
zwei getrennten Vektoren hätten, könnten wir die Methode `zip` verwenden, um
einen Vektor von Tupeln zu erstellen, in dem „Blau“ mit 10 gepaart ist, und so
weiter. Dann könnten wir die Methode `collect` verwenden, um diesen Vektor von
Tupeln in eine Hashtabelle umzuwandeln, wie in Codeblock 8-21 gezeigt wird.

```rust
use std::collections::HashMap;

let teams = vec![String::from("Blau"), String::from("Gelb")];
let initial_scores = vec![10, 50];

let mut scores: HashMap<_, _> =
    teams.into_iter().zip(initial_scores.into_iter()).collect();
```

<span class="caption">Codeblock 8-21: Erstellen einer Hashtabelle aus einer
Liste von Teams und einer Liste von Spielständen</span>

Die Typannotation `HashMap<_, _>` wird hier benötigt, weil `collect`
verschiedene Datenstrukturen als Rückgabetyp unterstützt und Rust nicht weiß,
welche du willst, es sei denn, du gibst sie an. Für die Typparameter der
Schlüssel- und Werttypen geben wir jedoch Unterstriche an, Rust kann anhand der
Datentypen in den Vektoren auf die Typen schließen, die die Hashtabelle
enthält. In Codeblock 8-21 wird der Schlüsseltyp `String` und der Werttyp `i32`
sein, genau wie die Typen in Codeblock 8-20.

### Hashtabellen und Eigentümerschaft

Bei Typen wie `i32`, die das Merkmal `Copy` implementieren, werden die Werte in
die Hashtabelle kopiert. Bei aneigenbaren Werten wie `String` werden die Werte
verschoben und die Hashtabelle ist Eigentümer dieser Werte, wie in Codeblock
8-22 gezeigt wird.

```rust
use std::collections::HashMap;

let field_name = String::from("Lieblingsfarbe");
let field_value = String::from("Blau");

let mut map = HashMap::new();
map.insert(field_name, field_value);
// field_name und field_value sind zu diesem Zeitpunkt ungültig.
// Versuche, sie zu benutzen und beobachte, welchen Kompilierfehler du erhältst!
```

<span class="caption">Codeblock 8-22: Zeigt, dass Schlüssel und Werte nach dem
Aufruf von `insert` Eigentum der Hashtabelle sind</span>

Wir können die Variablen `field_name` und `field_value` nicht mehr verwenden,
nachdem sie mit dem Aufruf von `insert` in die Hashtabelle verschoben wurden.

Wenn wir Referenzen auf Werte in die Hashtabelle einfügen, werden die Werte
nicht in die Hashtabelle verschoben. Die Werte, auf die die Referenzen zeigen,
müssen mindestens so lange gültig sein, wie die Hashtabelle gültig ist. Wir
werden mehr über diese Fragen im Abschnitt [„Referenzen validieren mit
Lebensdauern“][validating-references-with-lifetimes] in Kapitel 10 sprechen.

### Zugreifen auf Werte in einer Hashtabelle

Wir können einen Wert aus der Hashtabelle herausholen, indem wir die Methode
`get` mit ihrem Schlüssel aufrufen, wie in Codeblock 8-23 gezeigt.

```rust
use std::collections::HashMap;

let mut scores = HashMap::new();

scores.insert(String::from("Blau"), 10);
scores.insert(String::from("Geld"), 50);

let team_name = String::from("Blau");
let score = scores.get(&team_name);
```

<span class="caption">Codeblock 8-23: Zugreifen auf den Spielstand von Team
Blau in der Hashtabelle</span>

Hier wird `score` den Wert haben, der mit Team Blau assoziiert ist, und das
Ergebnis wird `Some(&10)` sein. Das Ergebnis ist in `Some` eingepackt, weil
`get` eine `Option<&V>` zurückgibt; wenn es keinen Wert für diesen Schlüssel in
der Hashtabelle gibt, gibt `get` den Wert `None` zurück. Das Programm muss die
`Option` auf eine Weise behandeln, die wir in Kapitel 6 besprochen haben.

Wir können über jedes Schlüssel-Wert-Paar in einer Hashtabelle auf ähnliche
Weise iterieren wie bei Vektoren, indem wir eine `for`-Schleife verwenden:

```rust
use std::collections::HashMap;

let mut scores = HashMap::new();

scores.insert(String::from("Blau"), 10);
scores.insert(String::from("Gelb"), 50);

for (key, value) in &scores {
    println!("{}: {}", key, value);
}
```

Dieser Code gibt alle Paare in einer beliebigen Reihenfolge aus:

```text
Gelb: 50
Blau: 10
```

### Aktualisieren einer Hashtabelle

Obwohl die Anzahl der Schlüssel und Werte wachsen kann, kann jedem Schlüssel
jeweils nur ein Wert zugeordnet werden. Wenn du die Daten in einer Hashtabelle
ändern willst, musst du entscheiden, wie der Fall zu behandeln ist, wenn einem
Schlüssel bereits ein Wert zugewiesen wurde. Du kannst den alten Wert durch den
neuen ersetzen und dabei den alten Wert völlig außer Acht lassen. Du kannst den
alten Wert behalten und den neuen Wert ignorieren und nur dann den neuen Wert
hinzufügen, wenn der Schlüssel noch *keinen* zugewiesenen Wert hat. Oder du
kannst den alten und neuen Wert kombinieren. Schauen wir uns an, wie diese
Varianten jeweils funktionieren!

#### Überschreiben eines Wertes

Wenn wir einen Schlüssel und einen Wert in eine Hashtabelle einfügen und dann
denselben Schlüssel mit einem anderen Wert einfügen, wird der mit diesem
Schlüssel assoziierte Wert ersetzt. Auch wenn der Code in Codeblock 8-24
zweimal `insert` aufruft, wird die Hashtabelle nur ein Schlüssel-Wert-Paar
enthalten, weil wir beide Male einen Wert für den Schlüssel des Teams Blau
einfügen.

```rust
use std::collections::HashMap;

let mut scores = HashMap::new();

scores.insert(String::from("Blau"), 10);
scores.insert(String::from("Blau"), 25);

println!("{:?}", scores);
```

<span class="caption">Codeblock 8-24: Ersetzen eines gespeicherten Wertes für
einen bestimmten Schlüssel</span>

Dieser Code wird `{"Blau": 25}` ausgeben. Der ursprüngliche Wert `10` wurde
überschrieben.

#### Nur einen Wert einfügen, wenn der Schlüssel keinen Wert hat

Es kommt oft vor, dass man zunächst prüfen will, ob ein bestimmter Schlüssel
einen Wert hat, und wenn dies nicht der Fall ist, einen Wert für ihn einzufügt.
Hashtabellen haben dafür eine spezielle Programmierschnittstelle (API) namens
`entry`, die den Schlüssel, den du prüfen willst, als Parameter nimmt. Der
Rückgabewert der Methode `entry` ist eine Aufzählung (enum) namens `Entry`, die
einen Wert repräsentiert, der existieren könnte oder auch nicht. Nehmen wir an,
wir wollen prüfen, ob der Schlüssel für das Team Gelb einen Wert hat. Wenn das
nicht der Fall ist, wollen wir den Wert 50 einfügen, und dasselbe gilt für das
Team Blau. Bei Verwendung von `entry` sieht der Code wie Codeblock 8-25 aus.

```rust
use std::collections::HashMap;

let mut scores = HashMap::new();
scores.insert(String::from("Blau"), 10);

scores.entry(String::from("Gelb")).or_insert(50);
scores.entry(String::from("Blau")).or_insert(50);

println!("{:?}", scores);
```

<span class="caption">Codeblock 8-25: Verwenden der Methode `entry` zum
Einfügen, nur wenn der Schlüssel nicht bereits einen Wert hat</span>

Die Methode `or_insert` von `Entry` ist so definiert, dass sie eine
veränderliche Referenz auf den Wert des entsprechenden `Entry`-Schlüssels
zurückgibt, wenn dieser Schlüssel existiert, andernfalls fügt sie den Parameter
als neuen Wert für diesen Schlüssel ein und gibt eine veränderliche Referenz
auf den neuen Wert zurück. Diese Technik ist viel sauberer, als die Logik
selbst zu schreiben, und sie harmoniert besser mit dem Ausleihenprüfer.

Der Code in Codeblock 8-25 gibt `{"Gelb": 50, "Blau": 10}` aus. Beim ersten
Aufruf von `entry` wird der Schlüssel von Team Gelb mit dem Wert 50 eingefügt,
da das Team Gelb noch keinen Wert hat. Der zweite Aufruf von `entry` wird die
Hashtabelle nicht verändern, da das Team Blau bereits den Wert 10 hat.

#### Aktualisieren eines Wertes auf Basis des alten Wertes

Ein weiterer gängiger Anwendungsfall für Hashtabellen besteht darin, den Wert
eines Schlüssels nachzuschlagen und ihn dann auf Basis des alten Wertes zu
aktualisieren. Beispielsweise zeigt Codeblock 8-26 einen Code, der zählt, wie
oft jedes Wort in einem Text vorkommt. Wir verwenden eine Hashtabelle mit den
Wörtern als Schlüssel und inkrementieren den Wert, um nachzuvollziehen, wie oft
wir dieses Wort schon gesehen haben. Wenn es das erste Mal ist, dass wir ein
Wort sehen, fügen wir zuerst den Wert 0 ein.

```rust
use std::collections::HashMap;

let text = "Hallo Welt wunderbare Welt";

let mut map = HashMap::new();

for word in text.split_whitespace() {
    let count = map.entry(word).or_insert(0);
    *count += 1;
}

println!("{:?}", map);
```

<span class="caption">Codeblock 8-26: Zählen des Vorkommens von Wörtern mit
Hilfe einer Hashtabelle, die Wörter speichert und zählt</span>

Dieser Code wird `{"Welt": 2, "wunderbare": 1, "Hallo": 1}` ausgeben. Die
Methode `or_insert` gibt tatsächlich eine veränderliche Referenz (`&mut V`) auf
den Wert für diesen Schlüssel zurück. Hier speichern wir diese veränderliche
Referenz in der Variablen `count`. Um diesen Wert zuzuweisen, müssen wir also
zuerst `count` mittels Sternoperator (`*`) dereferenzieren. Die veränderliche
Referenz verlässt den Gültigkeitsbereich am Ende der `for`-Schleife, sodass all
diese Änderungen sicher sind und von den Ausleihregeln erlaubt werden.

### Hash-Funktionen

Standardmäßig verwendet `HashMap` eine „kryptographisch starke“[^siphash]
Hash-Funktion, die gegen Denial-of-Service (DoS)-Attacken robust ist. Dies ist
nicht der schnellste verfügbare Hashing-Algorithmus, aber der Kompromiss
zugunsten einer höheren Sicherheit gegenüber einer geringeren Performanz ist es
Wert. Wenn du eine Performanzanalyse deines Codes machst und feststellst, dass
die Standard-Hash-Funktion für deine Zwecke zu langsam ist, kannst du zu einer
anderen Funktion wechseln, indem du eine andere Hash-Funktion angibst. Eine
Hash-Funktion ist ein Typ, der das Merkmal `BuildHasher` implementiert. Wir
werden in Kapitel 10 über Merkmale und ihre Implementierung sprechen. Du musst
nicht unbedingt deine eigene Hash-Funktion von Grund auf implementieren;
[crates.io](https://crates.io/) verfügt über Bibliotheken, die von anderen
Rust-Nutzern bereitgestellt werden und viele gängige Hash-Funktionen
implementieren.

[^siphash]: [https://www.131002.net/siphash/siphash.pdf](https://www.131002.net/siphash/siphash.pdf)

## Zusammenfassung

Vektoren, Zeichenketten und Hashtabellen bieten eine große Menge an
Funktionalität, die in Programmen benötigt wird, wenn du Daten speichern,
darauf zugreifen und sie verändern willst. Hier sind einige Übungen, für deren
Lösung du jetzt gerüstet sein solltest:

* Verwende bei einer Liste von ganzen Zahlen einen Vektor und gib den
  Mittelwert (Durchschnittswert), den Median (wenn sortiert, den Wert in der
  Mitte) und den Modus (den Wert, der am häufigsten vorkommt; eine Hashtabelle
  ist hier hilfreich) der Liste zurück.
* Wandle Zeichenketten in Schweinelatein (pig latin) um. Der erste Konsonant
  jedes Wortes wird an das Ende des Wortes verschoben und „ay“ angehängt,
  sodass „zuerst“ zu „uerst-zay“ wird. Bei Wörtern, die mit einem Vokal
  beginnen, wird stattdessen „hay“ an das Ende angefügt („ansehen“ wird zu
  „ansehen-hay“). Beachte die Details zur UTF-8-Kodierung!
* Erstelle mit Hilfe einer Hashtabelle und Vektoren eine Textschnittstelle, die
  es einem Benutzer ermöglicht, Mitarbeiternamen zu einer Abteilung in einem
  Unternehmen hinzuzufügen. Zum Beispiel „Sally zur Technik hinzufügen“ oder
  „Amir zum Vertrieb hinzufügen“. Lass den Benutzer dann eine alphabetisch
  sortierte Liste aller Personen in einer Abteilung oder aller Personen in der
  Firma nach Abteilung ausgeben.

Die API-Dokumentation der Standard-Bibliothek beschreibt Methoden für Vektoren,
Zeichenketten und Hashtabellen, die für diese Übungen hilfreich sind!

Wir steigen in komplexere Programme ein, in denen Operationen fehlschlagen
können, daher ist es ein perfekter Zeitpunkt, auf die Fehlerbehandlung
einzugehen. Das werden wir als nächstes tun!

[iterators]: ch13-02-iterators.html
[validating-references-with-lifetimes]:
ch10-03-lifetime-syntax.html
