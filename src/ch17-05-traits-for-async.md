## Ein genauerer Blick auf die Merkmale für Async

Im Laufe des Kapitels haben wir die Merkmale `Future`, `Pin`, `Unpin`, `Stream`
und `StreamExt` auf verschiedene Weise verwendet. Bis jetzt haben wir es jedoch
vermieden, zu sehr ins Detail zu gehen, wie sie funktionieren oder wie sie
zusammenpassen. Wenn wir Rust für den Alltag schreiben, ist das meist
ausreichend. Manchmal stößt man jedoch auf Situationen, in denen du
weitergehende Details verstehen musst. In diesem Abschnitt werden wir nur so
weit ins Detail gehen, wie es für diese Szenarien nötig ist, und überlassen die
_wirklich_ tiefen Einblicke der weiteren Dokumentation.

### Das Merkmal `Future`

Lass uns zunächst einen genaueren Blick darauf werfen, wie das Merkmal `Future`
funktioniert. Rust definiert es wie folgt:

```rust
use std::pin::Pin;
use std::task::{Context, Poll};

pub trait Future {
    type Output;

    fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output>;
}
```

Diese Merkmals-Definition enthält eine Reihe neuer Typen und auch eine Syntax,
die wir bisher noch nicht gesehen haben. Gehen wir also die Definition Stück
für Stück durch.

Erstens gibt der zugehörige Typ `Output` von `Future` an, was das Future
zurückgibt. Dies ist analog zum Typ `Item` des Merkmals `Iterator`. Zweitens
hat `Future` auch die Methode `poll`, die eine spezielle `Pin`-Referenz für
ihren `self`-Parameter und eine veränderbare Referenz auf einen `Context`-Typ
entgegennimmt und `Poll<Self::Output>` zurückgibt. Wir werden gleich ein wenig
mehr über `Pin` und `Context` sprechen. Für den Moment wollen wir uns auf das
konzentrieren, was die Methode zurückgibt: Den Typ `Poll`:

```rust
enum Poll<T> {
    Ready(T),
    Pending,
}
```

Dieser Typ `Poll` ist ähnlich wie eine `Option`: Er hat eine Variante
`Ready(T)`, die einen Wert hat, und eine Variante `Pending` ohne Wert. `Poll`
bedeutet jedoch etwas ganz anderes als `Option`! Die Variante `Pending` zeigt
an, dass das Future noch Arbeit zu erledigen hat, sodass der Aufrufer später
noch einmal nachsehen muss. Die Variante `Ready` zeigt an, dass das `Future`
seine Arbeit beendet hat und der Wert `T` verfügbar ist.

> Hinweis: Bei den meisten Futures sollte der Aufrufer die Methode `poll` nicht
> erneut aufrufen, nachdem das Future `Ready` zurückgegeben hat. Viele Futures
> werden das Programm abbrechen, wenn sie erneut abgefragt werden, obwohl sie
> bereit sind! Futures, bei denen eine erneute Abfrage sicher ist, werden dies
> in ihrer Dokumentation explizit erwähnen. Dies ist ähnlich zum Verhalten von
> `Iterator::next`!

Unter der Haube kompiliert Rust Code mit `await` zu Code, der `poll` aufruft.
Wenn du dir Codeblock 17-4 ansiehst, wo wir den Seitentitel für eine einzelne
URL ausgegeben haben, sobald sie aufgelöst wurde, kompiliert Rust das in etwa
(wenn auch nicht genau) wie folgt:

```rust,ignore
match page_title(url).poll() {
    Ready(page_title) => match page_title {
        Some(title) => println!("Der Titel für {url} war {title}"),
        None => println!("{url} hatte keinen Titel"),
    }
    Pending => {
        // Aber was kommt hierhin?
    }
}
```

Was sollen wir tun, wenn das Future noch `Pending` ist? Wir brauchen eine
Möglichkeit, es nochmal zu versuchen und nochmal und nochmal, bis das Future
endlich fertig ist. Mit anderen Worten, wir benötigen eine Schleife:

```rust,ignore
let mut page_title_fut = page_title(url);
loop {
    match page_title_fut.poll() {
        Ready(value) => match page_title {
            Some(title) => println!("Der Titel für {url} war {title}"),
            None => println!("{url} hatte keinen Titel"),
        }
        Pending => {
            // weitermachen
        }
    }
}
```

