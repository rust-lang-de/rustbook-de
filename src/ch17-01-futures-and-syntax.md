## Futures und die asynchrone Syntax

Die Schlüsselelemente der asynchronen Programmierung in Rust sind _Futures_ und
die Rust-Schlüsselwörter `async` und `await`.

Ein _Future_ ist ein Wert, der vielleicht noch nicht verfügbar ist, aber
irgendwann in der Zukunft verfügbar sein wird. (Das gleiche Konzept taucht in
vielen Programmiersprachen auf, manchmal unter anderen Namen wie „task“ oder
„promise“.) Rust hat ein Merkmal `Future` als Baustein, sodass verschiedene
asynchrone Operationen mit verschiedenen Datenstrukturen, aber mit einer
gemeinsamen Schnittstelle implementiert werden können. In Rust sind Futures
Typen, die das Merkmal `Future` implementieren. Jedes Future hält seine eigenen
Informationen über den Fortschritt, der gemacht wurde und was „fertig“
bedeutet.

Das Schlüsselwort `async` kann auf Blöcke und Funktionen angewendet werden, um
anzugeben, dass sie unterbrochen und fortgesetzt werden können. Innerhalb eines
asynchronen Blocks oder einer asynchronen Funktion kannst du mit dem
Schlüsselwort `await` auf ein Future warten (d.h. warten bis es fertig ist).
Jede Stelle, an der du innerhalb eines asynchronen Blocks oder einer
asynchronen Funktion auf ein Future wartest, ist eine Stelle, an der der
asynchrone Block oder die asynchrone Funktion unterbrochen und fortgesetzt
werden kann. Der Vorgang, bei dem bei einem Future geprüft wird, ob sein Wert
bereits verfügbar ist, wird _polling_ (engl. Abfragen) genannt.

Andere Sprachen wie C# und JavaScript verwenden ebenfalls die Schlüsselwörter
`async` und `await` für die asynchrone Programmierung. Wenn du mit diesen
Sprachen vertraut bist, wirst du vielleicht einige signifikante Unterschiede
zur Arbeitsweise von Rust bemerken, einschließlich der Art und Weise, wie es
die Syntax handhabt. Und das aus gutem Grund, wie wir sehen werden!

Wenn wir asynchrones Rust schreiben, verwenden wir meistens die Schlüsselwörter
`async` und `await`. Rust kompiliert sie in äquivalenten Code unter Verwendung
des Merkmals `Future`, genauso wie es `for`-Schleifen in äquivalenten Code
unter Verwendung des Merkmals `Iterator` kompiliert. Da Rust das Merkmal
`Future` bereitstellt, kannst du es bei Bedarf auch für deine eigenen
Datentypen implementieren. Viele der Funktionen, die wir in diesem Kapitel
sehen werden, geben Typen mit ihren eigenen Implementierungen von `Future`
zurück. Wir werden am Ende des Kapitels noch einmal auf die Definition des
Merkmals zurückkommen und mehr darüber erfahren, wie es funktioniert. Aber das
sind vorerst genug Details, die wir brauchen.

Das mag sich alles ein wenig abstrakt anfühlen, lass uns daher unser erstes
asynchrones Programm schreiben: Einen kleinen Web Scraper. Wir geben zwei URLs
über die Befehlszeile ein, rufen beide gleichzeitig ab und geben das Ergebnis
desjenigen zurück, der zuerst fertig wird. Dieses Beispiel wird eine neue
Syntax verwenden, aber keine Sorge &ndash; wir erklären dir alles, was du zum
jeweiligen Zeitpunkt wissen musst.

## Unser erstes asynchrones Programm

