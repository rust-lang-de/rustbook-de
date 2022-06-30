## Mit Umgebungsvariablen arbeiten

Wir werden `minigrep` verbessern, indem wir eine zusätzliche Funktionalität
hinzufügen: Eine Option für die Suche unabhängig von der Groß-/Kleinschreibung,
die der Benutzer über eine Umgebungsvariable einschalten kann. Wir könnten
diese Funktion zu einer Kommandozeilenoption machen und verlangen, dass die
Benutzer sie jedes Mal eingeben müssen, wenn sie angewendet werden soll, aber
stattdessen werden wir eine Umgebungsvariable verwenden. Auf diese Weise können
unsere Benutzer die Umgebungsvariable einmal setzen und alle Suchvorgänge in
dieser Terminalsitzung ohne Berücksichtigung der Groß-/Kleinschreibung
durchführen.

### Schreiben eines fehlschlagenden Tests für die Suche unabhängig von der Groß-/Kleinschreibung

Wir fügen zuerst eine neue Funktion `search_case_insensitive` hinzu, die
aufgerufen wird, wenn die Umgebungsvariable einen Wert hat. Wir werden die
TDD-Methode weiter verfolgen, sodass der erste Schritt wieder darin besteht,
einen fehlschlagenden Test zu schreiben. Wir werden einen neuen Test für die
neue Funktion `search_case_insensitive` hinzufügen und unseren alten Test von
`one_result` in `case_sensitive` umbenennen, um die Unterschiede zwischen den
beiden Tests zu verdeutlichen, wie in Codeblock 12-20 gezeigt wird.

<span class="filename">Dateiname: src/lib.rs</span>

```rust,ignore,does_not_compile
# use std::error::Error;
# use std::fs;
#
# pub struct Config {
#     pub query: String,
#     pub file_path: String,
# }
#
# impl Config {
#     pub fn new(args: &[String]) -> Result<Config, &'static str> {
#         if args.len() < 3 {
#             return Err("Nicht genügend Argumente");
#         }
#
#         let query = args[1].clone();
#         let file_path = args[2].clone();
#
#         Ok(Config { query, file_path })
#     }
# }
#
# pub fn run(config: Config) -> Result<(), Box<dyn Error>> {
#     let contents = fs::read_to_string(config.file_path)?;
#
#     for line in search(&config.query, &contents) {
#         println!("{line}");
#     }
#
#     Ok(())
# }
#
# pub fn search<'a>(query: &str, contents: &'a str) -> Vec<&'a str> {
#     let mut results = Vec::new();
#
#     for line in contents.lines() {
#         if line.contains(query) {
#             results.push(line);
#         }
#     }
#
#     results
# }
#
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn case_sensitive() {
        let query = "dukt";
        let contents = "\
Rust:
sicher, schnell, produktiv.
Nimm drei.
PRODUKTION.";

        assert_eq!(vec!["sicher, schnell, produktiv."], search(query, contents));
    }

    #[test]
    fn case_insensitive() {
        let query = "rUsT";
        let contents = "\
Rust:
sicher, schnell, produktiv.
Nimm drei.
Trust me.";

        assert_eq!(
            vec!["Rust:", "Trust me."],
            search_case_insensitive(query, contents)
        );
    }
}
```

<span class="caption">Codeblock 12-20: Hinzufügen eines neuen fehlschlagenden
Tests für die Funktion `search_case_insensitive`, die wir gleich hinzufügen
werden</span>

Beachte, dass wir auch den Inhalt des alten Tests bearbeitet haben. Wir haben
eine neue Zeile mit dem Text `"PRODUKTION."` in Großbuchstaben hinzugefügt,
die nicht mit dem Abfragetext `"dukt"` übereinstimmen sollte, wenn wir bei der
Suche die Groß-/Kleinschreibung beachten. Wenn wir den alten Test auf diese
Weise ändern, stellen wir sicher, dass wir nicht versehentlich die bereits
implementierte Suchfunktionalität unter Berücksichtigung der
Groß-/Kleinschreibung kaputt machen. Dieser Test sollte jetzt erfolgreich sein
und er sollte es auch bleiben, während wir an der Suche unabhängig von der
Groß-/Kleinschreibung arbeiten.

