## Pfade in den Gültigkeitsbereich bringen mit dem Schlüsselwort `use`

Es mag den Anschein haben, als seien die Pfade, die wir bisher geschrieben
haben, um Funktionen aufzurufen, unangenehm lang und wiederholend. Zum Beispiel
mussten wir in Codeblock 7-7, unabhängig davon, ob wir den absoluten oder
relativen Pfad zur Funktion `add_to_waitlist` wählten, bei jedem Aufruf von
`add_to_waitlist` auch `front_of_house` und `hosting` angeben. Glücklicherweise
gibt es einen Weg, diesen Vorgang zu vereinfachen. Wir können einen Pfad mit
dem Schlüsselwort `use` einmalig in einen Gültigkeitsbereich bringen und dann
die Elemente in diesem Pfad so aufrufen, als ob es sich um lokale Elemente
handelt. In Codeblock 7-11 bringen wir das Modul
`crate::front_of_house::hosting` in den Gültigkeitsbereich der Funktion
`eat_at_restaurant`, sodass wir nur noch `hosting::add_to_waitlist` angeben
müssen, um die Funktion `add_to_waitlist` in `eat_at_restaurant` aufzurufen.

<span class="filename">Dateiname: src/lib.rs</span>

```rust,noplayground,test_harness
mod front_of_house {
    pub mod hosting {
        pub fn add_to_waitlist() {}
    }
}

use crate::front_of_house::hosting;

pub fn eat_at_restaurant() {
    hosting::add_to_waitlist();
    hosting::add_to_waitlist();
    hosting::add_to_waitlist();
}
```

<span class="caption">Codeblock 7-11: Ein Modul mit `use` in den
Gültigkeitsbereich bringen</span>

Das Angeben von `use` und einem Pfad in einem Gültigkeitsbereich ist ähnlich
dem Erstellen eines symbolischen Links im Dateisystem. Durch Hinzufügen von
`use crate::front_of_house::hosting` in der Kistenwurzel ist `hosting` nun ein
gültiger Name in diesem Gültigkeitsbereich, so als wäre das Modul `hosting` in
der Kistenwurzel definiert worden. Pfade, die mit `use` in den
Gültigkeitsbereich gebracht werden, überprüfen wie alle anderen Pfade auch die
Privatsphäre.

Du kannst ein Element auch mit `use` und einem relativen Pfad in den
Gültigkeitsbereich bringen. In Codeblock 7-12 wird gezeigt, wie ein relativer
Pfad angegeben werden kann, um dasselbe Verhalten wie in Codeblock 7-11 zu
erzielen.

<span class="filename">Dateiname: src/lib.rs</span>

```rust,noplayground,test_harness
mod front_of_house {
    pub mod hosting {
        pub fn add_to_waitlist() {}
    }
}

use self::front_of_house::hosting;

pub fn eat_at_restaurant() {
    hosting::add_to_waitlist();
    hosting::add_to_waitlist();
    hosting::add_to_waitlist();
}
```

<span class="caption">Codeblock 7-12: Ein Modul mit `use` und einem relativen
Pfad in den Gültigkeitsbereich bringen</span>

### Idiomatische `use`-Pfade erstellen

In Codeblock 7-11 hast du dich vielleicht gefragt, warum wir `use
crate::front_of_house::hosting` angegeben und dann `hosting::add_to_waitlist`
in `eat_at_restaurant` aufgerufen haben, anstatt den `use`-Pfad bis hin zur
Funktion `add_to_waitlist` anzugeben, um dasselbe Ergebnis zu erzielen wie in
Codeblock 7-13.

<span class="filename">Dateiname: src/lib.rs</span>

```rust,noplayground,test_harness
mod front_of_house {
    pub mod hosting {
        pub fn add_to_waitlist() {}
    }
}

use crate::front_of_house::hosting::add_to_waitlist;

pub fn eat_at_restaurant() {
    add_to_waitlist();
    add_to_waitlist();
    add_to_waitlist();
}
```

<span class="caption">Codeblock 7-13: Die Funktion `add_to_waitlist` mit `use`
in den Gültigkeitsbereich bringen ist nicht idiomatisch.</span>

Obwohl sowohl Codeblock 7-11 als auch Codeblock 7-13 die gleiche Aufgabe
erfüllen, ist Codeblock 7-11 der idiomatische Weg, eine Funktion mit `use` in
den Gültigkeitsbereich zu bringen. Wenn wir das Elternmodul der Funktion mit
`use` in den Gültigkeitsbereich bringen, sodass wir das Elternmodul beim Aufruf
der Funktion angeben müssen, wird klar, dass die Funktion nicht lokal definiert
ist, während gleichzeitig die Wiederholung des vollständigen Pfades minimiert
wird. Im Code in Codeblock 7-13 ist unklar, wo `add_to_waitlist` definiert ist.

