# Die Programmiersprache Rust

[Die Programmiersprache Rust](title-page.md)
[Vorwort](foreword.md)
[Einführung](ch00-00-introduction.md)

## Erste Schritte

- [Erste Schritte](ch01-00-getting-started.md)
    - [Installation](ch01-01-installation.md)
    - [Hallo Welt](ch01-02-hello-world.md)
    - [Hallo Cargo](ch01-03-hello-cargo.md)

- [Ein Ratespiel programmieren](ch02-00-guessing-game-tutorial.md)

- [Allgemeine Programmierkonzepte](ch03-00-common-programming-concepts.md)
    - [Variablen und Veränderbarkeit](ch03-01-variables-and-mutability.md)
    - [Datentypen](ch03-02-data-types.md)
    - [Funktionen](ch03-03-how-functions-work.md)
    - [Kommentare](ch03-04-comments.md)
    - [Kontrollfluss](ch03-05-control-flow.md)

- [Eigentümerschaft (ownership) verstehen](ch04-00-understanding-ownership.md)
    - [Was ist Eigentümerschaft (ownership)?](ch04-01-what-is-ownership.md)
    - [Referenzen und Ausleihen (borrowing)](ch04-02-references-and-borrowing.md)
    - [Der Anteilstyp (slice)](ch04-03-slices.md)

- [Strukturen (structs) für zusammenhängende Daten verwenden](ch05-00-structs.md)
    - [Strukturen (structs) definieren und instanziieren](ch05-01-defining-structs.md)
    - [Beispielprogramm mit Strukturen (structs)](ch05-02-example-structs.md)
    - [Methodensyntax](ch05-03-method-syntax.md)

- [Aufzählungen (enums) und Musterabgleich (pattern matching)](ch06-00-enums.md)
    - [Eine Aufzählung (enum) definieren](ch06-01-defining-an-enum.md)
    - [Das Kontrollflusskonstrukt `match`](ch06-02-match.md)
    - [Prägnanter Kontrollfluss mit `if let`](ch06-03-if-let.md)

## Grundlegende Sprachelemente

- [Wachsende Projekte verwalten mit Paketen (packages), Kisten (crates) und Modulen](ch07-00-managing-growing-projects-with-packages-crates-and-modules.md)
    - [Pakete (packages) und Kisten (crates)](ch07-01-packages-and-crates.md)
    - [Mit Modulen den Kontrollumfang und Datenschutz steuern](ch07-02-defining-modules-to-control-scope-and-privacy.md)
    - [Mit Pfaden auf ein Element im Modulbaum verweisen](ch07-03-paths-for-referring-to-an-item-in-the-module-tree.md)
    - [Pfade in den Gültigkeitsbereich bringen mit dem Schlüsselwort `use`](ch07-04-bringing-paths-into-scope-with-the-use-keyword.md)
    - [Module in verschiedene Dateien aufteilen](ch07-05-separating-modules-into-different-files.md)

- [Allgemeine Kollektionen](ch08-00-common-collections.md)
    - [Wertlisten in Vektoren ablegen](ch08-01-vectors.md)
    - [UTF-8-kodierten Text in Zeichenketten (strings) ablegen](ch08-02-strings.md)
    - [Schlüssel mit zugehörigen Werten in Hashtabellen ablegen](ch08-03-hash-maps.md)

- [Fehlerbehandlung](ch09-00-error-handling.md)
    - [Nicht behebbare Fehler mit `panic!`](ch09-01-unrecoverable-errors-with-panic.md)
    - [Behebbare Fehler mit `Result`](ch09-02-recoverable-errors-with-result.md)
    - [Wann `panic!` aufrufen und wann nicht?](ch09-03-to-panic-or-not-to-panic.md)

- [Generische Typen, Merkmale (traits) und Lebensdauer](ch10-00-generics.md)
    - [Generische Datentypen](ch10-01-syntax.md)
    - [Merkmale (traits): Gemeinsames Verhalten definieren](ch10-02-traits.md)
    - [Referenzen validieren mit Lebensdauern](ch10-03-lifetime-syntax.md)

- [Automatisierte Tests schreiben](ch11-00-testing.md)
    - [Tests schreiben](ch11-01-writing-tests.md)
    - [Steuern wie Tests ausgeführt werden](ch11-02-running-tests.md)
    - [Testverwaltung](ch11-03-test-organization.md)

- [Ein E/A-Projekt: Ein Kommandozeilenprogramm erstellen](ch12-00-an-io-project.md)
    - [Kommandozeilenargumente entgegennehmen](ch12-01-accepting-command-line-arguments.md)
    - [Eine Datei einlesen](ch12-02-reading-a-file.md)
    - [Refaktorierung um die Modularität und Fehlerbehandlung zu verbessern](ch12-03-improving-error-handling-and-modularity.md)
    - [Bibliotheksfunktionalität mit testgetriebener Entwicklung erstellen](ch12-04-testing-the-librarys-functionality.md)
    - [Mit Umgebungsvariablen arbeiten](ch12-05-working-with-environment-variables.md)
    - [Fehlermeldungen in die Standardfehlerausgabe anstatt der Standardausgabe schreiben](ch12-06-writing-to-stderr-instead-of-stdout.md)

## Denken in Rust

