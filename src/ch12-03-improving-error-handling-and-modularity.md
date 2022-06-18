## Refaktorierung um die Modularität und Fehlerbehandlung zu verbessern

Um unser Programm zu verbessern, werden wir vier Probleme beheben, die mit der
Struktur des Programms und dem Umgang mit potenziellen Fehlern zu tun haben.

Erstens erfüllt unsere Funktion `main` jetzt zwei Aufgaben: Sie parst Argumente
und liest Dateien. Für eine so kleine Funktion ist dies kein großes Problem.
Wenn wir jedoch unser Programm innerhalb der Funktion `main` weiter ausbauen,
wird die Anzahl der einzelnen Aufgaben, die die Funktion `main` bearbeitet,
zunehmen. In dem Maße, wie eine Funktion an Verantwortung hinzugewinnt, wird es
schwieriger sie zu verstehen, schwieriger sie zu testen und schwieriger sie zu
ändern, ohne dass eines ihrer Teile kaputtgeht. Am besten ist es, die
Funktionalität so aufzuteilen, dass jede Funktion für eine Aufgabe zuständig
ist.

Diese Frage hängt auch mit dem zweiten Problem zusammen: Obwohl `query` und
`file_path` Konfigurationsvariablen unseres Programms sind, werden Variablen
wie `contents` verwendet, um die Logik des Programms umzusetzen. Je länger
`main` wird, desto mehr Variablen müssen wir in den Gültigkeitsbereich bringen;
je mehr Variablen wir im Gültigkeitsbereich haben, desto schwieriger wird es,
den Zweck der einzelnen Variablen im Auge zu behalten. Es ist am besten, die
Konfigurationsvariablen in einer Struktur zu gruppieren, um ihren Zweck zu
verdeutlichen.

Das dritte Problem ist, dass wir `expect` benutzt haben, um eine Fehlermeldung
auszugeben, wenn das Lesen der Datei fehlschlägt, aber die Fehlermeldung gibt
nur `Sollte die Datei lesen können` aus. Das Lesen einer Datei kann
auf verschiedene Arten fehlschlagen: Zum Beispiel könnte die Datei fehlen oder
wir haben keine Berechtigung, sie zu öffnen. Im Moment würden wir unabhängig
von der Situation die Fehlermeldung „Etwas ging beim Lesen der Datei schief“
ausgeben, die dem Benutzer keinerlei Informationen geben würde!

Viertens verwenden wir `expect` erneut, um verschiedene Fehler zu behandeln,
und wenn der Benutzer unser Programm ausführt, ohne genügend Argumente
anzugeben, erhält er einen `Index out of bounds`-Fehler von Rust, der das
Problem nicht eindeutig erklärt. Am besten wäre es, wenn sich der gesamte
Fehlerbehandlungscode an einer Stelle befände, sodass zukünftige Betreuer nur
eine Stelle im Code konsultieren bräuchten, falls sich die
Fehlerbehandlungslogik ändern sollte. Wenn sich der gesamte
Fehlerbehandlungscode an einer Stelle befindet, wird auch sichergestellt, dass
wir Meldungen ausgeben, die für unsere Endbenutzer aussagekräftig sind.

Lass uns diese vier Probleme angehen, indem wir unser Projekt refaktorieren.

### Trennen der Zuständigkeiten bei Binärprojekten

Das organisatorische Problem der Zuweisung der Verantwortung für mehrere
Aufgaben an die Funktion `main` ist vielen Binärprojekten gemein.
Infolgedessen hat die Rust-Gemeinschaft eine Richtlinie für die Aufteilung der
einzelnen Aufgaben eines Binärprogramms entwickelt, wenn die Funktion `main`
groß wird. Dieser Prozess umfasst die folgenden Schritte:

* Teile dein Programm in eine *main.rs* und eine *lib.rs* auf und verschiebe
  die Logik deines Programms in die *lib.rs*.
* Solange deine Kommandozeilen-Parselogik klein ist, kann sie in *main.rs*
  bleiben.
* Wenn die Kommandozeilen-Parselogik anfängt, kompliziert zu werden, extrahiere
  sie aus *main.rs* und verschiebe sie in *lib.rs*.

Die Verantwortlichkeiten, die nach diesem Prozess in der Funktion `main`
verbleiben, sollten sich auf Folgendes beschränken:

* Aufrufen der Kommandozeilen-Parselogik mit den Argumentwerten
* Aufbauen weiterer Konfiguration
* Aufrufen einer Funktion `run` in *lib.rs*
* Behandeln des Fehlers, wenn `run` einen Fehler zurückgibt

Bei diesem Muster geht es darum, Verantwortlichkeiten zu trennen: *main.rs*
kümmert sich um die Ausführung des Programms und *lib.rs* kümmert sich um die
gesamte Logik der anstehenden Aufgabe. Da du die Funktion `main` nicht direkt
testen kannst, kannst du mit dieser Struktur die gesamte Logik deines Programms
testen, indem du sie in Funktionen in *lib.rs* verschiebst. Der Code, der in
*main.rs* verbleibt, wird klein genug sein, um seine Korrektheit durch Lesen zu
überprüfen. Lass uns unser Programm überarbeiten, indem wir diesem Prozess
folgen.
                                                            
#### Extrahieren des Argument-Parsers
     
