# Referenzen und Ausleihen

Dieser Guide ist einer von dreien, der Rusts Ownership-System
präsentiert. Dies ist eines von Rusts einzigartigen und verlockenden
Features mit denen Rust-Entwickler vertraut sein sollten.
Durch Ownership [engl.: Besitz] erreicht Rust sein größtes Ziel,
die Speichersicherheit.
Es gibt ein paar verschiedene Konzepte, jedes mit seinem eigenen Kapitel:

* [Besitz][ownership], das Schlüsselkonzept.
* Ausleihen, das was du gerade liest.
* [Lebensdauer][lifetimes], ein fortgeschrittenes Konzept des Ausleihens.

Diese drei Kapitel sind verwandt und deswegen in dieser Reihenfolge zu lesen.
Du wirst alle drei benötigen um das Ownership-System vollständig zu verstehen.

[ownership]: Besitz.html
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
Erfahrenere Rust Entwickler berichten, dass, sobald sie eine Zeit
mit den Regeln des Ownership-Systems gearbeitet haben, sie immer weniger
mit dem *borrow checker* kämpfen müssen. 

Mit diesem Wissen, lass uns über Ausleihen lernen.

# Ausleihen

Am Ende des [Besitz][ownership]-Abschnittes hatten wir eine üble Funktion,
die so aussah:

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

Das ist jedoch kein übliches Rust,
da wir das "Ausleihen" [borrowing] nicht verwenden.
Hier ist unser erster Schritt:

```rust
fn foo(v1: &Vec<i32>, v2: &Vec<i32>) -> i32 {
    // do stuff with v1 and v2

    // return the answer
    42
}

let v1 = vec![1, 2, 3];
let v2 = vec![1, 2, 3];

let answer = foo(&v1, &v2);

// we can use v1 and v2 here!
```

Anstatt der `Vec<i32>` verwenden wir Referenzen als Argument:
`&Vec<i32>`. Und anstatt `v1` und `v2` übergeben wir `&v1` und `&v2`.
Wir nennen den `&T` eine ‘Referenz’ und anstatt die Ressource zu besitzen,
leihen sie sich die Ressource aus.
Eine Bindung, die sich etwas ausleiht, gibt den Speicher der Ressource nicht
frei, wenn sie den Scope verlässt. Das bedeutet, dass wir nach dem Aufruf
`foo()` unsere ursprüngliche Bindung wieder verwenden könnne.

Referenzen sind unveränderbar [immutable], genauso wie Bindungen.
Das bedeutet, dass der Vektor innerhalb von `foo()` nicht verändert werden kann:

```rust
fn foo(v: &Vec<i32>) {
     v.push(5);
}

let v = vec![];

foo(&v);
```

Dies erzeugt einen Fehler:

```text
error: cannot borrow immutable borrowed content `*v` as mutable
v.push(5);
^
```

Eine neue Variable am Ende des Vektors anzufügen verändert den Vektor,
also dürfen wir das nicht machen.

# &mut Referenzen

Es gibt eine zweite Art von Referenz: `&mut T`.
Eine veränderbare Referenz [mutable reference] erlaubt einem
die Ressource, die man ausleiht, zu verändern. Zum Beispiel:

```rust
let mut x = 5;
{
    let y = &mut x;
    *y += 1;
}
println!("{}", x);
```

Dies wird `6` ausgeben. Wir machen `y` zu einer veränderbaren Referenz auf
`x` und inkrementieren dann den Wert auf den `y` zeigt.
Du wirst bemerken, dass `x` ebenfalls als `mut` markiert werden musste.
Wenn es das nicht wäre, dann könnten wir keine veränderbare Referenz darauf
erzeugen.

Du wirst auch feststellen, dass wir ein Stern (`*`) vor dem `y` hinzugefügt
haben: `*y`. Das ist so, weil `y` eine `&mut` Referenz ist.
Du wirst den Stern auch brauchen, wenn du auf den Inhalt einer normalen
Referenz zugreifen möchtest.

