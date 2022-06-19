## Charakteristiken objektorientierter Sprachen

Es gibt in der Programmierergemeinschaft keinen Konsens darüber, welche
Funktionalitäten eine Sprache haben muss, um als objektorientiert zu gelten.
Rust wird von vielen Programmierparadigmen beeinflusst, einschließlich OOP; zum
Beispiel haben wir in Kapitel 13 die Funktionalitäten untersucht, die aus der
funktionalen Programmierung stammen. Die OOP-Sprachen haben wohl bestimmte
gemeinsame Charakteristiken, nämlich Objekte, Kapselung (encapsulation) und
Vererbung (inheritance). Schauen wir uns an, was jedes dieser Charakteristiken
bedeutet und ob Rust es unterstützt.

### Objekte enthalten Daten und Verhalten

Das Buch *Design Patterns: Elements of Reusable Object-Oriented Software* von
Erich Gamma, Richard Helm, Ralph Johnson und John Vlissides (Addison-Wesley
Professional, 1994), umgangssprachlich als *The Gang of Four*-Buch bezeichnet,
ist ein Katalog von objektorientierten Entwurfsmustern. Es definiert OOP auf
diese Weise:

> Objektorientierte Programme setzen sich aus Objekten zusammen. Ein *Objekt*
> verpackt sowohl Daten als auch Prozeduren, die auf diesen Daten operieren.
> Die Prozeduren werden normalerweise *Methoden* oder *Operationen* genannt.

Mit dieser Definition ist Rust objektorientiert: Strukturen (structs) und
Aufzählungen (enums) haben Daten, und `impl`-Blöcke stellen Methoden auf
Strukturen und Aufzählungen zur Verfügung. Auch wenn Strukturen und
Aufzählungen mit Methoden keine *aufgerufenen* Objekte sind, bieten sie
dieselbe Funktionalität gemäß der Definition von Objekten der Gang of Four.

### Kapselung, die Implementierungsdetails verbirgt

Ein weiterer Aspekt, der gemeinhin mit OOP in Verbindung gebracht wird, ist die
Idee der *Kapselung* (encapsulation), was bedeutet, dass die
Implementierungsdetails eines Objekts nicht zugänglich sind für Code, der
dieses Objekt verwendet. Daher ist die einzige Möglichkeit, mit einem Objekt zu
interagieren, seine öffentliche API; Code, der das Objekt verwendet, sollte
nicht in der Lage sein, in die Interna des Objekts einzudringen und Daten oder
Verhalten direkt zu ändern. Dies ermöglicht es dem Programmierer, die Interna
eines Objekts zu ändern und umzugestalten, ohne Code ändern zu müssen, der das
Objekt verwendet.

Wie man die Kapselung steuert, haben wir in Kapitel 7 besprochen: Wir können
das Schlüsselwort `pub` benutzen, um zu entscheiden, welche Module, Typen,
Funktionen und Methoden in unserem Code öffentlich sein sollen, alles andere
ist standardmäßig privat. Zum Beispiel können wir eine Struktur
`AveragedCollection` definieren, die ein Feld hat, das einen Vektor mit
`i32`-Werten enthält. Die Struktur kann auch ein Feld haben, das den Mittelwert
der Werte im Vektor enthält, was bedeutet, dass der Mittelwert nicht auf
Anfrage berechnet werden muss, wenn jemand ihn braucht. Mit anderen Worten:
`AveragedCollection` wird den errechneten Durchschnitt für uns
zwischenspeichern. Codeblock 17-1 zeigt die Definition der Struktur
`AveragedCollection`:

<span class="filename">Dateiname: src/lib.rs</span>

```rust
pub struct AveragedCollection {
    list: Vec<i32>,
    average: f64,
}
```

<span class="caption">Codeblock 17-1: Eine Struktur `AveragedCollection`, die
eine Liste von ganzen Zahlen und den Durchschnitt der Elemente in der
Kollektion verwaltet</span>

