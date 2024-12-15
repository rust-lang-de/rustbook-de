## Arbeiten mit einer beliebigen Anzahl von Futures

Als wir im vorigen Abschnitt von zwei auf drei Futures umgestellt haben,
mussten wir auch von `join` auf `join3` umstellen. Es wäre lästig, jedes Mal
eine andere Funktion aufrufen zu müssen, wenn wir die Anzahl der Futures, die
wir verbinden wollen, ändern. Glücklicherweise gibt es eine Makroform von
`join`, an die wir eine beliebige Anzahl von Argumenten übergeben können. Es
kümmert sich auch um das Warten auf die Futures. Wir könnten also den Code aus
Codeblock 17-13 umschreiben, um `join!` anstelle von `join3` zu verwenden, wie
in Codeblock 17-14:

<span class="filename">Dateiname: src/main.rs</span>

```rust
# extern crate trpl;
#
# use std::time::Duration;
#
# fn main() {
#     trpl::run(async {
#         let (tx, mut rx) = trpl::channel();
#
#         let tx1 = tx.clone();
#         let tx1_fut = async move {
#             let vals = vec![
#                 String::from("Hallo"),
#                 String::from("aus"),
#                 String::from("dem"),
#                 String::from("Future"),
#             ];
#
#             for val in vals {
#                 tx1.send(val).unwrap();
#                 trpl::sleep(Duration::from_secs(1)).await;
#             }
#         };
#
#         let rx_fut = async {
#             while let Some(value) = rx.recv().await {
#                 println!("Erhalten: '{value}'");
#             }
#         };
#
#         let tx_fut = async move {
#             let vals = vec![
#                 String::from("Weitere"),
#                 String::from("Nachrichten"),
#                 String::from("für"),
#                 String::from("dich"),
#             ];
#
#             for val in vals {
#                 tx.send(val).unwrap();
#                 trpl::sleep(Duration::from_secs(1)).await;
#             }
#         };
#
        trpl::join!(tx1_fut, tx_fut, rx_fut);
#     });
# }
```

<span class="caption">Codeblock 17-14: Verwenden von `join!` zum Warten auf
mehrere Futures</span>

Das ist definitiv eine nette Verbesserung gegenüber der Notwendigkeit, zwischen
`join` und `join3` und `join4` und so weiter zu wechseln! Allerdings
funktioniert auch diese Makroform nur, wenn wir die Anzahl der Futures im
Voraus kennen. In der realen Welt von Rust ist es jedoch ein gängiges Muster,
Futures in eine Kollektion zu geben und dann darauf zu warten, dass einige oder
alle Futures in dieser Kollektion fertig werden.

Um alle Futures in einer Kollektion zu prüfen, müssen wir über *alle* Futures
iterieren und sie verbinden. Die Funktion `trpl::join_all` akzeptiert jeden
Typ, der das Merkmal `Iterator` implementiert, das wir in Kapitel 13
kennengelernt haben, also scheint sie genau das Richtige zu sein. Lass uns
versuchen, unsere Futures in einen Vektor zu packen und `join!` durch
`join_all` zu ersetzen.

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore,does_not_compile
# extern crate trpl;
#
# use std::time::Duration;
#
# fn main() {
#     trpl::run(async {
#         let (tx, mut rx) = trpl::channel();
#
#         let tx1 = tx.clone();
#         let tx1_fut = async move {
#             let vals = vec![
#                 String::from("Hallo"),
#                 String::from("aus"),
#                 String::from("dem"),
#                 String::from("Future"),
#             ];
#
#             for val in vals {
#                 tx1.send(val).unwrap();
#                 trpl::sleep(Duration::from_secs(1)).await;
#             }
#         };
#
#         let rx_fut = async {
#             while let Some(value) = rx.recv().await {
#                 println!("Erhalten: '{value}'");
#             }
#         };
#
#         let tx_fut = async move {
#             let vals = vec![
#                 String::from("Weitere"),
#                 String::from("Nachrichten"),
#                 String::from("für"),
#                 String::from("dich"),
#             ];
#
#             for val in vals {
#                 tx.send(val).unwrap();
#                 trpl::sleep(Duration::from_secs(1)).await;
#             }
#         };
#
        let futures = vec![tx1_fut, rx_fut, tx_fut];

        trpl::join_all(futures).await;
#     });
# }
```

<span class="caption">Codeblock 17-15: Speichern anonymer Futures in einem
Vektor und Aufrufen von `join_all`</span>

Leider lässt sich das nicht kompilieren. Stattdessen erhalten wir diesen
Fehler:

```text
error[E0308]: mismatched types
  --> src/main.rs:45:37
   |