Wir werden die Funktionalität für das Parsen von Argumenten in eine Funktion
extrahieren, die von `main` aufgerufen wird, um das Verschieben der
Kommandozeilen-Parselogik nach *src/lib.rs* vorzubereiten. Codeblock 12-5 zeigt
den neuen Anfang von `main`, der eine neue Funktion `parse_config` aufruft, die
wir vorerst in *src/main.rs* definieren werden.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# use std::env;
# use std::fs;
#
fn main() {
    let args: Vec<String> = env::args().collect();

    let (query, filename) = parse_config(&args);

    // --abschneiden--
#
#     println!("Suche nach {}", query);
#     println!("In Datei {}", filename);
#
#     let contents = fs::read_to_string(filename)
#         .expect("Etwas ging beim Lesen der Datei schief");
#
#     println!("Mit text:\n{}", contents);
}

fn parse_config(args: &[String]) -> (&str, &str) {
    let query = &args[1];
    let filename = &args[2];

    (query, filename)
}
```

<span class="caption">Codeblock 12-5: Extrahieren einer Funktion `parse_config`
aus `main`</span>

Wir sammeln immer noch die Kommandozeilenargumente in einem Vektor, aber
anstatt den Argumentwert am Index 1 der Variablen `query` und den Argumentwert
am Index 2 der Variablen `file_path` innerhalb der `main`-Funktion zuzuweisen,
übergeben wir den gesamten Vektor an die Funktion `parse_config`. Die Funktion
`parse_config` enthält dann die Logik, die bestimmt, welches Argument in welche
Variable geht und die Werte an `main` zurückgibt. Wir erstellen immer noch die
Variablen `query` und `file_path` in `main`, aber `main` hat nicht mehr die
Verantwortung zu bestimmen, wie die Kommandozeilenargumente und Variablen
zusammenpassen.

Dieses Überarbeiten mag für unser kleines Programm übertrieben erscheinen, aber
wir führen die Refactoring-Maßnahmen in kleinen, inkrementellen Schritten
durch. Nachdem du diese Änderung vorgenommen hast, führe das Programm erneut
aus, um zu überprüfen, ob das Argumentparsen noch funktioniert. Es ist gut, den
Fortschritt oft zu überprüfen, um die Ursache von Problemen zu erkennen, wenn
sie auftreten.

#### Gruppieren von Konfigurationswerten
     
Wir können einen weiteren kleinen Schritt tun, um die Funktion `parse_config`
weiter zu verbessern. Im Moment geben wir ein Tupel zurück, aber dann zerlegen
wir dieses Tupel sofort wieder in einzelne Teile. Das ist ein Zeichen dafür,
dass wir vielleicht noch nicht die richtige Abstraktion haben.

Ein weiterer Indikator, der zeigt, dass es Raum für Verbesserungen gibt, ist
der `config`-Teil von `parse_config`, der impliziert, dass die beiden von uns
zurückgegebenen Werte miteinander in Beziehung stehen und beide Teil eines
Konfigurationswertes sind. Diese Bedeutung vermitteln wir derzeit in der
Struktur der Daten nur durch die Gruppierung der beiden Werte in einem Tupel;
wir werden stattdessen die beiden Werte in eine Struktur setzen und jedem der
Strukturfelder einen aussagekräftigen Namen geben. Auf diese Weise wird es
künftigen Betreuern dieses Codes leichter fallen, zu verstehen, wie die
verschiedenen Werte miteinander in Beziehung stehen und was ihr Zweck ist.
                                                   
Codeblock 12-6 zeigt die Verbesserungen der Funktion `parse_config`.

<span class="filename">Dateiname: src/main.rs</span>

```rust,should_panic
# use std::env;
# use std::fs;
#
fn main() {
    let args: Vec<String> = env::args().collect();

    let config = parse_config(&args);

    println!("Suche nach {}", config.query);
    println!("In Datei {}", config.filename);

    let contents = fs::read_to_string(config.filename)
        .expect("Etwas ging beim Lesen der Datei schief");

    // --abschneiden--
#
#     println!("Mit text:\n{}", contents);
}

struct Config {
    query: String,
    filename: String,
}

