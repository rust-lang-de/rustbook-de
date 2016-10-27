# Veränderbarkeit


<!-- Mutability, the ability to change something, works a bit differently in Rust
than in other languages. The first aspect of mutability is its non-default
status: -->
Veränderbarkeit, die Möglichkeit etwas zu ändern, funktioniert in Rust ein wenig anders als in anderen Programmiersprachen.
Standardmäßig sind Variablen nicht veränderbar: 

<!-- XXX rust,ignore wird bei meinem gitbook nicht erkannt und Syntaxhighlighting ist aus -->
```rust,ignore
let x = 5;
x = 6; // Fehler!
```

<!-- We can introduce mutability with the `mut` keyword: -->
Wir können Veränderbarkeit mit dem Schlüsselwort `mut`, die Kurzform für "mutable" (englisch: veränderbar), einführen:

```rust
let mut x = 5;

x = 6; // Kein Problem!
```

<!-- This is a mutable [variable binding][vb]. When a binding is mutable, it means
you’re allowed to change what the binding points to. So in the above example,
it’s not so much that the value at `x` is changing, but that the binding
changed from one `i32` to another. -->
Dies ist eine veränderbare [Variablenbindung][v].
Wenn eine Bindung veränderbar ist, bedeutet es,
 dass du ändern kannst woran die Variablenbindung gebunden ist.
In dem oberen Beispiel ist es nicht so, dass sich der Wert in `x` ändert,
 sondern dass sich die Bindung von `x` von einem `i32` zu einem Anderen geändert hat.

[vb]: Variablenbindung.html

<!-- You can also create a [reference][ref] to it, using `&x`, but if you want to use the reference to change it, you will need a mutable reference: -->
Du kannst auch eine [Referenz][ref] zu einer Variablenbindung mittels `&x` erstellen.
Wenn du aber die Referenz benutzen möchtest um die Variablenbindung zu ändern,
 benötigst du eine *veränderbare* Referenz: <!-- *Hervorhebung* hinzugefügt -->

```rust
let mut x = 5;
let y = &mut x;
```

[ref]: Referenzen_Und_Ausleihen.html

<!-- `y` is an immutable binding to a mutable reference,
  which means that you can’t bind 'y' to something else (`y = &mut z`),
  but `y` can be used to bind `x` to something else (`*y = 5`). A subtle distinction. -->
`y` ist eine unveränderbare Variablenbindung zu einer veränderbaren Referenz.
Das bedeutet, dass du `y` nicht zu etwas anderem binden kannst, z.B. `y = &mut z`.
Du kannst aber `y` benutzen um `x` an etwas anders zu binden, z.B. durch `*y = 5`.
Ein subtiler Unterschied.

<!-- Of course, if you need both: -->
Wenn du beides brauchst:

```rust
let mut x = 5;
let mut y = &mut x;
```

<!-- Now `y` can be bound to another value, and the value it’s referencing can be
changed. -->
Jetzt kann `y` an einen anderen Wert gebunden werden und der Wert der referenziert wird,
 kann geändert werden.

<!-- It’s important to note that `mut` is part of a [pattern][pattern], so you
can do things like this: -->
Es ist wichtig hervorzuheben, dass `mut` Teil eines [`Musters`][pattern] ist,
 so dass du zu soetwas binden kannst:

```rust
let (mut x, y) = (5, 6);

fn foo(mut x: i32) {
}
```
<!-- hier war ein Fehler in dem Book 1.3.0 durch ein # im Code -->

<!-- Note that here, the `x` is mutable, but not the `y`. -->
In dem Beispiel ist `x` veränderbar aber nicht `y`.

[pattern]: Muster.html

<!-- # Interior vs. Exterior Mutability -->
# Innere und äußere Veränderbarkeit

<!-- However, when we say something is ‘immutable’ in Rust, that doesn’t mean that
it’s not able to be changed: we are referring to its ‘exterior mutability’ that
in this case is immutable. Consider, for example, [`Arc<T>`][arc]: -->
Doch wenn wir sagen, etwas ist "unveränderlich" in Rust,
 dann bedeutet das nicht, dass es sich nicht ändern kann:
 wir meinen damit, dass dessen "äußere Veränderbarkeit" unveränderlich ist.
Betrachte als Beispiel [`Arc<T>`][arc]:

```rust
use std::sync::Arc;

let x = Arc::new(5);
let y = x.clone();
```

[arc]: ../std/sync/struct.Arc.html

<!-- When we call `clone()`, the `Arc<T>` needs to update the reference count. Yet
we’ve not used any `mut`s here, `x` is an immutable binding, and we didn’t take
`&mut 5` or anything. So what gives? -->
Wenn wir `clone()` aufrufen, muss das `Arc<T>` seinen Referenzzähler aktualisieren.
Jedoch haben wir kein `mut` verwendet,
 `x` ist eine unveränderliche Variablenbindung,
 und wir haben nicht `&mut 5` oder soetwas benutzt.
Nun, was passiert hier?

<!-- To understand this, we have to go back to the core of Rust’s guiding
philosophy, memory safety, and the mechanism by which Rust guarantees it, the
[ownership][ownership] system, and more specifically, [borrowing][borrowing]: -->
Um das zu verstehen, müssen wir zurück zu den Kernprinzipien von Rust,
 Speichersicherheit und der Mechanismus, mit dem dies garantiert wird,
 [Besitz][ownership] und [Ausleihe][borrowing].

