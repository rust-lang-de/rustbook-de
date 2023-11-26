## Bibliotheksfunktionalität mit testgetriebener Entwicklung erstellen

Jetzt, da wir die Logik nach *src/lib.rs* extrahiert haben und die
Argumentkollektion und Fehlerbehandlung in *src/main.rs* belassen haben, ist es
viel einfacher, Tests für die Kernfunktionalität unseres Codes zu schreiben.
Wir können Funktionen direkt mit verschiedenen Argumenten aufrufen und
Rückgabewerte überprüfen, ohne unsere Binärdatei Terminal aus aufrufen zu
müssen.

In diesem Abschnitt fügen wir dem `minigrep`-Programm die Suchlogik hinzu,
indem wir die Methode der testgetriebenen Entwicklung (TDD) verwenden. Diese
Softwareentwicklungstechnik folgt diesen Schritten:

1. Schreibe einen Test, der fehlschlägt, und führe ihn aus, um sicherzustellen,
   dass er aus dem von dir erwarteten Grund fehlschlägt.
2. Schreibe oder modifiziere gerade genug Code, um den neuen Test zu bestehen.
3. Refaktoriere den Code, den du gerade hinzugefügt oder geändert hast, und
   stelle sicher, dass die Tests weiterhin bestanden werden.
4. Wiederhole ab Schritt 1!

Obwohl es nur eine von vielen Möglichkeiten ist, Software zu schreiben, kann
TDD auch beim Code-Design helfen. Das Schreiben der Tests vor dem Schreiben des
Codes, der den Test bestehen lässt, trägt dazu bei, während des gesamten
Entwicklungsprozesses eine hohe Testabdeckung aufrechtzuerhalten.

Wir werden die Implementierung der Funktionalität testen, die tatsächlich die
Suche nach der Suchzeichenkette im Dateiinhalt durchführt und eine Liste von
Zeilen erzeugt, die der Suchabfrage entsprechen. Wir werden diese
Funktionalität in einer Funktion namens `search` hinzufügen.

### Schreiben eines fehlschlagenden Tests

Da wir sie nicht mehr benötigen, entfernen wir die `println!` -Anweisungen aus
*src/lib.rs* und *src/main.rs*, die wir zum Überprüfen des Programmverhaltens
verwendet haben. Dann füge in *src/lib.rs* ein Modul `tests` mit einer
Testfunktion hinzu, wie wir es in [Kapitel 11][ch11-anatomy] getan haben. Die
Testfunktion spezifiziert das Verhalten, das die Funktion `search` haben soll:
Sie nimmt eine Suchabfrage und den Text, in dem gesucht werden soll, entgegen
und gibt nur die Zeilen aus dem Text zurück, die die Suchabfrage enthalten.
Codeblock 12-15 zeigt diesen Test, der sich noch nicht kompilieren lässt.

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
#     pub fn build(args: &[String]) -> Result<Config, &'static str> {
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
#     Ok(())
# }
#
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn one_result() {
        let query = "dukt";
        let contents = "\
Rust:
sicher, schnell, produktiv.
Nimm drei.";

        assert_eq!(vec!["sicher, schnell, produktiv."], search(query, contents));
    }
}
```

<span class="caption">Codeblock 12-15: Erstellen eines fehlschlagenden Tests
für die Funktion `search`, die wir uns wünschen</span>

Dieser Test sucht nach der Zeichenkette `"dukt"`. Der Text, den wir
durchsuchen, besteht aus drei Zeilen, von denen nur eine `"dukt"` enthält.
(Beachte, dass der Backslash nach dem öffnenden doppelten Anführungszeichen
Rust anweist, keinen Zeilenumbruch an den Anfang des Zeichenkettenliterals zu
setzen.) Wir verlangen, dass der von der Funktion `search` zurückgegebene Wert
nur die Zeile enthält, die wir erwarten.

Wir sind noch nicht in der Lage, diesen Test auszuführen und zuzusehen, wie er
fehlschlägt, weil der Test noch nicht mal kompiliert: Die Funktion `search`
existiert noch nicht! In Übereinstimmung mit den TDD-Prinzipien werden wir
jetzt gerade genug Code hinzufügen, um den Test zum Kompilieren und Ausführen
zu bringen, indem wir eine Definition der Funktion `search` hinzufügen, die
immer einen leeren Vektor zurückgibt, wie in Codeblock 12-16 gezeigt. Dann
sollte der Test kompiliert werden können und fehlschlagen, weil ein leerer
Vektor nicht mit einem Vektor übereinstimmt, der die Zeile `"sicher, schnell,
produktiv."` enthält.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
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
#     Ok(())
# }
#
pub fn search<'a>(query: &str, contents: &'a str) -> Vec<&'a str> {
    vec![]
}
#
# #[cfg(test)]
# mod tests {
#     use super::*;
#
#     #[test]
#     fn one_result() {
#         let query = "dukt";
#         let contents = "\
# Rust:
# sicher, schnell, produktiv.
# Nimm drei.";
#
#         assert_eq!(vec!["sicher, schnell, produktiv."], search(query, contents));
#     }
# }
```

<span class="caption">Codeblock 12-16: Definiere gerade genug von der Funktion
`search`, damit unser Test kompiliert</span>

Beachte, dass wir eine explizite Lebensdauer `'a` in der Signatur von `search`
definieren müssen und diese Lebensdauer beim Argument `contents` und dem
Rückgabewert verwenden. Erinnere dich in [Kapitel 10][ch10-lifetimes] daran,
dass die Lebensdauer-Parameter angeben, welche Argument-Lebensdauer mit der
Lebensdauer des Rückgabewertes verbunden ist. In diesem Fall geben wir an, dass
der zurückgegebene Vektor Zeichenkettenanteilstypen enthalten sollte, die auf
Anteilstypen des Arguments `contents` (und nicht auf das Argument `query`)
referenzieren.

