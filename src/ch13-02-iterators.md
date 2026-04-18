## Eine Reihe von Elementen verarbeiten mit Iteratoren

Iteratoren ermöglichen dir, nacheinander eine Aufgabe für eine Folge von
Elementen auszuführen. Der Iterator ist für die Logik verantwortlich, die
Elemente zu durchlaufen und zu bestimmen, wann eine Sequenz beendet ist.
Durch die Verwendung von Iteratoren ist es nicht notwendig, diese Logik selbst
neu zu implementieren.

Die Iteratoren in Rust sind _faul_ (lazy), das bedeutet, dass sie erst durch
Methodenaufrufe konsumiert werden müssen, um einen Effekt zu haben. Der
Programmcode in Listing 13-10 erstellt beispielsweise einen Iterator über die
Elemente im Vektor `v1` indem die in `Vec<T>` definierte Methode `iter`
aufgerufen wird. Dieser Programmcode macht nichts Sinnvolles.


```rust
let v1 = vec![1, 2, 3];

let v1_iter = v1.iter();
```

<span class="caption">Listing 13-10: Einen Iterator erstellen</span>

Der Iterator wird in der Variable `v1_iter` gespeichert. Sobald wir einen
Iterator erstellt haben, können wir ihn auf verschiedene Weise verwenden.
In Listing 3-5 haben wir über ein Array iteriert, indem wir eine
`for`-Schleife verwendet haben, um einen Code für jedes Element auszuführen.
Unter der Haube wird dabei implizit ein Iterator erzeugt und dann konsumiert,
aber wir haben bis jetzt übersehen, wie das genau funktioniert.

In Listing 13-11 wird die Erstellung des Iterators von dessen Verwendung in
der `for`-Schleife getrennt. Wenn die `for`-Schleife unter Verwendung des
Iterators in `v1_iter` aufgerufen wird, wird jedes Element des Iterators in
einer Iteration der Schleife verwendet, die den jeweiligen Wert ausgibt.

```rust
let v1 = vec![1, 2, 3];

let v1_iter = v1.iter();

for val in v1_iter {
    println!("Erhalten: {val}");
}
```

<span class="caption">Listing 13-11: Verwendung eines Iterators in einer
`for`-Schleife</span>

In Sprachen, deren Standardbibliotheken Iteratoren nicht bereitstellen, würde
man diese Funktionalität bereitstellen, indem man eine Variable bei Index 0
startet und diese zum Indizieren im Vektor verwendet und den Wert der 
Indexvariable bei jedem Schleifendurchlauf erhöht bis die Gesamtzahl der
Elemente im Vektor erreicht ist.

Iteratoren übernehmen derartige Logik für dich und reduzieren dadurch sich
wiederholenden Code, der zusätzliche Fehlerquellen beinhalten kann. Iteratoren
geben dir mehr Flexibilität bei der Verwendung derselben Logik für viele
verschiedene Arten von Sequenzen, nicht nur für Datenstrukturen, die du wie
Vektoren indizieren kannst. Lass uns herausfinden, wie Iteratoren das
bewerkstelligen.

### Das Trait `Iterator` und die Methode `next`

Alle Iteratoren implementieren ein Trait namens `Iterator` das in der
Standardbibliothek definiert ist. Die Definition dieses Traits sieht wie folgt
aus:

```rust
pub trait Iterator {
    type Item;

    fn next(&mut self) -> Option<Self::Item>;

    // Methoden mit Standardimplementierung wurden elidiert
}
```

Beachte, dass in der Definition eine neue Syntax verwendet wird: `type Item` und
`Self::Item` die einen zugeordneten Typ (associated type) mit diesem Trait
definieren. Wir werden zugeordnete Typen im Kapitel 20 besprechen. Im Moment
musst du nur wissen, dass dieser Programmcode bedeutet, dass die Implementierung
des `Iterator`-Traits erfordert, dass du auch einen `Item`-Typ definierst und
dieser `Item`-Typ im Rückgabetyp der Methode `next` benutzt wird. Mit anderen
Worten wird der `Item`-Typ der vom Iterator zurückgegebene Typ sein.

Für das `Iterator`-Trait muss man bei der Implementierung nur eine Methode
definieren: Die Methode `next`, die jeweils ein Element des Iterators verpackt
in `Some` zurückgibt und nach Beendigung der Iteration `None` zurückgibt.

Wir können für Iteratoren die Methode `next` direkt aufrufen. Listing 13-12
zeigt, welche Werte bei wiederholten Aufrufen von `next` auf einen aus einem
Vektor erstellten Iterator zurückgegeben werden:

<span class="filename">Dateiname: src/lib.rs</span>