Um dieses Kapitel auf das Erlernen von async zu beschränken, anstatt mit Teilen
des Ökosystems zu jonglieren, haben wir die Kiste `trpl` erstellt (`trpl` ist
die Abkürzung für „The Rust Programming Language“). Sie re-exportiert alle
Typen, Merkmale und Funktionen, die du benötigst, hauptsächlich aus den Kisten
[`futures`][futures-crate] und [`tokio`][tokio]. Die Kiste `futures` ist ein
offizielles Zuhause für Rust-Experimente mit asynchronem Code und ist
eigentlich der Ort, an dem das Merkmal `Future` ursprünglich entworfen wurde.
Tokio ist heute die am häufigsten verwendete asynchrone Laufzeitumgebung in
Rust, insbesondere für Webanwendungen. Es gibt noch andere großartige
Laufzeitumgebungen, die für deine Zwecke evtl. besser geeignet sind. Wir
verwenden unter der Haube die Kiste `tokio` für `trpl`, weil es gut getestet
und weit verbreitet ist.

In einigen Fällen nennt `trpl` die ursprünglichen APIs um oder umschließt sie,
damit wir uns auf die für dieses Kapitel relevanten Details konzentrieren
können. Wenn du verstehen willst, was die Kiste tut, empfehlen wir dir, sich
den [trpl-Quellcode][crate-source] anzusehen. Du wirst sehen können, aus
welcher Kiste jeder Re-Export stammt, und wir haben ausführliche Kommentare
angegeben, die erklären, was die Kiste tut.

Erstelle ein neues Binärprojekt mit dem Namen `hello-async` und füge die Kiste
`trpl` als Abhängigkeit hinzu:

```console
$ cargo new hello-async
$ cd hello-async
$ cargo add trpl
```

Jetzt können wir die verschiedenen von `trpl` bereitgestellten Teile verwenden,
um unser erstes asynchrones Programm zu schreiben. Wir werden ein kleines
Kommandozeilen-Werkzeug erstellen, das zwei Webseiten abruft, das
jeweilige `<title>`-Element ausliest und den Titel derjenigen Seite ausgibt,
die den Vorgang zuerst beendet hat.

### Definieren der Funktion `page_title`

Beginnen wir mit dem Schreiben einer Funktion, die eine Seiten-URL als
Parameter entgegennimmt, eine Anfrage an diese stellt und den Text des
Titelelements zurückgibt (siehe Codeblock 17-1).

<span class="filename">Dateiname: src/main.rs</span>

```rust
# extern crate trpl;
#
# fn main() {
#     // TODO: Wir fügen dies als nächstes hinzu!
# }
#
use trpl::Html;

async fn page_title(url: &str) -> Option<String> {
    let response = trpl::get(url).await;
    let response_text = response.text().await;
    Html::parse(&response_text)
        .select_first("title")
        .map(|title_element| title_element.inner_html())
}
```

<span class="caption">Codeblock 17-1: Definieren einer asynchronen Funktion zum
Abrufen des Titelelements aus einer HTML-Seite</span>

Zuerst definieren wir eine Funktion `page_title` und versehen sie mit dem
Schlüsselwort `async`. Dann verwenden wir die Funktion `trpl::get`, um die
übergebene URL abzurufen, und geben das Schlüsselwort `await` an, um auf die
Antwort zu warten. Um den Text aus der Antwort zu erhalten, rufen wir die
Methode `text` auf und warten erneut mit dem Schlüsselwort `await`. Diese
beiden Schritte sind asynchron. Bei der Funktion `get` müssen wir darauf
warten, dass der Server den ersten Teil seiner Antwort sendet, der den
HTTP-Header, Cookies und so weiter enthält. Dieser Teil der Antwort kann
getrennt vom Hauptteil der Anfrage übermittelt werden. Vor allem, wenn der
Textteil sehr umfangreich ist, kann es einige Zeit dauern, bis er vollständig
angekommen ist. Da wir auf das Eintreffen der _gesamten_ Antwort warten müssen,
wird die Methode `text` ebenfalls als asynchron deklariert.

