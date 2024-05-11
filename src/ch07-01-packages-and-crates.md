## Pakete (packages) und Kisten (crates)

Die ersten Teile des Modulsystems, die wir behandeln werden, sind Pakete und
Kisten.

Eine *Kiste* ist die kleinste Menge an Code, die der Rust-Compiler zu einem
bestimmten Zeitpunkt berücksichtigt. Selbst wenn du `rustc` anstelle von
`cargo` ausführst und eine einzelne Quellcodedatei übergibst (wie wir es
bereits im Abschnitt „Schreiben und Ausführen eines Rust-Programms“ in Kapitel
1 getan haben), betrachtet der Compiler diese Datei als eine Kiste. Kisten
können Module enthalten, und die Module können in anderen Dateien definiert
sein, die mit der Kiste kompiliert werden, wie wir in den nächsten Abschnitten
sehen werden.

Es gibt zwei Arten von Kisten: Binäre Kisten und Bibliothekskisten. *Binäre
Kisten* (binary crates) sind Programme, die du zu einer ausführbaren Datei
kompilieren und starten kannst, z.B. ein Befehlszeilenprogramm
oder einen Server. Jede muss eine Funktion namens `main` haben, die definiert,
was passiert, wenn die ausführbare Datei läuft. Alle Kisten, die wir bisher
erstellt haben, waren binäre Kisten.

*Bibliothekskisten* (library crates) haben keine `main`-Funktion und sie werden
nicht zu einer ausführbaren Datei kompiliert. Stattdessen definieren sie
Funktionalität, die für mehrere Projekte gemeinsam genutzt werden soll. Zum
Beispiel bietet die Kiste `rand`, die wir in [Kapitel 2][rand] verwendet haben,
Funktionalität, die Zufallszahlen erzeugt. Wenn Rust-Entwickler „Kiste“ sagen,
meinen sie meistens „Bibliothekskiste“, und sie verwenden „Kiste“ austauschbar
mit dem allgemeinen Programmierkonzept einer „Bibliothek“.

Die *Kistenwurzel* ist eine Quelldatei, von der der Rust-Compiler ausgeht und
die das Wurzel-Modul deiner Kiste bildet (Module werden im Abschnitt [„Mit
Modulen den Kontrollumfang und Datenschutz steuern“][modules] ausführlich
erklärt).

Ein *Paket* ist ein Bündel von einer oder mehreren Kisten, die eine Reihe von
Funktionalitäten bereitstellen. Ein Paket enthält eine Datei *Cargo.toml*, die
beschreibt, wie diese Kisten zu bauen sind. Cargo ist eigentlich ein Paket, das
die Binärkiste für das Kommandozeilenwerkzeug enthält, das du zum Erstellen
deines Codes verwendet hast. Das Cargo-Paket enthält auch eine
Bibliothekskiste, von der die binäre Kiste abhängt. Andere Projekte können von
der Cargo-Bibliothekskiste abhängen, um die gleiche Logik wie das
Cargo-Befehlszeilenwerkzeug zu verwenden.

Es gibt zwei Arten von Kisten: Binärkisten und Bibliothekskisten. Ein Paket
kann beliebig viele Binärkisten enthalten, aber höchstens eine
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
sehen, was Cargo erzeugt. Im Projektverzeichnis gibt es eine Datei
*Cargo.toml*, die uns ein Paket gibt. Es gibt auch ein Verzeichnis *src*, das
*main.rs* enthält. Öffne *Cargo.toml* in deinem Texteditor und beachte, dass
*src/main.rs* nicht erwähnt wird. Cargo folgt der Konvention, dass
*src/main.rs* die Kistenwurzel einer binären Kiste mit dem gleichen Namen wie
das Paket ist. Ebenso weiß Cargo, dass, wenn das Paketverzeichnis *src/lib.rs*
enthält, das Paket eine Bibliothekskiste mit dem gleichen Namen wie das Paket
enthält, und *src/lib.rs* deren Kistenstamm ist. Cargo übergibt die
Kistenwurzel-Dateien an `rustc`, um die Bibliothek oder Binärdatei zu bauen.

Hier haben wir ein Paket, das nur *src/main.rs* enthält, d.h. es enthält nur
eine binäre Kiste mit dem Namen `my-project`. Wenn ein Paket *src/main.rs* und
*src/lib.rs* enthält, hat es zwei Kisten: Eine binäre und eine Bibliothek,
beide mit dem gleichen Namen wie das Paket. Ein Paket kann mehrere binäre
Kisten haben, indem es Dateien im Verzeichnis *src/bin* ablegt: Jede Datei ist
dann eine eigene binäre Kiste.

[modules]: ch07-02-defining-modules-to-control-scope-and-privacy.html
[rand]: ch02-00-guessing-game-tutorial.html#generieren-einer-geheimzahl