fn parse_config(args: &[String]) -> Config {
    let query = args[1].clone();
    let filename = args[2].clone();

    Config { query, filename }
}
```

<span class="caption">Codeblock 12-6: Refactorieren von `parse_config` zur
Rückgabe einer Instanz einer `Config`-Struktur</span>

Wir haben eine Struktur namens `Config` hinzugefügt, die so definiert ist, dass
sie Felder mit den Namen `query` und `file_path` enthält. Die Signatur von
`parse_config` zeigt nun an, dass sie einen `Config`-Wert zurückgibt. Im
Rumpf von `parse_config`, wo wir früher Zeichenkettenanteilstypen (string
slices) zurückgegeben haben, die auf `String`-Werte in `args` referenzieren,
definieren wir `Config` jetzt so, dass es aneigenbare (owned) `String`-Werte
enthält. Die `args`-Variable in `main` ist der Eigentümer der Argumentwerte und
lässt die Funktion `parse_config` diese nur ausleihen, was bedeutet, dass wir
Rusts Regeln für das Ausleihen verletzen würden, wenn `Config` versucht, die
Eigentümerschaft für die Werte in `args` zu nehmen.

Wir könnten die `String`-Daten auf verschiedene Weise verwalten, aber der
einfachste, wenn auch etwas ineffiziente Weg ist es, die `clone`-Methode der
Werte aufzurufen. Dadurch wird eine vollständige Kopie der Daten erstellt, die
die `Config`-Instanz besitzen soll, was mehr Zeit und Speicherplatz in Anspruch
nimmt als das Speichern einer Referenz auf die Zeichenkettendaten. Das Klonen
der Daten macht unseren Code jedoch auch sehr unkompliziert, weil wir die
Lebensdauer der Referenzen nicht verwalten müssen; unter diesen Umständen ist
es ein lohnender Kompromiss, ein wenig Leistung aufzugeben, um Einfachheit zu
bekommen.

> ### Die Kompromisse beim Verwenden von `clone`
>
> Viele Rust-Entwickler neigen dazu, das Verwenden von `clone` zur Lösung von
> Eigentümerschaftsproblemen wegen der Laufzeitkosten zu vermeiden. In [Kapitel
> 13][ch13] erfährst du, wie du in solchen Situationen effizientere Methoden
> einsetzen kannst. Aber für den Moment ist es in Ordnung, ein paar
> Zeichenketten zu kopieren, um weiter voranzukommen, da du diese Kopien nur
> einmal erstellen wirst und dein Dateipfad und deine Suchzeichenkette sehr
> klein sind. Es ist besser, ein funktionierendes Programm zu haben, das ein
> bisschen ineffizient ist, als zu versuchen, den Code beim ersten Durchgang zu
> hyperoptimieren. Je mehr Erfahrung du mit Rust sammelst, desto einfacher wird
> es, mit der effizientesten Lösung zu beginnen, aber im Moment ist es völlig
> akzeptabel, `clone` aufzurufen.

Wir haben `main` aktualisiert, sodass es die Instanz von `Config`, die von
`parse_config` zurückgegeben wird, in eine Variable namens `config` setzt, und
wir haben den Code aktualisiert, der vorher die separaten Variablen `query` und
`file_path` verwendet hat, sodass er jetzt stattdessen die Felder der
`Config`-Struktur verwendet.

Nun vermittelt unser Code deutlicher, dass `query` und `file_path` zueinander
gehören und dass ihr Zweck darin besteht, die Funktionsweise des Programms zu
konfigurieren. Jeder Code, der diese Werte verwendet, weiß, dass er sie in der
`config`-Instanz in den für ihren Zweck benannten Feldern findet.

#### Erstellen eines Konstruktors für `Config`

Bisher haben wir die Logik, die für das Parsen der Kommandozeilenargumente
verantwortlich ist, aus `main` extrahiert und in die Funktion `parse_config`
verschoben. Dies half uns zu erkennen, dass die Werte `query` und `file_path`
miteinander in Beziehung stehen und diese Beziehung in unserem Code vermittelt
werden sollte. Wir fügten dann eine `Config`-Struktur hinzu, um das
Zusammengehören von `query` und `file_path` zu benennen und um die Namen der
Werte als Feldnamen der Struktur von der `parse_config`-Funktion zurückgeben zu
können.

Da nun der Zweck der `parse_config`-Funktion darin besteht, eine
`Config`-Instanz zu erzeugen, können wir `parse_config` von einer einfachen
Funktion in eine Funktion namens `new` ändern, die mit der `Config`-Struktur
assoziiert ist. Durch diese Änderung wird der Code idiomatischer. Wir können
Instanzen von Typen in der Standardbibliothek erstellen, wie bei `String`,
indem wir `String::new` aufrufen. In ähnlicher Weise können wir durch Ändern
von `parse_config` in eine Funktion `new`, die mit `Config` assoziiert ist,
Instanzen von `Config` durch Aufrufen von `Config::new` erzeugen. Codeblock
12-7 zeigt die Änderungen, die wir vornehmen müssen.

<span class="filename">Dateiname: src/main.rs</span>

```rust,should_panic
# use std::env;
# use std::fs;
#
fn main() {
    let args: Vec<String> = env::args().collect();

    let config = Config::new(&args);

#     println!("Suche nach {}", config.query);
#     println!("In Datei {}", config.filename);
#
#     let contents = fs::read_to_string(config.filename)
#         .expect("Etwas ging beim Lesen der Datei schief");
#
#     println!("Mit text:\n{}", contents);
#
    // --abschneiden--
}

// --abschneiden--

