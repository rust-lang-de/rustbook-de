# Die Programmiersprache Rust

[Die Programmiersprache Rust](title-page.html)
[Vorwort](foreword.html)
[Einführung](ch00-00-introduction.html)

## Erste Schritte

- [Erste Schritte](ch01-00-getting-started.html)
    - [Installation](ch01-01-installation.html)
    - [Hallo Welt](ch01-02-hello-world.html)
    - [Hallo Cargo](ch01-03-hello-cargo.html)

- [Ein Ratespiel programmieren](ch02-00-guessing-game-tutorial.html)

- [Allgemeine Programmierkonzepte](ch03-00-common-programming-concepts.html)
    - [Variablen und Veränderlichkeit](ch03-01-variables-and-mutability.html)
    - [Datentypen](ch03-02-data-types.html)
    - [Funktionen](ch03-03-how-functions-work.html)
    - [Kommentare](ch03-04-comments.html)
    - [Kontrollfluss](ch03-05-control-flow.html)

- [Eigentümerschaft (ownership) verstehen](ch04-00-understanding-ownership.html)
    - [Was ist Eigentümerschaft (ownership)?](ch04-01-what-is-ownership.html)
    - [Referenzen und Ausleihen (borrowing)](ch04-02-references-and-borrowing.html)
    - [Der Anteilstyp (slice)](ch04-03-slices.html)

- [Strukturen (structs) für zusammenhängende Daten verwenden](ch05-00-structs.html)
    - [Strukturen (structs) definieren und instanziieren](ch05-01-defining-structs.html)
    - [Beispielprogramm mit Strukturen (structs)](ch05-02-example-structs.html)
    - [Methodensyntax](ch05-03-method-syntax.html)

- [Aufzählungen (enums) und Musterabgleich (pattern matching)](ch06-00-enums.html)
    - [Eine Aufzählung (enum) definieren](ch06-01-defining-an-enum.html)
    - [Das Kontrollflusskonstrukt `match`](ch06-02-match.html)
    - [Prägnanter Kontrollfluss mit `if let`](ch06-03-if-let.html)

## Grundlegende Sprachelemente

- [Wachsende Projekte verwalten mit Paketen (packages), Kisten (crates) und Modulen](ch07-00-managing-growing-projects-with-packages-crates-and-modules.html)
    - [Pakete (packages) und Kisten (crates)](ch07-01-packages-and-crates.html)
    - [Mit Modulen den Kontrollumfang und Datenschutz steuern](ch07-02-defining-modules-to-control-scope-and-privacy.html)
    - [Mit Pfaden auf ein Element im Modulbaum verweisen](ch07-03-paths-for-referring-to-an-item-in-the-module-tree.html)
    - [Pfade in den Gültigkeitsbereich bringen mit dem Schlüsselwort `use`](ch07-04-bringing-paths-into-scope-with-the-use-keyword.html)
    - [Module in verschiedene Dateien aufteilen](ch07-05-separating-modules-into-different-files.html)

- [Allgemeine Kollektionen](ch08-00-common-collections.html)
    - [Wertlisten in Vektoren ablegen](ch08-01-vectors.html)
    - [UTF-8-kodierten Text in Zeichenketten (strings) ablegen](ch08-02-strings.html)
    - [Schlüssel mit zugehörigen Werten in Hashtabellen ablegen](ch08-03-hash-maps.html)

- [Fehlerbehandlung](ch09-00-error-handling.html)
    - [Nicht behebbare Fehler mit `panic!`](ch09-01-unrecoverable-errors-with-panic.html)
    - [Behebbare Fehler mit `Result`](ch09-02-recoverable-errors-with-result.html)
    - [Wann `panic!` aufrufen und wann nicht?](ch09-03-to-panic-or-not-to-panic.html)

- [Generische Typen, Merkmale (traits) und Lebensdauer](ch10-00-generics.html)
    - [Generische Datentypen](ch10-01-syntax.html)
    - [Merkmale (traits): Gemeinsames Verhalten definieren](ch10-02-traits.html)
    - [Referenzen validieren mit Lebensdauern](ch10-03-lifetime-syntax.html)

- [Automatisierte Tests schreiben](ch11-00-testing.html)
    - [Tests schreiben](ch11-01-writing-tests.html)
    - [Steuern wie Tests ausgeführt werden](ch11-02-running-tests.html)
    - [Testverwaltung](ch11-03-test-organization.html)

- [Ein E/A-Projekt: Ein Kommandozeilenprogramm erstellen](ch12-00-an-io-project.html)
    - [Kommandozeilenargumente entgegennehmen](ch12-01-accepting-command-line-arguments.html)
    - [Eine Datei einlesen](ch12-02-reading-a-file.html)
    - [Refaktorierung um die Modularität und Fehlerbehandlung zu verbessern](ch12-03-improving-error-handling-and-modularity.html)
    - [Bibliotheksfunktionalität mit testgetriebener Entwicklung erstellen](ch12-04-testing-the-librarys-functionality.html)
    - [Mit Umgebungsvariablen arbeiten](ch12-05-working-with-environment-variables.html)
    - [Fehlermeldungen in die Standardfehlerausgabe anstatt der Standardausgabe schreiben](ch12-06-writing-to-stderr-instead-of-stdout.html)