Die Struktur wird als `pub` markiert, damit anderer Code sie verwenden kann,
aber die Felder innerhalb der Struktur bleiben privat. Dies ist in diesem Fall
wichtig, weil wir sicherstellen wollen, dass immer dann, wenn ein Wert
hinzugefügt oder aus der Liste entfernt wird, auch der Durchschnitt
aktualisiert wird. Wir tun dies, indem wir die Methoden `add`, `remove` und
`average` auf der Struktur implementieren, wie in Codeblock 17-2 gezeigt:

<span class="filename">Dateiname: src/lib.rs</span>

```rust
# pub struct AveragedCollection {
#     list: Vec<i32>,
#     average: f64,
# }
#
impl AveragedCollection {
    pub fn add(&mut self, value: i32) {
        self.list.push(value);
        self.update_average();
    }

    pub fn remove(&mut self) -> Option<i32> {
        let result = self.list.pop();
        match result {
            Some(value) => {
                self.update_average();
                Some(value)
            }
            None => None,
        }
    }

    pub fn average(&self) -> f64 {
        self.average
    }

    fn update_average(&mut self) {
        let total: i32 = self.list.iter().sum();
        self.average = total as f64 / self.list.len() as f64;
    }
}
```

<span class="caption">Codeblock 17-2: Implementierungen der öffentlichen
Methoden `add`, `remove` und `average` auf  `AveragedCollection`</span>

Die öffentlichen Methoden `add`, `remove` und `average` sind die einzigen
Möglichkeiten, auf Daten in einer `AveragedCollection`-Instanz zuzugreifen oder
sie zu ändern. Wenn ein Eintrag mit der Methode `add` zu `list` hinzugefügt
oder mit der Methode `remove` entfernt wird, rufen die Implementierungen der
einzelnen Methoden die private Methode `update_average` auf, die auch das
Aktualisieren des Feldes `average` übernimmt.

Wir lassen die Felder `list` und `average` privat, sodass es keine Möglichkeit
für externen Code gibt, Elemente direkt zum Feld `list` hinzuzufügen oder zu
entfernen; andernfalls könnte das Feld `average` inkonsistent werden, wenn sich
`list` ändert. Die Methode `average` gibt den Wert im Feld `average` zurück,
sodass externer Code den Wert `average` lesen, aber nicht verändern kann.

Da wir die Implementierungsdetails der Struktur `AveragedCollection` gekapselt
haben, können wir Aspekte, z.B. die Datenstruktur, in Zukunft leicht ändern.
Zum Beispiel könnten wir ein `HashSet<i32>` anstelle eines `Vec<i32>` für das
`list`-Feld verwenden. Solange die Signaturen der öffentlichen Methoden `add`,
`remove` und `average` gleich bleiben, würde Code, der `AveragedCollection`
verwendet, nicht geändert werden müssen. Wenn wir stattdessen `list` öffentlich
machen würden, wäre dies nicht unbedingt der Fall: `HashSet<i32>` und
`Vec<i32>` haben unterschiedliche Methoden zum Hinzufügen und Entfernen von
Elementen, sodass externer Code wahrscheinlich geändert werden müsste, wenn er
`list` direkt modifizieren würde.

Wenn die Kapselung ein erforderlicher Aspekt ist, damit eine Sprache als
objektorientiert betrachtet werden kann, dann erfüllt Rust diese Anforderung.
Die Möglichkeit, `pub` für verschiedene Teile des Codes zu verwenden oder auch
nicht, ermöglicht die Kapselung von Implementierungsdetails.

### Vererbung als Typsystem und für gemeinsamen Code

*Vererbung* ist ein Mechanismus, mit dem ein Objekt Elemente von der Definition
eines anderen Objekts erben kann und so die Daten und das Verhalten des
übergeordneten Objekts erhält, ohne dass du diese erneut definieren musst.

