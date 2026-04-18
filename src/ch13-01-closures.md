## Closures

Rusts Closures (engl. Funktionsabschlüsse) sind anonyme Funktionen, die du in
einer Variable speichern oder anderen Funktionen als Argument übergeben kannst.
Du kannst einen Closure erstellen und dann in einem anderen Zusammenhang
aufrufen und auswerten. Im Gegensatz zu Funktionen können Closures auf Werte
(values) im Gültigkeitsbereich (scope) zugreifen, in dem sie erstellt wurden.
Wir werden im Folgenden zeigen, wie die Funktionalität von Closures die
Wiederverwendung von Code erlaubt und sein Verhalten anpassen kann.

### Erfassen der Umgebung

Wir werden zunächst untersuchen, wie wir Closures verwenden können, um Werte aus
der Umgebung, in der sie definiert sind, zur späteren Verwendung zu erfassen.
Hier ist das Szenario: Von Zeit zu Zeit verschenkt unsere T-Shirt-Firma ein
exklusives T-Shirt in limitierter Auflage an jemanden aus unserer Mailingliste
als Werbeaktion. Die Personen auf der Mailingliste können optional ihre
Lieblingsfarbe zu ihrem Profil hinzufügen. Wenn die Person, die das kostenlose
Shirt erhalten soll, ihre Lieblingsfarbe in ihrem Profil angegeben hat, erhält
sie das Hemd in dieser Farbe. Wenn die Person keine Lieblingsfarbe angegeben
hat, erhält sie die Farbe, in der das Unternehmen derzeit die meisten Exemplare
hat.

Es gibt viele Möglichkeiten, dies zu implementieren. Für dieses Beispiel werden
wir eine Aufzählung namens `ShirtColor` verwenden, die die Varianten `Red` und
`Blue` hat (der Einfachheit halber wird die Anzahl der verfügbaren Farben
begrenzt). Das Inventar des Unternehmens wird durch eine Struktur `Inventory`
repräsentiert, die ein Feld mit dem Namen `shirts` hat, das ein
`Vec<ShirtColor>` mit den derzeit vorrätigen Hemden enthält. Die Methode
`giveaway`, die auf `Inventory` definiert ist, erhält die optionale
Shirtfarbe der Person, die das kostenlose Shirt erhält, und gibt die Shirtfarbe
zurück, die die Person erhalten wird. Dies wird in Listing 13-1 gezeigt.

<span class="filename">Dateiname: src/main.rs</span>

```rust
#[derive(Debug, PartialEq, Copy, Clone)]
enum ShirtColor {
    Red,
    Blue,
}

struct Inventory {
    shirts: Vec<ShirtColor>,
}

impl Inventory {
    fn giveaway(&self, user_preference: Option<ShirtColor>) -> ShirtColor {
        user_preference.unwrap_or_else(|| self.most_stocked())
    }

    fn most_stocked(&self) -> ShirtColor {
        let mut num_red = 0;
        let mut num_blue = 0;

        for color in &self.shirts {
            match color {
                ShirtColor::Red => num_red += 1,
                ShirtColor::Blue => num_blue += 1,
            }
        }
        if num_red > num_blue {
            ShirtColor::Red
        } else {
            ShirtColor::Blue
        }
    }
}

fn main() {
    let store = Inventory {
        shirts: vec![ShirtColor::Blue, ShirtColor::Red, ShirtColor::Blue],
    };

    let user_pref1 = Some(ShirtColor::Red);
    let giveaway1 = store.giveaway(user_pref1);
    println!("Der Benutzer mit Präferenz {user_pref1:?} erhält {giveaway1:?}");

    let user_pref2 = None;
    let giveaway2 = store.giveaway(user_pref2);
    println!("Der Benutzer mit Präferenz {user_pref2:?} erhält {giveaway2:?}");
}
```
<span class="caption">Listing 13-1: Werbegeschenk der Shirtfirma</span>