Wir müssen beide Futures explizit abwarten, weil Futures in Rust _faul_ (lazy)
sind: Sie tun nichts, bis man sie mit dem Schlüsselwort `await` dazu
auffordert. (Tatsächlich zeigt Rust eine Compiler-Warnung an, wenn du keine
Futures verwendest.) Das dürfte dich an unsere Diskussion über Iteratoren in
[„Eine Reihe von Elementen verarbeiten mit Iteratoren“][iterators-lazy] in
Kapitel 13 erinnern. Iteratoren tun nichts, es sei denn, du rufst ihre Methode
`next` auf &ndash; entweder direkt oder mit Hilfe von `for`-Schleifen
oder Methoden wie `map`, die `next` unter der Haube verwenden. Ebenso machen
Futures nichts, es sei denn, man bittet sie ausdrücklich darum. Diese Faulheit
erlaubt es Rust, die Ausführung von asynchronem Code zu vermeiden, bis er
tatsächlich benötigt wird.

> Anmerkung: Dies unterscheidet sich von dem Verhalten, das wir im vorherigen
> Kapitel gesehen haben, als wir `thread::spawn` in [„Erstellen eines neuen
> Strangs mit spawn“][thread-spawn] verwendet haben und der Funktionsabschluss,
> den wir an einen anderen Strang übergeben haben, sofort zu laufen begann. Es
> unterscheidet sich auch davon, wie viele andere Sprachen die asynchrone
> Programmierung umsetzen! Aber es ist wichtig für Rust, dass es seine
> Leistungsgarantien gewährleisten kann, genau wie bei Iteratoren.

Sobald wir `response_text` haben, können wir ihn mit `Html::parse` in eine
Instanz des Typs `Html` einlesen. Anstelle einer rohen Zeichenkette haben wir
nun einen Datentyp, den wir verwenden können, um mit HTML als eine
reichhaltigere Datenstruktur zu arbeiten. Insbesondere können wir die Methode
`select_first` verwenden, um die erste Instanz eines bestimmten CSS-Selektors
zu finden. Durch Übergeben der Zeichenkette `"title"` erhalten wir das erste
`<title>`-Element im Dokument, wenn es eines gibt. Da möglicherweise kein
passendes Element vorhanden ist, gibt `select_first` eine `Option<ElementRef>`
zurück. Schließlich verwenden wir die Methode `Option::map`, die uns mit dem
Element in der `Option` arbeiten lässt, wenn es vorhanden ist, und nichts tut,
wenn es nicht vorhanden ist. (Wir könnten hier auch einen `match`-Ausdruck
verwenden, aber `map` ist idiomatischer.) Im Rumpf der Funktion, die wir an
`map` übergeben, rufen wir `inner_html` auf `title_element` auf, um dessen
Inhalt als `String` zu erhalten. Wenn alles erledigt ist, haben wir eine
`Option<String>`.

Beachte, dass das Rust-Schlüsselwort `await` _hinter_ dem Ausdruck steht, auf
den du wartest, nicht vor ihm. Das heißt, es ist ein _Postfix_-Schlüsselwort.
Dies mag sich von dem unterscheiden, was du vielleicht gewohnt bist, wenn du
async in anderen Sprachen verwendet hast. Rust hat sich dafür entschieden, weil
es die Arbeit mit Methodenketten viel angenehmer macht. Als Ergebnis können wir
den Rumpf von `page_url_for` ändern, um die Funktionsaufrufe `trpl::get` und
`text` mit `await` dazwischen zu verketten, wie in Codeblock 17-2 gezeigt.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# extern crate trpl;
#
# use trpl::Html;
#
# fn main() {
#     // TODO: Wir fügen dies als nächstes hinzu!
# }
#
# async fn page_title(url: &str) -> Option<String> {
    let response_text = trpl::get(url).await.text().await;
