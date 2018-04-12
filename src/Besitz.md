# Besitz

Dieser Guide ist einer von dreien, der Rusts Ownership-System.
präsentiert. Dies ist eines von Rusts einzigartigen und verlockenden
Features mit denen Rust Entwickler vertraut sein sollten.
Durch Ownership [engl.: Besitz] erreicht Rust sein größtes Ziel,
die Speichersicherheit.
Es gibt ein paar verschiedene Konzepte, jedes mit seinem eigenen Kapitel:

* Besitz, das was du gerade liest.
* [Ausleihen][borrowing], und das assozierte Feature ‘Referenzen’
* [Lebensdauer][lifetimes], ein fortgeschrittenes Konzept des Ausleihens.

Diese drei Kapitel sind verwandt und deswegen in dieser Reihenfolge zu lesen.
Du wirst alle drei benötigen um das Ownership-System vollständig zu verstehen.

[borrowing]: Referenzen_Und_Ausleihen.html
[lifetimes]: Lebensdauer.html

# Meta

Bevor wir in die Details gehen gibt es zwei wichtige Hinweise über das
Ownership-System.

Rust hat einen Fokus auf Sicherheit und Geschwindigkeit.
Es erfüllt diese Ziele durch viele "kostenfreie Abstraktionen"
[‘zero-cost abstractions’], was bedeutet, dass in Rust die Kosten so niedrig
wie möglich sind um diese Abstraktionen funktionieren zu lassen.
Jegliche Analyse über die wie in diesem Guide sprechen wird
_zur Kompilierzeit_ ausgeführt. Du zahlst für diese Features
keine Extrakosten zur Laufzeit.

Jedoch hat dieses System einen gewissen Preis: Die Lernkurve.
Viele neue Rust-Nutzer erleben etwas,
was wir "mit dem *borrow checker* kämpfen" nennen,
wobei dann Rust verweigert ein Programm zu kompilieren,
bei dem der Autor denkt, dass es korrekt ist.
Das passiert häufig, da das mentale Modell des Programmierers von Ownership
nicht den eigentlichen Regeln entspricht, die Rust implementiert.
Du wirst wahrscheinlich zuerst etwas Ähnliches erleben.
Die guten Nachricht ist aber:
Erfahrenere Rust-Entwickler berichten, dass, sobald sie eine Zeit
mit den Regeln des Ownership-Systems gearbeitet haben, sie immer weniger
mit dem *borrow checker* kämpfen müssen. 

Mit diesem Wissen, lass uns über Besitz lernen.

# Besitz

[Variablenbindungen][bindings] haben eine bestimmte Eigenschaft in Rust:
Sie ‘besitzen’ das woran sie gebunden sind.
Das bedeutet, dass Rust die gebundene Ressource freigibt,
wenn eine Bindung den Scope verlässt. Zum Beispiel:

```rust
fn foo() {
    let v = vec![1, 2, 3];
}
```

Wenn `v` in den Scope eingeführt wird, dann wird ein neuer [`Vec<T>`][vect]
erzeugt. In diesem Fall alloziert der Vektor auch Speicher auf dem Heap für
die ersten drei Elemente. Wenn `v` dann am Ende von `foo` den Scope verlässt,
räumt Rust alles was mit dem Vektor zu tun hat auf, sogar den auf dem Heap
allozierten Speicher.
Dies passiert deterministisch am Ende des Scopes.

[vect]: https://doc.rust-lang.org/std/std/vec/struct.Vec.html
[heap]: Der_Stack_Und_Der_Heap.html
[bindings]: Variablenbindung.html

# Move Semantik

Es gibt jedoch noch ein paar mehr Feinheiten hier: Rust stellt sicher,
dass es _genau eine_ Bindung an eine bestimmte Ressource gibt.
Zum Beispiel, wenn wir einen Vektor haben, können wir ihn einer
anderen Bindung zuweisen:

```rust
let v = vec![1, 2, 3];

let v2 = v;
```

Aber, wenn wir versuchen `v` danach zu verwenden,
bekommen wir einen Fehler:

```rust
let v = vec![1, 2, 3];

let v2 = v;

println!("v[0] is: {}", v[0]);
```

Der Fehler sieht so aus:

```text
error: use of moved value: `v`
println!("v[0] is: {}", v[0]);
                        ^
```

Etwas ähnliches passiert, wenn wir eine Funktion definieren,
welche etwas in Besitz nimmt und dann versuchen etwas zu verwenden,
nachdem wir es ihr als Argument übergeben haben:

```rust
fn take(v: Vec<i32>) {
    // what happens here isn’t important.
}

let v = vec![1, 2, 3];

take(v);

println!("v[0] is: {}", v[0]);
```