Mit anderen Worten sagen wir Rust, dass die von der Funktion `search`
zurückgegebenen Daten so lange leben, wie die Daten, die im Argument `contents`
an die Funktion `search` übergeben werden. Das ist wichtig! Die Daten, auf die
durch einen Anteilstyp *referenziert* wird, müssen gültig sein, damit die
Referenz gültig ist; wenn der Compiler annimmt, dass wir
Zeichenkettenanteilstypen aus `query` statt aus `contents` erstellen, wird er
seine Sicherheitsprüfung falsch durchführen.

Wenn wir die Lebensdauer-Annotationen vergessen und versuchen, diese Funktion
zu kompilieren, erhalten wir diesen Fehler:

```console
$ cargo build
   Compiling minigrep v0.1.0 (file:///projects/minigrep)
error[E0106]: missing lifetime specifier
  --> src/lib.rs:28:51
   |
28 | pub fn search(query: &str, contents: &str) -> Vec<&str> {
   |                      ----            ----         ^ expected named lifetime parameter
   |
   = help: this function's return type contains a borrowed value, but the signature does not say whether it is borrowed from `query` or `contents`
help: consider introducing a named lifetime parameter
   |
28 | pub fn search<'a>(query: &'a str, contents: &'a str) -> Vec<&'a str> {
   |              ++++         ++                 ++              ++

For more information about this error, try `rustc --explain E0106`.
error: could not compile `minigrep` due to previous error
```

Rust kann unmöglich wissen, welches der beiden Argumente wir brauchen, also
müssen wir es ihm explizit sagen. Da `contents` das Argument ist, das unseren
gesamten Text enthält, und wir diejenigen Teile dieses Textes zurückgeben
wollen, die passen, wissen wir, dass `contents` das Argument ist, das mit dem
Rückgabewert unter Verwendung der Lebensdauer-Syntax verbunden werden sollte.

Bei anderen Programmiersprachen ist es nicht erforderlich, Argumente zu
verbinden, um Werte in der Signatur zurückzugeben, aber dieses Vorgehen wird
mit der Zeit einfacher werden. Vergleiche dieses Beispiel mit dem Abschnitt
[„Referenzen validieren mit Lebensdauern“][validating-references-with-lifetimes]
in Kapitel 10.

Lass uns jetzt den Test ausführen:

```console
$ cargo test
   Compiling minigrep v0.1.0 (file:///projects/minigrep)
    Finished test [unoptimized + debuginfo] target(s) in 0.97s
     Running unittests src/lib.rs (target/debug/deps/minigrep-9cd200e5fac0fc94)

running 1 test
test tests::one_result ... FAILED

failures:

---- tests::one_result stdout ----
thread 'tests::one_result' panicked at 'assertion failed: `(left == right)`
  left: `["sicher, schnell, produktiv."]`,
 right: `[]`', src/lib.rs:44:9
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace


failures:
    tests::one_result

test result: FAILED. 0 passed; 1 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

error: test failed, to rerun pass `--lib`
```

Toll, der Test schlägt fehl, genau wie wir erwartet haben. Bringen wir den Test
zum Bestehen!

### Code schreiben, um den Test zu bestehen

Derzeit scheitert unser Test, weil wir immer einen leeren Vektor zurückgeben.
Um dies zu korrigieren und `search` zu implementieren, muss unser Programm die
folgenden Schritte befolgen:

* Iteriere über jede Zeile des Inhalts.
* Prüfe, ob die Zeile unseren Abfragetext enthält.
* Wenn ja, füge sie der Liste der Werte hinzu, die wir zurückgeben.
* Wenn nicht, tue nichts.
* Gib die Liste der passenden Ergebnisse zurück.

