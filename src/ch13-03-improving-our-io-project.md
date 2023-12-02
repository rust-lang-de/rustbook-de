## Unser E/A-Projekt verbessern

Mit diesem Wissen über Iteratoren können wir unser E/A-Projekt in Kapitel 12
verbessern. Wir werden Bereiche im Code klarer und prägnanter gestalten. Lass
uns herausfinden wie Iteratoren unsere Implementierung der
Funktion `Config::build` und der Funktion `search` optimieren können.

### Ein `clone` durch Verwendung eines Iterators entfernen

Im Codeblock 12-6 haben wir Programmcode hinzugefügt, der einen Anteilstyp
(slice) von `Zeichenketten`-Werten (String values) nimmt, und erzeugten eine
`Config`-Struktur indem wir den Anteilstyp indexierten und die Werte klonten
und der `Config`-Struktur die Eigentümerschaft dieser Werte gaben. Im Codeblock
13-17 haben wir die Implementierung der Funktion `Config::build` so reproduziert 
wie sie im Codeblock 12-23 aussah:

<span class="filename">Dateiname: src/lib.rs</span>

```rust,noplayground
# use std::env;
# use std::error::Error;
# use std::fs;
#
# pub struct Config {
#     pub query: String,
#     pub file_path: String,
#     pub ignore_case: bool,
# }
#
impl Config {
    pub fn build(args: &[String]) -> Result<Config, &'static str> {
        if args.len() < 3 {
            return Err("Nicht genügend Argumente");
        }

        let query = args[1].clone();
        let file_path = args[2].clone();

        let ignore_case = env::var("IGNORE_CASE").is_ok();

        Ok(Config {
            query,
            file_path,
            ignore_case,
        })
    }
}
#
# pub fn run(config: Config) -> Result<(), Box<dyn Error>> {
#     let contents = fs::read_to_string(config.file_path)?;
#
#     let results = if config.ignore_case {
#         search_case_insensitive(&config.query, &contents)
#     } else {
#         search(&config.query, &contents)
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
#         let query = "duct";
#         let contents = "\
# Rust:
# safe, fast, productive.
# Pick three.
# Duct tape.";
#
#         assert_eq!(vec!["safe, fast, productive."], search(query, contents));
#     }
#
#     #[test]
#     fn case_insensitive() {
#         let query = "rUsT";
#         let contents = "\
# Rust:
# safe, fast, productive.
# Pick three.
# Trust me.";
#
#         assert_eq!(
#             vec!["Rust:", "Trust me."],
#             search_case_insensitive(query, contents)
#         );
#     }
# }
```

<span class="caption">Codeblock 13-17: Reproduktion der `Config::build`-Funktion
vom Codeblock 12-23</span>

Zu diesem Zeitpunkt sagten wir, dass man sich keine Gedanken wegen der
ineffizienten `clone`-Aufrufe machen soll, da sie zu einem späteren Zeitpunkt
entfernt werden. Jetzt ist es an der Zeit, dass wir uns darum kümmern!

Wir haben `clone` benutzt, da wir einen Anteilstyp mit `String`-Elementen im
Parameter `args` haben, aber die Funktion `build` besitzt `args` nicht. Um die
Eigentümerschaft einer `Config`-Instanz zurückzugeben, mussten wir die Werte
aus den Feldern `query` und `file_path` von `Config` klonen, damit die
`Config`-Instanz ihre Werte besitzen kann.

Mithilfe unserer neuen Kenntnisse über Iteratoren können wir die Funktion
`build` so ändern, dass sie die Eigentümerschaft eines Iterators als Argument
nimmt anstatt sich einen Anteilstyp auszuleihen. Wir werden die
`Iterator`-Funktionalität benutzen und nicht mehr den Programmcode der die
Länge des Anteilstyps überprüft und an bestimmte Stellen indiziert. Dadurch
wird deutlich, was die Funktion `Config::build` bewirkt, da der Iterator auf
Werte zugreift.

Sobald `Config::build` die Eigentümerschaft des Iterators hat und keine
ausleihenden Indexierungsoperationen mehr verwendet, können wir die
`String`-Werte vom `Iterator` in `Config` verschieben anstatt `clone`
aufzurufen und eine neue Zuweisung vorzunehmen.

