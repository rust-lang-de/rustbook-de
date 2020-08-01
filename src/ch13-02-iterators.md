## Eine Reihe von Elementen verarbeiten mit Iteratoren

Iteratoren ermöglichen dir, nacheinander eine Aufgabe für eine Folge von
Elementen auszuführen. Der Iterator ist für die Logik verantwortlich, die
Elemente zu durchlaufen und zu bestimmen, wann eine Sequenz beendet ist.
Durch die Verwendung von Iteratoren ist es nicht notwendig, diese Logik selbst
neu zu implementieren.

Die Iteratoren in Rust sind *faul* (lazy), das bedeutet, dass sie erst durch
Methoden verbraucht werden müssen, um einen Effekt zu haben. Der Programmcode im
Codeblock 13-13, zum Beispiel erstellt einen Iterator über die Elemente im
Vektor `v1` indem die in `Vec<T>` definierte Methode `iter` aufgerufen wird.
Dieser Programmcode macht nichts Sinnvolles.


```rust
#fn main() {
#
    let v1 = vec![1, 2, 3];

    let v1_iter = v1.iter();
#  
#}
```

<span class="caption">Codeblock 13-13: Einen Iterator erstellen</span>

Ein Iterator kann nach Erstellung auf verschiedene Weise verwendet werden. In
Codeblock 3-5 in Kapitel 3 haben wir Iteratoren mit `for`-Schleifen verwendet,
um Programmcode für jedes Element auszuführen, wenngleich wir dadurch nur den
Aufruf von `iter` schöngefärbt haben.

Im Codeblock 13-14 wird die Erstellung des Iterators von dessen Verwendung in
der `for`-Schleife getrennt. Der Iterator wird in der Variable `v1_iter`
gespeichert, und es findet noch keine Iteration statt. Erst wenn die
`for`-Schleife mit dem Iterator in `v1_iter` aufgerufen wird, wird jedes
Element von `v1_iter` in einer Iteration der Schleife verwendet, die den
jeweiligen Wert ausgibt.

```rust
#fn main() {
#    
    let v1 = vec![1, 2, 3];

    let v1_iter = v1.iter();

    for val in v1_iter {
        println!("Erhielt: {}", val);
#   }
#   
#}
```
<span class="caption">Codeblock 13-14: Verwendung eines Iterators in einer `for`
Schleife</span>

In Sprachen, deren Standardbibliotheken Iteratoren nicht bereitstellen, würde
man diese Funktionalität bereitstellen, indem man eine Variable bei Index 0
startet und diese zum Indizieren im Vektor verwendet und den Wert der 
Indexvariable bei jedem Schleifendurchlauf erhöht bis die Gesamtzahl der
Elemente im Vektor erreicht ist.

Iteratoren übernehmen derartige Logik für dich und reduzieren dadurch sich
wiederholenden Code, der zusätzliche Fehlerquellen beinhalten kann. Iteratoren
erhöhen die Flexibilität um dieselbe Logik auf unterschiedliche, sequenzielle
Art darzustellen und einen nicht bloß auf das Indexieren von Datenstrukturen, wie
Vektoren, beschränkt. Lass uns herausfinden, wie Iteratoren das bewerkstelligen.

### Das `Iterator`-Merkmal (-Trait) und die `next`-Methode

Alle Iteratoren implementieren ein Merkmal, namens `Iterator` das in der
Standardbibliothek definiert ist. Die Definition dieses Merkmals sieht wie folgt
aus:

```rust
pub trait Iterator {
    type Item;

    fn next(&mut self) -> Option<Self::Item>;

    // Methoden mit Standardimplementierung wurden elidiert
}
```
Beachte, dass in der Definition eine neue Syntax verwendet wird: `type Item` und
`Self::Item` die einen *zugeordneten Typ* (associated type) mit diesem Merkmal 
definieren. Wir werden zugeordnete Typen im Kapitel 19 besprechen. Im Moment
musst du nur wissen, dass dieser Programmcode bedeutet, dass die Implementierung
des `Iterator`-Merkmals erfordert, dass du auch einen `Item`-Typ definierst und
dieser `Item`-Typ im Rückgabetyp der `next`-Methode benutzt wird. Mit anderen
Worten wird der `Item`-Typ der vom Iterator zurückgegebene Typ sein.

