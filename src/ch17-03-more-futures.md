### Abgeben (yielding) der Kontrolle an die Laufzeitumgebung

Erinnere dich an den Abschnitt [„Unser erstes asynchrones
Programm“][async-program], bei dem Rust der Laufzeitumgebung an jedem
await-Punkt die Möglichkeit gibt, die Aufgabe anzuhalten und zu einer anderen
zu wechseln, wenn das zu erwartende Future nicht fertig ist. Der umgekehrte
Fall gilt ebenfalls: Rust hält asynchrone Blöcke _nur_ an einem await-Punkt an
und übergibt die Kontrolle der Laufzeitumgebung. Alles zwischen den
await-Punkten ist synchron.

Das heißt, wenn du eine Menge Arbeit in einem asynchronen Block ohne einen
await-Punkt erledigst, blockiert dieses Future alle anderen Futures an ihrem
Fortschritt. Dies wird manchmal auch als „ein Future lässt ein anderes Future
verhungern“ bezeichnet. In manchen Fällen mag das keine große Sache sein. Wenn
du jedoch eine teure Initialisierung oder eine langwierige Arbeit durchführst
oder wenn du ein Future hast, das eine bestimmte Aufgabe auf unbestimmte Zeit
ausführt, musst du darüber nachdenken, wann und wo du die Kontrolle an die
Laufzeitumgebung abgibst.

Simulieren wir einen lang andauernden Vorgang, um das Problem des Verhungerns
(starvation) zu veranschaulichen, und untersuchen wir anschließend, wie es
gelöst werden kann. Codeblock 17-14 führt eine Funktion `slow` ein.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# extern crate trpl;
#
# use std::{thread, time::Duration};
#
# fn main() {
#     trpl::block_on(async {
#         // Wir werden hier `slow` aufrufen
#     });
# }
#
fn slow(name: &str, ms: u64) {
    thread::sleep(Duration::from_millis(ms));
    println!("'{name}' ist für {ms} ms gelaufen");
}
```

<span class="caption">Codeblock 17-14: Verwenden von `thread::sleep` zum
Simulieren langsamer Abläufe</span>

Dieser Code verwendet `std::thread::sleep` anstelle von `trpl::sleep`, sodass
der Aufruf von `slow` den aktuellen Strang für eine bestimmte Anzahl von
Millisekunden blockiert. Wir können `slow` benutzen, um reale Abläufe zu
simulieren, die sowohl langwierig als auch blockierend sind.

In Codeblock 17-15 verwenden wir `slow`, um diese Art von CPU-gebundener Arbeit
in einem Paar von Futures zu emulieren.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# extern crate trpl;
#
# use std::{thread, time::Duration};
#
# fn main() {
#     trpl::block_on(async {
        let a = async {
            println!("'a' gestartet.");
            slow("a", 30);
            slow("a", 10);
            slow("a", 20);
            trpl::sleep(Duration::from_millis(50)).await;
            println!("'a' beendet.");
        };

        let b = async {
            println!("'b' gestartet.");
            slow("b", 75);
            slow("b", 10);
            slow("b", 15);
            slow("b", 350);
            trpl::sleep(Duration::from_millis(50)).await;
            println!("'b' beendet.");
        };

        trpl::race(a, b).await;
#     });
# }
#
# fn slow(name: &str, ms: u64) {
#     thread::sleep(Duration::from_millis(ms));
#     println!("'{name}' ist für {ms} ms gelaufen");
# }
```

<span class="caption">Codeblock 17-15: Aufrufen der Funktion `slow` zum
Simulieren langsamer Abläufe</span>

Zunächst gibt jedes Future die Kontrolle erst nach einer Reihe von langsamen
Abläufen an die Laufzeitumgebung zurück. Wenn du diesen Code ausführst,
erhältst du diese Ausgabe:

```text
'a' gestartet.
'a' ist für 30 ms gelaufen
'a' ist für 10 ms gelaufen
'a' ist für 20 ms gelaufen
'b' gestartet.
'b' ist für 75 ms gelaufen
'b' ist für 10 ms gelaufen
'b' ist für 15 ms gelaufen
'b' ist für 350 ms gelaufen
'a' beendet.
```
Wie in Codeblock 17-5, wo wir `trpl::select` verwendet haben, um Futures beim
Abrufen von zwei URLs gegeneinander antreten zu lassen, wird `select` immer
noch beendet, sobald `a` fertig ist. Es gibt jedoch keine Abwechslung zwischen
den Aufrufen von `slow` in den beiden Futures. Das Future `a` erledigt seine
gesamte Arbeit, bis auf den Aufruf von `trpl::sleep` gewartet wird, dann
erledigt das Future `b` seine gesamte Arbeit, bis auch dort auf den Aufruf von
`trpl::sleep` gewartet wird, und schließlich wird das Future `a` beendet. Damit
beide Futures während ihrer langsamen Vorgänge Fortschritte machen können,
brauchen wir await-Punkte, damit wir die Kontrolle an die Laufzeitumgebung
abgeben können. Das heißt, wir brauchen etwas, auf das wir warten können!

