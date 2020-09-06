# Ein E/A-Projekt: Ein Kommandozeilenprogramm erstellen

Dieses Kapitel ist eine Zusammenfassung der vielen Fähigkeiten, die du bisher
gelernt hast, und eine Erkundung einiger weiterer
Standard-Bibliotheks-Funktionalitäten. Wir werden ein Kommandozeilenwerkzeug
erstellen, das mit Datei- und Kommandozeilen-Ein- und -Ausgabe interagiert, um
einige der Rust-Konzepte zu üben, die du bereits gelernt hast.

Rusts Geschwindigkeit, Sicherheit, Ausgabe in eine einzelne Binärdatei und
plattformübergreifende Unterstützung machen es zu einer idealen Sprache zum
Erstellen von Kommandozeilenwerkzeugen. Für unser Projekt werden wir daher eine
eigene Version des klassischen Kommandozeilenwerkzeugs `grep` (**g**lobally
search a **r**egular **e**xpression and **p**rint) erstellen. Im einfachsten
Anwendungsfall durchsucht `grep` eine angegebene Datei nach einer bestimmten
Zeichenkette. Dazu nimmt `grep` als Argumente einen Dateinamen und eine
Zeichenkette. Dann liest es die Datei, findet Zeilen in dieser Datei, die das
Zeichenketten-Argument enthalten, und gibt diese Zeilen aus.

Auf dem Weg dorthin werden wir zeigen, wie wir unser Kommandozeilenwerkzeug
dazu bringen können, Funktionalitäten des Terminals zu nutzen, die viele
Kommandozeilenwerkzeuge nutzen. Wir werden den Wert einer Umgebungsvariablen
lesen, die es dem Benutzer ermöglicht, das Verhalten unseres Werkzeugs zu
konfigurieren. Wir werden Fehlermeldungen auch auf der Standardfehlerausgabe
(`stderr`) statt auf der Standardausgabe (`stdout`) ausgeben, sodass der
Benutzer z.B. eine erfolgreiche Ausgabe in eine Datei umleiten kann, während er
weiterhin Fehlermeldungen auf dem Bildschirm sieht.

Ein Mitglied der Rust-Gemeinschaft, Andrew Gallant, hat bereits eine voll
ausgestattete, sehr schnelle Version von `grep`, genannt `ripgrep`, erstellt.
Im Vergleich dazu wird unsere Version von `grep` ziemlich einfach sein, aber
dieses Kapitel wird dir einiges an Hintergrundwissen vermitteln, das du
benötigst, um ein reales Projekt wie `ripgrep` zu verstehen.

Unser `grep`-Projekt wird eine Reihe von Konzepten kombinieren, die du bisher
gelernt hast:

* Code organisieren (unter Verwendung dessen, was du über Module in [Kapitel
  7][ch7] gelernt hast)
* Verwenden von Vektoren und Zeichenketten (Kollektionen, [Kapitel 8][ch8])
* Fehlerbehandlung ([Kapitel 9][ch9])
* Verwenden von Merkmalen (traits) und Lebensdauer (lifetimes) soweit möglich
  ([Kapitel 10][ch10])
* Schreiben von Tests ([Kapitel 11][ch11])

Wir werden auch kurz Funktionsabschlüsse (closures), Iteratoren und
Merkmalsobjekte (trait objects) vorstellen, die in den Kapiteln [13][ch13] und
[17][ch17] ausführlich behandelt werden.

[ch7]: ch07-00-managing-growing-projects-with-packages-crates-and-modules.html
[ch8]: ch08-00-common-collections.html
[ch9]: ch09-00-error-handling.html
[ch10]: ch10-00-generics.html
[ch11]: ch11-00-testing.html
[ch13]: ch13-00-functional-features.html
[ch17]: ch17-00-oop.html