Für das `Iterator`-Merkmal muss man bei der Implementierung nur eine Methode
definieren: Die `next`-Methode, die jeweils ein Element des Iterators verpackt
in `Some` zurückgibt und nach Beendigung der Iteration `None` zurückgibt.

Wir können für Iteratoren die `next`-Methode direkt aufrufen. Codeblock 13-15
zeigt, welche Werte bei wiederholten Aufrufen von `next` auf einen aus einem
Vektor erstellten Iterator zurückgegeben werden:

<span class="filename">Dateiname: src/lib.rs</span>

```rust
##[cfg(test)]
#mod tests {
#   
    #[test]
    fn iterator_demonstration() {
        let v1 = vec![1, 2, 3];

        let mut v1_iter = v1.iter();

        assert_eq!(v1_iter.next(), Some(&1));
        assert_eq!(v1_iter.next(), Some(&2));
        assert_eq!(v1_iter.next(), Some(&3));
        assert_eq!(v1_iter.next(), None);
#    }
#   
#}
#
#fn main() {}
```

<span class="caption">Codeblock 13-15: Iterator mit der `next`-Methode aufrufen</span>

Beachte, dass wir `v1_iter` veränderlich (mutable) machen mussten: Beim Aufrufen
der `next`-Methode auf einen Iterator wird, dessen interner Status geändert, der
verwendet wird, um festzustellen, wo sich der Iterator in der Sequenz befindet.
Mit anderen Worten *verbraucht* dieser Programmcode den Iterator. Jeder Aufruf
von `next` isst ein Element des Iterators auf. Als wir die `for`-Schleife
benutzten, mussten wir `v1_iter` nicht veränderlich machen, da dies schon hinter
den Kulissen geschah, als die Schleife die Eigentümerschaft (ownership) von
`v1_iter` übernahm.

Merke auch, dass die Werte, die wir von den Aufrufen von `next` erhalten
unveränderliche Referenzen (immutable references) auf die Werte im Vektor sind.
Die `iter`-Methode erzeugt einen Iterator über unveränderliche Referenzen. Wenn
wir einen Iterator erzeugen möchten der die Eigentümerschaft von `v1` übernimmt
und angeeignete Werte (owned values) zurückgibt, können wir die
`into_iter`-Methode anstelle von `iter` benutzen und wenn wir über veränderliche
Referenzen iterieren möchten, können wir `iter_mut` statt `iter` aufrufen.

### Methoden die den Iterator verbrauchen

Das `Iterator`-Merkmal verfügt über eine Vielzahl von Methoden, die in der
Standardbibliothek bereitgestellt werden. Du kannst dich über diese Methoden
informieren, indem du in der Standardbibliothek API Dokumentation (standard
library API documentation) nach dem `Iterator`-Merkmal suchst. Einige dieser
Methoden rufen in ihrer Definition die `next`-Methode auf, daher musst du die
`next`-Methode bei der Implementierung des `Iterator`-Merkmals einbauen.

Methoden die `next` aufrufen werden als *konsumierende Adapter* (consuming
adaptors) bezeichnet, da deren Aufruf den Iterator verbraucht. Ein Beispiel ist
die Methode `sum`, sie übernimmt die Eigentümerschaft des Iterators und
durchläuft die Elemente durch wiederholtes Aufrufen von `next`, wodurch der
Iterator verbraucht wird. Jedes Element wird während der Iteration zu einer
Summe hinzugefügt, die zurückgegeben wird, sobald die Iteration abgeschlossen
ist. Codeblock 13-16 enthält einen Test, der die `sum`-Methode veranschaulicht:

<span class="filename">Dateiname: src/lib.rs</span>

