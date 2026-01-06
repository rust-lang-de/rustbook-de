## Pakete (packages) und Kisten (crates)

Die ersten Teile des Modulsystems, die wir behandeln werden, sind Pakete und
Kisten.

Eine _Kiste_ ist die kleinste Menge an Code, die der Rust-Compiler zu einem
bestimmten Zeitpunkt berücksichtigt. Selbst wenn du `rustc` anstelle von
`cargo` ausführst und eine einzelne Quellcodedatei übergibst (wie wir es
bereits im Abschnitt [„Grundlagen eines Rust-Programms“][basics] in Kapitel 1
getan haben), betrachtet der Compiler diese Datei als eine Kiste. Kisten können
Module enthalten, und die Module können in anderen Dateien definiert sein, die
mit der Kiste kompiliert werden, wie wir in den nächsten Abschnitten sehen
werden.

Es gibt zwei Arten von Kisten: Binäre Kisten und Bibliothekskisten. _Binäre
Kisten_ (binary crates) sind Programme, die du zu einer ausführbaren Datei
kompilieren und starten kannst, z.B. ein Befehlszeilenprogramm
oder einen Server. Jede muss eine Funktion namens `main` haben, die definiert,
was passiert, wenn die ausführbare Datei läuft. Alle Kisten, die wir bisher
erstellt haben, waren binäre Kisten.

_Bibliothekskisten_ (library crates) haben keine Funktion `main` und sie werden
nicht zu einer ausführbaren Datei kompiliert. Stattdessen definieren sie
Funktionalität, die für mehrere Projekte gemeinsam genutzt werden soll. Zum
Beispiel bietet die Kiste `rand`, die wir in [Kapitel 2][rand] verwendet haben,
Funktionalität, die Zufallszahlen erzeugt. Wenn Rust-Entwickler „Kiste“ sagen,
meinen sie meistens „Bibliothekskiste“, und sie verwenden „Kiste“ austauschbar
mit dem allgemeinen Programmierkonzept einer „Bibliothek“.

Die _Kistenwurzel_ ist eine Quelldatei, von der der Rust-Compiler ausgeht und
die das Wurzel-Modul deiner Kiste bildet (Module werden in [„Kontrollumfang und
Datenschutz mit Modulen“][modules] ausführlich erklärt).

Ein _Paket_ ist ein Bündel von einer oder mehreren Kisten, die eine Reihe von
Funktionalitäten bereitstellen. Ein Paket enthält eine Datei _Cargo.toml_, die
beschreibt, wie diese Kisten zu bauen sind. Cargo ist eigentlich ein Paket, das
die Binärkiste für das Kommandozeilenwerkzeug enthält, das du zum Erstellen
deines Codes verwendet hast. Das Cargo-Paket enthält auch eine
Bibliothekskiste, von der die binäre Kiste abhängt. Andere Projekte können von
der Bibliothekskiste Cargo abhängen, um die gleiche Logik wie das
Befehlszeilenwerkzeug Cargo zu verwenden.

Ein Paket kann beliebig viele Binärkisten enthalten, aber höchstens eine
Bibliothekskiste. Ein Paket muss mindestens eine Kiste enthalten, unabhängig
davon, ob es sich um eine Bibliothek oder eine binäre Kiste handelt.

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
_src/main.rs_ nicht erwähnt wird. Cargo folgt der Konvention, dass
_src/main.rs_ die Kistenwurzel einer binären Kiste mit dem gleichen Namen wie
das Paket ist. Ebenso weiß Cargo, dass, wenn das Paketverzeichnis _src/lib.rs_
enthält, das Paket eine Bibliothekskiste mit dem gleichen Namen wie das Paket
enthält, und _src/lib.rs_ deren Kistenstamm ist. Cargo übergibt die
Kistenwurzel-Dateien an `rustc`, um die Bibliothek oder Binärdatei zu bauen.

Hier haben wir ein Paket, das nur _src/main.rs_ enthält, d.h. es enthält nur
eine binäre Kiste mit dem Namen `my-project`. Wenn ein Paket _src/main.rs_ und
_src/lib.rs_ enthält, hat es zwei Kisten: Eine binäre und eine Bibliothek,
beide mit dem gleichen Namen wie das Paket. Ein Paket kann mehrere binäre
Kisten haben, indem es Dateien im Verzeichnis _src/bin_ ablegt: Jede Datei ist
dann eine eigene binäre Kiste.

[basics]: ch01-02-hello-world.html#grundlagen-eines-rust-programms
[modules]: ch07-02-defining-modules-to-control-scope-and-privacy.html
[rand]: ch02-00-guessing-game-tutorial.html#generieren-einer-geheimzahl
