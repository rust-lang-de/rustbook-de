## Einen einsträngigen (single-threaded) Webserver erstellen

Wir beginnen damit, einen einsträngigen Webserver zum Laufen zu bringen. Bevor
wir beginnen, wollen wir uns einen kurzen Überblick über die Protokolle
verschaffen, die beim Aufbau von Webservern eine Rolle spielen. Die
Einzelheiten dieser Protokolle sprengen den Rahmen dieses Buches, aber ein
kurzer Überblick wird dir die Informationen geben, die du benötigst.

Die beiden wichtigsten Protokolle, die bei Webservern zum Einsatz kommen, sind
das *Hypertext-Übertragungsprotokoll* (Hypertext Transfer Protocol, kurz
*HTTP*) und das *Übertragungssteuerungsprotokoll* (Transmission Control
Protocol, kurz *TCP*). Beide Protokolle sind *Anfrage-Antwort-Protokolle*, d.h.
ein *Client* initiiert Anfragen und ein *Server* hört auf die Anfragen und gibt
eine Antwort an den Client. Der Inhalt dieser Anfragen und Antworten wird durch
die Protokolle definiert.

TCP ist das Protokoll der untergeordneten Ebene, das im Detail beschreibt, wie
Informationen von einem Server zu einem anderen gelangen, aber nicht
spezifiziert, um welche Informationen es sich dabei handelt. HTTP baut auf TCP
auf, indem es den Inhalt der Anfragen und Antworten definiert. Es ist technisch
möglich, HTTP mit anderen Protokollen zu verwenden, aber in den allermeisten
Fällen sendet HTTP seine Daten über TCP. Wir werden mit den Roh-Bytes von TCP-
und HTTP-Anfragen und -Antworten arbeiten.

### Lauschen auf eine TCP-Verbindung

Unser Webserver muss auf eine TCP-Verbindung lauschen (listen), also ist das
der erste Teil, an dem wir arbeiten werden. Die Standardbibliothek bietet ein
Modul `std::net` an, mit dem wir dies tun können. Lass uns ein neues Projekt
auf die übliche Art und Weise erstellen:

```console
$ cargo new hello
     Created binary (application) `hello` project
$ cd hello
```

Gib nun den Code in Codeblock 20-1 in *src/main.rs* ein, um zu beginnen. Dieser
Code lauscht unter der lokalen Adresse `127.0.0.1:7878` auf eingehende
TCP-Ströme (TCP streams). Wenn er einen eingehenden Strom erhält, wird er
`Verbindung hergestellt!` ausgeben.

<span class="filename">Dateiname: src/main.rs</span>

```rust,no_run
use std::net::TcpListener;

fn main() {
    let listener = TcpListener::bind("127.0.0.1:7878").unwrap();

    for stream in listener.incoming() {
        let stream = stream.unwrap();

        println!("Verbindung hergestellt!");
    }
}
```

<span class="caption">Codeblock 20-1: Warten auf eingehende Ströme und Ausgeben
einer Nachricht, wenn wir einen Strom empfangen</span>

Mit `TcpListener` können wir unter der Adresse `127.0.0.1:7878` auf
TCP-Verbindungen warten. In der Adresse ist der Abschnitt vor dem Doppelpunkt
eine IP-Adresse, die deinen Computer repräsentiert (dies ist auf jedem Computer
gleich und gilt nicht nur speziell für den Computer der Autoren), und `7878`
ist der Port. Wir haben diesen Port aus zwei Gründen gewählt: HTTP wird auf
diesem Port normalerweise nicht akzeptiert, sodass unser Server wahrscheinlich
nicht mit anderen Webservern in Konflikt geraten wird, die du auf deinem
Rechner hast, und 7878 steht für *rust*, wenn du es auf einem Telefon tippst.

Die Funktion `bind` in diesem Szenario arbeitet wie die Funktion `new`, indem
sie eine neue `TcpListener`-Instanz zurückgibt. Die Funktion wird `bind`
genannt, weil in Netzwerken das Verbinden mit einem Port zum Lauschen als
„Binden (binding) an einen Port“ bezeichnet wird.