```rust
##[cfg(test)]
#mod tests {
#   
    #[test]
    fn iterator_sum() {
        let v1 = vec![1, 2, 3];

        let v1_iter = v1.iter();

        let total: i32 = v1_iter.sum();

        assert_eq!(total, 6);
    }
#   
#}
#
#fn main() {}
```

<span class="caption">Codeblock 13-16: Aufruf der `sum`-Methode um den Wert der
Summe aller Elemente zu erhalten</span>

Man kann `v1_iter` nach dem Aufruf von `sum` nicht verwenden, da `sum` die
Eigentümerschaft des Iterators übernimmt, auf dem sie aufgerufen wird.

### Methoden die andere Iteratoren erzeugen

Andere Methoden die im `Iterator`-Merkmal definiert sind werden als
*Iteratoradapter* (iterator adaptors) bezeichnet, sie ermöglichen dir Iteratoren
in andere Arten von Iteratoren zu ändern. Man kann mehrere Aufrufe von
Iteratorenadapter verketten und dadurch komplexe Handlungen auf lesbare Art
ausführen. Da alle Iteratoren jedoch faul sind, ist es notwendig, eine der
konsumierenden Adapter Methoden aufzurufen, um Ergebnisse zu erhalten.

Codeblock 13-17 zeigt ein Beispiel von einen Aufruf der `map`-Methode, die einen
Funktionsabschluss auf jedes Element anwendet, um einen neuen Iterator zu
erstellen. Dieser Funktionsabschluss inkrementiert den Wert jedes Elementes des
Vektors um 1. Dieser Programmcode erzeugt jedoch eine Warnung:

<span class="filename">Dateiname: src/main.rs</span>

```rust,not_desired_behavior
#fn main() {
#   
    let v1: Vec<i32> = vec![1, 2, 3];

    v1.iter().map(|x| x + 1);
#   
#}
```

<span class="caption">Codeblock 13-17: Aufruf des `map`-Iteratorenadapter um
einen neuen Iterator zu erzeugen</span>

Wir erhalten folgende Warnung:

```console
$ cargo run
   Compiling iterators v0.1.0 (file:///projects/iterators)
warning: unused `std::iter::Map` that must be used
 --> src/main.rs:4:5
  |
4 |     v1.iter().map(|x| x + 1);
  |     ^^^^^^^^^^^^^^^^^^^^^^^^^
  |
  = note: `#[warn(unused_must_use)]` on by default
  = note: iterators are lazy and do nothing unless consumed

    Finished dev [unoptimized + debuginfo] target(s) in 0.47s
     Running `target/debug/iterators`
```

Der Programmcode im Codeblock 13-17, hat keine Wirkung, der Funktionsabschluss
wird nie aufgerufen. Die Warnung erinnert uns daran, dass Iteratorenadapter faul
sind und das wir den Iterator verwenden müssen, um etwas zu bewirken.

Um das zu beheben, werden wir die `collect`-Methode verwenden, die wir im Kapitel
12 mit `env::args` im Codeblock 12-1 benutzt haben. Diese Methode konsumiert den
Iterator und sammelt die Ergebniswerte in einen Kollektionsdatentyp (collection
data type).

Im Codeblock 13-18 sammeln wir die Resultate der Iterationen über den Iterator,
der vom Aufruf der `map`-Methode zurückgegeben wird, in einem Vektor. Dieser
Vektor wird dann alle Elemente vom Originalvektor erhöht um 1 beinhalten.

<span class="filename">Dateiname: src/main.rs</span>

```rust
#fn main() {
#   
    let v1: Vec<i32> = vec![1, 2, 3];

    let v2: Vec<_> = v1.iter().map(|x| x + 1).collect();