- [Funktionale Sprachelemente: Iteratoren und Funktionsabschlüsse (closures)](ch13-00-functional-features.md)
    - [Funktionsabschlüsse (closures): Anonyme Funktionen, die ihre Umgebung erfassen](ch13-01-closures.md)
    - [Eine Reihe von Elementen verarbeiten mit Iteratoren](ch13-02-iterators.md)
    - [Unser E/A-Projekt verbessern](ch13-03-improving-our-io-project.md)
    - [Performanzvergleich: Schleifen vs. Iteratoren](ch13-04-performance.md)

- [Mehr über Cargo und Crates.io](ch14-00-more-about-cargo.md)
    - [Bauvorgang anpassen mit Freigabeprofilen (release profiles)](ch14-01-release-profiles.md)
    - [Kisten (crate) auf crates.io veröffentlichen](ch14-02-publishing-to-crates-io.md)
    - [Cargo-Arbeitsbereiche](ch14-03-cargo-workspaces.md)
    - [Installieren von Binärdateien mit  `cargo install`](ch14-04-installing-binaries.md)
    - [Cargo um benutzerdefinierte Befehle erweitern](ch14-05-extending-cargo.md)

- [Intelligente Zeiger](ch15-00-smart-pointers.md)
    - [Mit `Box<T>` auf Daten im Haldenspeicher zeigen](ch15-01-box.md)
    - [Intelligente Zeiger wie normale Referenzen behandeln mit dem Merkmal (trait) `Deref`](ch15-02-deref.md)
    - [Programmcode beim Aufräumen ausführen mit dem Merkmal (trait) `Drop`](ch15-03-drop.md)
    - [Der referenzzählende intelligente Zeiger `Rc<T>`](ch15-04-rc.md)
    - [`RefCell<T>` und das innere Veränderbarkeitsmuster](ch15-05-interior-mutability.md)
    - [Referenzzyklen können zu einem Speicherleck führen](ch15-06-reference-cycles.md)

- [Furchtlose Nebenläufigkeit](ch16-00-concurrency.md)
    - [Mit Strängen (threads) Programmcode gleichzeitig ausführen](ch16-01-threads.md)
    - [Nachrichtenaustausch zwischen Strängen (threads)](ch16-02-message-passing.md)
    - [Nebenläufigkeit mit gemeinsamem Zustand](ch16-03-shared-state.md)
    - [Erweiterbare Nebenläufigkeit mit den Merkmalen (traits) `Sync` und `Send`](ch16-04-extensible-concurrency-sync-and-send.md)

- [Async und Await](ch17-00-async-await.md)
  - [Futures und die asynchrone Syntax](ch17-01-futures-and-syntax.md)
  - [Nebenläufigkeit mit async](ch17-02-concurrency-with-async.md)
  - [Arbeiten mit einer beliebigen Anzahl von Futures](ch17-03-more-futures.md)
  - [Ströme (streams)](ch17-04-streams.md)
  - [Merkmale für async](ch17-05-traits-for-async.md)
  - [Futures, Aufgaben und Stränge](ch17-06-futures-tasks-threads.md)

- [Objektorientierte Sprachelemente von Rust](ch18-00-oop.md)
    - [Charakteristiken objektorientierter Sprachen](ch18-01-what-is-oo.md)
    - [Merkmalsobjekte (trait objects) die Werte unterschiedlicher Typen erlauben](ch18-02-trait-objects.md)
    - [Ein objektorientiertes Entwurfsmuster implementieren](ch18-03-oo-design-patterns.md)

## Fortgeschrittene Themen

- [Muster (patterns) und Abgleich (matching)](ch19-00-patterns.md)
    - [Alle Stellen an denen Muster (patterns) verwendet werden können](ch19-01-all-the-places-for-patterns.md)
    - [Abweisbarkeit: Falls ein Muster (pattern) mal nicht passt](ch19-02-refutability.md)
    - [Mustersyntax](ch19-03-pattern-syntax.md)

- [Fortgeschrittene Sprachelemente](ch20-00-advanced-features.md)
    - [Unsicheres (unsafe) Rust](ch20-01-unsafe-rust.md)
    - [Fortgeschrittene Merkmale (traits)](ch20-03-advanced-traits.md)
    - [Fortgeschrittene Typen](ch20-04-advanced-types.md)
    - [Erweiterte Funktionen und Funktionsabschlüsse (closures)](ch20-05-advanced-functions-and-closures.md)
    - [Makros](ch20-06-macros.md)

- [Abschlussprojekt: Einen mehrsträngigen (multi-threaded) Webserver erstellen](ch21-00-final-project-a-web-server.md)
    - [Einen einsträngigen (single-threaded) Webserver erstellen](ch21-01-single-threaded.md)
    - [Unseren einsträngigen (single-threaded) Webserver in einen mehrsträngigen (multi-threaded) Webserver verwandeln](ch21-02-multithreaded.md)
    - [Kontrolliertes Beenden und Aufräumen](ch21-03-graceful-shutdown-and-cleanup.md)

- [Anhang](appendix-00.md)
    - [A - Schlüsselwörter](appendix-01-keywords.md)
    - [B - Operatoren und Symbole](appendix-02-operators.md)
    - [C - Ableitbare Merkmale (traits)](appendix-03-derivable-traits.md)
    - [D - Nützliche Entwicklungswerkzeuge](appendix-04-useful-development-tools.md)
    - [E - Ausgaben](appendix-05-editions.md)
    - [F - Übersetzungen des Buchs](appendix-06-translation.md)
    - [G - Wie Rust erstellt wird und „nächtliches Rust“](appendix-07-nightly-rust.md)