Der neue Test `case_insensitive` verwendet `"rUsT"` als Suchabfrage. In der
Funktion `search_case_insensitive`, die wir gerade hinzufügen wollen, sollte
der Abfragetext `"rUsT"` zur Zeile, die `"Rust:"` mit einem großen R enthält,
passen und zur Zeile `"Trust me."`, obwohl beide eine andere Schreibweise haben
als der Abfragetext. Dies ist unser fehlschlagender Test und er wird sich nicht
kompilieren lassen, weil wir die Funktion `search_case_insensitive` noch nicht
definiert haben. Es steht dir frei, eine Skelett-Implementierung hinzuzufügen,
die immer einen leeren Vektor zurückgibt, ähnlich wie wir es für die Funktion
`search` in Codeblock 12-16 getan haben, um zu sehen, wie der Test kompilieren
wird und fehlschlägt.

### Implementieren der Funktion `search_case_insensitive`

Die Funktion `search_case_insensitive`, die in Codeblock 12-21 gezeigt wird,
wird fast die gleiche sein wie die Funktion `search`. Der einzige Unterschied
besteht darin, dass wir `query` und `line` in Kleinbuchstaben umwandeln, sodass
sie unabhängig von der Groß-/Kleinschreibung der Eingabe-Argumente sind, wenn
wir prüfen, ob die Zeile die Abfrage enthält.

<span class="filename">Dateiname: src/lib.rs</span>

```rust,noplayground
# use std::error::Error;
# use std::fs;
#
# pub struct Config {
#     pub query: String,
#     pub file_path: String,
# }
#
# impl Config {
#     pub fn new(args: &[String]) -> Result<Config, &'static str> {
#         if args.len() < 3 {
#             return Err("Nicht genügend Argumente");
#         }
#
#         let query = args[1].clone();
#         let file_path = args[2].clone();
#
#         Ok(Config { query, file_path })
#     }
# }
#
# pub fn run(config: Config) -> Result<(), Box<dyn Error>> {
#     let contents = fs::read_to_string(config.file_path)?;
#
#     for line in search(&config.query, &contents) {
#         println!("{line}");
#     }
#
#     Ok(())
# }
#
# pub fn search<'a>(query: &str, contents: &'a str) -> Vec<&'a str> {
#     let mut results = Vec::new();
#
#     for line in contents.lines() {
#         if line.contains(query) {
#             results.push(line);
#         }
#     }
#
#     results
# }
#
pub fn search_case_insensitive<'a>(
    query: &str,
    contents: &'a str,
) -> Vec<&'a str> {
    let query = query.to_lowercase();
    let mut results = Vec::new();

    for line in contents.lines() {
        if line.to_lowercase().contains(&query) {
            results.push(line);
        }
    }

    results
}
#
# #[cfg(test)]
# mod tests {
#     use super::*;
#
#     #[test]
#     fn case_sensitive() {
#         let query = "dukt";
#         let contents = "\
# Rust:
# sicher, schnell, produktiv.
# Nimm drei.
# PRODUKTION.";
#
#         assert_eq!(vec!["sicher, schnell, produktiv."], search(query, contents));
#     }
#
#     #[test]
#     fn case_insensitive() {
#         let query = "rUsT";
#         let contents = "\
# Rust:
# sicher, schnell, produktiv.
# Nimm drei.
# Trust me.";
#
#         assert_eq!(
#             vec!["Rust:", "Trust me."],
#             search_case_insensitive(query, contents)
#         );
#     }
# }
```

<span class="caption">Codeblock 12-21: Definieren der Funktion
`search_case_insensitive`, um den Abfragetext und die Zeile vor dem Vergleich
in Kleinbuchstaben umzuwandeln</span>

