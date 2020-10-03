## Nachrichtenaustausch zwischen Strängen (threads)

Ein immer beliebter werdender Ansatz zur Gewährleistung einer sicheren
Nebenläufigkeit (safe concurrency) ist der *Nachrichtenaustausch* (message
passing), bei dem Stränge oder Akteure kommunizieren, indem sie sich
gegenseitig Nachrichten mit Daten senden. Hier ist die Idee in einem Slogan aus
[der Go-Sprachdokumentation][go-lang]: „Kommuniziere nicht, indem du
Arbeitsspeicher teilst; teile stattdessen Arbeitsspeicher durch Kommunikation.“

Ein Hauptwerkzeug von Rust zum Erreichen von nachrichtenübermittelnder
Nebenläufigkeit ist der *Kanal* (channel), ein Programmierkonzept, das in der
Standardbibliothek von Rust implementiert ist. Man kann sich einen Kanal in der
Programmierung wie einen Wasserkanal vorstellen, wie einen Bach oder einen
Fluss. Wenn du etwas wie eine Gummiente oder ein Boot in einen Fluss setzt,
wird sie/es flussabwärts bis zum Ende des Wasserwegs reisen.

Ein Kanal in der Programmierung hat zwei Hälften: Einen Sender und einen
Empfänger. Die Senderhälfte ist die stromaufwärts gelegene Stelle, an der du
Gummienten in den Fluss setzt, und die Empfängerhälfte ist die Stelle, an der
die Gummiente stromabwärts ankommt. Ein Teil deines Codes ruft Methoden auf dem
Sender mit den Daten auf, die du senden möchtest, und ein anderer Teil
überprüft die Empfangsseite auf ankommende Nachrichten. Ein Kanal gilt als
*geschlossen* (closed), wenn entweder die Sender- oder die Empfängerhälfte
aufgeräumt (dropped) wird.

Hier arbeiten wir uns zu einem Programm hoch, das einen Strang hat, um Werte zu
generieren und sie über einen Kanal zu senden, und einen anderen Strang, der
die Werte empfängt und ausgibt. Wir werden einfache Werte zwischen den Strängen
über einen Kanal senden, um die Funktionalität zu veranschaulichen. Sobald du
mit der Technik vertraut bist, kannst du Kanäle verwenden, um ein Chatsystem zu
implementieren oder ein System, bei dem viele Stränge Teile einer Berechnung
durchführen und die Teile an einen Strang senden, der die Ergebnisse
zusammenfasst.

Erstens werden wir in Codeblock 16-6 einen Kanal erstellen, aber nichts damit
machen. Beachte, dass sich dieser noch nicht kompilieren lässt, weil Rust nicht
sagen kann, welchen Typ von Werten wir über den Kanal senden wollen.

<span class="filename">Dateiname: src/main.rs</span>

```rust,does_not_compile
use std::sync::mpsc;

fn main() {
    let (tx, rx) = mpsc::channel();
}
```

<span class="caption">Codeblock 16-6: Erstellen eines Kanals und Zuweisen der
beiden Hälften zu `tx` und `rx`</span>

Wir erstellen einen neuen Kanal mit der Funktion `mpsc::channel`; `mpsc` steht
für *mehrfacher Produzent, einzelner Konsument* (multiple producer, single
consumer). Kurz gesagt, die Art und Weise, wie die Standardbibliothek von Rust
Kanäle implementiert, bedeutet, dass ein Kanal mehrere *sendende* Enden haben
kann, die Werte produzieren, aber nur ein *empfangendes* Ende, das diese Werte
konsumiert. Stell dir vor, mehrere Bäche würden zu einem großen Fluss
zusammenfließen: Alles, was in einem der Bäche hinuntergeschickt wird, landet
am Ende in einem Fluss. Wir fangen zunächst mit einem einzigen Produzenten an,
aber wir fügen mehrere Produzenten hinzu, wenn dieses Beispiel funktioniert.

Die Funktion `mpsc::channel` gibt ein Tupel zurück, dessen erstes Element die
sendende Seite und dessen zweites Element die empfangende Seite ist. Die
Abkürzungen `tx` und `rx` werden traditionell in vielen Feldern für *Sender*
(transmitter) bzw. *Empfänger* (receiver) verwendet, daher benennen wir unsere
Variablen als solche, um jedes Ende anzugeben. Wir verwenden eine
`let`-Anweisung mit einem Muster, das die Tupel destrukturiert; wir werden die
Verwendung von Mustern in `let`-Anweisungen und die Destrukturierung in Kapitel
18 besprechen. Das Verwenden einer `let`-Anweisung auf diese Weise ist ein
bequemer Ansatz, um die Teile des Tupels zu extrahieren, die von
`mpsc::channel` zurückgegeben werden.

