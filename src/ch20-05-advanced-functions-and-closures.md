## Erweiterte Funktionen und Funktionsabschlüsse (closures)

Dieser Abschnitt befasst sich mit fortgeschrittenen Funktionalitäten im
Zusammenhang mit Funktionen und Funktionsabschlüsse, einschließlich
Funktionszeigern und Zurückgeben von Funktionsabschlüssen.

### Funktionszeiger

Wir haben darüber gesprochen, wie man Funktionsabschlüsse an Funktionen
übergibt; man kann auch reguläre Funktionen an Funktionen übergeben! Diese
Technik ist nützlich, wenn du eine Funktion, die du bereits definiert hast,
übergeben willst, anstatt einen neuen Funktionsabschluss zu definieren.
Funktionen haben den Typ `fn` (mit kleinem f), nicht zu verwechseln mit dem
Funktionsabschlussmerkmal (closure trait) `Fn`. Der Typ `fn` wird
*Funktionszeiger* (function pointer) genannt. Die Übergabe von Funktionen mit
Funktionszeigern ermöglicht es dir, Funktionen als Argumente für andere
Funktionen zu verwenden.

Die Syntax für die Angabe, dass ein Parameter ein Funktionszeiger ist, ähnelt
der von Funktionsabschlüssen, wie in Codeblock 19-27 gezeigt, wo wir eine
Funktion `add_one` definiert haben, die ihrem Parameter eins hinzufügt. Die
Funktion `do_twice` nimmt zwei Parameter entgegen: Einen Funktionszeiger auf
eine beliebige Funktion mit einem `i32`-Parameter und einem `i32`-Rückgabewert,
und einen `i32`-Parameter. Die Funktion `do_twice` ruft die Funktion `f`
zweimal auf, übergibt ihr den Wert `arg` und addiert dann die Ergebnisse der
beiden Funktionsaufrufe zusammen. Die Funktion `main` ruft `do_twice` mit den
Argumenten `add_one` und `5` auf.

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn add_one(x: i32) -> i32 {
    x + 1
}

fn do_twice(f: fn(i32) -> i32, arg: i32) -> i32 {
    f(arg) + f(arg)
}

fn main() {
    let answer = do_twice(add_one, 5);

    println!("Die Antwort ist: {answer}");
}
```

<span class="caption">Codeblock 19-27: Verwenden des Typs `fn` zum
Entgegennehmen eines Funktionszeigers als Argument</span>

Dieser Code gibt `Die Antwort ist: 12` aus. Wir spezifizieren, dass der
Parameter `f` in `do_twice` ein `fn` ist, das einen Parameter vom Typ `i32`
nimmt und ein `i32` zurückgibt. Wir können dann `f` im Rumpf von `do_twice`
aufrufen. In `main` können wir den Funktionsnamen `add_one` als erstes Argument
an `do_twice` übergeben.

Im Gegensatz zu Funktionsabschlüssen ist `fn` ein Typ, nicht ein Merkmal, daher
spezifizieren wir `fn` direkt als Parametertyp, anstatt einen generischen
Typparameter mit einem Merkmal `Fn` als Merkmalsabgrenzung (trait bound) zu
deklarieren.

Funktionszeiger implementieren alle drei Funktionsabschlussmerkmale (`Fn`,
`FnMut` und `FnOnce`), was bedeutet, dass du immer einen Funktionszeiger als
Argument an eine Funktion übergeben kannst, die einen Funktionsabschluss
erwartet. Es ist am besten, Funktionen mit einem generischen Typ und einer der
Funktionsabschlussmerkmale zu schreiben, sodass deine Funktionen entweder
Funktionen oder Funktionsabschlüsse akzeptieren können.

Ein Beispiel, bei dem du nur `fn` und keine Funktionsabschlüsse akzeptieren
möchtest, ist die Schnittstelle zu externem Code, der keine Funktionsabschlüsse
hat: C-Funktionen können Funktionen als Argumente akzeptieren, aber C hat keine
Funktionsabschlüsse.

Als Beispiel dafür, wo du entweder einen inline definierten Funktionsabschluss
oder eine benannte Funktion verwenden könntest, sehen wir uns die Verwendung
der Methode `map` an, die vom Merkmal `Iterator` in der Standardbibliothek
bereitgestellt wird. Um die Funktion `map` zu verwenden, um einen Vektor von
Zahlen in einen Vektor von Zeichenketten zu verwandeln, könnten wir einen
Funktionsabschluss wie diesen verwenden:

```rust
    let list_of_numbers = vec![1, 2, 3];
    let list_of_strings: Vec<String> =
        list_of_numbers.iter().map(|i| i.to_string()).collect();
