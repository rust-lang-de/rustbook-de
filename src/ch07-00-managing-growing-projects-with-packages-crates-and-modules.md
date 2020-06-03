# Wachsende Projekte verwalten mit Paketen (packages), Kisten (crates) und Modulen

Wenn du große Programme schreibst, ist es wichtig, deinen Code zu organisieren,
da es unmöglich wird, den Überblick über dein gesamtes Programm im Kopf zu
behalten. Durch Gruppieren verwandter Funktionen und Aufteilen von Code mit
unterschiedlichen Funktionalitäten wirst du klären, wo du Code findest, der
eine bestimmte Funktionalität implementiert, und an welcher Stelle du eine
Funktionalität ändern musst.

Die Programme, die wir bisher geschrieben haben, waren in einem Modul in einer
Datei. Wenn ein Projekt wächst, kannst du den Code organisieren, indem du ihn
in mehrere Module und dann in mehrere Dateien aufteilst. Ein Paket (package)
kann mehrere Binär-Kisten (binary crates) und optional eine Bibliotheks-Kiste
(library crate) enthalten. Wenn ein Paket wächst, kannst du Teile in separate
Kisten extrahieren, die zu externen Abhängigkeiten werden. Dieses Kapitel
behandelt all diese Techniken. Für sehr große Projekte aus einer Reihe von
zusammenhängenden Paketen, die sich gemeinsam weiterentwickeln, stellt Cargo
Arbeitsbereiche zur Verfügung, die wir im Abschnitt
[„Cargo-Arbeitsbereiche“][workspaces] in Kapitel 14 behandeln werden.

Zusätzlich zur Gruppierungsfunktionalität ermöglicht die Kapselung von
Implementierungsdetails die Wiederverwendung von Code auf einer höheren Ebene:
Sobald du eine Operation implementiert hast, kann anderer Code diesen Code über
die öffentliche Schnittstelle des Codes aufrufen, ohne zu wissen, wie die
Implementierung funktioniert. Die Art und Weise, wie du Code schreibst,
definiert, welche Teile für anderen Code öffentlich sind und welche Teile
private Implementierungsdetails sind, deren Änderung du dir vorbehältst. Dies
ist eine weitere Möglichkeit, die Menge der Details, die man im Kopf behalten
muss, zu begrenzen.

Ein verwandtes Konzept ist der Gültigkeitsbereich (scope): Der verschachtelte
Kontext, in dem Code geschrieben wird, hat eine Reihe von Namen, die als „im
Gültigkeitsbereich“ (in scope) definiert sind. Beim Lesen, Schreiben und
Kompilieren von Code müssen Programmierer und Kompilierer wissen, ob sich ein
bestimmter Name an einer bestimmten Stelle auf eine Variable, Funktion,
Struktur (struct), Aufzählung (enum), Modul, Konstante oder ein anderes Element
bezieht und was dieses Element bedeutet. Du kannst Gültigkeitsbereiche
erstellen und verändern, welche Namen in oder außerhalb des Gültigkeitsbereichs
liegen. Du kannst nicht zwei Elemente mit gleichem Namen im selben
Gültigkeitsbereich haben; es sind Werkzeuge zur Lösung von Namenskonflikten
vorhanden.

Rust verfügt über eine Reihe von Funktionalitäten, mit denen du die
Organisation deines Codes verwalten kannst, z.B. welche Details offengelegt
werden, welche Details privat sind und welche Namen im jeweiligen
Gültigkeitsbereich deines Programms sind. Zu diesen Funktionalitäten, die
manchmal kollektiv als *Modulsystem* bezeichnet werden, gehören:

* **Pakete (packages):** Eine Cargo-Funktionalität, mit der du Kisten bauen,
  testen und gemeinsam nutzen kannst.
* **Kisten (crates):** Ein Baum von Modulen, der eine Bibliothek oder ein
  ausführbares Programm erzeugt.
* **Module** und **`use`**: Ermöglicht dir, die Organisation, den
  Gültigkeitsbereich und den Datenschutz von Pfaden zu steuern.
* **Pfade:** Eine Möglichkeit, ein Element zu benennen, z.B. eine Struktur,
  eine Funktion oder ein Modul.

In diesem Kapitel gehen wir auf all diese Funktionalitäten ein, besprechen, wie
sie zusammenwirken, und erklären, wie sie zur Verwaltung der
Gültigkeitsbereiche eingesetzt werden können. Am Ende solltest du ein solides
Verständnis des Modulsystems haben und in der Lage sein, mit den
Gültigkeitsbereichen wie ein Profi zu arbeiten!

[workspaces]: ch14-03-cargo-workspaces.html
