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

Das Verwenden eines Semikolons nach `mod front_of_house` anstelle eines Blocks
weist Rust an, den Inhalt des Moduls aus einer anderen Datei mit dem gleichen
Namen wie das Modul zu laden. Um mit unserem Beispiel fortzufahren und das
Modul `hosting` ebenfalls in seine eigene Datei zu extrahieren, ändern wir
*src/front_of_house.rs* so, dass es nur die Deklaration des Moduls `hosting`
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

Der Modulbaum bleibt derselbe und die Funktionsaufrufe in `eat_at_restaurant`
funktionieren ohne jede Änderung, auch wenn sich die Definitionen in
verschiedenen Dateien befinden. Mit dieser Technik kannst du Module in neue
Dateien verschieben, wenn diese größer werden.

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