Der in `main` definierte `store` hat zwei blaue Shirts und ein rotes Shirt
übrig, die für diese limitierte Aktion verteilt werden sollen. Wir rufen die
Methode `giveaway` für einen Benutzer mit einer Präferenz für ein rotes Hemd
und einen Benutzer ohne jegliche Präferenz auf.

Auch dieser Code könnte auf viele Arten implementiert werden. Um uns auf
Closures zu konzentrieren, haben wir uns an die Konzepte gehalten, die du
bereits gelernt hast, mit Ausnahme des Methodenrumpfs von `giveaway`, der einen
Closure verwendet. In der Methode `giveaway` erhalten wir die Benutzerpräferenz
als einen Parameter vom Typ `Option<ShirtColor>` und rufen die Methode
`unwrap_or_else` auf `user_preference` auf. Die [Methode `unwrap_or_else` auf
`Option<T>`][unwrap-or-else] ist in der Standardbibliothek definiert. Sie nimmt
ein Argument entgegen: Einen Closure ohne Argument, der einen Wert `T`
zurückgibt (denselben Typ, der in der Variante `Some` von `Option<T>`
gespeichert ist, in diesem Fall `ShirtColor`). Wenn `Option<T>` die Variante
`Some` ist, gibt `unwrap_or_else` den Wert aus `Some` zurück. Wenn `Option<T>`
die Variante `None` ist, ruft `unwrap_or_else` den Closure auf und gibt den Wert
zurück, der vom Closure zurückgegeben wurde.

Wir geben den Closure-Ausdruck `|| self.most_stocked()` als Argument bei
`unwrap_or_else` an. Dies ist ein Closure, die selbst keine Parameter hat (wenn
der Closure Parameter hätte, würden sie zwischen den beiden vertikalen Strichen
erscheinen). Der Rumpf des Closures ruft `self.most_stocked()` auf. Wir
definieren den Closure hier, und die Implementierung von `unwrap_or_else` wird
den Closure später auswerten, wenn das Ergebnis benötigt wird.

Die Ausführung dieses Codes gibt folgendes aus:

```console
$ cargo run
   Compiling shirt-company v0.1.0 (file:///projects/shirt-company)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.27s
     Running `target/debug/shirt-company`
Der Benutzer mit Präferenz Some(Red) erhält Red
Der Benutzer mit Präferenz None erhält Blue
```

Ein interessanter Aspekt ist hier, dass wir einen Closure übergeben haben, der
`self.most_stocked()` für die aktuelle `Inventory`-Instanz aufruft. Die
Standardbibliothek musste nichts über die von uns definierten Typen `Inventory`
oder `ShirtColor` oder die Logik, die wir in diesem Szenario verwenden wollen,
wissen. Der Closure hat eine unveränderbare Referenz auf die `self`-Instanz von
`Inventory` erfasst und sie mit dem von uns angegebenen Code an die Methode
`unwrap_or_else` übergeben. Funktionen sind andererseits nicht in der Lage, ihre
Umgebung auf diese Weise zu erfassen.

### Herleiten und Annotieren von Closure-Typen

Es gibt weitere Unterschiede zwischen Funktionen und Closures. Bei Closures ist
es normalerweise nicht erforderlich, die Typen der Parameter oder des
Rückgabewertes zu annotieren, wie es bei `fn`-Funktionen der Fall ist.
Typ-Annotationen sind bei Funktionen erforderlich, weil die Typen Teil einer
expliziten Schnittstelle sind, die für deine Benutzer sichtbar ist. Die strikte
Definition dieser Schnittstelle ist wichtig, um sicherzustellen, dass alle
Beteiligten sich darüber einig sind, welche Arten von Werten eine Funktion
verwendet und zurückgibt. Closures werden hingegen nicht in einer offengelegten
Schnittstelle wie dieser verwendet: Sie werden in Variablen gespeichert und
verwendet, ohne sie zu benennen und den Benutzern unserer Bibliothek
offenzulegen.

Closures sind in der Regel kurz und nur in einem engen Kontext und nicht in
jedem beliebigen Szenario relevant. Innerhalb dieser begrenzten Kontexte kann
der Compiler die Typen der Parameter und des Rückgabetyps ableiten, ähnlich wie
er die Typen der meisten Variablen ableiten kann (es gibt seltene Fälle, in
denen der Compiler auch Closure-Typannotationen benötigt).

