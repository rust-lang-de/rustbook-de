## Wertlisten in Vektoren ablegen

Der erste Kollektionstyp, den wir betrachten werden, ist `Vec<T>`, auch bekannt
als *Vektor*. Vektoren ermöglichen es dir, mehr als einen Wert in einer
einzigen Datenstruktur zu speichern and alle Werte nebeneinander im Speicher
abzulegen. Vektoren können nur Werte desselben Typs speichern. Sie sind nützlich,
wenn du eine Liste von Einträgen hast, z.B. die Textzeilen einer Datei oder die
Preise der Artikel in einem Einkaufswagen.

### Erstellen eines neuen Vektors

Um einen neuen, leeren Vektor zu erstellen, können wir die Funktion `Vec::new`
aufrufen, wie in Codeblock 8-1 gezeigt.

```rust
let v: Vec<i32> = Vec::new();
```

<span class="caption">Codeblock 8-1: Erstellen eines neuen, leeren Vektors zur
Aufnahme von Werten des Typs `i32`</span>

Beachte, dass wir hier eine Typ-Annotation hinzugefügt haben. Da wir keine
Werte in diesen Vektor einfügen, weiß Rust nicht, welche Art von Elementen wir
zu speichern beabsichtigen. Dies ist ein wichtiger Punkt. Vektoren werden mit
Hilfe generischer Typen implementiert; wie du eigene generische Typen verwenden
kannst, wird in Kapitel 10 behandelt. Für den Moment sollst du wissen, dass der
von der Standardbibliothek bereitgestellte Typ `Vec<T>` jeden Typ enthalten
kann, und wenn ein bestimmter Vektor einen bestimmten Typ enthält, wird der Typ
in spitzen Klammern angegeben. In Codeblock 8-1 haben wir Rust gesagt, dass der
Vektor `Vec<T>` in `v` Elemente des Typs `i32` enthalten wird.

In realistischerem Code kann Rust oft auf den Typ des Wertes schließen, den du
nach dem Einfügen von Werten speichern möchtest, sodass du diese Art der
Annotation nur selten verwenden musst. Häufiger kommt es vor, einen `Vec<T>` zu
erstellen, der Anfangswerte hat, und Rust stellt der Einfachheit halber das
Makro `vec!` zur Verfügung. Das Makro erstellt einen neuen Vektor, der die von
dir angegebenen Werte enthält. Codeblock 8-2 erzeugt einen neuen `Vec<i32>`,
der die Werte `1`, `2` und `3` enthält. Als Integer-Typ wird `i32` verwendet,
weil das der Standard-Integer-Typ ist, wie wir im Abschnitt
[„Datentypen“][data-types] in Kapitel 3 besprochen haben.

```rust
let v = vec![1, 2, 3];
```

<span class="caption">Codeblock 8-2: Erstellen eines neuen Vektors mit
Werten</span>

Da wir initiale `i32`-Werte angegeben haben, kann Rust daraus schließen, dass
`v` den Typ `Vec<i32>` hat, und die Typ-Annotation ist nicht notwendig. Als
Nächstes werden wir uns ansehen, wie man einen Vektor modifiziert.

### Aktualisieren eines Vektors

Um einen Vektor zu erstellen und ihm dann Elemente hinzuzufügen, können wir die
Methode `push` verwenden, wie in Codeblock 8-3 zu sehen ist.

```rust
let mut v = Vec::new();

v.push(5);
v.push(6);
v.push(7);
v.push(8);
```

<span class="caption">Codeblock 8-3: Verwenden der Methode `push` zum
Hinzufügen von Werten zu einem Vektor</span>

Wie bei jeder Variablen müssen wir, wenn wir ihren Wert ändern wollen, sie mit
dem Schlüsselwort `mut` als veränderlich markieren, wie in Kapitel 3
besprochen. Die Zahlen, die wir darin platzieren, sind alle vom Typ `i32`, und
Rust leitet dies aus den Daten ab, sodass wir die Annotation `Vec<i32>` nicht
benötigen.

### Beim Aufräumen eines Vektors werden seine Elemente aufgeräumt