```rust,noplayground
# #[cfg(test)]
# mod tests {
#
    #[test]
    fn iterator_demonstration() {
        let v1 = vec![1, 2, 3];

        let mut v1_iter = v1.iter();

        assert_eq!(v1_iter.next(), Some(&1));
        assert_eq!(v1_iter.next(), Some(&2));
        assert_eq!(v1_iter.next(), Some(&3));
        assert_eq!(v1_iter.next(), None);
    }
#
# }
```

<span class="caption">Listing 13-12: Iterator mit der Methode `next`
aufrufen</span>

Beachte, dass wir `v1_iter` veränderbar (mutable) machen mussten: Beim Aufrufen
der Methode `next` auf einen Iterator wird dessen interner Status geändert, der
verwendet wird, um festzustellen, wo sich der Iterator in der Sequenz befindet.
Mit anderen Worten _verbraucht_ dieser Programmcode den Iterator. Jeder Aufruf
von `next` isst ein Element des Iterators auf. Als wir die `for`-Schleife
benutzten, mussten wir `v1_iter` nicht veränderbar machen, da dies schon hinter
den Kulissen geschah, als die Schleife das Eigentum (ownership) an `v1_iter`
übernahm.

Merke auch, dass die Werte, die wir von den Aufrufen von `next` erhalten,
unveränderbare Referenzen (immutable references) auf die Werte im Vektor sind.
Die Methode `iter` erzeugt einen Iterator über unveränderbare Referenzen. Wenn
wir einen Iterator erzeugen möchten der das Eigentum an `v1` übernimmt und
angeeignete Werte (owned values) zurückgibt, können wir die Methode `into_iter`
anstelle von `iter` benutzen, und wenn wir über veränderbare Referenzen
iterieren möchten, können wir `iter_mut` statt `iter` aufrufen.

### Methoden die den Iterator verbrauchen

Das Trait `Iterator` verfügt über eine Vielzahl von Methoden, die in der
Standardbibliothek bereitgestellt werden. Du kannst dich über diese Methoden
informieren, indem du in der Standardbibliothek-API-Dokumentation (standard
library API documentation) nach dem Trait `Iterator` suchst. Einige dieser
Methoden rufen in ihrer Definition die Methode `next` auf, daher musst du die
Methode `next` bei der Implementierung des Trait `Iterator` einbauen.

Methoden die `next` aufrufen werden als _konsumierende Adapter_ (consuming
adapters) bezeichnet, da deren Aufruf den Iterator verbraucht. Ein Beispiel ist
die Methode `sum`, sie übernimmt das Eigentum am Iterators und durchläuft die
Elemente durch wiederholtes Aufrufen von `next`, wodurch der Iterator verbraucht
wird. Jedes Element wird während der Iteration zu einer Summe hinzugefügt, die
zurückgegeben wird, sobald die Iteration abgeschlossen ist. Listing 13-13
enthält einen Test, der die Methode `sum` veranschaulicht:

<span class="filename">Dateiname: src/lib.rs</span>

```rust,noplayground
# #[cfg(test)]
# mod tests {
#
    #[test]
    fn iterator_sum() {
        let v1 = vec![1, 2, 3];

        let v1_iter = v1.iter();

        let total: i32 = v1_iter.sum();

        assert_eq!(total, 6);
    }
#
# }
```

<span class="caption">Listing 13-13: Aufruf der Methode `sum` um den Wert der
Summe aller Elemente zu erhalten</span>

Man kann `v1_iter` nach dem Aufruf von `sum` nicht verwenden, da `sum` das
Eigentum am Iterators übernimmt, auf dem es aufgerufen wird.

### Methoden die andere Iteratoren erzeugen

_Iterator-Adaptoren_ sind Methoden, die auf dem Trait `Iterator` definiert
sind und den Iterator nicht verbrauchen. Stattdessen erzeugen sie andere
Iteratoren, indem sie einen Aspekt des ursprünglichen Iterators verändern.

Listing 13-14 zeigt ein Beispiel für den Aufruf der Iterator-Adaptor-Methode
`map`, die einen Closure für jedes Element aufruft, während die Elemente
durchlaufen werden. Die Methode `map` gibt einen neuen Iterator zurück, der die
geänderten Elemente erzeugt. Der Closure erzeugt hier einen neuen Iterator, der
jedes Element des Vektors um 1 erhöht.

<span class="filename">Dateiname: src/main.rs</span>

```rust,not_desired_behavior
let v1: Vec<i32> = vec![1, 2, 3];

v1.iter().map(|x| x + 1);
```

<span class="caption">Listing 13-14: Aufruf des Iteratoradapters `map` um
einen neuen Iterator zu erzeugen</span>

Dieser Code führt jedoch zu einer Warnung:

```console
$ cargo run
   Compiling iterators v0.1.0 (file:///projects/iterators)
warning: unused `Map` that must be used
 --> src/main.rs:4:5
  |
4 |     v1.iter().map(|x| x + 1);
  |     ^^^^^^^^^^^^^^^^^^^^^^^^
  |
  = note: iterators are lazy and do nothing unless consumed
  = note: `#[warn(unused_must_use)]` on by default