Wie bei Variablen können wir Typ-Annotationen hinzufügen, wenn wir die
Explizitheit und Klarheit erhöhen wollen, auch wenn wir dafür ausführlicher sind
als unbedingt nötig. Die Annotation der Typen für einen Closure würde wie die in
Listing 13-2 gezeigte Definition aussehen. In diesem Beispiel definieren wir
einen Closure und speichern ihn in einer Variablen, anstatt den Closure an der
Stelle zu definieren, an der wir ihn als Argument übergeben, wie wir es in
Listing 13-1 getan haben.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# use std::thread;
# use std::time::Duration;
#
# fn generate_workout(intensity: u32, random_number: u32) {
    let expensive_closure = |num: u32| -> u32 {
        println!("rechnet langsam...");
        thread::sleep(Duration::from_secs(2));
        num
    };
#
#     if intensity < 25 {
#         println!("Mach heute {} Liegestütze!", expensive_closure(intensity));
#         println!("Als nächstes {} Sit-ups!", expensive_closure(intensity));
#     } else {
#         if random_number == 3 {
#             println!("Mach heute eine Pause! Denk daran, ausreichend zu trinken!");
#         } else {
#             println!(
#                 "Heute, {} Minuten Lauftraining!",
#                 expensive_closure(intensity)
#             );
#         }
#     }
# }
#
# fn main() {
#     let simulated_user_specified_value = 10;
#     let simulated_random_number = 7;
#
#     generate_workout(simulated_user_specified_value, simulated_random_number);
# }
```

<span class="caption">Listing 13-2: Hinzufügen optionaler Datentypangabe der
Parameter- und Rückgabewert-Typen im Closure</span>

Mit Typ-Annotationen ähnelt die Syntax eines Closures sehr der Syntax einer
Funktion. Hier definieren wir eine Funktion, die zu ihrem Parameter den Wert 1
addiert, und zum Vergleich einen Closure mit identischem Verhalten. Zur besseren
Darstellung der relevanten Teile haben wir einige Leerzeichen eingefügt. Dies
zeigt, wie ähnlich die Syntax von Funktionen der von Closures ist, abgesehen von
den senkrechten Strichen und der Möglichkeit, einen Teil der Syntax wegzulassen:

```rust,ignore
fn  add_one_v1   (x: u32) -> u32 { x + 1 }
let add_one_v2 = |x: u32| -> u32 { x + 1 };
let add_one_v3 = |x|             { x + 1 };
let add_one_v4 = |x|               x + 1  ;
```

Die erste Zeile zeigt eine Funktionsdefinition und die zweite eine Definition
eines Closures mit allen Datentypangaben. In der dritten Zeile werden die
Datentypangaben aus der Closure-Definition entfernt, und in der vierten Zeile
werden die geschweiften Klammern weggelassen, die optional sind, da der
Closure-Rumpf nur einen Ausdruck beinhaltet. All diese Ausdrücke sind gültig und
verhalten sich beim Aufruf gleich. Von `add_one_v3` und `add_one_v4` wird ein
Aufruf zum Kompilieren des Codes benötigt, da hier die Typen abhängig von der
Verwendung abgeleitet werden. Dies ist vergleichbar mit `let v = Vec::new();`,
bei dem entweder Typ-Annotationen oder Werte eines bestimmten Typs in den `Vec`
eingefügt werden müssen, damit Rust den Typ ableiten kann.

Bei Closure-Definitionen wird für jeden Parameter und für den Rückgabewert ein
konkreter Typ abgeleitet. Listing 13-3 zeigt zum Beispiel die Definition eines
kurzen Closures, der nur den Wert des übergebenen Parameters zurückgibt. Dieser
Closure ist außer für dieses Beispiel nicht weiter nützlich. Beachte, dass wir
der Definition keine Datentypangaben hinzugefügt haben. Da es keine
Typ-Annotationen gibt, können wir den Closure mit einem beliebigen Typ aufrufen,
was wir hier mit `String` das erste Mal getan haben. Wenn wir dann versuchen,
`example_closure` mit einer Ganzzahl aufzurufen, erhalten wir einen Fehler.

<span class="filename">Dateiname: src/main.rs</span>

```rust,does_not_compile
let example_closure = |x| x;

