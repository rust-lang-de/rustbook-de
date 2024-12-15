## Nebenläufigkeit mit async

In diesem Abschnitt werden wir async auf einige der Nebenläufigkeitsprobleme
anwenden, die wir in Kapitel 16 mit Strängen angegangen sind. Da wir dort
bereits über viele der Schlüsselideen gesprochen haben, werden wir uns in
diesem Abschnitt auf die Unterschiede zwischen Strängen und Futures
konzentrieren.

In vielen Fällen sind die APIs für den Umgang mit Nebenläufigkeit mittels async
sehr ähnlich zu denen mit Strängen. In anderen Fällen sind sie am Ende ganz
anders gestaltet. Selbst wenn die APIs von Strängen und async *ähnlich*
aussehen, haben sie oft ein anderes Verhalten und fast immer unterschiedliche
Leistungsmerkmale.

### Zählen

Die erste Aufgabe, die wir in Kapitel 16 in Angriff genommen haben, war das
Hochzählen in zwei separaten Strängen. Lass uns das Gleiche mit async machen.
Die Kiste `trpl` enthält eine Funktion `spawn_task`, die der API
`thread::spawn` sehr ähnlich ist, und eine Funktion `sleep`, die eine
async-Version der API `thread::sleep` ist. Wir können diese zusammen verwenden,
um das gleiche Zählbeispiel wie mit Strängen in Codeblock 17-6 zu
implementieren.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# extern crate trpl;
#
use std::time::Duration;

fn main() {
    trpl::run(async {
        trpl::spawn_task(async {
            for i in 1..10 {
                println!("Hallo Nummer {i} von der ersten Aufgabe!");
                trpl::sleep(Duration::from_millis(500)).await;
            }
        });

        for i in 1..5 {
            println!("Hallo Nummer {i} von der zweiten Aufgabe!");
            trpl::sleep(Duration::from_millis(500)).await;
        }
    });
}
```

<span class="caption">Codeblock 17-6: Verwenden von `spawn_task`</span>

Als Ausgangspunkt richten wir unsere Funktion `main` mit `trpl::run` ein,
sodass unsere Top-Level-Funktion asynchron sein kann.

> Hinweis: Von diesem Punkt an in diesem Kapitel wird jedes Beispiel genau
> den gleichen Rahmen-Code mit `trpl::run` in `main` enthalten, also werden wir
> ihn oft auslassen, genau wie wir es mit `main` tun. Vergiss nicht, ihn in
> deinem Code einzubauen!

Dann schreiben wir zwei Schleifen innerhalb dieses Blocks, jede mit einem
`trpl::sleep`-Aufruf, der eine halbe Sekunde (500 Millisekunden) wartet, bevor
die nächste Nachricht gesendet wird. Wir platzieren die eine Schleife in den
Rumpf des `trpl::spawn_task`-Aufrufs und die andere in eine `for`-Schleife auf
oberster Ebene. Wir fügen auch ein `await` nach den `sleep`-Aufrufen ein.

Dies funktioniert ähnlich wie die Strang-basierte Implementierung &ndash;
einschließlich der Tatsache, dass die Meldungen in deinem Terminal in einer
anderen Reihenfolge erscheinen, wenn du es ausführst.

```text
Hallo Nummer 1 von der zweiten Aufgabe!
Hallo Nummer 1 von der ersten Aufgabe!
Hallo Nummer 2 von der ersten Aufgabe!
Hallo Nummer 2 von der zweiten Aufgabe!
Hallo Nummer 3 von der ersten Aufgabe!
Hallo Nummer 3 von der zweiten Aufgabe!
Hallo Nummer 4 von der ersten Aufgabe!
Hallo Nummer 4 von der zweiten Aufgabe!
Hallo Nummer 5 von der ersten Aufgabe!
```

Diese Version beendet sich, sobald die for-Schleife im Rumpf des asynchronen
Blocks beendet ist, da die von `spawn_task` erzeugte Aufgabe beendet wird, wenn
die Hauptfunktion endet. Wenn du die Aufgabe bis zum Ende ausführen willst,
musst du ein Join-Handle verwenden, um auf das Ende der ersten Aufgabe zu
warten. Bei Strängen haben wir die Methode `join` verwendet, um zu
„blockieren“, bis der Strang fertig ist. In Codeblock 17-7 können wir `await`
verwenden, um dasselbe zu tun, weil das Task-Handle selbst ein Future ist. Sein
`Output`-Typ ist ein `Result`, also entpacken wir es ebenfalls, nachdem wir es
erwartet haben.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# extern crate trpl;
#
# use std::time::Duration;
#
# fn main() {
#     trpl::run(async {
        let handle = trpl::spawn_task(async {
            for i in 1..10 {
                println!("Hallo Nummer {i} von der ersten Aufgabe!");
                trpl::sleep(Duration::from_millis(500)).await;
            }
        });

        for i in 1..5 {
            println!("Hallo Nummer {i} von der zweiten Aufgabe!");
            trpl::sleep(Duration::from_millis(500)).await;
        }

        handle.await.unwrap();
#     });
# }
```