#     Html::parse(&response_text)
#         .select_first("title")
#         .map(|title_element| title_element.inner_html())
# }
```

<span class="caption">Codeblock 17-2: Verketten mit dem Schlüsselwort
`await`</span>

Damit haben wir erfolgreich unsere erste asynchrone Funktion geschrieben! Bevor
wir etwas Code in `main` schreiben, um sie aufzurufen, wollen wir uns ansehen,
was wir geschrieben haben und was es bedeutet.

Wenn Rust einen mit dem Schlüsselwort `async` markierten Block sieht,
kompiliert es ihn in einen eindeutigen, anonymen Datentyp, der das Merkmal
`Future` implementiert. Wenn Rust eine mit dem Schlüsselwort `async`
markierte Funktion sieht, kompiliert es sie zu einer nicht-asynchronen
Funktion, deren Rumpf ein asynchroner Block ist. Der Rückgabetyp einer
asynchronen Funktion ist der Typ des anonymen Datentyps, den der Compiler für
diesen asynchronen Block erstellt.

Die Angabe von `async fn` ist also gleichbedeutend mit dem Schreiben einer
Funktion, die ein _Future_ des Rückgabetyps zurückgibt. Für den Compiler ist
eine Funktionsdefinition wie `async fn page_title` in Codeblock 17-1
äquivalent zu einer nicht-asynchronen Funktion, die wie folgt definiert ist:

```rust
# extern crate trpl;
use std::future::Future;
use trpl::Html;

fn page_title(url: &str) -> impl Future<Output = Option<String>> {
    async move {
        let text = trpl::get(url).await.text().await;
        Html::parse(&text)
            .select_first("title")
            .map(|title| title.inner_html())
    }
}
```

Gehen wir die einzelnen Teile der umgewandelten Version durch:

- Sie verwendet die Syntax `impl Trait`, die wir bereits in [„Merkmale als
  Parameter verwenden“][impl-trait] in Kapitel 10 besprochen haben.
- Das zurückgegebene Merkmal ist ein `Future` mit dem assoziierten Typ von
  `Output`. Beachte, dass der `Output`-Typ `Option<String>` ist, was dem
  ursprünglichen Rückgabetyp der `async fn`-Version von `page_title`
  entspricht.
- Der gesamte im Rumpf der ursprünglichen Funktion wird in einen `async
  move`-Block eingepackt. Denke daran, dass Blöcke Ausdrücke sind. Dieser ganze
  Block ist der Ausdruck, der von der Funktion zurückgegeben wird.
- Dieser asynchrone Block erzeugt einen Wert vom Typ `Option<String>`, wie eben
  beschrieben. Dieser Wert entspricht dem Typ `Output` im Rückgabetyp. Dies ist
  genau wie bei anderen Blöcken, die du gesehen hast.
- Der neue Funktionsrumpf ist ein `async move`-Block, da er den Parameter `url`
  verwendet. (Wir werden mehr über `async` versus `async move` später in diesem
  Kapitel sprechen.)

Jetzt können wir `page_title` in `main` aufrufen.

## Bestimmen des Titels einer einzelnen Seite

Für den Anfang werden wir nur den Titel einer einzelnen Seite abrufen. In
Codeblock 17-3 folgen wir dem gleichen Muster, das wir zum Einlesen von
Kommandozeilenargumenten in [„Kommandozeilenargumente
entgegennehmen“][cli-args] in Kapitel 12 verwendet haben. Dann übergeben wir
die erste URL an `page_title` und warten das Ergebnis ab. Da der vom Future
erzeugte Wert ein `Option<String>` ist, verwenden wir einen `match`-Ausdruck,
um verschiedene Meldungen auszugeben, je nachdem ob die Seite einen `<title>`
hatte oder nicht.

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore,does_not_compile
# extern crate trpl;
#
# use trpl::Html;
#
async fn main() {
    let args: Vec<String> = std::env::args().collect();
    let url = &args[1];
    match page_title(url).await {
        Some(title) => println!("Der Titel von {url} ist {title}"),
        None => println!("{url} hat keinen Titel"),
    }
}
#
# async fn page_title(url: &str) -> Option<String> {
#     let response_text = trpl::get(url).await.text().await;
#     Html::parse(&response_text)
#         .select_first("title")
#         .map(|title_element| title_element.inner_html())
# }
```

<span class="caption">Codeblock 17-3: Aufruf der Funktion `page_title` aus
`main` mit einem vom Benutzer angegebenen Argument</span>

Leider lässt sich dieser Code nicht kompilieren. Der einzige Ort, an dem wir
das Schlüsselwort `await` verwenden können, ist in asynchronen Funktionen oder
Blöcken, und Rust lässt uns die spezielle Funktion `main` nicht als `async`
markieren.

