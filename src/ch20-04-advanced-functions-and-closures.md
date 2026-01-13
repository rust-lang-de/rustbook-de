## Erweiterte Funktionen und Funktionsabschlüsse (closures)

Dieser Abschnitt befasst sich mit fortgeschrittenen Funktionalitäten im
Zusammenhang mit Funktionen und Funktionsabschlüsse, einschließlich
Funktionszeigern und Zurückgeben von Funktionsabschlüssen.

### Funktionszeiger

Wir haben darüber gesprochen, wie man Funktionsabschlüsse an Funktionen
übergibt; man kann auch reguläre Funktionen an Funktionen übergeben! Diese
Technik ist nützlich, wenn du eine Funktion, die du bereits definiert hast,
übergeben willst, anstatt einen neuen Funktionsabschluss zu definieren.
Funktionen haben den Typ `fn` (mit kleinem _f_), nicht zu verwechseln mit dem
Funktionsabschlussmerkmal (closure trait) `Fn`. Der Typ `fn` wird
_Funktionszeiger_ (function pointer) genannt. Die Übergabe von Funktionen mit
Funktionszeigern ermöglicht es dir, Funktionen als Argumente für andere
Funktionen zu verwenden.

Die Syntax für die Angabe, dass ein Parameter ein Funktionszeiger ist, ähnelt
der von Funktionsabschlüssen, wie in Codeblock 20-28 gezeigt, wo wir eine
Funktion `add_one` definiert haben, die ihrem Parameter 1 hinzufügt. Die
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

<span class="caption">Codeblock 20-28: Verwenden des Typs `fn` zum
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
bereitgestellt wird. Um die Methode `map` zu verwenden, um einen Vektor von
Zahlen in einen Vektor von Zeichenketten zu verwandeln, könnten wir einen
Funktionsabschluss verwenden, wie in Codeblock 20-29.

```rust
    let list_of_numbers = vec![1, 2, 3];
    let list_of_strings: Vec<String> =
        list_of_numbers.iter().map(|i| i.to_string()).collect();
```

<span class="caption">Codeblock 20-29: Verwendung eines Funktionsabschlusses
mit der Methode `map` zur Umwandlung von Zahlen in Zeichenketten</span>

Oder wir könnten eine Funktion als Argument für `map` angeben anstelle des
Funktionsabschlusses. Codeblock 20-30 zeigt, wie das aussehen würde.

```rust
    let list_of_numbers = vec![1, 2, 3];
    let list_of_strings: Vec<String> =
        list_of_numbers.iter().map(ToString::to_string).collect();
```

<span class="caption">Codeblock 20-30: Verwenden der Methode
`String::to_string` zur Umwandlung von Zahlen in Zeichenketten</span>

Beachte, dass wir die vollständig qualifizierte Syntax verwenden müssen, über
die wir in Abschnitt [„Fortgeschrittene Merkmale (traits)“][advanced-traits]
gesprochen haben, weil es mehrere Funktionen namens `to_string` gibt.

Hier verwenden wir die Funktion `to_string`, die im Merkmal `ToString`
definiert ist, welche die Standardbibliothek für jeden Typ implementiert hat,
der `Display` implementiert.

Aus Abschnitt [„Werte in Aufzählungen“][enum-values] in Kapitel 6 wissen wir,
dass der Name jeder definierten Aufzählungsvariante auch eine
Initialisierungsfunktion ist. Wir können diese Initialisierungsfunktionen als
Funktionszeiger verwenden, die die Funktionsabschlussmerkmale implementieren,
was bedeutet, dass wir die Initialisierungsfunktionen als Argumente für
Methoden angeben können, die Funktionsabschlüsse nehmen, wie in Codeblock 20-32
zu sehen ist.

```rust
    enum Status {
        Value(u32),
        Stop,
    }

    let list_of_statuses: Vec<Status> = (0u32..20).map(Status::Value).collect();
```

<span class="caption">Codeblock 20-31: Verwenden eines
Aufzählungs-Initialisierers mit der Methode `map` zum Erstellen einer
`Status`-Instanz aus Zahlen</span>

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
Aber das kannst du bei Funktionsabschlüssen normalerweise nicht tun, weil sie
keinen konkreten Typ haben, den man zurückgeben kann. Es ist dir beispielsweise
nicht erlaubt, den Funktionszeiger `fn` als Rückgabetyp zu verwenden, wenn der
Funktionsabschluss irgendwelche Werte aus seinem Gültigkeitsbereich erfasst.

Stattdessen wirst du normalerweise die Syntax `impl Trait` verwenden, die wir
in Kapitel 10 kennengelernt haben. Du kannst jeden Funktionstyp zurückgeben,
indem du `Fn`, `FnOnce` und `FnMut` verwendest. Zum Beispiel wird der Code in
Codeblock 20-32 problemlos funktionieren.

```rust
fn returns_closure() -> impl Fn(i32) -> i32 {
    |x| x + 1
}
```

<span class="caption">Codeblock 20-32: Rückgeben eines Funktionsabschlusses aus
einer Funktion unter Verwendung der Syntax `impl Trait`</span>