Ansonsten sind `&mut` Referenzen genauso wie die gewöhnlichen Referenzen.
Es _gibt_ jedoch einen großen Unterschied zwischen den beiden und wie sie
interagieren. Du kannst bereits an dem zusätzlichen Scope, den wir mit
`{` und `}` eingeführt haben, feststellen, dass etwas komisch ist.

Wenn wir sie entfernen, dann erhalten wir einen Fehler:

```text
error: cannot borrow `x` as immutable because it is also borrowed as mutable
    println!("{}", x);
                   ^
note: previous borrow of `x` occurs here; the mutable borrow prevents
subsequent moves, borrows, or modification of `x` until the borrow ends
        let y = &mut x;
                     ^
note: previous borrow ends here
fn main() {

}
^
```

Wie es sich herausstellt gibt es Regeln.

# Die Regeln

Hier sind die Regeln die beim Ausleihen in Rust gelten:

Erstens darf etwas nicht länger ausgeliehen werden als das ausgeliehene
existiert. Zweitens darfst du entweder die eine oder die andere Art von
Referenz haben, aber nicht beide zur gleichen Zeit:

* eine oder mehr Referenzen (`&T`) auf eine Ressource,
* genau eine veränderbare Referenz (`&mut T`).

Du wirst feststellen, das dies sehr ähnlich (wenn auch nicht ganz exakt)
der Definition eines *data race* entspricht:

> There is a ‘data race’ when two or more pointers access the same memory
> location at the same time, where at least one of them is writing, and the
> operations are not synchronized.

> Es gibt ein ‘data race’, wenn zwei oder mehr Zeiger zur selben Zeit
> die gleiche Speicherstelle zugreifen, wobei mindestens ein Zugriff
> schreibend erfolgt und die Operation nicht synchronisiert ist.

Referenzen kann man so viele haben wie man möchte,
da keine von ihnen Schreibzugriffe erlaubt.
Wenn man schreibend zugreift, dann benötigt es zwei oder
mehr Zeiger auf die gleiche Speicherstelle um einen *data race* hervorzurufen,
aber Rust erlaubt es uns zu einem gewissen Zeitpunkt nur eine `&mut` Referenz
zu haben.
So verhindert Rust *data races* zur Kompilierzeit:
Wir erhalten Fehler, wenn wir die Regeln brechen.

## In Scopes denken

Hier ist der Code:

```rust
let mut x = 5;
let y = &mut x;

*y += 1;

println!("{}", x);
```

Dieser Code gibt uns diesen Fehler:

```text
error: cannot borrow `x` as immutable because it is also borrowed as mutable
    println!("{}", x);
                   ^
```

Das kommt weil wir die Regeln verletzt haben:
Wir haben ein `&mut T` welches auf `x` zeigt, weswegen wir
keine  `&T`s erzeugen dürfen. Entweder nur das eine oder nur das andere.
Die `note:` Meldung gibt uns einen Hinweis
wie man über das Problem denken kann:

```text
note: previous borrow ends here
fn main() {

}
^
```

In anderen Worten bleibt das *mutable borrow* bis zum Ende unseres
Beispiels bestehen. Was wir wollen ist, dass das *mutable borrow*
endet _bevor_ wir versuchen `println!` aufzurufen und damit eine
ein *immutable borrow* vornehmen.
In Rust ist ein *borrow* an den Scope gebunden für den es gültig ist.
Und unser Scope sieht so aus:


```rust
let mut x = 5;

let y = &mut x;    // -+ &mut borrow of x starts here
                   //  |
*y += 1;           //  |
                   //  |
println!("{}", x); // -+ - try to borrow x here
                   // -+ &mut borrow of x ends here
```

Die Scopes stehen im Konflikt: Wir können kein `&x` erzeugen, während `y`
im Scope ist.
Wenn wir also geschweifte Klammern hinzufügen:

