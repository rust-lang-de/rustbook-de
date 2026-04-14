## Pakete (packages) und Crates

Die ersten Teile des Modulsystems, die wir behandeln werden, sind Pakete und
Crates.

Eine _Crate_ (engl. Kiste) ist die kleinste Menge an Code, die der Rust-Compiler
zu einem bestimmten Zeitpunkt berücksichtigt. Selbst wenn du `rustc` anstelle
von `cargo` ausführst und eine einzelne Quellcodedatei übergibst (wie wir es
bereits im Abschnitt [„Grundlagen eines Rust-Programms“][basics] in Kapitel 1
getan haben), betrachtet der Compiler diese Datei als eine Crate. Crates können
Module enthalten, und die Module können in anderen Dateien definiert sein, die
mit der Crate kompiliert werden, wie wir in den nächsten Abschnitten sehen
werden.

Es gibt zwei Arten von Crates: Binäre Crates und Bibliotheks-Crates. _Binäre
Crates_ (binary crates) sind Programme, die du zu einer ausführbaren Datei
kompilieren und starten kannst, z.B. ein Befehlszeilenprogramm
oder einen Server. Jede muss eine Funktion namens `main` haben, die definiert,
was passiert, wenn die ausführbare Datei läuft. Alle Crates, die wir bisher
erstellt haben, waren binäre Crates.

_Bibliotheks-Crates_ (library crates) haben keine Funktion `main` und sie werden
nicht zu einer ausführbaren Datei kompiliert. Stattdessen definieren sie
Funktionalität, die für mehrere Projekte gemeinsam genutzt werden soll. Zum
Beispiel bietet die Crate `rand`, die wir in [Kapitel 2][rand] verwendet haben,
Funktionalität, die Zufallszahlen erzeugt. Wenn Rust-Entwickler „Crate“ sagen,
meinen sie meistens „Bibliotheks-Crates“, und sie verwenden „Crate“ austauschbar
mit dem allgemeinen Programmierkonzept einer „Bibliothek“.

Die _Crate-Wurzel_ ist eine Quelldatei, von der der Rust-Compiler ausgeht und
die das Wurzel-Modul deiner Crate bildet (Module werden in [„Kontrollumfang und
Datenschutz mit Modulen“][modules] ausführlich erklärt).

Ein _Paket_ ist ein Bündel von einer oder mehreren Crates, die eine Reihe von
Funktionalitäten bereitstellen. Ein Paket enthält eine Datei _Cargo.toml_, die
beschreibt, wie diese Crates zu bauen sind. Cargo ist eigentlich ein Paket, das
die binäre Crate für das Kommandozeilenwerkzeug enthält, das du zum Erstellen
deines Codes verwendet hast. Das Cargo-Paket enthält auch eine
Bibliotheks-Crate, von der die binäre Crate abhängt. Andere Projekte können von
der Bibliotheks-Crate Cargo abhängen, um die gleiche Logik wie das
Befehlszeilenwerkzeug Cargo zu verwenden.

Ein Paket kann beliebig viele binäre Crates enthalten, aber höchstens eine
Bibliotheks-Crate. Ein Paket muss mindestens eine Crate enthalten, unabhängig
davon, ob es sich um eine Bibliotheks-Crate oder eine binäre Crate handelt.

Lass uns durchgehen, was passiert, wenn wir ein Paket erstellen. Zuerst geben
wir den Befehl `cargo new my-project` ein:

```console
$ cargo new my-project
     Created binary (application) `my-project` package
$ ls my-project
Cargo.toml
src
$ ls my-project/src
main.rs
```

Nachdem wir `cargo new my-project` ausgeführt haben, verwenden wir `ls`, um zu
sehen, was Cargo erzeugt. Im Projektverzeichnis _my-project_ gibt es eine Datei
_Cargo.toml_, die uns ein Paket gibt. Es gibt auch ein Verzeichnis _src_, das
_main.rs_ enthält. Öffne _Cargo.toml_ in deinem Texteditor und beachte, dass
_src/main.rs_ nicht erwähnt wird. Cargo folgt der Konvention, dass _src/main.rs_
die Crate-Wurzel einer binären Crate mit dem gleichen Namen wie das Paket ist.
Ebenso weiß Cargo, dass, wenn das Paketverzeichnis _src/lib.rs_ enthält, das
Paket eine Bibliotheks-Crate mit dem gleichen Namen wie das Paket enthält, und
_src/lib.rs_ deren Crate-Wurzel ist. Cargo übergibt die Crate-Wurzel-Dateien an
`rustc`, um die Bibliothek oder Binärdatei zu bauen.

Hier haben wir ein Paket, das nur _src/main.rs_ enthält, d.h. es enthält nur
eine binäre Crate mit dem Namen `my-project`. Wenn ein Paket _src/main.rs_ und
_src/lib.rs_ enthält, hat es zwei Crates: Eine binäre und eine Bibliothek, beide
mit dem gleichen Namen wie das Paket. Ein Paket kann mehrere binäre Crates
haben, indem es Dateien im Verzeichnis _src/bin_ ablegt: Jede Datei ist dann
eine eigene binäre Crate.

[basics]: ch01-02-hello-world.html#grundlagen-eines-rust-programms
[modules]: ch07-02-defining-modules-to-control-scope-and-privacy.html
[rand]: ch02-00-guessing-game-tutorial.html#generieren-einer-geheimzahl
