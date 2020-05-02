# Die Programmiersprache Rust

*von Steve Klabnik und Carol Nichols, unter Mitarbeit der Rust-Gemeinschaft*

Diese Version des Textes geht davon aus, dass du Rust 1.41.0 oder später mit
`edition="2018"` in *Cargo.toml* in allen Projekten verwendest, um Rust 2018
Idiome zu verwenden. Siehe [Abschnitt „Installation“][install] zum Installieren
und Aktualisieren von Rust sowie [Anhang E][editions] zu Informationen zu den
Ausgaben.

Ausgabe 2018 von Rust enthält einige Verbesserungen, die Rust ergonomischer und
einfacher zu lernen machen. Diese Fassung des Buchs enthält eine Reihe von
Änderungen, die diese Verbesserungen widerspiegeln:

- Kapitel 7 „Wachsende Projekte verwalten mit Paketen (packages), Kisten
  (crates) und Modulen“ wurde größtenteils umgeschrieben. Das Modulsystem und
  die Funktionsweise der Pfade in Ausgabe 2018 wurden konsistenter gestaltet.
- Kapitel 10 hat die neuen Abschnitte „Merkmale als Parameter“ und
  „Rückgabetypen die Merkmale implementieren“, die die neue Syntax von
  `impl Trait` erklären.
- Kapitel 11 hat einen neuen Abschnitt „Verwenden von `Result<T, E>` in Tests“,
  der zeigt, wie man Tests schreibt, die den Operator `?` verwenden.
- Der Abschnitt „Fortgeschrittene Lebensdauern“ in Kapitel 19 wurde entfernt,
  weil die verwendeten Konstrukte durch Kompilierer-Verbesserungen noch
  seltener geworden sind.
- Der frühere Anhang D „Makros“ wurde um prozedurale Makros erweitert und in
  den Abschnitt „Makros“ in Kapitel 19 verschoben.
- Anhang A „Schlüsselwörter“ erläutert auch die neue Funktionalität der rohen
  Bezeichner, die es ermöglicht, dass in Ausgabe 2015 und in Ausgabe 2018
  geschriebener Programmcode zusammen verwendet werden kann.
- Anhang D trägt jetzt den Titel „Nützliche Entwicklungswerkzeuge“ und umfasst
  kürzlich veröffentlichte Werkzeuge, die dir beim Schreiben von Rust-Code
  helfen.
- Wir haben im gesamten Buch etliche kleine Fehler und unpräzise Formulierungen
  korrigiert. Vielen Dank an die Leser, die sie gemeldet haben!

Beachte, dass jeder kompilierbare Programmcode aus früheren Fassungen des Buchs
weiterhin kompiliert, wenn `edition="2018"` nicht in *Cargo.toml* des Projekts
nicht angegeben wird, selbst wenn du die verwendete Rust-Kompilierer-Version
aktualisierst. Das ist die Rückwärtskompatibilitätsgarantie von Rust!

Die HTML-Version ist online verfügbar unter
https://doc.rust-lang.org/stable/book/ (englisches Original) und
https://rust-lang-de.github.io/rustbook-de/ (deutsche Übersetzung).
Wenn die Rust-Installation mit `rustup` erfolgt ist, kann das Buch offline mit
`rustup docs --book` geöffnet werden (nur in Englisch).

Der englische Text ist auch als [Taschenbuch und E-Book bei No Starch
Press][nsprust] erhältlich.

[install]: ch01-01-installation.html
[editions]: appendix-05-editions.html
[nsprust]: https://nostarch.com/rust