<span class="caption">Codeblock 17-7: Verwenden von `await` mit einem
Join-Handle, um eine Aufgabe bis zum Ende auszuführen</span>

Diese aktualisierte Version läuft, bis *beide* Schleifen beendet sind.


```text
Hallo Nummer 1 von der zweiten Aufgabe!
Hallo Nummer 1 von der ersten Aufgabe!
Hallo Nummer 2 von der ersten Aufgabe!
Hallo Nummer 2 von der zweiten Aufgabe!
Hallo Nummer 3 von der ersten Aufgabe!
Hallo Nummer 3 von der zweiten Aufgabe!
Hallo Nummer 4 von der ersten Aufgabe!
Hallo Nummer 4 von der zweiten Aufgabe!
Hallo Nummer 5 von der ersten Aufgabe!
Hallo Nummer 6 von der ersten Aufgabe!
Hallo Nummer 7 von der ersten Aufgabe!
Hallo Nummer 8 von der ersten Aufgabe!
Hallo Nummer 9 von der ersten Aufgabe!
```

Bisher sieht es so aus, als ob async und Stränge zu den gleichen Ergebnissen
führen, nur mit einer anderen Syntax: Verwenden von `await` anstelle des
Aufrufs von `join` auf dem Join-Handle und Abwarten der `sleep`-Aufrufe.

Der größere Unterschied ist, dass wir dafür keinen weiteren
Betriebssystem-Strang starten müssen. Tatsächlich brauchen wir hier nicht
einmal eine Aufgabe zu starten. Da asynchrone Blöcke zu anonymen Futures
kompiliert werden, können wir jede Schleife in einen asynchronen Block packen
und die Laufzeitumgebung beide mittels der Funktion `trpl::join` zu Ende führen
lassen.

In Kapitel 16 haben wir gezeigt, wie man die Methode `join` auf den Typ
`JoinHandle` anwendet, der beim Aufruf von `std::thread::spawn` zurückgegeben
wird. Die Funktion `trpl::join` ist ähnlich, aber für Futures. Wenn du ihr zwei
Futures gibst, erzeugt sie ein einziges neues Future, dessen Ausgabe ein Tupel
mit der Ausgabe der beiden übergebenen Futures ist, sobald *beide*
abgeschlossen sind. In Codeblock 17-8 verwenden wir also `trpl::join`, um
darauf zu warten, dass sowohl `fut1` als auch `fut2` fertig sind. Wir warten
*nicht* auf `fut1` und `fut2`, sondern auf das neue Future, das von
`trpl::join` erzeugt wird. Wir ignorieren die Ausgabe, da es sich nur um ein
Tupel mit zwei Einheitswerten darin handelt.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# extern crate trpl;
#
# use std::time::Duration;
#
# fn main() {
#     trpl::run(async {
        let fut1 = async {
            for i in 1..10 {
                println!("Hallo Nummer {i} von der ersten Aufgabe!");
                trpl::sleep(Duration::from_millis(500)).await;
            }
        };

        let fut2 = async {
            for i in 1..5 {
                println!("Hallo Nummer {i} von der zweiten Aufgabe!");
                trpl::sleep(Duration::from_millis(500)).await;
            }
        };

        trpl::join(fut1, fut2).await;
