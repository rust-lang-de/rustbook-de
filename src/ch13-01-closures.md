## Funktionsabschlüsse (closures): Anonyme Funktionen, die ihre Umgebung erfassen können

Rusts Funktionsabschlüsse sind anonyme Funktionen, die du in einer Variable
speichern oder anderen Funktionen als Argument übergeben kannst. Du kannst einen 
Funktionsabschluss erstellen und dann in einem anderen Zusammenhang aufrufen
und auswerten. Im Gegensatz zu Funktionen können Funktionsabschlüsse auf Werte 
(values) im Gültigkeitsbereich (scope) zugreifen, in dem sie erstellt wurden.
Wir werden im Folgenden zeigen, wie die Funktionalität von Funktionsabschlüssen
die Wiederverwendung von Code erlaubt und sein Verhalten anpassen kann.

### Erfassen der Umgebung mit Funktionsabschlüssen

Der erste Aspekt von Funktionsabschlüssen, den wir untersuchen werden, ist,
dass Funktionsabschlüsse Werte aus der Umgebung, in der sie definiert sind, zur
späteren Verwendung erfassen können. Das Szenario sieht folgendermaßen aus:
Eine T-Shirt-Firma verschenkt in regelmäßigen Abständen ein kostenloses T-Shirt
an jemanden aus ihrer Mailingliste. Die Personen auf der Mailingliste können
optional ihre Lieblingsfarbe zu ihrem Profil hinzufügen. Wenn die Person, die
das kostenlose Shirt erhalten soll, ihre Lieblingsfarbe in ihrem Profil
angegeben hat, erhält sie das Hemd in dieser Farbe. Wenn die Person keine
Lieblingsfarbe angegeben hat, erhält sie die Farbe, in der das Unternehmen
derzeit die meisten Exemplare hat.

Es gibt viele Möglichkeiten, dies zu implementieren. Für dieses Beispiel werden
wir eine Aufzählung namens `ShirtColor` verwenden, die die Varianten `Red` und
`Blue` hat. Das Inventar des Unternehmens wird durch eine Struktur `Inventory`
repräsentiert, die ein Feld mit dem Namen `shirts` hat, das ein
`Vec<ShirtColor>` mit den derzeit vorrätigen Hemden enthält. Die Methode
`shirt_giveaway`, die auf `Inventory` definiert ist, erhält die optionale
Shirtfarbe der Person, die das kostenlose Shirt erhält, und gibt die Shirtfarbe
zurück, die die Person erhalten wird. Dies wird in Codeblock 13-1 gezeigt:

<span class="filename">Dateiname: src/main.rs</span>

```rust,noplayground
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
    println!(
        "Der Benutzer mit Präferenz {:?} erhält {:?}",
        user_pref1, giveaway1
    );

    let user_pref2 = None;
    let giveaway2 = store.giveaway(user_pref2);
    println!(
        "Der Benutzer mit Präferenz {:?} erhält {:?}",
        user_pref2, giveaway2
    );
}
```
<span class="caption">Codeblock 13-1: Werbegeschenk der Shirtfirma</span>

Der in `main` definierte `store` hat zwei blaue Shirts und ein rotes Shirt auf
Lager. Dann ruft er die Methode `giveaway` für einen Benutzer mit einer
Präferenz für ein rotes Shirt und einen Benutzer ohne Referenz auf. Die
Ausführung dieses Codes gibt aus:

```console
$ cargo run
   Compiling shirt-company v0.1.0 (file:///projects/shirt-company)
    Finished dev [unoptimized + debuginfo] target(s) in 0.27s
     Running `target/debug/shirt-company`
Der Benutzer mit Präferenz Some(Red) erhält Red
Der Benutzer mit Präferenz None erhält Blue
```

