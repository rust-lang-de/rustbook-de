## Mit Modulen den Kontrollumfang und Datenschutz steuern

In diesem Abschnitt werden wir über Module und andere Teile des Modulsystems
sprechen, nämlich _Pfade_, die es dir erlauben, Elemente zu benennen; das
Schlüsselwort `use`, das einen Pfad in den Gültigkeitsbereich bringt; und das
Schlüsselwort `pub`, um Elemente öffentlich zu machen. Wir werden auch das
Schlüsselwort `as`, externe Pakete und den Stern-Operator (glob operator)
besprechen.

### Spickzettel für Module

Bevor wir zu den Details von Modulen und Pfaden kommen, stellen wir hier eine
kurze Referenz zusammen, wie Module, Pfade, das Schlüsselwort `use` und das
Schlüsselwort `pub` im Compiler funktionieren und wie die meisten Entwickler
ihren Code organisieren. Wir werden im Laufe dieses Kapitels Beispiele für jede
dieser Regeln durchgehen, aber dies ist ein guter Ort, um sich daran zu
erinnern, wie Module funktionieren.

- **Beginne bei der Kistenwurzel (crate root)**: Beim Kompilieren einer Kiste
  sucht der Compiler zuerst in der Wurzeldatei der Kiste (normalerweise
  _src/lib.rs_ für eine Bibliothekskiste oder _src/main.rs_ für eine
  Binärkiste).
- **Module deklarieren**: In der Kisten-Stammdatei kannst du neue Module
  deklarieren; z.B. deklarierst du ein „Garten“-Modul mit `mod garden;`. Der
  Compiler wird an diesen Stellen nach dem Code des Moduls suchen:
    - In der Zeile direkt nach `mod garden`, in geschweiften Klammern anstelle
      des Semikolons
    - In der Datei _src/garden.rs_
    - In der Datei _src/garden/mod.rs_
- **Submodule deklarieren**: In jeder anderen Datei als der Kistenwurzel
  kannst du Untermodule deklarieren. Du kannst zum Beispiel `mod vegetables;`
  in _src/garden.rs_ deklarieren. Der Compiler sucht den Code des Submoduls in
  dem Verzeichnis, das nach dem übergeordneten Modul benannt ist, an folgenden
  Stellen:
    - In der Zeile direkt nach `mod vegetables`, in geschweiften Klammern
      anstelle des Semikolons
    - In der Datei _src/garden/vegetables.rs_
    - In der Datei _src/garden/vegetables/mod.rs_
- **Pfade zum Code in Modulen**: Sobald ein Modul Teil deiner Kiste ist, kannst
  du auf den Code in diesem Modul von jedem anderen Ort in derselben Kiste aus
  referenzieren, solange die Datenschutzregeln dies zulassen, indem du den Pfad
  zum Code verwendest. Zum Beispiel würde ein Typ `Asparagus` (engl. Spargel)
  im Gartengemüse-Modul unter `crate::garden::vegetables::Asparagus` zu finden
  sein.
- **Privat vs. öffentlich**: Der Code innerhalb eines Moduls ist standardmäßig
  für seine übergeordneten Module nicht zugänglich. Um ein Modul öffentlich zu
  machen, deklariere es mit `pub mod` anstelle von `mod`. Um Elemente innerhalb
  eines öffentlichen Moduls ebenfalls öffentlich zu machen, verwende `pub` vor
  ihren Deklarationen.
- **Das Schlüsselwort `use`**: Innerhalb eines Gültigkeitsbereichs werden mit
  dem Schlüsselwort `use` Verknüpfungen zu Elementen erstellt, um die
  Wiederholung langer Pfade zu reduzieren. In jedem Gültigkeitsbereichs, der
  auf `crate::garden::vegetables::Asparagus` referenzieren kann, kann man eine
  Verknüpfung mit `use crate::garden::vegetables::Asparagus` erstellen und von
  da an braucht man nur noch `Asparagus` zu schreiben, um diesen Typ im
  Gültigkeitsbereich zu verwenden.

Hier erstellen wir eine binäre Kiste namens `backyard` (Hinterhof), die diese
Regeln veranschaulicht. Das Verzeichnis der Kiste, ebenfalls `backyard`
genannt, enthält diese Dateien und Verzeichnisse:

```text
backyard
├── Cargo.lock
├── Cargo.toml
└── src
    ├── garden
    │   └── vegetables.rs
    ├── garden.rs
    └── main.rs
```

Die Stammdatei der Kiste ist in diesem Fall _src/main.rs_, und sie enthält:

<span class="filename">Dateiname: src/main.rs</span>

```rust,noplayground,ignore
use crate::garden::vegetables::Asparagus;

pub mod garden;

fn main() {
    let plant = Asparagus {};
    println!("Ich baue {plant:?} an!");
}
```

Die Zeile `pub mod garden;` weist den Compiler an, den Code einzubinden, den er
in _src/garden.rs_ findet, nämlich:

<span class="filename">Dateiname: src/garden.rs</span>

```rust,noplayground,ignore
pub mod vegetables;
```

Hier bedeutet `pub mod vegetables;`, dass der Code in
_src/garden/vegetables.rs_ ebenfalls enthalten ist. Dieser Code ist:

```rust,noplayground,ignore
#[derive(Debug)]
pub struct Asparagus {}
```

Lass uns nun auf die Einzelheiten dieser Regeln eingehen und sie in der Praxis demonstrieren!

