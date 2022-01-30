## Pakete (packages) und Kisten (crates)

Die ersten Bestandteile des Modulsystems, die wir behandeln werden, sind Pakete
(packages) und Kisten (crates). Eine Kiste ist eine Binärdatei oder eine
Bibliothek. Die *Kistenwurzel* (crate root) ist eine Quelldatei, bei der der
Rust-Compiler anfängt und die das Wurzelmodul deiner Kiste darstellt (Module
werden im Abschnitt [„Mit Modulen den Kontrollumfang und Datenschutz
steuern“][modules] ausführlich erklärt). Ein *Paket* besteht aus einer oder
mehreren Kisten, die eine Reihe von Funktionalitäten bereitstellen. Ein Paket
enthält eine Datei *Cargo.toml*, die beschreibt, wie man diese Kisten baut.

Mehrere Regeln bestimmen, was ein Paket enthalten kann. Ein Paket kann *maximal
eine* Bibliothekskiste enthalten. Sie kann so viele binäre Kisten
enthalten, wie du möchtest, aber sie muss mindestens eine Kiste enthalten
(egal ob Bibliothek oder binär).

Lass uns durchgehen, was passiert, wenn wir ein Paket erstellen. Zuerst geben
wir den Befehl `cargo new` ein:

```console
$ cargo new my-project
     Created binary (application) `my-project` package
$ ls my-project
Cargo.toml
src
$ ls my-project/src
main.rs
```

Nachdem wir den Befehl eingegeben haben, erstellte Cargo eine Datei
*Cargo.toml* und gab uns ein Paket. Wenn man sich den Inhalt von *Cargo.toml*
ansieht, wird *src/main.rs* nicht erwähnt, weil Cargo einer Konvention folgt,
dass *src/main.rs* die Kistenwurzel einer binären Kiste mit dem gleichen Namen
wie das Paket ist. Ebenso weiß Cargo, dass, wenn im Paketverzeichnis
*src/lib.rs* enthalten ist, das Paket eine Bibliothekskiste mit dem gleichen
Namen wie das Paket enthält und *src/lib.rs* seine Kistenwurzel ist. Cargo
übergibt die Kistenwurzeldateien an `rustc`, um die Bibliothek oder Binärdatei
zu bauen.

Hier haben wir ein Paket, das nur *src/main.rs* enthält, was bedeutet, dass es
nur eine binäre Kiste namens `my-project` enthält. Wenn ein Paket
*src/main.rs* und *src/lib.rs* enthält, hat es zwei Kisten: Eine Binärdatei und
eine Bibliothek, beide mit dem gleichen Namen wie das Paket. Ein Paket kann
mehrere Binär-Kisten haben, indem Dateien im Verzeichnis *src/bin* abgelegt
werden: Jede Datei wird eine separate Binär-Kiste sein. Eine Kiste fasst
verwandte Funktionalitäten in einen Gültigkeitsbereich zusammen, sodass die
Funktionalität leicht von mehreren Projekten gemeinsam genutzt werden kann. Zum
Beispiel bietet die in [Kapitel 2][rand] verwendete Kiste `rand` eine
Funktionalität, die Zufallszahlen erzeugt. Wir können diese Funktionalität in
unseren eigenen Projekten nutzen, indem wir die Kiste `rand` in den
Gültigkeitsbereich unseres Projekts aufnehmen. Die gesamte Funktionalität, die
von der Kiste `rand` zur Verfügung gestellt wird, ist über den Namen `rand` der
Kiste zugänglich.

Das Beibehalten der Funktionalität einer Kiste in ihrem eigenen
Gültigkeitsbereich klärt, ob eine bestimmte Funktionalität in unserer Kiste
oder in der Kiste `rand` definiert ist, und verhindert potenzielle Konflikte.
Zum Beispiel bietet die Kiste `rand` ein Merkmal (trait) namens `Rng`. Wir
können auch eine Struktur (struct) mit dem Namen `Rng` in unserer eigenen Kiste
definieren. Da die Funktionalität einer Kiste im Namensraum des eigenen
Gültigkeitsbereichs ist, können wir `rand` als Abhängigkeit hinzufügen, ohne
dadurch den Compiler durcheinanderzubringen, worauf sich der Name `Rng`
bezieht. In unserer Kiste bezieht er sich auf `struct Rng`, die wir definiert
haben. Wir würden auf das Merkmal `Rng` aus der Kiste `rand` mit `rand::Rng`
zugreifen.

Lass uns weitermachen und über das Modulsystem sprechen!

[modules]: ch07-02-defining-modules-to-control-scope-and-privacy.html
[rand]: ch02-00-guessing-game-tutorial.html#generieren-einer-geheimzahl
