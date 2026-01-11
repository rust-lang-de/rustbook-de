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
Arbeitsspeicher verbraucht. Stränge sind auch nur dann eine Option, wenn dein
Betriebssystem und deine Hardware sie unterstützen. Im Gegensatz zu
herkömmlichen Desktop- und Mobilcomputern haben einige eingebettete Systeme
überhaupt kein Betriebssystem, sodass sie auch keine Stränge haben.

Das asynchrone Modell bietet eine andere &ndash; und letztlich ergänzende
&ndash; Reihe von Kompromissen. Im asynchronen Modell benötigen nebenläufige
Vorgänge keine eigenen Stränge. Stattdessen können sie in Aufgaben laufen, so
wie wir `trpl::spawn_task` verwendet haben, um die Arbeit von einer synchronen
Funktion im Abschnitt „Ströme“ zu starten. Eine Aufgabe ähnelt einem Strang,
wird aber nicht vom Betriebssystem, sondern von einem Code auf Bibliotheksebene
verwaltet: der Laufzeitumgebung.

Es gibt einen Grund dafür, dass die APIs zum Erzeugen von Strängen und zum
Erzeugen von Aufgaben so ähnlich sind. Stränge dienen als Grenze für Gruppen
von synchronen Operationen; Nebenläufigkeit ist _zwischen_ Strängen möglich.
Aufgaben fungieren als Grenze für Gruppen von _asynchronen_ Vorgängen;
Nebenläufigkeit ist sowohl _zwischen_ als auch _innerhalb_ von Aufgaben
möglich, da eine Aufgabe in ihrem Rumpf zwischen Futures wechseln kann.
Schließlich sind Futures die granularste Einheit der Nebenläufigkeit in Rust,
und jedes Future kann einen Baum von anderen Futures darstellen. Die
Laufzeitumgebung &ndash; genauer gesagt ihr Executor &ndash; verwaltet
Aufgaben, und Aufgaben verwalten Futures. In dieser Hinsicht ähneln Aufgaben
leichtgewichtigen, von der Laufzeitumgebung verwalteten Strängen mit
zusätzlichen Fähigkeiten, die sich daraus ergeben, dass sie von der
Laufzeitumgebung und nicht vom Betriebssystem verwaltet werden.

Das bedeutet nicht, dass asynchrone Aufgaben immer besser sind als Stränge
(oder umgekehrt). Nebenläufigkeit mit Strängen ist in gewisser Weise ein
einfacheres Programmiermodell als Nebenläufigkeit mit `async`. Das kann eine
Stärke und eine Schwäche sein. Stränge sind eine Art „Feuern und Vergessen“;
sie haben kein natives Äquivalent zu einem Future, also laufen sie einfach bis
zum Ende, ohne Unterbrechung, außer durch das Betriebssystem selbst.

Und es stellt sich heraus, dass Stränge und Aufgaben oft sehr gut
zusammenarbeiten, weil Aufgaben (zumindest in einigen Laufzeitumgebungen)
zwischen Strängen verschoben werden können. Unter der Haube ist die
Laufzeitumgebung, die wir verwenden &ndash; einschließlich der Funktionen
`spawn_blocking` und `spawn_task` &ndash; standardmäßig mehrstängig
(multithreaded)! Viele Laufzeitumgebungen verwenden einen Ansatz namens _Work
Stealing_, um Aufgaben transparent zwischen Strängen zu verschieben, je
nachdem, wie die Stränge gerade ausgelastet sind, um die Gesamtleistung des
Systems zu verbessern. Dieser Ansatz erfordert eigentlich Stränge _und_
Aufgaben, und damit Futures.

Wenn du überlegst, welche Methode du wann anwenden solltest, beachte diese
Daumenregeln:

- Wenn die Arbeit _sehr parallelisierbar_ ist (d.h. CPU-gebunden), z.B. bei der
  Verarbeitung einer Menge von Daten, bei der jeder Teil separat verarbeitet
  werden kann, sind Stränge die bessere Wahl.
- Wenn es sich um _sehr nebenläufige_ Arbeit handelt (d.h. E/A-gebunden), wie
  die Bearbeitung von Nachrichten aus einer Reihe von verschiedenen Quellen,
  die in unterschiedlichen Intervallen oder mit unterschiedlicher
  Geschwindigkeit eintreffen können, ist asynchroner Code die bessere Wahl.

Und wenn du Parallelität und Nebenläufigkeit benötigst, musst du dich nicht
zwischen Strängen und asynchronem Code entscheiden. Du kannst beide zusammen
verwenden, wobei jede der beiden die Aufgabe übernimmt, für die sie am besten
geeignet ist. Codeblock 17-25 zeigt zum Beispiel ein gängiges Beispiel für
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

    trpl::block_on(async {
        while let Some(message) = rx.recv().await {
            println!("{message}");
        }
    });
}
```

<span class="caption">Codeblock 17-25: Senden von Nachrichten mit blockierendem
Code in einem Strang und Warten auf die Nachrichten in einem asynchronen
Block</span>

Wir beginnen mit der Erstellung eines asynchronen Kanals. Dann legen wir einen
Strang an, der für die Senderseite des Kanals zuständig ist, indem wir das
Schlüsselword `move` verwenden. Innerhalb des Strangs senden wir die Zahlen 1
bis 10 und schlafen dazwischen jeweils eine Sekunde lang. Schließlich führen
wir ein Future aus, das mit einem asynchronen Block erstellt wurde, der an
`trpl::block_on` übergeben wurde, so wie wir es im ganzen Kapitel getan haben.
In diesem Future warten wir auf diese Nachrichten, genau wie in den anderen
Beispielen mit Nachrichten-Weitergabe, die wir gesehen haben.

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