Wie bei jeder anderen Struktur wird ein Vektor freigegeben, wenn er den
Gültigkeitsbereich verlässt, wie in Codeblock 8-4 kommentiert wird.

```rust
{
    let v = vec![1, 2, 3, 4];

    // mache etwas mit v
} // <- v verlässt den Gültigkeitsbereich und wird hier freigegeben
```

<span class="caption">Codeblock 8-4: Zeigt, wo der Vektor und seine Elemente
aufgeräumt werden</span>

Wenn der Vektor aufgeräumt wird, wird auch sein gesamter Inhalt aufgeräumt,
d.h. die ganzen Zahlen, die er enthält, werden beseitigt. Dies mag recht
einfach erscheinen, kann aber etwas komplizierter werden, wenn du anfängst,
Referenzen auf Elemente des Vektors einzuführen. Lass uns das als Nächstes
angehen!

### Elemente aus Vektoren lesen

Da du jetzt weißt, wie man Vektoren erstellt, aktualisiert und aufräumt, ist es
ein guter nächster Schritt zu wissen, wie man ihre Inhalte ausliest. Es gibt
zwei Möglichkeiten, einen in einem Vektor gespeicherten Wert zu referenzieren. 
In den Beispielen haben wir zur besseren Lesbarkeit die Werttypen, die von den
Funktionen zurückgegeben werden, mit angegeben.

Codeblock 8-5 zeigt beide Zugriffsmethoden auf einen Wert in einem Vektor,
mittels Indexierungssyntax und die Methode `get`.

```rust
let v = vec![1, 2, 3, 4, 5];

let third: &i32 = &v[2];
println!("Das dritte Element ist {}", third);

match v.get(2) {
    Some(third) => println!("Das dritte Element ist {}", third),
    None => println!("Es gibt kein drittes Element."),
}
```

<span class="caption">Codeblock 8-5: Verwenden der Indexierungssyntax und der
Methode `get` für den Zugriff auf ein Element in einem Vektor</span>

Beachte hier zwei Details. Erstens verwenden wir den Indexwert `2`, um das
dritte Element zu erhalten: Vektoren werden mit Zahlen indiziert, beginnend bei
null. Zweitens gibt es zwei Möglichkeiten, das dritte Element zu erhalten:
Entweder durch Verwendung von `&` und `[]`, was eine Referenz ergibt, oder
durch die Methode `get` mit dem Index als Argument, was eine `Option<&T>`
ergibt.

Rust hat zwei Möglichkeiten, ein Element zu referenzieren, sodass du bestimmen
kannst, wie sich das Programm verhalten soll, wenn du versuchst, einen
Indexwert zu verwenden, für den der Vektor kein Element enthält. Als Beispiel
wollen wir sehen, was ein Programm tut, wenn wir bei einem Vektor mit fünf
Elementen versuchen, auf ein Element mit Index 100 zuzugreifen, wie in
Codeblock 8-6 zu sehen ist.

```rust,should_panic,panics
let v = vec![1, 2, 3, 4, 5];

let does_not_exist = &v[100];
let does_not_exist = v.get(100);
```

<span class="caption">Codeblock 8-6: Versuch, auf das Element mit Index 100 in
einem Vektor zuzugreifen, der fünf Elemente enthält</span>

Wenn wir diesen Code ausführen, wird die Variante `[]` das Programm abbrechen
lassen, weil es auf ein nicht existierendes Element verweist. Diese Methode
wird vorzugsweise verwendet, wenn du dein Programm abstürzen lassen möchtest,
wenn versucht wird, auf ein Element hinter dem Ende des Vektors zuzugreifen.

Wenn der Methode `get` ein Index außerhalb des Vektors übergeben wird, gibt sie
`None` zurück, ohne abzubrechen. Du würdest diese Methode verwenden, wenn der
Zugriff auf ein Element außerhalb des Bereichs des Vektors unter normalen
Umständen gelegentlich vorkommt. Dein Code wird dann eine Logik haben, die mit
`Some(&element)` und `None` umgehen kann, wie in Kapitel 6 besprochen. Der
Index könnte zum Beispiel von einer Person stammen, die eine Zahl eingibt. Wenn
sie versehentlich eine zu große Zahl eingibt und das Programm einen `None`-Wert
erhält, kannst du dem Benutzer mitteilen, wie viele Elemente sich aktuell im
Vektor befinden und ihm eine weitere Chance geben, einen gültigen Wert
einzugeben. Das wäre benutzerfreundlicher, als das Programm wegen eines
Tippfehlers abstürzen zu lassen!

