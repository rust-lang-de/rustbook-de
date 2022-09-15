## Schlüssel mit zugehörigen Werten in Hashtabellen ablegen

Die letzte unserer allgemeinen Kollektionen ist die *Hashtabelle* (hash map).
Der Typ `HashMap<K, V>` speichert eine Zuordnung von Schlüsseln vom Typ `K` zu
Werten vom Typ `V` mittels einer *Hashfunktion* (hash function), die bestimmt,
wie er diese Schlüssel und Werte im Speicher ablegt. Viele Programmiersprachen
unterstützen diese Art Datenstruktur, aber sie verwenden oft einen anderen
Namen, z.B. Hash, Abbildung (map), Objekt, Hashtabelle (hash table), Wörterbuch
(dictionary) oder assoziatives Array (associative array), um nur einige zu
nennen. Hashtabellen sind nützlich, wenn du Daten nicht wie bei Vektoren über
einen Index nachschlagen willst, sondern über einen Schlüssel, der ein
beliebiger Typ sein kann. Beispielsweise könntest du in einem Spiel den
Spielstand jedes Teams in einer Hashtabelle vermerken, in der die Schlüssel den
Teamnamen und die Werte den Spielstand des jeweiligen Teams darstellen. Wenn du
den Namen eines Teams angibst, kannst du seine Punktzahl abrufen.

In diesem Abschnitt gehen wir die grundlegende Programmierschnittstelle (API)
von Hashtabellen durch, aber viele weitere Leckerbissen verbergen sich in den
Funktionen, die in der Standardbibliothek für `HashMap<K, V>` definiert sind.
Weitere Informationen findest du wie immer in der
Standardbibliotheksdokumentation.

### Erstellen einer neuen Hashtabelle

Ein Weg um eine leere Hashtabelle zu erzeugen ist mit `new` und um Elemente
hinzuzufügen mit `insert`. In Codeblock 8-20 verfolgen wir die Ergebnisse
zweier Mannschaften mit den Namen Blau und Gelb. Das Team Blau startet mit 10
Punkten, das Team Gelb mit 50 Punkten.

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

Genau wie Vektoren speichern Hashtabellen ihre Daten im Haldenspeicher. 
Obige `HashMap` hat Schlüssel vom Typ `String` und Werte vom Typ `i32`.
Hashtabellen sind wie Vektoren homogen: Alle Schlüssel müssen denselben Typ
haben und alle Werte müssen denselben Typ haben.

### Zugreifen auf Werte in einer Hashtabelle

Wir können einen Wert aus der Hashtabelle herausholen, indem wir die Methode
`get` mit ihrem Schlüssel aufrufen, wie in Codeblock 8-21 gezeigt.

```rust
use std::collections::HashMap;

let mut scores = HashMap::new();

scores.insert(String::from("Blau"), 10);
scores.insert(String::from("Geld"), 50);

let team_name = String::from("Blau");
let score = scores.get(&team_name);
```

<span class="caption">Codeblock 8-21: Zugreifen auf den Spielstand von Team
Blau in der Hashtabelle</span>

Hier wird `score` den Wert haben, der mit Team Blau assoziiert ist, und das
Ergebnis wird `10` sein. Die Methode `get` gibt eine `Option<&V>` zurück;
wenn es keinen Wert für diesen Schlüssel in der Hashtabelle gibt, gibt `get`
den Wert `None` zurück. Dieses Programm behandelt die `Option`, indem es
`unwrap_or` aufruft, um `score` auf Null zu setzen, wenn `scores` keinen
Eintrag für den Schlüssel hat.

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

### Aktualisieren einer Hashtabelle

Obwohl die Anzahl der Schlüssel- und Wertepaare vergrößerbar ist, kann jedem
eindeutigen Schlüssel jeweils nur ein Wert zugeordnet werden (aber nicht
umgekehrt: Zum Beispiel könnten sowohl das blaue Team als auch das gelbe Team
den Wert 10 in der Hashtabelle `scores` gespeichert haben).

Wenn du die Daten in einer Hashtabelle ändern willst, musst du entscheiden, wie
der Fall zu behandeln ist, wenn einem Schlüssel bereits ein Wert zugewiesen
wurde. Du kannst den alten Wert durch den neuen ersetzen und dabei den alten
Wert völlig außer Acht lassen. Du kannst den alten Wert behalten und den neuen
Wert ignorieren und nur dann den neuen Wert hinzufügen, wenn der Schlüssel noch
*keinen* zugewiesenen Wert hat. Oder du kannst den alten und neuen Wert
kombinieren. Schauen wir uns an, wie diese Varianten jeweils funktionieren!

#### Überschreiben eines Wertes

Wenn wir einen Schlüssel und einen Wert in eine Hashtabelle einfügen und dann
denselben Schlüssel mit einem anderen Wert einfügen, wird der mit diesem
Schlüssel assoziierte Wert ersetzt. Auch wenn der Code in Codeblock 8-23
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

<span class="caption">Codeblock 8-23: Ersetzen eines gespeicherten Wertes für
einen bestimmten Schlüssel</span>

Dieser Code wird `{"Blau": 25}` ausgeben. Der ursprüngliche Wert `10` wurde
überschrieben.

#### Nur einen Schlüssel und Wert einfügen, wenn der Schlüssel nicht vorhanden ist

Es ist üblich, zu prüfen, ob ein bestimmter Schlüssel bereits in der
Hashtabelle mit einem Wert vorhanden ist, und dann folgende Maßnahmen zu
ergreifen: Wenn der Schlüssel in der Hashtabelle vorhanden ist, sollte der
vorhandene Wert so bleiben, wie er ist. Wenn der Schlüssel nicht vorhanden ist,
füge ihn und einen Wert für ihn ein.

