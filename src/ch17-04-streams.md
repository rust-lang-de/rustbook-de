## Ströme (streams): Sequenz von Futures

Erinnere dich daran, wie wir den Empfänger unseres asynchronen Kanals
weiter in Abschnitt [„Datenaustausch zwischen zwei Aufgaben mit
Nachrichtenübermittlung“][17-02-messages] oben in diesem Kapitel verwendet
haben. Die asynchrone Methode `recv` erzeugt eine Sequenz von Elementen. Dies
ist ein Beispiel eines viel allgemeineren Musters, bekannt als _Strom_
(stream). Viele Konzepte lassen sich ganz natürlich als Ströme darstellen:
Elemente, die in einer Warteschlange verfügbar werden, Datenblöcke, die
schrittweise aus dem Dateisystem eingelesen werden, wenn der gesamte Datensatz
zu große für den Arbeitsspeicher des Computers ist, oder Daten, die nach und
nach über das Netzwerk eintreffen. Da Ströme Futures sind, können wir sie mit
jeder anderen Art von Future verwenden und auf interessante Weise kombinieren.
Beispielsweise können wir Ereignisse bündeln, um zu viele Netzwerkaufrufe zu
vermeiden, Zeitlimits für lang andauernde Vorgänge festlegen oder Ereignisse
der Benutzeroberfläche drosseln, um unnötige Arbeit zu vermeiden.

Wir haben eine Sequenz von Elementen in Kapitel 13 gesehen, als das Merkmal
`Iterator` im Abschnitt [„Das Merkmal (trait) `Iterator` und die Methode
`next`“][iterator] betrachtet haben. Es gibt jedoch zwei Unterschiede zwischen
Iteratoren und dem asynchronen Kanalempfänger. Der erste ist die Zeit:
Iteratoren sind synchron, während der Kanalempfänger asynchron ist. Der zweite
ist die API. Wenn wir direkt mit einem `Iterator` arbeiten, rufen wir seine
synchrone Methode `next` auf. Mit dem Strom `trpl::Receiver` rufen wir
stattdessen die asynchrone Methode `recv` auf. Ansonsten sind sich diese APIs
sehr ähnlich, und diese Ähnlichkeit ist kein Zufall. Ein Strom ist wie eine
asynchrone Form der Iteration. Während `trpl::Receiver` jedoch speziell auf den
Empfang von Nachrichten wartet, ist die allgemeine Strom-API viel breiter
angelegt: Sie liefert das nächste Element auf die gleiche Weise wie `Iterator`,
aber asynchron.

Die Ähnlichkeit zwischen Iteratoren und Strömen in Rust bedeutet, dass wir aus
jedem Iterator einen Strom erzeugen können. Wie bei einem Iterator können wir
mit einem Strom arbeiten, indem wir seine Methode `next` aufrufen und dann auf
die Ausgabe warten, wie in Codeblock 17-21.

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore,does_not_compile
# fn main() {
#     trpl::block_on(async {
        let values = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
        let iter = values.iter().map(|n| n * 2);
        let mut stream = trpl::stream_from_iter(iter);

        while let Some(value) = stream.next().await {
            println!("Der Wert war: {value}");
        }
#     });
# }
```

<span class="caption">Codeblock 17-21: Erstellen eines Stroms aus einem
Iterator und Ausgeben seiner Werte</span>

Wir beginnen mit einem Array von Zahlen, das wir in einen Iterator umwandeln
und dann `map` aufrufen, um alle Werte zu verdoppeln. Dann wandeln wir den
Iterator mit der Funktion `trpl::stream_from_iter` in einen Strom um.
Schließlich durchlaufen wir mit der `while let`-Schleife die Elemente im
Strom.

Leider lässt sich der Code nicht kompilieren, sondern wir bekommen die
Fehlermeldung, dass keine Methode `next` verfügbar ist:

```text
error[E0599]: no method named `next` found for struct `tokio_stream::iter::Iter` in the current scope
  --> src/main.rs:10:40
   |
10 |         while let Some(value) = stream.next().await {
   |                                        ^^^^
   |
   = help: items from traits can only be used if the trait is in scope
help: the following traits which provide `next` are implemented but not in scope; perhaps you want to import one of them
   |
1  + use crate::trpl::StreamExt;
   |
1  + use futures_util::stream::stream::StreamExt;
   |
1  + use std::iter::Iterator;
   |
1  + use std::str::pattern::Searcher;
   |
help: there is a method `try_next` with a similar name
   |
10 |         while let Some(value) = stream.try_next().await {
   |                                        ~~~~~~~~
```

Wie diese Ausgabe erklärt, liegt der Grund für den Compilerfehler darin, dass
wir das richtige Merkmal im Gültigkeitsbereich benötigen, um die Methode `next`
verwenden zu können. In Anbetracht der bisherigen Diskussion könnte man
erwarten, dass es sich um das Merkmal `Stream` handelt, aber ist das Merkmal
`StreamExt`. `Ext` steht hier für „extension“ (engl. Erweiterung): Dies ist
eine gängige Vorgehensweise in der Rust-Gemeinschaft, um ein Merkmal mit einem
anderen zu erweitern.

Das Merkmal `Stream` definiert eine Low-Level-Schnittstelle, die die Merkmale
`Iterator` und `Future` effektiv kombiniert. `StreamExt` bietet eine Reihe von
APIs auf höherer Ebene ab, die auf `Stream` basieren, darunter die Methode
`next` sowie andere Hilfsmethoden, die denen des Merkmals `Iterator` ähneln.
`Stream` und `StreamExt` sind noch nicht Teil der Standardbibliothek von Rust,
aber die meisten Kisten des Ökosystems verwenden ähnliche Definitionen.

Um den Compilerfehler zu beheben, fügen wir eine `use`-Anweisung für
`trpl::StreamExt` hinzu, wie in Codeblock 17-22.

<span class="filename">Dateiname: src/main.rs</span>

```rust
use trpl::StreamExt;

fn main() {
    trpl::block_on(async {
        let values = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
        // --abschneiden--
#         let iter = values.iter().map(|n| n * 2);
#         let mut stream = trpl::stream_from_iter(iter);
#
#         while let Some(value) = stream.next().await {
#             println!("Der Wert war: {value}");
#         }
#     });
# }
```

<span class="caption">Codeblock 17-22: Erfolgreiche Verwendung eines Iterators
als Grundlage für einen Strom</span>

Mit all diesen Teilen zusammen funktioniert der Code so, wie wir es wollen!
Außerdem können wir jetzt, da wir `StreamExt` im Gültigkeitsbereich haben, alle
seine Hilfsmethoden verwenden, genau wie bei Iteratoren.

[17-02-messages]: ch17-02-concurrency-with-async.html#datenaustausch-zwischen-zwei-aufgaben-mit-nachrichtenübermittlung
[iterator]: ch13-02-iterators.html#das-merkmal-trait-iterator-und-die-methode-next
