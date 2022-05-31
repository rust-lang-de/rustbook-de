## Module in verschiedene Dateien aufteilen

Bisher haben alle Beispiele in diesem Kapitel mehrere Module in einer Datei
definiert. Wenn Module groß werden, solltest du ihre Definitionen in eine
separate Datei verschieben, um die Navigation im Code zu erleichtern.

Beginnen wir beispielsweise mit dem Code in Codeblock 7-17 und verschieben das
Modul `front_of_house` in seine eigene Datei *src/front_of_house.rs*, indem wir
die Kistenwurzeldatei so ändern, dass sie den in Codeblock 7-21 gezeigten Code
enthält. In diesem Fall ist die Kistenwurzeldatei *src/lib.rs*, aber dieses
Vorgehensweise funktioniert auch mit binären Kisten, deren Kistenwurzeldatei
*src/main.rs* ist.

<span class="filename">Dateiname: src/lib.rs</span>

```rust,ignore
mod front_of_house;

pub use crate::front_of_house::hosting;

pub fn eat_at_restaurant() {
    hosting::add_to_waitlist();
    hosting::add_to_waitlist();
    hosting::add_to_waitlist();
}
```

<span class="caption">Codeblock 7-21: Deklarieren des Moduls `front_of_house`,
dessen Rumpf sich in *src/front_of_house.rs* befinden wird</span>

Und *src/front_of_house.rs* erhält die Definitionen aus dem Modulrumpf von
`front_of_house`, wie in Codeblock 7-22 zu sehen ist.

<span class="filename">Dateiname: src/front_of_house.rs</span>

```rust,ignore
pub mod hosting {
    pub fn add_to_waitlist() {}
}
```

<span class="caption">Codeblock 7-22: Definitionen innerhalb des Moduls
`front_of_house` in *src/front_of_house.rs*</span>

Beachte, dass du eine Datei mit einer `mod`-Deklaration nur *einmal* in deinem
Modulbaum laden musst. Sobald der Compiler weiß, dass die Datei Teil des
Projekts ist (und weiß, wo im Modulbaum sich der Code befindet, weil du die
`mod`-Anweisung eingefügt hast), sollten andere Dateien in deinem Projekt auf
den Code der geladenen Datei referenzieren, indem sie einen Pfad zu der Stelle
verwenden, an der er deklariert wurde, wie im Abschnitt [„Mit Pfaden auf ein
Element im Modulbaum verweisen“][Pfade] beschrieben. Mit anderen Worten: `mod`
ist *keine* „include“-Operation, wie du sie vielleicht aus anderen
Programmiersprachen kennst.

Als Nächstes extrahieren wir das Modul `hosting` in seine eigene Datei. Der
Prozess ist ein bisschen anders, weil `hosting` ein untergeordnetes Modul von
`front_of_house` ist, nicht vom Stammmodul. Wir legen die Datei für `hosting`
in einem neuen Verzeichnis ab, das nach seinen Vorgängern im Modulbaum benannt
wird, in diesem Fall *src/front_of_house/*.

Um mit dem Verschieben von `hosting` zu beginnen, ändern wir
*src/front_of_house.rs* so, dass es nur die Deklaration des `hosting`-Moduls
enthält:

<span class="filename">Dateiname: src/front_of_house.rs</span>

```rust,ignore
pub mod hosting;
```

Dann erstellen wir ein Verzeichnis *src/front_of_house* und eine Datei
*src/front_of_house/hosting.rs*, die die im Modul `hosting` vorgenommenen
Definitionen enthält:

<span class="filename">Dateiname: src/front_of_house/hosting.rs</span>

```rust
pub fn add_to_waitlist() {}
```

Wenn wir stattdessen *hosting.rs* in das *src*-Verzeichnis legen, würde der
Compiler erwarten, dass der *hosting.rs*-Code in einem `hosting`-Modul
enthalten ist, das im Stammverzeichnis der Kiste deklariert ist, und nicht als
Kind des `front_of_house`-Moduls. Die Regeln des Compilers dafür, welche
Dateien auf den Code welcher Module zu prüfen sind, bedeuten, dass die
Verzeichnisse und Dateien dem Modulbaum besser entsprechen.

> ### Alternative Dateipfade
>
> Bis jetzt haben wir die idiomatischsten Dateipfade behandelt, die der
> Rust-Compiler verwendet, aber Rust unterstützt auch eine ältere Art von
> Dateipfaden. Für ein Modul mit dem Namen `front_of_house`, das in der
> Kistenwurzel deklariert ist, sucht der Compiler den Code des Moduls in:
>
> * *src/front_of_house.rs* (was wir behandelt haben)
> * *src/front_of_house/mod.rs* (älterer Stil, noch unterstützter Pfad)
>
> Bei einem Modul mit dem Namen `hosting`, das ein Untermodul von
> `front_of_house` ist, sucht der Compiler den Code des Moduls in:
>
> * *src/front_of_house/hosting.rs* (was wir behandelt haben)
> * *src/front_of_house/hosting/mod.rs* (älterer Stil, noch unterstützter Pfad)
>
> Wenn du beide Stile für dasselbe Modul verwendest, erhältst einen
> Compilerfehler. Die Verwendung beider Stile für verschiedene Module im selben
> Projekt ist zulässig, kann aber für die Benutzer verwirrend sein, die durch
> dein Projekt navigieren.
>
> Der größte Nachteil des Stils, der Dateien mit dem Namen *mod.rs* verwendet,
> ist, dass dein Projekt am Ende viele Dateien mit dem Namen *mod.rs* haben
> kann, was verwirrend sein kann, wenn du sie gleichzeitig in deinem Editor
> geöffnet hast.

Wir haben den Code jedes Moduls in eine separate Datei verschoben, und der
Modulbaum bleibt derselbe. Die Funktionsaufrufe in `eat_at_restaurant`
funktionieren ohne jede Änderung, auch wenn die Definitionen in verschiedenen
Dateien stehen. Mit dieser Technik kannst du Module in neue Dateien
verschieben, wenn diese größer werden.

Beachte, dass sich die Anweisung `pub use crate::front_of_house::hosting` in
*src/lib.rs* ebenfalls nicht geändert hat und dass `use` keinen Einfluss darauf
hat, welche Dateien als Teil der Kiste kompiliert werden. Das Schlüsselwort
`mod` deklariert Module und Rust sucht in einer Datei mit dem Modulnamen nach
dem Code, der zu diesem Modul gehört.

## Zusammenfassung

Mit Rust kannst du ein Paket in mehrere Kisten und eine Kiste in Module
aufteilen, sodass du auf in einem Modul definierte Elemente aus einem anderen
Modul verweisen kannst. Du kannst dies tun, indem du absolute oder relative
Pfade angibst. Diese Pfade können mit einer `use`-Anweisung in den
Gültigkeitsbereich gebracht werden, sodass du einen kürzeren Pfad für mehrere
Verwendungen des Elements in diesem Gültigkeitsbereich angeben kannst. Der
Modulcode ist standardmäßig privat, aber du kannst Definitionen öffentlich
machen, indem du das Schlüsselwort `pub` angibst.

Im nächsten Kapitel werden wir uns einige Kollektionsdatenstrukturen in der
Standardbibliothek ansehen, die du in deinem ordentlich organisierten Code
verwenden kannst.

[paths]: ch07-03-paths-for-referring-to-an-item-in-the-module-tree.html