let s = example_closure(String::from("hallo"));
let n = example_closure(5);
```

<span class="caption">Listing 13-3: Versuchter Aufruf eines Closure, dem zwei
unterschiedliche Typen übergeben wurden</span>

Der Compiler gibt diesen Fehler aus:

```console
$ cargo run
   Compiling closure-example v0.1.0 (file:///projects/closure-example)
error[E0308]: mismatched types
 --> src/main.rs:5:29
  |
5 |     let n = example_closure(5);
  |             --------------- ^ expected `String`, found integer
  |             |
  |             arguments to this function are incorrect
  |
note: expected because the closure was earlier called with an argument of type `String`
 --> src/main.rs:4:29
  |
4 |     let s = example_closure(String::from("hello"));
  |             --------------- ^^^^^^^^^^^^^^^^^^^^^ expected because this argument is of type `String`
  |             |
  |             in this closure call
note: closure parameter defined here
 --> src/main.rs:2:28
  |
2 |     let example_closure = |x| x;
  |                            ^
help: try using a conversion method
  |
5 |     let n = example_closure(5.to_string());
  |                              ++++++++++++

For more information about this error, try `rustc --explain E0308`.
error: could not compile `closure-example` (bin "closure-example") due to 1 previous error
```

Beim ersten Aufruf von `example_closure` wird dem Typ von `x` und dem
Rückgabewert des Closures der Typ `String` zugewiesen. Diese Typen sind dann für
den Closure `example_closure` festgeschrieben. Daher bekommen wir eine
Fehlermeldung, wenn wir versuchen einen anderen Typ mit dem gleichen Closure zu
benutzen.

### Erfassen von Referenzen oder Verschieben der Eigentümerschaft

Closures können Werte aus ihrer Umgebung auf drei Arten erfassen, die direkt den
drei Möglichkeiten entsprechen, wie eine Funktion einen Parameter aufnehmen
kann: Unveränderbare Borrows, veränderbare Borrows und Eigentümerschaft
übernehmen (taking ownership). Der Closure entscheidet, welche dieser
Möglichkeiten verwendet wird, je nachdem, was der Rumpf der Funktion mit den
erfassten Werten macht.

In Listing 13-4 definieren wir einen Closure, der eine unveränderbare Referenz
an den Vektor mit dem Namen `list` erfasst, weil er nur eine unveränderbare
Referenz benötigt, um den Wert auszugeben.

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let list = vec![1, 2, 3];
    println!("Vor der Closure-Definition: {list:?}");

    let only_borrows = || println!("Im Closure: {list:?}");

    println!("Vor dem Closure-Aufruf: {list:?}");
    only_borrows();
    println!("Nach dem Closure-Aufruf: {list:?}");
}
```

<span class="caption">Listing 13-4: Definieren und Aufrufen eines Closure, der
eine unveränderbare Referenz erfasst</span>

Dieses Beispiel veranschaulicht auch, dass eine Variable an eine
Closure-Definition gebunden werden kann, und wir den Closure später aufrufen
können, indem wir den Variablennamen und die Klammern verwenden, als ob der
Variablenname ein Funktionsname wäre.

Da wir mehrere unveränderbare Referenzen auf `list` zur gleichen Zeit haben
können, ist `list` immer noch vom Code vor der Closure-Definition zugreifbar,
sowie nach der Closure-Definition und vor dem Aufruf des Closures, und nach dem
Aufruf des Closures. Dieser Code kompiliert, läuft und gibt folgendes aus:

```console
$ cargo run
   Compiling closure-example v0.1.0 (file:///projects/closure-example)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.43s
     Running `target/debug/closure-example`
Vor der Closure-Definition: [1, 2, 3]
Vor dem Closure-Aufruf: [1, 2, 3]
Im Closure: [1, 2, 3]
Nach dem Closure-Aufruf: [1, 2, 3]
```

In Listing 13-5 wird die Definition des Closures so geändert, dass er ein
Element zum Vektor `list` hinzufügt. Der Closure erfasst nun eine veränderbare
Referenz.

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let mut list = vec![1, 2, 3];
    println!("Vor der Closure-Definition: {list:?}");

    let mut borrows_mutably = || list.push(7);

    borrows_mutably();
    println!("Nach dem Closure-Aufruf: {list:?}");
}
```

<span class="caption">Listing 13-5: Definieren und Aufrufen eines Closures,
der eine veränderbare Referenz erfasst</span>

Dieser Code kompiliert, läuft und gibt aus:

```console
$ cargo run
   Compiling closure-example v0.1.0 (file:///projects/closure-example)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.43s
     Running `target/debug/closure-example`
Vor der Closure-Definition: [1, 2, 3]
Nach dem Closure-Aufruf: [1, 2, 3, 7]
```

Beachte, dass es kein `println!` mehr zwischen der Definition und dem Aufruf des
Closures `borrows_mutably` gibt: Wenn `borrows_mutably` definiert ist, erfasst
es eine veränderbare Referenz auf `list`. Der Closure wird nicht mehr verwendet,
nachdem er aufgerufen wurde, daher endet die veränderbare Borrow. Zwischen der
Closure-Definition und dem Closureaufruf ist eine unveränderbare Borrow für die
Ausgabe nicht erlaubt, weil keine anderen Borrows erlaubt sind, wenn es eine
veränderbare Borrow gibt. Versuche, dort ein `println!` hinzuzufügen, um zu
sehen, welche Fehlermeldung du erhältst!

Wenn du den Closure zwingen willst, die Eigentümerschaft der Werte, die er in
der Umgebung verwendet, zu übernehmen, obwohl der Rumpf des Closures nicht
unbedingt Eigentümer sein muss, kannst du das Schlüsselwort `move` vor der
Parameterliste verwenden.

Diese Technik ist vor allem nützlich, wenn ein Closure an einen neuen Thread
übergeben wird, um die Daten zu verschieben, sodass sie dem neuen Thread
gehören. Wir werden in Kapitel 16, wenn wir über Nebenläufigkeit (concurrency)
sprechen, detailliert auf Threads eingehen und erläutern, warum man sie
verwenden sollte, aber jetzt wollen wir uns kurz mit dem Erzeugen eines neuen
Threads mithilfe eines Closures befassen, der das Schlüsselwort `move` benötigt.
Listing 13-6 zeigt Listing 13-4 modifiziert, um den Vektor in einem neuen
Thread statt im Haupt-Thread auszugeben.

<span class="filename">Dateiname: src/main.rs</span>

```rust
use std::thread;

fn main() {
    let list = vec![1, 2, 3];
    println!("Vor der Closure-Definition: {list:?}");

    thread::spawn(move || println!("Im Thread: {list:?}"))
        .join()
        .unwrap();
}
```

<span class="caption">Listing 13-6: Verwenden von `move`, um den Closure des
Threads zu zwingen, die Eigentümerschaft an `list` zu übernehmen</span>

Wir starten einen neuen Thread und geben ihm einen Closure als Argument mit. Der
Rumps des Closures gibt die Liste aus. In Listing 13-4 hat der Closure nur
`list` mit einer unveränderbaren Referenz erfasst, weil das die kleinste
Zugriffmenge auf `list` ist, die benötigt wird, um sie auszugeben. In diesem
Beispiel müssen wir, obwohl der Closurer-Rumpf nur eine unveränderbare Referenz
benötigt, angeben, dass `list` in den Closure verschoben werden soll, indem wir
das Schlüsselwort `move` an den Anfang der Closure-Definition setzen.

Wenn der Haupt-Thread vor dem Aufruf von `join` für den neuen Thread weitere
Operationen ausgeführt hat, könnte der neue Thread beendet werden, bevor der
Rest des Haupt-Threads beendet wird, oder der Haupt-Thread könnte zuerst beendet
werden. Wenn der Haupt-Thread die Eigentümerschaft von `list` beibehält, aber
vor dem neuen Thread endet und `list` aufräumt, wäre die unveränderbare Referenz
im Thread ungültig. Daher verlangt der Compiler, dass `list` in den Closure im
neuen Thread verschoben wird, damit die Referenz gültig bleibt. Versuche, das
Schlüsselwort `move` zu entfernen oder `list` im Haupt-Thread zu verwenden,
nachdem der Closure definiert wurde, um zu sehen, welche Compilerfehler du
erhältst!

### Verschieben erfasster Werte aus Closures

Sobald ein Closure eine Referenz oder die Eigentümerschaft eines Werts aus der
Umgebung, in der der Closure definiert ist, erfasst hat (und damit beeinflusst,
was _in_ den Closure verschoben wird), definiert der Code im Rumpf des Closures,
was mit den Referenzen oder Werten passiert, wenn der Closure später ausgewertet
wird (und damit beeinflusst, was _aus_ dem Closure verschoben wird). Ein
Closure-Rumpf kann eine der folgenden Aktionen ausführen: Einen erfassten Wert
aus dem Closure herausverschieben, den erfassten Wert verändern, den Wert weder
verschieben noch verändern oder zunächst nichts aus der Umgebung erfassen.

Die Art und Weise, wie ein Closure Werte aus der Umgebung erfasst und
verarbeitet, wirkt sich darauf aus, welche Traits der Closure implementiert, und
mit Hilfe von Traits können Funktionen und Strukturen angeben, welche Arten von
Closures sie verwenden können. Closures implementieren automatisch eine, zwei
oder alle drei dieser `Fn`-Traits, und zwar in additiver Weise, je nachdem, wie
der Closure-Rumpf die Werte behandelt:

* `FnOnce` gilt für Closures, die einmal aufgerufen werden können. Alle Closures
  implementieren zumindest dieses Trait, weil alle Closures aufgerufen werden
  können. Ein Closure, der erfasste Werte aus seinem Rumpf herausverschiebt,
  implementiert nur `FnOnce` und keine der anderen `Fn`-Traits, weil er nur
  einmal aufgerufen werden kann.
* `FnMut` gilt für Closures, die die erfassten Werte nicht aus ihrem Rumpf
  herausverschieben, aber die erfassten Werte möglicherweise verändern. Diese
  Closures können mehr als einmal aufgerufen werden.
* `Fn` gilt für Closure, die die erfassten Werte nicht aus ihrem Rumpf
  herausverschieben und die erfassten Werte nicht verändern, sowie Closures, die
  nichts aus ihrer Umgebung erfassen. Diese Closures können mehr als einmal
  aufgerufen werden, ohne ihre Umgebung zu verändern, was wichtig ist, wenn z.B.
  ein Closure mehrere Male gleichzeitig aufgerufen wird.

Schauen wir uns die Definition der Methode `unwrap_or_else` auf `Option<T>` an,
die wir in Listing 13-1 verwendet haben:

```rust,ignore
impl<T> Option<T> {
    pub fn unwrap_or_else<F>(self, f: F) -> T
    where
        F: FnOnce() -> T
    {
        match self {
            Some(x) => x,
            None => f(),
        }
    }
}
```

Erinnere dich, dass `T` der generische Typ ist, der den Typ des Wertes in der
`Some`-Variante einer `Option` darstellt. Dieser Typ `T` ist auch der
Rückgabetyp der Funktion `unwrap_or_else`: Code, der `unwrap_or_else` auf einer
`Option<String>` aufruft, erhält zum Beispiel einen `String`.

Als Nächstes ist zu beachten, dass die Funktion `unwrap_or_else` den
zusätzlichen generischen Typ-Parameter `F` hat. Der Typ `F` ist der Typ des
Parameters namens `f`, der der Closure ist, den wir beim Aufruf von
`unwrap_or_else` bereitstellen.

Die für den generischen Typ `F` spezifizierte Trait Bound ist `FnOnce()
-> T`, was bedeutet, dass `F` mindestens einmal aufgerufen werden können muss,
keine Argumente annimmt und ein `T` zurückgeben muss. Die Verwendung von
`FnOnce` in der Trait Bound drückt die Einschränkung aus, dass
`unwrap_or_else` `f` nicht mehr als ein Mal aufrufen wird. Im Rumpf von
`unwrap_or_else` können wir sehen, dass, wenn die `Option` `Some` ist, `f` nicht
aufgerufen wird. Wenn die `Option` `None` ist, wird `f` einmal aufgerufen. Da
alle Closures `FnOnce` implementieren, akzeptiert `unwrap_or_else` alle drei
Arten von Closures und ist so flexibel wie nur möglich.

> Anmerkung: Wenn das, was wir tun wollen, keine Werte aus der Umgebung
> erfassen muss, können wir einen Funktionsnamen anstelle eines Closures
> verwenden. Zum Beispiel könnten wir `unwrap_or_else(Vec::new)` auf einem
> `Option<Vec<T>>`-Wert aufrufen, um einen neuen, leeren Vektor zu erhalten,
> wenn der Wert `None` ist. Der Compiler implementiert automatisch die
> `Fn`-Traits, die für eine Funktionsdefinition anwendbar sind.

Schauen wir uns nun die Standard-Bibliotheksmethode `sort_by_key` an, die auf
Anteilstypen (slices) definiert ist, um zu sehen, wie sie sich von
`unwrap_or_else` unterscheidet und warum `sort_by_key` `FnMut` statt `FnOnce`
für die Mermalsabgrenzung verwendet. Der Closure erhält ein Argument, eine
Referenz auf das aktuelle Element im betrachteten Anteilstyp, und gibt einen
Wert vom Typ `K` zurück, der geordnet werden kann. Diese Funktion ist nützlich,
wenn man einen Anteilstyp nach einem bestimmten Attribut der einzelnen Elemente
sortieren will. In Listing 13-7 haben wir eine Liste von `Rectangle`-Instanzen
und benutzen `sort_by_key`, um sie nach ihrem `width`-Attribut von niedrig nach
hoch zu sortieren:

<span class="filename">Dateiname: src/main.rs</span>

```rust
#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32,
}

