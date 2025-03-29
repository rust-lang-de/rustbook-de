# Fortgeschrittene Sprachelemente

Inzwischen hast du die am häufigsten verwendeten Teile der Programmiersprache
Rust gelernt. Bevor wir in Kapitel 20 ein weiteres Projekt durchführen, werden
wir uns einige Aspekte der Sprache ansehen, auf die du hin und wieder stoßen
könntest, aber nicht jeden Tag verwenden wirst. Du kannst dieses Kapitel als
Referenz verwenden, wenn du auf Unbekanntes stößt. Die hier beschriebenen
Funktionalitäten sind in ganz bestimmten Situationen nützlich. Auch wenn du sie
vielleicht nicht oft brauchst, möchten wir sicherstellen, dass du alle
Funktionen von Rust kennst. 

In diesem Kapitel werden wir behandeln:

- Unsicheres Rust: Wie kann man einige der Garantien von Rust ausschalten und
  Verantwortung für das manuelle Aufrechterhalten dieser Garantien übernehmen?
- Fortgeschrittene Merkmale (traits): Assoziierte Typen, Standardtypparameter,
  voll qualifizierte Syntax, Supermerkmale (supertraits) und das Newtype-Muster
  in Bezug auf Merkmale
- Fortgeschrittene Typen: Mehr über das Newtype-Muster, Typ-Aliase, den Typ
  never und Typen dynamischer Größe
- Erweiterte Funktionen und Funktionsabschlüsse: Funktionszeiger und
  Zurückgeben von Funktionsabschlüssen
- Makros: Möglichkeiten, Code zu definieren, der zur Kompilierzeit mehr Code
  definiert

Es ist eine Reihe von Rust-Funktionalitäten, die für jeden etwas bietet! Lass
uns eintauchen!