Wenn Rust diesen Code kompilieren würde, würde jedes `await` blockieren &ndash;
genau das Gegenteil von dem, was wir erreichen wollten! Stattdessen sorgt Rust
dafür, dass die Schleife die Kontrolle an etwas abgeben kann, das die Arbeit an
diesem Future unterbrechen und an anderen Futures arbeiten kann, um diese
später wieder zu prüfen. Wie wir bereits gesehen haben, ist dieses „Etwas“ eine
asynchrone Laufzeitumgebung, und diese Planungs- und Koordinierungsarbeit ist
eine der Hauptaufgaben einer Laufzeitumgebung.

Weiter oben in diesem Kapitel haben wir das Warten auf `rx.recv` beschrieben.
Der Aufruf `recv` gibt ein Future zurück und zum Warten darauf wird es es
abgefragt. Wir haben angemerkt, dass eine Laufzeitumgebung das Future pausieren
wird, bis es entweder mit `Some(message)` oder `None` bereit ist, wenn der
Kanal geschlossen wird. Mit unserem tieferen Verständnis des Merkmals `Future`
und insbesondere von `Future::poll` können wir sehen, wie das funktioniert. Die
Laufzeitumgebung weiß, dass das Future nicht bereit ist, wenn es
`Poll::Pending` zurückgibt. Umgekehrt weiß die Laufzeitumgebung, dass das
Future _bereit_ ist und bevorzugt es, wenn `poll` den Wert
`Poll::Ready(Some(message))` oder `Poll::Ready(None)` zurückgibt.

Die genauen Details, wie eine Laufzeitumgebung das macht, gehen über den Rahmen
dieses Buches hinaus, aber der Schlüssel ist, die grundlegende Mechanik von
Futures zu verstehen: Eine Laufzeitumgebung fragt jedes Future ab, für das sie
verantwortlich ist, und versetzt das Future zurück in den Schlaf, wenn es noch
nicht bereit ist.

### Die Merkmale `Pin` and `Unpin`

Als wir in Codeblock 17-16 die Idee des Anheftens einführten, stießen wir auf
eine sehr unangenehme Fehlermeldung. Hier ist noch einmal der relevante Teil
davon:

```text
error[E0277]: `{async block@src/main.rs:10:23: 10:33}` cannot be unpinned
  --> src/main.rs:48:33
   |
48 |         trpl::join_all(futures).await;
   |                                 ^^^^^ the trait `Unpin` is not implemented for `{async block@src/main.rs:10:23: 10:33}`, which is required by `Box<{async block@src/main.rs:10:23: 10:33}>: Future`
   |
   = note: consider using the `pin!` macro
           consider using `Box::pin` if you need to access the pinned value outside of the current scope
   = note: required for `Box<{async block@src/main.rs:10:23: 10:33}>` to implement `Future`
note: required by a bound in `futures_util::future::join_all::JoinAll`
  --> file:///home/.cargo/registry/src/index.crates.io-6f17d22bba15001f/futures-util-0.3.30/src/future/join_all.rs:29:8
   |
27 | pub struct JoinAll<F>
   |            ------- required by a bound in this struct
28 | where
29 |     F: Future,
   |        ^^^^^^ required by this bound in `JoinAll`
```

Diese Fehlermeldung sagt uns nicht nur, dass wir die Werte anheften müssen,
sondern auch, warum das Anheften erforderlich ist. Die Funktion
`trpl::join_all` gibt eine Struktur namens `JoinAll` zurück. Diese Struktur
ist generisch über einen Typ `F`, der auf die Implementierung des Merkmals
`Future` beschränkt ist. Direktes Warten auf ein Future mit `await` heftet das
Future implizit an. Deshalb müssen wir `pin!` nicht überall verwenden, wo wir
auf Futures warten wollen.

Allerdings warten wir hier nicht direkt ein Future. Stattdessen konstruieren
wir ein neues Future `JoinAll`, indem wir eine Kollektion von Futures an die
Funktion `join_all` übergeben. Die Signatur für `join_all` erfordert, dass der
Typ der Elemente in der Kollektion das Merkmal `Future` implementiert. `Box<T>`
implementiert `Future` nur, wenn das `T`, das es umhüllt, ein Future ist, das
das Merkmal `Unpin` implementiert.

