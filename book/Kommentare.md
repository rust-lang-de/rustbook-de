# Kommentare

Nun, da wir Funktionen kennen, ist es ein guter Zeitpunkt über Kommentare
zu lernen. Kommentare sind Notizen, die man anderen Programmierern hinterlässt
um Dinge über deinen Code zu erklären.
Der Compiler ignoriert sie größtenteils.

Rust hat zwei wesentliche Arten von Kommentaren:
*Zeilenkommentare* [*line comments*] und *Doku-Kommentare* [*doc comments*].

Hier ein Beispiel mit 4 Zeilenkommentaren:

```rust
// Line comments are anything after ‘//’ and extend to the end of the line.

let x = 5; // this is also a line comment.

// If you have a long explanation for something, you can put line comments next
// to each other. Put a space between the // and your comment so that it’s
// more readable.
```

Die andere Art von Kommentar ist ein Doku-Kommentar.
Doku-Kommentare werden mit `///` anstatt `//` eingeleitet und
unterstützen darin das Markdown Format:

<pre><code class="lang-rust">
/// Adds one to the number given.
///
/// # Examples
///
/// ```
/// let five = 5;
///
/// assert_eq!(6, add_one(5));
/// # fn add_one(x: i32) -> i32 {
/// #     x + 1
/// # }
/// ```
fn add_one(x: i32) -> i32 {
    x + 1
}
</code></pre>

Es gibt noch eine weitere Kommentarform, nämlich `//!`,
um Dinge zu Dokumentieren in denen diese Kommentare enthalten sind
(z.B. in Crates, Modulen oder Funktionen) ansttat das zu kommentieren,
was auf ihnen folgt.
Üblicherweise wird diese Form von Kommentar am Anfang einer
Crate (lib.rs) oder eines Moduls (mod.rs) verwendet:

```rust
//! # The Rust Standard Library
//!
//! The Rust Standard Library provides the essential runtime
//! functionality for building portable Rust software.
```

Wenn du Doku-Kommentare schreibst, dann ist es sehr hilfreich, wenn du
Beispiele angibst.
Du wirst feststellen, dass wir hier ein neues Makro verwendet haben:
`assert_eq!`. Dies vergleicht zwei Werte und `panic!`t wenn sie nicht
gleich sind. Das ist sehr hilfreich in der Dokumentation.
Es gibt ein weiteres Makro, nämlich `assert!`, welches `panic!`t,
wenn der übergebene Wert `false` ist.

Du kannst das [`rustdoc`][documentation] Tool verwenden um eine HTML
Dokumentation aus diesen Doku-Kommentaren zu erstellen und außerdem
den Beispielcode als Tests laufen lassen!

[documentation]: Dokumentation.md