fn main() {
    let mut list = [
        Rectangle { width: 10, height: 1 },
        Rectangle { width: 3, height: 5 },
        Rectangle { width: 7, height: 12 },
    ];

    list.sort_by_key(|r| r.width);
    println!("{list:#?}");
}
```

<span class="caption">Listing 13-7: Verwenden von `sort_by_key` um Rechtecke
nach ihrer Breite zu sortieren</span>

Dieser Code gibt aus:

```console
$ cargo run
   Compiling rectangles v0.1.0 (file:///projects/rectangles)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.41s
     Running `target/debug/rectangles`
[
    Rectangle {
        width: 3,
        height: 5,
    },
    Rectangle {
        width: 7,
        height: 12,
    },
    Rectangle {
        width: 10,
        height: 1,
    },
]
```

Der Grund, warum `sort_by_key` so definiert ist, dass es einen `FnMut`-Closure
nimmt, ist, dass es den Closure mehrfach aufruft: Einmal für jedes Element im
Anteilstyp. Der Closure `|r| r.width` erfasst, verändert oder verschiebt nichts
aus seiner Umgebung, sodass er die Anforderungen der Trait Bound erfüllt.

Im Gegensatz dazu zeigt Listing 13-8 ein Beispiel für einen Closure, der nur
das Trait `FnOnce` implementiert, weil er einen Wert aus der Umgebung
verschiebt. Der Compiler lässt uns diesen Closure nicht mit `sort_by_key`
verwenden.

<span class="filename">Dateiname: src/main.rs</span>

```rust,does_not_compile
#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32,
}

