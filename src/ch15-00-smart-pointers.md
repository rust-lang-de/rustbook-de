# Intelligente Zeiger

Ein _Zeiger_ ist im Allgemeinen ein Konzept für eine Variable, die eine
Speicheradresse enthält. Diese Adresse referenziert oder „zeigt“ auf andere
Daten. Die häufigste Art von Zeigern in Rust ist eine Referenz, die wir bereits
in Kapitel 4 kennengelernt haben. Referenzen werden durch das Symbol `&`
gekennzeichnet und leihen (borrow) den Wert auf den sie zeigen aus. Sie haben
außer dem Referenzieren auf Daten keine besondere Funktionalität und
verursachen keinen Mehraufwand (overhead).

_Intelligente Zeiger_ (smart pointers) sind hingegen Datenstrukturen, die wie
ein Zeiger funktionieren, und über zusätzliche Metadaten und Funktionalitäten
verfügen. Das Konzept der intelligenten Zeiger gibt es nicht nur in Rust, es
stammt aus C++ und ist auch in anderen Sprachen vorhanden. Rust hat diverse
intelligente Zeiger, die in der Standardbibliothek definiert sind und
Funktionalitäten haben, die über die durch Referenzen bereitgestellten
Möglichkeiten hinausgehen. Um das allgemeine Konzept zu erkunden, werden wir
uns verschiedene Beispiele mit intelligenten Zeigern ansehen, darunter einen
_referenzzählenden_ (reference counting) intelligenten Zeigertyp. Dieser Zeiger
ermöglicht es, dass Daten mehrere Eigentümer (owner) haben können, indem er die
Anzahl der Eigentümer verfolgt und die Daten erst dann aufräumt, wenn keine
Eigentümer mehr vorhanden sind.

Da Rust das Konzept der Eigentümerschaft (ownership) und Ausleihen
(borrowing) verwendet, besteht ein zusätzlicher Unterschied zwischen Referenzen
und intelligenten Zeigern: Während Referenzen Zeiger sind, die Daten nur
ausleihen, _besitzen_ intelligente Zeiger in vielen Fällen die Eigentümerschaft
der Daten, auf die sie zeigen.

Obwohl wir sie nicht so genannt haben, sind wir in diesem Buch bereits auf
einige intelligente Zeiger gestoßen, z.B. `String` und `Vec<T>` in Kapitel 8.
Diese beiden Typen zählen zu den intelligenten Zeigern, da sie etwas
Arbeitsspeicher besitzen und es dir ermöglichen, diesen zu manipulieren. Sie
verfügen auch über Metadaten und zusätzliche Fähigkeiten oder Garantien.
`String` speichert beispielsweise seine Kapazität als Metadaten und hat die
zusätzliche Fähigkeit, sicherzustellen, dass seine Daten immer gültiges UTF-8
enthalten.

Intelligente Zeiger werden normalerweise mithilfe von Strukturen implementiert.
Im Unterschied zu einer gewöhnlichen Struktur (struct) implementieren
intelligente Zeiger die Merkmale `Deref` und `Drop`. Das Merkmal `Deref`
ermöglicht es einer Instanz eines intelligenten Zeigers, sich wie eine Referenz
zu verhalten, sodass du Programmcode schreiben kannst, der entweder mit
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

- `Box<T>` zum Zuweisen von Werten auf dem Heap
- `Rc<T>`, ein Typ der Referenzen zählt und dadurch mehrfache Eigentümerschaft
  ermöglicht
- `Ref<T>` und `RefMut<T>` mit Zugriff über `RefCell<T>`, ein Typ, der das
  Einhalten der Ausleihregel zur Laufzeit (runtime) statt zur Kompilierzeit
  erzwingt.

Darüber hinaus wird das _innere Veränderbarkeitsmuster_ (interior mutability
pattern) behandelt, bei dem ein unveränderbarer Typ eine API zum Verändern
eines inneren Werts bereitstellt. Wir werden auch _Referenzzyklen_ besprechen,
wie sie Speicherverlust verursachen können und wie wir das verhindert können.

Lass uns in die Themen eintauchen!