# struct Config {
#     query: String,
#     filename: String,
# }
#
impl Config {
    fn new(args: &[String]) -> Config {
        let query = args[1].clone();
        let filename = args[2].clone();

        Config { query, filename }
    }
}
```

<span class="caption">Codeblock 12-7: Ändern von `parse_config` in
`Config::new`</span>

Wir haben `main` aktualisiert, wo wir `parse_config` aufgerufen haben, um
stattdessen `Config::new` aufzurufen. Wir haben den Namen von `parse_config` in
`new` geändert und ihn innerhalb eines `impl`-Blocks verschoben, der die
`new`-Funktion mit `Config` assoziiert. Versuche, diesen Code erneut zu
kompilieren, um sicherzustellen, dass er funktioniert.

### Korrigieren der Fehlerbehandlung

Jetzt werden wir daran arbeiten, unsere Fehlerbehandlung zu korrigieren.
Erinnere dich, dass der Versuch, auf die Werte im `args`-Vektor bei Index 1
oder Index 2 zuzugreifen, das Programm zum Absturz bringt, wenn der Vektor
weniger als drei Elemente enthält. Versuche, das Programm ohne irgendwelche
Argumente laufen zu lassen; es wird so aussehen:

```console
$ cargo run
   Compiling minigrep v0.1.0 (file:///projects/minigrep)
    Finished dev [unoptimized + debuginfo] target(s) in 0.0s
     Running `target/debug/minigrep`
thread 'main' panicked at 'index out of bounds: the len is 1 but the index is 1', src/main.rs:27:21
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
```

Die Zeile `index out of bounds: the len is 1 but the index is 1` ist eine für
Programmierer bestimmte Fehlermeldung. Sie wird unseren Endbenutzern nicht
helfen zu verstehen, was sie stattdessen tun sollten. Lass uns das jetzt
korrigieren.

#### Verbessern der Fehlermeldung

In Codeblock 12-8 fügen wir eine Prüfung in der Funktion `new` hinzu, die
überprüft, ob der Anteilstyp lang genug ist, bevor auf Index 1 und 2
zugegriffen wird. Wenn der Anteilstyp nicht lang genug ist, stürzt das Programm
ab und zeigt eine bessere Fehlermeldung an.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# use std::env;
# use std::fs;
#
# fn main() {
#     let args: Vec<String> = env::args().collect();
#
#     let config = Config::new(&args);
#
#     println!("Suche nach {}", config.query);
#     println!("In Datei {}", config.filename);
#
#     let contents = fs::read_to_string(config.filename)
#         .expect("Etwas ging beim Lesen der Datei schief");
#
#     println!("Mit text:\n{}", contents);
# }
#
# struct Config {
#     query: String,
#     filename: String,
# }
#
# impl Config {
    // --snip--
    fn new(args: &[String]) -> Config {
        if args.len() < 3 {
            panic!("Nicht genügend Argumente");
        }
        // --snip--
#
#         let query = args[1].clone();
#         let filename = args[2].clone();
#
#         Config { query, filename }
#     }
# }
```

<span class="caption">Codeblock 12-8: Hinzufügen einer Prüfung für die Anzahl
der Argumente</span>

Dieser Code ähnelt [der Funktion `Guess::new`, die wir in Codeblock
9-13][ch9-custom-types] geschrieben haben, wo wir `panic!` aufgerufen haben,
wenn das Argument `value` außerhalb des gültigen Wertebereichs lag. Anstatt
hier auf einen Wertebereich zu prüfen, prüfen wir, ob die Länge von `args`
mindestens 3 beträgt und der Rest der Funktion unter der Annahme arbeiten kann,
dass diese Bedingung erfüllt ist. Wenn `args` weniger als drei Elemente hat,
ist diese Bedingung wahr und wir rufen das Makro `panic!` auf, um das Programm
sofort zu beenden.

Mit diesen zusätzlichen wenigen Zeilen Code in `new` lassen wir das Programm
ohne Argumente erneut laufen, um zu sehen, wie der Fehler jetzt aussieht:

```console
$ cargo run
   Compiling minigrep v0.1.0 (file:///projects/minigrep)
    Finished dev [unoptimized + debuginfo] target(s) in 0.0s
     Running `target/debug/minigrep`
thread 'main' panicked at 'Nicht genügend Argumente', src/main.rs:26:13
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
```

Diese Ausgabe ist besser: Wir haben jetzt eine vernünftige Fehlermeldung. Wir
haben jedoch auch irrelevante Informationen, die wir unseren Benutzern nicht
geben wollen. Vielleicht ist die Technik, die wir in Codeblock 9-13 verwendet
haben, hier nicht die beste: Das Aufrufen von `panic!` ist für ein
Programmierproblem besser geeignet als für ein Nutzungsproblem, [wie in Kapitel
9 besprochen][ch9-error-guidelines]. Stattdessen können wir die andere Technik
verwenden, über die du in Kapitel 9 gelernt hast &ndash; [Rückgabe eines
`Result`][ch9-result] um entweder Erfolg oder einen Fehler anzuzeigen.

#### Zurückgeben eines `Result` von `new`, anstatt `panic!` aufzurufen

Wir können stattdessen einen `Result`-Wert zurückgeben, der im erfolgreichen
Fall eine `Config`-Instanz enthält und im Fehlerfall das Problem beschreibt.
Wir werden auch den Namen der Funktion von `new` in `build` ändern, weil viele
Programmierer erwarten, dass `new`-Funktionen niemals fehlschlagen. Wenn
`Config::new` mit `main` kommuniziert, können wir den `Result`-Typ verwenden,
um zu signalisieren, dass ein Problem aufgetreten ist. Dann können wir `main`
ändern, um eine `Err`-Variante in einen praktikableren Fehler für unsere
Benutzer umzuwandeln, ohne den umgebenden Text über `thread 'main'` und
`RUST_BACKTRACE`, den ein Aufruf von `panic!` verursacht.

Codeblock 12-9 zeigt die Änderungen, die wir am Rückgabewert der Funktion, die
nun `Config::new` aufruft, und am Funktionsrumpf vornehmen müssen, um ein
`Result` zurückzugeben. Beachte, dass dies nicht kompiliert werden kann, bis
wir auch `main` aktualisieren, was wir im nächsten Codeblock tun werden.

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore
# use std::env;
# use std::fs;
#
# fn main() {
#     let args: Vec<String> = env::args().collect();
#
#     let config = Config::new(&args);
#
#     println!("Suche nach {}", config.query);
#     println!("In Datei {}", config.filename);
#
#     let contents = fs::read_to_string(config.filename)
#         .expect("Etwas ging beim Lesen der Datei schief");
#
#     println!("Mit text:\n{}", contents);
# }
#
# struct Config {
#     query: String,
#     filename: String,
# }
#
impl Config {
    fn new(args: &[String]) -> Result<Config, &'static str> {
        if args.len() < 3 {
            return Err("Nicht genügend Argumente");
        }

        let query = args[1].clone();
        let filename = args[2].clone();

        Ok(Config { query, filename })
    }
}
```

<span class="caption">Codeblock 12-9: Rückgabe eines `Result` von
`Config::build`</span>

Unsere Funktion `build` liefert jetzt ein `Result` mit einer `Config`-Instanz im
Erfolgsfall und ein `&str` im Fehlerfall.

Wir haben zwei Änderungen im Rumpf der Funktion vorgenommen: Anstatt `panic!`
aufzurufen, wenn der Benutzer nicht genug Argumente übergibt, geben wir jetzt
einen `Err`-Wert zurück, und wir haben den `Config`-Rückgabewert in ein `Ok`
verpackt. Diese Änderungen machen die Funktion konform mit ihrer neuen
Typsignatur.

Die Rückgabe eines `Err`-Wertes aus `Config::build` erlaubt es der Funktion
`main`, den von der `build`-Funktion zurückgegebenen `Result`-Wert zu verarbeiten
und den Prozess im Fehlerfall sauberer zu beenden.

#### Aufrufen von `Config::build` und Behandeln von Fehlern

Um den Fehlerfall zu behandeln und eine benutzerfreundliche Meldung auszugeben,
müssen wir `main` aktualisieren, um das von `Config::build` zurückgegebene
`Result` zu behandeln, wie in Codeblock 12-10 gezeigt. Wir werden auch die
Verantwortung dafür übernehmen, das Kommandozeilenwerkzeug mit einem Fehlercode
ungleich Null wie bei `panic!` zu beenden und es von Hand zu implementieren.
Ein Exit-Status ungleich Null ist eine Konvention, um dem Prozess, der unser
Programm aufgerufen hat, zu signalisieren, dass das Programm mit einem
Fehlerstatus beendet wurde.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# use std::env;
# use std::fs;
use std::process;

fn main() {
    let args: Vec<String> = env::args().collect();

    let config = Config::new(&args).unwrap_or_else(|err| {
        println!("Fehler beim Parsen der Argumente: {}", err);
        process::exit(1);
    });

    // --abschneiden--
#
#     println!("Suche nach {}", config.query);
#     println!("In Datei {}", config.filename);
#
#     let contents = fs::read_to_string(config.filename)
#         .expect("Etwas ging beim Lesen der Datei schief");
#
#     println!("Mit text:\n{}", contents);
# }
#
# struct Config {
#     query: String,
#     filename: String,
# }
#
# impl Config {
#     fn new(args: &[String]) -> Result<Config, &'static str> {
#         if args.len() < 3 {
#             return Err("Nicht genügend Argumente");
#         }
#
#         let query = args[1].clone();
#         let filename = args[2].clone();
#
#         Ok(Config { query, filename })
#     }
# }
```

