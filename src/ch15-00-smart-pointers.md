# Intelligente Zeiger

Im Allgemeinen ist ein *Zeiger* ein Konzept für eine Variable die eine
Speicheradresse enthält. Diese Adresse bezieht sich, oder "zeigt", auf andere
Daten. Die häufigste Art von Zeigern in Rust ist eine Referenz, die wir bereits
in Kapitel 4 kennengelernt haben. Referenzen werden durch das Symbol `&`
gekennzeichnet und leihen (borrow) den Wert auf den sie zeigen aus. Sie haben,
außer dem Verweisen auf Daten, keine besonderen Funktionalitäten. Im Übrigen
erzeugen sie keinen Mehraufwand (overhead) und sind die am häufigsten
verwendete Art von Zeigern.

*Intelligente Zeiger* (smart pointers) sind hingegen Datenstrukturen, die nicht
ausschließlich wie ein Zeiger wirken, sondern auch über zusätzliche Metadaten
und Funktionalitäten verfügen. Das Konzept der intelligenten Zeiger gilt nicht
nur für Rust, sie stammen aus C++ und sind auch in anderen Sprachen vorhanden.
In Rust bieten die unterschiedlichen, in der Standardbibliothek definierten
intelligenten Zeiger, Funktionalitäten die über die durch Referenzen
bereitgestellten Möglichkeiten hinausgehen. Ein Beispiel, das wir in diesem
Kapitel untersuchen werden, ist der intelligente Zeiger-Typ *Referenzzählung*
(reference counting). Mit diesem Zeiger kann man mehrere Eigentümer (owner)
von Daten haben, indem man die Anzahl der Eigentümer verfolgt und die Daten
bereinigt sobald keine Eigentümer mehr vorhanden sind.

Da Rust das Konzept von Eigentümerschaft (ownership) und Ausleihen
(borrowing) verwendet, besteht ein zusätzlicher Unterschied zwischen Referenzen
und intelligenten Zeigern darin, dass Referenzen Zeiger sind, die Daten nur
ausleihen. Im Gegensatz dazu *besitzen* intelligente Zeiger in vielen Fällen die
Eigentümerschaft von Daten, auf die sie zeigen.

Intelligente Zeiger werden normalerweise mithilfe von Strukturen implementiert.
Das Merkmal, das einen intelligenten Zeiger von einer gewöhnlichen Struktur
(struct) unterscheidet, ist, dass intelligente Zeiger die Merkmale `Deref` und
`Drop` implementieren. Das Merkmal `Deref` ermöglicht es einer Instanz der
Struktur für intelligente Zeiger, sich wie eine Referenz zu verhalten, sodass du
Programmcode schreiben kannst, der entweder mit Referenzen oder intelligenten
Zeigern funktioniert. Mit dem Merkmal `Drop` kannst du den Programmcode
anpassen, der ausgeführt wird, wenn eine Instanz des intelligenten Zeigers den
Gültigkeitsbereich (scope) verlässt. In diesem Kapitel werden wir beide Merkmale
diskutieren und zeigen, warum sie für intelligente Zeiger wichtig sind.

Da das Muster des intelligenten Zeigers ein allgemeines Entwurfsmuster ist, das
in Rust häufig verwendet wird, werden in diesem Kapitel nicht alle vorhandenen
intelligenten Zeiger behandelt. Viele Bibliotheken haben ihre eigenen
intelligenten Zeiger, und du kannst sogar deine eigenen schreiben. Wir werden
die am häufigsten verwendeten intelligenten Zeiger der Standardbibliothek
behandeln:

* `Box<T>` zum Zuweisen von Werten auf dem Heap
* `Rc<T>`, ein Typ der Referenzen zählt und dadurch mehrfache Eigentümerschaft
    ermöglicht
* `Ref<T>` und `RefMut<T>`, Zugriff über `RefCell<T>`, ein Typ, der das
    einhalten der Ausleihregel zur Laufzeit (runtime) statt zur Kompilierungszeit
    erzwingt.

Darüber hinaus wird das *innere Veränderlichkeitsmuster* (interior mutability)
behandelt, bei dem ein unveränderlicher Typ eine API zum verändern eines inneren
Werts verfügbar macht. Wir werden auch *Referenzzyklen* diskutieren, wie diese
Speicherverlust verursachen können und wie das verhindert werden kann.

Lass uns in die Materie eintauchen!