Wir können diese Art der Übergabe bereits in Codeblock 17-15 sehen: Wenn wir
`trpl::sleep` am Ende des Futures `a` entfernen, würde es fertig werden, ohne
dass das Future `b` _überhaupt_ läuft. Versuchen wir, die Funktion
`trpl::sleep` als Ausgangspunkt zu verwenden, um Operationen am Fortschritt zu
hindern, wie in Codeblock 17-16 gezeigt.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# extern crate trpl;
#
# use std::{thread, time::Duration};
#
# fn main() {
#     trpl::block_on(async {
        let one_ms = Duration::from_millis(1);

        let a = async {
            println!("'a' gestartet.");
            slow("a", 30);
            trpl::sleep(one_ms).await;
            slow("a", 10);
            trpl::sleep(one_ms).await;
            slow("a", 20);
            trpl::sleep(one_ms).await;
            println!("'a' beendet.");
        };

        let b = async {
            println!("'b' gestartet.");
            slow("b", 75);
            trpl::sleep(one_ms).await;
            slow("b", 10);
            trpl::sleep(one_ms).await;
            slow("b", 15);
            trpl::sleep(one_ms).await;
            slow("b", 35);
            trpl::sleep(one_ms).await;
            println!("'b' beendet.");
        };
#
#         trpl::race(a, b).await;
#     });
# }
#
# fn slow(name: &str, ms: u64) {
#     thread::sleep(Duration::from_millis(ms));
#     println!("'{name}' ist für {ms} ms gelaufen");
# }
```

<span class="caption">Codeblock 17-16: Verwenden von `sleep`, um Vorgänge zu
unterbrechen</span>

Wir haben Aufrufe von `trpl::sleep` mit await-Punkten zwischen den Aufrufen von
`slow` eingefügt. Nun wechseln die beiden Futures ihre Arbeit ab:

```text
'a' gestartet.
'a' ist für 30 ms gelaufen
'b' gestartet.
'b' ist für 75 ms gelaufen
'a' ist für 10 ms gelaufen
'b' ist für 10 ms gelaufen
'a' ist für 20 ms gelaufen
'b' ist für 15 ms gelaufen
'a' beendet.
```

Das Future `a` läuft noch eine Weile, bevor es die Kontrolle an `b` abgibt,
weil es `slow` aufruft, bevor es `trpl::sleep` aufruft. Aber danach wechseln
sich die Futures jedes Mal ab, wenn eines von ihnen einen await-Punkt erreicht.
In diesem Fall haben wir das nach jedem Aufruf von `slow` gemacht, aber wir
könnten die Arbeit so aufteilen, wie es für uns am sinnvollsten ist.

Wir wollen hier aber nicht wirklich _schlafen_: Wir wollen so schnell wie
möglich vorankommen. Wir müssen nur die Kontrolle an die Laufzeitumgebung
abgeben. Das können wir direkt tun, indem wir die Funktion `trpl::yield_now`
verwenden. In Codeblock 17-17 ersetzen wir all diese Aufrufe von `trpl::sleep`
durch `trpl::yield_now`.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# extern crate trpl;
#
# use std::{thread, time::Duration};
#
# fn main() {
#     trpl::block_on(async {
        let a = async {
            println!("'a' gestartet.");
            slow("a", 30);
            trpl::yield_now().await;
            slow("a", 10);
            trpl::yield_now().await;
            slow("a", 20);
            trpl::yield_now().await;
            println!("'a' beendet.");
        };

        let b = async {
            println!("'b' gestartet.");
            slow("b", 75);
            trpl::yield_now().await;
            slow("b", 10);
            trpl::yield_now().await;
            slow("b", 15);
            trpl::yield_now().await;
            slow("b", 35);
            trpl::yield_now().await;
            println!("'b' beendet.");
        };
#
#         trpl::race(a, b).await;
#     });
# }
#
# # fn slow(name: &str, ms: u64) {
#     thread::sleep(Duration::from_millis(ms));
#     println!("'{name}' ist für {ms} ms gelaufen");
# }
```