#     });
# }
```

<span class="caption">Codeblock 17-8: Verwenden von `trpl::join`, um auf zwei
anonyme Futures zu warten</span>

Wenn wir dies ausführen, sehen wir, dass beide Futures bis zum Ende laufen:

```text
Hallo Nummer 1 von der ersten Aufgabe!
Hallo Nummer 1 von der zweiten Aufgabe!
Hallo Nummer 2 von der ersten Aufgabe!
Hallo Nummer 2 von der zweiten Aufgabe!
Hallo Nummer 3 von der ersten Aufgabe!
Hallo Nummer 3 von der zweiten Aufgabe!
Hallo Nummer 4 von der ersten Aufgabe!
Hallo Nummer 4 von der zweiten Aufgabe!
Hallo Nummer 5 von der ersten Aufgabe!
Hallo Nummer 6 von der ersten Aufgabe!
Hallo Nummer 7 von der ersten Aufgabe!
Hallo Nummer 8 von der ersten Aufgabe!
Hallo Nummer 9 von der ersten Aufgabe!
```

Hier siehst du jedes Mal genau dieselbe Reihenfolge, was sich sehr von dem
unterscheidet, was wir bei Strängen gesehen haben. Das liegt daran, dass die
Funktion `trpl::join` *fair* ist, d.h. sie prüft jedes Future gleich oft und
wechselt zwischen ihnen ab, und lässt nie eines vorauslaufen, wenn die andere
bereit ist. Bei Strängen entscheidet das Betriebssystem, welcher Strang geprüft
wird und wie lange er laufen darf. Bei asynchronem Rust entscheidet die
Laufzeitumgebung, welche Aufgabe geprüft werden soll. (In der Praxis sind die
Details komplizierter, weil eine async-Laufzeitumgebung unter der Haube
Betriebssystem-Stränge für die Verwaltung der Nebenläufigkeit verwenden könnte,
sodass das Einhalten der Fairness mehr Aufwand für eine Laufzeitumgebung sein
kann &ndach; aber es ist immer noch möglich!) Laufzeitumgebungen müssen nicht
für jede beliebige Operation Fairness garantieren, und Laufzeitumgebungen
stellen oft mehrere APIs bereit, mit denen du wählen kannst, ob du Fairness
wünschst oder nicht.

Probiere einige dieser verschiedenen Varianten des Wartens auf das Future aus
und sieh, was sie bewirken:

* Entferne den asynchronen Block um eine oder beide Schleifen.
* Warte auf jeden asynchronen Block sofort nach seiner Definition.
* Packe nur die erste Schleife in einen asynchronen Block und warte auf das 
  resultierende Future nach dem Rumpf der zweiten Schleife.

Eine zusätzliche Herausforderung ist es, herauszufinden, wie die Ausgabe in
jedem Fall aussehen wird, *bevor* du den Code ausführst!

### Übermitteln von Nachrichten

Auch die gemeinsame Nutzung von Daten zwischen Futures wird uns vertraut sein:
Wir werden wieder die Nachrichtenübermittlung verwenden, diesmal jedoch mit
asynchronen Versionen der Typen und Funktionen. Wir werden einen etwas anderen
Weg einschlagen als in Kapitel 16, um einige der wichtigsten Unterschiede
zwischen Strang-basierter und Futures-basierter Nebenläufigkeit zu
veranschaulichen. In Codeblock 17-9 beginnen wir mit einem einzigen asynchronen
Block &ndash; *ohne* eine separate Aufgabe zu erstellen, da wir einen separaten
Strang erstellt haben.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# extern crate trpl;
#
# fn main() {
#     trpl::run(async {
        let (tx, mut rx) = trpl::channel();

        let val = String::from("hi");
        tx.send(val).unwrap();

        let received = rx.recv().await.unwrap();
        println!("Got: {received}");
#     });
# }
```