Die Funktion `bind` gibt ein `Result<T, E>` zurück, was anzeigt, dass es
möglich ist, dass das Binden fehlschlagen könnte. Zum Beispiel erfordert das
Binden an Port 80 Administrator-Rechte (Nicht-Administratoren können nur auf
Ports größer als 1023 lauschen). Wenn wir also versuchen würden, an Port 80 zu
lauschen, ohne Administrator zu sein, würde das Binden nicht funktionieren. Das
Binden wäre beispielsweise auch nicht möglich, wenn wir zwei Instanzen unseres
Programms laufen lassen und somit zwei Programme auf dem gleichen Port lauschen
würden. Da wir einen einfachen Server nur für Lernzwecke schreiben, werden wir
uns nicht um die Behandlung dieser Art von Fehlern kümmern; stattdessen
verwenden wir `unwrap`, um das Programm zu stoppen, wenn Fehler auftreten.

Die Methode `incoming` von `TcpListener` gibt einen Iterator zurück, der uns
eine Sequenz von Strömen (genauer gesagt Ströme vom Typ `TcpStream`) liefert.
Ein einzelner *Strom* (stream) stellt eine offene Verbindung zwischen dem
Client und dem Server dar. Eine *Verbindung* (connection) ist der Name für den
vollständigen Anfrage- und Antwortprozess, bei dem sich ein Client mit dem
Server verbindet, der Server eine Antwort erzeugt und der Server die Verbindung
schließt. Daher werden wir aus dem `TcpStream` lesen, um zu sehen, was der
Client gesendet hat, und dann unsere Antwort in den Strom schreiben, um Daten
zurück an den Client zu senden. Insgesamt wird diese `for`-Schleife jede
Verbindung der Reihe nach verarbeiten und eine Reihe von Strömen erzeugen, die
wir verarbeiten müssen.

Im Moment besteht unsere Behandlung des Stroms darin, dass wir `unwrap`
aufrufen, um unser Programm zu beenden, wenn der Strom Fehler aufweist; wenn
keine Fehler vorliegen, gibt das Programm eine Nachricht aus. Wir werden im
nächsten Codeblock mehr Funktionalität für den Erfolgsfall hinzufügen. Der
Grund, warum wir Fehler von der `incoming`-Methode erhalten könnten, wenn sich
ein Client mit dem Server verbindet, ist, dass wir nicht wirklich über
Verbindungen iterieren. Stattdessen iterieren wir über *Verbindungsversuche*.
Die Verbindung kann aus einer Reihe von Gründen nicht erfolgreich sein, viele
davon sind betriebssystemspezifisch. Zum Beispiel haben viele Betriebssysteme
ein Limit für die Anzahl der gleichzeitig offenen Verbindungen, die sie
unterstützen können; neue Verbindungsversuche über diese Anzahl hinaus führen
zu einem Fehler, bis einige der offenen Verbindungen geschlossen werden.

Lass uns versuchen, diesen Code auszuführen! Rufe `cargo run` im Terminal auf
und öffne dann *127.0.0.1:7878* in einem Web-Browser. Der Browser sollte eine
Fehlermeldung wie „Verbindung abgebrochen“ anzeigen, da der Server derzeit
keine Daten zurücksendet. Aber wenn du auf dein Terminal siehst, solltest du
mehrere Meldungen sehen, die ausgegeben wurden, als der Browser eine Verbindung
mit dem Server herstellte!

```text
     Running `target/debug/hello`
Verbindung hergestellt!
Verbindung hergestellt!
Verbindung hergestellt!
```

Manchmal werden mehrere Nachrichten für eine Browser-Anfrage ausgegeben; der
Grund dafür könnte sein, dass der Browser sowohl eine Anfrage für die Seite als
auch eine Anfrage für andere Ressourcen stellt, z.B. das Symbol *favicon.ico*,
das in der Browser-Registerkarte erscheint.

Es könnte auch sein, dass der Browser mehrmals versucht, eine Verbindung mit
dem Server herzustellen, weil der Server nicht mit Daten antwortet. Wenn
`stream` den Gültigkeitsbereich verlässt und am Ende der Schleife aufgeräumt
wird, wird die Verbindung als Teil der `drop`-Implementierung geschlossen.
Browser reagieren auf geschlossene Verbindungen manchmal damit, es erneut zu
versuchen, weil das Problem möglicherweise nur vorübergehend ist. Der wichtige
Punkt ist, dass wir erfolgreich eine TCP-Verbindung hergestellt haben!