Das ist eine Menge, die man verarbeiten muss! Um es wirklich zu verstehen,
müssen wir ein wenig tiefer in die Funktionsweise des Merkmals `Future`
eintauchen, insbesondere in Bezug auf das _Anheften_ (pinning).

Schau dir noch einmal die Definition des Merkmals `Future` an:

```rust
use std::pin::Pin;
use std::task::{Context, Poll};

pub trait Future {
    type Output;

    // Erforderliche Methode
    fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output>;
}
```

Der Parameter `cx` und sein Typ `Context` sind der Schlüssel dazu, wie eine
Laufzeitumgebung tatsächlich weiß, wann sie ein bestimmtes Future prüfen muss,
während es immer noch faul ist. Die Details, wie das funktioniert, liegen
jedoch außerhalb des Rahmens dieses Kapitels: Du musst dich im Allgemeinen nur
darum kümmern, wenn du eine eigene `Future`-Implementierung schreibst. Wir
werden uns stattdessen auf den Typ von `self` konzentrieren, da dies das erste
Mal ist, dass wir eine Methode sehen, bei der `self` eine Typ-Annotation hat.
Eine Typ-Annotation für `self` funktioniert wie Typ-Annotationen für andere
Funktionsparameter, jedoch mit zwei wesentlichen Unterschieden:

- Sie teilt Rust mit, welchen Typ `self` haben muss, damit die Methode
  aufgerufen werden kann.

- Sie teilt Rust mit, welchen Typ `self` haben muss, damit die Methode aufgerufen werden kann.

- Es kann nicht einfach irgendein Typ sein. Es ist beschränkt auf den Typ, auf
  dem die Methode implementiert ist, eine Referenz oder ein Smart Pointer auf
  diesen Typ oder ein `Pin`, der eine Referenz auf diesen Typ umhüllt.

Wir werden mehr über diese Syntax in [Kapitel 18][ch-18] erfahren. Für den
Moment reicht es zu wissen, dass wir, wenn wir ein Future abfragen wollen, um
zu prüfen, ob es `Pending` oder `Ready(Output)` ist, eine mit `Pin` umhüllte
veränderbare Referenz auf den Typ benötigen.

`Pin` ist ein Wrapper für zeigerartige Typen wie `&`, `&mut`, `Box` und `Rc`.
(Technisch gesehen arbeitet `Pin` mit Typen, die die Merkmale `Deref` oder
`DerefMut` implementieren, aber das ist effektiv gleichbedeutend damit, nur mit
Zeigern zu arbeiten.) `Pin` ist selbst kein Zeiger und hat kein eigenes
Verhalten wie `Rc` und `Arc` mit Referenzzählern; es ist lediglich ein
Werkzeug, das der Compiler verwenden kann, um Einschränkungen bei der 
Verwendung von Zeigern zu erzwingen.

Wenn man sich daran erinnert, dass `await` in Form von Aufrufen von `poll`
implementiert ist, erklärt das die Fehlermeldung, die wir oben gesehen haben,
aber die bezog sich auf `Unpin`, nicht auf `Pin`. Wie genau verhält sich also
`Pin` zu `Unpin`, und warum muss `self` bei einem `Future` in einem `Pin`-Typ
sein, um `poll` aufzurufen?

Erinnere dich an den Anfang dieses Kapitels: Eine Reihe von Wartepunkten in
einem Future wird zu einem Zustandsautomaten kompiliert, und der Compiler
stellt sicher, dass dieser Zustandsautomat alle normalen Sicherheitsregeln von
Rust befolgt, einschließlich Ausleihen (borrowing) und Eigentümerschaft
(ownership). Damit das funktioniert, prüft Rust, welche Daten zwischen einem
await-Punkt und entweder dem nächsten await-Punkt oder dem Ende des
asynchronen Blocks benötigt werden. Anschließend wird eine entsprechende
Variante in der kompilierten Zustandsmaschine erstellt. Jede Variante erhält
den erforderlichen Zugriff auf die Daten, die in diesem Abschnitt des
Quellcodes verwendet werden, entweder durch Übernahme der Eigentümerschaft an
diesen Daten oder durch Erhalt einer veränderbaren oder unveränderbaren
Referenz darauf.

