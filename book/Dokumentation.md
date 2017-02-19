# Dokumentation

Dokumentation ist ein wichtiger Teil eines jeden Software Projekts.
In Rust ist sie ein Sprachbestandteil.
Reden wir doch mal über die Tools die uns Rust zur Verfügung stellt um unser Projekt zu dokumentieren.

## Über `rustdoc`

Das Rust Paket beinhaltet ein Tool namens `rustdoc`, welches Dokumentation generiert.
`rustdoc` wird von Cargo für `cargo doc` verwendet.

Dokumentation kann auf zwei Arten erzeugt werden: aus dem Quelltext und aus Markdown Dateien.


## Dokumentation von Quelltext

Die primäre Methode ein Rust Projekt zu dokumentieren ist den Quelltext zu annotieren.
Dafür gibt es eine eigene Art von Kommentaren:

<pre><code class="lang-rust">
/// Constructs a new `Rc<T>`.
///
/// # Examples
///
/// ```
/// use std::rc::Rc;
///
/// let five = Rc::new(5);
/// ```
pub fn new(value: T) -> Rc<T> {
    // hier die implementation
}
</code></pre>

Dieser Code generiert Dokumentation die [wie diese aussieht](https://doc.rust-lang.org/nightly/std/rc/struct.Rc.html#method.new).
Nur halt ohne die Implementierung.

Das erste was uns an diesen Annotationen auffällt ist dass es mit `///` anstatt `//` anfängt.
Drei Slashes deuten einen Dokumentationskommentar an.

Dokumentation wird in Markdown geschrieben.

Rust kann diese Kommentare unterscheiden und daraus Dokumentation erzeugen.
Das ist unter anderem wichtig wenn man Dinge wie `enum`s dokumentiert:


```rust
/// The `Option` type. See [the module level documentation](index.html) for more.
enum Option<T> {
    /// No value
    None,
    /// Some value `T`
    Some(T),
}
```

Das hier oben funktioniert, das folgende leider nicht:

```rust
/// The `Option` type. See [the module level documentation](index.html) for more.
enum Option<T> {
    None, /// No value
    Some(T), /// Some value `T`
}
```

Dafür gibt es sogar eine Fehlermeldung:

```text
hello.rs:4:1: 4:2 error: expected ident, found `}`
hello.rs:4 }
           ^
```