#### Direktes Verwenden des zurückgegebenen Iterators

Öffne die Datei *src/main.rs* deines E/A-Projekts, sie sollte so aussehen:

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore
#use std::env;
#use std::process;
#
#use minigrep::Config;
#
fn main() {
    let args: Vec<String> = env::args().collect();

    let config = Config::build(&args).unwrap_or_else(|err| {
        eprintln!("Problem beim Parsen der Argumente: {err}");
        process::exit(1);
    });

    // --abschneiden--
#
#    if let Err(e) = minigrep::run(config) {
#        eprintln!("Anwendungsfehler: {e}");
#
#        process::exit(1);
#    }
}
```

Wir werden zuerst den Anfang der Funktion `main` von Codeblock 12-24 in den 
Programmcode im Codeblock 13-18 ändern, der dieses Mal einen Iterator
verwendet. Dieser Code wird erst kompilieren, wenn wir auch `Config::build`
abgeändert haben.

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore
#use std::env;
#use std::process;
#
#use minigrep::Config;
#
fn main() {
    let config = Config::build(env::args()).unwrap_or_else(|err| {
        eprintln!("Problem beim Parsen der Argumente: {err}");
        process::exit(1);
    });

    // --abschneiden--
#   
#
#    if let Err(e) = minigrep::run(config) {
#        eprintln!("Anwendungsfehler: {e}");
#
#        process::exit(1);
#    }
}
```

<span class="caption">Codeblock 13-18: Übergabe des Rückgabewerts von 
`env::args` an `Config::build`</span>
	
Die `env::arg`-Funktion gibt einen Iterator zurück! Anstatt die Werte des Iterators
in einem Vektor zu sammeln und dann einen Anteilstyp an `Config::build` zu
übergeben, geben wir nun die Eigentümerschaft des Iterators, der von `env::args`
zurückgegeben wird, direkt an `Config::build`.

Als Nächstes müssen wir die Definition von `Config::build` aktualisieren.
Ändere in der Datei *src/lib.rs* deines E/A-Projekts die Signatur von
`Config::build` um, damit sie so wie im Codeblock 13-26 aussieht. Dies wird
noch immer nicht kompilieren, da der Funktionsrumpf aktualisiert werden muss.

<span class="filename">Dateiname src/lib.rs</span>

```rust,ignore
#use std::env;
#use std::error::Error;
#use std::fs;
#
#pub struct Config {
#    pub query: String,
#    pub file_path: String,
#    pub ignore_case: bool,
#}
#
impl Config {
    pub fn build(
        mut args: impl Iterator<Item = String>,
    ) -> Result<Config, &'static str> {
        // --abschneiden--
#      
#        if args.len() < 3 {
#            return Err("nicht genügend Argumente");
#        }
#
#        let query = args[1].clone();
#        let file_path = args[2].clone();
#
#        let ignore_case = env::var("IGNORE_CASE").is_ok();
#
#        Ok(Config {
#            query,
#            file_path,
#            ignore_case,
#        })
#    }
#}
#
#pub fn run(config: Config) -> Result<(), Box<dyn Error>> {
#    let contents = fs::read_to_string(config.file_path)?;
#
#    let results = if config.ignore_case {
#        search_case_insensitive(&config.query, &contents)
#    } else {
#        search(&config.query, &contents)
#    };
#
#    for line in results {
#        println!("{line}");
#    }
#
#    Ok(())
#}
#
#pub fn search<'a>(query: &str, contents: &'a str) -> Vec<&'a str> {
#    let mut results = Vec::new();
#
#    for line in contents.lines() {
#        if line.contains(query) {
#            results.push(line);
#        }
#    }
#
#    results
#}
#
#pub fn search_case_insensitive<'a>(
#    query: &str,
#    contents: &'a str,
#) -> Vec<&'a str> {
#    let query = query.to_lowercase();
#    let mut results = Vec::new();
#
#    for line in contents.lines() {
#        if line.to_lowercase().contains(&query) {
#            results.push(line);
#        }
#    }
#
#    results
#}
#
# #[cfg(test)]
#mod tests {
#    use super::*;
#
#    #[test]
#    fn case_sensitive() {
#        let query = "duct";
#        let contents = "\
#Rust:
#safe, fast, productive.
#Pick three.
#Duct tape.";
#
#        assert_eq!(vec!["safe, fast, productive."], search(query, contents));
#    }
#
#    #[test]
#    fn case_insensitive() {
#        let query = "rUsT";
#        let contents = "\
#Rust:
#safe, fast, productive.
#Pick three.
#Trust me.";
#
#        assert_eq!(
#            vec!["Rust:", "Trust me."],
#            search_case_insensitive(query, contents)
#        );
#    }
#}
```