<span class="caption">Codeblock 17-17: Verwenden von `yield_now`, um Vorgänge
anzuhalten</span>

Dieser Code ist sowohl klarer als auch wesentlich schneller als `sleep`, weil
Zeitgeber wie `sleep` oft Grenzen haben, wie granular sie sein können. Die
Version von `sleep`, die wir benutzen, wird zum Beispiel immer mindestens eine
Millisekunde lang schlafen, selbst wenn wir ihr eine `Duration` von einer
Nanosekunde übergeben. Nochmals, moderne Computer sind _schnell_: Sie können
eine Menge in einer Millisekunde tun!

Das bedeutet, dass async sogar für rechengebundene Aufgaben nützlich sein kann,
je nachdem, was dein Programm sonst noch tut, weil es ein nützliches Werkzeug
für die Strukturierung der Beziehungen zwischen verschiedenen Teilen des
Programms ist (jedoch mit Overhead der asynchronen Zustandsmaschine). Es
handelt sich um eine Form von _kooperativem Multitasking_, bei dem jedes Future
die Möglichkeit hat zu bestimmen, wann es die Kontrolle mittels await-Punkte
abgibt. Jedes Future hat daher auch die Verantwortung, ein zu langes Blockieren
zu vermeiden. In einigen Rust-basierten, eingebetteten Betriebssystemen ist
dies die _einzige_ Art von Multitasking!

In der Praxis wirst du natürlich nicht nach jeder einzelnen Zeile
einen await-Punkt einfügen. Obwohl die Abgabe der Kontrolle auf diese Weise
relativ kostengünstig ist, ist sie nicht kostenlos! In vielen Fällen kann der
Versuch, eine rechengebundene Aufgabe zu unterbrechen, sie erheblich langsamer
machen, sodass es manchmal für die _gesamte_ Performanz besser ist, eine
Operation kurzzeitig zu blockieren. Du solltest immer messen, um die
tatsächlichen Leistungsengpässe deines Codes zu finden. Die zugrundeliegende
Dynamik solltest du immer im Hinterkopf haben, wenn du feststellst, dass viele
Vorgänge seriell ausgeführt werden, von denen du erwartet hast, dass sie
nebenläufig ausgeführt werden!

### Eigene Async-Abstraktionen erstellen

Wir können Futures auch kombinieren, um neue Muster zu schaffen. Zum Beispiel
können wir eine Funktion `timeout` mit bereits vorhandenen asynchronen
Bausteinen erstellen. Wenn wir fertig sind, ist das Ergebnis ein weiterer
Baustein, mit dem wir weitere asynchrone Abstraktionen erstellen können.

Codeblock 17-18 zeigt die erwartete Arbeitsweise von `timeout` bei einem
langsamen Future.

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore,does_not_compile
# extern crate trpl;
#
# use std::time::Duration;
#
# fn main() {
#     trpl::block_on(async {
        let slow = async {
            trpl::sleep(Duration::from_millis(100)).await;
            "Bin fertig!"
        };

        match timeout(slow, Duration::from_millis(10)).await {
            Ok(message) => println!("Erfolgreich mit '{message}'"),
            Err(duration) => {
                println!("Fehlgeschlagen nach {} Sekunden", duration.as_secs())
            }
        }
#     });
# }
```

<span class="caption">Codeblock 17-18: Verwendeng unseres imaginären `timeout`,
um eine langsame Operation mit einem Zeitlimit durchzuführen</span>

Lass es uns implementieren! Denken wir zunächst über die API für `timeout`
nach:

- Sie muss selbst eine asynchrone Funktion sein, damit wir auf sie warten
  können.
- Ihr erster Parameter sollte ein ausführbares Future sein. Wir können sie
  generisch machen, damit sie mit jedem Future funktioniert.
- Der zweite Parameter ist die maximale Wartezeit. Wenn wir eine `Duration`
  verwenden, wird es einfach sein, ihn an `trpl::sleep` weiterzureichen.
- Es sollte ein `Result` zurückgeben. Wenn das Future erfolgreich beendet wird,
  ist das `Result` ein `Ok` mit dem vom Future erzeugten Wert. Wenn das
  Zeitlimit zuerst erreicht wird, wird `Result` ein `Err` mit der Wartedauer
  sein.

Codeblock 17-19 zeigt diese Deklaration.

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore,does_not_compile
# extern crate trpl;
#
# use std::{future::Future, time::Duration};
#
# fn main() {
#     trpl::block_on(async {
#         let slow = async {
#             trpl::sleep(Duration::from_secs(5)).await;
#             "Bin fertig"
#         };
#
#         match timeout(slow, Duration::from_millis(10)).await {
#             Ok(message) => println!("Erfolgreich mit '{message}'"),
#             Err(duration) => {
#                 println!("Fehlgeschlagen nach {} Sekunden", duration.as_secs())
#             }
#         }
#     });
# }
#
async fn timeout<F: Future>(
    future_to_try: F,
    max_time: Duration,
) -> Result<F::Output, Duration> {
    // Hier kommt die Implementierung hin
}
```