#    assert_eq!(v2, vec![2, 3, 4]);
#  
#}
```

<span class="caption">Codeblock 13-18: Aufruf der `map`-Methode um einen
Iterator zu erzeugen und anschließend die `collect`-Methode aufzurufen um den
Iterator zu verbrauchen und einen Vektor zu erzeugen</span>

Da `map` einen Funktionsabschluss als Parameter annimmt, können wir eine
beliebige Operation spezifizieren, die wir auf jedes Element anwenden wollen.
Dies ist ein gutes Beispiel dafür, wie man mit Funktionsabschlüssen ein
Verhalten anpassen kann, während das vom `Iterator`-Merkmal bereitgestellte 
Iterationsverhalten wiederverwendet wird.

### Verwendung von Funktionsabschlüssen die ihre Umgebung erfassen

Nun, da wir uns ein wenig mit Iteratoren befasst haben, werden wir anhand
des `filter`-Iteratorenadapters eine häufige Verwendung von Funktionsabschlüssen
die ihre Umgebung erfassen zeigen. Wird die `filter`-Methode auf einen
Iterator angewendet nimmt sie einen Funktionsabschluss als Argument, der für
jedes Element übernommen wird und einen booleschen Wert (boolean) zurückgibt.
Wenn der Abschluss `true` zurückgibt, wird der Wert in den von `filter`
erzeugten Iterator aufgenommen, wird `false` zurückgegeben, wird der Wert dem
resultierenden Iterator nicht hinzugefügt.

Im Codeblock 13-19 benutzen wir `filter` mit einem Funktionsabschluss, der die
Variable `shoe_size` aus seiner Umgebung erfasst, um über eine Kollektion von
`shoe`-Struktur (struct) Instanzen zu iterieren. Es wird nur Schuhe (shoes) einer
bestimmten Größe zurückgeben.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
#[derive(PartialEq, Debug)]
struct Shoe {
    size: u32,
    style: String,
}

fn shoes_in_my_size(shoes: Vec<Shoe>, shoe_size: u32) -> Vec<Shoe> {
    shoes.into_iter().filter(|s| s.size == shoe_size).collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn filters_by_size() {
        let shoes = vec![
            Shoe {
                size: 10,
                style: String::from("sneaker"),
            },
            Shoe {
                size: 13,
                style: String::from("sandal"),
            },
            Shoe {
                size: 10,
                style: String::from("boot"),
            },
        ];

        let in_my_size = shoes_in_my_size(shoes, 10);

        assert_eq!(
            in_my_size,
            vec![
                Shoe {
                    size: 10,
                    style: String::from("sneaker")
                },
                Shoe {
                    size: 10,
                    style: String::from("boot")
                },
            ]
        );
    }
}

fn main() {}
```

<span class="caption">Codeblock 13-19: Die `filter`-Methode mit einen
Funktionsabschluss benutzen der `shoe_size` erfasst</span>

Die `shoes_in_my_size`-Funktion übernimmt die Eigentümerschaft über einen Vektor
aus Schuhen mit der Schuhgröße als Parameter und gibt einen Vektor zurück, der
nur Schuhe einer bestimmten Größe enthält.

Im Funktionsrumpf von `shoes_in_my_size` rufen wir `into_iter` auf, um einen
Iterator zu erzeugen, der die Eigentümerschaft vom Vektor übernimmt. Im Anschluss
rufen wir den `filter`-Adapter auf, um einen neuen Iterator zu erzeugen, der nur
Elemente enthält, für die der Funktionsabschluss `true` zurückgibt.

Der Funktionsabschluss erfasst den `shoe_size`-Parameter aus seiner Umgebung und
vergleicht dessen Wert mit der jeweiligen Schuhgröße und behält nur Schuhe der
gewählten Größe. Zuletzt sammelt der Aufruf der `collect`-Methode die
zurückgegeben Werte des angeschlossenen Adapters in den Vektor, der von der
Funktion zurückgegeben wird.

Der Test zeigt, wenn wir `shoes_in_my_size` aufrufen, bekommen wir nur Schuhe
der spezifizierten Größe zurück.

### Mit dem `Iterator`-Merkmal eigene Iteratoren erstellen