Wie wir jedoch im Abschnitt [„Herleiten und Annotieren von
Funktionsabschluss-Typen“][closure-types] in Kapitel 13 festgestellt haben, ist
jeder Funktionsabschluss auch ein eigener Typ. Wenn du mit mehreren Funktionen
arbeiten musst, die dieselbe Signatur, aber unterschiedliche Implementierungen
haben, musst du ein Merkmals-Objekt für sie verwenden. Überlege, was passiert,
wenn du einen Code wie in Codeblock 20-33 schreibst.

<span class="filename">Dateiname: src/main.rs</span>

```rust,does_not_compile
fn main() {
    let handlers = vec![returns_closure(), returns_initialized_closure(123)];
    for handler in handlers {
        let output = handler(5);
        println!("{output}");
    }
}

fn returns_closure() -> impl Fn(i32) -> i32 {
    |x| x + 1
}

fn returns_initialized_closure(init: i32) -> impl Fn(i32) -> i32 {
    move |x| x + init
}
```

<span class="caption">Codeblock 20-33: Erstellen eines `Vec<T>` von
Funktionsabschlüssen, die durch Funktionen definiert sind, die `impl Fn`
zurückgeben</span>

Hier haben wir zwei Funktionen `returns_closure` und
`returns_initialized_closure`, die beide `impl Fn(i32) -> i32` zurückgeben. Man
beachte, dass die Funktionsabschlüsse, die sie zurückgeben, unterschiedlich
sind, obwohl sie den gleichen Typ implementieren. Wenn wir versuchen, dies zu
kompilieren, lässt uns Rust wissen, dass es nicht funktionieren wird:

```console
$ cargo build
   Compiling functions-example v0.1.0 (file:///projects/functions-example)
    error[E0308]: mismatched types
    --> src/main.rs:4:9
       |
    4  |         returns_initialized_closure(123)
       |         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ expected opaque type, found a different opaque type
    ...
    12 | fn returns_closure() -> impl Fn(i32) -> i32 {
       |                         ------------------- the expected opaque type
    ...
    16 | fn returns_initialized_closure(init: i32) -> impl Fn(i32) -> i32 {
       |                                              ------------------- the found opaque type
       |
    = note: expected opaque type `impl Fn(i32) -> i32` (opaque type at <src/main.rs:12:25>)
                found opaque type `impl Fn(i32) -> i32` (opaque type at <src/main.rs:16:46>)
    = note: distinct uses of `impl Trait` result in different opaque types

    For more information about this error, try `rustc --explain E0308`.
    error: could not compile `functions-example` (bin "functions-example") due to 1 previous error
```

Die Fehlermeldung sagt uns, dass Rust jedes Mal, wenn wir ein `impl Trait`
zurückgeben, einen eindeutigen _undurchsichtigen Typ_ (opaque type) erzeugt,
einen Typ, bei dem wir weder die Details dessen sehen können, was Rust für uns
konstruiert, noch den Typ erraten können, den Rust generieren wird. Obwohl
diese Funktionen also beide Funktionsabschlüsse zurückgeben, die dasselbe
Merkmal implementieren, nämlich `Fn(i32) -> i32`, sind die undurchsichtigen
Typen, die Rust für jede Funktion erzeugt, unterschiedlich. (Dies ist
vergleichbar mit der Art und Weise, wie Rust unterschiedliche konkrete Typen
für verschiedene asynchrone Blöcke erzeugt, selbst wenn sie denselben
Ausgabetyp haben, wie wir im Abschnitt [„Die Merkmale `Pin` and
`Unpin`“][future-types] in Kapitel 17 gesehen haben.) Eine Lösung für dieses
Problem haben wir jetzt schon ein paar Mal gesehen: Wir können ein
Merkmals-Objekt verwenden, wie in Codeblock 20-34.

```rust
# fn main() {
#     let handlers = vec![returns_closure(), returns_initialized_closure(123)];
#     for handler in handlers {
#         let output = handler(5);
#         println!("{output}");
#     }
# }
#
fn returns_closure() -> Box<dyn Fn(i32) -> i32> {
    Box::new(|x| x + 1)
}

fn returns_initialized_closure(init: i32) -> Box<dyn Fn(i32) -> i32> {
    Box::new(move |x| x + init)
}
```

<span class="caption">Codeblock 20-34: Erstellen eines `Vec<T>` von
Funktionsabschlüssen, die durch Funktionen definiert sind, die `Box<dyn Fn>`
zurückgeben, damit sie denselben Typ haben</span>

Dieser Code lässt sich sehr gut kompilieren. Weitere Informationen über
Merkmalsobjekte findest du im Abschnitt [„Verwendung von Merkmals-Objekten zur
Abstraktion über gemeinsames Verhalten“][trait-objects] in Kapitel 18.

Als nächstes wollen wir uns Makros ansehen!

[advanced-traits]: ch20-02-advanced-traits.html
[future-types]: ch17-05-traits-for-async.md#die-merkmale-pin-and-unpin
[closure-types]: ch13-01-closures.html#herleiten-und-annotieren-von-funktionsabschluss-typen
[enum-values]: ch06-01-defining-an-enum.html#werte-in-aufzählungen
[trait-objects]: ch18-02-trait-objects.html