Zuerst wandeln wir die Zeichenkette `query` in Kleinbuchstaben um und speichern
ihn in einer beschatteten Variablen mit dem gleichen Namen. Der Aufruf von
`to_lowercase` beim Abfragetext ist notwendig, sodass wir unabhängig davon, ob
die Abfrage des Benutzers `"rust"`, `"RUST"`, `"RUST"` oder `"rUsT"` ist, die
Abfrage so behandeln, als ob sie `"rust"` wäre, und die Groß-/Kleinschreibung
nicht beachten. Obwohl `to_lowercase` mit einfachem Unicode umgehen kann, wird
es nicht 100% genau sein. Wenn wir eine echte Anwendung schreiben würden,
würden wir hier etwas mehr Arbeit spendieren wollen, aber in diesem Abschnitt
geht es um Umgebungsvariablen, nicht um Unicode, also belassen wir es hier
dabei.

Beachte, dass `query` jetzt ein `String` und nicht mehr ein
Zeichenkettenanteilstyp ist, weil der Aufruf von `to_lowercase` neue Daten
erzeugt, anstatt auf bestehende Daten zu referenzieren. Nehmen wir als Beispiel
an, der Abfragetext sei `"rUsT"`, dieser Zeichenkettenanteilstyp enthält kein
kleingeschriebenes `u` oder `t`, das wir verwenden könnten, also müssen wir
einen neuen `String` zuweisen, der `"rust"` enthält. Wenn wir nun `query` als
Argument an die `contains`-Methode übergeben, müssen wir ein `&`-Zeichen
angeben, weil die Signatur von `contains` so definiert ist, dass sie einen
Zeichenkettenanteilstyp nimmt.

Als nächstes fügen wir einen Aufruf von `to_lowercase` für jede `line` ein,
um alle Zeichen kleinzuschreiben. Da wir nun `line` und `query` in
Kleinbuchstaben umgewandelt haben, werden wir passende Zeilen finden, egal wie
die Groß-/Kleinschreibung der Abfrage ist.

Warten wir ab, ob diese Implementierung die Tests besteht:

```console
$ cargo test
   Compiling minigrep v0.1.0 (file:///projects/minigrep)
    Finished test [unoptimized + debuginfo] target(s) in 1.33s
     Running target/debug/deps/minigrep-4672b652f7794785

running 2 tests
test tests::case_insensitive ... ok
test tests::case_sensitive ... ok

test result: ok. 2 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out

     Running target/debug/deps/minigrep-caf9dbee196c78b9

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out

   Doc-tests minigrep

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out
```

Großartig! Sie haben bestanden. Lass uns nun die neue Funktion
`search_case_insensitive` von der Funktion `run` aufrufen. Zuerst fügen wir
eine Konfigurationsoption zur `Config`-Struktur hinzu, um zwischen der Suche
mit und ohne Berücksichtigung der Groß- und Kleinschreibung umzuschalten. Das
Hinzufügen dieses Feldes führt zu Kompilierfehlern, da wir dieses Feld noch
nirgendwo initialisiert haben:

<span class="filename">Dateiname: src/lib.rs</span>