So weit, so gut: Wenn wir bei der Eigentümerschaft oder den Referenzen in einem
bestimmten asynchronen Block etwas falsch machen, wird uns der Ausleihenprüfer
(borrow checker) dies mitteilen. Wenn wir das Future, das diesem Block
entspricht, verschieben wollen &ndash; etwa in einen `Vec`, um es an `join_all`
zu übergeben &ndash; wird es schwieriger.

Wenn wir ein Future verschieben &ndash; sei es durch Verschieben in eine
Datenstruktur, um es als Iterator mit `join_all` zu verwenden oder durch
Rückgabe aus einer Funktion &ndash; bedeutet das eigentlich, dass wir die
Zustandsmaschine verschieben, die Rust für uns erstellt. Und im Gegensatz zu
den meisten anderen Typen in Rust können die Futures, die Rust für async-Blöcke
erzeugt, mit Referenzen auf sich selbst in den Feldern einer beliebigen
Variante enden, wie in der vereinfachten Darstellung in Abbildung 17-4 gezeigt.

<img alt="Nebenläufiger Arbeitsablauf" src="img/trpl17-04.svg" />

<figcaption>Abbildung 17-4: Ein selbstreferenzierender Datentyp</figcaption>

Standardmäßig kann ein Objekt, das eine Referenz auf sich selbst hat, nicht
sicher verschoben werden, da Referenzen immer auf die tatsächliche
Speicheradresse des Objekts zeigen (siehe Abbildung 17-5). Wenn du die
Datenstruktur selbst verschiebst, verweisen diese internen Referenzen weiterhin
auf den alten Speicherplatz. Dieser Speicherplatz ist nun jedoch ungültig. Zum
einen wird ihr Wert nicht mehr aktualisiert, wenn du Änderungen an der
Datenstruktur vornimmst. Zum anderen &ndash; und das ist noch wichtiger &ndash;
kann der Computer diesen Speicherplatz nun für andere Zwecke verwenden! Es
könnte sein, dass du später völlig unzusammenhängende Daten liest.

<img alt="Nebenläufiger Arbeitsablauf" src="img/trpl17-05.svg" />

<figcaption>Abbildung 17-5: Das unsichere Ergebnis beim Verschieben eines
selbstreferenzierenden Datentyps</figcaption>

Theoretisch könnte der Rust-Compiler versuchen, jede Referenz auf ein Objekt zu
aktualisieren, wenn es verschoben wird. Das würde potenziell eine Menge
zusätzlicher Performance-Overhead bedeuten, vor allem wenn man bedenkt, dass es
ein ganzes Netz von Referenzen geben kann, die aktualisiert werden müssen. Wenn
wir stattdessen sicherstellen können, dass die betreffende Datenstruktur _nicht
im Speicher verschoben wird_, müssen wir keine Referenzen aktualisieren. Das
ist genau das, was der Rust-Ausleihenprüfer verlangt: In sicherem Code kann man
kein ein Element, auf das aktive Referenzen bestehen, verschieben.

`Pin` baut darauf auf, um uns genau die Garantie zu geben, die wir brauchen.
Wenn wir einen Wert _anheften_, indem wir einen Zeiger auf diesen Wert in `Pin`
einpacken, kann er nicht mehr verschoben werden. Wenn du also
`Pin<Box<SomeType>>` hast, heftest du eigentlich den Wert `SomeType` an,
_nicht_ den Zeiger `Box`. Abbildung 17-6 veranschaulicht dies:

<img alt="Nebenläufiger Arbeitsablauf" src="img/trpl17-06.svg" />

<figcaption>Abbildung 17-6: Anheften einer `Box`, die auf einen
selbstreferenzierenden Future-Typ zeigt</figcaption>

In der Tat kann der Zeiger in `Box` immer noch verschoben werden. Denke daran:
Wir wollen sicherstellen, dass die Daten, auf die letztlich referenziert wird,
an ihrem Platz bleiben. Wenn ein Zeiger verschoben wird, aber die Daten, auf
die er zeigt, an der gleichen Stelle sind, wie in Abbildung 17-7, gibt es kein
potenzielles Problem. (Schau dir als unabhängige Übung die Dokumentationen der
Typen sowie des Moduls `std::pin` an und versuche herauszufinden, wie du das
mit einem `Pin` machst, der eine `Box` umhüllt). Der Schlüssel ist, dass der
selbstreferenzierende Typ selbst nicht verschoben werden kann, weil er immer
noch angeheftet ist.

