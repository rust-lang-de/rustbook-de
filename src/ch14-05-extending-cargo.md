## Cargo um benutzerdefinierte Befehle erweitern

Cargo ist so konzipiert, dass man es mit neuen Unterbefehlen erweitern kann,
ohne Cargo ändern zu müssen. Wenn eine Binärdatei in deinen `$PATH`
`cargo-something` benannt wird, kannst du sie wie einen Unterbefehl von Cargo
ausführen, indem du `cargo something` ausführst. Benutzerdefinierte Befehle wie
dieser werden auch aufgelistet, wenn du `cargo --list` ausführst. Die
Möglichkeit, mithilfe von `cargo install` Erweiterungen zu installieren und
diese dann wie die integrierten Werkzeuge von Cargo auszuführen, ist ein
äußerst praktischer Vorteil des Cargo-Designs!

## Zusammenfassung

Das veröffentlichen von Programmcode mit Cargo und [crates.io](https://crates.io/)<!-- ignore -->
ist Teil dessen, was das Rust-Ökosystem für viele verschiedene Aufgaben nützlich
macht. Die Standardbibliothek von Rust ist klein und stabil, aber Kisten können
einfach geteilt, verwendet und auf einer von der Sprache unterschiedlichen
Zeitlinie verbessert werden. Scheue dich nicht, Programmcode von 
[crates.io](https://crates.io/)<!-- ignore-->, der für dich nützlich ist zu
veröffentlichen. Es ist wahrscheinlich, dass er auch für andere nützlich sein
wird!