```rust,does_not_compile
# use std::error::Error;
# use std::fs;
#
pub struct Config {
    pub query: String,
    pub file_path: String,
    pub case_sensitive: bool,
}
# 
# impl Config {
#     pub fn new(args: &[String]) -> Result<Config, &'static str> {
#         if args.len() < 3 {
#             return Err("Nicht genügend Argumente");
#         }
#
#         let query = args[1].clone();
#         let file_path = args[2].clone();
#
#         Ok(Config { query, file_path })
#     }
# }
#
# pub fn run(config: Config) -> Result<(), Box<dyn Error>> {
#     let contents = fs::read_to_string(config.file_path)?;
#
#     let results = if config.case_sensitive {
#         search(&config.query, &contents)
#     } else {
#         search_case_insensitive(&config.query, &contents)
#     };
#
#     for line in results {
#         println!("{line}");
#     }
#
#     Ok(())
# }
#
# pub fn search<'a>(query: &str, contents: &'a str) -> Vec<&'a str> {
#     let mut results = Vec::new();
#
#     for line in contents.lines() {
#         if line.contains(query) {
#             results.push(line);
#         }
#     }
#
#     results
# }
#
# pub fn search_case_insensitive<'a>(
#     query: &str,
#     contents: &'a str,
# ) -> Vec<&'a str> {
#     let query = query.to_lowercase();
#     let mut results = Vec::new();
#
#     for line in contents.lines() {
#         if line.to_lowercase().contains(&query) {
#             results.push(line);
#         }
#     }
#
#     results
# }
#
# #[cfg(test)]
# mod tests {
#     use super::*;
#
#     #[test]
#     fn case_sensitive() {
#         let query = "dukt";
#         let contents = "\
# Rust:
# sicher, schnell, produktiv.
# Nimm drei.
# PRODUKTION.";
#
#         assert_eq!(vec!["sicher, schnell, produktiv."], search(query, contents));
#     }
#
#     #[test]
#     fn case_insensitive() {
#         let query = "rUsT";
#         let contents = "\
# Rust:
# sicher, schnell, produktiv.
# Nimm drei.
# Trust me.";
#
#         assert_eq!(
#             vec!["Rust:", "Trust me."],
#             search_case_insensitive(query, contents)
#         );
#     }
# }
```

Wir haben das Feld `ignore_case` hinzugefügt, das ein Boolean enthält. Als
Nächstes benötigen wir die Funktion `run`, um den Wert des Feldes `ignore_case`
auszuwerten, und verwenden diese, um zu entscheiden, ob die Funktion `search`
oder die Funktion `search_case_insensitive` aufgerufen werden soll, wie in
Codeblock 12-22 gezeigt. Dies kompiliert noch immer nicht.

<span class="filename">Dateiname: src/lib.rs</span>

```rust,does_not_compile
# use std::error::Error;
# use std::fs;
#
# pub struct Config {
#     pub query: String,
#     pub file_path: String,
#     pub case_sensitive: bool,
# }
# 
# impl Config {
#     pub fn new(args: &[String]) -> Result<Config, &'static str> {
#         if args.len() < 3 {
#             return Err("Nicht genügend Argumente");
#         }
#
#         let query = args[1].clone();
#         let file_path = args[2].clone();
#
#         Ok(Config { query, file_path })
#     }
# }
#
pub fn run(config: Config) -> Result<(), Box<dyn Error>> {
    let contents = fs::read_to_string(config.file_path)?;

    let results = if config.case_sensitive {
        search(&config.query, &contents)
    } else {
        search_case_insensitive(&config.query, &contents)
    };

    for line in results {
        println!("{line}");
    }

    Ok(())
}
#
# pub fn search<'a>(query: &str, contents: &'a str) -> Vec<&'a str> {
#     let mut results = Vec::new();
#
#     for line in contents.lines() {
#         if line.contains(query) {
#             results.push(line);
#         }
#     }
#
#     results
# }
#
# pub fn search_case_insensitive<'a>(
#     query: &str,
#     contents: &'a str,
# ) -> Vec<&'a str> {
#     let query = query.to_lowercase();
#     let mut results = Vec::new();
#
#     for line in contents.lines() {
#         if line.to_lowercase().contains(&query) {
#             results.push(line);
#         }
#     }
#
#     results
# }
#
# #[cfg(test)]
# mod tests {
#     use super::*;
#
#     #[test]
#     fn case_sensitive() {
#         let query = "dukt";
#         let contents = "\
# Rust:
# sicher, schnell, produktiv.
# Nimm drei.
# PRODUKTION.";
#
#         assert_eq!(vec!["sicher, schnell, produktiv."], search(query, contents));
#     }
#
#     #[test]
#     fn case_insensitive() {
#         let query = "rUsT";
#         let contents = "\
# Rust:
# sicher, schnell, produktiv.
# Nimm drei.
# Trust me.";
#
#         assert_eq!(
#             vec!["Rust:", "Trust me."],
#             search_case_insensitive(query, contents)
#         );
#     }
# }
```