<img alt="Nebenläufiger Arbeitsablauf" src="img/trpl17-07.svg" />

<figcaption>Figure 17-7: Verschieben einer `Box`, die auf einen
selbstreferenzierenden Futuretyp zeigt.</figcaption>

Die meisten Typen können jedoch gefahrlos verschoben werden, selbst wenn sie
sich hinter einem `Pin`-Wrapper befinden. Wir müssen nur über das Anheften
nachdenken, wenn Elemente interne Referenzen haben. Primitive Werte wie Zahlen
und Boolesche Werte sind sicher, weil sie keine internen Referenzen haben.
Genauso wenig wie die meisten Typen, mit denen man normalerweise in Rust
arbeitet. Du kannst zum Beispiel unbesorgt in einem `Vec` verschieben. Nach
dem, was wir bisher gesehen haben, müsste man bei einem `Pin<Vec<String>>`
alles über die sicheren, aber restriktiven APIs von `Pin` machen, obwohl ein
`Vec<String>` immer sicher verschoben werden kann, wenn es keine anderen
Referenzen auf ihn gibt. Wir brauchen eine Möglichkeit, dem Compiler
mitzuteilen, dass es in solchen Fällen in Ordnung ist, Elemente zu verschieben
&ndash; und hier kommt `Unpin` ins Spiel.

`Unpin` ist ein Markierungsmerkmal (marker trait), ähnlich wie die Merkmale
`Send` und `Sync`, die wir in Kapitel 16 gesehen haben, und es hat keine eigene
Funktionalität. Markierungsmerkmale existieren nur, um dem Compiler
mitzuteilen, dass es sicher ist, den Typ zu verwenden, der ein bestimmtes
Merkmal in einem bestimmten Kontext implementiert. `Unpin` teilt dem Compiler
mit, dass ein gegebener Typ _keine_ besonderen Garantien aufrechterhalten muss,
um den fragliche Wert zu verschieben.

Genau wie bei `Send` und `Sync` implementiert der Compiler `Unpin` automatisch
für alle Typen, bei denen er beweisen kann, dass sie sicher sind. Ein
Sonderfall analog zu `Send` und `Sync` ist, dass `Unpin` für einen Typ _nicht_
implementiert ist. Die Notation hierfür ist `impl !Unpin for SomeType`, wobei
`SomeType` der Name eines Typs ist, der diese Garantien aufrechterhalten
_muss_, um sicher zu sein, wenn ein Zeiger auf diesen Typ in einem `Pin`
verwendet wird.

Mit anderen Worten, es gibt zwei Dinge über die Beziehung zwischen `Pin` und
`Unpin` zu beachten. Erstens ist `Unpin` der „normale“ Fall und `!Unpin` der
Spezialfall. Zweitens, ob ein Typ `Unpin` oder `!Unpin` implementiert, spielt
_nur_ eine Rolle, wenn man einen angepinnten Zeiger auf diesen Typ wie
`Pin<&mut SomeType>` verwendet.

Um dies zu verdeutlichen, denke an einen `String`: Er hat eine Länge und die
Unicode-Zeichen, aus denen er besteht. Wir können einen `String` in einen `Pin`
einpacken, wie in Abbildung 17-8. Allerdings implementiert `String` automatisch
`Unpin`, wie die meisten anderen Typen in Rust.

<img alt="Concurrent work flow" src="img/trpl17-08.svg" />

<figcaption>Abbildung 17-8: Anheften eines `String`; die gestrichelte Linie
deutet an, dass die Zeichenkette das Merkmal `Unpin` implementiert und daher
nicht angeheftet ist.</figcaption>

Infolgedessen können wir Dinge tun, die illegal wären, wenn `String`
stattdessen `!Unpin` implementiert hätte, wie zum Beispiel das Ersetzen einer
Zeichenkette durch eine andere an der exakt gleichen Stelle im Speicher, wie in
Abbildung 17-9. Dies verletzt nicht den `Pin`-Vertrag, weil `String` keine
internen Referenzen hat, die es unsicher machen, es zu verschieben! Das ist
genau der Grund, warum es `Unpin` und nicht `!Unpin` implementiert.