<span class="caption">Codeblock 12-10: Beenden mit einem Fehlercode, wenn das
Erstellen einer `Config` fehlschlägt</span>

In diesem Codeblock haben wir eine Methode verwendet, die wir bisher noch
nicht behandelt haben: `unwrap_or_else`, die in der Standardbibliothek unter
`Result<T, E>` definiert ist. Das Verwenden von `unwrap_or_else` erlaubt es
uns, eine benutzerdefinierte nicht-`panic!`-Fehlerbehandlung zu definieren.
Wenn das `Result` ein `Ok`-Wert ist, verhält sich diese Methode ähnlich wie
`unwrap`: Sie gibt den inneren Wert von `Ok` zurück. Wenn der Wert jedoch ein
`Err`-Wert ist, ruft diese Methode den Code im *Funktionsabschluss* (closure)
auf, die eine anonyme Funktion ist, die wir definieren und als Argument an
`unwrap_or_else` übergeben. Auf Funktionsabschlüsse gehen wir ausführlicher in
[Kapitel 13][ch13] ein. Im Moment musst du nur wissen, dass `unwrap_or_else`
den inneren Wert des `Err`, in diesem Fall die statische Zeichenkette `Nicht
genügend Argumente`, die wir in Codeblock 12-9 hinzugefügt haben, an unseren
Funktionsabschluss im Argument `err`, das zwischen den senkrechten Strichen
erscheint, weitergibt. Der Code im Funktionsabschluss kann dann den `err`-Wert
verwenden, wenn sie ausgeführt wird.