Wenn andererseits Strukturen, Aufzählungen und andere Elemente mit `use`
eingebracht werden, ist es idiomatisch, den vollständigen Pfad anzugeben.
Codeblock 7-14 zeigt den idiomatischen Weg, die Struktur `HashMap` der
Standardbibliothek in den Gültigkeitsbereich einer binären Kiste zu bringen.

<span class="filename">Dateiname: src/main.rs</span>

```rust
use std::collections::HashMap;

fn main() {
    let mut map = HashMap::new();
    map.insert(1, 2);
}
```

<span class="caption">Codeblock 7-14: `HashMap` auf idiomatische Weise in den
Gültigkeitsbereich bringen</span>

Es gibt keinen triftigen Grund für dieses Idiom: Es ist einfach eine
Konvention, die entstanden ist, und die Leute haben sich daran gewöhnt,
Rust-Code auf diese Weise zu lesen und zu schreiben.

Die Ausnahme von diesem Idiom ist, wenn wir zwei gleichnamige Elemente mit
`use` in den Gültigkeitsbereich bringen, denn das lässt Rust nicht zu. In
Codeblock 7-15 wird gezeigt, wie zwei `Result`-Typen mit gleichem Namen, aber
unterschiedlichen Elternmodulen in den Gültigkeitsbereich gebracht werden und
wie auf sie verwiesen werden kann.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
use std::fmt;
use std::io;

fn function1() -> fmt::Result {
    // --abschneiden--
    Ok(())
}

fn function2() -> io::Result<()> {
    // --abschneiden--
    Ok(())
}
```

<span class="caption">Codeblock 7-15: Um zwei Typen mit dem gleichen Namen in
denselben Gültigkeitsbereich zu bringen, müssen ihre übergeordneten Module
angegeben werden.</span>

Wie du sehen kannst, unterscheidet die Verwendung der übergeordneten Module die
beiden `Result`-Typen. Wenn wir stattdessen `use std::fmt::Result` und
`use std::io::Result` angeben würden, hätten wir zwei `Result`-Typen im selben
Gültigkeitsbereich und Rust wüsste nicht, welchen wir beim Verwenden von
`Result` meinten.

### Mit dem Schlüsselwort `as` neue Namen vergeben

Es gibt eine andere Lösung für das Problem, zwei Typen desselben Namens mit
`use` in den gleichen Gültigkeitsbereich zu bringen: Hinter dem Pfad können wir
`as` und einen neuen lokalen Namen oder Alias für den Typ angeben. Codeblock
7-16 zeigt eine weitere Möglichkeit, den Code in Codeblock 7-15 zu schreiben,
indem einer der beiden `Result`-Typen mittels `as` umbenannt wird.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
use std::fmt::Result;
use std::io::Result as IoResult;

fn function1() -> Result {
    // --abschneiden--
    Ok(())
}

fn function2() -> IoResult<()> {
    // --abschneiden--
    Ok(())
}
```

<span class="caption">Codeblock 7-16: Umbenennen eines Typs, wenn er mit dem
Schlüsselwort `as` in den Gültigkeitsbereich gebracht wird</span>

In der zweiten `use`-Anweisung wählten wir den neuen Namen `IoResult` für den
Typ `std::io::result`, der nicht im Konflikt zum ebenfalls von uns in den
Gültigkeitsbereich gebrachten `Result` aus `std::fmt` steht. Codeblock 7-15
und Codeblock 7-16 gelten als idiomatisch, die Wahl liegt also bei dir!

### Rück-Exportieren von Namen mit `pub use`

Wenn wir einen Namen mit dem Schlüsselwort `use` in den Gültigkeitsbereich
bringen, ist der im neuen Gültigkeitsbereich verfügbare Name privat. Damit der
Code, der unseren Code aufruft, auf diesen Namen verweisen kann, als wäre er im
Gültigkeitsbereich dieses Codes definiert worden, können wir `pub` und `use`
kombinieren. Diese Technik wird *Rück-Exportieren* (re-exporting) genannt, weil
wir ein Element in den Gültigkeitsbereich bringen, dieses Element aber auch
anderen zur Verfügung stellen, um es in ihren Gültigkeitsbereich zu bringen.

