## Futures, Aufgaben und Stränge

Wie wir im vorigen Kapitel gesehen haben, bieten Stränge (threads) einen Ansatz
für Nebenläufigkeit (concurrency). In diesem Kapitel haben wir einen anderen
Ansatz für Nebenläufigkeit gesehen, nämlich die Verwendung von asynchronem Code
mit Futures und Strömen. Du fragst dich vielleicht, warum du dich für das eine
oder das andere entscheiden solltest. Die Antwort lautet: Es kommt darauf an!
Und in vielen Fällen ist die Wahl nicht Stränge *oder* asynchroner Code,
sondern eher Stränge *und* asynchroner Code.

Viele Betriebssysteme bieten schon seit Jahrzehnten Strang-basierte
Nebenläufigkeitsmodelle an, und viele Programmiersprachen unterstützen diese
Modelle daher. Sie sind jedoch nicht ohne Kompromisse. Auf vielen
Betriebssystemen wird für jeden Strang ein beträchtlicher Teil des
Arbeitsspeichers verbraucht, und es entsteht ein gewisser Overhead beim Starten
und Beenden. Stränge sind auch nur dann eine Option, wenn dein Betriebssystem
und deine Hardware sie unterstützen! Im Gegensatz zu herkömmlichen Desktop- und
Mobilcomputern haben einige eingebettete Systeme überhaupt kein Betriebssystem,
sodass sie auch keine Stränge haben!

Das asynchrone Modell bietet eine andere &ndash; und letztlich ergänzende
&ndash; Reihe von Kompromissen. Im asynchronen Modell benötigen gleichzeitige
Operationen keine eigenen Stränge. Stattdessen können sie auf Aufgaben laufen,
so wie wir `trpl::spawn_task` verwendet haben, um die Arbeit von einer
synchronen Funktion im Abschnitt Ströme zu starten. Eine Aufgabe ähnelt einem
Strang, wird aber nicht vom Betriebssystem, sondern von einem Code auf
Bibliotheksebene verwaltet: Der Laufzeitumgebung.

Im vorigen Abschnitt haben wir gesehen, dass wir einen `Stream` erstellen
können, indem wir einen asynchronen Kanal verwenden und eine asynchrone Aufgabe
erzeugen, die wir von synchronem Code aus aufrufen können. Wir könnten genau
das Gleiche mit einem Strang machen! In Codeblock 17-40 haben wir
`trpl::spawn_task` und `trpl::sleep` verwendet. In Codeblock 17-41 ersetzen wir
diese durch die APIs `thread::spawn` und `thread::sleep` aus der
Standardbibliothek in der Funktion `get_intervals`.

<span class="filename">Dateiname: src/main.rs</span>

```rust
{{#rustdoc_include ../listings/ch17-async-await/listing-17-41/src/main.rs:threads}}
```

<span class="caption">Codeblock 17-41: Verwenden der `std::thread`-APIs
anstelle der asynchronen `trpl`-APIs für die Funktion `get_intervals`.</span>

Wenn du dies ausführst, ist die Ausgabe identisch. Und beachte, wie wenig sich
hier aus der Sicht des aufrufenden Codes ändert! Und obwohl eine unserer
Funktionen eine asynchrone Aufgabe auf der Laufzeitumgebung und die andere
einen Betriebssystem-Strang startet, hat es keinen Effekt auf die
resultierenden Ströme.

Trotz der Ähnlichkeiten verhalten sich diese beiden Ansätze sehr
unterschiedlich, obwohl wir es in diesem sehr einfachen Beispiel schwer haben,
dies zu messen. Wir könnten Millionen von asynchronen Aufgaben auf jedem
modernen Computer ausführen. Wenn wir das mit Strängen versuchen würden, würde
uns buchstäblich der Speicher ausgehen!

Es gibt jedoch einen Grund, warum sich diese APIs so ähnlich sind. Stränge
dienen als Grenze für Gruppen von synchronen Operationen; Nebenläufigkeit ist
*zwischen* Strängen möglich. Aufgaben fungieren als Grenze für Gruppen von
*asynchronen* Vorgängen; Nebenläufigkeit ist sowohl *zwischen* als auch
*innerhalb* von Aufgaben möglich, da eine Aufgabe in ihrem Rumpf zwischen
Futures wechseln kann. Schließlich sind Futures die granularste Einheit der
Nebenläufigkeit in Rust, und jedes Future kann einen Baum von anderen Futures
darstellen. Die Laufzeitumgebung &ndash; genauer gesagt ihr Executor &ndash;
verwaltet Aufgaben, und Aufgaben verwalten Futures. In dieser Hinsicht ähneln
Aufgaben leichtgewichtigen, von der Laufzeitumgebung verwalteten Strängen mit
zusätzlichen Fähigkeiten, die sich daraus ergeben, dass sie von der
Laufzeitumgebung und nicht vom Betriebssystem verwaltet werden.

Das bedeutet nicht, dass asynchrone Aufgaben immer besser sind als Stränge, und
auch nicht, dass Stränge immer besser sind als Aufgaben.

