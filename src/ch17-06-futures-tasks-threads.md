## Alles zusammenfügen: Futures, Aufgaben und Stränge

Wie wir in [Kapitel 16][ch16] gesehen haben, bieten Stränge (threads) einen
Ansatz für Nebenläufigkeit (concurrency). In diesem Kapitel haben wir einen
anderen Ansatz für Nebenläufigkeit gesehen: Verwenden von asynchronem Code mit
Futures und Strömen (streams). Wenn du dich fragst, wann du eine Methode der
anderen vorziehen solltest, lautet die Antwort: Es kommt darauf an! Und in
vielen Fällen ist die Wahl nicht Stränge _oder_ asynchroner Code, sondern eher
Stränge _und_ asynchroner Code.

Viele Betriebssysteme bieten schon seit Jahrzehnten Strang-basierte
Nebenläufigkeitsmodelle an, und viele Programmiersprachen unterstützen diese
Modelle daher. Diese Modelle sind jedoch nicht frei von Kompromissen. Auf
vielen Betriebssystemen wird für jeden Strang ein beträchtlicher Teil an
Arbeitsspeicher verbraucht und es entsteht ein gewisser Overhead beim Starten
und Beenden. Stränge sind auch nur dann eine Option, wenn dein Betriebssystem
und deine Hardware sie unterstützen. Im Gegensatz zu herkömmlichen Desktop- und
Mobilcomputern haben einige eingebettete Systeme überhaupt kein Betriebssystem,
sodass sie auch keine Stränge haben.

Das asynchrone Modell bietet eine andere &ndash; und letztlich ergänzende
&ndash; Reihe von Kompromissen. Im asynchronen Modell benötigen nebenläufige
Vorgänge keine eigenen Stränge. Stattdessen können sie in Aufgaben laufen, so
wie wir `trpl::spawn_task` verwendet haben, um die Arbeit von einer synchronen
Funktion im Abschnitt „Ströme“ zu starten. Eine Aufgabe ähnelt einem Strang,
wird aber nicht vom Betriebssystem, sondern von einem Code auf Bibliotheksebene
verwaltet: der Laufzeitumgebung.

