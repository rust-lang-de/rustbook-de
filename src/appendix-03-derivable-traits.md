## Anhang C: Ableitbare Merkmale (traits)

An verschiedenen Stellen im Buch haben wir das Attribut `derive` besprochen,
das du auf eine Struktur- oder Aufzählungsdefinition anwenden kannst. Das
Attribut `derive` generiert Code, der ein Merkmal (trait) mit seiner eigenen
Standard-Implementierung auf dem Typ implementiert, den du mit der
`derive`-Syntax annotiert hast.

In diesem Anhang findest du eine Referenz aller Merkmale in der
Standardbibliothek, die du mit `derive` verwenden kannst. Jeder Abschnitt
umfasst:

* Welche Operatoren und Methoden nach Ableiten dieses Merkmals ermöglicht
  werden
* Was die Implementierung des durch `derive` bereitgestellten Merkmals bewirkt
* Was die Implementierung des Merkmals über den Typ aussagt
* Die Bedingungen, unter denen du das Merkmal implementieren darfst oder nicht
* Beispiele für Operationen, die dieses Merkmal erfordern

Wenn du ein anderes Verhalten wünschst als das, das durch das Attribut `derive`
bereitgestellt wird, schaue in die [Standard-Bibliotheksdokumentation][std-lib]
zu den Merkmalen, um zu erfahren, wie sie manuell implementiert werden können.

Diese hier aufgelisteten Merkmale sind die einzigen, die von der
Standardbibliothek definiert werden und die mit `derive` in deinen Typen
implementiert werden können. Andere in der Standardbibliothek definierte
Merkmale haben kein sinnvolles Standardverhalten, sodass es an dir liegt, sie
so zu implementieren, wie es für dein Vorhaben sinnvoll ist.

Ein Beispiel für ein Merkmal, das nicht abgeleitet werden kann, ist `Display`,
das die Formatierung für Endbenutzer übernimmt. Du solltest immer eine
geeignete Art und Weise in Betracht ziehen, einen Typ für einen Endbenutzer
anzuzeigen. Welche Teile des Typs sollte ein Endbenutzer sehen dürfen? Welche
Teile würden sie für relevant halten? Welches Datenformat wäre für sie am
relevantesten? Der Rust-Compiler verfügt nicht über dieses Wissen, sodass er
kein angemessenes Standardverhalten für dich bereitstellen kann.

Die Liste der ableitbaren Merkmale in diesem Anhang ist nicht vollständig:
Bibliotheken können `derive` für ihre eigenen Merkmale implementieren, sodass
die Liste der Merkmale, die du mit `derive` verwenden kannst, wahrlich
unbegrenzt ist. Das Implementieren von `derive` verwendet ein prozedurales
Makro, das im Abschnitt [„Makros“][macros] in Kapitel 19 behandelt wird.

### `Debug` für die Programmierer-Ausgabe

Das Merkmal `Debug` ermöglicht das Debuggen von Formatierungen in
Formatierungszeichenketten, die du durch Angeben von `:?` innerhalb Platzhalter
`{}` angibst.

Das Merkmal `Debug` erlaubt es dir, Instanzen eines Typs zu Debugging-Zwecken
auszugeben, sodass du und andere Programmierer, die deinen Typ verwenden, eine
Instanz zu einem bestimmten Zeitpunkt der Programmausführung untersuchen
können.

Das Merkmal `Debug` ist beispielsweise beim Verwenden des Makros `assert_eq!`
erforderlich. Dieses Makro gibt die Werte der Instanzen, die als Argumente
angegeben wurden, aus, wenn die Gleichheitszusicherung fehlschlägt, damit
Programmierer sehen können, warum die beiden Instanzen nicht gleich waren.

### `PartialEq` und `Eq` für Gleichheitsvergleiche

Das Merkmal `PartialEq` erlaubt dir, Instanzen eines Typs auf Gleichheit zu
prüfen und ermöglicht das Verwenden der Operatoren `==` und `!=`.

Das Ableiten von `PartialEq` implementiert die Methode `eq`. Wenn `PartialEq`
für Strukturen abgeleitet wird, sind zwei Instanzen nur dann gleich, wenn
*alle* Felder gleich sind, und die Instanzen sind nicht gleich, wenn wenigstens
ein Feld nicht gleich ist. Beim Ableiten für Aufzählungen ist jede Variante
gleich sich selbst und nicht gleich den anderen Varianten.

Das Merkmal `PartialEq` ist beispielsweise beim Verwenden des Makros
`assert_eq!` erforderlich, das in der Lage sein muss, zwei Instanzen eines Typs
auf Gleichheit zu prüfen.