Lass uns jeden Schritt durcharbeiten, beginnend mit dem Iterieren über die
Zeilen.

#### Iterieren über Zeilen mit der Methode `lines`

Rust hat eine hilfreiche Methode zum zeilenweisen Iterieren von Zeichenketten,
bequemerweise `lines` genannt, die wie in Codeblock 12-17 gezeigt funktioniert.
Beachte, dass dies noch nicht kompiliert.

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
#     pub fn build(args: &[String]) -> Result<Config, &'static str> {
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
#     Ok(())
# }
#
pub fn search<'a>(query: &str, contents: &'a str) -> Vec<&'a str> {
    for line in contents.lines() {
        // mache etwas mit line
    }
}
#
# #[cfg(test)]
# mod tests {
#     use super::*;
#
#     #[test]
#     fn one_result() {
#         let query = "dukt";
#         let contents = "\
# Rust:
# sicher, schnell, produktiv.
# Nimm drei.";
#
#         assert_eq!(vec!["sicher, schnell, produktiv."], search(query, contents));
#     }
# }
```

<span class="caption">Codeblock 12-17: Iteriere über jede Zeile in
`contents`</span>

Die Methode `lines` gibt einen Iterator zurück. Wir werden in [Kapitel
13][ch13-iterators] ausführlich über Iteratoren sprechen, aber erinnere dich
daran, dass du diese Art der Verwendung eines Iterators in [Codeblock
3-5][ch3-iter] gesehen hast, wo wir eine `for`-Schleife mit einem Iterator
benutzt haben, um etwas Code für jedes Element in einer Kollektion auszuführen.

#### Durchsuchen aller Zeilen nach dem Abfragetext

Als nächstes prüfen wir, ob die aktuelle Zeile unsere Abfragezeichenkette
enthält. Glücklicherweise haben Zeichenketten eine hilfreiche Methode namens
`contains`, die dies für uns erledigt! Füge einen Aufruf der `contains`-Methode
in der Funktion `search` hinzu, wie in Codeblock 12-18 gezeigt. Beachte, dass
dies noch nicht kompiliert werden kann.

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
#     pub fn build(args: &[String]) -> Result<Config, &'static str> {
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
#     Ok(())
# }
#
pub fn search<'a>(query: &str, contents: &'a str) -> Vec<&'a str> {
    for line in contents.lines() {
        if line.contains(query) {
            // mache etwas mit line
        }
    }
}
#
# #[cfg(test)]
# mod tests {
#     use super::*;
#
#     #[test]
#     fn one_result() {
#         let query = "dukt";
#         let contents = "\
# Rust:
# sicher, schnell, produktiv.
# Nimm drei.";
#
#         assert_eq!(vec!["sicher, schnell, produktiv."], search(query, contents));
#     }
# }
```

<span class="caption">Codeblock 12-18: Hinzufügen von Funktionalität, um zu
sehen, ob die Zeile die Zeichenkette in `query` enthält</span>

Im Moment bauen wir die Funktionalität auf. Damit sie kompiliert werden kann,
müssen wir einen Wert aus dem Rumpf zurückgeben, wie wir es in der
Funktionssignatur angegeben haben.

#### Speichern passender Zeilen

Um diese Funktion zu vervollständigen, brauchen wir auch eine Möglichkeit, die
passenden Zeilen zu speichern, die wir zurückgeben wollen. Dafür können wir
einen veränderbaren Vektor vor der `for`-Schleife erstellen und die
`push`-Methode aufrufen, um eine `line` im Vektor zu speichern. Nach der
`for`-Schleife geben wir den Vektor zurück, wie in Codeblock 12-19 gezeigt.

<span class="filename">Dateiname: src/lib.rs</span>

```rust,ignore
# use std::error::Error;
# use std::fs;
#
# pub struct Config {
#     pub query: String,
#     pub file_path: String,
# }
#
# impl Config {
#     pub fn build(args: &[String]) -> Result<Config, &'static str> {
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
#     Ok(())
# }
#
pub fn search<'a>(query: &str, contents: &'a str) -> Vec<&'a str> {
    let mut results = Vec::new();

    for line in contents.lines() {
        if line.contains(query) {
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
#     fn one_result() {
#         let query = "dukt";
#         let contents = "\
# Rust:
# sicher, schnell, produktiv.
# Nimm drei.";
#
#         assert_eq!(vec!["sicher, schnell, produktiv."], search(query, contents));
#     }
# }
```

<span class="caption">Codeblock 12-19: Speichern der passenden Zeilen, damit
wir sie zurückgeben können</span>

Jetzt sollte die Funktion `search` nur noch die Zeilen zurückgeben, die `query`
enthalten, und unser Test sollte erfolgreich sein. Lass uns den Test ausführen:

```console
$ cargo test
   Compiling minigrep v0.1.0 (file:///projects/minigrep)
    Finished test [unoptimized + debuginfo] target(s) in 1.22s
     Running unittests src/lib.rs (target/debug/deps/minigrep-9cd200e5fac0fc94)

running 1 test
test tests::one_result ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

     Running unittests src/main.rs (target/debug/deps/minigrep-9cd200e5fac0fc94)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

   Doc-tests minigrep

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
```

Unser Test war erfolgreich, also wissen wir, dass es funktioniert!

An diesem Punkt könnten wir Möglichkeiten für eine Refaktorierung der
Implementierung der Suchfunktion in Betracht ziehen, während die Tests
weiterlaufen, um die gleiche Funktionalität zu erhalten. Der Code in der
Suchfunktion ist nicht allzu schlecht, aber er macht sich einige nützliche
Funktionen der Iteratoren nicht zunutze. Wir kehren zu diesem Beispiel in
[Kapitel 13][ch13-iterators] zurück, wo wir Iteratoren im Detail untersuchen
und uns ansehen, wie man sie verbessern kann.

#### Verwenden der Funktion `search` in der Funktion `run`

Da die Funktion `search` nun funktioniert und getestet ist, müssen wir `search`
von unserer Funktion `run` aus aufrufen. Wir müssen den Wert `config.query` und
den Wert `contents`, den `run` aus der Datei liest, an die Funktion `search`
übergeben. Dann wird `run` jede von `search` zurückgegebene Zeile ausgeben:

<span class="filename">Dateiname: src/lib.rs</span>

```rust,ignore
# use std::error::Error;
# use std::fs;
#
# pub struct Config {
#     pub query: String,
#     pub file_path: String,
# }
#
# impl Config {
#     pub fn build(args: &[String]) -> Result<Config, &'static str> {
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

    for line in search(&config.query, &contents) {
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
# #[cfg(test)]
# mod tests {
#     use super::*;
#
#     #[test]
#     fn one_result() {
#         let query = "dukt";
#         let contents = "\
# Rust:
# sicher, schnell, produktiv.
# Nimm drei.";
#
#         assert_eq!(vec!["sicher, schnell, produktiv."], search(query, contents));
#     }
# }
```

Wir benutzen immer noch eine `for`-Schleife, um jede Zeile von `search`
zurückzugeben und auszugeben.

Jetzt sollte das gesamte Programm funktionieren! Lass es uns ausprobieren,
zunächst mit einem Wort, das genau eine Zeile aus dem Emily-Dickinson-Gedicht
wiedergeben sollte: „frog“

```console
$ cargo run frog poem.txt
   Compiling minigrep v0.1.0 (file:///projects/minigrep)
    Finished dev [unoptimized + debuginfo] target(s) in 0.38s
     Running `target/debug/minigrep frog poem.txt`
How public, like a frog
```

Cool! Versuchen wir nun ein Wort, das zu mehreren Zeilen passt, wie „body“:

```console
$ cargo run body poem.txt
   Compiling minigrep v0.1.0 (file:///projects/minigrep)
    Finished dev [unoptimized + debuginfo] target(s) in 0.0s
     Running `target/debug/minigrep body poem.txt`
I'm nobody! Who are you?
Are you nobody, too?
How dreary to be somebody!
```

Und schließlich sollten wir sicherstellen, dass wir keine Zeilen bekommen, wenn
wir nach einem Wort suchen, das nirgendwo im Gedicht vorkommt, zum Beispiel
„monomorphization“:

```console
$ cargo run monomorphization poem.txt
   Compiling minigrep v0.1.0 (file:///projects/minigrep)
    Finished dev [unoptimized + debuginfo] target(s) in 0.0s
     Running `target/debug/minigrep monomorphization poem.txt`
```

Ausgezeichnet! Wir haben unsere eigene Miniversion eines klassischen Tools
gebaut und viel darüber gelernt, wie man Anwendungen strukturiert. Wir haben
auch ein wenig über Dateieingabe und -ausgabe, Lebensdauer, Testen und
Kommandozeilen-Parsen gelernt.

Um dieses Projekt abzurunden, werden wir kurz demonstrieren, wie man mit
Umgebungsvariablen arbeitet und wie man Standardfehler ausgibt, beides ist
nützlich, wenn du Kommandozeilenprogramme schreibst.

[validating-references-with-lifetimes]: ch10-03-lifetime-syntax.html
[ch11-anatomy]: ch11-01-writing-tests.html#anatomie-einer-testfunktion
[ch10-lifetimes]: ch10-03-lifetime-syntax.html
[ch3-iter]: ch03-05-control-flow.html#wiederholen-anhand-einer-kollektion-mit-for
[ch13-iterators]: ch13-02-iterators.html