Wir haben eine neue Zeile `use` hinzugefügt, um `process` aus der
Standardbibliothek in den Gültigkeitsbereich zu bringen. Der Code im
Funktionsabschluss, der im Fehlerfall ausgeführt wird, besteht nur aus zwei
Zeilen: Wir geben den `err`-Wert aus und rufen dann `process::exit` auf. Die
Funktion `process::exit` stoppt das Programm sofort und gibt die Zahl zurück,
die als Exit-Statuscode übergeben wurde. Dies ähnelt der `panic!`-basierten
Behandlung, die wir in Codeblock 12-8 verwendet haben, aber wir erhalten nicht
mehr die gesamte zusätzliche Ausgabe. Lass es uns versuchen:

```console
$ cargo run
   Compiling minigrep v0.1.0 (file:///projects/minigrep)
    Finished dev [unoptimized + debuginfo] target(s) in 0.48s
     Running `target/debug/minigrep`
Fehler beim Parsen der Argumente: Nicht genügend Argumente
```

Großartig! Diese Ausgabe ist viel benutzerfreundlicher.

### Extrahieren von Logik aus `main`

Da wir mit dem Refaktorieren des Konfigurations-Parsers nun fertig sind, wollen
wir uns der Logik des Programms zuwenden. Wie wir in [„Trennen der
Zuständigkeiten bei
Binärprojekten“](#trennen-der-zuständigkeiten-bei-binärprojekten) erklärt
haben, werden wir eine Funktion namens `run` extrahieren, die die gesamte Logik
enthält, die sich derzeit in der Funktion `main` befindet und nicht mit dem
Aufsetzen der Konfiguration oder dem Behandeln von Fehlern zu tun hat. Wenn wir
fertig sind, wird `main` prägnant und leicht durch Inspektion zu verifizieren
sein, und wir werden in der Lage sein, Tests für all die andere Logik zu
schreiben.

Codeblock 12-11 zeigt die extrahierte Funktion `run`. Im Moment machen wir nur
die kleine, inkrementelle Verbesserung durch Extrahieren der Funktion. Wir sind
immer noch dabei, die Funktion in *src/main.rs* zu definieren.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# use std::env;
# use std::fs;
# use std::process;
#
fn main() {
    // --abschneiden--

#     let args: Vec<String> = env::args().collect();
#
#     let config = Config::new(&args).unwrap_or_else(|err| {
#         println!("Fehler beim Parsen der Argumente: {}", err);
#         process::exit(1);
#     });
#
    println!("Suche nach {}", config.query);
    println!("In Datei {}", config.filename);

    run(config);
}

fn run(config: Config) {
    let contents = fs::read_to_string(config.filename)
        .expect("Etwas ging beim Lesen der Datei schief");

    println!("Mit text:\n{}", contents);
}

// --abschneiden--
#
# struct Config {
#     query: String,
#     filename: String,
# }
#
# impl Config {
#     fn new(args: &[String]) -> Result<Config, &'static str> {
#         if args.len() < 3 {
#             return Err("Nicht genügend Argumente");
#         }
#
#         let query = args[1].clone();
#         let filename = args[2].clone();
#
#         Ok(Config { query, filename })
#     }
# }
```

<span class="caption">Codeblock 12-11: Extrahieren einer Funktion `run`, die
den Rest der Programmlogik enthält</span>

Die Funktion `run` enthält nun die gesamte restliche Logik von `main`,
beginnend mit dem Lesen der Datei. Die Funktion `run` nimmt die
`Config`-Instanz als Argument.

#### Rückgabe von Fehlern aus der Funktion `run`

Wenn die verbleibende Programmlogik in die Funktion `run` separiert wird,
können wir die Fehlerbehandlung verbessern, wie wir es mit `Config::build` in
Codeblock 12-9 getan haben. Anstatt das Programm durch den Aufruf von `expect`
abstürzen zu lassen, gibt die Funktion `run` ein `Result<T, E>` zurück, wenn
etwas schief läuft. Auf diese Weise können wir in `main` die Logik rund um den
Umgang mit Fehlern auf benutzerfreundliche Weise weiter konsolidieren.
Codeblock 12-12 zeigt die Änderungen, die wir an der Signatur und dem Rumpf von
`run` vornehmen müssen.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# use std::env;
# use std::fs;
# use std::process;
use std::error::Error;

// --abschneiden--

# fn main() {
#     let args: Vec<String> = env::args().collect();
#
#     let config = Config::new(&args).unwrap_or_else(|err| {
#         println!("Fehler beim Parsen der Argumente: {}", err);
#         process::exit(1);
#     });
#
#     println!("Suche nach {}", config.query);
#     println!("In Datei {}", config.filename);
#
#     run(config);
# }
#
fn run(config: Config) -> Result<(), Box<dyn Error>> {
    let contents = fs::read_to_string(config.filename)?;

    println!("Mit text:\n{}", contents);

    Ok(())
}
#
# struct Config {
#     query: String,
#     filename: String,
# }
#
# impl Config {
#     fn new(args: &[String]) -> Result<Config, &'static str> {
#         if args.len() < 3 {
#             return Err("Nicht genügend Argumente");
#         }
#
#         let query = args[1].clone();
#         let filename = args[2].clone();
#
#         Ok(Config { query, filename })
#     }
# }
```

<span class="caption">Codeblock 12-12: Ändern der Funktion `run`, um ein
`Result` zurückzugeben

Wir haben hier drei wesentliche Änderungen vorgenommen. Erstens haben wir den
Rückgabetyp der Funktion `run` in `Result<(), Box<dyn Error>>` geändert. Diese
Funktion gab zuvor den Einheitstyp `()` zurück und wir behalten diesen als
Rückgabewert im Fall `Ok` bei.

Für den Fehlertyp haben wir das *Merkmalsobjekt* (trait object) `Box<dyn
Error>` verwendet (und wir haben `std::error::Error` mit einer `use`-Anweisung
am Anfang des Gültigkeitsbereichs eingebunden). Wir werden Merkmalsobjekte in
[Kapitel 17][ch17] behandeln. Für den Moment solltest du nur wissen, dass
`Box<dyn Error>` bedeutet, dass die Funktion einen Typ zurückgibt, der das
Merkmal `Error` implementiert, aber wir müssen nicht angeben, welcher bestimmte
Typ der Rückgabewert sein wird. Das gibt uns die Flexibilität, Fehlerwerte
zurückzugeben, die in verschiedenen Fehlerfällen von unterschiedlichem Typ sein
können. Das Schlüsselwort `dyn` ist die Abkürzung für „dynamisch“.

Zweitens haben wir den Aufruf von `expect` zugunsten des `?`-Operators
entfernt, wie wir in [Kapitel 9][ch9-question-mark] besprochen haben. Statt
`panic!` bei einem Fehler aufzurufen gibt `?` den Fehlerwert aus der aktuellen
Funktion zurück, den der Aufrufer behandeln muss.

Drittens gibt die Funktion `run` jetzt im Erfolgsfall einen `Ok`-Wert zurück.
Wir haben den Erfolgstyp der Funktion `run` mit `()` in der Signatur
deklariert, was bedeutet, dass wir den Wert des Einheitstyps in den Wert `Ok`
einpacken müssen. Diese Syntax `Ok((())` mag zunächst etwas merkwürdig
aussehen, aber wenn wir `()` so verwenden, ist das der idiomatische Weg, um
anzuzeigen, dass wir `run` nur wegen seiner Nebenwirkungen aufrufen; es gibt
keinen Wert zurück, den wir brauchen.

Wenn du diesen Code ausführst, wird er kompiliert, aber es wird eine Warnung
angezeigt:

```console
$ cargo run the poem.txt
   Compiling minigrep v0.1.0 (file:///projects/minigrep)
warning: unused `Result` that must be used
  --> src/main.rs:19:5
   |
19 |     run(config);
   |     ^^^^^^^^^^^^
   |
   = note: `#[warn(unused_must_use)]` on by default
   = note: this `Result` may be an `Err` variant, which should be handled

warning: `minigrep` (bin "minigrep") generated 1 warning

    Finished dev [unoptimized + debuginfo] target(s) in 0.71s
     Running `target/debug/minigrep the poem.txt`
Suche nach the
In Datei poem.txt
Mit text:
I'm nobody! Who are you?
Are you nobody, too?
Then there's a pair of us - don't tell!
They'd banish us, you know.

How dreary to be somebody!
How public, like a frog
To tell your name the livelong day
To an admiring bog!
```

Rust sagt uns, dass unser Code den `Result`-Wert ignoriert hat, und der
`Result`-Wert könnte darauf hinweisen, dass ein Fehler aufgetreten ist. Aber
wir überprüfen nicht, ob ein Fehler aufgetreten ist oder nicht, und der
Compiler erinnert uns daran, dass wir wahrscheinlich gemeint haben, hier etwas
Fehlerbehandlungscode zu haben! Lass uns dieses Problem jetzt beheben.

#### Behandeln von Fehlern, die von `run` in `main` zurückgegeben wurden

Wir werden nach Fehlern suchen und sie mit einer Technik behandeln, die ähnlich
der Technik ist, die wir mit `Config::build` in Codeblock 12-10 verwendet
haben, aber mit einem kleinen Unterschied:

<span class="filename">Dateiname: src/main.rs</span>

```rust
# use std::env;
# use std::error::Error;
# use std::fs;
# use std::process;
#
fn main() {
    // --abschneiden--

#     let args: Vec<String> = env::args().collect();
#
#     let config = Config::new(&args).unwrap_or_else(|err| {
#         println!("Fehler beim Parsen der Argumente: {}", err);
#         process::exit(1);
#     });
#
    println!("Suche nach {}", config.query);
    println!("In Datei {}", config.filename);

    if let Err(e) = run(config) {
        println!("Anwendungsfehler: {}", e);

        process::exit(1);
    }
}
#
# fn run(config: Config) -> Result<(), Box<dyn Error>> {
#     let contents = fs::read_to_string(config.filename)?;
#
#     println!("Mit text:\n{}", contents);
#
#     Ok(())
# }
#
# struct Config {
#     query: String,
#     filename: String,
# }
#
# impl Config {
#     fn new(args: &[String]) -> Result<Config, &'static str> {
#         if args.len() < 3 {
#             return Err("Nicht genügend Argumente");
#         }
#
#         let query = args[1].clone();
#         let filename = args[2].clone();
#
#         Ok(Config { query, filename })
#     }
# }
```

Wir benutzen `if let` statt `unwrap_or_else`, um zu prüfen, ob `run` einen
`Err`-Wert zurückgibt und rufen `process::exit(1)` auf, wenn dies der Fall ist.
Die Funktion `run` gibt keinen Wert zurück, den wir mit `unwrap` auspacken
wollen, auf die gleiche Weise, wie `Config::build` die `Config`-Instanz
zurückgibt. Da `run` im Erfolgsfall `()` zurückgibt, geht es uns nur darum,
einen Fehler zu entdecken, wir brauchen also nicht `unwrap_or_else`, um den
ausgepackten Wert zurückzugeben, der nur `()` wäre.

Die Rümpfe von `if let` und der `unwrap_or_else`-Funktionen sind in beiden
Fällen gleich: Wir geben den Fehler aus und beenden.

### Code in eine Bibliothekskiste aufteilen

Unser `minigrep`-Projekt sieht soweit gut aus! Jetzt teilen wir die Datei
*src/main.rs* auf und fügen etwas Code in die Datei *src/lib.rs* ein. Auf
diese Weise können wir den Code testen und haben eine Datei *src/main.rs* mit
weniger Verantwortlichkeiten.

Lass uns den ganzen Code, der nicht die Funktion `main` ist, von *src/main.rs*
nach *src/lib.rs* verschieben:

* Die Definition der Funktion `run`
* Die relevanten `use`-Anweisungen
* Die Definition von `Config`
* Die Funktionsdefinition `Config::build`

Der Inhalt von *src/lib.rs* sollte die in Codeblock 12-13 gezeigten Signaturen
haben (wir haben die Rümpfe der Funktionen der Kürze halber weggelassen).
Beachte, dass dies nicht kompiliert werden kann, bis wir *src/main.rs* in
Codeblock 12-14 modifiziert haben.

<span class="filename">Dateiname: src/lib.rs</span>

```rust,ignore
use std::error::Error;
use std::fs;

pub struct Config {
    pub query: String,
    pub filename: String,
}

impl Config {
    pub fn new(args: &[String]) -> Result<Config, &'static str> {
        // --abschneiden--
#         if args.len() < 3 {
#             return Err("Nicht genügend Argumente");
#         }
#
#         let query = args[1].clone();
#         let filename = args[2].clone();
#
#         Ok(Config { query, filename })
    }
}