<span class="caption">Codeblock 13-19: Aktualisieren der Funktion
`Config::build` damit sie einen Iterator annimmt</span>

Laut Dokumentation der Standardbibliothek für die Funktion `env::args` ist der
Typ des zurückgegebenen Iterators `std::env::Args`, und dieser Typ
implementiert das Merkmal `Iterator` und gibt `String`-Werte zurück.

Wir haben die Signatur der Funktion `Config::build` aktualisiert, sodass der
Parameter `args` einen generischen Typ mit den Merkmalsabgrenzungen `impl
Iterator<Item = String>` anstelle von `&[String]` hat. Diese Verwendung der
Syntax `impl Trait`, die wir im Abschnitt [„Merkmale als
Parameter“][impl-trait] in Kapitel 10 besprochen haben, bedeutet, dass `args`
jeder Typ sein kann, der den Typ `Iterator` implementiert und `String`-Elemente
zurückgibt.

Da wir die Eigentümerschaft von `args` übernehmen und `args` beim Iterieren
verändern werden, können wir das Schlüsselwort `mut` in die Spezifikation des
Parameters `args` eintragen, um ihn veränderbar (mutable) zu machen.

#### Verwenden von `Iterator`-Merkmalen anstelle von Indizierung

Als Nächstes werden wir den Rumpf von `Config::build` in Ordnung bringen. Da
`args` das Merkmal `Iterator` implementiert, wissen wir, dass wir die Methode
`next` darauf aufrufen können! Codeblock 13-20 aktualisiert den Code aus
Codeblock 12-23, um die `next`-Methode zu verwenden:

<span class="filename">Dateiname: src/lib.rs</span>

```rust
#use std::env;
#use std::error::Error;
#use std::fs;
#
#pub struct Config {
#    pub query: String,
#    pub file_path: String,
#    pub ignore_case: bool,
#}
#
impl Config {
    pub fn build(
        mut args: impl Iterator<Item = String>,
    ) -> Result<Config, &'static str> {
        args.next();

        let query = match args.next() {
            Some(arg) => arg,
            None => return Err("Keine Abfragezeichenkette erhalten"),
        };

        let file_path = match args.next() {
            Some(arg) => arg,
            None => return Err("Keinen Dateinamen erhalten"),
        };

        let ignore_case = env::var("IGNORE_CASE").is_ok();

        Ok(Config {
            query,
            file_path,
            ignore_case,
        })
    }
}
#
#pub fn run(config: Config) -> Result<(), Box<dyn Error>> {
#    let contents = fs::read_to_string(config.file_path)?;
#
#    let results = if config.ignore_case {
#        search_case_insensitive(&config.query, &contents)
#    } else {
#        search(&config.query, &contents)
#    };
#
#    for line in results {
#        println!("{line}");
#    }
#
#    Ok(())
#}
#
#pub fn search<'a>(query: &str, contents: &'a str) -> Vec<&'a str> {
#    let mut results = Vec::new();
#
#    for line in contents.lines() {
#        if line.contains(query) {
#            results.push(line);
#        }
#    }
#
#    results
#}
#
#pub fn search_case_insensitive<'a>(
#    query: &str,
#    contents: &'a str,
#) -> Vec<&'a str> {
#    let query = query.to_lowercase();
#    let mut results = Vec::new();
#
#    for line in contents.lines() {
#        if line.to_lowercase().contains(&query) {
#            results.push(line);
#        }
#    }
#
#    results
#}
#
# #[cfg(test)]
#mod tests {
#    use super::*;
#
#    #[test]
#    fn case_sensitive() {
#        let query = "duct";
#        let contents = "\
#Rust:
#safe, fast, productive.
#Pick three.
#Duct tape.";
#
#        assert_eq!(vec!["safe, fast, productive."], search(query, contents));
#    }
#
#    #[test]
#    fn case_insensitive() {
#        let query = "rUsT";
#        let contents = "\
#Rust:
#safe, fast, productive.
#Pick three.
#Trust me.";
#
#        assert_eq!(
#            vec!["Rust:", "Trust me."],
#            search_case_insensitive(query, contents)
#        );
#    }
#}
```

