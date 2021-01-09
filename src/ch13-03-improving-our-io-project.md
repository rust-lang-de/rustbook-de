## Unser E/A-Projekt verbessern

Mit diesem Wissen über Iteratoren können wir unser E/A-Projekt in Kapitel 12
verbessern. Wir werden Bereiche im Code klarer und prägnanter gestalten. Lass
uns herausfinden wie Iteratoren unsere Implementierung der
Funktion `Config::new` und der Funktion `search` optimieren können.

### Ein `clone` durch Verwendung eines Iterators entfernen

Im Codeblock 12-6 haben wir Programmcode hinzugefügt, der einen Anteilstyp
(slice) von `Zeichenketten`-Werten (String values) nimmt, und erzeugten eine
`Config`-Struktur indem wir den Anteilstyp indexierten und die Werte klonten
und der `Config`-Struktur die Eigentümerschaft dieser Werte gaben. Im Codeblock
13-24 haben wir die Implementierung der Funktion `Config::new` so reproduziert 
wie sie im Codeblock 12-23 aussah:

<span class="filename">Dateiname: src/lib.rs</span>

```rust,noplayground
# use std::env;
# use std::error::Error;
# use std::fs;
#
# pub struct Config {
#     pub query: String,
#     pub filename: String,
#     pub case_sensitive: bool,
# }
#
impl Config {
    pub fn new(args: &[String]) -> Result<Config, &str> {
        if args.len() < 3 {
            return Err("nicht genügend Argumente");
        }

        let query = args[1].clone();
        let filename = args[2].clone();

        let case_sensitive = env::var("CASE_INSENSITIVE").is_err();

        Ok(Config {
            query,
            filename,
            case_sensitive,
        })
    }
}
#
# pub fn run(config: Config) -> Result<(), Box<dyn Error>> {
#     let contents = fs::read_to_string(config.filename)?;
#
#     let results = if config.case_sensitive {
#         search(&config.query, &contents)
#     } else {
#         search_case_insensitive(&config.query, &contents)
#     };
#
#     for line in results {
#         println!("{}", line);
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

<span class="caption">Codeblock 13-24: Reproduktion der `Config::new`-Funktion
vom Codeblock 12-23</span>

Zu diesem Zeitpunkt sagten wir, dass man sich keine Gedanken wegen der
ineffizienten `clone`-Aufrufe machen soll, da sie zu einem späteren Zeitpunkt
entfernt werden. Jetzt ist es an der Zeit, dass wir uns darum kümmern!

Wir haben `clone` benutzt, da wir einen Anteilstyp mit `String`-Elementen im
Parameter `args` haben. Um die Eigentümerschaft einer `Config`-Instanz
zurückzugeben, mussten wir die Werte aus den Feldern `query` und `filename` von
`Config` klonen, damit die `Config`-Instanz ihre Werte besitzen kann.

Mithilfe unserer neuen Kenntnisse über Iteratoren können wir die
`new`-Funktion so ändern, dass sie die Eigentümerschaft eines Iterators als
Argument nimmt anstatt sich einen Anteilstyp auszuleihen. Wir werden die
`Iterator`-Funktionalität benutzen und nicht mehr den Programmcode der die Länge
des Anteilstyps überprüft und an bestimmte Stellen indiziert. Dadurch wird deutlich,
was die `Config::new`-Funktion bewirkt, da der Iterator auf Werte zugreift.

Sobald `Config::new` die Eigentümerschaft des Iterators hat und keine
ausgeliehenen Indexierungsoperationen mehr verwendet, können wir die
`Zeichenketten`-Werte vom `Iterator` in `Config` verschieben anstatt `clone`
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

    let config = Config::new(&args).unwrap_or_else(|err| {
        eprintln!("Problem beim Parsen der Argumente: {}", err);
        process::exit(1);
    });

    // --abschneiden--
#
#    if let Err(e) = minigrep::run(config) {
#        eprintln!("Anwendungsfehler: {}", e);
#
#        process::exit(1);
#    }
}
```
Wir werden den Anfang der Funktion `main` von Codeblock 12-24 in den 
Programmcode im Codeblock 13-25 ändern. Dieser Code wird erst kompilieren,
wenn wir auch `Config::new` abgeändert haben.