```

Oder wir könnten eine Funktion als Argument für `map` angeben anstelle des
Funktionsabschlusses, so wie hier:

```rust
    let list_of_numbers = vec![1, 2, 3];
    let list_of_strings: Vec<String> =
        list_of_numbers.iter().map(ToString::to_string).collect();
```

Beachte, dass wir die vollständig qualifizierte Syntax verwenden müssen, über
die wir vorhin im Abschnitt [„Fortgeschrittene Merkmale
(traits)“][advanced-traits] gesprochen haben, weil es mehrere Funktionen namens
`to_string` gibt. Hier verwenden wir die Funktion `to_string`, die im Merkmal
`ToString` definiert ist, welche die Standardbibliothek für jeden Typ
implementiert hat, der `Display` implementiert.

Aus dem Abschnitt [„Werte in Aufzählungen“][enum-values] in Kapitel 6 wissen
wir, dass der Name jeder definierten Aufzählungsvariante auch eine
Initialisierungsfunktion ist. Wir können diese Initialisierungsfunktionen als
Funktionszeiger verwenden, die die Funktionsabschlussmerkmale implementieren,
was bedeutet, dass wir die Initialisierungsfunktionen als Argumente für
Methoden angeben können, die Funktionsabschlüsse wie diese nehmen:

```rust
    enum Status {
        Value(u32),
        Stop,
    }

    let list_of_statuses: Vec<Status> = (0u32..20).map(Status::Value).collect();
```

Hier erzeugen wir `Status::Value`-Instanzen für die `u32`-Werte im Bereich, für
den `map` aufgerufen wird, indem wir die Initialisierungsfunktion von
`Status::Value` verwenden. Einige Leute bevorzugen diesen Stil und einige Leute
ziehen es vor, Funktionsabschlüsse zu verwenden. Sie kompilieren zum gleichen
Code, also verwende den Stil, der für dich am klarsten ist.

### Zurückgeben von Funktionsabschlüssen

Funktionsabschlüsse werden durch Merkmale repräsentiert, was bedeutet, dass du
Funktionsabschlüsse nicht direkt zurückgeben kannst. In den meisten Fällen, in
denen du ein Merkmal zurückgeben möchtest, kannst du stattdessen den konkreten
Typ, der das Merkmal implementiert, als Rückgabewert der Funktion verwenden.
Aber das kannst du bei Funktionsabschlüssen nicht tun, weil sie keinen
konkreten Typ haben, der rückgabefähig ist; es ist dir beispielsweise nicht
erlaubt, den Funktionszeiger `fn` als Rückgabetyp zu verwenden.

Der folgende Code versucht, einen Funktionsabschluss direkt zurückzugeben, aber
er lässt sich nicht kompilieren:

```rust,does_not_compile
fn returns_closure() -> dyn Fn(i32) -> i32 {
    |x| x + 1
}
```

Der Kompilierfehler ist folgender:

```console
$ cargo build
   Compiling functions-example v0.1.0 (file:///projects/functions-example)
error[E0746]: return type cannot have an unboxed trait object
 --> src/lib.rs:1:25
  |
1 | fn returns_closure() -> dyn Fn(i32) -> i32 {
  |                         ^^^^^^^^^^^^^^^^^^ doesn't have a size known at compile-time
  |
help: return an `impl Trait` instead of a `dyn Trait`, if all returned values are the same type
  |
1 | fn returns_closure() -> impl Fn(i32) -> i32 {
  |                         ~~~~
help: box the return type, and wrap all of the returned values in `Box::new`
  |
1 ~ fn returns_closure() -> Box<dyn Fn(i32) -> i32> {
2 ~     Box::new(|x| x + 1)
  |

For more information about this error, try `rustc --explain E0746`.
error: could not compile `functions-example` (lib) due to 1 previous error
```

Der Fehler bezieht sich wieder auf das Merkmal `Sized`! Rust weiß nicht, wie
viel Platz benötigt wird, um den Funktionsabschluss zu speichern. Wir haben
vorhin eine Lösung für dieses Problem gesehen. Wir können ein Merkmalsobjekt
(trait object) verwenden:

```rust
fn returns_closure() -> Box<dyn Fn(i32) -> i32> {
    Box::new(|x| x + 1)
}
```

Dieser Code lässt sich sehr gut kompilieren. Weitere Informationen über
Merkmalsobjekte findest du im Abschnitt [„Merkmalsobjekte (trait objects) die
Werte unterschiedlicher Typen erlauben“][trait-objects] in Kapitel 17.

Als nächstes wollen wir uns Makros ansehen!

[advanced-traits]: ch19-03-advanced-traits.html
[enum-values]: ch06-01-defining-an-enum.html#werte-in-aufzählungen
[trait-objects]: ch17-02-trait-objects.html