10 |         let tx1_fut = async move {
   |                       ---------- the expected `async` block
...
24 |         let rx_fut = async {
   |                      ----- the found `async` block
...
45 |         let futures = vec![tx1_fut, rx_fut, tx_fut];
   |                                     ^^^^^^ expected `async` block, found a different `async` block
   |
   = note: expected `async` block `{async block@src/main.rs:10:23: 10:33}`
              found `async` block `{async block@src/main.rs:24:22: 24:27}`
   = note: no two async blocks, even if identical, have the same type
   = help: consider pinning your async block and casting it to a trait object
```

Das mag überraschend sein. Schließlich gibt keiner von ihnen etwas zurück,
sodass jeder Block ein `Future<Output = ()>` erzeugt. Allerdings ist `Future`
ein Merkmal, kein konkreter Typ. Die konkreten Typen sind die einzelnen
Datenstrukturen, die der Compiler für asynchrone Blöcke erzeugt. Man kann nicht
zwei verschiedene handgeschriebene Strukturen in einen `Vec` packen, und
dasselbe gilt für die verschiedenen vom Compiler erzeugten Strukturen.

Damit dies funktioniert, müssen wir *Merkmalsobjekte* (trait objects)
verwenden, wie wir es in [„Rückgabe von Fehlern aus der Funktion `run`“][dyn]
in Kapitel 12 getan haben. (Wir werden Merkmalsobjekte im Detail in Kapitel 18
behandeln.) Die Verwendung von Merkmalsobjekte ermöglicht es uns, alle anonymen
Futures, die von diesen Typen erzeugt werden, als denselben Typ zu behandeln,
da alle von ihnen das Merkmal „Future“ implementieren.

> Anmerkung: In Kapitel 8 haben wir eine andere Möglichkeit besprochen, mehrere
> Typen in einen `Vec` aufzunehmen: Die Verwendung eines Enums, um jeden der
> verschiedenen Typen, die im Vektor vorkommen können, zu repräsentieren. Das
> können wir hier allerdings nicht tun. Zum einen haben wir keine Möglichkeit,
> die verschiedenen Typen zu benennen, da sie anonym sind. Zum anderen war der
> Grund, warum wir uns überhaupt für einen Vektor und `join_all` entschieden
> haben, dass wir mit einer dynamischen Kollektion von Futures arbeiten
> wollten, von denen wir bis zur Laufzeit nicht wissen, was sie sein werden.

Wir beginnen, indem wir jedes Future in `vec!` in eine `Box::new` verpacken,
wie in Codeblock 17-16 gezeigt.

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore,does_not_compile
# extern crate trpl;
#
# use std::time::Duration;
#
# fn main() {
#     trpl::run(async {
#         let (tx, mut rx) = trpl::channel();
#
#         let tx1 = tx.clone();
#         let tx1_fut = async move {
#             let vals = vec![
#                 String::from("Hallo"),
#                 String::from("aus"),
#                 String::from("dem"),
#                 String::from("Future"),
#             ];
#
#             for val in vals {
#                 tx1.send(val).unwrap();
#                 trpl::sleep(Duration::from_secs(1)).await;
#             }
#         };
#
#         let rx_fut = async {
#             while let Some(value) = rx.recv().await {
#                 println!("Erhalten: '{value}'");
#             }
#         };
#
#         let tx_fut = async move {
#             let vals = vec![
#                 String::from("Weitere"),
#                 String::from("Nachrichten"),
#                 String::from("für"),
#                 String::from("dich"),
#             ];
#
#             for val in vals {
#                 tx.send(val).unwrap();
#                 trpl::sleep(Duration::from_secs(1)).await;
#             }
#         };
#
        let futures =
            vec![Box::new(tx1_fut), Box::new(rx_fut), Box::new(tx_fut)];

        trpl::join_all(futures).await;
#     });
# }
```

<span class="caption">Codeblock 17-16: Versuch `Box::new` zu verwenden, um die
Typen der Futures in einem `Vec` anzuordnen</span>

Leider lässt sich das immer noch nicht kompilieren. Tatsächlich haben wir den
gleichen grundlegenden Fehler wie zuvor, aber wir bekommen einen für den
zweiten und dritten Aufruf von `Box::new`, und wir bekommen auch neue Fehler,
die sich auf das Merkmal `Unpin` beziehen. Wir werden gleich auf die
`Unpin`-Fehler zurückkommen. Lass uns zunächst die Typ-Fehler bei den
`Box::new`-Aufrufen beheben, indem wir den Typ der Variable `futures` explizit
annotieren:

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore,does_not_compile
# extern crate trpl;
#
# use std::{future::Future, time::Duration};
#
# fn main() {
#     trpl::run(async {
#         let (tx, mut rx) = trpl::channel();
#
#         let tx1 = tx.clone();
#         let tx1_fut = async move {
#             let vals = vec![
#                 String::from("Hallo"),
#                 String::from("aus"),
#                 String::from("dem"),
#                 String::from("Future"),
#             ];
#
#             for val in vals {
#                 tx1.send(val).unwrap();
#                 trpl::sleep(Duration::from_secs(1)).await;
#             }
#         };
#
#         let rx_fut = async {
#             while let Some(value) = rx.recv().await {
#                 println!("Erhalten: '{value}'");
#             }
#         };
#
#         let tx_fut = async move {
#             let vals = vec![
#                 String::from("Weitere"),
#                 String::from("Nachrichten"),
#                 String::from("für"),
#                 String::from("dich"),
#             ];
#
#             for val in vals {
#                 tx.send(val).unwrap();
#                 trpl::sleep(Duration::from_secs(1)).await;
#             }
#         };
#
        let futures: Vec<Box<dyn Future<Output = ()>>> =
            vec![Box::new(tx1_fut), Box::new(rx_fut), Box::new(tx_fut)];

#         trpl::join_all(futures).await;
#     });
# }
```

<span class="caption">Codeblock 17-17: Beheben der restlichen Typfehler durch
Verwenden einer expliziten Typdeklaration</span>

Der Typ, den wir hier schreiben mussten, ist ein wenig kompliziert, also gehen
wir ihn Stück für Stück durch:

* Der innerste Typ ist das Future selbst. Wir geben explizit an, dass das
  Ergebnis des Future der Einheitstyp `()` ist, indem wir `Future<Output = ()>`
  schreiben.
* Dann annotieren wir das Merkmal mit `dyn`, um es als dynamisch zu
  kennzeichnen.
* Die gesamte Merkmals-Referenz wird in eine `Box` gepackt.
* Schließlich geben wir explizit an, dass `futures` ein `Vec` ist, der diese
  Elemente enthält.

Das hat bereits einen großen Unterschied gemacht. Wenn wir nun den Compiler
laufen lassen, haben wir nur noch die `Unpin`-Fehler. Obwohl es drei davon
gibt, ist ihr Inhalt sehr ähnlich.

```text
error[E0308]: mismatched types
   --> src/main.rs:46:46
    |
10  |         let tx1_fut = async move {
    |                       ---------- the expected `async` block
...
24  |         let rx_fut = async {
    |                      ----- the found `async` block
...
46  |             vec![Box::new(tx1_fut), Box::new(rx_fut), Box::new(tx_fut)];
    |                                     -------- ^^^^^^ expected `async` block, found a different `async` block
    |                                     |
    |                                     arguments to this function are incorrect
    |
    = note: expected `async` block `{async block@src/main.rs:10:23: 10:33}`
               found `async` block `{async block@src/main.rs:24:22: 24:27}`
    = note: no two async blocks, even if identical, have the same type
    = help: consider pinning your async block and casting it to a trait object
note: associated function defined here
   --> file:///home/.rustup/toolchains/1.82/lib/rustlib/src/rust/library/alloc/src/boxed.rs:255:12
    |
255 |     pub fn new(x: T) -> Self {
    |            ^^^

error[E0308]: mismatched types
   --> src/main.rs:46:64
    |
10  |         let tx1_fut = async move {
    |                       ---------- the expected `async` block
...
30  |         let tx_fut = async move {
    |                      ---------- the found `async` block
...
46  |             vec![Box::new(tx1_fut), Box::new(rx_fut), Box::new(tx_fut)];
    |                                                       -------- ^^^^^^ expected `async` block, found a different `async` block
    |                                                       |
    |                                                       arguments to this function are incorrect
    |
    = note: expected `async` block `{async block@src/main.rs:10:23: 10:33}`
               found `async` block `{async block@src/main.rs:30:22: 30:32}`
    = note: no two async blocks, even if identical, have the same type
    = help: consider pinning your async block and casting it to a trait object
note: associated function defined here
   --> file:///home/.rustup/toolchains/1.82/lib/rustlib/src/rust/library/alloc/src/boxed.rs:255:12
    |
255 |     pub fn new(x: T) -> Self {
    |            ^^^

error[E0277]: `{async block@src/main.rs:10:23: 10:33}` cannot be unpinned
   --> src/main.rs:48:24
    |
48  |         trpl::join_all(futures).await;
    |         -------------- ^^^^^^^ the trait `Unpin` is not implemented for `{async block@src/main.rs:10:23: 10:33}`, which is required by `Box<{async block@src/main.rs:10:23: 10:33}>: Future`
    |         |
    |         required by a bound introduced by this call
    |
    = note: consider using the `pin!` macro
            consider using `Box::pin` if you need to access the pinned value outside of the current scope
    = note: required for `Box<{async block@src/main.rs:10:23: 10:33}>` to implement `Future`
note: required by a bound in `join_all`
   --> file:///home/.cargo/registry/src/index.crates.io-6f17d22bba15001f/futures-util-0.3.30/src/future/join_all.rs:105:14
    |
102 | pub fn join_all<I>(iter: I) -> JoinAll<I::Item>
    |        -------- required by a bound in this function
...
105 |     I::Item: Future,
    |              ^^^^^^ required by this bound in `join_all`

error[E0277]: `{async block@src/main.rs:10:23: 10:33}` cannot be unpinned
  --> src/main.rs:48:9
   |
48 |         trpl::join_all(futures).await;
   |         ^^^^^^^^^^^^^^^^^^^^^^^ the trait `Unpin` is not implemented for `{async block@src/main.rs:10:23: 10:33}`, which is required by `Box<{async block@src/main.rs:10:23: 10:33}>: Future`
   |
   = note: consider using the `pin!` macro
           consider using `Box::pin` if you need to access the pinned value outside of the current scope
   = note: required for `Box<{async block@src/main.rs:10:23: 10:33}>` to implement `Future`
note: required by a bound in `futures_util::future::join_all::JoinAll`
  --> file:///home/.cargo/registry/src/index.crates.io-6f17d22bba15001f/futures-util-0.3.30/src/future/join_all.rs:29:8
   |
27 | pub struct JoinAll<F>
   |            ------- required by a bound in this struct
28 | where
29 |     F: Future,
   |        ^^^^^^ required by this bound in `JoinAll`

error[E0277]: `{async block@src/main.rs:10:23: 10:33}` cannot be unpinned
  --> src/main.rs:48:33
   |
48 |         trpl::join_all(futures).await;
   |                                 ^^^^^ the trait `Unpin` is not implemented for `{async block@src/main.rs:10:23: 10:33}`, which is required by `Box<{async block@src/main.rs:10:23: 10:33}>: Future`
   |
   = note: consider using the `pin!` macro
           consider using `Box::pin` if you need to access the pinned value outside of the current scope
   = note: required for `Box<{async block@src/main.rs:10:23: 10:33}>` to implement `Future`
note: required by a bound in `futures_util::future::join_all::JoinAll`
  --> file:///home/.cargo/registry/src/index.crates.io-6f17d22bba15001f/futures-util-0.3.30/src/future/join_all.rs:29:8
   |
27 | pub struct JoinAll<F>
   |            ------- required by a bound in this struct
28 | where
29 |     F: Future,
   |        ^^^^^^ required by this bound in `JoinAll`
```

Das ist *viel* zu verdauen, also lass uns das auseinandernehmen. Der erste Teil
der Meldung sagt uns, dass der erste asynchrone Block (`src/main.rs:8:23:
 20:10`) das Merkmal `Unpin` nicht implementiert, und schlägt vor, `pin!` oder
`Box::pin` zu verwenden, um das Problem zu lösen. Später in diesem Kapitel
werden wir uns mit ein paar mehr Details über `Pin` und `Unpin` beschäftigen.
Für den Moment können wir jedoch einfach dem Rat des Compilers folgen, um uns
aus der Patsche zu helfen! In Codeblock 17-18 beginnen wir damit, die
Typ-Annotation für `futures` zu aktualisieren, wobei jede `Box` mit einem `Pin`
umschlossen wird. Zweitens verwenden wir `Box::pin` bei den Futures.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# extern crate trpl;
#
# use std::{
#     future::Future,
#     pin::{pin, Pin},
#     time::Duration,
# };
#
# fn main() {
#     trpl::run(async {
#         let (tx, mut rx) = trpl::channel();
#
#         let tx1 = tx.clone();
#         let tx1_fut = pin!(async move {
#             let vals = vec![
#                 String::from("Hallo"),
#                 String::from("aus"),
#                 String::from("dem"),
#                 String::from("Future"),
#             ];
#
#             for val in vals {
#                 tx1.send(val).unwrap();
#                 trpl::sleep(Duration::from_secs(1)).await;
#             }
#         });
#
#         let rx_fut = pin!(async {
#             while let Some(value) = rx.recv().await {
#                 println!("Erhalten: '{value}'");
#             }
#         });
#
#         let tx_fut = pin!(async move {
#             let vals = vec![
#                 String::from("Weitere"),
#                 String::from("Nachrichten"),
#                 String::from("für"),
#                 String::from("dich"),
#             ];
#
#             for val in vals {
#                 tx.send(val).unwrap();
#                 trpl::sleep(Duration::from_secs(1)).await;
#             }
#         });
#
        let futures: Vec<Pin<Box<dyn Future<Output = ()>>>> =
            vec![Box::pin(tx1_fut), Box::pin(rx_fut), Box::pin(tx_fut)];

#         trpl::join_all(futures).await;
#     });
# }
```

<span class="caption">Codeblock 17-18: Verwenden von `Pin` und `Box::pin` zum
Überprüfen des Typs `Vec`</span>

Wenn wir dies kompilieren und ausführen, erhalten wir endlich die erhoffte Ausgabe:

```text
Erhalten: 'Hallo'
Erhalten: 'Weitere'
Erhalten: 'aus'
Erhalten: 'Nachrichten'
Erhalten: 'dem'
Erhalten: 'für'
Erhalten: 'Future'
Erhalten: 'dich'
```

Puh!

Wir können hier noch ein bisschen mehr erforschen. Zum einen bringt die
Verwendung von `Pin<Box<T>>` ein wenig zusätzlichen Overhead mit sich, da wir
diese Futures mit `Box` auf den Haldenspeicher (heap) legen &ndash; und das tun
wir nur, um die Typen in eine Reihe zu bringen. Wir *brauchen* die
Haldenspeicher-Allokation eigentlich nicht: Diese Futures sind lokal zu dieser
speziellen Funktion. Wie oben erwähnt, ist `Pin` selbst ein Wrapper-Typ, sodass
wir den Vorteil haben, einen einzigen Typ in `Vec` zu haben &ndash; der
ursprüngliche Grund, warum wir uns für `Box` entschieden haben &ndash; ohne
eine Haldenspeicher-Allokation durchzuführen. Wir können `Pin` direkt mit jedem
Future verwenden, indem wir das Makro `std::pin::pin` benutzen.

Wir müssen jedoch immer noch explizit den Typ der `Pin`-Referenz angeben, da
Rust sonst nicht weiß, wie es diese als dynamische Merkmals-Objekte
interpretieren soll, was wir im `Vec` benötigen. Wir verwenden `pin!` daher für
jedes Future, und definieren `futures` als `Vec` wie in Codeblock 17-19.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# extern crate trpl;
#
# use std::{
#     future::Future,
#     pin::{pin, Pin},
#     time::Duration,
# };
#
# fn main() {
#     trpl::run(async {
#         let (tx, mut rx) = trpl::channel();
#
#         let tx1 = tx.clone();
        let tx1_fut = pin!(async move {
            // --abschneiden--
#             let vals = vec![
#                 String::from("Hallo"),
#                 String::from("aus"),
#                 String::from("dem"),
#                 String::from("Future"),
#              ];
#
#              for val in vals {
#                  tx1.send(val).unwrap();
#                  trpl::sleep(Duration::from_secs(1)).await;
#              }
        });

        let rx_fut = pin!(async {
            // --abschneiden--
#              while let Some(value) = rx.recv().await {
#                  println!("Erhalten: '{value}'");
#              }
        });

        let tx_fut = pin!(async move {
            // --abschneiden--
#             let vals = vec![
#                 String::from("Weitere"),
#                 String::from("Nachrichten"),
#                 String::from("für"),
#                 String::from("dich"),
#             ];
# 
#             for val in vals {
#                 tx.send(val).unwrap();
#                 trpl::sleep(Duration::from_secs(1)).await;
#             }
        });

        let futures: Vec<Pin<&mut dyn Future<Output = ()>>> =
            vec![tx1_fut, rx_fut, tx_fut];
#
#         trpl::join_all(futures).await;
#     });
# }
```

<span class="caption">Codeblock 17-19: Direktes Verwenden von `Pin` mit dem
Makro `pin!` zum Vermeiden unnötiger Haldenspeicher-Allokation</span>

Wir sind so weit gekommen, indem wir die Tatsache ignoriert haben, dass wir
verschiedene `Output`-Typen haben könnten. In Codeblock 17-20 zum Beispiel
implementiert das anonyme Future für `a` den Typ `Future<Output = u32>`, das
anonyme Future für `b` implementiert `Future<Output = &str>`, und das anonyme
Future für `c` implementiert `Future<Output = bool>`.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# extern crate trpl;
#
# fn main() {
#     trpl::run(async {
        let a = async { 1u32 };
        let b = async { "Hallo!" };
        let c = async { true };

        let (a_result, b_result, c_result) = trpl::join!(a, b, c);
        println!("{a_result}, {b_result}, {c_result}");
#     });
# }
```

<span class="caption">Codeblock 17-20: Drei Futures mit unterschiedlichen
Typen</span>

Wir können `trpl::join!` verwenden, um auf sie zu warten, weil es dir erlaubt,
mehrere Future-Typen zu übergeben und ein Tupel dieser Typen zu erzeugen. Wir
können *nicht* `trpl::join_all` verwenden, weil es voraussetzt, dass die
übergebenen Futures alle denselben Typ haben. Erinnere dich, dieser Fehler war
es, der uns zu diesem Abenteuer mit `Pin` gebracht hat!

Dies ist eine grundlegende Abwägung: Wir können entweder eine dynamische Anzahl
von Futures mit `join_all` behandeln, solange sie alle denselben Typ haben,
oder wir können eine bestimmte Anzahl von Futures mit den Funktionen `join`
oder dem Makro `join!` behandeln, auch wenn sie unterschiedliche Typen haben.
Das ist das Gleiche wie mit jedem anderen Typ in Rust. Futures sind nichts
Besonderes, auch wenn wir eine nette Syntax für die Arbeit mit ihnen haben, und
das ist eine gute Sache.

### Future-Wettlauf

Wenn wir auf Futures mit `join` warten, müssen *alle* von ihnen beendet sein,
bevor wir weitermachen. Manchmal müssen jedoch nur *einige* Futures aus einer
Menge fertig sein, bevor wir weitermachen &ndash; ähnlich wie bei einem
Wettlauf zwischen zwei Futures.

In Codeblock 17-21 verwenden wir wieder `trpl::race`, um zwei Futures `slow`
und `fast` gegeneinander laufen zu lassen. Jedes gibt eine Nachricht aus, wenn
es startet, pausiert für eine gewisse Zeit, indem es `sleep` aufruft und
wartet, und gibt dann eine weitere Nachricht aus, wenn es fertig ist. Dann
übergeben wir beide an `trpl::race` und warten, bis eines von ihnen fertig ist.
(Das Ergebnis ist nicht allzu überraschend: `fast` gewinnt!) Anders als bei der
Verwendung von `race` in [Unser erstes asynchrones Programm][async-program]
ignorieren wir hier einfach die `Either`-Instanz, die es zurückgibt, da das
gesamte interessante Verhalten im Rumpf der asynchronen Blöcke stattfindet.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# extern crate trpl;
#
# use std::time::Duration;
#
# fn main() {
#     trpl::run(async {
        let slow = async {
            println!("'slow' gestartet.");
            trpl::sleep(Duration::from_millis(100)).await;
            println!("'slow' beendet.");
        };

        let fast = async {
            println!("'fast' gestartet.");
            trpl::sleep(Duration::from_millis(50)).await;
            println!("'fast' beendet.");
        };

        trpl::race(slow, fast).await;
#     });
# }
```

<span class="caption">Codeblock 17-21: Verwenden von `race`, um das Ergebnis
des zuerst beendeten Future zu erhalten</span>

Beachte, dass sich die Reihenfolge der „gestarteten“ Meldungen ändert, wenn du
die Reihenfolge der Argumente in `race` umdrehst, obwohl das Future `fast`
immer zuerst fertig wird. Das liegt daran, dass die Implementierung dieser
speziellen Funktion `race` nicht fair ist. Sie führt die als Argumente
übergebenen Futures immer in der Reihenfolge aus, in der sie übergeben werden.
Andere Implementierungen *sind* fair und wählen zufällig, welches Future zuerst
abgefragt wird. Unabhängig davon, ob die Implementierung von `race` fair ist,
wird *eines* der Futures bis zum ersten `await` in seinem Rumpf laufen, bevor
eine andere Aufgabe beginnen kann.

Erinnere dich an [Unser erstes asynchrones Programm][async-program], bei dem
Rust der Laufzeitumgebung an jedem await-Punkt die Möglichkeit gibt, die
Aufgabe anzuhalten und zu einer anderen zu wechseln, wenn das zu erwartende
Future nicht fertig ist. Der umgekehrte Fall ist ebenfalls wahr: Rust hält
asynchrone Blöcke *nur* an einem await-Punkt an und übergibt die Kontrolle die
Laufzeitumgebung. Alles zwischen den await-Punkten ist synchron.

Das heißt, wenn du eine Menge Arbeit in einem asynchronen Block ohne einen
await-Punkt erledigst, blockiert dieses Future alle anderen Futures an ihrem
Fortschritt. Dies wird manchmal auch als ein Future lässt ein anderes Future
*verhungern* bezeichnet. In manchen Fällen mag das keine große Sache sein. Wenn
du jedoch eine teure Initialisierung oder eine langwierige Arbeit durchführst,
oder wenn du ein Future hast, das eine bestimmte Aufgabe auf unbestimmte Zeit
ausführt, musst du darüber nachdenken, wann und wo du die Kontrolle an die
Laufzeitumgebung zurückgibst.

Aber *wie* würdest du in diesen Fällen die Kontrolle an die Laufzeitumgebung
zurückgeben?

### Abgeben (yielding)

Simulieren wir einen langlaufenden Ablauf. Codeblock 17-22 führt eine Funktion
`slow` ein. Sie verwendet `std::thread::sleep` anstelle von `trpl::sleep`,
sodass der Aufruf von `slow` den aktuellen Strang für eine bestimmte Anzahl von
Millisekunden blockiert. Wir können `slow` benutzen, um reale Abläufe zu
simulieren, die sowohl langwierig als auch blockierend sind.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# extern crate trpl;
#
# use std::{thread, time::Duration};
#
# fn main() {
#     trpl::run(async {
#         // Wir werden hier `slow` aufrufen
#     });
# }
#
fn slow(name: &str, ms: u64) {
    thread::sleep(Duration::from_millis(ms));
    println!("'{name}' ist für {ms}ms gelaufen");
}
```

<span class="caption">Codeblock 17-22: Verwenden von `thread::sleep` zum
Simulieren langsamer Abläufe</span>

In Codeblock 17-23 verwenden wir `slow`, um diese Art von CPU-gebundener Arbeit
in einem Paar von Futures zu emulieren. Zunächst gibt jedes Future die
Kontrolle erst nach einer Reihe von langsamen Abläufen an die Laufzeitumgebung
zurück.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# extern crate trpl;
#
# use std::{thread, time::Duration};
#
# fn main() {
#     trpl::run(async {
        let a = async {
            println!("'a' gestartet.");
            slow("a", 30);
            slow("a", 10);
            slow("a", 20);
            trpl::sleep(Duration::from_millis(50)).await;
            println!("'a' beendet.");
        };

        let b = async {
            println!("'b' gestartet.");
            slow("b", 75);
            slow("b", 10);
            slow("b", 15);
            slow("b", 350);
            trpl::sleep(Duration::from_millis(50)).await;
            println!("'b' beendet.");
        };

        trpl::race(a, b).await;
#     });
# }
#
# fn slow(name: &str, ms: u64) {
#     thread::sleep(Duration::from_millis(ms));
#     println!("'{name}' ist für {ms}ms gelaufen");
# }
```

<span class="caption">Codeblock 17-23: Verwenden von `thread::sleep` zum
Simulieren langsamer Abläufe</span>

Wenn du dies ausführst, erhältst du diese Ausgabe:

```text
'a' gestartet.
'a' ran for 30ms
'a' ran for 10ms
'a' ran for 20ms
'b' gestartet.
'b' ran for 75ms
'b' ran for 10ms
'b' ran for 15ms
'b' ist für 350ms gelaufen
'a' beendet.
```

Wie in unserem früheren Beispiel wird `race` immer noch beendet, sobald `a`
fertig ist. Es gibt jedoch keine Abwechslung zwischen den beiden Futures. Das
Future `a` erledigt seine gesamte Arbeit, bis auf den Aufruf von `trpl::sleep`
gewartet wird, dann erledigt das Future `b` seine gesamte Arbeit, bis auch dort
auf den Aufruf von `trpl::sleep` gewartet wird, und dann wird das Future `a`
beendet. Damit beide Futures während ihre langsamen Vorgänge Fortschritte
machen können, brauchen wir await-Punkte, damit wir die Kontrolle an die
Laufzeitumgebung zurückgeben können. Das heißt, wir brauchen etwas, auf das wir
warten können!

Wir können diese Art der Übergabe bereits in Codeblock 17-23 sehen: Wenn wir
`trpl::sleep` am Ende des Futures `a` entfernen, würde es fertig werden, ohne
dass das Future `b` *überhaupt* läuft. Vielleicht könnten wir die Funktion
`sleep` als Ausgangspunkt verwenden?

<span class="filename">Dateiname: src/main.rs</span>

```rust
# extern crate trpl;
#
# use std::{thread, time::Duration};
#
# fn main() {
#     trpl::run(async {
        let one_ms = Duration::from_millis(1);

        let a = async {
            println!("'a' gestartet.");
            slow("a", 30);
            trpl::sleep(one_ms).await;
            slow("a", 10);
            trpl::sleep(one_ms).await;
            slow("a", 20);
            trpl::sleep(one_ms).await;
            println!("'a' beendet.");
        };

        let b = async {
            println!("'b' gestartet.");
            slow("b", 75);
            trpl::sleep(one_ms).await;
            slow("b", 10);
            trpl::sleep(one_ms).await;
            slow("b", 15);
            trpl::sleep(one_ms).await;
            slow("b", 35);
            trpl::sleep(one_ms).await;
            println!("'b' beendet.");
        };
#
#         trpl::race(a, b).await;
#     });
# }
#
# fn slow(name: &str, ms: u64) {
#     thread::sleep(Duration::from_millis(ms));
#     println!("'{name}' ist für {ms}ms gelaufen");
# }
```

<span class="caption">Codeblock 17-24: Verwenden von `sleep`, um Vorgänge zu
unterbrechen</span>

In Codeblock 17-24 fügen wir Aufrufe von `trpl::sleep` mit await-Punkten
zwischen den Aufrufen von `slow` ein. Nun wechseln die beiden Futures ihre
Arbeit ab:

```text
'a' gestartet.
'a' ist für 30ms gelaufen
'b' gestartet.
'b' ist für 75ms gelaufen
'a' ist für 10ms gelaufen
'b' ist für 10ms gelaufen
'a' ist für 20ms gelaufen
'b' ist für 15ms gelaufen
'a' beendet.
```

Das Future `a` läuft noch eine Weile, bevor es die Kontrolle an `b` abgibt,
weil es `slow` aufruft, bevor es `trpl::sleep` aufruft. Aber danach wechseln
sich die Futures jedes Mal ab, wenn eines von ihnen einen await-Punkt erreicht.
In diesem Fall haben wir das nach jedem Aufruf von `slow` gemacht, aber wir
könnten die Arbeit so aufteilen, wie es für uns am sinnvollsten ist.

Wir wollen hier aber nicht wirklich *schlafen*: Wir wollen so schnell wie
möglich vorankommen. Wir müssen nur die Kontrolle an die Laufzeitumgebung
abgeben. Das können wir direkt tun, indem wir die Funktion `yield_now`
verwenden. In Codeblock 17-25 ersetzen wir all diese Aufrufe von `sleep` durch
`yield_now`.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# extern crate trpl;
#
# use std::{thread, time::Duration};
#
# fn main() {
#     trpl::run(async {
        let a = async {
            println!("'a' gestartet.");
            slow("a", 30);
            trpl::yield_now().await;
            slow("a", 10);
            trpl::yield_now().await;
            slow("a", 20);
            trpl::yield_now().await;
            println!("'a' beendet.");
        };

        let b = async {
            println!("'b' gestartet.");
            slow("b", 75);
            trpl::yield_now().await;
            slow("b", 10);
            trpl::yield_now().await;
            slow("b", 15);
            trpl::yield_now().await;
            slow("b", 35);
            trpl::yield_now().await;
            println!("'b' beendet.");
        };
#
#         trpl::race(a, b).await;
#     });
# }
#
# # fn slow(name: &str, ms: u64) {
#     thread::sleep(Duration::from_millis(ms));
#     println!("'{name}' ist für {ms}ms gelaufen");
# }
```

<span class="caption">Codeblock 17-25: Verwenden von `yield_now`, um Vorgänge
anzuhalten</span>

Dies ist sowohl klarer als auch wesentlich schneller als `sleep`, weil
Zeitgeber wie `sleep` oft Grenzen haben, wie granular sie sein können. Die
Version von `sleep`, die wir benutzen, wird zum Beispiel immer mindestens eine
Millisekunde lang schlafen, selbst wenn wir ihr eine `Duration` von einer
Nanosekunde übergeben. Nochmals, moderne Computer sind *schnell*: Sie können
eine Menge in einer Millisekunde tun!

Du kannst dich selbst davon überzeugen, indem du einen kleinen Benchmark wie in
Codeblock 17-26 erstellst. (Dies ist kein besonders strenger Weg, um
Leistungstests durchzuführen, aber es reicht aus, um den Unterschied hier zu
zeigen.) Hier überspringen wir die Statusausgabe, übergeben eine `Duration` von
einer Nanosekunde an `trpl::sleep` und lassen jedes Future für sich laufen,
ohne zwischen den Futures zu wechseln. Dann lassen wir 1.000 Iterationen laufen
und sehen, wie lange das Future mit `trpl::sleep` im Vergleich zum Future mit
`trpl::yield_now` braucht.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# extern crate trpl;
#
# use std::time::{Duration, Instant};
#
# fn main() {
#     trpl::run(async {
        let one_ns = Duration::from_nanos(1);
        let start = Instant::now();
        async {
            for _ in 1..1000 {
                trpl::sleep(one_ns).await;
            }
        }
        .await;
        let time = Instant::now() - start;
        println!(
            "'sleep'-Version beendet nach {} Sekunden.",
            time.as_secs_f32()
        );

        let start = Instant::now();
        async {
            for _ in 1..1000 {
                trpl::yield_now().await;
            }
        }
        .await;
        let time = Instant::now() - start;
        println!(
            "'yield'-Version beendet nach {} Sekunden.",
            time.as_secs_f32()
        );
#     });
# }
```

<span class="caption">Codeblock 17-26: Vergleich der Performanz von `sleep` und
`yield_now`</span>

Die Version mit `yield_now` ist *viel* schneller!

Das bedeutet, dass async sogar für rechengebundene Aufgaben nützlich sein kann,
je nachdem, was dein Programm sonst noch tut, weil es ein nützliches Werkzeug
für die Strukturierung der Beziehungen zwischen verschiedenen Teilen des
Programms ist. Es handelt sich um eine Form von *kooperativem Multitasking*,
bei dem jedes Future die Möglichkeit hat zu bestimmen, wann es die Kontrolle
mittels await-Punkte abgibt. Jedes Future hat daher auch die Verantwortung, ein
zu langes Blockieren zu vermeiden. In einigen Rust-basierten eingebetteten
Betriebssystemen ist dies die *einzige* Art von Multitasking!

In der Praxis wirst du natürlich nicht nach jeder einzelnen Zeile
einen await-Punkt einfügen. Obwohl die Abgabe der Kontrolle auf diese Weise
relativ kostengünstig ist, ist sie nicht kostenlos! In vielen Fällen kann der
Versuch, eine rechengebundene Aufgabe zu unterbrechen, sie erheblich langsamer
machen, sodass es manchmal für die *gesamte* Performanz besser ist, eine
Operation kurzzeitig zu blockieren. Du solltest immer messen, um die
tatsächlichen Leistungsengpässe deines Codes zu finden. Die zugrundeliegende
Dynamik solltest du immer im Hinterkopf haben, wenn du feststellst, dass viele
Vorgänge seriell ausgeführt werde, von denen du erwartet hast, dass sie
nebenläufig ausgeführt werden!

### Eigene Async-Abstraktionen erstellen

Wir können auch Futures kombinieren, um neue Muster zu schaffen. Zum Beispiel
können wir eine Funktion `timeout` mit bereits vorhandenen asynchronen
Bausteinen erstellen. Wenn wir fertig sind, ist das Ergebnis ein weiterer
Baustein, mit dem wir weitere asynchrone Abstraktionen aufbauen können.

Codeblock 17-27 zeigt die erwartete Arbeitsweise von `timeout` bei einem
langsamen Future.

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore
# extern crate trpl;
#
# use std::time::Duration;
#
# fn main() {
#     trpl::run(async {
        let slow = async {
            trpl::sleep(Duration::from_millis(100)).await;
            "Bin fertig!"
        };

        match timeout(slow, Duration::from_millis(10)).await {
            Ok(message) => println!("Erfolgreich mit '{message}'"),
            Err(duration) => {
                println!("Fehlgeschlagen nach {} Sekunden", duration.as_secs())
            }
        }
#     });
# }
```

<span class="caption">Codeblock 17-27: Verwendeng unseres imaginären `timeout`,
um eine langsame Operation mit einem Zeitlimit durchzuführen</span>

Lass es uns implementieren! Denken wir zunächst über die API für `timeout`
nach:

* Es muss selbst eine asynchrone Funktion sein, damit wir auf es warten können.
* Sein erster Parameter sollte ein ausführbares Future sein. Wir können es
  generisch machen, damit es mit jedem Future funktioniert.
* Der zweite Parameter ist die maximale Wartezeit. Wenn wir eine `Duration`
  verwenden, wird es einfach sein, ihn an `trpl::sleep` weiterzureichen.
* Es sollte ein `Result` zurückgeben. Wenn das Future erfolgreich beendet wird,
  ist das `Result` ein `Ok` mit dem vom Future erzeugten Wert. Wenn das
  Zeitlimit zuerst erreicht wird, wird `Result` ein `Err` mit der Wartedauer
  sein.

Codeblock 17-28 zeigt diese Deklaration.

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore
# extern crate trpl;
#
# use std::{future::Future, time::Duration};
#
# fn main() {
#     trpl::run(async {
#         let slow = async {
#             trpl::sleep(Duration::from_secs(5)).await;
#             "Bin fertig"
#         };
#
#         match timeout(slow, Duration::from_millis(10)).await {
#             Ok(message) => println!("Erfolgreich mit '{message}'"),
#             Err(duration) => {
#                 println!("Fehlgeschlagen nach {} Sekunden", duration.as_secs())
#             }
#         }
#     });
# }
#
async fn timeout<F: Future>(
    future_to_try: F,
    max_time: Duration,
) -> Result<F::Output, Duration> {
    // Hier kommt die Implementierung hin
}
```

<span class="caption">Codeblock 17-28: Definieren der Signatur von
`timeout`</span>

Damit sind unsere Ziele für die Typen erfüllt. Denken wir nun über das
*Verhalten* nach, das wir brauchen: Wir wollen Die Dauer des übergebenen Future
überwachen. Wir können mit `trpl::sleep` einen Timer aus der Dauer machen und
`trpl::race` verwenden, um mit diesem Timer das übergebene Future überwachen.

Wir wissen auch, dass `race` nicht fair ist und die Argumente in der
Reihenfolge abfragt, in der sie übergeben werden. Daher übergeben wir
`future_to_try` zuerst an `race`, sodass es eine Chance bekommt, auch dann
fertig zu werden, wenn `max_time` eine sehr kurze Dauer hat. Wenn
`future_to_try` zuerst fertig wird, wird `race` den Wert `Left` mit der
Ausgabe von `future` zurückgeben. Wenn `timer` zuerst fertig wird, gibt
`race` den Wert `Right` mit der Ausgabe des Timers von `()` zurück.

In Codeblock 17-29 gleichen wir das Ergebnis des Wartens auf `trpl::race` ab.
Wenn `Future_to_try` erfolgreich war und wir `Left(output)` erhalten, geben wir
`Ok(output)` zurück. Wenn stattdessen der Sleep-Timer abgelaufen ist und wir
`Right(())` erhalten, ignorieren wir der Wert `()` mit `_` und geben
stattdessen `Err(max_time)` zurück.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# extern crate trpl;
#
# use std::{future::Future, time::Duration};
#
use trpl::Either;

// --abschneiden--
#
# fn main() {
#     trpl::run(async {
#         let slow = async {
#             trpl::sleep(Duration::from_secs(5)).await;
#             "Bin fertig"
#         };
#
#         match timeout(slow, Duration::from_secs(2)).await {
#             Ok(message) => println!("Erfolgreich mit '{message}'"),
#             Err(duration) => {
#                 println!("Fehlgeschlagen nach {} Sekunden", duration.as_secs())
#             }
#         }
#     });
# }
#
# async fn timeout<F: Future>(
#     future_to_try: F,
#     max_time: Duration,
# ) -> Result<F::Output, Duration> {
    match trpl::race(future_to_try, trpl::sleep(max_time)).await {
        Either::Left(output) => Ok(output),
        Either::Right(_) => Err(max_time),
    }
# }
```

<span class="caption">Codeblock 17-29: Definieren von `timeout` mit `race` und
`sleep`</span>

Damit haben wir ein funktionierendes `timeout`, das aus zwei anderen
asynchronen Helfern besteht. Wenn wir unseren Code ausführen, wird er als
Fehlermeldung nach dem Timeout ausgeben:

```text
Fehlgeschlagen nach 2 Sekunden
```

Da Futures aus anderen Futures zusammengesetzt werden können, lassen sich mit
kleineren asynchronen Bausteinen wirklich leistungsfähige Werkzeuge erstellen.
So kannst du beispielsweise mit demselben Ansatz Zeitüberschreitungen mit
Wiederholungen kombinieren und diese wiederum für Dinge wie Netzwerkaufrufe
verwenden &ndash; eines der Beispiele vom Anfang des Kapitels!

In der Praxis wirst du normalerweise direkt mit `async` und `await` arbeiten
und in zweiter Linie mit Funktionen und Makros wie `join`, `join_all`, `race`
und so weiter. Du wirst nur ab und zu zu `pin` greifen müssen, um es mit diesen
APIs zu benutzen.

Wir haben nun eine Reihe von Möglichkeiten gesehen, mit mehreren Futures
gleichzeitig zu arbeiten. Als Nächstes werden wir uns ansehen, wie wir mit
mehreren Futures in einer zeitlichen Abfolge arbeiten können, mit *Strömen*
(streams). Vorher solltest du aber noch ein paar Dinge beachten:

* Wir haben einen `Vec` mit `join_all` verwendet, um zu warten, bis alle
  Futures in einer Gruppe beendet sind. Wie könnte man stattdessen einen
  `Vec` verwenden, um eine Gruppe von Futures nacheinander zu verarbeiten?
  Was sind die Nachteile dieser Vorgehensweise?

* Wirf einen Blick auf den Typ `futures::stream::FuturesUnordered` aus der
  Kiste `futures`. Inwiefern unterscheidet sich die Verwendung dieses Typs von
  der Verwendung eines `Vec`? (Mach dir keine Sorgen über die Tatsache, dass es
  aus dem `stream`-Teil der Kiste stammt; es funktioniert einfach mit jeder
  Sammlung von Futures.)

[dyn]: ch12-03-improving-error-handling-and-modularity.html##rückgabe-von-fehlern-aus-der-funktion-run
[async-program]: ch17-01-futures-and-syntax.html#unser-erstes-asynchrones-programm