Denke daran, das Programm durch Drücken von <span
class="keystroke">Strg+c</span> zu beenden, wenn du mit der Ausführung einer
bestimmten Version des Codes fertig bist. Starte dann das Programm neu, indem
du den Befehl `cargo run` aufrufst, nachdem du die einzelnen Codeänderungen
vorgenommen hast, um sicherzustellen, dass du den neuesten Code ausführst.

### Lesen der Anfrage

Lass uns die Funktionalität zum Lesen der Anfrage vom Browser implementieren!
Um die Zuständigkeiten zu trennen, also zuerst eine Verbindung entgegenzunehmen
und dann mit der Verbindung etwas zu machen, werden wir eine neue Funktion zur
Verarbeitung von Verbindungen anfangen. In dieser neuen Funktion
`handle_connection` lesen wir Daten aus dem TCP-Strom und geben sie aus, sodass
wir sehen können, welche Daten vom Browser gesendet werden. Ändere den Code so,
dass er wie Codeblock 20-2 aussieht.

<span class="filename">Dateiname: src/main.rs</span>

```rust,no_run
use std::{
    io::{prelude::*, BufReader},
    net::{TcpListener, TcpStream},
};

fn main() {
    let listener = TcpListener::bind("127.0.0.1:7878").unwrap();

    for stream in listener.incoming() {
        let stream = stream.unwrap();

        handle_connection(stream);
    }
}

fn handle_connection(mut stream: TcpStream) {
    let buf_reader = BufReader::new(&mut stream);
    let http_request: Vec<_> = buf_reader
        .lines()
        .map(|result| result.unwrap())
        .take_while(|line| !line.is_empty())
        .collect();

    println!("Request: {:#?}", http_request);
}
```

<span class="caption">Codeblock 20-2: Lesen aus dem `TcpStream` und Ausgeben
der Daten</span>

Wir bringen `std::io::prelude` und `std::io::BufReader` in den
Gültigkeitsbereich, um Zugang zu Merkmalen (traits) und Typen zu erhalten, die
es uns ermöglichen, aus dem Strom zu lesen und in den Strom zu schreiben. In
der `for`-Schleife in der Funktion `main` rufen wir jetzt, statt eine Nachricht
auszugeben, dass wir eine Verbindung hergestellt haben, die neue Funktion
`handle_connection` auf und übergeben ihr den `stream`.

In der Funktion `handle_connection` erstellen wir eine neue
`BufReader`-Instanz, die eine veränderbare Referenz auf den `stream` enthält.
`BufReader` sorgt für die Pufferung, indem es die Aufrufe der Merkmals-Methoden
von `std::io::Read` für uns verwaltet.

Wir erstellen eine Variable namens `http_request`, um die Zeilen der Anfrage zu
aufzusammeln, die der Browser an unseren Server sendet. Wir geben an, dass wir
diese Zeilen in einem Vektor sammeln wollen, indem wir die Typ-Annotation
`Vec<_>` hinzufügen.

`BufReader` implementiert das Merkmal `std::io::BufRead`, das die Methode
`lines` bereitstellt. Die Methode `lines` gibt einen Iterator von
`Result<String, std::io::Error>` zurück, indem sie den Datenstrom immer dann
aufteilt, wenn sie ein Neue-Zeile-Byte sieht. Um jeden `String` zu erhalten,
wird jedes `Result` abgebildet und `unwrap` aufgerufen. Das `Result` könnte
einen Fehler darstellen, wenn die Daten kein gültiges UTF-8 sind oder wenn es
ein Problem beim Lesen aus dem Strom gab. Auch hier sollte ein
Produktivprogramm diese Fehler besser behandeln, aber der Einfachheit halber
brechen wir das Programm im Fehlerfall ab.

Der Browser signalisiert das Ende einer HTTP-Anfrage, indem er zwei
Zeilenumbrüche hintereinander sendet. Um also eine Anfrage aus dem Strom zu
erhalten, nehmen wir so lange Zeilen an, bis wir eine leere Zeile erhalten.
Sobald wir die Zeilen im Vektor gesammelt haben, geben wir sie mit einer
hübschen Debug-Formatierung aus, damit wir einen Blick auf die Anweisungen
werfen können, die der Webbrowser an unseren Server sendet.

Lass uns diesen Code ausprobieren! Starte das Programm und stelle erneut eine
Anfrage in einem Webbrowser. Beachte, dass wir immer noch eine Fehlerseite im
Browser erhalten, aber die Ausgabe unseres Programms im Terminal wird nun
ähnlich aussehen:

```console
$ cargo run
   Compiling hello v0.1.0 (file:///projects/hello)
    Finished dev [unoptimized + debuginfo] target(s) in 0.42s
     Running `target/debug/hello`
Request: [
    "GET / HTTP/1.1",
    "Host: 127.0.0.1:7878",
    "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:99.0) Gecko/20100101 Firefox/99.0",
    "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
    "Accept-Language: en-US,en;q=0.5",
    "Accept-Encoding: gzip, deflate, br",
    "DNT: 1",
    "Connection: keep-alive",
    "Upgrade-Insecure-Requests: 1",
    "Sec-Fetch-Dest: document",
    "Sec-Fetch-Mode: navigate",
    "Sec-Fetch-Site: none",
    "Sec-Fetch-User: ?1",
    "Cache-Control: max-age=0",
]
```

Je nach Browser erhältst du möglicherweise eine etwas andere Ausgabe. Jetzt, wo
wir die Anfragedaten ausgeben, können wir sehen, warum wir mehrere Verbindungen
von einer Browser-Anfrage erhalten, wenn wir uns den Pfad nach `GET` in der
ersten Zeile der Anfrage ansehen. Wenn die wiederholten Verbindungen alle `/`
anfordern, wissen wir, dass der Browser wiederholt versucht, `/` abzurufen,
weil er keine Antwort von unserem Programm erhält.

Lass uns diese Anfragedaten aufschlüsseln, um zu verstehen, was der Browser von
unserem Programm will.

### Ein genauerer Blick auf eine HTTP-Anfrage

HTTP ist ein textbasiertes Protokoll und eine Anfrage hat dieses Format an:

```text
Method Request-URI HTTP-Version CRLF
headers CRLF
message-body
```

Die erste Zeile ist die *Anfragezeile* (request line), die Informationen
darüber enthält, was der Client anfragt. Der erste Teil der Anfragezeile gibt
die *Methode* an, die verwendet wird, z.B. `GET` oder `POST`, die beschreibt,
wie der Client diese Anfrage stellt. Unser Client benutzte eine `GET`-Anfrage,
was bedeutet, dass er nach Informationen fragt.

Der nächste Teil der Anfragezeile ist `/`, der den *einheitlichen
Ressourcenbezeichner* (Uniform Resource Identifier, kurz *URI*) angibt, den der
Client anfragt: Ein URI ist fast, aber nicht ganz dasselbe wie ein
*einheitlicher Ressourcenzeiger* (Uniform Resource Locator, kurz *URL*). Der
Unterschied zwischen URIs und URLs ist für unsere Zwecke in diesem Kapitel
nicht wichtig, aber die HTTP-Spezifikation verwendet den Begriff URI, sodass
wir hier einfach gedanklich URL durch URI ersetzen können.

Der letzte Teil ist die HTTP-Version, die der Client verwendet, und dann endet
die Anfragezeile mit einer *CRLF-Sequenz*. (CRLF steht für *carriage return*
(Wagenrücklauf) und *line feed* (Zeilenvorschub), das sind Begriffe aus der
Schreibmaschinenzeit!) Die CRLF-Sequenz kann auch als `\r\n` geschrieben
werden, wobei `\r` ein Wagenrücklauf und `\n` ein Zeilenvorschub ist. Die
CRLF-Sequenz trennt die Anfragezeile von den restlichen Anfragedaten. Beachte,
dass wir beim Ausgeben von CRLF eine neue Zeile sehen und nicht `\r\n`.

Wenn wir uns die Daten der Anfragezeile ansehen, die wir bisher beim Ausführen
unseres Programms erhalten haben, sehen wir, dass `GET` die Methode, `/` die
Anfrage-URI und `HTTP/1.1` die Version ist.

Nach der Anfragezeile sind die restlichen Zeilen ab `Host:` Kopfzeilen.
`GET`-Anfragen haben keinen Rumpf (body).

Versuche, eine Anfrage von einem anderen Browser aus zu stellen oder nach einer
anderen Adresse zu fragen, z.B. *127.0.0.1:7878/test*, um zu sehen, wie sich
die Anfragedaten ändern.

Jetzt, da wir wissen, was der Browser anfragt, schicken wir ein paar Daten
zurück!

### Schreiben einer Antwort

