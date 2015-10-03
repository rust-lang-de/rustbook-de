% Dokumentation

Dokumentation ist ein wichtiger Teil eines jeden Software Projekts.
In Rust ist sie ein Sprachbestandteil.
Reden wir doch mal über die Tools die uns Rust zur Verfügung stellt um unser Projekt zu Dokumentieren.

## Über `rustdoc`

Das Rust Paket beinhaltet ein Tool namens `rustdoc`, welches Dokumentation generiert.
`rustdoc` wird von Cargo für `cargo doc` verwendet.

Dokumentation kann auf zwei arten erzeugt werden: aus dem Quelltext und aus Markdown Dateien.

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


<pre><code class="lang-rust">
/// The `Option` type. See [the module level documentation](index.html) for more.
enum Option<T> {
    /// No value
    None,
    /// Some value `T`
    Some(T),
}
</code></pre>

Das hier oben funktioniert, das folgende leider nicht:

<pre><code class="lang-rust">
/// The `Option` type. See [the module level documentation](index.html) for more.
enum Option<T> {
    None, /// No value
    Some(T), /// Some value `T`
}
</pre></code>

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
```

`panic` indiziert in Rust vornehmlich, dass ein nicht behebbarer Fehler aufgetreten ist,
meistens durch Programmierfehler.
In diesen Fällen soll der aktuelle Thread "kontrolliert abstürzen".
Wenn das in deinem Programm so vorgesehen ist, solltest du in der Dokumentation explizit darauf hinweisen.

```rust
/// # Failures
```

Wenn deine Funktion/Methode ein `Result<T, E>` zurückgibt,
dann beschreibe die Bedingungen unter denen es einen `Err(E)` zurückgibt.
Das ist nicht ganz so wichtig wie eine Panik, da Failures Teil des Typsystems sind, aber es ist dennoch wichtig.

```rust
/// # Safety
```

Wenn die Funktion `unsafe` verwendet, dann sollte ebenfalls explizit darauf hingewiesen werden, da hier eventuell Probleme auftreten können vor denen Rust anderweitig gefeit ist.


<pre><code class="rust-lang">
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

<pre><code class="rust-lang">
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
</pre></code>

Reden wir einmal etwas detailierter über Codeblöcke.

#### Codeblock Annotationen

Um Quelltext in Kommentaren zu schreiben benutzt man in Markdown drei Accent Graves.

<pre><code class="lang-rust">
/// ```
/// println!("Hello, world");
/// ```
</code></pre>

Dabei wir wird in der ersten Zeile normalerweise die Programmiersprache für den Highlighter angegeben.
Bei uns ist Rust Standard, wenn du etwas anderes angeben willst dann sieht das zum Beispiel so aus:


<pre><code class="lang-rust">
/// ```c
/// printf("Hello, world\n");
/// ```
</code></pre>

Wenn du Plaintext ausgeben willst nimm ` ```text `

Es ist wichtig die richtige Codeblockannotation zu wählen, da `rustdoc` diese nicht nur für Highlighting verwendet.
Denn die Beispiele in deinem Crate können tatsächlich getestet werden.
Somit wird sichergestellt, dass sie nicht veraltet sind.
Wenn du allerdings C Code nicht mit ` ```c ` annotierst, denkt `rustdoc` es muss ihn als Rust kompilieren und meldet dann Fehler, weil das natürlich nicht geht.

## Dokumentation und Tests

Reden wir einmal über unsere Beispiele:


```rust
/// ```
/// println!("Hello, world");
/// ```
# fn foo() {}
```

Dir ist vielleicht aufgefallen, dass du kein `fn main()` gebraucht hast.
`rustdoc` generiert hier automatisch einen Wrapper dafür.
Zum Beispiel:


```rust
/// ```
/// use std::rc::Rc;
///
/// let five = Rc::new(5);
/// ```
# fn foo() {}
```

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
3. Wenn ein Beispiel keine `extern crate` enthält wird `extern crate <mein crate>; hinzugefügt.
4. Zum Schluss wird der Code noch in ein `fn main() {...}` eingepackt, wenn das noch nicht so ist.

Manchmal reicht das aber nicht, zum Beispiel wenn 