fn main() {
    let mut list = [
        Rectangle { width: 10, height: 1 },
        Rectangle { width: 3, height: 5 },
        Rectangle { width: 7, height: 12 },
    ];

    let mut sort_operations = vec![];
    let value = String::from("Closure aufgerufen");

    list.sort_by_key(|r| {
        sort_operations.push(value);
        r.width
    });
    println!("{list:#?}");
}
```

<span class="caption">Listing 13-8: Versuch, einen `FnOnce`-Closure mit
`sort_by_key` zu verwenden</span>

Dies ist ein ausgeklügelter, verworrener Weg (der nicht funktioniert), der
versucht die Anzahl der Aufrufe des Closures durch `sort_by_key` beim Sortieren
von `list` zu zählen. Dieser Code versucht diese Zählung durchzuführen, indem er
den `String` `value` aus der Umgebung des Closures in den Vektor
`sort_operations` verschiebt. Der Closure erfasst `value` und verschiebt dann
`value` aus dem Closure heraus, indem er die Eigentümerschaft von `value` an den
Vektor `sort_operations` überträgt. Dieser Closure kann einmal aufgerufen
werden; ein zweiter Aufruf würde nicht funktionieren, da `value` nicht mehr in
der Umgebung wäre, um erneut in `sort_operations` verschoben zu werden! Daher
implementiert dieser Closure nur `FnOnce`. Wenn wir versuchen, diesen Code zu
kompilieren, erhalten wir die Fehlermeldung, dass `value` nicht aus dem Closure
verschoben werden kann, weil der Closure `FnMut` implementieren muss:

```console
$ cargo run
   Compiling rectangles v0.1.0 (file:///projects/rectangles)
error[E0507]: cannot move out of `value`, a captured variable in an `FnMut` closure
  --> src/main.rs:18:30
   |
15 |     let value = String::from("Closure aufgerufen");
   |         -----   ---------------------------------- move occurs because `value` has type `String`, which does not implement the `Copy` trait
   |         |
   |         captured outer variable
16 |
17 |     list.sort_by_key(|r| {
   |                      --- captured by this `FnMut` closure
18 |         sort_operations.push(value);
   |                              ^^^^^ `value` is moved here
   |
help: consider cloning the value if the performance cost is acceptable
   |
18 |         sort_operations.push(value.clone());
   |                                   ++++++++

For more information about this error, try `rustc --explain E0507`.
error: could not compile `rectangles` (bin "rectangles") due to 1 previous error
```

Der Fehler bezieht sich auf die Zeile im Closure-Rumpf, die `value` aus der
Umgebung verschiebt. Um dies zu beheben, müssen wir den Rumpf des Closures so
ändern, dass er keine Werte aus der Umgebung verschiebt. Es ist einfacher, einen
Zähler in der Umgebung zu halten und seinen Wert im Closure-Rumpf zu erhöhen, um
zu zählen, wie oft `sort_by_key` aufgerufen wurde. Der Closure in Listing 13-9
funktioniert mit `sort_by_key`, weil er nur eine veränderbare Referenz auf den
`num_sort_operations`-Zähler erfasst und daher mehr als einmal aufgerufen werden
kann.

<span class="filename">Dateiname: src/main.rs</span>

```rust
#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32,
}

fn main() {
    let mut list = [
        Rectangle { width: 10, height: 1 },
        Rectangle { width: 3, height: 5 },
        Rectangle { width: 7, height: 12 },
    ];

    let mut num_sort_operations = 0;
    list.sort_by_key(|r| {
        num_sort_operations += 1;
        r.width
    });
    println!("{list:#?}, sortiert in {num_sort_operations} Operationen");
}
```

<span class="caption">Listing 13-9: Verwenden eines `FnMut`-Closure mit
`sort_by_key` ist erlaubt</span>

Die `Fn`-Traits sind wichtig bei der Definition oder Verwendung von Funktionen
oder Typen, die Closures verwenden. Im nächsten Abschnitt besprechen wir
Iteratoren. Viele Iterator-Methoden nehmen Closure-Argumente entgegen, also
behalte diese Details von Closures im Kopf, wenn wir weitermachen!

[unwrap-or-else]: https://doc.rust-lang.org/std/option/enum.Option.html#method.unwrap_or_else