Wir implementieren das Senden von Daten als Antwort auf eine Clientanfrage. Die
Antworten haben das folgende Format:

```text
HTTP-Version Status-Code Reason-Phrase CRLF
headers CRLF
message-body
```

Die erste Zeile ist eine *Statuszeile*, die die in der Antwort verwendete
HTTP-Version, einen numerischen Statuscode, der das Ergebnis der Anfrage
zusammenfasst, und eine Begründungsphrase, die eine Textbeschreibung des
Statuscodes liefert, enthält. Nach der CRLF-Sequenz folgen beliebige
Kopfzeilen, eine weitere CRLF-Sequenz und der Rumpf der Antwort.

Hier ist eine Beispielantwort, die HTTP-Version 1.1 verwendet, den Statuscode
200, eine OK-Begründungsphrase, keine Kopfzeilen und keinen Rumpf hat:

```text
HTTP/1.1 200 OK\r\n\r\n
```

Der Statuscode 200 ist die Standard-Erfolgsantwort. Der Text ist eine winzige
erfolgreiche HTTP-Antwort. Lass uns dies als Antwort auf eine erfolgreiche
Anfrage in den Strom schreiben! Entferne aus der Funktion `handle_connection`
das `println!`, das die Anfragedaten ausgegeben hat, und ersetze es durch den
Code in Codeblock 20-3.

<span class="filename">Dateiname: src/main.rs</span>

```rust,no_run
# use std::io::prelude::*;
# use std::net::TcpListener;
# use std::net::TcpStream;
#
# fn main() {
#     let listener = TcpListener::bind("127.0.0.1:7878").unwrap();
#
#     for stream in listener.incoming() {
#         let stream = stream.unwrap();
#
#         handle_connection(stream);
#     }
# }
#
fn handle_connection(mut stream: TcpStream) {
    let mut buffer = [0; 1024];

    stream.read(&mut buffer).unwrap();

    let response = "HTTP/1.1 200 OK\r\n\r\n";

    stream.write(response.as_bytes()).unwrap();
    stream.flush().unwrap();
}
```

<span class="caption">Codeblock 20-3: Schreiben einer kleinen erfolgreichen
HTTP-Antwort in den Strom</span>

Die erste neue Zeile definiert die Variable `response`, die die Daten der
Erfolgsmeldung enthält. Dann rufen wir `as_bytes` auf unserer `response` auf,
um die Zeichenkettendaten in Bytes zu konvertieren. Die Methode `write_all` auf
`stream` nimmt ein `&[u8]` und sendet diese Bytes direkt in die Verbindung. Da
die Operation `write_all` fehlschlagen könnte, verwenden wir wie bisher bei
jedem Fehlerergebnis `unwrap` . Auch hier würdest du in einer echten Anwendung
eine Fehlerbehandlung hinzufügen.

Lass uns mit diesen Änderungen unseren Code ausführen und eine Anfrage stellen.
Wir geben keine Daten mehr im Terminal aus, sodass wir außer der Ausgabe von
Cargo keine weiteren Ausgaben sehen werden. Wenn du *127.0.0.1:7878* in einem
Webbrowser lädst, solltest du statt eines Fehlers eine leere Seite sehen. Du
hast soeben das Empfangen einer HTTP-Anfrage und das Senden einer Antwort von
Hand programmiert!

### Echtes HTML zurückgeben

Lass uns die Funktionalität für die Rückgabe von mehr als einer leeren Seite
implementieren. Erstelle die neue Datei *hello.html* in der Wurzel deines
Projektverzeichnisses, nicht im Verzeichnis *src*. Du kannst beliebiges HTML
eingeben, das du willst; Codeblock 20-4 zeigt eine Möglichkeit.

<span class="filename">Dateiname: hello.html</span>

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Hallo!</title>
  </head>
  <body>
    <h1>Hallo!</h1>
    <p>Hallo von Rust</p>
  </body>
</html>
```

<span class="caption">Codeblock 20-4: Eine Beispiel-HTML-Datei, die in einer
Antwort zurückgegeben werden soll</span>

Dies ist ein minimales HTML5-Dokument mit einer Überschrift und etwas Text. Um
dies vom Server zurückzugeben, wenn eine Anfrage empfangen wird, modifizieren
wir `handle_connection` wie in Codeblock 20-5 gezeigt, um die HTML-Datei zu
lesen, sie der Antwort als Rumpf hinzuzufügen und sie zu senden.

<span class="filename">Dateiname: src/main.rs</span>

```rust,no_run
use std::{
    fs,
    io::{prelude::*, BufReader},
    net::{TcpListener, TcpStream},
};
// --abschneiden--

