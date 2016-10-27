# Variablenbindung

Fast jedes nicht-triviale Rust Programm verwendet *Variablenbindungen*.
Sie sehen so aus:

```rust
fn main() {
    let x = 5;
}
```

`fn main() {` in jedes Beispiel zu schreiben ist ein wenig mühsam,
also werden wir es in Zukunft weglassen. Falls du diese Beispiele ausprobierst,
stelle sicher, dass du deinen Code in einer `main()` Methode schreibst
(und nicht wie wir weglässt). Ansonsten bekommst du einen Fehler.

In vielen Sprachen wird das eine *Variable* genannt, aber Rusts
Variablenbindungen haben ein paar Tricks im Ärmel.
Zum Beispiel ist die linke Seite der `let` Anweisung ein ‘[Muster][pattern]’
und nicht einfach nur ein Variablenname. Das bedeutet,
dass wir solche Sachen tun können:

```rust
let (x, y) = (1, 2);
```

Nach dem Ausführen dieser Anweisung ist `x` `1` und `y` wird `2` sein.
Muster sind wirklich mächtig und haben [ihren eigenen Abschnitt][pattern]
im Buch. Wir brauchen diese Features fürs Erste nicht, also behalten wir
uns das hier erstmal im Hinterkopf während wir weiter machen.

[pattern]: Muster.md

Rust ist eine statisch typisierte Sprache, was bedeutet, dass wir unsere
Typen im Voraus angeben müssen und diese zur Kompilierzeit überprüft werden.
Aber warum kompiliert dann unser erstes Beispiel? Nun, Rust kann etwas namens
‘Typinferenz’. Wenn Rust den Typ alleine herausfinden kann, dann müssen
wir den Typ nicht unbedingt angeben.

Wir können den Typ aber angeben, wenn wir wollen.
Ein Typ kommt nach einem Doppelpunkt (`:`):

```rust
let x: i32 = 5;
```

<!--
Fehlende Übersetzung:
"If I asked you to read this out loud to the rest of the class, you’d say “`x`
is a binding with the type `i32` and the value `five`.”"

Ich weis nicht genau wie das zu formulieren ist. ~~~ panicbit 02.10.15
-->

In diesem Fall stellt `x` eine vorzeichenbehaftete 32-bit Ganzzahl dar.
Rust hat viele verschiedene primitive Ganzzahl Typen.
Sie beginnen mit `i` für vorzeichenbehaftete Ganzzahlen und
mit `u` für vorzeichenlose Ganzzahlen. Die möglichen Ganzzahlgrößen sind
8, 16, 32 und 64 Bits.

In zukünftigen Beispielen werden wir manchmal den Typ in einem Kommentar
angeben. Diese Beispiele werden so aussehen:

```rust
fn main() {
    let x = 5; // x: i32
}
```

Beachte die Ähnlichkeit zwischen dieser Anmerkung und der Syntax,
die man mit `let` verwendet. Diese Art von Kommentar ist kein
idiomatisches Rust, aber wir werden sie dennoch gelegentlich verwenden
um klar zu machen, welche Typen Rust ableitet.

Standardmäßig sind Bindungen *immutable* [engl.: unveränderbar].
Dieser Code wird nicht kompilieren:

```rust
let x = 5;
x = 10;
```

Er wird dir diesen Fehler geben:

```text
error: re-assignment of immutable variable `x`
     x = 10;
     ^~~~~~~
```

Wenn du eine Bindung *mutable* [engl.: veränderbar] machen willst,
dann geht das mit `mut`.

```rust
let mut x = 5; // mut x: i32
x = 10;
```