Codeblock 7-17 zeigt den Code in Codeblock 7-11, wobei `use` im Wurzelmodul in
`pub use` geändert wurde.

<span class="filename">Dateiname: src/lib.rs</span>

```rust,noplayground,test_harness
mod front_of_house {
    pub mod hosting {
        pub fn add_to_waitlist() {}
    }
}

pub use crate::front_of_house::hosting;

pub fn eat_at_restaurant() {
    hosting::add_to_waitlist();
    hosting::add_to_waitlist();
    hosting::add_to_waitlist();
}
```

<span class="caption">Codeblock 7-17: Bereitstellen eines Namens für externen
Code zum Verwenden in einem neuen Gültigkeitsbereich mit `pub use`</span>

Durch Verwenden von `pub use` kann jetzt externer Code die Funktion
`add_to_waitlist` unter Verwendung von `hosting::add_to_waitlist` aufrufen.
Hätten wir nicht `pub use` angegeben, könnte die Funktion `eat_at_restaurant`
in ihrem Gültigkeitsbereich `hosting::add_to_waitlist` aufrufen, aber externer
Code könnte diesen neuen Pfad nicht nutzen.

Der Rück-Export ist nützlich, wenn sich die interne Struktur deines Codes von
dem unterscheidet, wie Programmierer, die deinen Code
aufrufen, über die Domäne denken würden. In der Restaurantmetapher denken die
Betreiber des Restaurants zum Beispiel an die „Vorderseite des Hauses“ und die
„Rückseite des Hauses“. Mit `pub use` können wir unseren Code mit einer
Struktur schreiben, aber eine andere Struktur veröffentlichen. Auf diese Weise
ist unsere Bibliothek für Programmierer, die an der Bibliothek arbeiten, und
Programmierer, die die Bibliothek aufrufen, gut organisiert.

### Verwenden externer Pakete

In Kapitel 2 programmierten wir ein Ratespielprojekt, das ein externes Paket
namens `rand` benutzte, um Zufallszahlen zu generieren. Um `rand` in unserem
Projekt zu verwenden, fügten wir diese Zeile zu *Cargo.toml* hinzu:

<span class="filename">Dateiname: Cargo.toml</span>

```toml
[dependencies]
rand = "0.5.5"
```

