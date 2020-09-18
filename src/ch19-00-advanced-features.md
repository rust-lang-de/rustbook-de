# Fortgeschrittene Sprachelemente

Inzwischen hast du die am häufigsten verwendeten Teile der Programmiersprache
Rust gelernt. Bevor wir in Kapitel 20 ein weiteres Projekt durchführen, werden
wir uns einige Aspekte der Sprache ansehen, auf die du hin und wieder stoßen
könntest. Du kannst dieses Kapitel als Referenz verwenden, wenn du beim
Verwenden von Rust auf Unbekanntes stößt. Die Funktionalitäten, die du in
diesem Kapitel lernen wirst, sind in sehr speziellen Situationen nützlich. Auch
wenn du vielleicht nicht oft danach greifst, möchten wir sicherstellen, dass du
alle Funktionen, die Rust zu bieten hat, beherrschst.

In diesem Kapitel werden wir behandeln:

* Unsicheres Rust: Wie kann man einige der Garantien von Rust ausschalten und
  Verantwortung für das manuelle Aufrechterhalten dieser Garantien übernehmen?
* Fortgeschrittene Merkmale (traits): Assoziierte Typen, Standardtypparameter,
  voll qualifizierte Syntax, Supermerkmale (supertraits) und das Newtype-Muster
  in Bezug auf Merkmale
* Fortgeschrittene Typen: Mehr über das Newtype-Muster, Typ-Aliase, den Typ
  never und Typen dynamischer Größe
* Erweiterte Funktionen und Funktionsabschlüsse: Funktionszeiger und
  Zurückgeben von Funktionsabschlüssen
* Makros: Möglichkeiten, Code zu definieren, der zur Kompilierzeit mehr Code
  definiert

Es ist eine Reihe von Rust-Funktionalitäten, die für jeden etwas bietet! Lass
uns eintauchen!
