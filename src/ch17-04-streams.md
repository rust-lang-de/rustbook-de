## Ströme (streams): Sequenz von Futures

Bislang haben wir uns in diesem Kapitel hauptsächlich mit einzelnen Futures
beschäftigt. Die einzige große Ausnahme war der von uns verwendete asynchrone
Kanal. Erinnere dich daran, wie wir den Empfänger unseres asynchronen Kanals
weiter oben in diesem Kapitel in [„Hochzählen in zwei Aufgaben mit
Nachrichtenübermittlung“][17-02-messages] verwendet haben. Die asynchrone
Methode `recv` erzeugt eine Sequenz von Elementen. Dies ist ein Beispiel eines
viel allgemeineren Musters, bekannt als _Strom_ (stream).

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
die Ausgabe warten, wie in Codeblock 17-30.

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore,does_not_compile
# extern crate trpl;
#
# fn main() {
#     trpl::run(async {
        let values = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
        let iter = values.iter().map(|n| n * 2);
        let mut stream = trpl::stream_from_iter(iter);

        while let Some(value) = stream.next().await {
            println!("Der Wert war: {value}");
        }
#     });
# }
```

<span class="caption">Codeblock 17-30: Erstellen eines Stroms aus einem
Iterator und Ausgeben seiner Werte</span>

Wir beginnen mit einem Array von Zahlen, das wir in einen Iterator umwandeln
und dann `map` aufrufen, um alle Werte zu verdoppeln. Dann wandeln wir den
Iterator mit der Funktion `trpl::stream_from_iter` in einen Strom um.
Schließlich durchlaufen wir mit der `while let`-Schleife die Elemente im
Strom.

Wenn wir versuchen, den Code auszuführen, lässt er sich leider nicht
kompilieren. Stattdessen meldet der Compiler, dass keine Methode `next`
verfügbar ist.

```console
error[E0599]: no method named `next` found for struct `Iter` in the current scope
  --> src/main.rs:10:40
   |