```text
error[E0752]: `main` function is not allowed to be `async`
 --> src/main.rs:6:1
  |
6 | async fn main() {
  | ^^^^^^^^^^^^^^^ `main` function is not allowed to be `async`
```

Der Grund, warum `main` nicht mit `async` markiert werden kann, ist, dass
asynchroner Code eine _Laufzeitumgebung_ benötigt: eine Rust-Kiste, die die
Details der Ausführung von asynchronem Code verwaltet. Die Funktion `main`
eines Programms kann eine Laufzeitumgebung _initialisieren_, aber sie ist
nicht _selbst_ eine Laufzeitumgebung. (Warum das so ist, werden wir später
sehen.) Jedes Rust-Programm, das asynchronen Code ausführt, hat mindestens eine
Stelle, an der es eine Laufzeitumgebung einrichtet und die Futures ausführt.

Die meisten Sprachen, die asynchrone Programmierung unterstützen, enthalten
eine Laufzeitumgebung, Rust hat das nicht. Stattdessen gibt es viele
verschiedene asynchrone Laufzeitumgebungen, von denen jede für den jeweiligen
Anwendungsfall unterschiedliche Kompromisse eingeht. Ein Webserver mit hohem
Durchsatz, vielen CPU-Kernen und einer großen Menge an RAM hat zum Beispiel
ganz andere Anforderungen als einen Mikrocontroller mit einem einzigen Kern,
einer kleinen Menge an RAM und keiner Möglichkeit, Haldenspeicher-Allokationen
(heap allocations) durchzuführen. Die Kisten, die diese Laufzeitumgebungen
bereitstellen, bieten oft auch asynchrone Versionen gängiger Funktionen wie
Datei- oder Netzwerkkommunikation.

Hier und im Rest dieses Kapitels werden wir die Funktion `run` aus der Kiste
`trpl` verwenden, die ein Future als Argument annimmt und es bis zum Ende
ausführt. Hinter den Kulissen wird durch den Aufruf von `run` eine
Laufzeitumgebung eingerichtet, die das übergebene Future ausführt. Sobald das
Future abgeschlossen ist, gibt `run` den Wert zurück, den das Future erzeugt
hat.

Wir könnten das von `page_title` zurückgegebene Future direkt an `run`
übergeben. Sobald es abgeschlossen ist, könnten wir die resultierende
`Option<String>` abgleichen, so wie wir es in Codeblock 17-3 versucht haben.
Für die meisten Beispiele in diesem Kapitel (und den meisten asynchronen Code
in der realen Welt!) werden wir jedoch mehr als nur einen asynchronen
Funktionsaufruf durchführen, also übergeben wir stattdessen einen `async`-Block
und warten explizit auf das Ergebnis des Aufrufs von `page_title`, wie in
Codeblock 17-4.

<span class="filename">Dateiname: src/main.rs</span>

```rust,should_panic,noplayground
# extern crate trpl;
#
# use trpl::Html;
#
fn main() {
    let args: Vec<String> = std::env::args().collect();

    trpl::run(async {
        let url = &args[1];
        match page_title(url).await {
            Some(title) => println!("Der Titel von {url} ist {title}"),
            None => println!("{url} hat keinen Titel"),
        }
    })
}
#
# async fn page_title(url: &str) -> Option<String> {
#     let response_text = trpl::get(url).await.text().await;
#     Html::parse(&response_text)
#         .select_first("title")
#         .map(|title_element| title_element.inner_html())
# }
```

<span class="caption">Codeblock 17-4: Warten auf einen asynchronen Block mit
`trpl::run`</span>

Wenn wir diesen Code ausführen, erhalten wir das Verhalten, das wir anfangs
erwartet haben:

```console
$ cargo run -- https://www.rust-lang.org
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.05s
     Running `target/debug/async_await 'https://www.rust-lang.org'`
Der Titel von https://www.rust-lang.org ist
            Rust Programming Language
```

Puh &ndash; wir haben endlich funktionierenden asynchronen Code! Bevor wir aber
den Code hinzufügen, um zwei Webseiten gegeneinander antreten zu lassen, wollen
wir uns noch einmal kurz der Funktionsweise von Futures zuwenden.

