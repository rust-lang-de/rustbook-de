## Installieren von Binärdateien mit  `cargo install`

Mit dem Befehl `cargo install` kannst du Binärkisten installieren und verwenden.
Dies soll keine Systempakete ersetzen, sondern soll Rust-Entwicklern eine
bequeme Möglichkeit bieten, Tools zu installieren, die andere auf
[crates.io](https://crates.io/) veröffentlicht haben. Beachte,
dass du nur binäre Pakete installieren kannst, das heißt in der Kiste muss eine
Datei *src/main.rs* oder eine andere als binär spezifizierte Datei vorhanden
sein, und nicht nur eine Bibliothek, die alleine nicht ausführbar ist sondern zur 
Aufnahme in andere Programme geeignet ist. Für gewöhnlich enthalten Kisten eine
*README*-Datei mit Informationen darüber ob die Datei ausführbar ist, eine
Bibliothek enthält oder beides.

Alle mit `cargo install` installierten Binärdateien werden im Verzeichnis *bin* 
des Wurzelverzeichnisses der Installation gespeichert. Wenn du die Installation
mit *rustup.rs* durchgeführt und keine benutzerdefinierte Konfiguration
hast, lautet dieses Verzeichnis *$HOME/.cargo/bin*. Stelle sicher, dass sich
dieses Verzeichnis in deinem `$PATH` befindet, damit du Programme ausführen
kannst, die du mit `cargo install` installiert hast.

In Kapitel 12 haben wir beispielsweise erwähnt, dass es eine
Rust-Implementierung namens `ripgrep` des Werkzeugs `grep` zum Durchsuchen von
Dateien gibt. Um `ripgrep` zu installieren, führen wir Folgendes aus:

```console
$ cargo install ripgrep
    Updating crates.io index
  Downloaded ripgrep v11.0.2
  Downloaded 1 crate (243.3 KB) in 0.88s
  Installing ripgrep v11.0.2
--abschneiden--
   Compiling ripgrep v11.0.2
    Finished release [optimized + debuginfo] target(s) in 3m 10s
  Installing ~/.cargo/bin/rg
   Installed package `ripgrep v11.0.2` (executable `rg`)
```

Die vorletzte Zeile der Ausgabe zeigt den Speicherort und den Namen der
installierten Binärdatei, der im Fall von `ripgrep` `rg` ist. Solange sich das
Installationsverzeichnis in deinem `$PATH` befindet, kannst du `rg --help`
ausführen und damit beginnen ein schnelleres, in Rust programmiertes
Werkzeug zum Durchsuchen von Dateien verwenden!