<span class="caption">Codeblock 13-20: Ändern des Rumpfes von `Config::build` um
Iterator-Methoden zu verwenden</span>

Beachte, dass der erste Wert des Rückgabewerts von `env::args` der Name des
Programms ist, wir wollen das ignorieren und rufen daher gleich `next` auf um
zum nächsten Wert zu gelangen und den ersten Rückgabewert zu überspringen. Als
Nächstes rufen wir `next` auf, um den Wert zu erhalten, den wir in das Feld `query`
von `Config` einfügen möchten. Falls `next` ein `Some` zurückgibt, benutzen wir
`match`, um den Wert zu extrahieren, wenn es jedoch `None` zurückgibt,
bedeutet dies, das nicht genügend Argumente eingegeben wurden und wir kehren
vorzeitig mit einem `Err` zurück. Dasselbe machen wir für den Wert `file_path`.

### Programmcode mit Iteratorenadapter klarer gestalten


Wir können die Vorteile der Iteratoren auch in der Funktion `search` unseres
E/A-Projekts nutzen, die hier im Codeblock 13-21 wiedergegeben ist, wie im
Codeblock 12-19:

<span class="filename">Dateiname: src/lib.rs</span>

```rust,ignore
#use std::error::Error;
#use std::fs;
#
#pub struct Config {
#    pub query: String,
#    pub file_path: String,
#}
#
#impl Config {
#    pub fn build(args: &[String]) -> Result<Config, &'static str> {
#        if args.len() < 3 {
#            return Err("nicht genügend Argumente");
#        }
#
#        let query = args[1].clone();
#        let file_path = args[2].clone();
#
#        Ok(Config { query, file_path })
#    }
#}
#
#pub fn run(config: Config) -> Result<(), Box<dyn Error>> {
#    let contents = fs::read_to_string(config.file_path)?;
#
#    Ok(())
#}
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
#mod tests {
#    use super::*;
#
#    #[test]
#    fn one_result() {
#        let query = "duct";
#        let contents = "\
#Rust:
#safe, fast, productive.
#Pick three.";
#
#        assert_eq!(vec!["safe, fast, productive."], search(query, contents));
#    }
#}
```

<span class="caption">Codeblock 13-21: Implementierung der Funktion `search`
aus Codeblock 12-19</span>

Wir können diesen Programmcode durch die Verwendung von Iteratoradaptern
prägnanter gestalten und vermeiden, einen veränderbaren Vektor `results` für
die Zwischenergebnisse zu haben. Bevorzugt wird im funktionalen Programmierstil
die Menge der veränderbaren Werte reduziert, um den Code übersichtlicher zu
machen. Das Entfernen des veränderbar-Status kann uns eventuell zukünftige
Verbesserungen ermöglichen, um die Suche parallel auszuführen, da wir uns nicht
um die Verwaltung des simultanen Zugriffs auf den Vektor `results` kümmern
müssen. Codeblock 13-22 zeigt diese Änderung:


<span class="filename">Dateiname: src/lib.rs</span>