Das Merkmal `Eq` hat keine Methoden. Sein Zweck ist es, zu signalisieren, dass
für jeden Wert des annotierten Typs der Wert gleich sich selbst ist. Das
Merkmal `Eq` kann nur auf Typen angewandt werden, die auch `PartialEq`
implementieren, obwohl nicht alle Typen, die `PartialEq` implementieren, `Eq`
implementieren können. Ein Beispiel dafür sind Fließkomma-Zahlentypen: Die
Implementierung von Fließkomma-Zahlen besagt, dass zwei Instanzen des
Keine-Zahl-Wertes (`NaN`) nicht gleichwertig sind.

Ein Beispiel dafür, wann `Eq` erforderlich ist, ist für Schlüssel in einer
`HashMap<K, V>`, damit `HashMap<K, V>` erkennen kann, ob zwei Schlüssel gleich
sind.

### `PartialOrd` und `Ord` für Sortiervergleiche

Das Merkmal `PartialOrd` erlaubt dir, Instanzen eines Typs zum Sortieren zu
vergleichen. Ein Typ, der `PartialOrd` implementiert, kann mit den Operatoren
`<`, `>`, `<=` und `>=` verwendet werden. Du kannst das Merkmal `PartialOrd`
nur auf Typen anwenden, die auch `PartialEq` implementieren.

Das Ableiten von `PartialOrd` implementiert die Methode `partial_cmp`, die eine
`Option<Ordering>` zurückgibt, die `None` ist, wenn die angegebenen Werte nicht
vergleichbar sind. Ein Beispiel für einen Wert, der nicht vergleichbar ist,
obwohl die meisten Werte dieses Typs verglichen werden können, ist die
Fließkommazahl `NaN`. Der Aufruf von `partial_cmp` mit einer beliebigen
Fließkommazahl und dem Fließkommawert `NaN` ergibt `None`.

Beim Ableiten auf Strukturen vergleicht `PartialOrd` zwei Instanzen, indem es
den Wert in jedem Feld in der Reihenfolge vergleicht, in der die Felder in der
Strukturdefinition erscheinen. Beim Ableiten auf Aufzählungen werden Varianten,
die in der Aufzählungsdefinition früher deklariert sind, als kleiner als die
später aufgeführten Varianten betrachtet.

Das Merkmal `PartialOrd` ist z.B. für die Methode `gen_range` aus der Kiste
`rand` erforderlich, die einen Zufallswert aus einem Wertebereich erzeugt, der
durch einen Bereichsausdruck festgelegt wird.

Das Merkmal `Ord` erlaubt dir zu wissen, dass für zwei beliebige Werte des
annotierten Typs eine gültige Reihenfolge existiert. Das Merkmal `Ord`
implementiert die Methode `cmp`, die `Ordering` statt `Option<Ordering>`
zurückgibt, weil eine gültige Reihenfolge immer möglich sein wird. Du kannst
das Merkmal `Ord` nur auf Typen anwenden, die auch `PartialOrd` und `Eq`
implementieren (und `Eq` erfordert `PartialEq`). Beim Ableiten auf Strukturen
und Aufzählungen verhält sich `cmp` genauso wie die abgeleitete Implementierung
für `partial_cmp` mit `PartialOrd`.

Ein Beispiel dafür, wann `Ord` erforderlich ist, ist das Speichern von Werten
in einem `BTreeSet<T>`, einer Datenstruktur, die Daten auf Grundlage der
Sortierreihenfolge der Werte speichert.

### `Clone` und `Copy` zum Duplizieren von Werten

Das Merkmal `Clone` erlaubt es dir, explizit eine tiefe Kopie eines Wertes zu
erstellen, und der Vervielfältigungsprozess könnte die Ausführung von
beliebigem Code und das Kopieren von Daten im Haldenspeicher beinhalten.
Siehe den Abschnitt [„Wege, wie Variablen und Daten interagieren: Klonen
(clone)“][ways-variables-and-data-interact-clone] in Kapitel 4 für weitere
Informationen zu `Clone`.

Das Ableiten von `Clone` implementiert die Methode `clone`, die, wenn sie für
den gesamten Typ implementiert ist, `clone` auf jedem der Teile des Typs
aufruft. Das bedeutet, dass alle Felder oder Werte des Typs auch `Clone`
implementieren müssen, um `Clone` abzuleiten.