<span class="caption">Codeblock 17-19: Definieren der Signatur von
`timeout`</span>

Damit sind unsere Ziele für die Typen erfüllt. Denken wir nun über das
_Verhalten_ nach, das wir brauchen: Wir wollen die Dauer des übergebenen Future
überwachen. Wir können mit `trpl::sleep` einen Timer aus der Dauer machen und
`trpl::select` verwenden, um mit diesem Timer das übergebene Future zu
überwachen.

In Codeblock 17-20 implementieren wir `timeout`, indem wir das Ergebnis von
`trpl::select` abgleichen.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# extern crate trpl;
#
# use std::{future::Future, time::Duration};
#
use trpl::Either;

// --abschneiden--
#
# fn main() {
#     trpl::block_on(async {
#         let slow = async {
#             trpl::sleep(Duration::from_secs(5)).await;
#             "Bin fertig"
#         };
#
#         match timeout(slow, Duration::from_secs(2)).await {
#             Ok(message) => println!("Erfolgreich mit '{message}'"),
#             Err(duration) => {
#                 println!("Fehlgeschlagen nach {} Sekunden", duration.as_secs())
#             }
#         }
#     });
# }

async fn timeout<F: Future>(
    future_to_try: F,
    max_time: Duration,
) -> Result<F::Output, Duration> {
    match trpl::race(future_to_try, trpl::sleep(max_time)).await {
        Either::Left(output) => Ok(output),
        Either::Right(_) => Err(max_time),
    }
# }
```

<span class="caption">Codeblock 17-20: Definieren von `timeout` mit `select` und
`sleep`</span>

Die Implementierung von `trpl::select` ist nicht fair: Sie fragt die Argumente
immer in der Reihenfolge ab, in der sie übergeben werden (andere
Implementierungen von `select` wählen zufällig aus, welches Argument zuerst
abgefragt wird). Daher übergeben wir `future_to_try` zuerst an `select`, damit
es auch dann eine Chance hat, abgeschlossen zu werden, wenn `max_time` eine
sehr kurze Dauer hat. Wenn `future_to_try` zuerst fertig ist, gibt `select`
`Left` mit der Ausgabe von `future_to_try` zurück. Wenn `timer` zuerst fertig
ist, gibt `select` `Right` mit der Ausgabe des Timers `()` zurück.

Wenn `Future_to_try` erfolgreich war und wir `Left(output)` erhalten, geben wir
`Ok(output)` zurück. Wenn stattdessen der Sleep-Timer abgelaufen ist und wir
`Right(())` erhalten, ignorieren wir der Wert `()` mit `_` und geben
stattdessen `Err(max_time)` zurück.

Damit haben wir ein funktionierendes `timeout`, das aus zwei anderen
asynchronen Helfern besteht. Wenn wir unseren Code ausführen, wird er als
Fehlermeldung nach dem Timeout ausgeben:

```text
Fehlgeschlagen nach 2 Sekunden
```

Da Futures aus anderen Futures zusammengesetzt werden können, lassen sich mit
kleineren asynchronen Bausteinen wirklich leistungsfähige Werkzeuge erstellen.
So kannst du beispielsweise mit demselben Ansatz Zeitüberschreitungen mit
Wiederholungen kombinieren und diese wiederum für Operationen wie
Netzwerkaufrufe verwenden (so wie in Codeblock 17-5).

In der Praxis arbeitest du in der Regel direkt mit `async` und `await` und
seltener mit Funktionen wie `select` und Makros wie `join!`, um die Ausführung
der äußersten Futures zu steuern.

Wir haben nun verschiedene Möglichkeiten kennengelernt, wie man mit mehreren
Futures gleichzeitig arbeiten kann. Als Nächstes werden wir uns ansehen, wie
wir mit _Strömen_ (streams) mehrere Futures in einer zeitlichen Abfolge
arbeiten können.

[async-program]: ch17-01-futures-and-syntax.html#unser-erstes-asynchrones-programm
