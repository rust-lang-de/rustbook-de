## Kommentare

Alle Programmierer bemühen sich, ihren Code leicht verständlich zu machen, aber
manchmal sind zusätzliche Erklärungen angebracht. In solchen Fällen versehen
Entwickler den Quellcode mit *Kommentaren*, welche der Kompilierer ignoriert und
für andere Entwickler nützlich sein kann.

Dies ist ein einfacher Kommentar:

```rust
// hallo welt
```

In Rust beginnt ein gewöhnlicher Kommentar mit zwei Schrägstrichen; der
Kommentar reicht dann bis zum Ende der Zeile. Für Kommentare, die über Zeilen
hinausgehen, musst du an jedem Zeilenanfang `//` anfügen:

```rust
// Hier passiert etwas kompliziertes, so komplex dass wir
// mehrere Zeilen an Kommentaren brauchen! Puh! Hoffentlich erklärt
// dieser Kommentar, was hier passiert.
```

Kommentare können auch am Ende einer Zeile, nach Code, stehen:

```rust
fn main() {
    let lucky_number = 7; // I'm feeling lucky today
}
```

Gängiger ist jedoch die Schreibweise mit dem Kommentar über der Zeile an Code,
die er beschreibt:

```rust
fn main() {
    // I'm feeling lucky today
    let lucky_number = 7;
}
```

Rust hat auch Dokumentations-Kommentare, welche im "Kisten (crate) auf crates.io
veröffentlichen" Bereich in Kapitel 14 erklärt werden.