Wir haben bereits gezeigt, wie man mit `iter` und `into_iter` oder `iter_mut` für
einen Vektor aufgerufen einen Iterator erstellen können. Sie können Iteratoren
auch aus anderen Kollektion-Typen der Standardbibliothek wie zum Beispiel einer 
Hashtabelle (hash map) herstellen. Sie können auch beliebige Iteratoren
durch Implementierung des `Iterator`-Merkmals auf eigene Typen erstellen. 
Wie bereits erwähnt ist die einzige Methode, für die du eine Definition angeben
musst, die `next`-Methode. Sobald man das getan hat, kann man alle anderen
Methoden verwenden, die die Standardimplementierung des `Iterator`-Merkmals
bereitstellt.

Erstellen wir nun einen Iterator zur Demonstration, der immer nur von 1 bis 5 zählt.
Zunächst erstellen wir eine Struktur, die einige Werte enthält, anschließend
machen wir aus dieser Struktur einen Iterator, indem wir das `Iterator`-Merkmal
implementieren und die Werte in dieser Implementierung benutzen.

Codeblock 13-20 enthält die Definition einer `Counter`-Struktur und eine
zugehörige `new`-Funktion zur Erstellung von Instanzen von `Counter`:

<span class="filename">Dateiname: src/lib.rs</span>

```rust
struct Counter {
    count: u32,
}

impl Counter {
    fn new() -> Counter {
        Counter { count: 0 }
    }
}

fn main() {}
```

<span class="caption">Codeblock 13-20: Definition einer `Counter`-Struktur und einer
Funktion `new` die Instanzen von `Counter` mit einem Startwert 0 für `count` erstellt</span>

Die `Counter`-Struktur beinhaltet ein Feld `count`, dieses Feld hält einen
`u32`-Wert der den aktuellen Status der Iteration von 1 bis 5 wiedergibt. Das
Feld `count` ist privat, da wir möchten, das die Implementierung von `Counter`
den Wert verwaltet. Die `new`-Funktion erzwingt, dass neue Instanzen stets mit
einem Wert 0 im `count`-Feld beginnen.

Als Nächstes werden wir das `Iterator`-Merkmal für unseren `Counter`-Typ
implementieren, indem wir den Rumpf der `next`-Methode so definieren, das er
beinhaltet was wir geschehen lassen möchten, wenn der Iterator benützt wird.
Siehe Codeblock 12-21:

<span class="filename">Dateiname: src/lib.rs</span>

```rust
#struct Counter {
#    count: u32,
#}
#
#impl Counter {
#    fn new() -> Counter {
#        Counter { count: 0 }
#    }
#}
#
#
impl Iterator for Counter {
    type Item = u32;

    fn next(&mut self) -> Option<Self::Item> {
        if self.count < 5 {
            self.count += 1;
            Some(self.count)
        } else {
            None
        }
    }
}
#
#
#fn main() {}
```

<span class="caption">Codeblock 13-21: Implementierung des `Iterator`-Merkmals für
die `Counter`-Struktur</span>

Wir setzen den zugehörigen Typ unseres Iterators auf `u32`, was bedeutet, dass 
der Iterator `u32`-Werte zurückgibt. Nochmals, kümmer dich derzeit nicht um 
zugehörige Typen, wir werden sie im Kapitel 19 behandeln.

Wir möchten, dass unser Iterator 1 zum aktuellen Wert hinzufügt, daher haben wir 
`count` auf 0 initialisiert, damit er zuerst 1 zurückgibt, wenn der Wert von
`count` kleiner als 5 ist, erhöht `next` `count` und gibt den aktuellen Wert
zurück, der in `Some` eingeschlossen ist. Wenn `count` gleich 5 ist, stoppt
unser Iterator das Inkrementieren und gibt immer `None` zurück.

#### Verwendung der `next`-Methode unseres `Counter`-Iterators

Sobald wir das `Iterator`-Merkmal implementiert haben, verfügen wir über einen
Iterator! Codeblock 13-22 zeigt mittels Test, dass wir die
`Iterator`-Funktionalität unserer `Counter`-Funktion benutzen können, indem wir
die `next`-Methode direkt auf ihn verwenden, so wie wir es mit dem von einem
Vektor erzeugten Iterator im Codeblock 13-15 gemacht haben.

<span class="filename">Codeblock: src/lib.rs</span>