Das Hinzufügen von `rand` als Abhängigkeit in *Cargo.toml* weist Cargo an, das
Paket `rand` und alle Abhängigkeiten von [crates.io](https://crates.io/)
herunterzuladen und `rand` für unser Projekt verfügbar zu machen.

Um dann Definitionen von `rand` in den Gültigkeitsbereich unseres Pakets
aufzunehmen, haben wir eine Zeile mit `use` hinzugefügt, die mit dem
Kistennamen `rand` beginnt und die Elemente auflistet, die wir in den
Gültigkeitsbereich bringen wollten. Erinnere dich, dass wir im Abschnitt
[„Generieren einer Geheimzahl“][rand] in Kapitel 2 das Merkmal `Rng` in den
Gültigkeitsbereich gebracht und die Funktion `rand::thread_rng` aufgerufen
haben:

```rust
# use std::io;
use rand::Rng;

fn main() {
#     println!("Rate die Zahl!");
#
    let secret_number = rand::thread_rng().gen_range(1, 101);
#
#     println!("Die geheime Zahl ist: {}", secret_number);
#
#     println!("Bitte gib deine Vermutung ein.");
#
#     let mut guess = String::new();
#
#     io::stdin()
#         .read_line(&mut guess)
#         .expect("Fehler beim Lesen einer Zeile");
#
#     println!("Du hast geraten: {}", guess);
}
```

Mitglieder der Rust-Gemeinschaft haben viele Pakete unter
[crates.io](https://crates.io/) zur Verfügung gestellt und wenn du eines davon
in dein Paket aufnimmst, sind die gleichen Schritte erforderlich: Liste sie
in der Datei *Cargo.toml* deines Pakets auf und verwende `use`, um Elemente aus
ihren Kisten in den Gültigkeitsbereich zu bringen.

Beachte, dass die Standardbibliothek (`std`) ebenfalls eine Kiste ist, die
nicht zu unserem Paket gehört. Da die Standardbibliothek mit der Sprache Rust
ausgeliefert wird, brauchen wir *Cargo.toml* nicht zu ändern, um `std`
einzubinden. Aber wir müssen `use` verwenden, um Elemente von dort in den
Gültigkeitsbereich unseres Pakets zu bringen. Zum Beispiel würden wir für
`HashMap` diese Zeile verwenden:

```rust
use std::collections::HashMap;
```

Dies ist ein absoluter Pfad, der mit `std`, dem Namen der
Standard-Bibliothekskiste, beginnt.

### Verschachtelte Pfade verwenden, um lange `use`-Listen zu vereinfachen

Wenn wir mehrere in der gleichen Kiste oder im gleichen Modul definierte
Elemente verwenden, kann das Auflisten jedes Elements in einer eigenen Zeile
viel vertikalen Platz in unseren Dateien einnehmen. Zum Beispiel bringen diese
beiden `use`-Anweisungen, die wir im Ratespiel in Codeblock 2-4 hatten,
Elemente aus `std` in den Gültigkeitsbereich:

<span class="filename">Dateiname: src/main.rs</span>

```rust
use std::cmp::Ordering;
use std::io;
```

Stattdessen können wir verschachtelte Pfade verwenden, um die gleichen Elemente
in einer Zeile in den Gültigkeitsbereich zu bringen. Wir tun dies, indem wir
den gemeinsamen Teil des Pfades angeben, gefolgt von zwei Doppelpunkten und
dann geschweiften Klammern um Liste der Pfadteile, die sich unterscheiden, wie
in Codeblock 7-18 gezeigt.

<span class="filename">Dateiname: src/main.rs</span>

```rust
use std::{cmp::Ordering, io};
```

<span class="caption">Codeblock 7-18: Angeben eines verschachtelten Pfades, um
mehrere Elemente mit demselben Präfix in den Gültigkeitsbereich zu
bringen</span>

In größeren Programmen kann das Einbeziehen vieler Elemente aus derselben Kiste
oder demselben Modul in den Gültigkeitsbereich durch verschachtelte Pfade die
Anzahl der separaten `use`-Anweisungen um ein Vielfaches reduzieren!

Wir können einen verschachtelten Pfad auf jeder Ebene in einem Pfad verwenden,
was nützlich ist, wenn zwei `use`-Anweisungen kombiniert werden, die sich einen
Teilpfad teilen. Beispielsweise zeigt Codeblock 7-19 zwei `use`-Anweisungen:
Eine, die `std::io` in den Gültigkeitsbereich bringt, und eine, die
`std::io::Write` in den Gültigkeitsbereich bringt.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
use std::io;
use std::io::Write;
```

<span class="caption">Codeblock 7-19: Zwei `use`-Anweisungen, bei denen eine
ein Teilpfad der anderen ist</span>

Der gemeinsame Teil dieser beiden Pfade ist `std::io` und das ist der
vollständige erste Pfad. Um diese beiden Pfade zu einer einzigen
`use`-Anweisung zu verschmelzen, können wir `self` im verschachtelten Pfad
verwenden, wie in Codeblock 7-20 gezeigt wird.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
use std::io::{self, Write};
```

<span class="caption">Codeblock 7-20: Zusammenfassen der Pfade aus Codeblock
7-19 zu einer `use`-Anweisung</span>

Diese Zeile bringt `std::io` und `std::io::Write` in den Gültigkeitsbereich.

### Der Stern-Operator (glob)

Wenn wir *alle* öffentlichen Elemente, die in einem Pfad definiert sind, in den
Gültigkeitsbereich bringen wollen, können wir diesen Pfad gefolgt von `*`, dem
Stern-Operator, angeben:

```rust
use std::collections::*;
```

Diese `use`-Anweisung bringt alle öffentlichen Elemente, die in
`std::collections` definiert sind, in den aktuellen Gültigkeitsbereich. Sei
vorsichtig beim Verwenden des Stern-Operators! Er kann es schwieriger machen,
zu erkennen, welche Namen in den Gültigkeitsbereich fallen und wo ein in deinem
Programm verwendeter Name definiert wurde.

Der Stern-Operator wird oft beim Testen verwendet, um alles, was getestet wird,
in das Modul `tests` zu bringen. Wir werden darüber im Abschnitt [„Tests
schreiben“][writing-tests] in Kapitel 11 sprechen. Der Stern-Operator wird
manchmal auch als Teil des Präludiumsmusters (prelude pattern) verwendet: Siehe
[Standardbibliotheksdokumentation][std-lib-preludes] für weitere Informationen
zu diesem Muster.

[rand]: ch02-00-guessing-game-tutorial.html#generieren-einer-geheimzahl
[std-lib-preludes]: https://doc.rust-lang.org/std/prelude/index.html#other-preludes
[writing-tests]: ch11-01-writing-tests.html