10 |         while let Some(value) = stream.next().await {
   |                                        ^^^^
   |
   = note: the full type name has been written to 'file:///projects/async_await/target/debug/deps/async_await-9de943556a6001b8.long-type-1281356139287206597.txt'
   = note: consider using `--verbose` to print the full type name to the console
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

Wir werden die Merkmale `Stream` und `StreamExt` am Ende des Kapitels etwas
genauer erklären, aber für den Moment musst du nur wissen, dass das Merkmal
`Stream` eine Low-Level-Schnittstelle definiert, die effektiv die Merkmale
`Iterator` und `Future` kombiniert. `StreamExt` stellt eine Reihe von APIs auf
höherer Ebene zur Verfügung, darunter die Methode `next` sowie andere
Hilfsmethoden, die denen des Merkmals `Iterator` ähneln. `Stream` und
`StreamExt` sind noch nicht Teil der Standardbibliothek von Rust, aber die
meisten Ökosystemkisten verwenden dieselbe Definition.

Die Behebung des Compilerfehlers besteht darin, eine `use`-Anweisung für
`trpl::StreamExt` hinzuzufügen, wie in Codeblock 17-31.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# extern crate trpl;
#
use trpl::StreamExt;

fn main() {
    trpl::run(async {
        let values = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
        let iter = values.iter().map(|n| n * 2);
        let mut stream = trpl::stream_from_iter(iter);

        while let Some(value) = stream.next().await {
            println!("Der Wert war: {value}");
        }
    });
}
```

<span class="caption">Codeblock 17-31: Erfolgreiche Verwendung eines Iterators
als Grundlage für einen Strom</span>

Mit all diesen Teilen zusammen funktioniert der Code so, wie wir es wollen!
Außerdem können wir jetzt, da wir `StreamExt` im Gültigkeitsbereich haben, alle
seine Hilfsmethoden verwenden, genau wie bei Iteratoren. In Codeblock 17-32
verwenden wir zum Beispiel die Methode `filter`, um alles außer Vielfache von
drei und fünf herauszufiltern.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# extern crate trpl;
#
use trpl::StreamExt;

fn main() {
    trpl::run(async {
        let values = 1..101;
        let iter = values.map(|n| n * 2);
        let stream = trpl::stream_from_iter(iter);

        let mut filtered =
            stream.filter(|value| value % 3 == 0 || value % 5 == 0);

        while let Some(value) = filtered.next().await {
            println!("Der Wert war: {value}");
        }
    });
}
```

<span class="caption">Codeblock 17-32: Filtern eines Stroms mit der Methode
`StreamExt::filter`</span>

Das ist natürlich nicht sehr interessant, da wir das auch mit normalen
Iteratoren und ganz ohne asynchronen Code machen könnten. Schauen wir uns an,
was für Ströme einzigartig sind.

### Komposition von Strömen

Viele Konzepte werden auf natürliche Weise als Datenströme dargestellt:
Elemente, die in einer Warteschlange verfügbar werden, Datenpakete, die
inkrementell aus dem Dateisystem eingelesen werden, wenn der gesamte Datensatz
zu groß für den Speicher des Computers ist, oder Daten, die im Laufe der Zeit
über das Netz ankommen. Da es sich bei Strömen um Futures handelt, können wir
sie auch mit jeder anderen Art von Futures verwenden und sie auf interessante
Weise kombinieren. So können wir beispielsweise Ereignisse stapeln, um zu viele
Netzwerkaufrufe zu vermeiden, Zeitüberschreitungen für Sequenzen lang laufender
Vorgänge festlegen oder Ereignisse der Benutzeroberfläche drosseln, um unnötige
Arbeit zu vermeiden.

Beginnen wir damit, einen kleinen Nachrichtenstrom zu erstellen, als Ersatz für
einen Datenstrom, den wir von einer WebSocket oder einem anderen
Echtzeit-Kommunikationsprotokoll sehen könnten, wie in Codeblock 17-33 gezeigt.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# extern crate trpl;
#
use trpl::{ReceiverStream, Stream, StreamExt};

fn main() {
    trpl::run(async {
        let mut messages = get_messages();

        while let Some(message) = messages.next().await {
            println!("{message}");
        }
    });
}

fn get_messages() -> impl Stream<Item = String> {
    let (tx, rx) = trpl::channel();

    let messages = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"];
    for message in messages {
        tx.send(format!("Nachricht: '{message}'")).unwrap();
    }

    ReceiverStream::new(rx)
}
```

<span class="caption">Codeblock 17-33: Verwenden des Empfängers `rx` als
`ReceiverStream`</span>

Zunächst erstellen wir eine Funktion namens `get_messages`, die `impl
 Stream<Item = String>` zurückgibt. Für die Implementierung erstellen wir einen
asynchronen Kanal, iterieren über die ersten 10 Buchstaben des englischen
Alphabets und senden sie über den Kanal.

Wir verwenden auch einen neuen Typ: `ReceiverStream`, der den Empfänger `rx`
aus dem `trpl::channel` in einen `Stream` mit einer Methode `next` umwandelt.
Zurück in `main` benutzen wir eine `while let`-Schleife, um alle Nachrichten
aus dem Strom auszugeben.

Wenn wir diesen Code ausführen, erhalten wir genau die Ergebnisse, die wir
erwarten würden:

```text
Nachricht: 'a'
Nachricht: 'b'
Nachricht: 'c'
Nachricht: 'd'
Nachricht: 'e'
Nachricht: 'f'
Nachricht: 'g'
Nachricht: 'h'
Nachricht: 'i'
Nachricht: 'j'
```

Wir könnten dies erneut mit der regulären `Receiver`-API oder sogar mit der
regulären `Iterator`-API tun. Fügen wir also etwas hinzu, das Ströme erfordert:
Eine Zeitüberschreitung, die für jedes Element im Strom gilt, und eine
Verzögerung für die Elemente, die wir ausgeben, siehe Codeblock 17-34.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# extern crate trpl;
#
use std::{pin::pin, time::Duration};
use trpl::{ReceiverStream, Stream, StreamExt};

fn main() {
    trpl::run(async {
        let mut messages =
            pin!(get_messages().timeout(Duration::from_millis(200)));

        while let Some(result) = messages.next().await {
            match result {
                Ok(message) => println!("{message}"),
                Err(reason) => eprintln!("Problem: {reason:?}"),
            }
        }
    })
}
#
# fn get_messages() -> impl Stream<Item = String> {
#     let (tx, rx) = trpl::channel();
#
#     let messages = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"];
#     for message in messages {
#         tx.send(format!("Nachricht: '{message}'")).unwrap();
#     }
#
#     ReceiverStream::new(rx)
# }
```

<span class="caption">Codeblock 17-34: Verwenden der Methode
`StreamExt::timeout`, um ein Zeitlimit für die Elemente in einem Strom
festzulegen</span>

Fügen wir zunächst mit der Methode `timeout`, die aus dem Merkmal `StreamExt`
stammt, eine Zeitüberschreitung zum Strom hinzu. Dann aktualisieren wir den
Rumpf der `while let`-Schleife, weil der Strom jetzt ein `Result` zurückgibt.
Die Variante `Ok` zeigt an, dass eine Nachricht rechtzeitig angekommen ist; die
Variante `Err` zeigt an, dass die Zeit abgelaufen ist, bevor irgendeine
Nachricht angekommen ist. Wir gleichen dieses Ergebnis mit `match` ab und geben
entweder die Nachricht oder eine Meldung über die Zeitüberschreitung aus.
Schließlich ist zu beachten, dass wir die Nachrichten anpinnen, nachdem wir die
Zeitüberschreitung auf sie angewendet haben, da die Timeout-Hilfsmethode einen
Strom erzeugt, der angeheftet werden muss, um abgefragt zu werden.

Da es jedoch keine Verzögerungen zwischen den Nachrichten gibt, ändert diese
Zeitüberschreitung das Verhalten des Programms nicht. Fügen wir den
Nachrichten, die wir senden, eine variable Verzögerung hinzu, wie in Codeblock
17-35 zu sehen.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# extern crate trpl;
#
# use std::{pin::pin, time::Duration};
#
# use trpl::{ReceiverStream, Stream, StreamExt};
#
# fn main() {
#     trpl::run(async {
#         let mut messages =
#             pin!(get_messages().timeout(Duration::from_millis(200)));
#
#         while let Some(result) = messages.next().await {
#             match result {
#                 Ok(message) => println!("{message}"),
#                 Err(reason) => eprintln!("Problem: {reason:?}"),
#             }
#         }
#     })
# }
#
fn get_messages() -> impl Stream<Item = String> {
    let (tx, rx) = trpl::channel();

    trpl::spawn_task(async move {
        let messages = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"];
        for (index, message) in messages.into_iter().enumerate() {
            let time_to_sleep = if index % 2 == 0 { 100 } else { 300 };
            trpl::sleep(Duration::from_millis(time_to_sleep)).await;

            tx.send(format!("Nachricht: '{message}'")).unwrap();
        }
    });

    ReceiverStream::new(rx)
}
```

<span class="caption">Codeblock 17-35: Senden von Nachrichten durch `tx` mit
einer asynchronen Verzögerung, ohne `get_messages` zu einer asynchronen
Funktion zu machen</span>

In `get_messages` verwenden wir die Iterator-Methode `enumerate` mit dem Array
`messages`, sodass wir den Index jedes Elements, das wir senden, zusammen mit
dem Element selbst erhalten können. Dann wenden wir eine Verzögerung von 100
Millisekunden auf Elemente mit geradem Index und eine Verzögerung von 300
Millisekunden auf Elemente mit ungeradem Index an, um die verschiedenen
Verzögerungen zu simulieren, die wir in der realen Welt bei einem Strom von
Nachrichten sehen könnten. Da unser Timeout 200 Millisekunden beträgt, sollte
dies die Hälfte der Nachrichten betreffen.

Um zwischen den Nachrichten in der Funktion `get_messages` zu schlafen ohne zu
blockieren, müssen wir async verwenden. Allerdings können wir `get_messages`
selbst nicht zu einer asynchronen Funktion machen, denn dann würden wir ein
`Future<Output = Stream<Item = String>>` statt eines `Stream<Item = String>>`
zurückgeben. Der Aufrufer müsste selbst auf `get_messages` warten, um Zugriff
auf den Strom zu erhalten. Aber denke daran: Alles in einem bestimmten Future
geschieht linear; Nebenläufigkeit geschieht _zwischen_ den Futures. Das Warten
auf `get_messages` würde erfordern, dass es alle Nachrichten sendet,
einschließlich einer Pause zwischen dem Senden jeder Nachricht, bevor es den
Empfängerstrom zurückgibt. Infolgedessen wäre die Zeitüberschreitung nutzlos.
Es gäbe keine Verzögerungen im Strom selbst: Die Verzögerungen würden alle
auftreten, bevor der Strom überhaupt verfügbar wäre.

Stattdessen belassen wir `get_messages` als reguläre Funktion, die einen Strom
zurückgibt, und erzeugen eine Aufgabe, die die asynchronen Aufrufe von `sleep`
durchführt.

> Anmerkung: Der Aufruf von `spawn_task` auf diese Weise funktioniert, weil wir
> unsere Laufzeitumgebung bereits eingerichtet haben; andernfalls würde das
> Programm abstürzen. Andere Implementierungen wählen andere Kompromisse: Sie
> könnten eine neue Laufzeitumgebung erzeugen und so den Programmabbruch
> vermeiden, müssten dafür aber zusätzlichen Overhead in Kauf nehmen, oder sie
> bieten einfach keine eigenständige Möglichkeit, Aufgaben ohne Bezug auf eine
> Laufzeitumgebung zu erzeugen. Stelle sicher, dass du weißt, welchen
> Kompromiss deine Laufzeitumgebung gewählt hat, und schreibe deinen Code
> entsprechend!

Jetzt hat unser Code ein viel interessanteres Ergebnis. Zwischen jedem zweiten
Paar von Meldungen wird der Fehler `Problem: Elapsed(())` gemeldet.

```text
Nachricht: 'a'
Problem: Elapsed(())
Nachricht: 'b'
Nachricht: 'c'
Problem: Elapsed(())
Nachricht: 'd'
Nachricht: 'e'
Problem: Elapsed(())
Nachricht: 'f'
Nachricht: 'g'
Problem: Elapsed(())
Nachricht: 'h'
Nachricht: 'i'
Problem: Elapsed(())
Nachricht: 'j'
```

Die Zeitüberschreitung verhindert nicht, dass die Nachrichten am Ende ankommen.
Wir erhalten immer noch alle ursprünglichen Nachrichten. Das liegt daran, dass
unser Kanal _unbegrenzt_ ist: Er kann so viele Nachrichten aufnehmen, wie in
den Arbeitsspeicher passen. Wenn die Nachricht nicht vor der Zeitüberschreitung
eintrifft, wird unser Strom-Handler dies berücksichtigen, aber wenn er den
Strom erneut abruft, ist die Nachricht vielleicht schon angekommen.

Du kannst bei Bedarf ein anderes Verhalten erreichen, indem du andere Arten von
Kanälen oder allgemeiner andere Arten von Strömen verwendest. Lass uns eine
dieser Möglichkeiten in der Praxis ansehen, indem wir einen Strom von
Zeitintervallen mit diesem Strom von Nachrichten kombinieren.

### Zusammenführen von Strömen

Erstellen wir zunächst einen weiteren Strom, der jede Millisekunde ein Element
ausgibt, wenn wir ihn direkt laufen lassen. Der Einfachheit halber können wir
die Funktion `sleep` verwenden, um eine Nachricht verzögert zu senden, und sie
mit dem gleichen Ansatz kombinieren, den wir in `get_messages` verwendet haben,
indem wir einen Stroms aus einem Kanal erstellen. Der Unterschied ist, dass wir
dieses Mal die Anzahl der abgelaufenen Intervalle zurücksenden werden, also
wird der Rückgabetyp `impl Stream<Item = u32>` sein, und wir können die Funktion
`get_intervals` aufrufen (siehe Codeblock 17-36).

<span class="filename">Dateiname: src/main.rs</span>

```rust
# extern crate trpl;
#
# use std::{pin::pin, time::Duration};
#
# use trpl::{ReceiverStream, Stream, StreamExt};
#
# fn main() {
#     trpl::run(async {
#         let mut messages =
#             pin!(get_messages().timeout(Duration::from_millis(200)));
#
#         while let Some(result) = messages.next().await {
#             match result {
#                 Ok(message) => println!("{message}"),
#                 Err(reason) => eprintln!("Problem: {reason:?}"),
#             }
#         }
#     })
# }
#
# fn get_messages() -> impl Stream<Item = String> {
#     let (tx, rx) = trpl::channel();
#
#     trpl::spawn_task(async move {
#         let messages = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"];
#         for (index, message) in messages.into_iter().enumerate() {
#             let time_to_sleep = if index % 2 == 0 { 100 } else { 300 };
#             trpl::sleep(Duration::from_millis(time_to_sleep)).await;
#
#             tx.send(format!("Nachricht: '{message}'")).unwrap();
#         }
#     });
#
#     ReceiverStream::new(rx)
# }
#
fn get_intervals() -> impl Stream<Item = u32> {
    let (tx, rx) = trpl::channel();

    trpl::spawn_task(async move {
        let mut count = 0;
        loop {
            trpl::sleep(Duration::from_millis(1)).await;
            count += 1;
            tx.send(count).unwrap();
        }
    });

    ReceiverStream::new(rx)
}
```

<span class="caption">Codeblock 17-36: Erstellen eines Stroms mit einem Zähler,
der einmal pro Millisekunde eine Nachricht generiert</span>

Beginnen wir mit der Definition von `count` in der Aufgabe. (Wir könnten sie
auch außerhalb der Aufgabe definieren, aber es ist klarer, den
Gültigkeitsbereich einer bestimmten Variablen zu begrenzen.) Dann erstellen wir
eine Endlosschleife. Jede Iteration der Schleife schläft asynchron eine
Millisekunde lang, erhöht die Anzahl und sendet sie dann über den Kanal. Da
dies alles in der von `spawn_task` erzeugten Aufgabe verpackt ist, wird alles
zusammen mit der Laufzeitumgebung aufgeräumt, einschließlich der
Endlosschleife.

Eine derartige Endlosschleife, die erst endet, wenn die gesamte
Laufzeitumgebung beendet wird, ist in asynchronem Rust recht häufig: Viele
Programme müssen unbegrenzt weiterlaufen. Mit asynchronem Code blockiert dies
nichts anderes, solange es in jeder Schleifeniteration mindestens einen
await-Punkt gibt.

Zurück im asynchronen Block unserer Hauptfunktion können wir nun versuchen, die
Ströme `messages` und `intervals` zusammenzuführen, wie in Codeblock 17-37
gezeigt.

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore,does_not_compile
# extern crate trpl;
#
# use std::{pin::pin, time::Duration};
#
# use trpl::{ReceiverStream, Stream, StreamExt};
#
# fn main() {
#     trpl::run(async {
        let messages = get_messages().timeout(Duration::from_millis(200));
        let intervals = get_intervals();
        let merged = messages.merge(intervals);
#
#         while let Some(result) = merged.next().await {
#             match result {
#                 Ok(message) => println!("{message}"),
#                 Err(reason) => eprintln!("Problem: {reason:?}"),
#             }
#         }
#     })
# }
#
# fn get_messages() -> impl Stream<Item = String> {
#     let (tx, rx) = trpl::channel();
#
#     trpl::spawn_task(async move {
#         let messages = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"];
#         for (index, message) in messages.into_iter().enumerate() {
#             let time_to_sleep = if index % 2 == 0 { 100 } else { 300 };
#             trpl::sleep(Duration::from_millis(time_to_sleep)).await;
#
#             tx.send(format!("Nachricht: '{message}'")).unwrap();
#         }
#     });
#
#     ReceiverStream::new(rx)
# }
#
# fn get_intervals() -> impl Stream<Item = u32> {
#     let (tx, rx) = trpl::channel();
#
#     trpl::spawn_task(async move {
#         let mut count = 0;
#         loop {
#             trpl::sleep(Duration::from_millis(1)).await;
#             count += 1;
#             tx.send(count).unwrap();
#         }
#     });
#
#     ReceiverStream::new(rx)
# }
```

<span class="caption">Codeblock 17-37: Versuch, die Ströme `messages` and
`intervals` zusammenzuführen</span>

Wir beginnen mit dem Aufruf von `get_intervals`. Dann führen wir die Ströme
`messages` und `intervals` mit der Methode `merge` zusammen, die mehrere Ströme
zu einem Strom kombiniert, der Elemente aus jedem der Quellströme produziert,
sobald die Elemente verfügbar sind, ohne eine bestimmte Reihenfolge
festzulegen. Schließlich laufen wir in einer Schleife über diesen kombinierten
Strom anstatt über `messages`.

Zu diesem Zeitpunkt müssen weder `messages` noch `intervals` angeheftet oder
veränderbar sein, da beide zu einem einzigen Strom `merged` zusammengeführt
werden. Allerdings lässt sich dieser Aufruf von `merge` nicht kompilieren!
(Genauso wenig wie der `next`-Aufruf in der `while let`-Schleife, aber darauf
kommen wir zurück.) Das liegt daran, dass die beiden Ströme unterschiedliche
Typen haben. Der Strom `messages` hat den Typ `Timeout<impl Stream<Item =
 String>>`, wobei `Timeout` der Typ ist, den `Stream` für einen
`timeout`-Aufruf implementiert. Der Strom `intervals` hat den Typ `impl
Stream<Item = u32>`. Um diese beiden Ströme zusammenzuführen, müssen wir
einen von ihnen umwandeln, damit er mit dem anderen übereinstimmt. Wir
überarbeiten den Strom `intervals`, da `messages` bereits das gewünschte
Grundformat hat und Timeout-Fehler behandeln muss (siehe Codeblock 17-38).

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore
# extern crate trpl;
#
# use std::{pin::pin, time::Duration};
#
# use trpl::{ReceiverStream, Stream, StreamExt};
#
# fn main() {
#     trpl::run(async {
        let messages = get_messages().timeout(Duration::from_millis(200));
        let intervals = get_intervals()
            .map(|count| format!("Intervall: {count}"))
            .timeout(Duration::from_secs(10));
        let merged = messages.merge(intervals);
        let mut stream = pin!(merged);
#
#         while let Some(result) = stream.next().await {
#             match result {
#                 Ok(message) => println!("{message}"),
#                 Err(reason) => eprintln!("Problem: {reason:?}"),
#             }
#         }
#     })
# }
#
# fn get_messages() -> impl Stream<Item = String> {
#     let (tx, rx) = trpl::channel();
#
#     trpl::spawn_task(async move {
#         let messages = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"];
#         for (index, message) in messages.into_iter().enumerate() {
#             let time_to_sleep = if index % 2 == 0 { 100 } else { 300 };
#             trpl::sleep(Duration::from_millis(time_to_sleep)).await;
#
#             tx.send(format!("Nachricht: '{message}'")).unwrap();
#         }
#     });
#
#     ReceiverStream::new(rx)
# }
#
# fn get_intervals() -> impl Stream<Item = u32> {
#     let (tx, rx) = trpl::channel();
#
#     trpl::spawn_task(async move {
#         let mut count = 0;
#         loop {
#             trpl::sleep(Duration::from_millis(1)).await;
#             count += 1;
#             tx.send(count).unwrap();
#         }
#     });
#
#     ReceiverStream::new(rx)
# }
```

<span class="caption">Codeblock 17-38: Angleichen des Typs des Stroms
`intervals` an den Typ des Stroms `messages`</span>

Erstens können wir die Hilfsmethode `map` verwenden, um `intervals` in eine
Zeichenkette umzuwandeln. Zweitens müssen wir das `Timeout` aus `messages`
abgleichen. Da wir aber eigentlich keine Zeitüberschreitung für `intervals`
_wollen_, können wir einfach eine Zeitüberschreitung erstellen, die länger ist
als die anderen Zeitspannen, die wir verwenden. Hier erstellen wir eine
10-Sekunden-Zeitüberschreitung mit `Duration::from_secs(10)`. Schließlich
müssen wir `Stream` veränderbar machen, damit die Aufrufe von `next` in der
`while let`-Schleife durch den Strom iterieren können, und ihn so pinnen, dass
es sicher ist, dies zu tun. Damit sind wir _fast_ da, wo wir hinwollen. Alle
Typen passen. Wenn du das Programm ausführst, gibt es allerdings zwei Probleme.
Erstens wird es sich nie beenden! Du musst es mit <kbd>Strg</kbd>+<kbd>c</kbd>
abbrechen. Zweitens werden die Meldungen des englischen Alphabets inmitten all
der Intervallzähler-Meldungen begraben sein:

```text
--abschneiden--
Intervall: 38
Intervall: 39
Intervall: 40
Nachricht: 'a'
Intervall: 41
Intervall: 42
Intervall: 43
--abschneiden--
```

Codeblock 17-39 zeigt eine Möglichkeit, diese beiden letzten Probleme zu lösen.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# extern crate trpl;
#
# use std::{pin::pin, time::Duration};
#
# use trpl::{ReceiverStream, Stream, StreamExt};
#
# fn main() {
#     trpl::run(async {
        let messages = get_messages().timeout(Duration::from_millis(200));
        let intervals = get_intervals()
            .map(|count| format!("Intervall: {count}"))
            .throttle(Duration::from_millis(100))
            .timeout(Duration::from_secs(10));
        let merged = messages.merge(intervals).take(20);
        let mut stream = pin!(merged);
#
#         while let Some(result) = stream.next().await {
#             match result {
#                 Ok(message) => println!("{message}"),
#                 Err(reason) => eprintln!("Problem: {reason:?}"),
#             }
#         }
#     })
# }
#
# fn get_messages() -> impl Stream<Item = String> {
#     let (tx, rx) = trpl::channel();
#
#     trpl::spawn_task(async move {
#         let messages = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"];
#         for (index, message) in messages.into_iter().enumerate() {
#             let time_to_sleep = if index % 2 == 0 { 100 } else { 300 };
#             trpl::sleep(Duration::from_millis(time_to_sleep)).await;
#
#             tx.send(format!("Nachricht: '{message}'")).unwrap();
#         }
#     });
#
#     ReceiverStream::new(rx)
# }
#
# fn get_intervals() -> impl Stream<Item = u32> {
#     let (tx, rx) = trpl::channel();
#
#     trpl::spawn_task(async move {
#         let mut count = 0;
#         loop {
#             trpl::sleep(Duration::from_millis(1)).await;
#             count += 1;
#             tx.send(count).unwrap();
#         }
#     });
#
#     ReceiverStream::new(rx)
# }
```

<span class="caption">Codeblock 17-39: Verwenden von `throttle` und `take` zur
Verwaltung des zusammengeführten Stroms</span>

Zuerst verwenden wir die Methode `throttle` für den Strom `intervals`, sodass
er den Strom `messages` nicht begräbt. Die _Drosselung_ ist eine Möglichkeit,
die Rate zu begrenzen, mit der eine Funktion aufgerufen wird &ndash; oder in
diesem Fall, wie oft der Strom abgefragt wird. Einmal alle 100 Millisekunden
sollte genügen, denn das entspricht in etwa der Häufigkeit, mit der unsere
Nachrichten eintreffen.

Um die Anzahl der Elemente zu begrenzen, die wir aus einem Strom akzeptieren,
wenden wir die Methode `take` auf den _zusammengeführten_ Strom an, da wir die
gesamte Ausgabe begrenzen wollen, nicht nur den einen oder anderen Strom.

Wenn wir das Programm jetzt ausführen, hält es nach dem Abrufen von 20
Elementen aus dem Strom an, und die Intervalle begraben die Nachrichten nicht.
Wir erhalten auch nicht `Intervall: 100` oder `Intervall: 200` usw., sondern
stattdessen `Intervall: 1`, `Intervall: 2` usw. &ndash; obwohl wir einen
Quellstrom haben, der jede Millisekunde ein Ereignis erzeugen _kann_. Das liegt
daran, dass der Aufruf `throttle` einen neuen Strom erzeugt, der den
ursprünglichen Strom umhüllt, sodass der ursprüngliche Strom nur mit der
Drosselrate abgefragt wird und nicht mit seiner eigenen „nativen“ Rate. Wir
haben keine Vielzahl von unbehandelten Intervallnachrichten, die wir ignorieren
wollen. Stattdessen erzeugen wir diese Intervallnachrichten gar nicht erst!
Hier haben wir wieder die inhärente „Faulheit“ von Rusts Futures, die uns
erlaubt, die Leistungsmerkmale zu wählen.

```text
Intervall: 1
Nachricht: 'a'
Intervall: 2
Intervall: 3
Problem: Elapsed(())
Intervall: 4
Nachricht: 'b'
Intervall: 5
Nachricht: 'c'
Intervall: 6
Intervall: 7
Problem: Elapsed(())
Intervall: 8
Nachricht: 'd'
Intervall: 9
Nachricht: 'e'
Intervall: 10
Intervall: 11
Problem: Elapsed(())
Intervall: 12
```

Es gibt noch eine letzte Sache, die wir behandeln müssen: Fehler! Bei diesen
beiden kanalbasierten Strömen könnten die Sendeaufrufe fehlschlagen, wenn die
andere Seite des Kanals geschlossen wird &ndash; und das ist nur eine Frage der
Art und Weise, wie die Laufzeitumgebung die Futures ausführt, die den Strom
bilden. Bis jetzt haben wir dies möglicherweise ignoriert, indem wir `unwrap`
aufgerufen haben, aber in einer anständigen Anwendung sollten wir den Fehler
explizit behandeln, zumindest indem wir die Schleife beenden, damit wir nicht
versuchen, weitere Nachrichten zu senden! Codeblock 17-40 zeigt eine einfache
Fehlerstrategie: Den Fehler ausgeben und dann die Schleife verlassen. 

<span class="filename">Dateiname: src/main.rs</span>

```rust
# extern crate trpl;
#
# use std::{pin::pin, time::Duration};
#
# use trpl::{ReceiverStream, Stream, StreamExt};
#
# fn main() {
#     trpl::run(async {
#         let messages = get_messages().timeout(Duration::from_millis(200));
#         let intervals = get_intervals()
#             .map(|count| format!("Intervall #{count}"))
#             .throttle(Duration::from_millis(500))
#             .timeout(Duration::from_secs(10));
#         let merged = messages.merge(intervals).take(20);
#         let mut stream = pin!(merged);
#
#         while let Some(result) = stream.next().await {
#             match result {
#                 Ok(item) => println!("{item}"),
#                 Err(reason) => eprintln!("Problem: {reason:?}"),
#             }
#         }
#     });
# }
#
fn get_messages() -> impl Stream<Item = String> {
    let (tx, rx) = trpl::channel();

    trpl::spawn_task(async move {
        let messages = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"];

        for (index, message) in messages.into_iter().enumerate() {
            let time_to_sleep = if index % 2 == 0 { 100 } else { 300 };
            trpl::sleep(Duration::from_millis(time_to_sleep)).await;

            if let Err(send_error) = tx.send(format!("Nachricht: '{message}'")) {
                eprintln!("Kann die Nachricht '{message}' nicht senden: {send_error}");
                break;
            }
        }
    });

    ReceiverStream::new(rx)
}

fn get_intervals() -> impl Stream<Item = u32> {
    let (tx, rx) = trpl::channel();

    trpl::spawn_task(async move {
        let mut count = 0;
        loop {
            trpl::sleep(Duration::from_millis(1)).await;
            count += 1;

            if let Err(send_error) = tx.send(count) {
                eprintln!("Konnte das Intervall {count} nicht senden: {send_error}");
                break;
            };
        }
    });

    ReceiverStream::new(rx)
}
```

<span class="caption">Codeblock 17-40: Behandeln von Fehlern und Beenden der
Schleifen</span>

Wie üblich, gibt es verschiedene Weisen, einen Fehler beim Senden von
Nachrichten zu behandeln, &ndash; stelle einfach sicher, dass du eine Strategie
hast.

Nachdem wir nun eine Menge asynchronen Code in der Praxis gesehen haben, wollen
wir einen Schritt zurückgehen und uns ein paar Details, wie `Future`, `Stream`
und andere Schlüsselmerkmale, die Rust verwendet, ansehen, die die asynchrone
Programmierung ermöglichen.

[17-02-messages]: ch17-02-concurrency-with-async.html#hochzählen-in-zwei-aufgaben-mit-nachrichtenübermittlung
[iterator]: ch13-02-iterators.html#das-merkmal-trait-iterator-und-die-methode-next
