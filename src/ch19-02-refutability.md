## Abweisbarkeit: Falls ein Muster (pattern) mal nicht passt

Es gibt zwei Arten von Mustern: Abweisbare (refutable) und unabweisbare
(irrefutable). Muster, die für jeden möglichen übergebenen Wert passen, sind
_unabweisbar_. Ein Beispiel wäre `x` in der Anweisung `let x = 5;` weil `x` auf
alles passt und daher nicht fehlschlagen kann. Muster, die für irgendeinen
möglichen Wert nicht passen können, sind _abweisbar_. Ein Beispiel wäre
`Some(x)` im Ausdruck `if let Some(x) = a_value`, denn wenn der Wert in der
Variablen `a_value` eher `None` als `Some` ist, wird das Muster `Some(x)` nicht
passen. 

Funktionsparameter, `let`-Anweisungen und `for`-Schleifen können nur
unabweisbare Muster akzeptieren, da das Programm nichts Sinnvolles tun kann,
wenn die Werte nicht passen. Die Ausdrücke `if let` und `while let` sowie die
Anweisung `let...else` akzeptieren abweisbare und unabweisbare Muster, aber der
Compiler warnt vor unabweisbaren Mustern, weil sie per Definition dazu gedacht
sind, mit einem möglichen Fehlerfall umzugehen: Die Funktionalität einer
Bedingung besteht in ihrer Fähigkeit, sich abhängig von Erfolg oder Fehlerfall
unterschiedlich zu verhalten.

Im Allgemeinen solltest du dich nicht um die Unterscheidung zwischen
abweisbaren und unabweisbaren Mustern kümmern müssen; du musst jedoch mit dem
Konzept der Abweisbarkeit vertraut sein, damit du reagieren kannst, wenn du es
in einer Fehlermeldung siehst. In diesen Fällen musst du entweder das Muster
oder das Konstrukt, in dem du das Muster verwendest, ändern, je nach dem
beabsichtigten Verhalten des Codes.

Betrachten wir ein Beispiel dafür, was passiert, wenn wir versuchen, ein
abweisbares Muster zu verwenden, wo Rust ein unabweisbares Muster erfordert und
umgekehrt. Codeblock 19-8 zeigt eine `let`-Anweisung, allerdings haben wir für
das Muster `Some(x)` angegeben, ein abweisbares Muster. Wie zu erwarten ist,
lässt sich dieser Code nicht kompilieren.

```rust,does_not_compile
# fn main() {
#     let some_option_value: Option<i32> = None;
    let Some(x) = some_option_value;
# }
```

<span class="caption">Codeblock 19-8: Versuch, ein abweisbares Muster mit `let`
zu verwenden</span>

Wenn `some_option_value` den Wert `None` hätte, würde er nicht zum Muster
`Some(x)` passen, was bedeutet, dass das Muster abweisbar ist. Die
`let`-Anweisung kann jedoch nur ein unabweisbares Muster akzeptieren, weil es
nichts Gültiges gibt, was der Code mit einem `None`-Wert tun kann. Zur
Kompilierzeit wird sich Rust beschweren, dass wir versucht haben, ein
abweisbares Muster zu verwenden, wo ein unabweisbares Muster erforderlich ist:

```console
$ cargo run
   Compiling patterns v0.1.0 (file:///projects/patterns)
error[E0005]: refutable pattern in local binding
 --> src/main.rs:3:9
  |
3 |     let Some(x) = some_option_value;
  |         ^^^^^^^ pattern `None` not covered
  |
  = note: `let` bindings require an "irrefutable pattern", like a `struct` or an `enum` with only one variant
  = note: for more information, visit https://doc.rust-lang.org/book/ch19-02-refutability.html
  = note: the matched value is of type `Option<i32>`
help: you might want to use `let else` to handle the variant that isn't matched
  |
3 |     let Some(x) = some_option_value else { todo!() };
  |                                     ++++++++++++++++

For more information about this error, try `rustc --explain E0005`.
error: could not compile `patterns` (bin "patterns") due to 1 previous error
```

Da wir nicht jeden gültigen Wert mit dem Muster `Some(x)` abgedeckt haben (und
auch nicht abdecken konnten!), erzeugt Rust zu Recht einen Kompilierfehler.

Wenn wir ein abweisbares Muster haben, obwohl ein unabweisbares Muster benötigt
wird, können wir den Code, der das Muster verwendet, korrigieren: Anstatt `let`
zu verwenden, können wir `let...else` verwenden. Wenn das Muster dann nicht
passt, führt das Programm einfach den Code in den geschweiften Klammern aus.
Codeblock 19-9 zeigt, wie der Code in Codeblock 19-8 zu korrigieren ist.

```rust
# fn main() {
#     let some_option_value: Option<i32> = None;
    let Some(x) = some_option_value else {
        return;
    };
# }
```

<span class="caption">Codeblock 19-9: Verwenden von `let...else` und eines
Blocks mit abweisbaren Mustern anstelle von `let`</span>

Wir haben den Code repariert! Dieser Code ist vollkommen gültig, auch wenn wir
damit kein unabweisbares Muster verwenden können, ohne eine Warnung zu
erhalten. Wenn wir in `let...else` ein unabweisbares Muster angeben, das immer
passt, z.B. `x` wie in Codeblock 19-10 gezeigt, gibt der Compiler eine Warnung
aus.

```rust
# fn main() {
    let x = 5 else {
        return;
    };
# }
```

<span class="caption">Codeblock 19-10: Der Versuch, ein unabweisbares Muster
mit `let...else` zu verwenden</span>

Rust beklagt, dass es keinen Sinn macht, `let...else` mit einem unabweisbaren
Muster zu verwenden:

```console
$ cargo run
   Compiling patterns v0.1.0 (file:///projects/patterns)
warning: irrefutable `let...else` pattern
 --> src/main.rs:2:5
  |
2 |     let x = 5 else {
  |     ^^^^^^^^^
  |
  = note: this pattern will always match, so the `else` clause is useless
  = help: consider removing the `else` clause
  = note: `#[warn(irrefutable_let_patterns)]` on by default

warning: `patterns` (bin "patterns") generated 1 warning
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.39s
     Running `target/debug/patterns`
5
```

Aus diesem Grund müssen `match`-Zweige abweisbare Muster verwenden, mit
Ausnahme des letzten Zweigs, bei dem alle verbleibenden Werte mit einem
unabweisbaren Muster übereinstimmen sollten. Rust erlaubt es uns, ein
unabweisbares Muster in einem `match` mit nur einem Zweig zu verwenden, aber
diese Syntax ist nicht besonders nützlich und könnte durch eine einfachere
`let`-Anweisung ersetzt werden.

Da du nun weißt, wo du Muster verwenden kannst und den Unterschied zwischen
abweisbaren und unabweisbaren Mustern kennst, lass uns alle Syntaxen behandeln,
die wir zum Erstellen von Mustern verwenden können.