Es gibt verschiedene Gründe, dass Bindungen standardmäßig unveränderbar sind,
aber betrachten wir es einfach mal aus Sicht eines der Hauptziele von Rust:
Sicherheit. Wenn du vergisst `mut` zu schreiben, dann wird der Compiler
das abfangen und dich wissen lassen, dass du etwas veränderst,
was du vielleicht garnicht verändern willst.
Wären Bindungen standardmäßig veränderbar, dann könnte dir
der Compiler das nicht mitteilen.
Wenn die Veränderung doch beabsichtigt ist,
dann ist die Lösung ziemlich einfach: füge `mut` hinzu.

Es gibt noch weitere gute Gründe veränderbaren Zustand so viel wie möglich
zu vermeiden, aber das sprengt den Rahmen dieses Guides. <!-- mmh, Ramen -->
Im Allgemeinen kann man häufig ausdrückliche Veränderungen vermeiden.
Somit ist diese in Rust bevorzugt. Dennoch benötigt man manchmal
Veränderungen, also ist sie nicht verboten.

Also zurück zu Bindungen. Rusts Variablenbindungen haben noch einen weiteren
Aspekt, der von anderen Sprachen abweicht:
Bindungen müssen initialisiert werden, bevor man sie benutzen kann.

Lass uns das ausprobieren.
Ändere deine `src/main.rs` damit sie so aussieht:

```rust
fn main() {
    let x: i32;

    println!("Hallo Welt!");
}
```

Du kannst `cargo build` in der Kommandozeile verwenden, um es zu kompilieren.
Du wirst zwar eine Warnung bekommen, aber das Programm wird trotzdem
"Hallo Welt!" ausgeben:

```text
   Compiling hallo_welt v0.0.1 (file:///home/du/projekte/hallo_welt)
src/main.rs:2:9: 2:10 warning: unused variable: `x`, #[warn(unused_variable)]
   on by default
src/main.rs:2     let x: i32;
                      ^
```

Rust warnt uns jedes mal, wenn eine Bindung nicht verwendet wird, ist
aber ansonsten kein Fehler an sich.
Die Sache ändert sich jedoch, wenn wir versuchen dieses `x` zu verwenden.
Lass uns das mal ausprobieren. Ändere dein Programm wie folgt:

```rust
fn main() {
    let x: i32;

    println!("Der Wert von x ist: {}", x);
}
```

Und, wenn wir versuchen zu kompilieren, bekommen wir diesen Fehler:

```bash
$ cargo build
   Compiling hallo_welt v0.0.1 (file:///home/du/projekte/hallo_welt)
src/main.rs:4:40: 4:41 error: use of possibly uninitialized variable: `x`
src/main.rs:4     println!("Der Wert von x ist: {}", x);
                                                     ^
note: in expansion of format_args!
<std macros>:2:23: 2:77 note: expansion site
<std macros>:1:1: 3:2 note: in expansion of println!
src/main.rs:4:5: 4:42 note: expansion site
error: aborting due to previous error
Could not compile `hallo_welt`.
```

Rust lässt uns keinen uninitialisierten Wert verwenden.
Lass uns als nächstes über die Sachen reden, die wir in `println!`
verwendet haben.

Wenn du die zwei geschweiften Klammern (`{}`, manche nennen sie Schnurrbärte..)
in deinem auszugebenden String einfügst, dann interpretiert Rust sie als
Anweisung an dieser Stelle irgendeinen Wert einzufügen.
Wir fügen ein Komma und dann `x` hinzu, um anzuzeigen, dass wir den Wert von
`x` an dieser Stelle stehen haben wollen. Das Komma wird benutzt, um
mehrere Funktions- oder Makroargumente voneinander zu trennen, falls es mehr
als ein Argument gibt.

Wenn du einfach nur die geschweiften Klammern verwendest, dann versucht
Rust den Wert, basierend auf dessen Typ, auf eine sinnvolle
Art und Weise darzustellen.
Wenn du das Format etwas genauer spezifizieren willst, stehen dir eine
[breite Palette an Optionen zur Verfügung][format].
Fürs erste bleiben wir beim Standard:
Es ist ja nicht so kompliziert eine Ganzzahl auszugeben.