# fn main() {
#     let listener = TcpListener::bind("127.0.0.1:7878").unwrap();
#
#     for stream in listener.incoming() {
#         let stream = stream.unwrap();
#
#         handle_connection(stream);
#     }
# }
#
fn handle_connection(mut stream: TcpStream) {
    let buf_reader = BufReader::new(&mut stream);
    let http_request: Vec<_> = buf_reader
        .lines()
        .map(|result| result.unwrap())
        .take_while(|line| !line.is_empty())
        .collect();

    let status_line = "HTTP/1.1 200 OK";
    let contents = fs::read_to_string("hello.html").unwrap();
    let length = contents.len();

    let response =
        format!("{status_line}\r\nContent-Length: {length}\r\n\r\n{contents}");

    stream.write_all(response.as_bytes()).unwrap();
}
```

<span class="caption">Codeblock 20-5: Senden des Inhalts von *hello.html* als
Rumpf der Antwort</span>

Wir haben `fs` zur `use`-Deklaration hinzugefügt, um das Dateisystemmodul der
Standardbibliothek in den Gültigkeitsbereich zu bringen. Der Code zum Lesen des
Inhalts einer Datei in eine Zeichenkette sollte vertraut aussehen; wir haben
ihn in Kapitel 12 verwendet, als wir den Inhalt einer Datei für unser
E/A-Projekt in Codeblock 12-4 gelesen haben.

Als Nächstes verwenden wir `format!`, um den Inhalt der Datei als Rumpf der
Erfolgsantwort hinzuzufügen. Um eine gültige HTTP-Antwort zu gewährleisten,
fügen wir den Header `Content-Length` hinzu, der auf die Größe unseres
Antwortrumpfs gesetzt wird, in diesem Fall auf die Größe von `hello.html`. 

Führe diesen Code mit `cargo run` aus und lade *127.0.0.1:7878* im Browser; du
solltest dein HTML gerendert sehen!

Gegenwärtig ignorieren wir die Anfragedaten in `http_request` und senden
einfach den Inhalt der HTML-Datei bedingungslos zurück. Das heißt, wenn du
versuchst, *127.0.0.1:7878/something-else* in deinem Browser anzufragen,
erhältst du immer noch dieselbe HTML-Antwort zurück. Unser Server ist im Moment
sehr begrenzt und macht nicht das, was die meisten Webserver tun. Wir wollen
unsere Antworten je nach Anfrage anpassen und nur die HTML-Datei für eine
wohlgeformte Anfrage an `/` zurücksenden.

### Validieren der Anfrage und selektives Beantworten

Im Moment wird unser Webserver das HTML in der Datei zurückgeben, unabhängig
davon, was der Client angefragt hat. Fügen wir Funktionen hinzu, um zu
überprüfen, ob der Browser `/` anfragt, bevor er die HTML-Datei zurückgibt, und
um einen Fehler zurückzugeben, wenn der Browser etwas anderes anfragt. Dazu
müssen wir `handle_connection` modifizieren, wie in Codeblock 20-6 gezeigt.
Dieser neue Code prüft den Inhalt der erhaltenen Anfrage, ob `/` angefragt
wird, und fügt `if`- und `else`-Blöcke hinzu, um die Anfragen unterschiedlich
zu behandeln.

<span class="filename">Dateiname: src/main.rs</span>

```rust,no_run
# use std::{
#     fs,
#     io::{prelude::*, BufReader},
#     net::{TcpListener, TcpStream},
# };
#
# fn main() {
#     let listener = TcpListener::bind("127.0.0.1:7878").unwrap();
#
#     for stream in listener.incoming() {
#         let stream = stream.unwrap();
#
#         handle_connection(stream);
#     }
# }
#
// --abschneiden--