<span class="caption">Codeblock 12-22: Aufruf von entweder `search` oder
`search_case_insensitive` basierend auf dem Wert in `config.ignore_case`</span>

Schließlich müssen wir nach der Umgebungsvariablen suchen. Die Funktionen zum
Arbeiten mit Umgebungsvariablen befinden sich im Modul `env` in der
Standardbibliothek, daher bringen wir dieses Modul am Anfang von *src/lib.rs*
in den Gültigkeitsbereich. Dann werden wir die Funktion `var` aus dem Modul
`env` verwenden, um zu prüfen ob eine Umgebungsvariable namens `IGNORE_CASE`
einen Wert hat, wie in Codeblock 12-23 gezeigt.

<span class="filename">Dateiname: src/lib.rs</span>

```rust,noplayground
use std::env;
// --abschneiden--

# use std::error::Error;
# use std::fs;
#
# pub struct Config {
#     pub query: String,
#     pub file_path: String,
#     pub case_sensitive: bool,
# }
#
impl Config {
    pub fn new(args: &[String]) -> Result<Config, &'static str> {
        if args.len() < 3 {
            return Err("Nicht genügend Argumente");
        }

        let query = args[1].clone();
        let file_path = args[2].clone();

        let case_sensitive = env::var("CASE_INSENSITIVE").is_err();

        Ok(Config {
            query,
            file_path,
            case_sensitive,
        })
    }
}
#
# pub fn run(config: Config) -> Result<(), Box<dyn Error>> {
#     let contents = fs::read_to_string(config.file_path)?;
#
#     let results = if config.case_sensitive {
#         search(&config.query, &contents)
#     } else {
#         search_case_insensitive(&config.query, &contents)
#     };
#
#     for line in results {
#         println!("{line}");
#     }
#
#     Ok(())
# }
#
# pub fn search<'a>(query: &str, contents: &'a str) -> Vec<&'a str> {
#     let mut results = Vec::new();
#
#     for line in contents.lines() {
#         if line.contains(query) {
#             results.push(line);
#         }
#     }
#
#     results
# }
#
# pub fn search_case_insensitive<'a>(
#     query: &str,
#     contents: &'a str,
# ) -> Vec<&'a str> {
#     let query = query.to_lowercase();
#     let mut results = Vec::new();
#
#     for line in contents.lines() {
#         if line.to_lowercase().contains(&query) {
#             results.push(line);
#         }
#     }
#
#     results
# }
#
# #[cfg(test)]
# mod tests {
#     use super::*;
#
#     #[test]
#     fn case_sensitive() {
#         let query = "dukt";
#         let contents = "\
# Rust:
# sicher, schnell, produktiv.
# Nimm drei.
# PRODUKTION.";
#
#         assert_eq!(vec!["sicher, schnell, produktiv."], search(query, contents));
#     }
#
#     #[test]
#     fn case_insensitive() {
#         let query = "rUsT";
#         let contents = "\
# Rust:
# sicher, schnell, produktiv.
# Nimm drei.
# Trust me.";
#
#         assert_eq!(
#             vec!["Rust:", "Trust me."],
#             search_case_insensitive(query, contents)
#         );
#     }
# }
```

<span class="caption">Codeblock 12-23: Prüfen, ob eine Umgebungsvariable namens
`IGNORE_CASE` einen Wert hat</span>

Hier erstellen wir eine neue Variable `ignore_case`. Um ihren Wert zu setzen,
rufen wir die Funktion `env::var` auf und übergeben ihr den Namen der
Umgebungsvariablen `IGNORE_CASE`. Die Funktion `env::var` gibt ein `Result`
zurück, das die erfolgreiche `Ok`-Variante ist, die den Wert der
Umgebungsvariablen enthält, wenn die Umgebungsvariable einen Wert hat. Sie gibt
die Variante `Err` zurück, wenn die Umgebungsvariable nicht gesetzt ist.