Hashtabellen haben dafür eine spezielle Programmierschnittstelle (API) namens
`entry`, die den Schlüssel, den du prüfen willst, als Parameter nimmt. Der
Rückgabewert der Methode `entry` ist eine Aufzählung (enum) namens `Entry`, die
einen Wert repräsentiert, der existieren könnte oder auch nicht. Nehmen wir an,
wir wollen prüfen, ob der Schlüssel für das Team Gelb einen Wert hat. Wenn das
nicht der Fall ist, wollen wir den Wert 50 einfügen, und dasselbe gilt für das
Team Blau. Bei Verwendung von `entry` sieht der Code wie Codeblock 8-24 aus.

```rust
use std::collections::HashMap;

let mut scores = HashMap::new();
scores.insert(String::from("Blau"), 10);

scores.entry(String::from("Gelb")).or_insert(50);
scores.entry(String::from("Blau")).or_insert(50);

println!("{:?}", scores);
```

<span class="caption">Codeblock 8-24: Verwenden der Methode `entry` zum
Einfügen, nur wenn der Schlüssel nicht bereits einen Wert hat</span>

Die Methode `or_insert` von `Entry` ist so definiert, dass sie eine
veränderliche Referenz auf den Wert des entsprechenden `Entry`-Schlüssels
zurückgibt, wenn dieser Schlüssel existiert, andernfalls fügt sie den Parameter
als neuen Wert für diesen Schlüssel ein und gibt eine veränderliche Referenz
auf den neuen Wert zurück. Diese Technik ist viel sauberer, als die Logik
selbst zu schreiben, und sie harmoniert besser mit dem Ausleihenprüfer.

Der Code in Codeblock 8-24 gibt `{"Gelb": 50, "Blau": 10}` aus. Beim ersten
Aufruf von `entry` wird der Schlüssel von Team Gelb mit dem Wert 50 eingefügt,
da das Team Gelb noch keinen Wert hat. Der zweite Aufruf von `entry` wird die
Hashtabelle nicht verändern, da das Team Blau bereits den Wert 10 hat.

#### Aktualisieren eines Wertes auf Basis des alten Wertes

Ein weiterer gängiger Anwendungsfall für Hashtabellen besteht darin, den Wert
eines Schlüssels nachzuschlagen und ihn dann auf Basis des alten Wertes zu
aktualisieren. Beispielsweise zeigt Codeblock 8-25 einen Code, der zählt, wie
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

<span class="caption">Codeblock 8-25: Zählen des Vorkommens von Wörtern mit
Hilfe einer Hashtabelle, die Wörter speichert und zählt</span>

Dieser Code gibt `{"Welt": 2, "wunderbare": 1, "Hallo": 1}` aus. Es kann sein,
dass dieselben Schlüssel/Wert-Paare in einer anderen Reihenfolge ausgegeben
werden: Du erinnerst dich an den Abschnitt [„Zugreifen auf Werte in einer
Hashtabelle“][access], dass die Iteration über eine Hashtabelle in beliebiger
Reihenfolge erfolgt.

Die Methode `split_whitespace` gibt einen Iterator über durch Leerzeichen
getrennte Sub-Anteilstypen des Wertes in `text` zurück. Die Methode `or_insert`
gibt eine veränderliche Referenz (`&mut V`) auf den Wert für den angegebenen
Schlüssel zurück. Hier speichern wir diese veränderlichen Referenz in der
Variablen `count`. Um diesen Wert zuzuweisen, müssen wir also zuerst `count`
mit dem Stern (`*`) derefenzieren. Die veränderliche Referenz verlässt am Ende
der `for`-Schleife dem Gültigkeitsbereich, sodass alle diese Änderungen sicher
und gemäß der Ausleihregeln zulässig sind.

### Hash-Funktionen

Standardmäßig verwendet `HashMap` eine Hash-Funktion namens *SipHash*, die robust
gegen Denial-of-Service-Angriffe (DoS) mit Hash-Tabellen[^siphash] ist. Dies
ist nicht der schnellste verfügbare Hashing-Algorithmus, aber der Kompromiss
zugunsten einer höheren Sicherheit gegenüber einer geringeren Performanz ist es
Wert. Wenn du eine Performanzanalyse deines Codes machst und feststellst, dass
die Standard-Hash-Funktion für deine Zwecke zu langsam ist, kannst du zu einer
anderen Funktion wechseln, indem du eine andere Hash-Funktion angibst. Eine
*Hash-Funktion* ist ein Typ, der das Merkmal `BuildHasher` implementiert. Wir
werden in Kapitel 10 über Merkmale und ihre Implementierung sprechen. Du musst
nicht unbedingt deine eigene Hash-Funktion von Grund auf implementieren;
[crates.io](https://crates.io/) verfügt über Bibliotheken, die von anderen
Rust-Nutzern bereitgestellt werden und viele gängige Hash-Funktionen
implementieren.

[^siphash]: <https://en.wikipedia.org/wiki/SipHash>

## Zusammenfassung

Vektoren, Zeichenketten und Hashtabellen bieten eine große Menge an
Funktionalität, die in Programmen benötigt wird, wenn du Daten speichern,
darauf zugreifen und sie verändern willst. Hier sind einige Übungen, für deren
Lösung du jetzt gerüstet sein solltest:

* Verwende bei einer Liste von ganzen Zahlen einen Vektor und gib den
  den Median (wenn sortiert, den Wert in der Mitte) und den Modus (den Wert,
  der am häufigsten vorkommt; eine Hashtabelle ist hier hilfreich) der Liste
  zurück.
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

[access]: #zugreifen-auf-werte-in-einer-hashtabelle
[validating-references-with-lifetimes]:
ch10-03-lifetime-syntax.html