fn handle_connection(mut stream: TcpStream) {
    let buf_reader = BufReader::new(&mut stream);
    let request_line = buf_reader.lines().next().unwrap().unwrap();

    if request_line == "GET / HTTP/1.1" {
        let status_line = "HTTP/1.1 200 OK";
        let contents = fs::read_to_string("hello.html").unwrap();
        let length = contents.len();

        let response = format!(
            "{status_line}\r\nContent-Length: {length}\r\n\r\n{contents}"
        );

        stream.write_all(response.as_bytes()).unwrap();
    } else {
        // eine andere Anfrage
    }
}
```

<span class="caption">Codeblock 20-6: Behandlung von Anfragen an `/` anders als
andere Anfragen</span>

Wir werden uns nur die erste Zeile der HTTP-Anfrage ansehen. Anstatt also die
gesamte Anfrage in einen Vektor zu lesen, rufen wir `next` auf, um das erste
Element aus dem Iterator zu erhalten. Das erste `unwrap` kümmert sich um die
`Option` und hält das Programm an, wenn der Iterator keine Elemente hat. Das
zweite `unwrap` behandelt das `Result` und hat den gleichen Effekt wie das
`unwrap` in  `map` in Codeblock 20-2.

Als nächstes überprüfen wir `request_line`, um zu sehen, ob es der Anfragezeile
einer GET-Anfrage mit dem Pfad `/` entspricht. Ist dies der Fall, gibt der
`if`-Block den Inhalt unserer HTML-Datei zurück.

Wenn `request_line` *nicht* der GET-Anfrage mit dem `/` Pfad entspricht,
bedeutet das, dass wir eine andere Anfrage erhalten haben. Wir werden dem
`else`-Block gleich Code hinzufügen, um auf alle anderen Anfragen zu reagieren.

Führe diesen Code jetzt aus und frage *127.0.0.1:7878* an; du solltest das HTML
in *hello.html* erhalten. Wenn du eine andere Anfrage stellst, z.B.
*127.0.0.1:7878/something-else*, erhältst du einen Verbindungsfehler, wie du
ihn beim Ausführen des Codes in Codeblock 20-1 und Codeblock 20-2 gesehen hast.

Fügen wir nun den Code in Codeblock 20-7 in den `else`-Block ein, um eine
Antwort mit dem Statuscode 404 zurückzugeben, der signalisiert, dass der Inhalt
für die Anfrage nicht gefunden wurde. Wir geben auch etwas HTML für eine Seite
zurück, die im Browser dargestellt werden soll, um dem Endbenutzer die Antwort
anzuzeigen.

<span class="filename">Dateiname: src/main.rs</span>

```rust,no_run
# use std::{
#     fs,
#     io::{prelude::*, BufReader},
#     net::{TcpListener, TcpStream},
# };
#
# fn main() {
#     let listener = TcpListener::bind("127.0.0.1:7878").unwrap();
#
#     for stream in listener.incoming() {
#         let stream = stream.unwrap();
#
#         handle_connection(stream);
#     }
# }
#
# fn handle_connection(mut stream: TcpStream) {
#     let buf_reader = BufReader::new(&mut stream);
#     let request_line = buf_reader.lines().next().unwrap().unwrap();
#
#     if request_line == "GET / HTTP/1.1" {
#         let status_line = "HTTP/1.1 200 OK";
#         let contents = fs::read_to_string("hello.html").unwrap();
#         let length = contents.len();
#
#         let response = format!(
#             "{status_line}\r\nContent-Length: {length}\r\n\r\n{contents}"
#         );
#
#         stream.write_all(response.as_bytes()).unwrap();
    // --abschneiden--
    } else {
        let status_line = "HTTP/1.1 404 NOT FOUND";
        let contents = fs::read_to_string("404.html").unwrap();
        let length = contents.len();

        let response = format!(
            "{status_line}\r\nContent-Length: {length}\r\n\r\n{contents}"
        );

        stream.write_all(response.as_bytes()).unwrap();
    }
# }
```

<span class="caption">Codeblock 20-7: Antworten mit Statuscode 404 und einer
Fehlerseite, wenn etwas anderes als `/` angefragt wurde</span>

Hier hat unsere Antwort eine Statuszeile mit Statuscode 404 und der
Begründungsphrase `NOT FOUND` (nicht gefunden). Der Rumpf der Antwort wird das
HTML in der Datei *404.html* sein. Du musst neben *hallo.html* eine Datei
*404.html* für die Fehlerseite erstellen; auch hier kannst du jedes beliebige
HTML verwenden oder das Beispiel-HTML in Codeblock 20-8.

<span class="filename">Dateiname: 404.html</span>

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Hallo!</title>
  </head>
  <body>
    <h1>Ups!</h1>
    <p>Entschuldige, ich weiß nicht wonach du gefragt hast.</p>
  </body>
</html>
```

