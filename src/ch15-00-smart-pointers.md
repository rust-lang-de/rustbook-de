# Intelligente Zeiger

Im Allgemeinen ist ein *Zeiger* ein Konzept für eine Variable die eine
Speicheradresse enthält. Diese Adresse bezieht sich, oder „zeigt“, auf andere
Daten. Die häufigste Art von Zeigern in Rust ist eine Referenz, die wir bereits
in Kapitel 4 kennengelernt haben. Referenzen werden durch das Symbol `&`
gekennzeichnet und leihen (borrow) den Wert auf den sie zeigen aus. Sie haben,
außer dem Verweisen auf Daten, keine besonderen Funktionalitäten. Im Übrigen
erzeugen sie keinen Mehraufwand (overhead) und sind die am häufigsten
verwendete Art von Zeigern.

*Intelligente Zeiger* (smart pointers) sind hingegen Datenstrukturen, die wie
ein Zeiger wirken, sondern auch über zusätzliche Metadaten und Funktionalitäten
verfügen. Das Konzept der intelligenten Zeiger gilt nicht nur für Rust, sie
stammen aus C++ und sind auch in anderen Sprachen vorhanden. Rust hat diverse
intelligente Zeiger, die in der Standardbibliothek definiert sind und
Funktionalitäten die über die durch Referenzen bereitgestellten Möglichkeiten
hinausgehen. Um das allgemeine Konzept zu erkunden, werden wir uns einige
verschiedene Beispiele für intelligente Zeiger ansehen, darunter einen
*referenzzählenden* (reference counting) intelligenten Zeigertyp. Dieser Zeiger
ermöglicht es, dass Daten mehrere Eigentümer (owner) haben können, indem er die
Anzahl der Eigentümer verfolgt und die Daten aufräumt, wenn keine Eigentümer
mehr vorhanden sind.

Da Rust das Konzept der Eigentümerschaft (ownership) und Ausleihen
(borrowing) verwendet, besteht ein zusätzlicher Unterschied zwischen Referenzen
und intelligenten Zeigern: Während Referenzen Zeiger sind, die Daten nur
ausleihen, *besitzen* intelligente Zeiger in vielen Fällen die Eigentümerschaft
der Daten, auf die sie zeigen.

Obwohl wir sie nicht so genannt haben, sind wir in diesem Buch bereits auf
einige intelligente Zeiger gestoßen, z.B. `String` und `Vec<T>` in Kapitel 8.
Diese beiden Typen zählen zu den intelligenten Zeigern, da sie einen gewissen
Speicher besitzen und es dir ermöglichen, diesen zu manipulieren. Sie verfügen
auch über Metadaten und zusätzliche Fähigkeiten oder Garantien. `String`
speichert beispielsweise seine Kapazität als Metadaten und hat die zusätzliche
Fähigkeit, sicherzustellen, dass seine Daten immer gültiges UTF-8 enthalten.

Intelligente Zeiger werden normalerweise mithilfe von Strukturen implementiert.
Im Unterschied zu einer gewöhnlichen Struktur (struct) implementieren
intelligente Zeiger die Merkmale `Deref` und `Drop`. Das Merkmal `Deref`
ermöglicht es einer Instanz der Struktur für intelligente Zeiger, sich wie eine
Referenz zu verhalten, sodass du Programmcode schreiben kannst, der entweder mit
Referenzen oder intelligenten Zeigern funktioniert. Mit dem Merkmal `Drop`
kannst du den Programmcode anpassen, der ausgeführt wird, wenn eine Instanz des
intelligenten Zeigers den Gültigkeitsbereich (scope) verlässt. In diesem
Kapitel werden wir beide Merkmale besprechen und zeigen, warum sie für
intelligente Zeiger wichtig sind.

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
    Einhalten der Ausleihregel zur Laufzeit (runtime) statt zur Kompilierungszeit
    erzwingt.

Darüber hinaus wird das *innere Veränderbarkeitsmuster* (interior mutability pattern)
behandelt, bei dem ein unveränderbarer Typ eine API zum Verändern eines inneren
Werts verfügbar macht. Wir werden auch *Referenzzyklen* besprechen, wie diese
Speicherverlust verursachen können und wie das verhindert werden kann.

Lass uns in die Materie eintauchen!