Wenn das Programm über eine gültige Referenz verfügt, stellt der
Ausleihenprüfer mittels Eigentümerschafts- und Ausleihregeln (siehe Kapitel 4)
sicher, dass diese Referenz und alle anderen Referenzen auf den Inhalt des
Vektors gültig bleiben. Erinnere dich an die Regel, die besagt, dass du keine
veränderlichen und unveränderlichen Referenzen im gleichen Gültigkeitsbereich
haben kannst. Diese Regel trifft in Codeblock 8-7 zu, wo wir eine
unveränderliche Referenz auf das erste Element in einem Vektor halten und
versuchen, am Ende ein Element hinzuzufügen, was nicht funktionieren wird.

```rust,does_not_compile
let mut v = vec![1, 2, 3, 4, 5];

let first = &v[0];

v.push(6);

println!("Das erste Element ist: {}", first);
```

<span class="caption">Codeblock 8-7: Versuch, ein Element zu einem Vektor
hinzuzufügen, während eine Referenz auf ein Element gehalten wird</span>

Das Kompilieren dieses Codes führt zu folgendem Fehler:

```console
$ cargo run
   Compiling collections v0.1.0 (file:///projects/collections)
error[E0502]: cannot borrow `v` as mutable because it is also borrowed as immutable
 --> src/main.rs:6:5
  |
4 |     let first = &v[0];
  |                  - immutable borrow occurs here
5 | 
6 |     v.push(6);
  |     ^^^^^^^^^ mutable borrow occurs here
7 | 
8 |     println!("Das erste Element ist: {}", first);
  |                                           ----- immutable borrow later used here

error: aborting due to previous error

For more information about this error, try `rustc --explain E0502`.
error: could not compile `collections`.

To learn more, run the command again with --verbose.
```

Der Code in Codeblock 8-7 sieht so aus, als könnte er funktionieren: Warum
sollte sich eine Referenz auf das erste Element darum kümmern, was sich am
Ende des Vektors ändert? Dieser Fehler ist in der Funktionsweise von Vektoren
begründet: Das Hinzufügen eines neuen Elements am Ende des Vektors könnte die
Allokation neuen Speichers und das Kopieren der alten Elemente an die neue
Stelle erfordern, wenn nicht genügend Platz vorhanden ist, um alle Elemente
nebeneinander an der aktuellen Stelle des Vektors zu platzieren. In diesem Fall
würde die Referenz auf das erste Element auf einen freigegebenen Speicherplatz
verweisen. Die Ausleihregeln verhindern, dass Programme in diese Situation
geraten.

> Anmerkung: Weitere Einzelheiten zu den Implementierungsdetails des Typs
> `Vec<T>` findest du in [„Das Rustonomicon“][nomicon].

### Iterieren über die Werte in einem Vektor

Wenn wir auf die Elemente eines Vektors der Reihe nach zugreifen wollen, können
wir über alle Elemente iterieren, anstatt Indizes zu verwenden, um auf jeweils
ein Element zur gleichen Zeit zuzugreifen. Codeblock 8-8 zeigt, wie man eine
`for`-Schleife verwendet, um unveränderliche Referenzen auf die Elemente eines
Vektors von `i32`-Werten zu erhalten und diese auszugeben.

```rust
let v = vec![100, 32, 57];
for i in &v {
    println!("{}", i);
}
```

<span class="caption">Codeblock 8-8: Ausgeben aller Elemente eines Vektors
durch Iterieren über die Elemente mittels `for`-Schleife</span>

Wir können auch über veränderliche Referenzen der Elemente eines veränderlichen
Vektors iterieren, um Änderungen an allen Elementen vorzunehmen. Die
`for`-Schleife in Codeblock 8-9 addiert zu jedem Element `50`.

```rust
let mut v = vec![100, 32, 57];
for i in &mut v {
    *i += 50;
}
```