Verschieben wir das sendende Ende in einen erzeugten Strang und lassen es eine
Zeichenkette senden, sodass der erzeugte Strang mit dem Hauptstrang
kommuniziert, wie in Codeblock 16-7 gezeigt. Das ist so, als würde man eine
Gummiente flussaufwärts in den Fluss setzen oder eine Chat-Nachricht von einem
Strang zum anderen senden.

<span class="filename">Dateiname: src/main.rs</span>

```rust
use std::sync::mpsc;
use std::thread;

fn main() {
    let (tx, rx) = mpsc::channel();

    thread::spawn(move || {
        let val = String::from("hallo");
        tx.send(val).unwrap();
    });
}
```

<span class="caption">Codeblock 16-7: Verschieben von `tx` in einen erzeugten
Strang und Senden von „hallo“</span>

Wieder verwenden wir `thread::spawn`, um einen neuen Strang zu erstellen, und
dann `move`, um `tx` in den Funktionsabschluss zu verschieben, sodass der
erzeugte Strang `tx` besitzt. Der erzeugte Strang muss das sendende Ende des
Kanals besitzen, um in der Lage zu sein, Nachrichten durch den Kanal zu senden.

Auf der Sendeseite gibt es eine Methode `send`, die den Wert nimmt, den wir
senden wollen. Die Methode `send` gibt ein `Result<T, E>` zurück; wenn also die
empfangende Seite bereits aufgeräumt wurde und es keinen Ort gibt, an den ein
Wert gesendet werden kann, wird die Sendeoperation einen Fehler zurückgeben. In
diesem Beispiel rufen wir `unwrap` auf, um im Falle eines Fehlers abzustürzen.
Aber in einer echten Anwendung würden wir es richtig handhaben: Kehre zu
Kapitel 9 zurück, um Strategien für eine korrekte Fehlerbehandlung anzusehen.

In Codeblock 16-8 erhalten wir den Wert vom empfangenden Ende des Kanals im
Hauptstrang. Das ist so, als würde man die Gummiente am Ende des Flusses aus
dem Wasser holen oder eine Chat-Nachricht erhalten.

<span class="filename">Dateiname: src/main.rs</span>

```rust
use std::sync::mpsc;
use std::thread;

fn main() {
    let (tx, rx) = mpsc::channel();

    thread::spawn(move || {
        let val = String::from("hallo");
        tx.send(val).unwrap();
    });

    let received = rx.recv().unwrap();
    println!("Erhalten: {}", received);
}
```

<span class="caption">Codeblock 16-8: Empfangen des Wertes „hallo“ im
Hauptstrang und Ausgeben des Wertes</span>

Das empfangende Ende eines Kanals hat zwei nützliche Methoden: `recv` und
`try_recv`. Wir benutzen `recv`, kurz für *empfangen* (receive), was die
Ausführung des Hauptstrangs blockiert und wartet, bis ein Wert in den Kanal
geschickt wird. Sobald ein Wert gesendet wurde, wird er von `recv` in einem
`Result<T, E>` zurückgegeben. Wenn das Sendeende des Kanals geschlossen wird,
gibt `recv` einen Fehler zurück, um zu signalisieren, dass keine weiteren Werte
mehr kommen werden.

Die Methode `try_recv` blockiert nicht, sondern gibt stattdessen sofort ein
`Result<T, E>` zurück: Einen `Ok`-Wert, der eine Nachricht enthält, wenn eine
verfügbar ist, und einen `Err`-Wert, wenn diesmal keine Nachricht vorhanden
ist. Die Verwendung von `try_recv` ist nützlich, wenn dieser Strang während des
Wartens auf Nachrichten andere Arbeiten zu erledigen hat: Wir könnten eine
Schleife schreiben, die `try_recv` ab und zu aufruft, eine Nachricht
verarbeitet, wenn eine verfügbar ist, und ansonsten für eine Weile andere
Arbeiten erledigt, bis sie erneut überprüft wird.

Wir haben in diesem Beispiel der Einfachheit halber `recv` verwendet; wir haben
keine andere Arbeit für den Hauptstrang zu erledigen, außer auf Nachrichten zu
warten, daher ist es angebracht, den Hauptstrang zu blockieren.

