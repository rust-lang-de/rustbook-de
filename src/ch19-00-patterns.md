# Muster (patterns) und Abgleich (matching)

_Muster_ sind eine spezielle Syntax in Rust für den Abgleich mit der Struktur
von Typen, sowohl komplexen als auch einfachen Typen. Das Verwenden von Mustern
in Verbindung mit `match`-Ausdrücken und anderen Konstrukten gibt dir mehr
Kontrolle über den Kontrollfluss eines Programms. Ein Muster besteht aus einer
Kombination der folgenden Elemente:

- Literale
- Destrukturierte Arrays, Aufzählungen (enums), Strukturen (structs) oder Tupel
- Variablen
- Wildcards
- Platzhalter

Einige Beispielmuster sind `x`, `(a, 3)`, und `Some(Color::Red)`. In den
Kontexten, in denen Muster gültig sind, beschreiben diese Komponenten die
Datenform. Unser Programm gleicht dann Werte mit den Mustern ab, um
festzustellen, ob es die richtige Datenform hat, um ein bestimmtes Stück Code
weiter auszuführen.

Um ein Muster zu verwenden, vergleichen wir es mit einem Wert. Wenn das Muster
zum Wert passt, verwenden wir die Wertteile in unserem Code. Erinnere dich an
die `match`-Ausdrücke in Kapitel 6, in denen Muster verwendet wurden, z.B. die
Münzsortiermaschine. Wenn der Wert zur Form des Musters passt, können wir die
genannten Teile verwenden. Wenn dies nicht der Fall ist, wird der mit dem
Muster verbundene Code nicht ausgeführt.

Dieses Kapitel ist eine Referenz zu allen Dingen, die mit Mustern zu tun haben.
Wir behandeln die gültigen Stellen, an denen Muster verwendet werden können,
den Unterschied zwischen abweisbaren (refutable) und unabweisbaren
(irrefutable) Mustern und die verschiedenen Arten der Mustersyntax, die du
sehen kannst. Am Ende des Kapitels wirst du wissen, wie du Muster verwenden
kannst, um viele Konzepte auf klare Weise auszudrücken.