```rust
#struct Counter {
#    count: u32,
#}
#
#impl Counter {
#    fn new() -> Counter {
#        Counter { count: 0 }
#    }
#}
#
#impl Iterator for Counter {
#    type Item = u32;
#
#    fn next(&mut self) -> Option<Self::Item> {
#        if self.count < 5 {
#            self.count += 1;
#            Some(self.count)
#        } else {
#            None
#        }
#    }
#}
#
##[cfg(test)]
#mod tests {
#    use super::*;
#
#    
    #[test]
    fn calling_next_directly() {
        let mut counter = Counter::new();

        assert_eq!(counter.next(), Some(1));
        assert_eq!(counter.next(), Some(2));
        assert_eq!(counter.next(), Some(3));
        assert_eq!(counter.next(), Some(4));
        assert_eq!(counter.next(), Some(5));
        assert_eq!(counter.next(), None);
    }
#
#}
#
#fn main() {}
```

<span class="caption">Codeblock 13-22: Testen der Funktionalität der
Implementierung der `next`-Methode</span>

Dieser Test erstellt eine neue Instanz von `Counter` in der `counter`-Variable
und ruft dann wiederholt `next` auf, um zu überprüfen, ob wir das Verhalten
entsprechend implementiert haben und der Iterator die Werte von 1 bis 5
zurückgibt.

#### Verwendung anderer `Iterator`-Merkmal Methoden

Da wir das `Iterator`-Merkmal durch implementieren der `next`-Methode
eingerichtet haben, können wir nun beliebige Methoden der
Standardimplementierung des `Iterator`-Merkmals benutzen, da sie alle die
Funktionalität der `next`-Methode verwenden.

Wenn wir beispielsweise, die Werte übernehmen  und sie mit den Werten
einer anderen `Counter`-Instanz koppeln wollen und nach dem Überspringen des
ersten Wertes der anderen Instanz jedes Zahlenpaar miteinander multiplizieren
dabei allerdings nur die Werte behalten, die durch 3 teilbar sind und diese dann
summieren möchten, können wir das wie im Codeblock 13-23 beschrieben erreichen:

<span class="filename">Dateiname: src/lib.rs</span>

```rust
#struct Counter {
#    count: u32,
#}
#
#impl Counter {
#    fn new() -> Counter {
#        Counter { count: 0 }
#    }
#}
#
#impl Iterator for Counter {
#    type Item = u32;
#
#    fn next(&mut self) -> Option<Self::Item> {
#        if self.count < 5 {
#            self.count += 1;
#            Some(self.count)
#        } else {
#            None
#        }
#    }
#}
#
##[cfg(test)]
#mod tests {
#    use super::*;
#
#    #[test]
#    fn calling_next_directly() {
#        let mut counter = Counter::new();
#
#        assert_eq!(counter.next(), Some(1));
#        assert_eq!(counter.next(), Some(2));
#        assert_eq!(counter.next(), Some(3));
#        assert_eq!(counter.next(), Some(4));
#        assert_eq!(counter.next(), Some(5));
#        assert_eq!(counter.next(), None);
#    }
#
#   
    #[test]
    fn using_other_iterator_trait_methods() {
        let sum: u32 = Counter::new()
            .zip(Counter::new().skip(1))
            .map(|(a, b)| a * b)
            .filter(|x| x % 3 == 0)
            .sum();        assert_eq!(18, sum);
    }
#    
#}
#
#fn main() {}
```
<span class="caption">Codeblock 13-23: Benutzung einer Auswahl von `Iterator`-Merkmal
Methoden auf unseren `Counter`-Iterator</span>

Beachte, dass `zip` nur vier Paare erzeugt. Das theoretische fünfte Paar `(5,
None)` wird nicht erzeugt da `zip` `None` zurückgibt wenn einer seiner
Eingabeiteratoren `None` zurückgibt.

Alle diese Methodenaufrufe sind möglich, da wir angegeben haben wie die
`next`-Methode in `Counter` funktioniert und die Standardbibliothek für andere
Methoden, die `next` aufrufen, Standardimplementierungen bereitstellt.