Auch dieser Code könnte auf viele Arten implementiert werden, aber dieser Weg
verwendet Konzepte, die du bereits gelernt hast, mit Ausnahme des Rumpfs der
Methode `giveaway`, der einen Funktionsabschluss verwendet. Die Methode
`giveaway` nimmt die Benutzerpräferenz `Option<ShirtColor>` und ruft
`unwrap_or_else` auf. Die [Methode `unwrap_or_else` auf
`Option<T>`][unwrap-or-else] ist in der Standardbibliothek definiert. Sie nimmt
ein Argument: Ein Funktionsabschluss ohne Argumente, der einen Wert `T`
zurückgibt (den gleichen Typ, der in der `Some`-Variante der `Option<T>`
gespeichert ist, in diesem Fall eine `ShirtColor`). Wenn `Option<T>` die
Variante `Some` ist, gibt `unwrap_or_else` den Wert aus `Some` zurück. Wenn
`Option<T>` die Variante `None` ist, ruft `unwrap_or_else` den
Funktionsabschluss auf und gibt den vom Funktionsabschluss zurückgegebenen Wert
zurück.

Das ist interessant, weil wir einen Funktionsabschluss übergeben haben, der
`self.most_stocked()` für die aktuelle `Inventory`-Instanz aufruft. Die
Standardbibliothek musste nichts über die von uns definierten Typen `Inventory`
oder `ShirtColor` oder die Logik, die wir in diesem Szenario verwenden wollen,
wissen. Der Funktionsabschluss hat eine unveränderliche Referenz auf die
`self`-Instanz von `Inventory` erfasst und sie mit dem von uns angegebenen Code
an die Methode `unwrap_or_else` übergeben. Funktionen sind nicht in der Lage,
ihre Umgebung auf diese Weise zu erfassen.

### Funktionsabschluss-Typinferenz und Annotation

Es gibt weitere Unterschiede zwischen Funktionen und Funktionsabschlüssen. Bei
Funktionsabschlüssen ist es normalerweise nicht erforderlich, die Typen der
Parameter oder des Rückgabewertes zu annotieren, wie es bei `fn`-Funktionen der
Fall ist. Typ-Annotationen sind bei Funktionen erforderlich, weil sie Teil
einer expliziten Schnittstelle sind, die für deine Benutzer sichtbar ist. Die
strikte Definition dieser Schnittstelle ist wichtig, um sicherzustellen, dass
alle Beteiligten sich darüber einig sind, welche Arten von Werten eine Funktion
verwendet und zurückgibt. Aber Funktionsabschlüsse werden nicht in einer
exponierten Schnittstelle wie dieser verwendet: Sie werden in Variablen
gespeichert und verwendet, ohne sie zu benennen und den Benutzern unserer
Bibliothek offenzulegen.

Funktionsabschlüsse sind in der Regel kurz und nur in einem engen Kontext und
nicht in jedem beliebigen Szenario relevant. Innerhalb dieser begrenzten
Kontexte kann der Compiler die Typen der Parameter und des Rückgabetyps
ableiten, ähnlich wie er die Typen der meisten Variablen ableiten kann (es gibt
seltene Fälle, in denen der Compiler auch Funktionsabschluss-Typannotationen
benötigt).

Wie bei Variablen können wir Typ-Annotationen hinzufügen, wenn wir die
Explizitheit und Klarheit erhöhen wollen, auch wenn wir dafür ausführlicher
sind als unbedingt nötig. Die Annotation der Typen für einen Funktionsabschluss
würde wie die in Codeblock 13-2 gezeigte Definition aussehen.

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
Parameter- und Rückgabewert-Typen im Funktionsabschluss</span>

Mit Typ-Annotationen ähnelt die Syntax eines Funktionsabschlusses sehr der
Syntax einer Funktion. Im Folgenden vergleichen wir die Syntax einer
Funktionsdefinition, die zu ihrem Parameter den Wert 1 addiert, und die eines
Funktionsabschlusses mit identischem Verhalten. Zur besseren Darstellung der
relevanten Teile haben wir einige Leerzeichen eingefügt. Dies zeigt, wie
ähnlich die Syntax von Funktionen der von Funktionsabschlüssen ist, abgesehen
von den senkrechten Strichen und der Möglichkeit, einen Teil der Syntax
wegzulassen:

```rust,ignore
fn  add_one_v1   (x: u32) -> u32 { x + 1 }
let add_one_v2 = |x: u32| -> u32 { x + 1 };
let add_one_v3 = |x|             { x + 1 };
let add_one_v4 = |x|               x + 1  ;
```

Die erste Zeile zeigt eine Funktionsdefinition und die zweite eine Definition
eines Funktionsabschlusses mit allen Datentypangaben. In der dritten Zeile
werden die Datentypangaben aus der Funktionsabschlusses-Definition entfernt,
und in der vierten Zeile werden die geschweiften Klammern weggelassen, die
optional sind, da der Funktionsabschlusses-Rumpf nur einen Ausdruck beinhaltet.
Alle diese Ausdrücke sind gültig und verhalten sich beim Aufruf gleich. Von
`add_one_v3` und `add_one_v4` wird ein Aufruf zum Kompilieren des Codes
benötigt, da hier die Typen abhängig von der Verwendung abgeleitet werden.

Bei Funktionsabschluss-Definitionen wird für jeden Parameter und für den
Rückgabewert ein konkreter Typ abgeleitet. Codeblock 13-8 zeigt zum Beispiel
die Definition eines kurzen Funktionsabschlusses, der nur den Wert des
übergebenen Parameters zurückgibt. Dieser Funktionsabschluss ist außer für
dieses Beispiel nicht weiter nützlich. Beachte, dass wir der Definition keine
Datentypangaben hinzugefügt haben: Wenn wir nun versuchen, den
Funktionsabschluss zweimal aufzurufen, einmal mit `String` und einmal mit
`u32`, erhalten wir eine Fehlermeldung.

<span class="filename">Dateiname: src/main.rs</span>

```rust,does_not_compile
let example_closure = |x| x;

let s = example_closure(String::from("hallo"));
let n = example_closure(5);
```

<span class="caption">Codeblock 13-3: Versuchter Aufruf eines
Funktionsabschlusses, dem zwei unterschiedliche Typen zugewiesen wurden</span>

Der Compiler gibt diesen Fehler aus:

```console
$ cargo run
   Compiling closure-example v0.1.0 (file:///projects/closure-example)
error[E0308]: mismatched types
 --> src/main.rs:5:29
  |
5 |     let n = example_closure(5);
  |                             ^- help: try using a conversion method: `.to_string()`
  |                             |
  |                             expected struct `String`, found integer

For more information about this error, try `rustc --explain E0308`.
error: could not compile `closure-example` due to previous error
```

Beim ersten Aufruf von `example_closure` wird dem Typ von `x` und dem
Rückgabewert des Funktionsabschlusses der Typ `String` zugewiesen. Diese Typen
sind dann für den Funktionsabschluss `example_closure` festgeschrieben. Daher
bekommen wir eine Fehlermeldung, wenn wir versuchen einen anderen Typ mit dem
gleichen Funktionsabschluss zu benutzen.

### Erfassen von Referenzen oder Verschieben der Eigentümerschaft

Funktionsabschlüsse können Werte aus ihrer Umgebung auf drei Arten erfassen,
die direkt den drei Möglichkeiten entsprechen, wie eine Funktion einen
Parameter aufnehmen kann: Unveränderliche Ausleihen (borrowing immutably),
veränderliche Ausleihen (borrowing mutably) und Eigentümerschaft übernehmen
(taking ownership). Der Funktionsabschluss entscheidet, welche dieser
Möglichkeiten verwendet wird, je nachdem, was der Rumpf der Funktion mit den
erfassten Werten macht.