### Gruppierung von zugehörigem Code in Modulen

_Module_ ermöglichen es uns, den Code innerhalb einer Kiste zu organisieren,
damit er lesbar und leicht wiederverwendbar ist. Mit Modulen können wir auch
den _Datenschutz_ (privacy) von Elementen kontrollieren, da Code innerhalb
eines Moduls standardmäßig privat ist. Private Elemente sind interne
Implementierungsdetails, die nicht für die externe Nutzung zur Verfügung
stehen. Wir können uns dafür entscheiden, Module und die darin enthaltenen
Elemente öffentlich zu machen, damit externer Code sie verwenden und von ihnen
abhängen kann.

Als Beispiel schreiben wir eine Bibliothekskiste, die die Funktionalität eines
Restaurants bietet. Wir werden die Signaturen der Funktionen definieren, aber
ihre Rümpfe leer lassen, um uns auf die Organisation des Codes zu konzentrieren
und nicht auf die Implementierung eines Restaurants.

Im Gaststättengewerbe werden einige Teile eines Restaurants als _Vorderseite
des Hauses_ und andere als _Hinterseite des Hauses_ bezeichnet. Auf der
Vorderseite des Hauses sind die Kunden; hier setzen Gastgeber ihre Kunden hin,
Kellner nehmen Bestellungen auf und rechnen ab und Barkeeper machen die
Getränke. Auf der Hinterseite des Hauses arbeiten die Küchenchefs und Köche in
der Küche, Geschirrspüler waschen ab und Manager erledigen Verwaltungsarbeiten.

Um unsere Kiste auf diese Weise zu strukturieren, können wir ihre Funktionen in
verschachtelten Modulen organisieren. Erstelle eine neue Bibliothek namens
`restaurant`, indem du `cargo new --lib restaurant` ausführst. Gib dann den
Code in Codeblock 7-1 in _src/lib.rs_ ein, um einige Module und
Funktionssignaturen zu definieren. Hier ist der vordere Teil des Hauses:

<span class="filename">Dateiname: src/lib.rs</span>

```rust,noplayground
mod front_of_house {
    mod hosting {
        fn add_to_waitlist() {}

        fn seat_at_table() {}
    }

    mod serving {
        fn take_order() {}

        fn serve_order() {}

        fn take_payment() {}
    }
}
```

<span class="caption">Codeblock 7-1: Ein Modul `front_of_house`, das andere
Module enthält, die dann Funktionen enthalten</span>

Wir definieren ein Modul mit dem Schlüsselwort `mod`, gefolgt vom Namen des
Moduls (in diesem Fall `front_of_house`). Der Rumpf des Moduls steht dann in
geschweiften Klammern. Innerhalb von Modulen können wir andere Module
platzieren, wie in diesem Fall mit den Modulen `hosting` und `serving`. Module
können auch Definitionen für andere Elemente enthalten, wie Strukturen,
Aufzählungen, Konstanten, Merkmalen und &ndash; wie in Codeblock 7-1 &ndash;
Funktionen.

Durch die Verwendung von Modulen können wir verwandte Definitionen gruppieren
und angeben, warum sie verwandt sind. Programmierer, die diesen Code verwenden,
können anhand der Gruppen durch den Code navigieren, anstatt alle Definitionen
lesen zu müssen, und finden so leichter die für sie relevanten Definitionen.
Programmierer, die diesem Code neue Funktionalität hinzufügen, wissen, wo sie
den Code platzieren müssen, damit das Programm übersichtlich bleibt.

Vorhin haben wir erwähnt, dass _src/main.rs_ und _src/lib.rs_ als Kistenwurzel
bezeichnet werden. Der Grund für ihren Namen ist, dass der Inhalt dieser beiden
Dateien ein Modul namens `crate` an der Wurzel der Modulstruktur der Kiste
bilden, die als _Modulbaum_ bekannt ist.

Codeblock 7-2 zeigt den Modulbaum für die Struktur in Codeblock 7-1.

```text
crate
 └── front_of_house
     ├── hosting
     │   ├── add_to_waitlist
     │   └── seat_at_table
     └── serving
         ├── take_order
         ├── serve_order
         └── take_payment
```

<span class="caption">Codeblock 7-2: Modulbaum für den Code in Codeblock
7-1</span>

Dieser Baum zeigt, wie einige Module in anderen Modulen verschachtelt sind;
z.B. ist `hosting` innerhalb von `front_of_house`. Der Baum zeigt auch, dass
einige Module _Geschwister_ sind, was bedeutet, dass sie im selben Modul
definiert sind; `hosting` und `serving` sind Geschwister, die innerhalb von
`front_of_house` definiert sind. Wenn Modul A innerhalb von Modul B enthalten
ist, sagen wir, dass Modul A das _Kind_ (child) von Modul B ist und dass Modul
B der _Elternteil_ (parent) von Modul A ist. Beachte, dass der gesamte
Modulbaum als Wurzel das implizite Modul namens `crate` hat.

Der Modulbaum könnte dich an den Verzeichnisbaum des Dateisystems auf deinem
Computer erinnern; dies ist ein sehr treffender Vergleich! Genau wie
Verzeichnisse in einem Dateisystem verwendest du Module, um deinen Code zu
organisieren. Und genau wie Dateien in einem Verzeichnis brauchen wir einen
Weg, unsere Module zu finden.