Jede Codestelle mit dem Schlüsselwort `await` stellt einen Punkt dar, an dem
die Kontrolle an die Laufzeitumgebung abgegeben wird. Damit das funktioniert,
muss Rust den Zustand des asynchronen Blocks verwalten, sodass die
Laufzeitumgebung eine andere Arbeit starten und dann zurückkommen kann, wenn
er bereit ist, diese Arbeit wieder fortzusetzen. Dies ist eine unsichtbare
Zustandsmaschine, so als ob du eine Aufzählung auf diese Weise geschrieben
hättest, um den aktuellen Zustand an jedem `await`-Punkt zu speichern:

```rust
# extern crate trpl;
#
enum PageTitleFuture<'a> {
    Initial { url: &'a str },
    GetAwaitPoint { url: &'a str },
    TextAwaitPoint { response: trpl::Response },
}
```

Den Code für den Übergang zwischen den einzelnen Zuständen von Hand zu
schreiben, wäre allerdings mühsam und fehleranfällig, vor allem, wenn dem Code
später mehr Funktionalität und mehr Zustände hinzugefügt werden. Stattdessen
erstellt und verwaltet der Rust-Compiler die Zustandsmaschinen-Datenstrukturen
für asynchronen Code automatisch. Falls du dich wunderst: Ja, die normalen
Regeln für Ausleihen und die Eigentümerschaft von Datenstrukturen gelten auch
hier. Erfreulicherweise übernimmt der Compiler auch die Überprüfung dieser
Regeln für uns und gibt hilfreiche Fehlermeldungen aus. Ein paar davon werden
wir später im Kapitel durcharbeiten.

Letztendlich muss etwas diese Zustandsmaschine ausführen, und dieses Etwas ist
eine Laufzeitumgebung. (Aus diesem Grund wird auf _Executors_ verwiesen, wenn
man sich mit Laufzeitumgebungen befasst: Ein Executor ist der Teil einer
Laufzeitumgebung, der für die Ausführung des asynchronen Codes verantwortlich
ist.)

Jetzt kannst du sehen, warum uns der Compiler in Codeblock 17-3 davon
abgehalten hat, `main` selbst zu einer asynchronen Funktion zu machen. Wäre
`main` eine asynchrone Funktion, müsste etwas anderes den Zustandsautomaten für
das Future verwalten, das `main` zurückgibt, aber `main` ist der Startpunkt des
Programms! Stattdessen haben wir die Funktion `trpl::run` in `main` aufgerufen,
um eine Laufzeitumgebung einzurichten und das vom `async`-Block zurückgegebene
Future auszuführen, bis es fertig ist.

> Hinweis: Einige Laufzeitumgebungen stellen Makros zur Verfügung, mit denen du
> eine asynchrone Funktion `main` schreiben _kannst_. Diese Makros wandeln
> `async fn main() { ... }` in eine normale `fn main` um, die dasselbe tut, was
> wir in Codeblock 17-4 von Hand gemacht haben: Eine Funktion aufrufen, die ein
> Future zu Ende ausführt, so wie `trpl::run` es macht.

Fügen wir die Teile zusammen und sehen wir uns an, wie wir nebenläufigen Code
schreiben können.

### Unsere zwei URLs gegeneinander antreten lassen

In Codeblock 17-5 rufen wir `page_title` mit zwei verschiedenen URLs auf, die
von der Befehlszeile übergeben werden, und lassen sie um die Wette laufen.

<span class="filename">Dateiname: src/main.rs</span>