<span class="caption">Codeblock 17-9: Erstellen eines asynchronen Kanals und
Zuweisen der beiden Enden an `tx` und `rx`</span>

Hier verwenden wir `trpl::channel`, eine asynchrone Version des Kanals wie in
Kapitel 16 mit Strängen. Die asynchrone Version der API unterscheidet sich nur
geringfügig von der Strang-basierten Version: Sie verwendet einen veränderbaren
statt eines unveränderbaren Empfängers `rx`, und ihre Methode `recv` erzeugt
ein Future, auf das wir warten müssen, anstatt den Wert direkt zu erzeugen.
Jetzt können wir Nachrichten vom Sender zum Empfänger senden. Beachte, dass wir
keinen separaten Strang oder gar eine Aufgabe erzeugen müssen; wir müssen
lediglich auf den Aufruf von `rx.recv` warten.

Die synchrone Methode `Receiver::recv` in `std::mpsc::channel` blockiert, bis
sie eine Nachricht erhält. Die Methode `trpl::Receiver::recv` tut dies nicht,
da sie asynchron ist. Anstatt zu blockieren, übergibt sie die Kontrolle zurück
an die Laufzeitumgebung, bis entweder eine Nachricht empfangen wird oder die
Sendeseite des Kanals geschlossen wird. Im Gegensatz dazu warten wir nicht auf
den `send`-Aufruf, weil er nicht blockiert. Das ist auch nicht nötig, denn der
Kanal, in den wir die Nachricht senden, ist unlimitiert.

> Anmerkung: Da der gesamte asynchrone Code in einem asynchronen Block in einem
> `trpl::run`-Aufruf läuft, kann alles innerhalb dieses Blocks ein Blockieren
> vermeiden. Allerdings wird der Code *außerhalb* des Blocks blockieren, wenn
> die Funktion `run` zurückkehrt. Das ist der ganze Sinn der Funktion
> `trpl::run`: Sie lässt dich *wählen*, wo du bei einem Satz von asynchronem
> Code blockieren willst, und somit wo du zwischen synchronem und asynchronem
> Code wechseln willst. In den meisten asynchronen Laufzeitumgebungen wird
> `run` aus genau diesem Grund `block_on` genannt.

Beachte bei diesem Beispiel zwei Dinge: Erstens: Die Nachricht wird sofort
ankommen! Zweitens: Obwohl wir hier ein Future verwenden, gibt es noch keine
Nebenläufigkeit. Alles im Codeblock geschieht der Reihe nach, so wie es auch
geschehen würde, wenn keine Futures beteiligt wären.

Der erste Teil besteht darin, eine Reihe von Nachrichten zu senden und
dazwischen zu schlafen, wie in Codeblock 17-10 gezeigt:

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore
# extern crate trpl;
#
# use std::time::Duration;
#
# fn main() {
#     trpl::run(async {
        let (tx, mut rx) = trpl::channel();

        let vals = vec![
            String::from("Hallo"),
            String::from("aus"),
            String::from("dem"),
            String::from("Future"),
        ];

        for val in vals {
            tx.send(val).unwrap();
            trpl::sleep(Duration::from_millis(500)).await;
        }

        while let Some(value) = rx.recv().await {
            println!("Erhalten: '{value}'");
        }
