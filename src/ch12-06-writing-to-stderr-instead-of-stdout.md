## Fehler zur Standardfehlerausgabe umleiten

Im Moment schreiben wir unsere gesamte Ausgabe mit dem Makro `println!` auf das
Terminal. In den meisten Terminals gibt es zwei Arten von Ausgaben:
Die _Standardausgabe_ (`stdout`) für allgemeine Informationen und die
_Standardfehlerausgabe_ (`stderr`) für Fehlermeldungen. Diese Unterscheidung
ermöglicht es dem Benutzer, die erfolgreiche Ausgabe eines Programms in eine
Datei zu leiten, aber dennoch Fehlermeldungen auf dem Bildschirm auszugeben.

Das Makro `println!` ist nur in der Lage, auf die Standardausgabe zu schreiben,
also müssen wir etwas anderes verwenden, um auf die Standardfehlerausgabe zu
schreiben.

### Prüfen, wo Fehler ausgegeben werden

Lass uns zunächst beobachten, wie der von `minigrep` ausgegebene Inhalt derzeit
in die Standardausgabe geschrieben wird, einschließlich aller Fehlermeldungen,
die wir stattdessen in die Standardfehlerausgabe schreiben wollen. Wir tun
dies, indem wir die Standardausgabe in eine Datei umleiten und dabei
absichtlich einen Fehler verursachen. Wir werden die Standardfehlerausgabe
nicht umleiten, sodass alle Inhalte, die an die Standardfehlerausgabe gesendet
werden, weiterhin auf dem Bildschirm angezeigt werden.

Von Kommandozeilenprogrammen wird erwartet, dass sie Fehlermeldungen an die
Standardfehlerausgabe senden, sodass wir Fehlermeldungen auch dann noch auf dem
Bildschirm sehen können, wenn wir die Standardausgabe in eine Datei umleiten.
Unser Programm ist zur Zeit nicht sehr brav: Wir werden gleich sehen, dass es
die ausgegebenen Fehlermeldungen stattdessen in eine Datei speichert!

Der Weg, dieses Verhalten zu demonstrieren, besteht darin, das Programm mit `>`
und dem Dateipfad _output.txt_ laufen zu lassen, zu dem wir die
Standardausgabe umleiten wollen. Wir werden keine Argumente übergeben, was
einen Fehler verursachen sollte:

```console
$ cargo run > output.txt
```

Die Syntax `>` weist die Shell an, den Inhalt der Standardausgabe anstelle des
Bildschirms in _output.txt_ zu schreiben. Wir haben die erwartete Fehlermeldung
nicht gesehen, die auf den Bildschirm ausgegeben werden sollte, also muss sie
in der Datei gelandet sein. Dies ist der Inhalt von _output.txt_:

```text
Fehler beim Parsen der Argumente: Nicht genügend Argumente
```

Ja, unsere Fehlermeldung wird in die Standardausgabe geschrieben. Es ist viel
nützlicher, wenn Fehlermeldungen wie diese auf der Standardfehlerausgabe
ausgegeben werden, sodass nur Daten aus einem erfolgreichen Lauf in der Datei
landen. Das werden wir ändern.

### Fehler auf der Standardfehlerausgabe ausgeben

Wir werden den Code in Codeblock 12-24 verwenden, um zu ändern, wie
Fehlermeldungen ausgegeben werden. Aufgrund der Refaktorierung, die wir früher
in diesem Kapitel vorgenommen haben, befindet sich der gesamte Code, der
Fehlermeldungen ausgibt, in einer einzigen Funktion, nämlich der Funktion
`main`. Die Standardbibliothek stellt das Makro `eprintln!` zur Verfügung, das
in die Standardfehlerausgabe schreibt. Lass uns also die beiden Stellen, an
denen wir `println!` aufgerufen haben, um Fehler auszugeben, ändern und
stattdessen `eprintln!` verwenden.

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore
# use std::env;
# use std::process;
#
# use minigrep::Config;
#
fn main() {
    let args: Vec<String> = env::args().collect();

    let config = Config::build(&args).unwrap_or_else(|err| {
        eprintln!("Fehler beim Parsen der Argumente: {err}");
        process::exit(1);
    });

    if let Err(e) = minigrep::run(config) {
        eprintln!("Anwendungsfehler: {e}");
        process::exit(1);
    }
}
```

<span class="caption">Codeblock 12-24: Schreiben von Fehlermeldungen auf die
Standardfehlerausgabe anstelle der Standardausgabe durch Verwenden von
`eprintln!`</span>

Lassen wir das Programm nun auf die gleiche Art und Weise erneut laufen, ohne
Argumente und mit Umleitung der Standardausgabe mit `>`:

```console
$ cargo run > output.txt
Fehler beim Parsen der Argumente: Nicht genügend Argumente
```

Jetzt sehen wir den Fehler auf dem Bildschirm und _output.txt_ enthält nichts,
was dem Verhalten entspricht, das wir von Kommandozeilenprogrammen erwarten.

Lassen wir das Programm erneut mit Argumenten laufen, die keinen Fehler
verursachen, aber dennoch die Standardausgabe in eine Datei umleiten, etwa so:

```console
$ cargo run -- to poem.txt > output.txt
```

Wir werden keine Ausgabe auf dem Terminal sehen und _output.txt_ wird unsere
Ergebnisse enthalten:

<span class="filename">Dateiname: output.txt</span>

```text
Are you nobody, too?
How dreary to be somebody!
```

Dies zeigt, dass wir jetzt die Standardausgabe für die erfolgreiche Ausgabe und
gegebenenfalls die Standardfehlerausgabe für die Fehlerausgabe verwenden.

## Zusammenfassung

Dieses Kapitel rekapituliert einige der wichtigsten Konzepte, die du bisher
gelernt hast, und behandelt das Durchführen gängiger E/A-Operationen in Rust.
Durch das Verwenden von Kommandozeilenargumenten, Dateien, Umgebungsvariablen
und des Makros `eprintln!` für die Fehlerausgabe bist du jetzt bereit,
Kommandozeilenanwendungen zu schreiben. Wenn du die Konzepte mit denen in den
vorhergehenden Kapiteln kombinierst, wird dein Code gut organisiert sein, Daten
effektiv in den entsprechenden Datenstrukturen speichern, Fehler gut behandeln
und gut getestet sein.

Als Nächstes werden wir einige Rust-Funktionalitäten untersuchen, die von
funktionalen Sprachen beeinflusst wurden: Funktionsabschlüsse (closures) und
Iteratoren.
