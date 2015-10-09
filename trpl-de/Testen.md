% Testing

> Program testing can be a very effective way to show the presence of bugs, but
> it is hopelessly inadequate for showing their absence.
>
> *Das Testen von Programmen ist eine sehr effektive Art,
> die Anwesenheit von Bugs zu zeigen, aber ist hoffnungslos unangemessen, deren Abwesenheit zu zeigen.*
>
> Edsger W. Dijkstra, "The Humble Programmer" (1972)


## Das `test` Attribut

In Rust ist ein Test ganz einfach eine Funktion die mit `test` annotiert ist.
Beginnen wir also ein kleines Cargo Projekt namens `adder`:

```bash
$ cargo new adder
$ cd adder
```

Wenn wir `cargo new` ohne `--bin` ausführen erzeugt Cargo ein Library-Projekt.
Cargo generiert automatisch einen kleinen Test, wie man am Inhalt von `src/lib.rs` sieht:

```rust
#[test]
fn it_works() {
}
```

Achte auf `#[test]`.
Das ist ein Attribut und es markiert die Funktion `it_works()` als Test.
Sie ist erst mal leer.
Dann kann sie auch auch nicht fehlschlagen.
Wir können sie ganz einfach mit `cargo test` ausführen:


```bash
$ cargo test
   Compiling adder v0.0.1 (file:///home/you/projects/adder)
     Running target/adder-91b3e234d4ed382a

running 1 test
test it_works ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured

   Doc-tests adder

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured
```

Hier sehen wir zwei Ausgaben.
Die erste für den Test den wir geschrieben haben,
die zweite für Dokumentationstests, davon später mehr.
Vorerst:

```text
test it_works ... ok
```

Beachte dass hier der Name unserer Funktion `it_works` steht.

```rust
fn it_works() {
}
```

Warum schlägt dieser leere Test aber nun nicht fehl?
Jeder Test der kein `panic!()` provoziert ist erfolgreich.
Wie könnten wir ihn nun fehlschlagen lassen?

```rust
#[test]
fn it_works() {
    assert!(false);
}
```

`assert!` ist ein Macro in Rust das genau ein Argument nimmt,
und wenn das nicht `true` ist, dann ruft es `panic!` auf.
Also nochmal:


```bash
$ cargo test
   Compiling adder v0.0.1 (file:///home/you/projects/adder)
     Running target/adder-91b3e234d4ed382a

running 1 test
test it_works ... FAILED

failures:

---- it_works stdout ----
        thread 'it_works' panicked at 'assertion failed: false', /home/steve/tmp/adder/src/lib.rs:3



failures:
    it_works

test result: FAILED. 0 passed; 1 failed; 0 ignored; 0 measured

thread '<main>' panicked at 'Some tests failed', /home/steve/src/rust/src/libtest/lib.rs:247
```

Rust sagt uns, dass unser Test gefailt ist.

```text
test it_works ... FAILED
```

Was uns auch die Zusammenfassung am Ende sagt:

```text
test result: FAILED. 0 passed; 1 failed; 0 ignored; 0 measured
```

Wir haben ebenfalls einen non-zero status code bekommen, ein feature unserer Shell (*linux und OS X*), dass das letzte Kommando fehlgeschlagen ist.

```bash
$ echo $?
101
```

Auf Windows in `cmd` :

```bash
> echo %ERRORLEVEL%
```

oder PowerShell:

```bash
> echo $LASTEXITCODE # Der Exitcode selbst
> echo $? # ein boolean, Erfolgreich oder nicht
```

Das ist nützlich wenn du `cargo test` in andere Tools integrieren willst.

Wir können den Test auch invertieren, wenn wir wollen, dass er fehlschlägt: `should_panic`:


```rust
#[test]
#[should_panic]
fn it_works() {
    assert!(false);
}
```

Der Test zählt nun als erfolgreich, wenn `panic!` eintritt.
Gleich mal ausprobieren:

```bash
$ cargo test
   Compiling adder v0.0.1 (file:///home/you/projects/adder)
     Running target/adder-91b3e234d4ed382a

running 1 test
test it_works ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured

   Doc-tests adder

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured
```

Rust kennt noch ein weiteres Macro: `assert_eq!`, zum Vergleichen zweier Werte:


```rust
#[test]
#[should_panic]
fn it_works() {
    assert_eq!("Hello", "world");
}
```

Schlägt das hier nun fehl?
Nein, denn da steht noch `should_panic`:


```bash
$ cargo test
   Compiling adder v0.0.1 (file:///home/you/projects/adder)
     Running target/adder-91b3e234d4ed382a

running 1 test
test it_works ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured

   Doc-tests adder

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured
```

`should_panic` ist immer mit etwas Vorsicht zu genießen, denn es schwer sicher zu sein, ob der Test nicht auf Grund anderer Probleme ge`panic`t hat.
Wir können aber Bedingungen für bestimmte Fehler hinzufügen:

```rust
#[test]
#[should_panic(expected = "assertion failed")]
fn it_works() {
    assert_eq!("Hello", "world");
}
```

Jetzt muss das `assert_eq!` fehlschlagen, sonst scheitert der Test trotzdem.

Soviel also zu Grundlagen, schreiben wir endlich einen nützlichen Test!


```rust
pub fn add_two(a: i32) -> i32 {
    a + 2
}

#[test]
fn it_works() {
    assert_eq!(4, add_two(2));
}
```

Das ist ein klassischer Fall für `assert_eq!`: Wir rufen eine Funktion auf und vergleichen ihren Rückgabewert.

## Das `ignore` Attribut

In Manchen Situationen wollen wir bestimmte Tests nicht immer mit ausführen, besonders, wenn sie teuer sind.
Diese kann man dann mit `ignore` ausschalten:


```rust
#[test]
fn it_works() {
    assert_eq!(4, add_two(2));
}

#[test]
#[ignore]
fn expensive_test() {
    // Code der eine Stunde läuft
}
```

Jetzt werden sie exklusiv dann ausgeführt wenn wir `cargo test -- --ignored` ausführen:

```bash
$ cargo test
   Compiling adder v0.0.1 (file:///home/you/projects/adder)
     Running target/adder-91b3e234d4ed382a

running 2 tests
test expensive_test ... ignored
test it_works ... ok

test result: ok. 1 passed; 0 failed; 1 ignored; 0 measured

   Doc-tests adder

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured
```

Wir sehen: `it_works` wurde getestet, `expensive_test` nicht.

```bash
$ cargo test -- --ignored
     Running target/adder-91b3e234d4ed382a

running 1 test
test expensive_test ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured

   Doc-tests adder

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured
```

Wichtig: `--ignored` ist ein Argument, das von dem Testbinary interpretiert wird, nicht von Cargo selbst.
Das wird mit den extra `--` vermittelt.

## Das `tests` Modul

Was ist allerdings, wenn wir noch Hilfsfunktionen für unsere Tests brauchen,
die selbst keine Tests sind, die wir aber auch nicht mit ausliefern wollen?
Dafür kann man Tests innerhalb eines `tests` Moduls implementieren.
So in etwa:

```rust
pub fn add_two(a: i32) -> i32 {
    a + 2
}

#[cfg(test)]
mod tests {
    use super::add_two;

    #[test]
    fn it_works() {
        assert_eq!(4, add_two(2));
    }
}
```

Das erlaubt es uns alle unsere Tests hier zu gruppieren und zusätzlich auch noch ggf. Hilfsfunktionen zu implementieren.
Dieses gesamte Modul wird nicht in unser crate kompiliert, wenn wir es nicht explizit als Test kompilieren, wir haben also nie Testcode in unserer Bibliothek.
Das spart nicht nur Kompilierzeit, sondern auch noch Platz.

Eine weitere Änderung ist die `use` Deklaration.
Weil wir uns hier in einem Untermodul und damit einem anderen Namespace befinden müssen, müssen wir die zu testende Funktion quasi importieren.
Das kann nerven, wenn wir irgendwann größere Projekte haben, also vereinfachen wir das doch einfach mit `*`

```rust,ignore
pub fn add_two(a: i32) -> i32 {
    a + 2
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        assert_eq!(4, add_two(2));
    }
}
```

Beachte, dass sich die `use` Zeile geändert hat:

```bash
$ cargo test
    Updating registry `https://github.com/rust-lang/crates.io-index`
   Compiling adder v0.0.1 (file:///home/you/projects/adder)
     Running target/adder-91b3e234d4ed382a

running 1 test
test tests::it_works ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured

   Doc-tests adder

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured
```

Schön!

Die momentane Konvention ist, dass das `tests` Modul deine "unit-style" tests enthält.
Alles was nur kleine Funktionalitätstests umfasst.
Integrationstest jedoch, verdienen etwas mehr platz, dafür haben wir das `tests` Verzeichnis.

## Das `tests` Verzeichnis

Um einen Integrationstest zu schreiben erzeugen wir erst einmal unser `tests` Verzeichnis und legen darin eine `.rs` Datei an: `tests/lib.rs`:

```rust,ignore
extern crate adder;

#[test]
fn it_works() {
    assert_eq!(4, adder::add_two(2));
}
```

Das sieht unserem vorherigen Test schon sehr ähnlich, naja, nicht ganz.
Wir haben nun die Zeile `extern crate adder` ganz oben.
Das ist weil die Tests im `tests` Verzeichnis ein eigenes Crate sind und daher unsere Bibliothek erst einbinden müssen.
Das ist auch ein Grund warum Integrationstests hier gut aufgehoben sind, sie verwenden unsere Bibliothek genauso wie es ein dritter tun würde.

Führen wir sie aus:

```bash
$ cargo test
   Compiling adder v0.0.1 (file:///home/you/projects/adder)
     Running target/adder-91b3e234d4ed382a

running 1 test
test tests::it_works ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured

     Running target/lib-c18e7d3494509e74

running 1 test
test it_works ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured

   Doc-tests adder

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured
```

Jetzt haben wir drei Sektionen: unsere vorherigen Tests werden ja immernoch ausgeführt.

Das ist alles zum `tests` Verzeichnis.
Das `tests` Modul brauchen wir hier nicht, da alles mit Tests zu tun hat.

Kommen wir nun zum dritten Teil: Dokumentation.

## Dokumentationstests

Nichts ist besser als Dokumentation mit Beispielen.
Nichts ist blöder als wenn die Beispiele in der Dokumentation nicht funktionieren, zum Beispiel, weil sich die API verändert hat, seitdem die Dokumentation geschrieben wurde.
Rust macht damit Schluss, indem es automatisch den Code in der Dokumentation mit ausführt.
*Allerdings nur bei Bibliothek-Crates, nicht Binary-Crates.*
Hier nochmal `src/lib.rs` mit Beispielen:

<pre><code class="lang-rust">
//! The `adder` crate provides functions that add numbers to other numbers.
//!
//! # Examples
//!
//! ```
//! assert_eq!(4, adder::add_two(2));
//! ```

/// This function adds two to its argument.
///
/// # Examples
///
/// ```
/// use adder::add_two;
///
/// assert_eq!(4, add_two(2));
/// ```
pub fn add_two(a: i32) -> i32 {
    a + 2
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        assert_eq!(4, add_two(2));
    }
}
</code></pre>


Wichtig hier: Moduldokumentation beginnt mit `//!` und Funktionsdokumentation mit `///`.
Kommentare die mit `//` beginnen landen nicht in der Dokumentation.
Rusts Dokumentationswerkzeug unterstützt Markdown, daher markieren drei Accent grave Zeichen *(backticks "\`")*
Es ist Konvention eine Überschrift `# Examples` *(bitte Englisch)* zu haben, dem dann die Beispiele folgen.

Noch ein Testlauf:

```bash
$ cargo test
   Compiling adder v0.0.1 (file:///home/steve/tmp/adder)
     Running target/adder-91b3e234d4ed382a

running 1 test
test tests::it_works ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured

     Running target/lib-c18e7d3494509e74

running 1 test
test it_works ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured

   Doc-tests adder

running 2 tests
test add_two_0 ... ok
test _0 ... ok

test result: ok. 2 passed; 0 failed; 0 ignored; 0 measured
```

Jetzt haben wir alle drei Arten von Tests getestet.
Hier heißt der Dokumentationstest `_0` und der Funktionstest `add_two_0`.
Die Zahl wir inkrementiert je mehr Tests dazukommen.

Wir haben noch nicht alles wichtige zu Dokumentationstests hier erwähnt.
Für mehr schau in das [Dokumentationskapitel](documentation).