Nebenläufigkeit mit Strängen ist in gewisser Weise ein einfacheres
Programmiermodell als Nebenläufigkeit mit `async`. Das kann eine Stärke oder
eine Schwäche sein. Stränge sind eine Art „Feuern und Vergessen“, sie haben
kein natives Äquivalent zu einem Future, also laufen sie einfach bis zum Ende,
ohne Unterbrechung, außer durch das Betriebssystem selbst. Das heißt, sie haben
keine eingebaute Unterstützung für *Nebenläufigkeit innerhalb der Aufgabe*, wie
es Futures tun. Stränge in Rust haben auch keine Mechanismen um die abzubrechen
&ndash; ein Thema, das wir in diesem Kapitel nicht eingehend behandelt haben,
das aber implizit in der Tatsache enthalten ist, dass immer dann, wenn wir ein
Future beenden, sein Zustand korrekt aufgeräumt wird.

Diese Einschränkungen machen es auch schwieriger, Stränge zu erstellen als
Futures. Es ist zum Beispiel viel schwieriger, Stränge zu verwenden, um Helfer
wie `timeout` zu bauen, das wir in [„Eigene Async-Abstraktionen
erstellen“][combining-futures] gesehen haben, oder die Methode `throttle`, die
wir mit Strömen in [„Komposition von Strömen“][streams] verwendet haben. Die
Tatsache, dass Futures reichhaltigere Datenstrukturen sind, bedeutet, dass sie
natürlicher zusammengesetzt werden können, wie wir gesehen haben.

Aufgaben geben dann *zusätzliche* Kontrolle über Futures, da man wählen kann,
wo und wie man die Futures gruppiert. Und es stellt sich heraus, dass Stränge
und Aufgaben oft sehr gut zusammenarbeiten, weil Aufgaben (zumindest in einigen
Laufzeitumgebungen) zwischen Strängen verschoben werden können. Wir haben es
bis jetzt nicht erwähnt, aber unter der Haube ist die `Runtime`, die wir
benutzt haben, einschließlich der Funktionen `spawn_blocking` und `spawn_task`,
standardmäßig mehrstängig (multithreaded)! Viele Laufzeitumgebungen verwenden
einen Ansatz namens *Work Stealing*, um Aufgaben transparent zwischen Strängen
hin- und herzuschieben, je nach aktueller Auslastung der Stränge. Ziel ist, die
die Gesamtleistung des Systems zu verbessern. Um das zu bauen, braucht man
eigentlich Stränge *und* Aufgaben, und damit Futures.

Daumenregel, was wann zu verwenden ist:

- Wenn die Arbeit *sehr parallelisierbar* ist, z.B. bei der Verarbeitung einer
  Menge von Daten, bei der jeder Teil separat verarbeitet werden kann, sind
  Stränge die bessere Wahl.
- Wenn es sich um *sehr nebenläufige* Arbeit handelt, wie die Bearbeitung von
  Nachrichten aus einer Reihe von verschiedenen Quellen, die in
  unterschiedlichen Intervallen oder mit unterschiedlicher Geschwindigkeit
  eintreffen können, ist asynchroner Code die bessere Wahl.

Und wenn du eine Mischung aus Parallelität und Nebenläufigkeit benötigst, musst
du dich nicht zwischen Strängen und asynchronem Code entscheiden. Du kannst
beide zusammen verwenden, wobei jede der beiden die Aufgabe übernimmt, für die
sie am besten geeignet ist. Codeblock 17-42 zeigt zum Beispiel ein ziemlich
häufiges Beispiel für diese Art von Mischung in echtem Rust-Code.

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
Strang an, der für die Absenderseite des Kanals zuständig ist. Innerhalb des
Strangs senden wir die Zahlen 1 bis 10 und schlafen dazwischen jeweils eine
Sekunde lang. Schließlich führen wir ein Future aus, das mit einem asynchronen
Block erstellt wurde, der an `trpl::run` übergeben wurde, so wie wir es im
ganzen Kapitel getan haben. In diesem Future warten wir auf diese Nachrichten,
genau wie in den anderen Beispielen für die Weitergabe von Nachrichten, die wir
gesehen haben.

Um zu den Beispielen zurückzukehren, mit denen wir das Kapitel eröffnet haben:
Man könnte sich vorstellen, dass eine Reihe von Videokodierungsaufgaben über
einen dedizierten Strang ausgeführt wird, da die Videokodierung rechenintensiv
ist. Die Benutzeroberfläche kann aber über einen asynchronen Kanal informiert
werden, wenn diese Vorgänge ausgeführt werden. Beispiele für diese Art von Mix
gibt es zuhauf!

## Zusammenfassung

Das Projekt in Kapitel 21 wird die Konzepte dieses Kapitels in einer
realistischeren Situation anwenden als die hier besprochenen kleineren
Beispiele &ndash; und einen direkteren Vergleich anstellen, wie es aussieht,
wenn man diese Art von Problemen mit Strängen und mit Aufgaben und Futures
löst.

Ob mit Strängen, mit Futures und Aufgaben oder mit einer Kombination aus
beidem, Rust gibt dir die Werkzeuge an die Hand, die du benötigst, um
sicheren, schnellen und nebenläufigen Code zu schreiben &ndash; sei es für
einen durchsatzstarken Webserver oder ein eingebettetes Betriebssystem.

Als nächstes werden wir über idiomatische Wege sprechen, Probleme zu
modellieren und Lösungen zu strukturieren wenn deine Rust-Programme größer
werden. Außerdem werden wir erörtern, wie die Idiome von Rust mit denen
verwandt sind, die du vielleicht aus der objektorientierten Programmierung
kennst.

[combining-futures]: ch17-03-more-futures.html#eigene-async-abstraktionen-erstellen
[streams]: ch17-04-streams.html#komposition-von-strömen