<span class="caption">Codeblock 20-8: Beispielinhalt für die Seite, die mit
jeder 404-Antwort zurückgesendet werden soll</span>

Lass deinen Server mit diesen Änderungen erneut laufen. Die Anfrage
*127.0.0.1:7878* sollte den Inhalt von *hallo.html* zurückgeben und jede andere
Anfrage, wie *127.0.0.1:7878/foo*, sollte das Fehler-HTML von *404.html*
zurückgeben.

### Ein Hauch von Refaktorierung

Im Moment haben die `if`- und `else`-Blöcke eine Menge Wiederholungen: Sie
lesen beide Dateien und schreiben den Inhalt der Dateien in den Strom. Die
einzigen Unterschiede sind die Statuszeile und der Dateiname. Lass uns den Code
prägnanter gestalten, indem wir diese Unterschiede in separate `if`- und
`else`-Zeilen herausziehen, die die Werte der Statuszeile und des Dateinamens
Variablen zuweisen; wir können diese Variablen dann bedingungslos im Code
verwenden, um die Datei zu lesen und die Antwort zu schreiben. Codeblock 20-9
zeigt den resultierenden Code nach dem Ersetzen der großen `if`- und
`else`-Blöcke.

<span class="filename">Dateiname: src/main.rs</span>

```rust,no_run
# use std::{
#     fs,
#     io::{prelude::*, BufReader},
#     net::{TcpListener, TcpStream},
# };
#
# fn main() {
#     let listener = TcpListener::bind("127.0.0.1:7878").unwrap();
#
#     for stream in listener.incoming() {
#         let stream = stream.unwrap();
#
#         handle_connection(stream);
#     }
# }
#
// --abschneiden--

fn handle_connection(mut stream: TcpStream) {
    // --abschneiden--

#     let buf_reader = BufReader::new(&mut stream);
#     let request_line = buf_reader.lines().next().unwrap().unwrap();
#
    let (status_line, filename) = if request_line == "GET / HTTP/1.1" {
        ("HTTP/1.1 200 OK", "hello.html")
    } else {
        ("HTTP/1.1 404 NOT FOUND", "404.html")
    };

    let contents = fs::read_to_string(filename).unwrap();
    let length = contents.len();

    let response =
        format!("{status_line}\r\nContent-Length: {length}\r\n\r\n{contents}");

    stream.write_all(response.as_bytes()).unwrap();
}
```

<span class="caption">Codeblock 20-9: Refaktorieren der `if`- und
`else`-Blöcke, sodass sie nur den Code enthalten, der sich zwischen den beiden
Fällen unterscheidet</span>

Die Blöcke `if` und `else` geben jetzt nur noch die entsprechenden Werte für
die Statuszeile und den Dateinamen in einem Tupel zurück; wir verwenden dann
die Destrukturierung, um diese beiden Werte den Variablen `status_line` und
`filename` zuzuweisen, unter Verwendung eines Musters in der `let`-Anweisung,
wie in Kapitel 18 besprochen.

Der zuvor duplizierte Code befindet sich jetzt außerhalb der Blöcke `if` und
`else` und verwendet die Variablen `status_line` und `filename`. Dies macht es
einfacher, den Unterschied zwischen den beiden Fällen zu erkennen, und es
bedeutet, dass wir nur einen Ort haben, an dem wir den Code aktualisieren
müssen, wenn wir ändern wollen, wie das Lesen der Datei und das Schreiben der
Antwort funktionieren. Das Verhalten des Codes in Codeblock 20-9 ist dasselbe
wie in Codeblock 20-8.

Fantastisch! Wir haben jetzt einen einfachen Webserver mit etwa 40 Zeilen
Rust-Code, der auf eine Anfrage mit einer Inhaltsseite antwortet und auf alle
anderen Anfragen mit einer 404-Antwort.

Derzeit läuft unser Server in einem einzigen Strang (thread), d.h. er kann
immer nur eine Anfrage gleichzeitig bedienen. Lass uns untersuchen, warum das
ein Problem sein kann, indem wir einige langsame Anfragen simulieren. Dann
werden wir es beheben, indem unser Server mehrere Anfragen auf einmal
bearbeiten kann.