```rust
let mut x = 5;

{                   
    let y = &mut x; // -+ &mut borrow starts here
    *y += 1;        //  |
}                   // -+ ... and ends here

println!("{}", x);  // <- try to borrow x here
```

Dann gibt es kein Problem. Unser *mutable borrow* verlässt den Scope bevor
wir ein *immutable borrow* erzeugen.
Der Scope ist der Schlüssel um zu sehen wie lange ein *borrow* anhält.

## Probleme die das Ausleihen verhindert

Warum haben wir diese einschränkenden Regeln?
Nun, wie wir schon angemerkt haben, verhindern sie *data rces*.
Welche Arten von Problemen werden durch *data races* erzeugt?
Hier sind ein paar.

### Iterator invalidation

Ein Beispiel ist ‘iterator invalidation’,
welche stattfindet, wenn man versucht eine Collection
zu verändern über die man iteriert. Rusts Borrow Checker verhindert,
dass das passiert:

```rust
let mut v = vec![1, 2, 3];

for i in &v {
    println!("{}", i);
}
```

Dies gibt eins bis drei aus. Während wir durch den Vektor iterieren
erhalten wir nur Referenzen auf die Elemente. Und `v` ist selber
nur unveränderbar ausgeliehen, was bedeutet, dass wir es nicht
verändern können, während wir darüber iterieren:

```rust
let mut v = vec![1, 2, 3];

for i in &v {
    println!("{}", i);
    v.push(34);
}
```

Hier ist der Fehler:

```text
error: cannot borrow `v` as mutable because it is also borrowed as immutable
    v.push(34);
    ^
note: previous borrow of `v` occurs here; the immutable borrow prevents
subsequent moves or mutable borrows of `v` until the borrow ends
for i in &v {
          ^
note: previous borrow ends here
for i in &v {
    println!(“{}”, i);
    v.push(34);
}
^
```

Wir können `v` nicht verändern, da es von der Schleife ausgeliehen ist.

### Benutzung nach einem `free`

Referenzen dürfen nicht länger leben als die Ressource, die sie referenzieren.
Rust wird die Scopes deiner Referenzen überprüfen um sicherzustellen, dass
das gilt.

Wenn Rust diese Eigenschaft nicht prüfen würde, dann könnten wir
versehentlich eine ungültige Referenz verwenden.
Zum Beispiel:

```rust
let y: &i32;
{ 
    let x = 5;
    y = &x;
}

println!("{}", y);
```

Wir erhalten diesen Fehler:

```text
error: `x` does not live long enough
    y = &x;
         ^
note: reference must be valid for the block suffix following statement 0 at
2:16...
let y: &i32;
{ 
    let x = 5;
    y = &x;
}

note: ...but borrowed value is only valid for the block suffix following
statement 0 at 4:18
    let x = 5;
    y = &x;
}
```

In anderen Worten ist `y` nur für das Scope gültig, in dem `x` existiert.
Sobald `x` weggeht, ist es ungültig darauf zu verweisen.
Deswegen sagt der Fehler dass das *borrow* nicht lange genug lebt
[`does not live long enough`], da es nicht für die richtige Länge gültig ist.

Dasselbe Problem taucht auf, wenn eine Referenz vor der referenzierten Variable
deklariert wird:

```rust
let y: &i32;
let x = 5;
y = &x;

println!("{}", y);
```

Wir erhalten diesen Fehler:

```text
error: `x` does not live long enough
y = &x;
     ^
note: reference must be valid for the block suffix following statement 0 at
2:16...
    let y: &i32;
    let x = 5;
    y = &x;
    
    println!("{}", y);
}

note: ...but borrowed value is only valid for the block suffix following
statement 1 at 3:14
    let x = 5;
    y = &x;
    
    println!("{}", y);
}
```

In dem oberen Beispiel wird `y` vor `x` deklariert, was bedeutet, dass `y`
länger lebt als `x`, was nicht erlaubt ist.