Wenn eine Sprache Vererbung haben muss, um eine objektorientierte Sprache zu
sein, dann ist Rust keine solche. Es gibt keine Möglichkeit, eine Struktur zu
definieren, die die Felder und Methodenimplementierungen der Elternstruktur
erbt, ohne ein Makro zu benutzen.

Wenn du jedoch daran gewöhnt bist, Vererbung in deinem
Programmierwerkzeugkasten zu haben, kannst du in Rust andere Lösungen
verwenden, je nachdem, warum du überhaupt zu Vererbung gegriffen hast.

Du würdest dich aus zwei Hauptgründen für die Vererbung entscheiden. Einer ist
die Wiederverwendung von Code: Du kannst ein bestimmtes Verhalten für einen Typ
implementieren und die Vererbung ermöglicht es dir, diese Implementierung für
einen anderen Typ wiederzuverwenden. Du kannst das auf begrenzte Weise in
Rust-Code unter Verwendung von Standard-Merkmalsmethoden-Implementierungen tun,
was du in Codeblock 10-14 gesehen hast, als wir eine Standard-Implementierung
der Methode `summarize` für das Merkmal (trait) `Summary` hinzugefügt haben.
Jeder Typ, der das Merkmal `Summary` implementiert, hätte die Methode
`summarize` ohne weiteren Code darauf zur Verfügung. Dies ist vergleichbar mit
einer Elternklasse, die eine Implementierung einer Methode hat, und einer
erbenden Kindklasse, die ebenfalls die Implementierung der Methode hat. Wir
können auch die Standard-Implementierung der Methode `summarize` außer Kraft
setzen, wenn wir das Markmal `Summary` implementieren, die einer Kindklasse
ähnelt, die die Implementierung einer von einer Elternklasse geerbten Methode
außer Kraft setzt.

Der andere Grund, Vererbung zu verwenden, bezieht sich auf das Typsystem: Ein
untergeordneter Typ soll an den gleichen Stellen wie der übergeordnete Typ
verwendet werden können. Dies wird auch *Polymorphismus* (polymorphism)
genannt, d.h. du kannst mehrere Objekte zur Laufzeit gegeneinander austauschen,
wenn sie bestimmte Eigenschaften gemeinsam haben.

> ### Polymorphismus
>
> Für viele Menschen ist Polymorphismus gleichbedeutend mit Vererbung. Aber es
> ist eigentlich ein allgemeinerer Begriff, der sich auf Code bezieht, der mit
> Daten unterschiedlichen Typs arbeiten kann. Für die Vererbung sind diese
> Typen im Allgemeinen Unterklassen.
>
> Rust verwendet stattdessen generische Datentypen (generics), um über
> verschiedene mögliche Typen und Merkmalsabgrenzungen (trait bounds) zu
> abstrahieren, um Beschränkungen für das aufzuerlegen, was diese Typen bieten
> müssen. Dies wird manchmal als *begrenzter parametrischer Polymorphismus*
> (bounded parametric polymorphism) bezeichnet.

Die Vererbung ist in letzter Zeit als Lösung für das Programmierdesign in
vielen Programmiersprachen in Ungnade gefallen, da sie oft das Risiko birgt,
mehr Code als nötig zu teilen. Unterklassen sollten nicht immer alle
Charakteristiken ihrer Elternklasse teilen, bei Vererbung tun sie es aber. Dies
kann den Programmentwurf weniger flexibel machen. Es wird auch die Möglichkeit
eingeführt, Methoden auf Unterklassen aufzurufen, die keinen Sinn machen oder
die Fehler verursachen, weil die Methoden nicht auf die Unterklasse zutreffen.
Darüber hinaus lassen einige Sprachen nur Einfachvererbung zu (d.h. eine
Unterklasse kann nur von einer Klasse erben), was die Flexibilität des
Programmdesigns weiter einschränkt.

Aus diesen Gründen verfolgt Rust den anderen Ansatz durch Verwendung von
Merkmalsobjekten (trait objects) anstelle der Vererbung. Schauen wir uns an,
wie Merkmalsobjekte Polymorphismus in Rust ermöglichen.