help: use `let _ = ...` to ignore the resulting value
  |
4 |     let _ = v1.iter().map(|x| x + 1);
  |     +++++++

warning: `iterators` (bin "iterators") generated 1 warning
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.47s
     Running `target/debug/iterators`
```

Der Programmcode in Listing 13-14 hat keine Wirkung, der Closure wird nie
aufgerufen. Die Warnung erinnert uns daran, dass Iteratoradapter faul sind und
dass wir den Iterator verwenden müssen, um etwas zu bewirken.

Um das zu beheben, werden wir die Methode `collect` verwenden, die wir mit
`env::args` im Listing 12-1 benutzt haben. Diese Methode konsumiert den
Iterator und sammelt die Ergebniswerte in einen Kollektionsdatentyp (collection
data type).

In Listing 13-15 sammeln wir die Resultate der Iterationen über den Iterator,
der vom Aufruf der Methode `map` zurückgegeben wird, in einem Vektor. Dieser
Vektor wird dann alle Elemente vom Originalvektor erhöht um 1 beinhalten.

<span class="filename">Dateiname: src/main.rs</span>

```rust
let v1: Vec<i32> = vec![1, 2, 3];

let v2: Vec<_> = v1.iter().map(|x| x + 1).collect();

assert_eq!(v2, vec![2, 3, 4]);
```

<span class="caption">Listing 13-15: Aufruf der Methode `map` um einen
Iterator zu erzeugen und anschließend der Methode `collect` um den
Iterator zu verbrauchen und einen Vektor zu erzeugen</span>

Da `map` einen Closure als Parameter annimmt, können wir eine beliebige
Operation spezifizieren, die wir auf jedes Element anwenden wollen. Dies ist ein
gutes Beispiel dafür, wie man mit Closures ein Verhalten anpassen kann, während
das vom Trait `Iterator` bereitgestellte Iterationsverhalten wiederverwendet
wird.

Du kannst mehrere Aufrufe von Iterator-Adaptoren verketten, um komplexe
Aktionen auf lesbare Weise durchzuführen. Da jedoch alle Iteratoren faul sind,
musst du eine der konsumierenden Adaptermethoden aufrufen, um Ergebnisse aus
Aufrufen von Iteratoradaptern zu erhalten.

### Closures die ihre Umgebung erfassen

Viele Iterator-Adapter nehmen Closures als Argumente, und in der Regel werden
diese Closures solche sein, die ihre Umgebung erfassen.

In diesem Beispiel verwenden wir die Methode `filter`, die einen Closure
entgegennimmt. Der Closure holt ein Element aus dem Iterator und gibt ein `bool`
zurück. Wenn der Closure `true` zurückgibt, wird der Wert in die von `filter`
erzeugte Iteration aufgenommen. Wenn der Closure `false` zurückgibt, wird der
Wert nicht aufgenommen.

Im Listing 13-16 benutzen wir `filter` mit einem Closure, der die Variable
`shoe_size` aus seiner Umgebung erfasst, um über eine Kollektion von
`Shoe`-Strukturinstanzen zu iterieren. Er wird nur Schuhe (shoes) einer
bestimmten Größe zurückgeben.

<span class="filename">Dateiname: src/lib.rs</span>

```rust,noplayground
#[derive(PartialEq, Debug)]
struct Shoe {
    size: u32,
    style: String,
}

fn shoes_in_size(shoes: Vec<Shoe>, shoe_size: u32) -> Vec<Shoe> {
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

        let in_my_size = shoes_in_size(shoes, 10);

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
```

<span class="caption">Listing 13-16: Die Methode `filter` mit einen Closure
benutzen, der `shoe_size` erfasst</span>

Die Funktion `shoes_in_size` übernimmt das Eigentum am Vektor aus Schuhen mit
der Schuhgröße als Parameter und gibt einen Vektor zurück, der nur Schuhe einer
bestimmten Größe enthält.

Im Funktionsrumpf von `shoes_in_size` rufen wir `into_iter` auf, um einen
Iterator zu erzeugen, der das Eigentum am Vektor übernimmt. Im Anschluss rufen
wir den `filter`-Adapter auf, um einen neuen Iterator zu erzeugen, der nur
Elemente enthält, für die der Closure `true` zurückgibt.

Der Closure erfasst den `shoe_size`-Parameter aus seiner Umgebung und vergleicht
dessen Wert mit der jeweiligen Schuhgröße und behält nur Schuhe der gewählten
Größe. Zuletzt sammelt der Aufruf der Methode `collect` die zurückgegeben Werte
des angeschlossenen Adapters in den Vektor, der von der Funktion zurückgegeben
wird.

Der Test zeigt, wenn wir `shoes_in_size` aufrufen, bekommen wir nur Schuhe
der spezifizierten Größe zurück.