Codeblock 13-4 definiert einen Funktionsabschluss, der eine unveränderliche
Ausleihe an den Vektor mit dem Namen `list` erfasst, weil sie nur eine
unveränderliche Ausleihe benötigt, um den Wert auszugeben. Dieses Beispiel
veranschaulicht auch, dass eine Variable an eine Funktionsabschluss-Definition
gebunden werden kann und der Funktionsabschluss später durch Verwendung des
Variablennamens und Klammern aufgerufen werden kann, als ob der Variablenname
ein Funktionsname wäre:

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let list = vec![1, 2, 3];
    println!("Vor der Funktionsabschluss-Definition: {:?}", list);

    let only_borrows = || println!("Im Funktionsabschluss: {:?}", list);

    println!("Vor dem Funktionsabschluss-Aufruf: {:?}", list);
    only_borrows();
    println!("Nach dem Funktionsabschluss-Aufruf: {:?}", list);
}
```

<span class="caption">Codeblock 13-4: Definieren und Aufrufen eines
Funktionsabschlusses, der eine unveränderliche Ausleihe erfasst</span>

Der Code vor der Funktionsabschluss-Definition, nach der
Funktionsabschluss-Definition, aber vor dem Aufruf des Funktionsabschlusses,
und nach dem Aufruf des Funktionsabschlusses kann immer noch auf `list`
zugreifen, da wir mehrere unveränderliche Ausleihen von `list` zur gleichen
Zeit haben können. Dieser Code kompiliert, läuft und gibt folgendes aus:

```console
$ cargo run
   Compiling closure-example v0.1.0 (file:///projects/closure-example)
    Finished dev [unoptimized + debuginfo] target(s) in 0.43s
     Running `target/debug/closure-example`
Vor der Funktionsabschluss-Definition: [1, 2, 3]
Vor dem Funktionsabschluss-Aufruf: [1, 2, 3]
Im Funktionsabschluss: [1, 2, 3]
Nach dem Funktionsabschluss-Aufruf: [1, 2, 3]
```

In Codeblock 13-5 wird die Definition des Funktionsabschlusses so geändert,
dass eine veränderliche Ausleihe benötigt wird, da der Funktionsabschluss ein
Element zum Vektor `list` hinzufügt:

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let mut list = vec![1, 2, 3];
    println!("Vor der Funktionsabschluss-Definition: {:?}", list);

    let mut borrows_mutably = || list.push(7);

    borrows_mutably();
    println!("Nach dem Funktionsabschluss-Aufruf: {:?}", list);
}
```

<span class="caption">Codeblock 13-5: Definieren und Aufrufen eines
Funktionsabschlusses, der eine veränderliche Ausleihe erfasst</span>

Dieser Code kompiliert, läuft und gibt aus:

```console
$ cargo run
   Compiling closure-example v0.1.0 (file:///projects/closure-example)
    Finished dev [unoptimized + debuginfo] target(s) in 0.43s
     Running `target/debug/closure-example`
Vor der Funktionsabschluss-Definition: [1, 2, 3]
Nach dem Funktionsabschluss-Aufruf: [1, 2, 3, 7]
```

Beachte, dass es kein `println!` mehr zwischen der Definition und dem Aufruf
des Funktionsabschlusses `borrows_mutably` gibt: Wenn `borrows_mutably`
definiert ist, erfasst es eine veränderliche Referenz auf `list`. Nachdem der
Funktionsabschluss aufgerufen wurde, endet die veränderliche Ausleihe, da wir
den Funktionsabschluss ab diesem Zeitpunkt nicht mehr verwenden. Zwischen der
Funktionsabschluss-Definition und dem Funktionsabschluss-Aufruf ist eine
unveränderliche Ausleihe für die Ausgabe nicht erlaubt, weil keine anderen
Ausleihen erlaubt sind, wenn es eine veränderliche Ausleihe gibt. Versuche,
dort ein `println!` hinzuzufügen, um zu sehen, welche Fehlermeldung du
erhältst!

Wenn du den Funktionsabschluss zwingen willst, die Eigentümerschaft der Werte,
die er in der Umgebung verwendet, zu übernehmen, obwohl der Rumpf des
Funktionsabschlusses nicht unbedingt Eigentümer sein muss, kannst du das
Schlüsselwort `move` vor der Parameterliste verwenden. Diese Technik ist vor
allem nützlich, wenn ein Funktionsabschluss an einen neuen Strang (thread)
übergeben wird, um die Daten zu verschieben, sodass sie dem neuen Strang
gehören. Wir werden mehr Beispiele für Funktionsabschlüsse mit `move` in
Kapitel 16 sehen, wenn wir über Nebenläufigkeit (concurrency) sprechen.

### Verschieben erfasster Werte aus dem Funktionsabschluss und die `Fn`-Merkmale

Sobald ein Funktionsabschluss eine Referenz erfasst oder einen Wert in den
Funktionsabschluss verschoben hat, beeinflusst der Code im Rumpf der Funktion
auch, was mit den Referenzen oder Werten als Ergebnis des Funktionsaufrufs
geschieht. Ein Funktionsabschluss-Rumpf kann einen erfassten Wert aus dem
Funktionsabschluss herausverschieben, den erfassten Wert verändern, den
erfassten Wert weder verschieben noch verändern oder nichts aus der Umgebung
erfassen. Die Art und Weise, wie ein Funktionsabschluss Werte aus der Umgebung
erfasst und verarbeitet, wirkt sich auf die Merkmale (traits) aus, die der
Funktionsabschluss implementiert. Mit den Merkmalen können Funktionen und
Strukturen angeben, welche Arten von Funktionsabschlüssen sie verwenden können.

Funktionsabschlüsse implementieren automatisch eine, zwei oder alle drei dieser
`Fn`-Merkmale, und zwar in additiver Weise:

1. `FnOnce` gilt für Funktionsabschlüsse, die mindestens einmal aufgerufen
   werden können. Alle Funktionsabschlüsse implementieren dieses Merkmal, weil
   alle Funktionsabschlüsse aufgerufen werden können. Wenn ein
   Funktionsabschluss erfasste Werte aus seinem Rumpf herausverschiebt, dann
   implementiert dieser Funktionsabschluss nur `FnOnce` und keine der anderen
   `Fn`-Merkmals, weil sie nur einmal aufgerufen werden kann.
2. `FnMut` gilt für Funktionsabschlüsse, die die erfassten Werte nicht aus
   ihrem Rumpf herausverschieben, aber die erfassten Werte möglicherweise
   verändern. Diese Funktionsabschlüsse können mehr als einmal aufgerufen
   werden.
3. `Fn` gilt für Funktionsabschlüsse, die die erfassten Werte nicht aus ihrem
   Rumpf herausbewegen und die erfassten Werte nicht verändern. Diese
   Funktionsabschlüsse können mehr als einmal aufgerufen werden, ohne ihre
   Umgebung zu verändern, was wichtig ist, wenn z.B. ein Funktionsabschluss
   mehrere Male gleichzeitig aufgerufen wird. Funktionsabschlüsse, die keine
   Werte aus ihrer Umgebung erfassen, implementieren `Fn`.

Schauen wir uns die Definition der Methode `unwrap_or_else` auf `Option<T>` an,
die wir in Codeblock 13-6 verwendet haben:

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

Als Nächstes ist zu beachten, dass die Funktion `unwrap_or_else` einen
zusätzlichen generischen Typ-Parameter `F` hat. Der Typ `F` ist der Typ des
Parameters namens `f`, der der Funktionsabschluss ist, den wir beim Aufruf von
`unwrap_or_else` bereitstellen.

Die für den generischen Typ `F` spezifizierte Merkmalsabgrenzung ist `FnOnce()
-> T`, was bedeutet, dass `F` mindestens einmal aufgerufen werden können muss,
keine Argumente annimmt und ein `T` zurückgeben muss. Die Verwendung von
`FnOnce` in der Merkmalsabgrenzung drückt die Einschränkung aus, dass
`unwrap_or_else` `f` höchstens ein Mal aufrufen wird. Im Rumpf von
`unwrap_or_else` können wir sehen, dass, wenn die `Option` `Some` ist, `f`
nicht aufgerufen wird. Wenn die `Option` `None` ist, wird `f` einmal
aufgerufen. Da alle Funktionsabschlüsse `FnOnce` implementieren, akzeptiert
`unwrap_or_else` die unterschiedlichsten Arten von Funktionsabschlüssen und ist
so flexibel wie nur möglich.

> Anmerkung: Funktionen können auch alle drei `Fn`-Merkmale implementieren.
> Wenn das, was wir tun wollen, keine Erfassung eines Wertes aus der Umgebung
> erfordert, können wir den Namen einer Funktion anstelle eines
> Funktionsabschlüsses verwenden, bei dem wir etwas brauchen, das eine der
> `Fn`-Markmale implementiert. Zum Beispiel könnten wir bei einem
> `Option<Vec<T>>`-Wert `unwrap_or_else(Vec::new)` aufrufen, um einen neuen,
> leeren Vektor zu erhalten, wenn der Wert `None` ist.

Schauen wir uns nun die Standard-Bibliotheksmethode `sort_by_key` an, die auf
Anteilstypen (slices) definiert ist, um zu sehen, wie sie sich unterscheidet.
Sie nimmt einen Funktionsabschluss, die `FnMut` implementiert. Der
Funktionsabschluss erhält ein Argument, eine Referenz auf das aktuelle Element
im betrachteten Anteilstyp, und gibt einen Wert vom Typ `K` zurück, der
geordnet werden kann. Diese Funktion ist nützlich, wenn man einen Anteilstyp
nach einem bestimmten Attribut der einzelnen Elemente sortieren will. In
Codeblock 13-7 haben wir eine Liste von `Rectangle`-Instanzen und benutzen
`sort_by_key`, um sie nach ihrem `width`-Attribut von niedrig nach hoch zu
sortieren:

<span class="filename">Dateiname: src/main.rs</span>

```rust
#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32,
}

fn main() {
    let mut list = [
        Rectangle {
            width: 10,
            height: 1,
        },
        Rectangle {
            width: 3,
            height: 5,
        },
        Rectangle {
            width: 7,
            height: 12,
        },
    ];

    list.sort_by_key(|r| r.width);
    println!("{:#?}", list);
}
```

<span class="caption">Codeblock 13-7: Verwendung von `sort_by_key` und eines
Funktionsabschlusses zum Sortieren einer Liste von `Rectangle`-Instanzen nach
ihrem `width`-Wert</span>

Dieser Code gibt aus:

```console
$ cargo run
   Compiling rectangles v0.1.0 (file:///projects/rectangles)
    Finished dev [unoptimized + debuginfo] target(s) in 0.41s
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

Der Grund, warum `sort_by_key` so definiert ist, dass es einen
`FnMut`-Funktionsabschluss nimmt, ist, dass es den Funktionsabschluss mehrfach
aufruft: Einmal für jedes Element im Anteilstyp. Der Funktionsabschluss `|r|
r.width` erfasst, verändert oder verschiebt nichts aus seiner Umgebung, sodass
er die Anforderungen der Merkmalsabgrenzung erfüllt.

Im Gegensatz dazu zeigt Codeblock 13-8 ein Beispiel für einen
Funktionsabschluss, die nur `FnOnce` implementiert, weil er einen Wert aus der
Umgebung verschiebt. Der Compiler lässt uns diesen Funktionsabschluss nicht mit
`sort_by_key` verwenden:

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore,does_not_compile
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
    let value = String::from("by key called");

    list.sort_by_key(|r| {
        sort_operations.push(value);
        r.width
    });
    println!("{:#?}", list);
}
```

<span class="caption">Listing 13-8: Versuch, einen `FnOnce`-Funktionsabschluss
mit `sort_by_key` zu verwenden</span>

Dies ist ein ausgeklügelter, verworrener Weg (der nicht funktioniert), um zu
versuchen, die Anzahl der Aufrufe von `sort_by_key` beim Sortieren von `list`
zu zählen. Dieser Code versucht, diese Zählung durchzuführen, indem er `value`,
einen `String` aus der Umgebung des Funktionsabschlusses, in den
`sort_operations`-Vektor schiebt. Der Funktionsabschluss erfasst `value` und
verschiebt dann `value` aus dem Funktionsabschluss heraus, indem er die
Eigentümerschaft von `value` an den Vektor `sort_operations` überträgt. Dieser
Funktionsabschluss kann einmal aufgerufen werden; ein zweiter Aufruf würde nicht
funktionieren, da `value` nicht mehr in der Umgebung wäre, um erneut in
`sort_operations` verschoben zu werden! Daher implementiert dieser
Funktionsabschluss nur `FnOnce`. Wenn wir versuchen, diesen Code zu
kompilieren, erhalten wir die Fehlermeldung, dass `value` nicht aus dem
Funktionsabschluss verschoben werden kann, weil der Funktionsabschluss `FnMut`
implementieren muss:

```console
$ cargo run
   Compiling rectangles v0.1.0 (file:///projects/rectangles)
error[E0507]: cannot move out of `value`, a captured variable in an `FnMut` closure
  --> src/main.rs:27:30
   |
24 |       let value = String::from("by key called");
   |           ----- captured outer variable
25 | 
26 |       list.sort_by_key(|r| {
   |  ______________________-
27 | |         sort_operations.push(value);
   | |                              ^^^^^ move occurs because `value` has type `String`, which does not implement the `Copy` trait
28 | |         r.width
29 | |     });
   | |_____- captured by this `FnMut` closure

For more information about this error, try `rustc --explain E0507`.
error: could not compile `rectangles` due to previous error
```

Der Fehler bezieht sich auf die Zeile im Funktionsabschluss-Rumpf, die `value`
aus der Umgebung verschiebt. Um dies zu beheben, müssen wir den Rumpf des
Funktionsabschlusses so ändern, dass er keine Werte aus der Umgebung
verschiebt. Wenn wir daran interessiert sind, wie oft `sort_by_key` aufgerufen
wird, ist es einfacher, einen Zähler in der Umgebung zu halten und seinen Wert
im Funktionsabschluss-Rumpf zu erhöhen, um das zu berechnen. Der
Funktionsabschluss in Codeblock 13-9 funktioniert mit `sort_by_key`, weil er
nur eine veränderliche Referenz auf den `num_sort_operations`-Zähler erfasst
und daher mehr als einmal aufgerufen werden kann:

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
    println!("{:#?}, sortiert in {num_sort_operations} Operationen", list);
}
```

<span class="caption">Listing 13-9: Verwenden eines
`FnMut`-Funktionsabschlusses mit `sort_by_key` ist erlaubt</span>

Die `Fn`-Merkmale sind wichtig bei der Definition oder Verwendung von
Funktionen oder Typen, die Funktionsabschlüsse verwenden. Der nächste Abschnitt
bespricht Iteratoren, und viele Iterator-Methoden nehmen
Funktionsabschluss-Argumente entgegen. Behalte diese Details von
Funktionsabschlüssen im Kopf, wenn wir Iteratoren erforschen!

[unwrap-or-else]: https://doc.rust-lang.org/std/option/enum.Option.html#method.unwrap_or_else