<span class="caption">Codeblock 8-9: Iterieren über veränderliche Referenzen
der Elemente eines Vektors</span>

Um den Wert, auf den sich die veränderliche Referenz bezieht, zu ändern, müssen
wir den Dereferenzierungsoperator (`*`) verwenden, um an den Wert in `i` zu
kommen, bevor wir den Operator `+=` verwenden können. Wir werden mehr über den
Dereferenzierungsoperator im Abschnitt [„Dem Zeiger zum Wert folgen mit dem
Dereferenzierungsoperator“][deref] in Kapitel 15 sprechen.

### Verwenden einer Aufzählung zum Speichern mehrerer Typen

Zu Beginn dieses Kapitels haben wir gesagt, dass Vektoren nur Werte desselben
Typs speichern können. Das kann unbequem sein; es gibt definitiv
Anwendungsfälle, in denen es notwendig ist, eine Liste von Einträgen
unterschiedlicher Typen zu speichern. Glücklicherweise werden die Varianten
einer Aufzählung unter dem gleichen Aufzählungstyp definiert. Wenn wir also
Elemente eines anderen Typs in einem Vektor speichern wollen, können wir eine
Aufzählung definieren und verwenden! Angenommen, wir möchten Werte aus einer
Zeile einer Tabellenkalkulationstabelle erhalten, in der einige Spalten der
Zeile ganze Zahlen, Fließkommazahlen und Zeichenketten enthalten.  Wir können
eine Aufzählung definieren, deren Varianten die verschiedenen Werttypen
enthalten, und dann werden alle Aufzählungsvarianten als derselbe Typ
angesehen: Der Typ der Aufzählung. Dann können wir einen Vektor erstellen, der
diese Aufzählung und damit letztlich verschiedene Typen enthält. Wir haben dies
in Codeblock 8-10 demonstriert.

```rust
enum SpreadsheetCell {
    Int(i32),
    Float(f64),
    Text(String),
}

let row = vec![
    SpreadsheetCell::Int(3),
    SpreadsheetCell::Text(String::from("blau")),
    SpreadsheetCell::Float(10.12),
];
```

<span class="caption">Codeblock 8-10: Definieren eines `enum`, um Werte
verschiedener Typen in einem Vektor zu speichern</span>

Rust muss wissen, welche Typen zur Kompilierzeit im Vektor enthalten sein
werden, damit es genau weiß, wie viel Speicherplatz im dynamischen Speicher
benötigt wird, um alle Elemente zu speichern. Ein zweiter Vorteil ist, dass wir
explizit festlegen können, welche Typen in diesem Vektor erlaubt sind. Wenn
Rust einen Vektor mit beliebigen Typen zuließe, bestünde die Möglichkeit, dass
einer oder mehrere Typen Fehler bei den an den Elementen des Vektors
durchgeführten Operationen verursachen würden. Das Verwenden einer Aufzählung
zusammen mit einem `match`-Ausdruck bedeutet, dass Rust zur Kompilierzeit
sicherstellt, dass jeder mögliche Fall behandelt wird, wie in Kapitel 6
besprochen.

Wenn du ein Programm schreibst und nicht weißt, welche Typen das Programm zur
Laufzeit in einen Vektor speichern wird, funktioniert der Aufzählungsansatz
nicht. Stattdessen kannst du ein Merkmalsobjekt (trait object) verwenden, das
wir in Kapitel 17 behandeln werden.

Nachdem wir nun einige der gängigsten Methoden zur Verwendung von Vektoren
besprochen haben, solltest du dir unbedingt die API-Dokumentation zu den vielen
nützlichen Methoden ansehen, die die Standardbibliothek für `Vec<T>` mitbringt. 
Zum Beispiel gibt es zusätzlich zu `push` die Methode `pop`, die das letzte
Element entfernt und zurückgibt. Lass uns zum nächsten Kollektionstyp
 übergehen: `String`

[data-types]: ch03-02-data-types.html#data-types
[nomicon]: https://doc.rust-lang.org/nomicon/vec.html
[deref]: ch15-02-deref.html#following-the-pointer-to-the-value-with-the-dereference-operator
