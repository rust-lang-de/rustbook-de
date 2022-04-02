# Funktionale Sprachelemente: Iteratoren und Funktionsabschlüsse (closures)

Das Design von Rust wurde von einer Vielzahl von vorhandenen Programmiersprachen
und Techniken beeinflusst und ein signifikanter Einfluss ist die *funktionale
Programmierung*. Programmieren im funktionalen Stil beinhaltet oft das
Verwenden von Funktionen als Werte, die in Argumenten übergeben, von anderen
Funktionen zurückgegeben, Variablen zur späteren Ausführung zugewiesen werden
und so weiter.
                 
Gegenstand dieses Kapitels ist es nicht, zu erörtern, was funktionale
Programmierung ist oder nicht, stattdessen werden wir einige Funktionalitäten von
Rust besprechen, die denen vieler anderer Sprachen ähneln und häufig als
funktional bezeichnet werden. 

Im Einzelnen wird Folgendes behandelt:

* *Funktionsabschlüsse*, ein Konstrukt, das einer Funktion ähnelt und in einer
  Variable gespeichert werden kann.
* *Iteratoren*, eine Möglichkeit, eine Reihe von Elementen abzuarbeiten.
* Wie wir diese zwei Möglichkeiten benutzen können, um unser E/A-Projekt in
  Kapitel 12 verbessern zu können.
* Die Performanz dieser beiden Funktionalitäten (Spoiler-Alarm: Sie sind
  schneller, als du vielleicht denken magst!)

Andere Rust-Funktionalitäten wie Aufzählungen (enums) und Musterabgleich
(pattern matching), die wir bereits in anderen Kapiteln behandelt haben, sind
ebenfalls vom funktionalen Stil beeinflusst. Das Beherrschen von
Funktionsabschlüssen und Iteratoren ist ein wichtiger Bestandteil beim
Schreiben von idiomatischem, schnellem Rust-Programmcode. Daher wird ihnen
das gesamte Kapitel gewidmet.