#     });
# }
```

<span class="caption">Codeblock 17-10: Senden und Empfangen mehrerer
Nachrichten über den asynchronen Kanal und Schlafen mit einem `await` zwischen
jeder Nachricht</span>

Wir müssen die Nachrichten nicht nur senden, sondern auch empfangen. In diesem
Fall könnten wir das manuell tun, indem wir einfach `rx.recv().await` viermal
ausführen, weil wir wissen, wie viele Nachrichten eingehen. In der realen Welt
werden wir jedoch im Allgemeinen auf eine *unbekannte* Anzahl von Nachrichten
warten. In diesem Fall müssen wir so lange warten, bis wir feststellen, dass es
keine weiteren Nachrichten mehr gibt.

In Codeblock 16-10 haben wir eine `for`-Schleife verwendet, um alle Elemente zu
verarbeiten, die von einem synchronen Kanal empfangen wurden. In Rust gibt es
jedoch noch keine Möglichkeit, eine `for`-Schleife über eine *asynchrone* Reihe
von Elementen zu schreiben. Stattdessen müssen wir eine neue Art von Schleife
verwenden, die wir bisher noch nicht gesehen haben, die `while let`-Schleife
mit Bedingungen. Eine `while let`-Schleife ist die Schleifenvariante des `if
 let`-Konstrukts, das wir in Kapitel 6 gesehen haben. Die Schleife wird so
lange ausgeführt, wie das angegebene Muster zum Wert passt.

Der Aufruf `rx.recv` erzeugt ein `Future`, auf das wir warten. Die
Laufzeitumgebung pausiert das `Future`, bis es bereit ist. Sobald eine
Nachricht eintrifft, wird das Future zu `Some(message)` aufgelöst, so oft wie
eine Nachricht eintrifft. Wenn der Kanal geschlossen wird, unabhängig davon, ob
*irgendwelche* Nachrichten eingetroffen sind, wird das Future stattdessen zu
`None` aufgelöst, um anzuzeigen, dass es keine weiteren Werte gibt und wir mit
dem Polling aufhören sollten, d.h. aufhören zu warten.

Die `while let`-Schleife fasst all dies zusammen. Wenn das Ergebnis des Aufrufs
von `rx.recv().await` den Wert `Some(message)` hat, erhalten wir Zugriff auf
die Nachricht und können sie im Schleifenrumpf verwenden, genauso wie wir es
mit `if let` könnten. Wenn das Ergebnis `None` ist, endet die Schleife. Jedes
Mal, wenn die Schleife beendet wird, trifft sie erneut auf den await-Punkt,
sodass die Laufzeitumgebung die Schleife erneut unterbricht, bis eine weitere
Nachricht eintrifft.

Der Code sendet und empfängt nun erfolgreich alle Nachrichten. Leider gibt es
immer noch ein paar Probleme. Zum einen kommen die Nachrichten nicht in
Abständen von einer halben Sekunde an. Sie kommen alle auf einmal an, und zwar
zwei Sekunden (2.000 Millisekunden) nach dem Start des Programms. Zum anderen
beendet sich dieses Programm nie! Stattdessen wartet es ewig auf neue
Nachrichten. Du musst es mit <span class="keystroke">Strg+c</span> beenden.

Beginnen wir damit, zu verstehen, warum die Nachrichten alle auf einmal nach
der vollen Verzögerung eintreffen, anstatt mit Verzögerungen zwischen den
einzelnen Nachrichten. Innerhalb eines bestimmten asynchronen Blocks ist die
Reihenfolge, in der die Schlüsselwörter `await` im Code erscheinen, auch die
Reihenfolge, in der sie bei der Ausführung des Programms auftreten.

In Codeblock 17-10 gibt es nur einen asynchronen Block, sodass alles darin
linear abläuft. Es gibt immer noch keine Nebenläufigkeit. Alle Aufrufe von
`tx.send` finden statt, unterbrochen von allen `trpl::sleep`-Aufrufen und
ihren zugehörigen Wartepunkten. Erst dann durchläuft die `while let`-Schleife
einen der `await` Punkte der Aufrufe von `recv`.

Um die gewünschte Verzögerung zwischen dem Empfang jeder Nachricht zu
erreichen, müssen wir die Operationen `tx` und `rx` in ihre eigenen asynchronen
Blöcke packen. Dann kann die Laufzeitumgebung jede dieser Operationen separat
mit `trpl::join` ausführen, genau wie im Zählbeispiel. Auch hier warten wir auf
das Ergebnis des Aufrufs von `trpl::join`, nicht auf die einzelnen Futures.
Würden wir auf die einzelnen Futures nacheinander warten, kämen wir wieder in
einen sequenziellen Ablauf &ndash; genau das, was wir *nicht* tun wollen.

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore
# extern crate trpl;
#
# use std::time::Duration;
#
# fn main() {
#     trpl::run(async {
#         let (tx, mut rx) = trpl::channel();
#
        let tx_fut = async {
            let vals = vec![
                String::from("Hallo"),
                String::from("aus"),
                String::from("dem"),
                String::from("Future"),
            ];

            for val in vals {
                tx.send(val).unwrap();
                trpl::sleep(Duration::from_millis(500)).await;
            }
        };

        let rx_fut = async {
            while let Some(value) = rx.recv().await {
                println!("Erhalten: '{value}'");
            }
        };

        trpl::join(tx_fut, rx_fut).await;
#     });
# }
```

