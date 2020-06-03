# Automatisierte Tests schreiben

In seinem Essay „Der bescheidene Programmierer“ von 1972 sagte Edsger W.
Dijkstra, dass „Programmtests eine sehr effektive Methode sein können, das
Vorhandensein von Fehlern zu zeigen, aber sie sind hoffnungslos unzureichend,
um deren Abwesenheit zu zeigen“. Das bedeutet nicht, dass wir nicht versuchen
sollten, so viel wie möglich zu testen!

Korrektheit unserer Programme ist das Maß, inwieweit unser Code das tut, was
wir beabsichtigen. Bei der Entwicklung von Rust wird der Korrektheit von
Programmen große Bedeutung beigemessen, aber Korrektheit ist komplex und nicht
leicht zu beweisen. Das Typsystem von Rust trägt einen großen Teil dieser Last,
aber das Typsystem kann nicht jede Art von Unrichtigkeit erkennen. Rust
beinhaltet Unterstützung für das Schreiben automatisierter Softwaretests
innerhalb der Sprache.

Nehmen wir beispielsweise an, wir schreiben eine Funktion namens `add_two`, die
2 zu jeder Zahl addiert, die ihr übergeben wird. Die Signatur dieser Funktion
akzeptiert eine ganze Zahl als Parameter und gibt als Ergebnis eine ganze Zahl
zurück. Wenn wir diese Funktion implementieren und kompilieren, führt Rust die
gesamte Typ- und Ausleihenprüfung durch, die du bisher kennengelernt hast, um
sicherzustellen, dass wir z.B. keinen `String`-Wert oder eine ungültige
Referenz an diese Funktion übergeben. Aber Rust kann *nicht* überprüfen, ob
diese Funktion genau das tut, was wir beabsichtigen, nämlich den Parameter plus
2 zurückzugeben und nicht etwa den Parameter plus 10 oder den Parameter minus
50! Hier kommen Tests ins Spiel.

Wir können Tests schreiben, die zum Beispiel sicherstellen, dass der
Rückgabewert `5` ist, wenn wir `3` an die Funktion `add_two` übergeben. Wir
können diese Tests immer dann durchführen, wenn wir Änderungen an unserem Code
vornehmen, um sicherzustellen, dass sich ein bestehendes korrektes Verhalten
 nicht geändert hat.

Testen ist eine komplexe Fähigkeit: Obwohl wir nicht jedes Detail darüber, wie
man gute Tests schreibt, in einem Kapitel behandeln können, werden wir die
Mechanismen der Rust-Testmöglichkeiten besprechen. Wir werden über Annotationen
und Makros sprechen, die dir beim Schreiben deiner Tests zur Verfügung stehen,
über das Standardverhalten und die Optionen, die es bei der Ausführung deiner
Tests gibt, und darüber, wie du Tests in Modultests (unit tests) und
Integrationstests organisieren kannst.
