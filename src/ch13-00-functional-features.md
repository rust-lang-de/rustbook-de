# Funktionale Sprachelemente: Iteratoren und Closures

Das Design von Rust wurde von einer Vielzahl von vorhandenen Programmiersprachen
und Techniken beeinflusst; einen signifikanten Einfluss hat die _funktionale
Programmierung_. Programmieren im funktionalen Stil beinhaltet oft das Verwenden
von Funktionen als Werte, die in Argumenten übergeben, von anderen Funktionen
zurückgegeben, Variablen zur späteren Ausführung zugewiesen werden und so
weiter.
                 
In diesem Kapitel soll nicht erörtert werden, was funktionale Programmierung ist
oder nicht, stattdessen werden wir einige Funktionalitäten von Rust besprechen,
die denen vieler anderer Sprachen ähneln und häufig als funktional bezeichnet
werden.

Im Einzelnen wird Folgendes behandelt:

- _Closures_, ein Konstrukt, das einer Funktion ähnelt und in einer Variable
  gespeichert werden kann.
- _Iteratoren_, ein Mechanismus, eine Reihe von Elementen abzuarbeiten.
- Wie wir Closures und Iteratoren einsetzen, um unser E/A-Projekt aus Kapitel 12
  zu verbessern
- Die Performanz von Closures und Iteratoren (Spoiler-Alarm: Sie sind schneller,
  als du vielleicht denken magst!)

Wir haben uns bereits andere Rust-Funktionalitäten wie Aufzählungen (enums) und
Pattern Matching angesehen, die ebenfalls vom funktionalen Stil beeinflusst
sind. Da das Beherrschen von Closures und Iteratoren ein wichtiger Bestandteil
für das Schreiben von schnellem, idiomatischem Rust-Programmcode ist, wird ihnen
das gesamte Kapitel gewidmet.
