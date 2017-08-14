# if

Rusts `if` ist nicht besonders kompliziert, aber es ähnelt viel mehr dem
`if` einer dynamisch typisierten Sprache, als dem einer
eher traditionellen Sprachen.

Lass uns also darüber sprechen, um sicherzustellen, dass du die Feinheiten
verstehst.

`if` ist eine spezielle Form eines allgemeineren Konzeptes, dem Zweig [branch].
Der Name stammt von dem Zweig im Baum: Ein Entscheidungspunkt, an welchem
verschiedene Wege gegangen werden können, je nachdem wie du dich entscheidest.

Im Falle von `if` gibt es eine Entscheidung mit zwei möglichen Pfaden:

```rust
let x = 5;

if x == 5 {
    println!("x is five!");
}
```

Wenn wir den Wert von `x` zu etwas anderem ändern würden, dann würde die
"x is five!" Zeile nicht ausgegeben werden. Genauer gesagt, wenn der Ausdruck
nach dem `if` zu `true` ausgewertet wird, dann wird der
nachfolgende Block ausgeführt. Wird er zu `false` ausgewertet,
dann wird der Block *nicht* ausgeführt.

Wenn du möchtest, dass in dem `false` Fall etwas passieren soll,
dann benutze `else`:

```rust
let x = 5;

if x == 5 {
    println!("x is five!");
} else {
    println!("x is not five :(");
}
```

Wenn es mehr als einen Fall gibt, benutze `else if`:

```rust
let x = 5;

if x == 5 {
    println!("x is five!");
} else if x == 6 {
    println!("x is six!");
} else {
    println!("x is not five or six :(");
}
```

Das ist alles ziemlich standardgemäß. Man kann aber auch sowas machen:

```rust
let x = 5;

let y = if x == 5 {
    10
} else {
    15
}; // y: i32
```

Was wir auch so schreiben könnten (und wohl auch lieber sollten):

```rust
let x = 5;

let y = if x == 5 { 10 } else { 15 }; // y: i32
```

Dies funktioniert, weil `if` ein Ausdruck ist. Der Wert den der `if` Ausdruck
zurückgibt ist der letzte des jeweiligen Zweiges.
Ein `if` ohne `else` gibt immer ein `()` zurück.
