## Performanz von Schleifen vs. Iteratoren

Um festzustellen, ob man besser Schleifen oder Iteratoren verwendet, solltest
du wissen, welche Implementierung schneller ist: Die Version der Funktion
`search` mit einer expliziten `for`-Schleife oder die Version mit Iteratoren.

Wir haben einen Benchmark durchführt, der den gesamten Inhalt von _The
Adventures of Sherlock Holmes_ von Sir Arthur Conan Doyle in eine `Zeichenkette`
(String) lädt und nach dem Wort _the_ im Inhalt sucht. Hier sind die
Ergebnisse des Benchmarks für die Version von `search` mit `for`-Schleife und
der Version die Iteratoren verwendet:

```text
test bench_search_for  ... bench:  19,620,300 ns/iter (+/- 915,700)
test bench_search_iter ... bench:  19,234,900 ns/iter (+/- 657,200)
```
Die Version mit Iteratoren war ein wenig schneller! Wir werden den Programmcode
des Benchmarks hier nicht erläutern, da es nicht darum geht, nachzuweisen, dass
die beiden Versionen gleichwertig sind, sondern einen allgemeinen Eindruck davon
zu bekommen, wie diese beiden Versionen im Bezug auf Performanz verglichen
werden.

Für einen umfassenderen Benchmark würde man verschiedene Texte
unterschiedlicher Größe als `contents`, verschiedene Wörter und Wörter
unterschiedlicher Länge als `query` verwenden und verschiedene Arten anderer
Variationen verwenden. Der Punkt ist folgender: Obwohl Iteratoren eine
hochrangige Abstraktion sind, werden sie ungefähr auf denselben Programmcode
kompiliert, als hättest du diesen selbst auf niedriger Ebene geschrieben.
Iteratoren sind eine von Rusts _Zero-Cost Abstraktionen_, damit ist gemeint,
dass die Verwendung keinen zusätzlichen Laufzeitaufwand verursacht. Dies
entspricht der Definition von Zero-Overhead, die Bjarne Stroustrup, der
ursprüngliche Entwickler und Implementierer von C++, in seiner
ETAPS-Keynote-Präsentation „Foundations of C++” aus dem Jahr 2012 gegeben hat:

> Im Allgemeinen folgen C++-Implementierungen dem Zero-Overhead-Prinzip: Was
> du nicht verwendest, bezahlst du nicht. Und darüber hinaus: Was du verwendest,
> hättest du von Hand nicht besser programmieren können.

In vielen Fällen wird Rust-Code, der Iteratoren verwendet, zu demselben
Assembler-Code kompiliert, die du von Hand schreiben würdest. Optimierungen wie
Schleifen-Abrollen und Entfernen von Bereichsprüfungen beim Array-Zugriff
machen den resultierenden Code äußerst effizient. Jetzt, da du das weißt,
kannst du Iteratoren und Funktionsabschlüsse ohne Bedenken verwenden! Sie
lassen den Code abstrakter erscheinen, verursachen aber keine
Performanzeinbußen zur Laufzeit.

## Zusammenfassung

Funktionsabschlüsse und Iteratoren sind Rust-Funktionalitäten, die von Ideen der
funktionalen Programmierung inspiriert sind. Sie tragen zu Rusts Fähigkeit bei,
abstrakte Ideen bei guter Performanz zu ermöglichen. Die Implementierungen von
Iteratoren und Funktionsabschlüssen sind so, dass die Performanz der Laufzeit
nicht beeinträchtigt wird. Dies ist ein Teil von Rusts Ziel,
Zero-Cost-Abstraktionen zu ermöglichen.

Nachdem wir die Ausdruckskraft unseres E/A-Projekts verbessert haben, wollen
wir uns nun einige weitere Funktionalitäten von `cargo` ansehen, die uns helfen
werden, das Projekt mit der Welt zu teilen.