<span class="caption">Codeblock 17-11: Aufteilen von `send` und `recv` in
eigene `async`-Blöcke und Warten auf die Futures für diese Blöcke</span>

Mit dem aktualisierten Code in Codeblock 17-11 werden die Nachrichten in
Abständen von 500 Millisekunden ausgegeben und nicht mehr alle auf einmal nach
zwei Sekunden.

Das Programm beendet sich aber trotzdem nicht, weil die `while let`-Schleife
mit `trpl::join` interagiert:

* Das von `trpl::join` zurückgegebene Future ist erst erledigt, wenn *beide*
  übergebene Futures erledigt sind.
* Das Future `tx` ist erledigt, sobald es die Pause nach dem Senden der letzten
  Nachricht in `vals` beendet hat.
* Das Future `rx` ist erst nach dem Ende der `while let`-Schleife erledigt.
* Die `while let`-Schleife endet erst, wenn das Ergebnis von `rx.recv` `None`
  ist.
* Das Ergebnis von `rx.recv` ist nur dann `None`, wenn das andere Ende des
  Kanals geschlossen wurde.
* Der Kanal wird nur geschlossen, wenn wir `rx.close` aufrufen oder wenn die
  Absenderseite `tx` aufgeräumt (dropped) wird.
* Wir rufen nirgendwo `rx.close` auf, und `tx` wird nicht aufgeräumt, bis der
  äußerste asynchrone Block, der an `trpl::run` übergeben wurde, endet.
* Der Block kann nicht enden, weil er auf `trpl::join` wartet, was uns wieder
  an den Anfang dieser Liste bringt!

Wir könnten `rx` manuell schließen, indem wir irgendwo `rx.close` aufrufen,
aber das macht nicht viel Sinn. Das Beenden nach der Verarbeitung einer
bestimmten Anzahl von Nachrichten würde das Programm herunterfahren, aber wir
könnten Nachrichten verpassen. Wir brauchen einen anderen Weg, um
sicherzustellen, dass `tx` *vor* dem Ende der Funktion aufgeräumt wird.

Im Moment leiht sich der async-Block, in dem wir die Nachrichten senden, nur
`tx` aus, weil das Senden einer Nachricht keine Eigentümerschaft erfordert.
Wenn wir `tx` aber in den async-Block verschieben könnten, würde es aufgeräumt
werden, sobald der Block endet. In Kapitel 13 haben wir gelernt, wie man das
Schlüsselwort `move` mit Funktionsabschlüssen verwendet, und in Kapitel 16
haben wir gesehen, dass wir oft Daten in Funktionsabschlüsse verschieben
müssen, wenn wir mit Strängen arbeiten. Für asynchrone Blöcke gilt dieselbe
grundlegende Dynamik, sodass das Schlüsselwort `move` mit asynchronen Blöcken
genauso funktioniert wie mit Funktionsabschlüssen.

