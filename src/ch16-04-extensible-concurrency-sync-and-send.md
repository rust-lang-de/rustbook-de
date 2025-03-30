## Erweiterbare Nebenläufigkeit mit den Merkmalen (traits) `Send` und `Sync`

Interessanterweise war fast jede Nebenläufigkeitsfunktionalität, über die wir
bisher in diesem Kapitel gesprochen haben, Teil der Standardbibliothek, nicht
der Sprache. Deine Möglichkeiten für den Umgang mit Nebenläufigkeit sind nicht
auf die Sprache oder die Standardbibliothek beschränkt; du kannst deine eigenen
Nebenläufigkeitsfunktionalitäten schreiben oder die von anderen geschriebenen
verwenden.

Zu den wichtigsten Nebenläufigkeitskonzepten, die in die Sprache und nicht in
die Standardbibliothek eingebettet sind, gehören jedoch die Merkmale `Send` und
`Sync` in `std::marker`.

### Erlauben der Eigentümerschaftübertragung zwischen Strängen mit `Send`

Das Markierungsmerkmal (marker trait) `Send` zeigt an, dass die
Eigentümerschaft an Werten des Typs, der `Send` implementiert, zwischen
Strängen (threads) übertragen werden kann. Fast jeder Rust-Typ implementiert
`Send`, aber es gibt einige Ausnahmen, einschließlich `Rc<T>`: Dieser kann
nicht `Send` sein, denn wenn du einen `Rc<T>`-Wert geklont hast und versucht
hast, die Eigentümerschaft am Klon auf einen anderen Strang zu übertragen,
könnten beide Stränge gleichzeitig den Referenzzähler aktualisieren. Aus diesem
Grund ist `Rc<T>` für die Verwendung in einsträngigen Situationen
implementiert, in denen du nicht die Strang-sichere Performanzeinbuße zahlen
willst.

Daher stellen das Typsystem und die Merkmalsabgrenzungen (trait bounds) von
Rust sicher, dass du niemals versehentlich einen `Rc<T>`-Wert unsicher zwischen
Strängen senden kannst. Als wir dies in Codeblock 16-14 versuchten, erhielten
wir folgenden Fehler: Das Merkmal `Send` ist für `Rc<Mutex<i32>>` nicht
implementiert. Als wir zu `Arc<T>` wechselten, das `Send` implementiert, ließ
sich der Code kompilieren.

Jeder Typ, der vollständig aus `Send`-Typen besteht, wird automatisch auch als
`Send` markiert. Fast alle primitiven Typen implementieren `Send`, abgesehen
von Roh-Zeigern, die wir in Kapitel 20 besprechen werden.

### Erlauben des Zugriffs von mehreren Strängen mit `Sync`

Das Markierungsmerkmal `Sync` zeigt an, dass es sicher ist, den Typ, der `Sync`
implementiert, von mehreren Strängen zu referenzieren. Mit anderen Worten,
jeder Typ `T` implementiert `Sync`, wenn `&T` (eine unveränderbare Referenz auf
`T`) `Send` implementiert, was bedeutet, dass die Referenz sicher an einen
anderen Strang gesendet werden kann. Ähnlich wie bei `Send` implementieren
primitive Typen `Sync`, und Typen, die vollständig aus Typen bestehen, die
`Sync` implementieren, implementieren ebenfalls `Sync`.

Der intelligente Zeiger `Rc<T>` implementiert ebenfalls nicht `Sync`, aus
denselben Gründen, warum er nicht `Send` implementiert. Der Typ `RefCell<T>`
(über den wir in Kapitel 15 gesprochen haben) und die Familie der verwandten
`Cell<T>`-Typen implementieren nicht `Sync`. Die Implementierung der
Ausleihenprüfung (borrow checking), die `RefCell<T>` zur Laufzeit durchführt,
ist nicht Strang-sicher. Der intelligente Zeiger `Mutex<T>` implementiert
`Sync` und kann verwendet werden, um den Zugriff mit mehreren Strängen zu
teilen, wie du in [„Gemeinsames Nutzen eines `Mutex<T>` von mehreren
Strängen“][sharing-mutext] gesehen hast.

### Manuelles Implementieren von `Send` und `Sync` ist unsicher

Da Typen, die sich ausschließlich aus Typen zusammensetzen, die die Merkmale
`Send` und `Sync` implementieren, automatisch auch `Send` und `Sync`
implementieren, müssen wir diese Merkmale nicht manuell implementieren. Als
Markierungsmerkmale haben sie noch nicht einmal irgendwelche Methoden, um sie
zu implementieren. Sie sind nur nützlich, um Invarianten in Bezug auf die
Nebenläufigkeit zu erzwingen.

Das manuelle Implementieren dieser Merkmale beinhaltet das Schreiben von
unsicherem Rust-Code. Wir werden über das Verwenden von unsicherem Rust-Code in
Kapitel 20 sprechen; für den Moment ist die wichtige Information, dass das
Erstellen neuer nebenläufiger Typen, die nicht aus `Send`- und `Sync`-Teilen
bestehen, sorgfältige Überlegungen erfordert, um die Sicherheitsgarantien
aufrechtzuerhalten. [„Das Rustonomicon“][nomicon3] enthält weitere
Informationen über diese Garantien und wie man sie aufrechterhalten kann.

## Zusammenfassung

Dies ist nicht das letzte Mal, dass du in diesem Buch der Nebenläufigkeit
begegnest: Das nächste Kapitel befasst sich mit asynchroner Programmierung, und
das Projekt in Kapitel 21 wird die Konzepte in diesem Kapitel in einer
realistischeren Situation anwenden als die hier besprochenen kleineren
Beispiele.

Wie bereits erwähnt, ist nur sehr wenig davon, wie Rust mit Nebenläufigkeit
umgeht, Teil der Sprache; viele Nebenläufigkeitslösungen sind in Kisten
(crates) implementiert. Diese entwickeln sich schneller als die
Standardbibliothek. Stelle also sicher, dass du online nach den aktuellen,
hochmodernen Kisten suchst, die in mehrsträngigen Situationen verwendet werden
können.

Die Rust-Standardbibliothek bietet Kanäle (channels) für die
Nachrichtenübermittlung und intelligente Zeigertypen wie `Mutex<T>` und
`Arc<T>`, die sicher in nebenläufigen Kontexten verwendet werden können. Das
Typsystem und der Ausleihenprüfer stellen sicher, dass der Code, der diese
Lösungen verwendet, nicht mit Daten-Wettlaufsituationen (data races) oder
ungültigen Referenzen endet. Sobald du deinen Code zum Kompilieren gebracht
hast, kannst du sicher sein, dass er problemlos mit mehreren Strängen läuft,
ohne die schwer aufspürbaren Fehler, die in anderen Sprachen üblich sind.
Nebenläufige Programmierung ist kein Konzept mehr, vor dem man sich fürchten
muss: Gehe hinaus und mache deine Programme nebenläufig &ndash; furchtlos!

[sharing-mutext]:
ch16-03-shared-state.html#gemeinsames-nutzen-eines-mutext-von-mehreren-strängen
[nomicon3]: https://doc.rust-lang.org/nomicon/index.html
