## Performanzvergleich: Schleifen vs. Iteratoren

Um festzustellen, ob man besser Schleifen oder Iteratoren verwendet, solltest
du wissen, welche Implementierung schneller ist: Die Version der Funktion
`search` mit einer expliziten `for`-Schleife oder die Version mit Iteratoren.

Wir haben einen Benchmark durchführt, der den gesamten Inhalt von *The
Adventures of Sherlock Holmes* von Sir Arthur Conan Doyle in eine `Zeichenkette`
(String) lädt und nach dem Wort *the* im Inhalt sucht. Hier sind die
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
Iteratoren sind eine von Rusts *Zero-Cost Abstraktionen*, damit ist gemeint,
dass die Verwendung keinen zusätzlichen Laufzeitaufwand verursacht. Dies
entspricht der Definition von *Zero-Overhead* in C++ von Bjarne Stroustrup in
"Foundations of C++" (2012):

> Im Allgemeinen folgen C++-Implementierungen dem Zero-Overhead-Prinzip: Was
> du nicht verwendest, bezahlst du nicht. Und darüber hinaus: Was du verwendest,
> hättest du von Hand nicht besser programmieren können.

Als anderes Beispiel wird der folgende Programmcode eines Audiodecoders
übernommen. Der Decodierungsalgorithmus verwendet die mathematische Operation
der linearen Vorhersage (linear prediction), um zukünftige Werte aufgrund einer
linearen Funktion der vergangenen Abtastwerte zu schätzen. Der Programmcode
verwendet eine Iteratorkette, die drei Variablen im Gültigkeitsbereich
berechnet, einen Anteilstyp `buffer`, ein Array mit 12 `coefficients` und einen 
Wert um den die Daten die nach `glp_shift` verschoben werden sollen. Wir haben
die Variablen in diesem Beispiel deklariert, diesen jedoch keine Werte
zugewiesen, obwohl dieser Programmcode aus seinem Kontext gerissen keine große
Bedeutung hat, ist er dennoch ein gutes Beispiel dafür, wie Rust abstrakte Ideen
im Programmcode auf Code niedriger Ebene übersetzt.

```rust,ignore
let buffer: &mut [i32];
let coefficients: [i64; 12];
let qlp_shift: i16;

for i in 12..buffer.len() {
    let prediction = coefficients.iter()
                                 .zip(&buffer[i - 12..i])
                                 .map(|(&c, &s)| c * s as i64)
                                 .sum::<i64>() >> qlp_shift;
    let delta = buffer[i];
    buffer[i] = prediction as i32 + delta;
}
```

Um den Wert von `prediction` zu berechnen, durchläuft dieser Code jeden der 12
Werte in `coefficients` und verwendet die Methode `zip`, um die Werte der
Koeffizienten mit den vorherigen 12 Werten in `buffer` zu paaren. Anschließend
multiplizieren wir die Werte jedes Paars miteinander, summieren alle
Ergebnisse und verschieben die Bits in der Summe um den Wert von `glp_shift` nach
rechts.

Bei Berechnungen in Anwendungen wie Audiodecodern wird die Performanz häufig
priorisiert. Hier erstellen wir einen Iterator mit zwei Adaptern und verbrauchen
dann den Wert. Zu welchen Assemblercode würde dieser Rustprogrammcode
kompiliert werden? Er würde auf denselben Programmcode kompiliert werden, als
hättest du das Programm selbst in Assemblersprache geschrieben. Es gibt keine
Schleife, die der Iteration über die Werte von `coefficients` entsprechen würde.
Rust weiß, dass es 12 Iterationen gibt und „rollt“ daher die Schleife ab.
*Abrollen* (unrolling) ist eine Optimierung, die den Mehraufwand (overhead) der
Steuerung der Schleife beseitigt und stattdessen sich wiederholenden
Programmcode für jede Iteration der Schleife generiert.

Alle Koeffizienten werden in Registern gespeichert, das bedeutet, dass der
Zugriff auf die Werte sehr schnell ist. Es gibt keine Begrenzungsprüfungen (bounds
checks) für den Zugriff auf Arrays zur Laufzeit. Durch diese Optimierungen, die
Rust anwenden kann, ist der resultierende Programmcode äußerst effizient. Nun,
da du das weißt, kannst du, ohne Angst zu haben, Funktionsabschlüsse und
Iteratoren verwenden! Sie lassen den Code abstrakter erscheinen, verursachen
aber keine Performanzeinbußen zur Laufzeit.

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