Der gleiche Fehler: ‘use of moved value’.
Wenn wir den Besitz an etwas übergeben, dann sagen wir,
dass wir die Sache "bewegt" [moved] haben. Man braucht hier keine
besondere Annotation, Rust macht das einfach standardmäßig.

## Die Details

Der Grund warum die Bindung nach einem *move* nicht verwenden können ist
subtil, aber sehr wichtig. Wenn wir solchen Code schreiben:

```rust
let v = vec![1, 2, 3];

let v2 = v;
```

Die erste Zeile alloziert Speicher für das Vektor-Objekt `v` und für
die Daten, die es enthält. Das Vektor-Objekt wird auf dem [Stack][sh]
gespeichert und enthält einen Zeiger auf den Inhalt (`[1, 2, 3]`), welcher
auf dem [Heap][sh] gespeichert ist. Wenn wir `v` zu `v2` bewegen,
dann wird eine Kopie dieses Zeigers für `v2` erstellt.
Das bedeutet, dass es zwei Zeiger gibt, die auf den Inhalt des Vektors auf dem
Heap zeigen. Es würde Rusts Sicherheitsgarantien verletzen indem es ein
*data race* ermöglicht. Deswegen verbietet Rust es `v` zu benutzen,
nachdem wir es bewegt haben.

[sh]: Der_Stack_Und_Der_Heap.html

Es ist auch wichtig zu erwähnen, dass Optimierungen die tatsächliche Kopie
der Bytes auf dem Stack entfernen können, je nach den Umständen.
Also ist ein `move` nicht so ineffizient wie er zuerst scheint.

## `Copy` Typen

Wir haben etabliert, dass, wenn Besitz an eine andere Bindung übertragen wird,
man die Originalbindung nicht mehr verwenden lassen. Es gibt jedoch ein
[Trait][traits] namens `Copy` der dieses Verhalten ändert.
Wir haben über Traits noch nicht diskutiert, aber fürs erste kannst du sie
dir als eine Art Annotation eines bestimmten Types vorstellen,
welche zusätzliches Verhalten hinzufügt. Zum Beispiel:


```rust
let v = 1;

let v2 = v;

println!("v is: {}", v);
```

In diesem Fall ist `v` ein `i32`, welcher den `Copy` Trait implementiert.
Das bedeutet, dass genau wie bei einem *move* eine Kopie der Daten gemacht
wird, wenn wir `v` nach `v2` zuweisen. Aber anders als bei einem *move*,
können wir `v` danach trotzdem verwenden. Das ist so, weil ein `i32`
keine Zeiger auf irgendwelche Daten woanders hat und somit eine
vollständige Kopie ist.

Alle primitiven Typen implementieren den `Copy` Trait und ihr Besitz
wird deswegen nicht bewegt wie man vermuten könnte, gemäß den
´Ownership Regeln´. Zum Beispiel kompilieren die folgenden beiden
Codeschnipsel nur, weil `i32` und `bool` den `Copy` Trait implementieren.

```rust
fn main() {
    let a = 5;

    let _y = double(a);
    println!("{}", a);
}

fn double(x: i32) -> i32 {
    x * 2
}
```

```rust
fn main() {
    let a = true;

    let _y = change_truth(a);
    println!("{}", a);
}

fn change_truth(x: bool) -> bool {
    !x
}
```

Wenn wir Typen verwendet hätten, die nicht den `Copy` Trait implementieren,
dann würden wir einen Kompilierfehler bekommen, da wir versucht hätten
einen *bewegten Wert* [moved value] zu verwenden.

```text
error: use of moved value: `a`
println!("{}", a);
               ^
```

Wir werden im [Traits][traits] Abschnitt diskutieren wie
man mit seinen eigenen Typen `Copy` implementiert.

[traits]: Traits.html

# Mehr als Besitz

Wenn wir jedes mal den Besitz zurückgeben müssten,
dann würde jede Funktion die wir schreiben so aussehen: 

```rust
fn foo(v: Vec<i32>) -> Vec<i32> {
    // do stuff with v

    // hand back ownership
    v
}
```

Das würde sehr lästig werden. Es würde umso schlimmer werden je mehr
Sachen wir in Besitz nehmen wollen:

```rust
fn foo(v1: Vec<i32>, v2: Vec<i32>) -> (Vec<i32>, Vec<i32>, i32) {
    // do stuff with v1 and v2

    // hand back ownership, and the result of our function
    (v1, v2, 42)
}

let v1 = vec![1, 2, 3];
let v2 = vec![1, 2, 3];

let (v1, v2, answer) = foo(v1, v2);
```

Bäh! Der Rückgabetyp, die Return-Zeile und der Funktionsaufruf sind
viel zu kompliziert.

Glücklicherweise bietet uns Rust ein Feature namens "Borrowing"
[engl.: Ausleihen], welches uns hilft dieses Problem zu lösen.
Das ist das Thema des nächsten Abschnitts!
