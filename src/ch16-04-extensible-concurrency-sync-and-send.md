## Erweiterbare Nebenläufigkeit mit den Merkmalen (traits) `Sync` und `Send`

Interessanterweise hat die Sprache Rust *sehr wenige*
Nebenläufigkeitsfunktionalitäten. Fast jede Nebenläufigkeitsfunktionalität,
über die wir bisher in diesem Kapitel gesprochen haben, war Teil der
Standardbibliothek, nicht der Sprache. Deine Möglichkeiten für den Umgang mit
Nebenläufigkeit sind nicht auf die Sprache oder die Standardbibliothek
beschränkt; du kannst deine eigenen Nebenläufigkeitsfunktionalitäten schreiben
oder die von anderen geschriebenen verwenden.

In der Sprache sind jedoch zwei Nebenläufigkeitskonzepte eingebettet: Die
`std::marker`-Merkmale (traits) `Sync` und `Send`.

### Erlauben der Eigentümerschaftübertragung zwischen Strängen mit `Send`

Das Markierungsmerkmal (marker trait) `Send` zeigt an, dass die
Eigentümerschaft an Werten des Typs, der `Send` implementiert, zwischen
Strängen (threads) übertragen werden kann. Fast jeder Rust-Typ ist `Send`, aber
es gibt einige Ausnahmen, einschließlich `Rc<T>`: Dieser kann nicht `Send`
sein, denn wenn du einen `Rc<T>` Wert geklont hast und versucht hast, die
Eigentümerschaft am Klon auf einen anderen Strang zu übertragen, könnten beide
Stränge gleichzeitig die Referenzzahl aktualisieren. Aus diesem Grund ist
`Rc<T>` für die Verwendung in einsträngigen Situationen implementiert, in denen
du nicht die Strang-sichere Performanzeinbuße zahlen willst.

Daher stellen das Typsystem und die Merkmalsabgrenzungen (trait bounds) von
Rust sicher, dass du niemals versehentlich einen `Rc<T>`-Wert über Stränge
unsicher senden kannst. Als wir dies in Codeblock 16-14 versuchten, erhielten
wir folgenden Fehler: Das Merkmal `Send` ist für `Rc<Mutex<i32>>` nicht
implementiert. Als wir zu `Arc<T>`, das `Send` ist, wechselten, wurde der Code
kompiliert.

Jeder Typ, der vollständig aus `Send`-Typen besteht, wird automatisch auch als
`Send` markiert. Fast alle primitiven Typen sind `Send`, abgesehen von
Roh-Zeigern, die wir in Kapitel 19 besprechen werden.

### Erlauben des Zugriffs von mehreren Strängen mit `Sync`

Das Markierungsmerkmal `Sync` zeigt an, dass es sicher ist, den Typ, der `Sync`
implementiert, von mehreren Strängen zu referenzieren. Mit anderen Worten,
jeder Typ `T` ist `Sync`, wenn `&T` (eine unveränderbare Referenz auf `T`)
`Send` ist, was bedeutet, dass die Referenz sicher an einen anderen Strang
gesendet werden kann. Ähnlich wie bei `Send` sind primitive Typen `Sync` und
Typen, die vollständig aus Typen bestehen, die `Sync` sind, sind ebenfalls
`Sync`.

Der intelligente Zeiger `Rc<T>` ist nicht `Sync`, aus den gleichen Gründen, aus
denen er nicht `Send` ist. Der Typ `RefCell<T>` (über den wir in Kapitel 15
gesprochen haben) und die Familie der verwandten `Cell<T>`-Typen sind nicht
`Sync`. Die Implementierung der Ausleihenprüfung (borrow checking), die
`RefCell<T>` zur Laufzeit durchführt, ist nicht Strang-sicher. Der intelligente
Zeiger `Mutex<T>` ist `Sync` und kann verwendet werden, um den Zugriff mit
mehreren Strängen zu teilen, wie du im Abschnitt [„Gemeinsames Nutzen eines
`Mutex<T>` von mehreren Strängen“][sharing-mutext] gesehen hast.

### Manuelles Implementieren von `Send` und `Sync` ist unsicher

Da Typen, die sich aus den Merkmalen `Send` und `Sync` zusammensetzen,
automatisch auch `Send` und `Sync` sind, müssen wir diese Merkmale nicht
manuell implementieren. Als Markierungsmerkmale haben sie noch nicht einmal
irgendwelche Methoden, um sie zu implementieren. Sie sind nur nützlich, um
Invarianten in Bezug auf die Nebenläufigkeit zu erzwingen.

Das manuelle Implementieren dieser Merkmale beinhaltet das Schreiben von
unsicherem Rust-Code. Wir werden über das Verwenden von unsicherem Rust-Code in
Kapitel 19 sprechen; für den Moment ist die wichtige Information, dass das
Erstellen neuer nebenläufiger Typen, die nicht aus `Send`- und `Sync`-Teilen
bestehen, sorgfältige Überlegungen erfordert, um die Sicherheitsgarantien
aufrechtzuerhalten. [„Das Rustonomicon“][nomicon3] enthält weitere Informationen
über diese Garantien und wie man sie aufrechterhalten kann.

## Zusammenfassung

Dies ist nicht das letzte Mal, dass du in diesem Buch der Nebenläufigkeit
begegnest: Das Projekt in Kapitel 20 wird die Konzepte in diesem Kapitel in
einer realistischeren Situation verwenden als die hier besprochenen kleinen
Beispiele.

Wie bereits erwähnt, ist nur sehr wenig davon, wie Rust mit Nebenläufigkeit
umgeht, Teil der Sprache; viele Nebenläufigkeitslösungen sind als Kisten
(crates) implementiert. Diese entwickeln sich schneller als die
Standardbibliothek. Stelle also sicher, dass du online nach den aktuellen,
hochmodernen Kisten suchst, die in mehrsträngigen Situationen verwendet werden
können.

Die Rust-Standardbibliothek bietet Kanäle (channels) für die
Nachrichtenübermittlung und intelligente Zeigertypen, wie `Mutex<T>` und
`Arc<T>`, die sicher in nebenläufigen Kontexten verwendet werden können. Das
Typsystem und der Ausleihenprüfer stellen sicher, dass der Code, der diese
Lösungen verwendet, nicht mit Daten-Wettlaufsituationen (data races) oder
ungültigen Referenzen endet. Sobald du deinen Code zum Kompilieren gebracht
hast, kannst du sicher sein, dass er problemlos mit mehreren Strängen läuft,
ohne die schwer aufzuspürenden Fehler, die in anderen Sprachen üblich sind.
Nebenläufige Programmierung ist kein Konzept mehr, vor dem man sich fürchten
muss: Gehe hinaus und mache deine Programme nebenläufig &ndash; furchtlos!

Als Nächstes werden wir über idiomatische Wege sprechen, Probleme zu
modellieren und Lösungen zu strukturieren, während deine Rust-Programme größer
werden. Darüber hinaus werden wir besprechen, wie Rusts Idiome mit denen
zusammenhängen, die dir vielleicht aus der objektorientierten Programmierung
bekannt sind.

[sharing-mutext]:
ch16-03-shared-state.html#gemeinsames-nutzen-eines-mutext-von-mehreren-strängen
[nomicon3]: https://doc.rust-lang.org/nomicon/index.html