In Codeblock 17-12 ändern wir den asynchronen Block zum Senden von Nachrichten
von einem einfachen `async`-Block in einen `async move`-Block. Wenn wir *diese*
Version des Codes ausführen, beendet er sich ordnungsgemäß, nachdem die letzte
Nachricht gesendet und empfangen wurde.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# extern crate trpl;
#
# use std::time::Duration;
#
# fn main() {
#     trpl::run(async {
        let (tx, mut rx) = trpl::channel();

        let tx_fut = async move {
            let vals = vec![
                String::from("Hallo"),
                String::from("aus"),
                String::from("dem"),
                String::from("Future"),
            ];

            for val in vals {
                tx.send(val).unwrap();
                trpl::sleep(Duration::from_millis(500)).await;
            }
        };

        let rx_fut = async {
            while let Some(value) = rx.recv().await {
                eprintln!("Erhalten: '{value}'");
            }
        };

        trpl::join(tx_fut, rx_fut).await;
#     });
# }
```

<span class="caption">Codeblock 17-12: Ein funktionierendes Beispiel für das
Senden und Empfangen von Nachrichten zwischen Futures, das sich am Ende
ordnungsgemäß beendet</span>

Dieser asynchrone Kanal ist auch ein Kanal für mehrere Erzeuger, sodass wir
`clone` auf `tx` aufrufen können, wenn wir Nachrichten von mehreren Futures
senden wollen. In Codeblock 17-13 klonen wir `tx` und erstellen `tx1` außerhalb
des ersten asynchronen Blocks. Wir verschieben `tx1` in diesen Block, genau wie
wir es zuvor mit `tx` gemacht haben. Dann verschieben wir das ursprüngliche
`tx` in einen *neuen* asynchronen Block, wo wir mehr Nachrichten mit einer
etwas langsameren Verzögerung senden. Wir setzen diesen neuen asynchronen Block
nach dem asynchronen Block für den Empfang von Nachrichten, aber er könnte
genauso gut vor ihm stehen. Der Schlüssel ist die Reihenfolge, in der auf die
Futures gewartet wird, nicht die Reihenfolge, in der sie erstellt werden.

Die beiden asynchronen Blöcke zum Senden von Nachrichten müssen `async
 move`-Blöcke sein, sodass sowohl `tx` als auch `tx1` aufgeräumt werden, wenn
diese Blöcke zu Ende sind. Sonst landen wir wieder in der gleichen
Endlosschleife, in der wir angefangen haben. Schließlich wechseln wir von
`trpl::join` zu `trpl::join3`, um das zusätzliche Future zu behandeln.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# extern crate trpl;
#
# use std::time::Duration;
#
# fn main() {
#     trpl::run(async {
        let (tx, mut rx) = trpl::channel();

        let tx1 = tx.clone();
        let tx1_fut = async move {
            let vals = vec![
                String::from("Hallo"),
                String::from("aus"),
                String::from("dem"),
                String::from("Future"),
            ];

            for val in vals {
                tx1.send(val).unwrap();
                trpl::sleep(Duration::from_millis(500)).await;
            }
        };

        let rx_fut = async {
            while let Some(value) = rx.recv().await {
                println!("Erhalten: '{value}'");
            }
        };

        let tx_fut = async move {
            let vals = vec![
                String::from("Weitere"),
                String::from("Nachrichten"),
                String::from("für"),
                String::from("dich"),
            ];

            for val in vals {
                tx.send(val).unwrap();
                trpl::sleep(Duration::from_millis(1500)).await;
            }
        };

        trpl::join3(tx1_fut, tx_fut, rx_fut).await;
#     });
# }
```

<span class="caption">Codeblock 17-13: Verwenden mehrerer Produzenten mit
asynchronen Blöcken</span>

Jetzt sehen wir alle Nachrichten der beiden sendenden Futures. Da die sendenden
Futures leicht unterschiedliche Verzögerungen nach dem Senden verwenden, werden
die Nachrichten auch in diesen unterschiedlichen Intervallen empfangen.

```text
Erhalten: 'Hallo'
Erhalten: 'Weitere'
Erhalten: 'aus'
Erhalten: 'dem'
Erhalten: 'Nachrichten'
Erhalten: 'Future'
Erhalten: 'für'
Erhalten: 'dich'
```

Das ist ein guter Anfang, aber es beschränkt uns auf eine Handvoll Futures:
Zwei mit `join`, oder drei mit `join3`. Schauen wir uns an, wie wir mit mehr
Futures arbeiten können.