pub fn run(config: Config) -> Result<(), Box<dyn Error>> {
    // --abschneiden--
#     let contents = fs::read_to_string(config.filename)?;
#
#     println!("Mit text:\n{}", contents);
#
#     Ok(())
}
```

<span class="caption">Codeblock 12-13: Verschieben von `Config` und `run` in
*src/lib.rs*</span>

Wir haben das Schlüsselwort `pub` großzügig verwendet: Bei `Config`, bei seinen
Feldern und seiner Methode `new` und bei der Funktion `run`. Wir haben jetzt
eine Bibliothekskiste, die eine öffentliche API hat, die wir testen können!

Jetzt müssen wir den Code, den wir nach *src/lib.rs* verschoben haben, in den
Gültigkeitsbereich der Binärkiste in *src/main.rs* bringen, wie in Codeblock
12-14 gezeigt.

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore
use std::env;
use std::process;

use minigrep::Config;

fn main() {
    // --abschneiden--
#     let args: Vec<String> = env::args().collect();
#
#     let config = Config::new(&args).unwrap_or_else(|err| {
#         println!("Fehler beim Parsen der Argumente: {}", err);
#         process::exit(1);
#     });
#
#     println!("Suche nach {}", config.query);
#     println!("In Datei {}", config.filename);
#
    if let Err(e) = minigrep::run(config) {
        // --abschneiden--
#         println!("Anwendungsfehler: {}", e);
#
#         process::exit(1);
    }
}
```