```rust,ignore
#use std::env;
#use std::error::Error;
#use std::fs;
#
#pub struct Config {
#    pub query: String,
#    pub file_path: String,
#    pub ignore_case: bool,
#}
#
#impl Config {
#    pub fn build(
#        mut args: impl Iterator<Item = String>,
#    ) -> Result<Config, &'static str> {
#        args.next();
#
#        let query = match args.next() {
#            Some(arg) => arg,
#            None => return Err("Keine Abfragezeichenkette erhalten"),
#        };
#
#        let file_path = match args.next() {
#            Some(arg) => arg,
#            None => return Err("Keinen Dateinamen erhalten"),
#        };
#
#        let ignore_case = env::var("IGNORE_CASE").is_ok();
#
#        Ok(Config {
#            query,
#            file_path,
#            ignore_case,
#        })
#    }
#}
#
#pub fn run(config: Config) -> Result<(), Box<dyn Error>> {
#    let contents = fs::read_to_string(config.file_path)?;
#
#    let results = if config.ignore_case {
#        search_case_insensitive(&config.query, &contents)
#    } else {
#        search(&config.query, &contents)
#    };
#
#    for line in results {
#        println!("{line}");
#    }
#
#    Ok(())
#}
#
pub fn search<'a>(query: &str, contents: &'a str) -> Vec<&'a str> {
    contents
        .lines()
        .filter(|line| line.contains(query))
        .collect()
}
#
#pub fn search_case_insensitive<'a>(
#    query: &str,
#    contents: &'a str,
#) -> Vec<&'a str> {
#    let query = query.to_lowercase();
#    let mut results = Vec::new();
#
#    for line in contents.lines() {
#        if line.to_lowercase().contains(&query) {
#            results.push(line);
#        }
#    }
#
#    results
#}
#
# #[cfg(test)]
#mod tests {
#    use super::*;
#
#    #[test]
#    fn case_sensitive() {
#        let query = "duct";
#        let contents = "\
#Rust:
#safe, fast, productive.
#Pick three.
#Duct tape.";
#
#        assert_eq!(vec!["safe, fast, productive."], search(query, contents));
#    }
#
#    #[test]
#    fn case_insensitive() {
#        let query = "rUsT";
#        let contents = "\
#Rust:
#safe, fast, productive.
#Pick three.
#Trust me.";
#
#        assert_eq!(
#            vec!["Rust:", "Trust me."],
#            search_case_insensitive(query, contents)
#        );
#    }
#}
```
<span class="caption">Codeblock 13-22: Verwendung von Iteratoradapter-Methoden
bei der Implementierung der Funktion `search`</span>

Denke daran, der Zweck der Funktion `search` besteht darin, alle Zeilen in
`contents` zurückzugeben, die die `query` enthalten. So ähnlich wie im Beispiel
`filter` im Codeblock 13-16 verwendet dieser Programmcode den `filter`-Adapter,
um nur die Zeilen beizubehalten, für die `line.contains(query)` den Wert `true` zurückgibt.
Wir sammeln dann die passenden Zeilen mit `collect` in einen anderen Vektor.
Viel einfacher! Nimm die gleiche Änderung vor, um Iteratormethoden auch in der
Funktion `search_case_insensitive` zu nutzen.

### Zwischen Schleifen und Iteratoren wählen

Die nächste logische Frage wäre, welchen Stil du in deinem eigenen Programmcode
wählen solltest und warum. Die ursprüngliche Implementierung im Codeblock 13-21
oder die Version die Iteratoren verwendet im Codeblock 13-22. Die meisten
Rust-Programmierer bevorzugen den Iterator-Stil. Zunächst ist es zwar
schwieriger, den Überblick zu behalten, aber sobald du ein Gefühl für die
verschiedenen Iteratoradapter und deren Funktionsweise hast, können Iteratoren 
einfacher zu verstehen sein. Statt mit verschiedensten Schleifen herumzuspielen
und Vektoren zu erstellen, konzentriert sich der Programmcode auf das höhere
Ziel der Schleife. Dadurch wird ein Teil des gewöhnlichen Programmcodes
abstrahiert und die einzigartigen Konzepte, z.B. die Filterbedingung die
jedes Element bestehen muss um durch den Iterator zu kommen, werden leichter
erkennbar.

Aber sind beide Implementierungen wirklich gleichwertig? Die intuitive Annahme
könnte sein, dass die weniger abstrakte Schleife schneller ist. Lass uns über
Performanz sprechen.

[impl-trait]: ch10-02-traits.html#merkmale-als-parameter
