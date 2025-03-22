# Aufzählungen (enums) und Musterabgleich (pattern matching)

In diesem Kapitel werden wir uns mit _Aufzählungen_ (enumerations, kurz: enums)
befassen. Aufzählungen erlauben es, einen Typ durch Aufzählung seiner möglichen
_Varianten_ (variants) zu definieren. Zuerst werden wir eine Aufzählung
definieren und verwenden, um zu zeigen, wie eine Aufzählung mit Daten eine
Bedeutung kodieren kann. Als Nächstes werden wir eine besonders nützliche
Aufzählung untersuchen, die `Option` genannt wird und zum Ausdruck bringt, dass
ein Wert entweder etwas oder nichts sein kann. Dann sehen wir uns an, wie man
mit dem Musterabgleich (pattern matching) im Ausdruck `match` auf einfache
Weise unterschiedlichen Code für verschiedene Werte einer Aufzählung
auszuführen kann. Schließlich werden wir uns mit dem Konstrukt `if let`
befassen, einem weiteren bequemen und prägnanten Idiom, um mit Aufzählungen in
deinem Code umzugehen.