<span class="caption">Codeblock 12-14: Verwenden der
`minigrep`-Bibliothekskiste in *src/main.rs*</span>

Wir fügen eine Zeile `use minigrep::Config` hinzu, um den Typ `Config` aus der
Bibliothekskiste in den Gültigkeitsbereich der Binärkiste zu bringen, und wir
stellen der Funktion `run` unseren Kistennamen voran. Nun sollte die gesamte
Funktionalität verbunden sein und funktionieren. Starte das Programm mit `cargo
run` und stelle sicher, dass alles korrekt funktioniert.

Puh! Das war eine Menge Arbeit, aber wir haben uns für den Erfolg in der
Zukunft gerüstet. Jetzt ist es viel einfacher, mit Fehlern umzugehen, und wir
haben den Code modularer gestaltet. Fast unsere gesamte Arbeit wird von nun an
in *src/lib.rs* durchgeführt.

Lass uns diese neu gewonnene Modularität nutzen, indem wir etwas tun, was mit
dem alten Code schwierig gewesen wäre, mit dem neuen Code aber einfach ist: Wir
schreiben ein paar Tests!

[ch13]: ch13-00-functional-features.html
[ch9-custom-types]: ch09-03-to-panic-or-not-to-panic.html#benutzerdefinierte-typen-für-die-validierung-erstellen
[ch9-error-guidelines]: ch09-03-to-panic-or-not-to-panic.html#richtlinien-zur-fehlerbehandlung
[ch9-result]: ch09-02-recoverable-errors-with-result.html
[ch17]: ch17-00-oop.html
[ch9-question-mark]: ch09-02-recoverable-errors-with-result.html#abkürzung-zum-weitergeben-von-fehlern-der-operator-