<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore
#use std::env;
#use std::process;
#
#use minigrep::Config;
#
fn main() {
    let config = Config::new(env::args()).unwrap_or_else(|err| {
        eprintln!("Problem beim Parsen der Argumente: {}", err);
        process::exit(1);
    });

    // --abschneiden--
#   
#
#    if let Err(e) = minigrep::run(config) {
#        eprintln!("Anwendungsfehler: {}", e);
#
#        process::exit(1);
#    }
}
```

<span class="caption">Codeblock 13-25: Übergabe des Rückgabewerts von 
`env::args` an `Config::new`</span>
	
Die `env::arg`-Funktion gibt einen Iterator zurück! Anstatt die Werte des Iterators
in einem Vektor zu sammeln und dann einen Anteilstyp an `Config::new` zu
übergeben, geben wir nun die Eigentümerschaft des Iterators, der von `env::args`
zurückgegeben wird, direkt an `Config::new`.

Als Nächstes müssen wir die Definition von `Config::new` aktualisieren. Ändere
in der Datei *src/lib.rs* deines E/A-Projekts die Signatur von `Config::new` um,
damit sie so wie im Codeblock 13-26 aussieht. Dies wird noch immer nicht
kompilieren, da der Funktionsrumpf aktualisiert werden muss.

<span class="filename">Dateiname src/lib.rs</span>

```rust,ignore
#use std::env;
#use std::error::Error;
#use std::fs;
#
#pub struct Config {
#    pub query: String,
#    pub filename: String,
#    pub case_sensitive: bool,
#}
#
impl Config {
    pub fn new(mut args: env::Args) -> Result<Config, &'static str> {
        // --snip--
#      
#        if args.len() < 3 {
#            return Err("nicht genügend Argumente");
#        }
#
#        let query = args[1].clone();
#        let filename = args[2].clone();
#
#        let case_sensitive = env::var("CASE_INSENSITIVE").is_err();
#
#        Ok(Config {
#            query,
#            filename,
#            case_sensitive,
#        })
#    }
#}
#
#pub fn run(config: Config) -> Result<(), Box<dyn Error>> {
#    let contents = fs::read_to_string(config.filename)?;
#
#    let results = if config.case_sensitive {
#        search(&config.query, &contents)
#    } else {
#        search_case_insensitive(&config.query, &contents)
#    };
#
#    for line in results {
#        println!("{}", line);
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

<span class="caption">Codeblock 13-26: Aktualisieren der Funktion`Config::new`
damit sie einen Iterator annimmt</span>

Laut Dokumentation der Standardbibliothek für die Funktion `env::args` ist der
Typ des zurückgegebenen Iterators `std::env::Args`. Wir haben die Signatur
der Funktion `Config::New` aktualisiert, damit der Parameter `args` den Typ
`std::env::Args` statt `&[String]` hat. Da wir die Eigentümerschaft von `args`
übernehmen und `args` beim Iterieren verändern werden, können wir das
Schlüsselwort `mut` in die Spezifikation des Parameters `args` eintragen, um
ihn veränderlich (mutable) zu machen.

Wir mussten auch spezifizieren, dass der Zeichenkettenanteilstyp-Fehlertyp nur
noch die Lebensdauer `'static` haben kann. Da wir immer nur
Zeichenketten-Literale zurückgeben, war dies schon vorher der Fall. Wenn wir
jedoch eine Referenz in den Parametern hätten, bestünde die Möglichkeit, dass
die Referenz im Rückgabetyp die gleiche Lebensdauer wie die Referenz in den
Parametern hat. Es gelten die Regeln, die wir im Abschnitt
[„Lebensdauer-Elision“][lifetime-elision] in Kapitel 10 besprochen haben, und
wir waren nicht gezwungen, die Lebensdauer von `&str` zu annotieren. Mit 
dem Wechsel zu `args` gelten die Regeln der Lebensdauer-Elision nicht mehr und
wir müssen die Lebensdauer `'static` angeben.

#### Verwenden von `Iterator`-Merkmalen anstelle von Indizierung

Als Nächstes werden wir den Rumpf von `Config::new` in Ordnung bringen. In der
Standardbibliotheksdokumentation wird auch beschrieben, dass `std::env::Args`
das `Iterator`-Merkmal implementiert, daher wissen wir, dass wir die Methode
`next` darauf anwenden können! Codeblock 13-27 aktualisiert den Programmcode aus
Codeblock 12-23, damit `next` verwendet wird:

<span class="filename">Dateiname: src/lib.rs</span>

```rust
#use std::env;
#use std::error::Error;
#use std::fs;
#
#pub struct Config {
#    pub query: String,
#    pub filename: String,
#    pub case_sensitive: bool,
#}
#
impl Config {
    pub fn new(mut args: env::Args) -> Result<Config, &'static str> {
        args.next();

        let query = match args.next() {
            Some(arg) => arg,
            None => return Err("Keine Abfragezeichenkette erhalten"),
        };

        let filename = match args.next() {
            Some(arg) => arg,
            None => return Err("Keinen Dateinamen erhalten"),
        };

        let case_sensitive = env::var("CASE_INSENSITIVE").is_err();

        Ok(Config {
            query,
            filename,
            case_sensitive,
        })
    }
}
#
#pub fn run(config: Config) -> Result<(), Box<dyn Error>> {
#    let contents = fs::read_to_string(config.filename)?;
#
#    let results = if config.case_sensitive {
#        search(&config.query, &contents)
#    } else {
#        search_case_insensitive(&config.query, &contents)
#    };
#
#    for line in results {
#        println!("{}", line);
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

<span class="caption">Codeblock 13-27: Ändern des Rumpfes von `Config::new` um
Iterator-Methoden zu verwenden</span>

Beachte, dass der erste Wert des Rückgabewerts von `env::args` der Name des
Programms ist, wir wollen das ignorieren und rufen daher gleich `next` auf um
zum nächsten Wert zu gelangen und den ersten Rückgabewert zu überspringen. Als
Nächstes rufen wir `next` auf, um den Wert zu erhalten, den wir in das Feld `query`
von `Config` einfügen möchten. Falls `next` ein `Some` zurückgibt, benutzen wir
`match`, um den Wert zu extrahieren, wenn es jedoch `None` zurückgibt,
bedeutet dies, das nicht genügend Argumente eingegeben wurden und wir kehren
vorzeitig mit einem `Err` zurück. Dasselbe machen wir für den Wert `filename`.

### Programmcode mit Iteratorenadapter klarer gestalten


Wir können die Vorteile der Iteratoren auch in der Funktion `search` unseres
E/A-Projekts nutzen, die hier im Codeblock 13-28 wiedergegeben, ist wie im
Codeblock 12-19:

<span class="filename">Dateiname: src/lib.rs</span>

```rust,ignore
#use std::error::Error;
#use std::fs;
#
#pub struct Config {
#    pub query: String,
#    pub filename: String,
#}
#
#impl Config {
#    pub fn new(args: &[String]) -> Result<Config, &str> {
#        if args.len() < 3 {
#            return Err("nicht genügend Argumente");
#        }
#
#        let query = args[1].clone();
#        let filename = args[2].clone();
#
#        Ok(Config { query, filename })
#    }
#}
#
#pub fn run(config: Config) -> Result<(), Box<dyn Error>> {
#    let contents = fs::read_to_string(config.filename)?;
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

<span class="caption">Codeblock 13-28: Implementierung der Funktion `search`
aus Codeblock 12-19</span>

Wir können diesen Programmcode durch die Verwendung von Iteratoradaptern
prägnanter gestalten und vermeiden, einen veränderlichen Vektor `results` für
die Zwischenergebnisse zu haben. Bevorzugt wird im funktionalen Programmierstil
die Menge der veränderlichen Werte reduziert, um den Code übersichtlicher zu
machen. Das Entfernen des veränderlich-Status kann uns eventuell zukünftige
Verbesserungen ermöglichen, um die Suche parallel auszuführen, da wir uns nicht
um die Verwaltung des simultanen Zugriffs auf den Ergebnisvektor kümmern müssen.

<span class="filename">Dateiname: src/lib.rs</span>

```rust,ignore
#use std::env;
#use std::error::Error;
#use std::fs;
#
#pub struct Config {
#    pub query: String,
#    pub filename: String,
#    pub case_sensitive: bool,
#}
#
#impl Config {
#    pub fn new(mut args: std::env::Args) -> Result<Config, &'static str> {
#        args.next();
#
#        let query = match args.next() {
#            Some(arg) => arg,
#            None => return Err("Keine Abfragezeichenkette erhalten"),
#        };
#
#        let filename = match args.next() {
#            Some(arg) => arg,
#            None => return Err("Keinen Dateinamen erhalten"),
#        };
#
#        let case_sensitive = env::var("CASE_INSENSITIVE").is_err();
#
#        Ok(Config {
#            query,
#            filename,
#            case_sensitive,
#        })
#    }
#}
#
#pub fn run(config: Config) -> Result<(), Box<dyn Error>> {
#    let contents = fs::read_to_string(config.filename)?;
#
#    let results = if config.case_sensitive {
#        search(&config.query, &contents)
#    } else {
#        search_case_insensitive(&config.query, &contents)
#    };
#
#    for line in results {
#        println!("{}", line);
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
<span class="caption">Codeblock 13-29: Verwendung von Iteratoradapter-Methoden
bei der Implementierung der Funktion `search`</span>

Denke daran, der Zweck der Funktion `search` besteht darin, alle Zeilen in
`contents` zurückzugeben, die die `query` enthalten. So ähnlich wie im Beispiel
`filter` im Codeblock 13-19 verwendet dieser Programmcode den `filter`-Adapter,
um nur die Zeilen beizubehalten, für die `line.contains(query)` den Wert `true` zurückgibt.
Wir sammeln dann die passenden Zeilen mit `collect` in einen anderen Vektor.
Viel einfacher! Nimm die gleiche Änderung vor, um Iteratormethoden auch in der
Funktion `search_case_insensitive` zu nutzen.

Die nächste logische Frage wäre, welchen Stil du in deinem eigenen Programmcode
wählen solltest und warum. Die ursprüngliche Implementierung im Codeblock 13-28
oder die Version die Iteratoren verwendet im Codeblock 13-29. Die meisten
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

[lifetime-elision]: ch10-03-lifetime-syntax.html#lebensdauer-elision