Ein Beispiel dafür, wann `Clone` erforderlich ist, ist der Aufruf der Methode
`to_vec` auf einem Anteilstyp. Der Anteilstyp besitzt die Typ-Instanzen nicht,
die er enthält, aber der von `to_vec` zurückgegebene Vektor muss seine
Instanzen besitzen, also ruft `to_vec` bei jedem Element `clone` auf. Daher
muss der im Anteilstyp gespeicherte Typ `Clone` implementieren.

Das Merkmal `Copy` erlaubt es dir, einen Wert zu duplizieren, indem nur die auf
dem Stapelspeicher gespeicherten Bits kopiert werden; es ist kein spezieller
Code notwendig. Weitere Informationen zu `Copy` findest du im Abschnitt [„Nur
Stapelspeicher-Daten: Kopieren (copy)“][stack-only-data-copy] in Kapitel 4.

Das Merkmal `Copy` definiert keine Methoden, um Programmierer daran zu hindern,
diese Methoden zu überladen und die Annahme zu verletzen, dass kein spezieller
Code ausgeführt wird. Auf diese Weise können alle Programmierer davon ausgehen,
dass das Kopieren eines Wertes sehr schnell gehen wird.

Du kannst `Copy` auf jeden Typ ableiten, dessen Teile alle `Copy`
implementieren. Du kannst das Merkmal `Copy` nur auf Typen anwenden, die auch
`Clone` implementieren, weil ein Typ, der `Copy` implementiert, eine triviale
Implementierung von `Clone` hat, das die gleiche Aufgabe wie `Copy` erfüllt.

Das Merkmal `Copy` ist selten erforderlich; Typen, die `Copy` implementieren,
verfügen über Optimierungen, d.h. du mussst nicht `clone` aufrufen, was den
Code prägnanter macht.

Alles, was mit `Copy` möglich ist, kannst du auch mit `Clone` erreichen, aber
der Code könnte langsamer sein oder an manchen Stellen `clone` erforderlich
machen.

### `Hash` für die Abbildung eines Wertes auf einen Wert fester Größe

Das Merkmal `Hash` erlaubt es dir, eine Instanz eines Typs beliebiger Größe zu
nehmen und diese Instanz mithilfe einer Hash-Funktion auf einen Wert fester
Größe abzubilden. Das Ableiten von `Hash` implementiert die Methode `hash`. Die
abgeleitete Implementierung der Methode `hash` kombiniert das Ergebnis des
Aufrufs von `hash` für alle Teile des Typs, d.h. alle Felder oder Werte müssen
ebenfalls `Hash` implementieren, um `Hash` abzuleiten.

Ein Beispiel dafür, wann `Hash` erforderlich ist, ist das Speichern von
Schlüsseln in einer `HashMap<K, V>`, um Daten effizient zu speichern.

### `Default` für Standardwerte

Das Merkmal `Default` erlaubt es dir, einen Standardwert für einen Typ zu
definieren. Das Ableiten von `Default` implementiert die Funktion `default`.
Die abgeleitete Implementierung der Funktion `default` ruft die Funktion
`default` für jeden Teil des Typs auf, d.h. alle Felder oder Werte in dem Typ
müssen auch `Default` implementieren, um `Default` abzuleiten.

Die Funktion `Default::default` wird häufig in Kombination mit der Syntax zur
Aktualisierung von Strukturen verwendet, die im Abschnitt [„Instanzen aus
anderen Instanzen erzeugen mit der
Strukturaktualisierungssyntax“][creating-instances-from-other-instances-with-struct-update-syntax]
in Kapitel 5 besprochen wird. Du kannst einige Felder einer Struktur anpassen
und dann einen Standardwert für den Rest der Felder festlegen und verwenden,
indem du `...Default::default()` schreibst.

Das Merkmal `Default` ist erforderlich, wenn du die Methode `unwrap_or_default`
z.B. auf Instanzen von `Option<T>` verwendest. Wenn die `Option<T>` den Wert
`None` hat, gibt die Methode `unwrap_or_default` das Ergebnis von
`Default::default` für den Typ `T` zurück, der in `Option<T>` gespeichert ist.

[creating-instances-from-other-instances-with-struct-update-syntax]:
ch05-01-defining-structs.html#instanzen-aus-anderen-instanzen-erzeugen-mit-der-strukturaktualisierungssyntax
[macros]: ch19-06-macros.html
[stack-only-data-copy]: ch04-01-what-is-ownership.html#nur-stapelspeicher-daten-kopieren-copy
[std-lib]: https://doc.rust-lang.org/std/index.html
[ways-variables-and-data-interact-clone]:
ch04-01-what-is-ownership.html#wege-wie-variablen-und-daten-interagieren-klonen-clone
