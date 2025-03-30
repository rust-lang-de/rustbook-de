# Funktionale Sprachelemente: Iteratoren und Funktionsabschlüsse (closures)

Das Design von Rust wurde von einer Vielzahl von vorhandenen Programmiersprachen
und Techniken beeinflusst und einen signifikanter Einfluss hat die _funktionale
Programmierung_. Programmieren im funktionalen Stil beinhaltet oft das
Verwenden von Funktionen als Werte, die in Argumenten übergeben, von anderen
Funktionen zurückgegeben, Variablen zur späteren Ausführung zugewiesen werden
und so weiter.
                 
In diesem Kapitels soll nicht erörtert werden, was funktionale
Programmierung ist oder nicht, stattdessen werden wir einige Funktionalitäten von
Rust besprechen, die denen vieler anderer Sprachen ähneln und häufig als
funktional bezeichnet werden. 

Im Einzelnen wird Folgendes behandelt:

- _Funktionsabschlüsse_, ein Konstrukt, das einer Funktion ähnelt und in einer
  Variable gespeichert werden kann.
- _Iteratoren_, ein Mechanismus, eine Reihe von Elementen abzuarbeiten.
- Wie wir Funktionsabschlüsse und Iteratoren einsetzen, um unser E/A-Projekt
  aus Kapitel 12 zu verbessern
- Die Performanz von Funktionsabschlüssen und Iteratoren (Spoiler-Alarm: Sie
  sind schneller, als du vielleicht denken magst!)

Wir haben uns bereits andere Rust-Funktionalitäten wie Aufzählungen (enums) und
Musterabgleich (pattern matching) angesehen, die ebenfalls vom funktionalen
Stil beeinflusst sind. Da das Beherrschen von Funktionsabschlüssen und
Iteratoren ein wichtiger Bestandteil für das Schreiben von idiomatischem,
schnellem Rust-Programmcode ist, wird ihnen das gesamte Kapitel gewidmet.
