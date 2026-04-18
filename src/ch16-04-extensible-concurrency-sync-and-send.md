## Erweiterbare Nebenläufigkeit mit `Send` und `Sync`

Interessanterweise war fast jede Nebenläufigkeitsfunktionalität, über die wir
bisher in diesem Kapitel gesprochen haben, Teil der Standardbibliothek, nicht
der Sprache. Deine Möglichkeiten für den Umgang mit Nebenläufigkeit sind nicht
auf die Sprache oder die Standardbibliothek beschränkt; du kannst deine eigenen
Nebenläufigkeitsfunktionalitäten schreiben oder die von anderen geschriebenen
verwenden.

Zu den wichtigsten Nebenläufigkeitskonzepten, die in die Sprache und nicht in
die Standardbibliothek eingebettet sind, gehören jedoch die Traits `Send` und
`Sync` in `std::marker`.

### Übertragen der Eigentümerschaft zwischen Threads

Das Marker Trait `Send` zeigt an, dass die Eigentümerschaft an Werten des Typs,
der `Send` implementiert, zwischen Threads übertragen werden kann. Fast jeder
Rust-Typ implementiert `Send`, aber es gibt einige Ausnahmen, einschließlich
`Rc<T>`: Dieser kann nicht `Send` sein, denn wenn du einen `Rc<T>`-Wert geklont
hast und versucht hast, die Eigentümerschaft am Klon auf einen anderen Thread zu
übertragen, könnten beide Threads gleichzeitig den Referenzzähler aktualisieren.
Aus diesem Grund ist `Rc<T>` für die Verwendung in single-threaded Situationen
implementiert, in denen du nicht die Thread-sichere Performanzeinbuße zahlen
willst.

Daher stellen das Typsystem und die Trait Bounds von Rust sicher, dass du
niemals versehentlich einen `Rc<T>`-Wert unsicher zwischen Threads senden
kannst. Als wir dies in Codeblock 16-14 versuchten, erhielten wir folgenden
Fehler: Das Trait `Send` ist für `Rc<Mutex<i32>>` nicht implementiert. Als wir
zu `Arc<T>` wechselten, das `Send` implementiert, ließ sich der Code
kompilieren.

Jeder Typ, der vollständig aus `Send`-Typen besteht, wird automatisch auch als
`Send` markiert. Fast alle primitiven Typen implementieren `Send`, abgesehen
von Roh-Zeigern, die wir in Kapitel 20 besprechen werden.

### Zugriff von mehreren Threads

Das Marker Trait `Sync` zeigt an, dass es sicher ist, den Typ, der `Sync`
implementiert, von mehreren Threads zu referenzieren. Mit anderen Worten, jeder
Typ `T` implementiert `Sync`, wenn `&T` (eine unveränderbare Referenz auf `T`)
`Send` implementiert, was bedeutet, dass die Referenz sicher an einen anderen
Thread gesendet werden kann. Ähnlich wie bei `Send` implementieren primitive
Typen `Sync`, und Typen, die vollständig aus Typen bestehen, die `Sync`
implementieren, implementieren ebenfalls `Sync`.

Der intelligente Zeiger `Rc<T>` implementiert ebenfalls nicht `Sync`, aus
denselben Gründen, warum er nicht `Send` implementiert. Der Typ `RefCell<T>`
(über den wir in Kapitel 15 gesprochen haben) und die Familie der verwandten
`Cell<T>`-Typen implementieren nicht `Sync`. Die Implementierung des Borrow
Checking, die `RefCell<T>` zur Laufzeit durchführt, ist nicht Thread-sicher. Der
intelligente Zeiger `Mutex<T>` implementiert `Sync` und kann verwendet werden,
um den Zugriff mit mehreren Threads zu teilen, wie du in [„Gemeinsamer Zugriff
auf `Mutex<T>`“][sharing-mutext] gesehen hast.

### Manuelles Implementieren von `Send` und `Sync` ist unsicher

Da Typen, die sich ausschließlich aus Typen zusammensetzen, die die Traits
`Send` und `Sync` implementieren, automatisch auch `Send` und `Sync`
implementieren, müssen wir diese Traits nicht manuell implementieren. Als Marker
Traits haben sie noch nicht einmal irgendwelche Methoden, um sie zu
implementieren. Sie sind nur nützlich, um Invarianten in Bezug auf die
Nebenläufigkeit zu erzwingen.

Das manuelle Implementieren dieser Traits beinhaltet das Schreiben von
unsicherem Rust-Code. Wir werden über das Verwenden von unsicherem Rust-Code in
Kapitel 20 sprechen; für den Moment ist die wichtige Information, dass das
Erstellen neuer nebenläufiger Typen, die nicht aus `Send`- und `Sync`-Teilen
bestehen, sorgfältige Überlegungen erfordert, um die Sicherheitsgarantien
aufrechtzuerhalten. [„Das Rustonomicon“][nomicon3] enthält weitere Informationen
über diese Garantien und wie man sie aufrechterhalten kann.

## Zusammenfassung

Dies ist nicht das letzte Mal, dass du in diesem Buch der Nebenläufigkeit
begegnest: Das nächste Kapitel befasst sich mit asynchroner Programmierung, und
das Projekt in Kapitel 21 wird die Konzepte in diesem Kapitel in einer
realistischeren Situation anwenden als die hier besprochenen kleineren
Beispiele.

Wie bereits erwähnt, ist nur sehr wenig davon, wie Rust mit Nebenläufigkeit
umgeht, Teil der Sprache; viele Nebenläufigkeitslösungen sind in Crates
implementiert. Diese entwickeln sich schneller als die Standardbibliothek.
Stelle also sicher, dass du online nach den aktuellen, hochmodernen Crates
suchst, die in multi-threaded Situationen verwendet werden können.

Die Rust-Standardbibliothek bietet Kanäle (channels) für die
Nachrichtenübermittlung und intelligente Zeigertypen wie `Mutex<T>` und
`Arc<T>`, die sicher in nebenläufigen Kontexten verwendet werden können. Das
Typsystem und der Borrow Checker stellen sicher, dass der Code, der diese
Lösungen verwendet, nicht mit Data Races oder ungültigen Referenzen endet.
Sobald du deinen Code zum Kompilieren gebracht hast, kannst du sicher sein, dass
er problemlos mit mehreren Threads läuft, ohne die schwer aufspürbaren Fehler,
die in anderen Sprachen üblich sind. Nebenläufige Programmierung ist kein
Konzept mehr, vor dem man sich fürchten muss: Gehe hinaus und mache deine
Programme nebenläufig &ndash; furchtlos!

[sharing-mutext]: ch16-03-shared-state.html#gemeinsamer-zugriff-auf-mutext
[nomicon3]: https://doc.rust-lang.org/nomicon/index.html