Im vorigen Abschnitt haben wir gesehen, dass wir einen Strom erstellen können,
indem wir einen asynchronen Kanal verwenden und eine asynchrone Aufgabe
erzeugen, die wir von synchronem Code aus aufrufen können. Wir können genau das
Gleiche mit einem Strang machen! In Codeblock 17-40 haben wir
`trpl::spawn_task` und `trpl::sleep` verwendet. In Codeblock 17-41 ersetzen wir
diese durch die APIs `thread::spawn` und `thread::sleep` aus der
Standardbibliothek.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# extern crate trpl;
#
# use std::{pin::pin, thread, time::Duration};
#
# use trpl::{ReceiverStream, Stream, StreamExt};
#
# fn main() {
#     trpl::run(async {
#         let messages = get_messages().timeout(Duration::from_millis(200));
#         let intervals = get_intervals()
#             .map(|count| format!("Interval #{count}"))
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
# fn get_messages() -> impl Stream<Item = String> {
#     let (tx, rx) = trpl::channel();
#
#     trpl::spawn_task(async move {
#         let messages = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"];
#
#         for (index, message) in messages.into_iter().enumerate() {
#             let time_to_sleep = if index % 2 == 0 { 100 } else { 300 };
#             trpl::sleep(Duration::from_millis(time_to_sleep)).await;
#
#             if let Err(send_error) = tx.send(format!("Nachricht: '{message}'")) {
#                 eprintln!("Kann die Nachricht '{message}' nicht senden: {send_error}");
#                 break;
#             }
#         }
#     });
#
#     ReceiverStream::new(rx)
# }
#
fn get_intervals() -> impl Stream<Item = u32> {
    let (tx, rx) = trpl::channel();

    // Dies ist *nicht* `trpl::spawn` sondern `std::thread::spawn`!
    thread::spawn(move || {
        let mut count = 0;
        loop {
            // Ebenso ist dies *nicht* `trpl::sleep` sondern `std::thread::sleep`!
            thread::sleep(Duration::from_millis(1));
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

<span class="caption">Codeblock 17-41: Verwenden der `std::thread`-APIs
anstelle der asynchronen `trpl`-APIs für die Funktion `get_intervals`</span>

Wenn du diesen Code ausführst, ist die Ausgabe identisch zu der von Codeblock
17-40. Und beachte, wie wenig sich hier aus der Sicht des aufrufenden Codes
ändert! Und obwohl eine unserer Funktionen eine asynchrone Aufgabe in der
Laufzeitumgebung und die andere einen Betriebssystem-Strang startet, hat es
keinen Effekt auf die resultierenden Ströme.

Trotz deren Ähnlichkeiten verhalten sich diese beiden Ansätze sehr
unterschiedlich, obwohl wir es in diesem sehr einfachen Beispiel schwer haben,
dies zu messen. Wir könnten Millionen von asynchronen Aufgaben auf jedem
modernen Computer ausführen. Wenn wir das mit Strängen versuchen würden, würde
uns buchstäblich der Speicher ausgehen!

Es gibt jedoch einen Grund, warum sich diese APIs so ähnlich sind. Stränge
dienen als Grenze für Gruppen von synchronen Operationen; Nebenläufigkeit ist
_zwischen_ Strängen möglich. Aufgaben fungieren als Grenze für Gruppen von
_asynchronen_ Vorgängen; Nebenläufigkeit ist sowohl _zwischen_ als auch
_innerhalb_ von Aufgaben möglich, da eine Aufgabe in ihrem Rumpf zwischen
Futures wechseln kann. Schließlich sind Futures die granularste Einheit der
Nebenläufigkeit in Rust, und jedes Future kann einen Baum von anderen Futures
darstellen. Die Laufzeitumgebung &ndash; genauer gesagt ihr Executor &ndash;
verwaltet Aufgaben, und Aufgaben verwalten Futures. In dieser Hinsicht ähneln
Aufgaben leichtgewichtigen, von der Laufzeitumgebung verwalteten Strängen mit
zusätzlichen Fähigkeiten, die sich daraus ergeben, dass sie von der
Laufzeitumgebung und nicht vom Betriebssystem verwaltet werden.

Das bedeutet nicht, dass asynchrone Aufgaben immer besser sind als Stränge
(oder umgekehrt). Nebenläufigkeit mit Strängen ist in gewisser Weise ein
einfacheres Programmiermodell als Nebenläufigkeit mit `async`. Das kann eine
Stärke und eine Schwäche sein. Stränge sind eine Art „Feuern und Vergessen“;
sie haben kein natives Äquivalent zu einem Future, also laufen sie einfach bis
zum Ende, ohne Unterbrechung, außer durch das Betriebssystem selbst. Das heißt,
sie haben keine eingebaute Unterstützung für _Nebenläufigkeit innerhalb der
Aufgabe_, wie es Futures haben. Stränge in Rust haben auch keine Mechanismen um
die abzubrechen &ndash; ein Thema, das wir in diesem Kapitel nicht eingehend
behandelt haben, das aber implizit in der Tatsache enthalten ist, dass immer
dann, wenn wir ein Future beenden, sein Zustand korrekt aufgeräumt wird.

Diese Einschränkungen machen es auch schwieriger, Stränge zu kombinieren, als
Futures. Es ist zum Beispiel viel schwieriger, Stränge zu verwenden, um Helfer
wie `timeout` und `throttle` zu erstellen, die wir weiter oben in diesem
Kapitel erstellt haben. Die Tatsache, dass Futures reichhaltigere
Datenstrukturen sind, bedeutet, dass sie natürlicher zusammengesetzt werden
können, wie wir gesehen haben.

Aufgaben geben uns dann _zusätzliche_ Kontrolle über Futures, da man wählen
kann, wo und wie man die Futures gruppiert. Und es stellt sich heraus, dass
Stränge und Aufgaben oft sehr gut zusammenarbeiten, weil Aufgaben (zumindest in
einigen Laufzeitumgebungen) zwischen Strängen verschoben werden können. Unter
der Haube ist die Laufzeitumgebung, die wir verwenden &ndash; einschließlich
der Funktionen `spawn_blocking` und `spawn_task` &ndash; standardmäßig
mehrstängig (multithreaded)! Viele Laufzeitumgebungen verwenden einen Ansatz
namens _Work Stealing_, um Aufgaben transparent zwischen Strängen zu
verschieben, je nachdem, wie die Stränge gerade ausgelastet sind, um die
Gesamtleistung des Systems zu verbessern. Dieser Ansatz erfordert eigentlich
Stränge _und_ Aufgaben, und damit Futures.

Wenn du überlegst, welche Methode du wann anwenden solltest, beachte diese
Faustregeln:

- Wenn die Arbeit _sehr parallelisierbar_ ist, z.B. bei der Verarbeitung einer
  Menge von Daten, bei der jeder Teil separat verarbeitet werden kann, sind
  Stränge die bessere Wahl.
- Wenn es sich um _sehr nebenläufige_ Arbeit handelt, wie die Bearbeitung von
  Nachrichten aus einer Reihe von verschiedenen Quellen, die in
  unterschiedlichen Intervallen oder mit unterschiedlicher Geschwindigkeit
  eintreffen können, ist asynchroner Code die bessere Wahl.

Und wenn du Parallelität und Nebenläufigkeit benötigst, musst du dich nicht
zwischen Strängen und asynchronem Code entscheiden. Du kannst beide zusammen
verwenden, wobei jede der beiden die Aufgabe übernimmt, für die sie am besten
geeignet ist. Codeblock 17-42 zeigt zum Beispiel ein gängiges Beispiel für
dieses Zusammenspiel in echtem Rust-Code.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# extern crate trpl;
#
use std::{thread, time::Duration};

fn main() {
    let (tx, mut rx) = trpl::channel();

    thread::spawn(move || {
        for i in 1..11 {
            tx.send(i).unwrap();
            thread::sleep(Duration::from_secs(1));
        }
    });

    trpl::run(async {
        while let Some(message) = rx.recv().await {
            println!("{message}");
        }
    });
}
```

<span class="caption">Codeblock 17-42: Senden von Nachrichten mit blockierendem
Code in einem Strang und Warten auf die Nachrichten in einem asynchronen
Block</span>

Wir beginnen mit der Erstellung eines asynchronen Kanals. Dann legen wir einen
Strang an, der für die Senderseite des Kanals zuständig ist. Innerhalb des
Strangs senden wir die Zahlen 1 bis 10 und schlafen dazwischen jeweils eine
Sekunde lang. Schließlich führen wir ein Future aus, das mit einem asynchronen
Block erstellt wurde, der an `trpl::run` übergeben wurde, so wie wir es im
ganzen Kapitel getan haben. In diesem Future warten wir auf diese Nachrichten,
genau wie in den anderen Beispielen mit Nachrichten-Weitergabe, die wir gesehen
haben.

Um zu den Szenarien zurückzukehren, mit denen wir das Kapitel eröffnet haben,
könnte man sich vorstellen, dass eine Reihe von Videokodierungsaufgaben über
einen dedizierten Strang ausgeführt wird, da die Videokodierung rechenintensiv
ist. Die Benutzeroberfläche kann aber über einen asynchronen Kanal informiert
werden, wenn diese Vorgänge ausgeführt werden. Es gibt unzählige Beispiele für
diese Art von Kombinationen in der Praxis.

## Zusammenfassung

Dies ist nicht das letzte Mal, dass du in diesem Buch etwas über
Nebenläufigkeit lesen wirst. Das Projekt in [Kapitel 21][ch21] wird die
Konzepte dieses Kapitels in einer realistischeren Situation anwenden als die
hier besprochenen einfacheren Beispiele und einen direkteren Vergleich
anstellen, wie es aussieht, wenn man diese Art von Problemen mit Strängen und
mit Aufgaben und Futures löst.

Welchen Ansatz du auch immer wählst, Rust gibt dir die Werkzeuge an die Hand,
die du benötigst, um sicheren, schnellen und nebenläufigen Code zu schreiben
&ndash; sei es für einen durchsatzstarken Webserver oder ein eingebettetes
Betriebssystem.

Als nächstes werden wir über idiomatische Wege sprechen, Probleme zu
modellieren und Lösungen zu strukturieren, wenn deine Rust-Programme größer
werden. Außerdem werden wir erörtern, wie die Idiome von Rust mit denen
verwandt sind, die du vielleicht aus der objektorientierten Programmierung
kennst.

[ch16]: ch16-00-concurrency.html
[ch21]: ch21-00-final-project-a-web-server.html
