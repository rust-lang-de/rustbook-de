# Hallo Cargo!

[Cargo][cratesio] ist ein Werkzeug, welches Rustler benutzen um ihre Rust
Projekte zu verwalten. Cargo ist derzeit in einem pre-1.0 Zustand und ist somit
immernoch in Arbeit. Jedoch ist es bereits gut genug es für viele Rust Projekte
einzusetzen und somit wird vorausgesetzt, dass Rust Projekte Cargo von Anfang
an einsetzen.

[cratesio]: http://doc.crates.io

Cargo verwaltet drei Sachen: Das bauen des Codes, das Herunterladen der
Abhängigkeiten, welche dein Projekt benötigt und
das Bauen dieser Abhängigkeiten. Zu Anfang hat dein Programm keine
Abhängigkeiten. Also wirst du nur den ersten Teil an Funktionalität nutzen.
Später wirst du komplexere Programme mit einigen Abhängigkeiten erstellen
und dann macht es sich bezahlt, dass du Cargo von Anfang an genutzt hast.

Wenn du Rust mit dem offiziellen Installer installiert hast, dann wirst du
auch Cargo haben. Wenn du allerdings Rust auf eine andere Art und Weise
installiert hast, dann möchtest du möglicherweise einen Blick in die
[Cargo README][cargoreadme] werfen um herauszufinden, wie man Cargo installiert.

[cargoreadme]: https://github.com/rust-lang/cargo#installing-cargo-from-nightlies

## Nach Cargo umwandeln

Lass uns unser 'Hallo Welt'-Projekt nach Cargo umwandeln.

Um ein Projekt zu "Cargoifizieren" benötigen wir drei Dinge:
Erstelle eine `Cargo.toml` Konfigurationsdatei, lege die Quelltexte an den
richtigen Platz und entferne die alte ausführbare Datei (`main.exe` unter
Windows, `main` sonst wo). Lass uns den ersten Teil zuerst machen:

```bash
$ mkdir src
$ mv main.rs src/main.rs
$ rm main  # oder main.exe unter Windows
```

Da wir eine ausführbare Datei erstellen behalten wir `main.rs` als
Dateiname bei. Wenn wir stattdessen eine Bibliothek erstellen wollten,
müssten wir `lib.rs` verwenden. Diese Konvention wird von Cargo benutzt um
unsere Projekte erfolgreich zu kompilieren. Wenn wir wollen, dann können
wir diese Konvention auch außer Kraft setzen.

[crates-custom]: http://doc.crates.io/manifest.html#configuring-a-target

Cargo erwartet, dass deine Quelltexte in einem `src`-Verzeichnis liegen.
Das lässt das oberste Verzeichnis für andere Sachen wie READMEs,
Lizenzinformationen und anderen Dingen, die nichts mit deinem
Code zu tun haben, frei. 
<!-- A place for everything, and everything in its place. -->

Als nächstes unsere Konfigurationsdatei:

```bash
$ editor Cargo.toml
```

Stelle sicher, dass der Name korrekt ist: Das große `C` ist notwendig!

Schreib das hier hinein:

```toml
[package]

name = "hallo_welt"
version = "0.0.1"
authors = [ "Dein Name <du@example.com>" ]
```

Diese Datei ist im [TOML][toml]-Format. TOML ist ähnlich wie INI, aber hat ein
paar tolle Extra-Funktionen. Der TOML-Dokumentation zufolge

> Zielt TOML darauf ab ein minimales Konfigurationsformat zu sein, welches
> aufgrund seiner offensichtlichen Semantik, leicht zu lesen ist. TOML ist
> dazu designt eindeutig auf eine Hashtabelle abzubilden. Toml sollte in einer
> breiten Vielzahl von Sprachen leicht in Datenstrukturen zu parsen sein.

[toml]: https://github.com/toml-lang/toml

Sobald wir diese Datei im Wurzelverzeichnis unseres Projektes haben, sind wir
auch schon bereit es zu bauen! Um das zu tun, führe dies aus:

```bash
$ cargo build
   Compiling hallo_welt v0.0.1 (file:///home/deinname/projekte/hallo_welt)
$ ./target/debug/hallo_welt
Hallo Welt!
```

Bumm! Wir haben unser Projekt mit `cargo build` gebaut und es mit
`./target/debug/hallo_welt` ausgeführt. Wir können beides auch in
einem einzigen Schritt machen mittels `cargo run`:

```bash
$ cargo run
     Running `target/debug/hallo_welt`
Hallo Welt!
```

Beachte, dass dieses mal das Projekt nicht neu kompiliert wurde. Cargo hat
selber herausgefunden, dass wir den Quelltext nicht verändert haben und hat
einfach nur die Binärdatei ausgeführt. Hätten wor eine Veränderung
vorgenommen, dann hätten wir beides gesehen:

```bash
$ cargo run
   Compiling hallo_welt v0.0.1 (file:///home/deinname/projekte/hallo_welt)
     Running `target/debug/hallo_welt`
Hallo Welt!
```

Dies hat uns nicht viel mehr eingebracht als einfach nur `rustc` zu benutzen.
Aber denk an Zukunft: Wenn unser Projekt komplexer wird, dann müssen wir
mehr machen um alle Teile zusammen ordentlich zum Kompilieren zu bringen.
Mit Cargo können wir, während unser Projekt wächst, einfach `cargo build`
aufrufen und unser Projekt wird sofort auf die richtige Art und Weise gebaut.

Wenn unser Projekt dann endlich fertig zum Release ist, kannst du einfach
`cargo build --release` benutzen um dein Projekt mit Optimierungen zu
kompilieren.

Do wirst auch feststellen, dass Cargo eine neue Datei erzeugt hat: `Cargo.lock`.

```toml
[root]
name = "hello_world"
version = "0.0.1"
```

Die `Cargo.lock`-Datei wird von Cargo benutzt, um deine Abhängigkeit zu
verfolgen. Im Moment haben wir keine, also ist sie etwas dürftig.
Du wirst diese Datei niemals selber anfassen müssen. Lass einfach Cargo
die Sache regeln.

Das wars! Wir haben `hallo_welt` erfolgreich mit Cargo gebaut. Obwohl das
Programm simpel ist, benutzt es viele der Werkzeuge die du für den Rest
deiner Rust-Karriere brauchst. <!-- klingt etwas merkwürdig -->
Du kannst erwarten, dass du mit nahezu allen Rust-Projekten so
loslegen kannst:

```bash
$ git clone someurl.com/foo
$ cd foo
$ cargo build
```

## Ein neues Projekt

Du brauchst nicht jedes mal durch alle diese Schritte gehen, wenn du ein neues
Projekt anfängst! Cargo hat die Fähigkeit ein Gerüst-Projekt zu erzeugen, mit
dem du sofort anfangen kannst zu entwickeln.

Um eine neues Projekt mit Cargo anzufangen benutze `cargo new`:

```bash
$ cargo new hallo_welt --bin
```

Wir übergeben `--bin`, da es unser Ziel ist eine ausführbare Anwendung,
anstatt einer Bibliothek, zu erzeugen. Ausführbare Dateien werden oft 
‘binaries’ genannt.
(So wie in `/usr/bin`, falls du auf einem Unix System bist).

Lass uns mal sehen welche Dateien Cargo für uns erzeugt hat:

```bash
$ cd hallo_welt
$ tree .
.
├── Cargo.toml
└── src
    └── main.rs

1 directory, 2 files
```

Falls du den `tree`-Befehl nicht hast, dann kannst du ihn dir wahrscheinlich
mithilfe der Paketverwaltung deiner Distribution besogen. Der Befehl ist nicht
notwendig, aber sicherlich nützlich.

Das ist alles was wir brauchen um loszulegen. Lass uns zuerst die `Cargo.toml` betrachten.

```toml
[package]

name = "hallo_welt"
version = "0.1.0"
authors = ["Dein Name <du@example.com>"]
```

Cargo hat diese Datei mit einigen Vorgaben, basierend auf den von dir
übergebenen Argumenten und deiner globalen `git`-Konfiguration, gefüllt.
Du wirst vielleicht bemerken, dass Cargo das `hallo_welt`-Verzeichnis auch
als `git`-Repository initialisiert hat.

Das hier steht in der `src/main.rs`:

```rust
fn main() {
    println!("Hello, world!");
}
```

Cargo hat ein "Hallo Welt!" für uns erzeugt und du kannst sofort mit dem Coden
loslegen!
Cargo hat seinen eigenen [Guide][guide], welcher die Features von Cargo in
größerem Detail behandelt.

[guide]: http://doc.crates.io/guide.html

Da du nun mit den Werkzeugen vertraut bist, lass uns tatsächlich mehr über
die Sprache Rust selbst lernen. Dies sind die Grundlagen, welche dir den Rest
deiner Zeit mit Rust sehr dienlich sein werden.

Du hast Zwei Möglichkeiten:
Entweder stürzt du dich in ein Projekt mit ‘[Lerne Rust][learnrust]’,
oder du arbeitest dir deinen Weg von unten nach oben mit
‘[Syntax und Semantik][syntax]’.
Erfahrene Systemprogrammierer werden ‘Lerne Rust’ mit sicherheit vorziehen, während Leute
mit Hintergrund in dynamischen Sprachen beides bevorzugen könnten.
Verschiedene Leute lernen verschieden! Wähle was Dir am besten liegt.

[learnrust]: Lerne_Rust.md
[syntax]: Syntax_Und_Semantik.md