Wenn wir den Code in Codeblock 16-8 ausführen, sehen wir den durch den
Hauptstrang ausgegebenen Wert:

```text
Erhalten: hallo
```

Perfekt!

### Kanäle und Eigentümerschaftsübertragung

Die Eigentumsregeln spielen beim Nachrichtenversand eine entscheidende Rolle,
da sie dir helfen, sicheren, nebenläufigen Code zu schreiben. Die Vermeidung
von Fehlern bei der nebenläufigen Programmierung ist der Vorteil, wenn du bei
deinen Rust-Programmen an die Eigentümerschaft denkst. Lass uns ein Experiment
machen, um zu zeigen, wie Kanäle und Eigentümerschaft zusammenwirken, um
Probleme zu vermeiden: Wir versuchen, einen `val`-Wert im erzeugten Strang zu
verwenden, *nachdem* wir ihn in den Kanal geschickt haben. Versuche, den Code
in Codeblock 16-9 zu kompilieren, um zu sehen, warum dieser Code nicht erlaubt
ist:

<span class="filename">Dateiname: src/main.rs</span>

```rust,does_not_compile
use std::sync::mpsc;
use std::thread;

fn main() {
    let (tx, rx) = mpsc::channel();

    thread::spawn(move || {
        let val = String::from("hallo");
        tx.send(val).unwrap();
        println!("val ist {}", val);
    });

    let received = rx.recv().unwrap();
    println!("Erhalten: {}", received);
}
```

<span class="caption">Codeblock 16-9: Versuch, `val` zu benutzen, nachdem wir
es in den Kanal geschickt haben</span>

Hier versuchen wir, `val` auszugeben, nachdem wir es per `tx.send` in den Kanal
geschickt haben. Dies zuzulassen wäre eine schlechte Idee: Sobald der Wert an
einen anderen Strang gesendet wurde, könnte dieser Strang ihn ändern oder
aufräumen, bevor wir versuchen, den Wert erneut zu verwenden. Möglicherweise
können die Änderungen des anderen Strangs aufgrund inkonsistenter oder nicht
vorhandener Daten zu Fehlern oder unerwarteten Ergebnissen führen. Rust gibt
uns jedoch einen Fehler, wenn wir versuchen, den Code in Codeblock 16-9 zu kompilieren:

```console
$ cargo run
   Compiling message-passing v0.1.0 (file:///projects/message-passing)
error[E0382]: borrow of moved value: `val`
  --> src/main.rs:10:31
   |
8  |         let val = String::from("hallo");
   |             --- move occurs because `val` has type `std::string::String`, which does not implement the `Copy` trait
9  |         tx.send(val).unwrap();
   |                 --- value moved here
10 |         println!("val ist {}", val);
   |                                ^^^ value borrowed here after move

error: aborting due to previous error

For more information about this error, try `rustc --explain E0382`.
error: could not compile `message-passing`.

To learn more, run the command again with --verbose.
```

Unser Nebenläufigkeitsfehler hat einen Kompilierzeitfehler verursacht. Die
Funktion `send` übernimmt die Eigentümerschaft an ihrem Parameter und wenn der
Wert verschoben wird, übernimmt der Empfänger die Eigentümerschaft an ihm.
Dadurch wird verhindert, dass wir den Wert nach dem Senden versehentlich wieder
verwenden; das Eigentumssystem prüft, ob alles in Ordnung ist.

### Mehrere Werte senden und den Empfänger warten sehen

Der Code in Codeblock 16-8 wurde kompiliert und ausgeführt, aber er zeigte uns
nicht eindeutig, dass zwei getrennte Stränge über den Kanal miteinander
sprachen. In Codeblock 16-10 haben wir einige Änderungen vorgenommen, die
beweisen, dass der Code in Codeblock 16-8 nebenläufig ausgeführt wird: Der
erzeugte Strang sendet nun mehrere Nachrichten und macht dazwischen eine Pause
von einer Sekunde.

<span class="filename">Dateiname: src/main.rs</span>

```rust
use std::sync::mpsc;
use std::thread;
use std::time::Duration;

fn main() {
    let (tx, rx) = mpsc::channel();

    thread::spawn(move || {
        let vals = vec![
            String::from("hallo"),
            String::from("aus"),
            String::from("dem"),
            String::from("Strang"),
        ];

        for val in vals {
            tx.send(val).unwrap();
            thread::sleep(Duration::from_secs(1));
        }
    });

    for received in rx {
        println!("Erhalten: {}", received);
    }
}
```