## Denken in Rust

- [Funktionale Sprachelemente: Iteratoren und Funktionsabschlüsse (closures)](ch13-00-functional-features.html)
    - [Funktionsabschlüsse (closures): Anonyme Funktionen, die ihre Umgebung erfassen können](ch13-01-closures.html)
    - [Eine Reihe von Elementen verarbeiten mit Iteratoren](ch13-02-iterators.html)
    - [Unser E/A-Projekt verbessern](ch13-03-improving-our-io-project.html)
    - [Performanzvergleich: Schleifen vs. Iteratoren](ch13-04-performance.html)

- [Mehr über Cargo und Crates.io](ch14-00-more-about-cargo.html)
    - [Bauvorgang anpassen mit Freigabeprofilen (release profiles)](ch14-01-release-profiles.html)
    - [Kisten (crate) auf crates.io veröffentlichen](ch14-02-publishing-to-crates-io.html)
    - [Cargo-Arbeitsbereiche](ch14-03-cargo-workspaces.html)
    - [Installieren von Binärdateien mit  `cargo install`](ch14-04-installing-binaries.html)
    - [Cargo um benutzerdefinierte Befehle erweitern](ch14-05-extending-cargo.html)

- [Intelligente Zeiger](ch15-00-smart-pointers.html)
    - [Mit `Box<T>` auf Daten im Haldenspeicher zeigen](ch15-01-box.html)
    - [Intelligente Zeiger wie normale Referenzen behandeln mit dem Merkmal (trait) `Deref`](ch15-02-deref.html)
    - [Programmcode beim Aufräumen ausführen mit dem Merkmal (trait) `Drop`](ch15-03-drop.html)
    - [Der referenzzählende intelligente Zeiger `Rc<T>`](ch15-04-rc.html)
    - [`RefCell<T>` und das innere Veränderlichkeitsmuster](ch15-05-interior-mutability.html)
    - [Referenzzyklen können zu einem Speicherleck führen](ch15-06-reference-cycles.html)

- [Furchtlose Nebenläufigkeit](ch16-00-concurrency.html)
    - [Mit Strängen (threads) Programmcode gleichzeitig ausführen](ch16-01-threads.html)
    - [Nachrichtenaustausch zwischen Strängen (threads)](ch16-02-message-passing.html)
    - [Nebenläufigkeit mit gemeinsamem Zustand](ch16-03-shared-state.html)
    - [Erweiterbare Nebenläufigkeit mit den Merkmalen (traits) `Sync` und `Send`](ch16-04-extensible-concurrency-sync-and-send.html)

- [Objektorientierte Sprachelemente von Rust](ch17-00-oop.html)
    - [Charakteristiken objektorientierter Sprachen](ch17-01-what-is-oo.html)
    - [Merkmalsobjekte (trait objects) die Werte unterschiedlicher Typen erlauben](ch17-02-trait-objects.html)
    - [Ein objektorientiertes Entwurfsmuster implementieren](ch17-03-oo-design-patterns.html)

## Fortgeschrittene Themen

- [Muster (patterns) und Abgleich (matching)](ch18-00-patterns.html)
    - [Alle Stellen an denen Muster (patterns) verwendet werden können](ch18-01-all-the-places-for-patterns.html)
    - [Abweisbarkeit: Falls ein Muster (pattern) mal nicht passt](ch18-02-refutability.html)
    - [Mustersyntax](ch18-03-pattern-syntax.html)

- [Fortgeschrittene Sprachelemente](ch19-00-advanced-features.html)
    - [Unsicheres (unsafe) Rust](ch19-01-unsafe-rust.html)
    - [Fortgeschrittene Merkmale (traits)](ch19-03-advanced-traits.html)
    - [Fortgeschrittene Typen](ch19-04-advanced-types.html)
    - [Erweiterte Funktionen und Funktionsabschlüsse (closures)](ch19-05-advanced-functions-and-closures.html)
    - [Makros](ch19-06-macros.html)

- [Abschlussprojekt: Einen mehrsträngigen (multi-threaded) Webserver erstellen](ch20-00-final-project-a-web-server.html)
    - [Einen einsträngigen (single-threaded) Webserver erstellen](ch20-01-single-threaded.html)
    - [Unseren einsträngigen (single-threaded) Webserver in einen mehrsträngigen (multi-threaded) Webserver verwandeln](ch20-02-multithreaded.html)
    - [Kontrolliertes Beenden und Aufräumen](ch20-03-graceful-shutdown-and-cleanup.html)

- [Anhang](appendix-00.html)
    - [A - Schlüsselwörter](appendix-01-keywords.html)
    - [B - Operatoren und Symbole](appendix-02-operators.html)
    - [C - Ableitbare Merkmale (traits)](appendix-03-derivable-traits.html)
    - [D - Nützliche Entwicklungswerkzeuge](appendix-04-useful-development-tools.html)
    - [E - Ausgaben](appendix-05-editions.html)
    - [F - Übersetzungen des Buchs](appendix-06-translation.html)
    - [G - Wie Rust erstellt wird und „nächtliches Rust“](appendix-07-nightly-rust.html)