<img alt="Concurrent work flow" src="img/trpl17-09.svg" />

<figcaption>Figure 17-9: Ersetzen eines `String` durch einen völlig anderen
`String` im Speicher.</figcaption>

Jetzt wissen wir genug, um die Fehler zu verstehen, die für den Aufruf
`join_all` in Codeblock 17-17 gemeldet wurden. Ursprünglich haben wir versucht,
die von asynchronen Blöcken erzeugten Futures in einen `Vec<Box<dyn
 Future<Output = ()>>>` zu verschieben, aber wie wir gesehen haben, können
diese Futures interne Referenzen haben, sodass sie `Unpin` nicht
implementieren. Sie müssen angepinnt werden und dann können wir den Typ `Pin`
an den `Vec` übergeben, in der Gewissheit, dass die zugrunde liegenden Daten in
den Futures _nicht_ verschoben werden.

`Pin` und `Unpin` sind vor allem für die Erstellung von Bibliotheken auf
niedrigerer Ebene wichtig und wenn du eine Laufzeitumgebung erstellst, weniger
für den alltäglichen Rust-Code. Wenn du diese Merkmale in Fehlermeldungen
siehst, hast du jetzt eine bessere Vorstellung davon, wie du deinen Code
korrigieren kannst!

> Anmerkung: Diese Kombination von `Pin` und `Unpin` macht es möglich, eine
> ganze Klasse von komplexen Typen sicher in Rust zu implementieren, die sich
> sonst als schwierig erweisen würden, weil sie selbstreferenzierend sind.
> Typen, die `Pin` benötigen, tauchen heute am häufigsten in asynchronem Rust
> auf, aber hin und wieder sieht man sie auch in anderen Kontexten.
>
> Die Besonderheiten der Funktionsweise von `Pin` und `Unpin` und die Regeln,
> die sie einhalten müssen, werden ausführlich in der API-Dokumentation für
> `std::pin` behandelt. Wenn du mehr darüber lernen willst, ist das ein guter
> Ausgangspunkt.
>
> Wenn du noch detaillierter verstehen willst, wie die Dinge unter der Haube
> funktionieren, schaue dir die Kapitel [2][under-the-hood] and [4][pinning]
> des Buchs [_Asynchronous Programming in Rust_][async-book] an:

### Das Merkmal `Stream`

Nachdem du nun ein tieferes Verständnis für die Merkmale `Future`, `Pin` und
`Unpin` hast, können wir uns dem Merkmal `Stream` zuwenden. Wie du bereits in
diesem Kapitel gelernt hast, sind Ströme ähnlich wie asynchrone Iteratoren. Im
Gegensatz zu `Iterator` und `Future` hat `Stream` derzeit keine Definition in
der Standardbibliothek, aber es _gibt_ eine sehr verbreitete Definition in der
Kiste `Futures`, die im gesamten Ökosystem verwendet wird.

Schauen wir uns die Definitionen der Merkmale `Iterator` und `Future` an, bevor
wir uns ansehen, wie ein Merkmal `Stream` aussehen könnte. Von `Iterator` haben
wir die Idee einer Sequenz: Seine Methode `next` liefert eine
`Option<Self::Item>`. Von `Future` haben wir die Idee der zeitlichen
Bereitschaft: Seine Methode `poll` liefert ein `Poll<Self::Output>`. Um eine
Sequenz von Elementen darzustellen, die im Laufe der Zeit bereit sind,
definieren wir ein Merkmal `Stream`, das diese Funktionalitäten zusammenführt:

```rust
use std::pin::Pin;
use std::task::{Context, Poll};

trait Stream {
    type Item;

    fn poll_next(
        self: Pin<&mut Self>,
        cx: &mut Context<'_>
    ) -> Poll<Option<Self::Item>>;
}
```

Das Merkmal `Stream` definiert einen zugehörigen Typ namens `Item` für den Typ
der vom Strom erzeugten Elemente. Dies ist ähnlich wie bei `Iterator`, wo es
null bis viele Elemente geben kann, anders als bei `Future`, wo es immer nur
einen einzigen `Output` gibt, selbst wenn es der Einheitstyp `()` ist.