<span class="caption">Codeblock 16-10: Senden mehrerer Nachrichten und
Pausieren dazwischen</span>

Diesmal hat der erzeugte Strang einen Vektor von Zeichenketten, die wir an den
Hauptstrang senden wollen. Wir iterieren über diese Zeichenketten, senden jede
einzeln und pausieren dazwischen, indem wir die Funktion `thread::sleep` mit
einem `Duration`-Wert von 1 Sekunde aufrufen.

Im Hauptstrang rufen wir die Funktion `recv` nicht mehr explizit auf:
Stattdessen behandeln wir `rx` als Iterator. Jeden empfangenen Wert geben wir
aus. Wenn der Kanal geschlossen wird, wird die Iteration beendet.

Wenn du den Code in Codeblock 16-10 ausführst, solltest du die folgende Ausgabe
mit einer 1-Sekunden-Pause zwischen jeder Zeile sehen:

```text
Erhalten: hallo
Erhalten: aus
Erhalten: dem
Erhalten: Strang
```

Da wir keinen Code haben, der die `for`-Schleife im Hauptstrang pausiert oder
verzögert, können wir sagen, dass der Hauptstrang darauf wartet, Werte vom
erzeugten Strang zu erhalten.

### Erstellen mehrerer Produzenten durch Klonen des Senders

Vorhin haben wir erwähnt, dass `mpsc` ein Akronym für *mehrfacher Produzent,
einzelner Konsument* ist. Lass uns `mpsc` verwenden und den Code in Codeblock
16-10 erweitern, um mehrere Stränge zu erzeugen, die alle Werte an den gleichen
Empfänger senden. Wir können dies tun, indem wir die sendende Hälfte des Kanals
klonen, wie in Codeblock 16-11 gezeigt:

<span class="filename">Dateiname: src/main.rs</span>

```rust
# use std::sync::mpsc;
# use std::thread;
# use std::time::Duration;
#
# fn main() {
    // --abschneiden--

    let (tx, rx) = mpsc::channel();

    let tx1 = mpsc::Sender::clone(&tx);
    thread::spawn(move || {
        let vals = vec![
            String::from("hallo"),
            String::from("aus"),
            String::from("dem"),
            String::from("Strang"),
        ];

        for val in vals {
            tx1.send(val).unwrap();
            thread::sleep(Duration::from_secs(1));
        }
    });

    thread::spawn(move || {
        let vals = vec![
            String::from("mehr"),
            String::from("Nachrichten"),
            String::from("für"),
            String::from("dich"),
        ];

        for val in vals {
            tx.send(val).unwrap();
            thread::sleep(Duration::from_secs(1));
        }
    });

    for received in rx {
        println!("Erhalten: {}", received);
    }

    // --abschneiden--
# }
```

<span class="caption">Codeblock 16-11: Senden mehrerer Nachrichten von mehreren
Produzenten</span>

Bevor wir den ersten Strang erzeugen, rufen wir dieses Mal `clone` auf dem
sendenden Ende des Kanals auf. Dadurch erhalten wir ein weiteres sendendes
Ende, das wir an den ersten erzeugten Strang weitergeben können. Wir übergeben
das ursprüngliche sendende Ende des Kanals an einen zweiten erzeugten Strang.
Dadurch erhalten wir zwei Stränge, die jeweils unterschiedliche Nachrichten an
das empfangende Ende des Kanals senden.

Wenn du den Code ausführst, sollte deine Ausgabe in etwa so aussehen:

```text
Erhalten: hallo
Erhalten: mehr
Erhalten: aus
Erhalten: Nachrichten
Erhalten: für
Erhalten: dem
Erhalten: Strang
Erhalten: dich
```

Möglicherweise siehst du die Werte in einer anderen Reihenfolge; dies hängt von
deinem System ab. Das macht die Nebenläufigkeit sowohl interessant als auch
schwierig. Wenn du mit `thread::sleep` experimentierst und ihm verschiedene
Werte in den verschiedenen Strängen gibst, wird jeder Durchlauf
nicht-deterministischer sein und jedes Mal eine andere Ausgabe erzeugen.

Nachdem wir uns nun angesehen haben, wie Kanäle funktionieren, wollen wir uns
eine andere Methode der Nebenläufigkeit ansehen.

[go-lang]: https://golang.org/doc/effective_go.html#concurrency