Dieser [Fehler](https://github.com/rust-lang/rust/issues/22547) ist leider richtig so denn Dokumentationskommentare beziehen sich immer auf was direkt auf sie folgt.

### Dokumentation Schreiben

Gehen wir also mal auf die einzelnen Teile diese Dokumentation ein:


```rust
/// Constructs a new `Rc<T>`.
```

Im Grunde gelten hier die gleichen Regeln wie für git commit Nachrichten.
Die erste Zeile der Dokumentation sollte eine kurze Zusammenfassung dessen sein, worauf sie sich bezieht. Nur ein Satz. Nur Grundsätzliches. Nicht in die Tiefe.

```rust
///
/// Other details about constructing `Rc<T>`s, maybe describing complicated
/// semantics, maybe additional options, all kinds of stuff.
///
```

Wenn wir noch mehr aussagen möchten, können wir einen weiteren Absatz zur Beschreibung hinzufügen.

#### Spezielle Überschriften

Als nächstes ein paar spezielle Überschriften.
Diese beginnen in Markdown immer mit einem `#`.
Es gibt vier sehr gebräuchliche Überschriften, diese sind allerdings reine Konvention, sie haben keine eigene Syntax.

```rust
/// # Panics
# fn foo() {}
```

`panic` indiziert in Rust vornehmlich, dass ein nicht behebbarer Fehler aufgetreten ist,
meistens durch Programmierfehler.
In diesen Fällen soll der aktuelle Thread "kontrolliert abstürzen".
Wenn das in deinem Programm so vorgesehen ist, solltest du in der Dokumentation explizit darauf hinweisen.

```rust
/// # Failures
# fn foo() {}
```

Wenn deine Funktion/Methode ein `Result<T, E>` zurückgibt,
dann beschreibe die Bedingungen unter denen es einen `Err(E)` zurückgibt.
Das ist nicht ganz so wichtig wie eine Panik, da Failures Teil des Typsystems sind, aber es ist dennoch wichtig.

```rust
/// # Safety
# fn foo() {}
```

Wenn die Funktion `unsafe` verwendet, dann sollte ebenfalls explizit darauf hingewiesen werden, da hier eventuell Probleme auftreten können vor denen Rust anderweitig gefeit ist.


<pre><code class="lang-rust">
/// # Examples
///
/// ```
/// use std::rc::Rc;
///
/// let five = Rc::new(5);
/// ```
</code></pre>


Viertens, `Examples`.
Wenn du nur ein bis zwei Beispiele zu deiner Dokumentation hinzufügst erleichterst du anderen den Umgang mit deiner Bibliothek erheblich.
Dokumentation kann noch so detailiert sein, bevor man wissen möchte wie etwas funktioniert möchte man wissen wie man es benutzt.
Bevor du dich fragst wie das Mahlwerk deiner neue Kaffeemaschine funktioniert, interessiert dich doch eher, wie du damit Kaffee kochst oder?

<pre><code class="lang-rust">
/// # Examples
///
/// Einfache `&str` Patterns:
///
/// ```
/// let v: Vec<&str> = "Mary had a little lamb".split(' ').collect();
/// assert_eq!(v, vec!["Mary", "had", "a", "little", "lamb"]);
/// ```
///
/// Kompliziertere Patterns mit einem Lambda:
///
/// ```
/// let v: Vec<&str> = "abc1def2ghi".split(|c: char| c.is_numeric()).collect();
/// assert_eq!(v, vec!["abc", "def", "ghi"]);
/// ```
</code></pre>

Reden wir einmal etwas detailierter über Codeblöcke.

#### Codeblock Annotationen

Um Quelltext in Kommentaren zu schreiben benutzt man in Markdown drei Accent Graves.

<pre><code class="lang-rust">
/// ```
/// println!("Hello, world");
/// ```
# fn foo() {}
</code></pre>

Dabei wir wird in der ersten Zeile normalerweise die Programmiersprache für den Highlighter angegeben.
Bei uns ist Rust Standard, wenn du etwas anderes angeben willst dann sieht das zum Beispiel so aus:


<pre><code class="lang-rust">
/// ```c
/// printf("Hello, world\n");
/// ```
# fn foo() {}
</code></pre>

Wenn du Plaintext ausgeben willst nimm ` ```text `

Es ist wichtig die richtige Codeblockannotation zu wählen, da `rustdoc` diese nicht nur für Highlighting verwendet.
Denn die Beispiele in deinem Crate können tatsächlich getestet werden.
Somit wird sichergestellt, dass sie nicht veraltet sind.
Wenn du allerdings C Code nicht mit ` ```c ` annotierst, denkt `rustdoc` es muss ihn als Rust kompilieren und meldet dann Fehler, weil das natürlich nicht geht.

## Dokumentation als Tests

Reden wir einmal über unsere Beispiele:


<pre><code class="lang-rust">
/// ```
/// println!("Hello, world");
/// ```
# fn foo() {}
</code></pre>

Dir ist vielleicht aufgefallen, dass du kein `fn main()` gebraucht hast.
`rustdoc` generiert hier automatisch einen Wrapper dafür.
Zum Beispiel:


<pre><code class="lang-rust">
/// ```
/// use std::rc::Rc;
///
/// let five = Rc::new(5);
/// ```
# fn foo() {}
</code></pre>

Das testet dann eigentlich diesen Code:


```rust
fn main() {
    use std::rc::Rc;
    let five = Rc::new(5);
}
```

Hier ist der gesamte Algorithmus den `rustdoc` verwendet um Beispiele nachzubearbeiten:

1. Jedes `#![foo]` Attribut am Anfang bleibt als Crate Attribut intakt.
2. Einige gebräuchliche `allow` Attribute werden eingefügt um die Linter zu beschwichtigen und die Regeln etwas weniger streng zu machen, u.a. `unused_variables`, `unused_assignments`, `unused_mut`, `unused_attributes`, und `dead_code`.
3. Wenn ein Beispiel keine `extern crate` enthält wird `extern crate <mein crate>;` hinzugefügt.
4. Zum Schluss wird der Code noch in ein `fn main() {...}` eingepackt, wenn das noch nicht so ist.


## Partielle Beispiele

Manchmal reicht die Nachbearbeitung aber nicht ganz,
zum Beispiel wenn man nur auf ganz bestimmte Zeilen hinweisen will.
Die obig genannten Beispiele mit `///` sehen eigentlich ein wenig anders aus:

```text
/// Kleines Beispiel.
# fn foo() {}
```

anstatt:

```rust
/// Kleines Beispiel.
# fn foo() {}
```

Man kann also *nur in Kommentaren* Zeilen mit einem `#` ausblenden.
Dieser Code wird dann mit kompiliert, aber nicht angezeigt.
Das kann man dazu nutzen um unvollständige Beispiele zu zeigen,
die allerdings trotzdem korrekt kompilieren sollen.
Zum Beispiel:

```rust
let x = 5;
let y = 6;
println!("{}", x + y);
```

Dieser Code muss auf jeden Fall Zeile für Zeile erläutert werden.

Erst setzen wir `x` auf fünf:

```rust
let x = 5;
# let y = 6;
# println!("{}", x + y);
```

Danach `y` auf sechs:

```rust
# let x = 5;
let y = 6;
# println!("{}", x + y);
```

Zum Schluss geben wir deren Summe aus:

```rust
# let x = 5;
# let y = 6;
println!("{}", x + y);
```

Hier das ganze nochmal als Plaintext:

> Erst setzen wir `x` auf fünf:
>
> ```text
> let x = 5;
> # let y = 6;
> # println!("{}", x + y);
> ```
>
> Danach `y` auf sechs:
>
> ```text
> # let x = 5;
> let y = 6;
> # println!("{}", x + y);
> ```
>
> Zum Schluss geben wir deren Summe aus:
>
> ```text
> # let x = 5;
> # let y = 6;
> println!("{}", x + y);
> ```

### Macros kommentieren

Hier ist ein Beispiel eines dokumentierten `macro`s:

<pre><code class="lang-rust">
/// Panic with a given message unless an expression evaluates to true.
///
/// # Examples
///
/// ```
/// # #[macro_use] extern crate foo;
/// # fn main() {
/// panic_unless!(1 + 1 == 2, “Math is broken.”);
/// # }
/// ```
///
/// ```should_panic
/// # #[macro_use] extern crate foo;
/// # fn main() {
/// panic_unless!(true == false, “I’m broken.”);
/// # }
/// ```
#[macro_export]
macro_rules! panic_unless {
    ($condition:expr, $($rest:expr),+) => ({ if ! $condition { panic!($($rest),+); } });
}
# fn main() {}
</code></pre>


Hier fallen dir sicherlich drei Dinge auf:
wir müssen selber `extern crate` hinzufügen, damit wir `#[macro_use]` dranschreiben können.
Zweitens müssen wir auch noch selbst `main()` schreiben und zum Schluss ganz viele `#`s um das dann wieder unsichtbar zu machen.

### Dokumentation Testen

Das geht entweder mit

```bash
$ rustdoc --test path/to/my/crate/root.rs
```

oder

```bash
$ cargo test
```

`cargo test` funktioniert allerdings nur bei Bibliotheken, das liegt daran wie `rustdoc` funktioniert: Es linkt gegen die Bibliothek.

Annotationen die auch beim [Testen](Testen.md) funktionieren, sind auch bei `rustdoc` manchmal nützlich, zum Beispiel:

<pre><code class="lang-rust">
/// ```ignore
/// fn foo() {
/// ```
# fn foo() {}
</code></pre>

`ignore` bittet Rust dieses Beispiel bitte nicht mitzutesten,
wenn man weiß dass der Test scheitern würde.

<pre><code class="lang-rust">
/// ```should_panic
/// assert!(false);
/// ```
# fn foo() {}
</code></pre>

Das ist allerdings die allgemeinste Lösung, meisten ist eine der folgenden Möglichkeiten passender.
Oder man will lieber `text` verwenden, wenn es kein gar Rustcode ist oder Zeilen mit `#` ausblenden um ein Beispiel zu konstruieren welches trotzdem funktioniert.

`should_panic` sagt `rustdoc` dass der code korrekt compiliert, aber der Test fehlschlagen soll.

<pre><code class="lang-rust">
/// ```no_run
/// loop {
///     println!("Hello, world");
/// }
/// ```
# fn foo() {}
</code></pre>

Und `no_run` führt dazu, dass dein Code kompiliert, aber nicht nicht ausgeführt  wird. Dann zählt der Test als bestanden, sobald er korrekt kompiliert hat.

### Module dokumentieren

Rust hat noch eine weitere Art von Kommentar, `//!`.
Diese Syntax bezieht sich nicht auf den darauf folgenden Block,
sondern auf den äußeren.
Sprich:

```rust
mod foo {
    //! This is documentation for the `foo` module.
    //!
    //! # Examples

    // ...
}
```

Am häufigsten wirst du `//!` am Anfang von Dateien sehen.
Dateien werden häufig also Module eingebunden: `./foo.rs` durch `mod foo`.

```rust
//! A module for using `foo`s.
//!
//! The `foo` module contains a lot of useful functionality blah blah blah
```

Oder einfach am Anfang deiner `lib.rs`.

### Dokumentationsstil

[RFC 505](https://github.com/rust-lang/rfcs/blob/master/text/0505-api-comment-conventions.md) (englisch) ist die vollständige Quelle für alle Konventionen bezüglich Dokumentation in Rust.


## Andere Dokumentation

Alles oben genannte funktioniert auch in nicht-`.rs` Dateien.
Da Kommentare in Markdown geschrieben sind,
kannst du auch gleich `.md` Dateien verwenden.

Wenn du Dokumentation in Markdowndateien schreibst, brauchst du die Prefixe nicht mehr. Zum Beispiel:

<pre><code class="lang-rust">
/// # Examples
///
/// ```
/// use std::rc::Rc;
///
/// let five = Rc::new(5);
/// ```
# fn foo() {}
</code></pre>

ist einfach

<pre><code class="lang-markdown">
# Examples

```
use std::rc::Rc;

let five = Rc::new(5);
```
</code></pre>

in einer Markdown Datei. Wichtig ist hier nur, dass diese Dokumente immer einen Titel brauchen:

```markdown
% The title

This is the example documentation.
```

Das `%` am Angang muss in der aller ersten Zeile sein.

## 'doc' Attribute

Wenn man genauer hinschaut, dann sind Kommentare nur eine einfachere Variante von Dokumentationsattributen:

```rust
/// this
# fn foo() {}

#[doc="this"]
# fn bar() {}
```

ist identisch zu:

```rust
//! this

#![doc="/// this"]
```

Das wirst du nicht häufig zu sehen bekommen, aber manchmal kann es nützlich sein.

## Re-Exporte

`rustdoc` wird die Dokumentation von Re-Exporten an an beiden Stellen einblenden:

```ignore
extern crate foo;

pub use foo::bar;
```

Hier wird die Dokumentation für 'bar` sowohl in der Dokumentation für das Crate `foo`, also auch in der dokumentation deines Crates auftauchen.

Das kann durch `no_inline` unterdrückt werden:

```ignore
extern crate foo;

#[doc(no_inline)]
pub use foo::bar;
```

### Kontrolle des HTML

Auf ein paar Aspekte des von `rustdoc` generierten HTMLs kannst du mit `#![doc]` Einfluss nehmen.

```rust
#![doc(html_logo_url = "https://www.rust-lang.org/logos/rust-logo-128x128-blk-v2.png",
       html_favicon_url = "https://www.rust-lang.org/favicon.ico",
       html_root_url = "https://doc.rust-lang.org/")]
```

Auf die weise kannst du das Logo, inklusive Favicon ersetzen.

## Optionen zum Einbinden von Dateien

`rustdoc` enthält außerdem noch ein paar weitere Kommandozeilen Optionen:

- `--html-in-header FILE`: inkludiert den Inhalt der Datei am Ende der
  `<head>...</head>` Sektion.
- `--html-before-content FILE`: inkludiert den Inhalt einer Datei direkt nach
  `<body>`, vor dem generierten Inhalt (inklusive Suchleiste).
- `--html-after-content FILE`: inkludiert den Inhalt der Datei am nach dem generierten Inhalt.

## Sicherheitshinweis

Das Markdown in den Dokumentationskommentaren wird unbearbeitet in die Webseite kopiert. Also vorsichtig mit HTML wie:

```rust
/// <script>alert(document.cookie)</script>
# fn foo() {}
```

☺