Wir benutzen die Methode `is_ok` auf `Result`, um zu prüfen, ob die
Umgebungsvariable gesetzt ist, was bedeutet, dass das Programm die Suche
ohne Berücksichtigung der Groß-/Kleinschreibung durchführen soll. Wenn
die Umgebungsvariable `IGNORE_CASE` keinen Wert hat, gibt `is_ok` false zurück
und das Programm führt eine Suche mit Berücksichtigung der
Groß-/Kleinschreibung durch. Wir kümmern uns nicht um den *Wert* der
Umgebungsvariablen, nur darum, ob sie gesetzt ist oder nicht, also prüfen wir
mit `is_ok`, anstatt mit `unwrap`, `expect` oder einer der anderen Methoden,
die wir bei `Result` gesehen haben.

Wir übergeben den Wert in der Variablen `ignore_case` an die
`Config`-Instanz, sodass die Funktion `run` diesen Wert lesen und entscheiden
kann, ob sie `search_case_insensitive` oder `search` aufrufen soll, wie wir es
in Codeblock 12-22 implementiert haben.

Lass es uns versuchen! Zuerst führen wir unser Programm ohne die gesetzte
Umgebungsvariable und mit dem Abfragetext `to` aus, die zu den Zeilen passen
sollte, die das Wort `to` in Kleinbuchstaben enthalten:

```console
$ cargo run to poem.txt
   Compiling minigrep v0.1.0 (file:///projects/minigrep)
    Finished dev [unoptimized + debuginfo] target(s) in 0.0s
     Running `target/debug/minigrep to poem.txt`
Are you nobody, too?
How dreary to be somebody!
```

Sieht so aus, als ob das immer noch funktioniert! Lass uns nun das Programm mit
`IGNORE_CASE` auf `1` gesetzt ausführen, aber mit dem gleichen Abfragetext
`to`.

```console
$ IGNORE_CASE=1 cargo run -- to poem.txt
```

Wenn du die PowerShell verwendest, sind das Setzen der Umgebungsvariable und
das Ausführen des Programms separate Befehle:

```console
PS> $Env:IGNORE_CASE=1; cargo run to poem.txt
```

Dadurch bleibt `IGNORE_CASE` für den Rest deiner Shell-Sitzung bestehen. Sie
kann mit `Remove-Item` zurückgesetzt werden:

```console
PS> Remove-Item Env:IGNORE_CASE
```

Wir sollten Zeilen erhalten, die „to“ enthalten, die Großbuchstaben haben
könnten:

```console
$ CASE_INSENSITIVE=1 cargo run to poem.txt
    Finished dev [unoptimized + debuginfo] target(s) in 0.0s
     Running `target/debug/minigrep to poem.txt`
Are you nobody, too?
How dreary to be somebody!
To tell your name the livelong day
To an admiring bog!
```

Ausgezeichnet, wir haben auch Zeilen mit „to“! Unser `minigrep`-Programm kann
jetzt ohne Berücksichtigung von Groß-/Kleinschreibung suchen, gesteuert durch
eine Umgebungsvariable. Jetzt weißt du, wie man Optionen verwaltet, die
entweder mit Kommandozeilenargumenten oder Umgebungsvariablen gesetzt werden.

Einige Programme erlauben Argumente *und* Umgebungsvariablen für die gleiche
Konfiguration. In diesen Fällen entscheiden die Programme, dass das eine oder
das andere Vorrang hat. Versuche für eine weitere eigene Übung, die Steuerung,
ob die Groß-/Kleinschreibung berücksichtigt werden soll, entweder über ein
Kommandozeilenargument oder eine Umgebungsvariable zu ermöglichen. Entscheide,
ob das Kommandozeilenargument oder die Umgebungsvariable Vorrang haben soll,
wenn das Programm mit widersprüchlichen Optionen ausgeführt wird.

Das Modul `std::env` enthält viele weitere nützliche Funktionalitäten für den
Umgang mit Umgebungsvariablen: Schaue in seine Dokumentation, um zu sehen, was
verfügbar ist.