`Stream` definiert auch eine Methode zum Abrufen dieser Elemente. Wir nennen
sie `poll_next`, um zu verdeutlichen, dass sie auf die gleiche Weise wie
`Future::poll` abfragt und eine Sequenz von Elementen auf die gleiche Weise wie
`Iterator::next` erzeugt. Sein Rückgabetyp kombiniert `Poll` mit `Option`. Der
äußere Typ ist `Poll`, weil er auf Bereitschaft geprüft werden muss, genau wie
ein Future. Der innere Typ ist `Option`, weil er signalisieren muss, ob es
weitere Nachrichten gibt, genau wie ein Iterator.

Etwas, das dieser Definition sehr ähnlich ist, wird wahrscheinlich Teil der
Standardbibliothek von Rust werden. In der Zwischenzeit ist es Teil des
Werkzeugkoffers der meisten Laufzeitumgebungen, sodass du dich darauf verlassen
kannst, und alles, was wir als nächstes behandeln, sollte im Allgemeinen
gelten!

Im Beispiel, das wir im Abschnitt über Ströme gesehen haben, haben wir
allerdings nicht `poll_next` _oder_ `Stream` benutzt, sondern `next` und
`StreamExt`. Wir _könnten_ direkt mit der `poll_next`-API arbeiten, indem wir
unsere eigenen `Stream`-Zustandsautomaten schreiben, genauso wie wir mit
Futures direkt über deren Methode `poll` arbeiten _können_. Die Verwendung von
`await` ist jedoch viel schöner, und das Merkmal `StreamExt` stellt die Methode
`next` bereit, sodass wir genau das tun können:

```rust
# use std::pin::Pin;
# use std::task::{Context, Poll};
#
# trait Stream {
#     type Item;
#     fn poll_next(
#         self: Pin<&mut Self>,
#         cx: &mut Context<'_>,
#     ) -> Poll<Option<Self::Item>>;
# }
#
trait StreamExt: Stream {
    async fn next(&mut self) -> Option<Self::Item>
    where
        Self: Unpin;

    // andere Methoden ...
}
```

> Anmerkung: Die tatsächliche Definition von `StreamExt` sieht etwas anders
> aus, da sie Versionen von Rust unterstützt, die noch keine Verwendung von
> asynchronen Funktionen in Merkmalen kennen. Infolgedessen sieht sie so aus:
>
> ```rust,ignore
> fn next(&mut self) -> Next<'_, Self> where Self: Unpin;
> ```
>
> Dieser Typ `Next` ist ein `struct`, das `Future` implementiert und erlaubt
> uns, die Lebensdauer der Referenz auf `self` mit `Next<'_, Self>` zu
> benennen, sodass `await` mit dieser Methode arbeiten kann!

Das Merkmal `StreamExt` ist auch die Heimat aller interessanten Methoden, die
für die Verwendung mit Strömen zur Verfügung stehen. `StreamExt` wird
automatisch für jeden Typ implementiert, der `Stream` implementiert, aber diese
Merkmale werden separat definiert, um der Rust-Gemeinschaft die Möglichkeit zu
geben, Komfort-APIs zu entwickeln, ohne die grundlegenden Merkmale zu
beeinflussen.

In der Version von `StreamExt`, die in der Kiste `trpl` verwendet wird,
definiert das Merkmal nicht nur die Methode `next`, sondern liefert auch eine
Implementierung von `next`, die die Details des Aufrufs von `Stream::poll_next`
korrekt behandelt. Das bedeutet, dass du selbst beim Schreiben deines eigenen
Streaming-Datentyps _nur_ `Stream` implementieren musst, und dann kann jeder,
der deinen Datentyp verwendet, `StreamExt` und seine Methoden automatisch mit
ihm verwenden.

Das ist alles, was wir für die tieferen Details zu diesen Merkmalen behandeln
werden. Zum Abschluss wollen wir uns ansehen, wie Futures (einschließlich
Ströme), Aufgaben und Stränge zusammenpassen!

[async-book]: https://rust-lang.github.io/async-book/
[ch-18]: ch18-00-oop.html
[pinning]: https://rust-lang.github.io/async-book/04_pinning/01_chapter.html
[under-the-hood]: https://rust-lang.github.io/async-book/02_execution/01_chapter.html