```rust,should_panic,noplayground
# extern crate trpl;
#
use trpl::{Either, Html};

fn main() {
    let args: Vec<String> = std::env::args().collect();

    trpl::run(async {
        let title_fut_1 = page_title(&args[1]);
        let title_fut_2 = page_title(&args[2]);

        let (url, maybe_title) =
            match trpl::race(title_fut_1, title_fut_2).await {
                Either::Left(left) => left,
                Either::Right(right) => right,
            };

        println!("{url} wurde zuerst zurückgegeben");
        match maybe_title {
            Some(title) => println!("Der Titel ist: '{title}'"),
            None => println!("Der Titel konnte nicht eingelesen werden."),
        }
    })
}

async fn page_title(url: &str) -> (&str, Option<String>) {
    let text = trpl::get(url).await.text().await;
    let title = Html::parse(&text)
        .select_first("title")
        .map(|title| title.inner_html());
    (url, title)
}
```

<span class="caption">Codeblock 17-5</span>

Wir beginnen mit dem Aufruf von `page_title` für jede der vom Benutzer
angegebenen URLs. Wir speichern die erhaltenen Futures als `title_fut_1` und
`title_fut_2`. Denke daran, dass diese noch nichts tun, denn Futures sind faul
und wir haben noch nicht auf sie gewartet. Dann übergeben wir die Futures an
`trpl::race`, das einen Wert zurückgibt, der anzeigt, welches der übergebenen
Futures zuerst fertig wurde.

> Anmerkung: Unter der Haube ist `race` auf der allgemeineren Funktion `select`
> aufgebaut, der du bei realem Rust-Codes häufiger begegnen wirst. Die Funktion
> `select` kann eine Menge Dinge tun, die die Funktion `trpl::race` nicht kann,
> aber sie bringt auch zusätzliche Komplexität mit sich, die wir für den Moment
> überspringen können.

Jedes Future kann legitimerweise „gewinnen“, also macht es keinen Sinn, ein
`Result` zurückzugeben. Stattdessen gibt `race` einen Typ zurück, den wir noch
nicht gesehen haben: `trpl::Either`. Der Typ `Either` ist einem `Result`
insofern ähnlich, als dass er zwei Fälle hat. Im Gegensatz zu `Result`
unterscheidet `Either` jedoch nicht zwischen Erfolg und Misserfolg.
Stattdessen werden `Left` und `Right` verwendet, um „das eine oder das andere“
anzuzeigen.

```rust
enum Either<A, B> {
    Left(A),
    Right(B),
}
```

Die Funktion `race` gibt `Left` mit der Ausgabe des ersten Futures zurück, wenn
das erste Argument zuerst fertig ist, und `Right` mit der Ausgabe des zweiten
Futures, wenn dieses zuerst fertig ist. Dies entspricht der Reihenfolge, in der
die Argumente beim Aufruf der Funktion angegeben wurden: Das erste Argument
steht links vom zweiten Argument.

Wir aktualisieren auch `page_title`, um die gleiche URL zurückzugeben, die wir
übergeben haben. Auf diese Weise können wir eine aussagekräftige Meldung
ausgeben, wenn die Seite, die zuerst zurückkommt, keinen `<title>` hat, den wir
auslesen können. Mit diesen Informationen aktualisieren wir die Ausgabe von
`println!`, um anzugeben, welche URL als erste beendet wurde und was der
`<title>` der Webseite hinter dieser URL war, sofern vorhanden.

Du hast jetzt einen kleinen funktionierenden Web Scraper erstellt! Wähle ein
paar URLs aus und führe das Befehlszeilenwerkzeug aus. Du wirst möglicherweise
feststellen, dass einige Webseiten stets schneller sind als andere, während in
anderen Fällen die schnellere Webseite von Ausführung zu Ausführung
unterschiedlich ist. Noch wichtiger ist, dass du die Grundlagen der Arbeit mit
Futures gelernt hast, sodass wir uns jetzt noch mehr mit den Dingen befassen
können, die wir mit asynchroner Programmierung tun können.

[cli-args]: ch12-01-accepting-command-line-arguments.html
[crate-source]: https://github.com/rust-lang/book/tree/main/packages/trpl
[futures-crate]: https://crates.io/crates/futures
[impl-trait]: ch10-02-traits.html#merkmale-als-parameter-verwenden
[iterators-lazy]: ch13-02-iterators.html
[thread-spawn]: ch16-01-threads.html#erstellen-eines-neuen-strangs-mit-spawn
[tokio]: https://tokio.rs