<!--
> You may have one or the other of these two kinds of borrows, but not both at
> the same time:
>
> * one or more references (`&T`) to a resource,
> * exactly one mutable reference (`&mut T`).
-->
> Du hast entweder die eine oder die andere Art Ausleihe, aber nicht beide gleichzeitig:
>
> * eine oder mehrere Referenzen (`&T`) zu einer Resource,
> * exakt eine veränderbare Referenz (`&mut T`).

[ownership]: Besitz.html
[borrowing]: Referenzen_Und_Ausleihen.html#Ausleihen

<!-- So, that’s the real definition of ‘immutability’: is this safe to have two
pointers to? In `Arc<T>`’s case, yes: the mutation is entirely contained inside
the structure itself. It’s not user facing. For this reason, it hands out `&T`
with `clone()`. If it handed out `&mut T`s, though, that would be a problem. -->
Nun, dies ist die wirkliche Definition von "Unveränderbarkeit".
Ist es sicher zwei Referenzen zu Etwas zu haben?
Im Falle von `Arc<T>` ist es sicher.
Die Veränderung ist gekapselt im der Struktur selbst.
Sie ist nicht nach Außen sichtbar.
Aus diesem Grund wird `&T` durch `clone()` zurück gegeben.
Wenn es `&mut T` zurück geben würde, wäre das ein Problem.
<!-- XXX der englische Text selbst ist mit
     '...: is this safe to have two pointers to? ... yes: ...`
     sehr holprig und unklar was gemeint ist.
     Ich habe das mal angepasst. -->

<!-- Other types, like the ones in the [`std::cell`][stdcell] module, have the
opposite: interior mutability. For example: -->
Andere Typen, wie die in dem [`std::cell`][stdcell] Modul,
 haben hingegen innere Veränderbarkeit:

```rust
use std::cell::RefCell;

let x = RefCell::new(42);

let y = x.borrow_mut();
```

[stdcell]: ../std/cell/index.html

<!-- RefCell hands out `&mut` references to what’s inside of it with the
`borrow_mut()` method. Isn’t that dangerous? What if we do: -->
`RefCell` gibt über die Methode `borrow_mut()`
 eine `&mut` Referenz zu der inneren Bindung <!-- XXX Bindung oder Wert? -->
 zurück.
Ist das nicht gefährlich? Was ist, wenn wir folgendes tun:

```rust,ignore
use std::cell::RefCell;

let x = RefCell::new(42);

let y = x.borrow_mut();
let z = x.borrow_mut();
# (y, z);
```
<!-- XXX warum ist hier ein # (y, z); ? Im book ist diese Zeile nicht mit einkompiliert. -->

<!-- This will in fact panic, at runtime. This is what `RefCell` does: it enforces
Rust’s borrowing rules at runtime, and `panic!`s if they’re violated. This
allows us to get around another aspect of Rust’s mutability rules. Let’s talk
about it first. -->
Dies löst durchaus eine `panic` zur Laufzeit aus.
Das ist, was `RefCell` macht:
 es setzt Rusts Regeln zum Ausleihen zur Laufzeit durch
 und `panic!`t wenn sie gebrochen werden.
Das erlaubt es uns mit einem weiteren Aspekt von Rusts Regeln zur Veränderbarkeit
 umzuhehen.
Lass uns aber ersteinmal über diesen Aspekt sprechen.

<!-- ## Field-level mutability -->
## Veränderbarkeit bei Feldern

<!-- Mutability is a property of either a borrow (`&mut`) or a binding (`let mut`).
This means that, for example, you cannot have a [`struct`][struct] with
some fields mutable and some immutable: -->
Veränderbarkeit ist eine Eigenschaft einer Ausleihe (`&mut`)
 oder einer Variablenbindung (`let mut`).
Das bedeutet zum Beispiel, dass du kein [Struct][struct]
 mit einigen veränderbaren und einigen unveränderbaren Feldern haben kannst:

```rust,ignore
struct Point {
      x: i32,
      mut y: i32, // das geht nicht
}
```

<!-- The mutability of a struct is in its binding: -->
Die Veränderbarkeit eines Struct ist in ihrer Bindung:

```rust,ignore
struct Point {
      x: i32,
      y: i32,
}

let mut a = Point { x: 5, y: 6 };

a.x = 10;

let b = Point { x: 5, y: 6};

b.x = 10; // error: cannot assign to immutable field `b.x`
```

[struct]: Structs.html

<!-- However, by using [`Cell<T>`][cell], you can emulate field-level mutability: -->
Jedoch kann man mit Hilfe von [`Cell<T>`][cell] Veränderbarkeit pro Feld nachbilden:

```rust
use std::cell::Cell;

struct Point {
      x: i32,
      y: Cell<i32>,
}

let point = Point { x: 5, y: Cell::new(6) };

point.y.set(7);

println!("y: {:?}", point.y);
```

[cell]: ../std/cell/struct.Cell.html

<!-- This will print `y: Cell { value: 7 }`. We’ve successfully updated `y`. -->
Dies gibt `y: Cell { value: 7 }` aus.
Wir haben `y` erfolgreich verändert.

