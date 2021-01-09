## Mit Modulen den Kontrollumfang und Datenschutz steuern

In diesem Abschnitt werden wir über Module und andere Teile des Modulsystems
sprechen, nämlich *Pfade*, die es dir erlauben, Elemente zu benennen; das
Schlüsselwort `use`, das einen Pfad in den Gültigkeitsbereich bringt; und das
Schlüsselwort `pub`, um Elemente öffentlich zu machen. Wir werden auch das
Schlüsselwort `as`, externe Pakete und den Stern-Operator (glob operator)
besprechen. Konzentrieren wir uns vorerst auf die Module!

*Module* lassen uns Code innerhalb einer Kiste in Gruppen organisieren, um ihn
lesbar und leicht wiederverwendbar zu machen. Module kontrollieren auch den
*Datenschutz* (privacy) von Elementen, d.h. ob ein Element von einem externen
Code verwendet werden kann (*öffentlich*) oder ob es sich um ein internes
Implementierungsdetail handelt und nicht für die externe Verwendung verfügbar
ist (*privat*).

Als Beispiel schreiben wir eine Bibliothekskiste, die die Funktionalität eines
Restaurants bietet. Wir werden die Signaturen der Funktionen definieren, aber
ihre Rümpfe leer lassen, um uns auf die Organisation des Codes zu
konzentrieren, anstatt tatsächlich ein Restaurant im Code zu implementieren.

Im Gaststättengewerbe werden einige Teile eines Restaurants als *Vorderseite
des Hauses* und andere als *Hinterseite des Hauses* bezeichnet. Auf der
Vorderseite des Hauses sind die Kunden; hier setzen Gastgeber ihre Kunden hin,
Kellner nehmen Bestellungen auf und rechnen ab und Barkeeper machen die
Getränke. Auf der Hinterseite des Hauses arbeiten die Küchenchefs und Köche in
der Küche, Geschirrspüler waschen ab und Manager erledigen Verwaltungsarbeiten.

Um unsere Kiste so zu strukturieren, wie ein echtes Restaurant funktioniert,
können wir die Funktionen in verschachtelten Modulen organisieren. Erstelle
eine neue Bibliothek namens `restaurant`, indem du `cargo new --lib restaurant`
ausführst; dann schreibe den Code aus Codeblock 7-1 in *src/lib.rs*, um einige
Module und Funktionssignaturen zu definieren.

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

Wir definieren ein Modul, indem wir mit dem Schlüsselwort `mod` beginnen und
dann den Namen des Moduls angeben (in diesem Fall `front_of_house`) und
geschweifte Klammern um den Rumpf des Moduls setzen. Innerhalb von Modulen
können wir andere Module haben, wie in diesem Fall mit den Modulen `hosting`
und `serving`. Module können auch Definitionen für andere Elemente enthalten,
z.B. Strukturen, Aufzählungen, Konstanten, Merkmale oder &ndash; wie in
Codeblock 7-1 &ndash; Funktionen.

Durch die Verwendung von Modulen können wir verwandte Definitionen gruppieren
und benennen, warum sie verwandt sind. Programmierer, die diesen Code
verwenden, hätten es leichter, die Definitionen zu finden, die sie verwenden
wollten, da sie sich anhand der Gruppen im Code bewegen könnten, anstatt alle
Definitionen durchlesen zu müssen. Programmierer, die diesem Code neue
Funktionen hinzufügen, wüssten, wo sie den Code platzieren müssten, um das
Programm zu organisieren.

Vorhin haben wir erwähnt, dass *src/main.rs* und *src/lib.rs* als Kistenwurzel
bezeichnet werden. Der Grund für ihren Namen ist, dass der Inhalt dieser beiden
Dateien ein Modul namens `crate` an der Wurzel der Modulstruktur der Kiste
bilden, die als *Modulbaum* bekannt ist.

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

Dieser Baum zeigt, wie einige der Module ineinander verschachtelt sind (z.B.
ist `hosting` innerhalb von `front_of_house`). Der Baum zeigt auch, dass einige
Module *Geschwister* voneinander sind, was bedeutet, dass sie im selben Modul
definiert sind (`hosting` und `serving` sind innerhalb von `front_of_house`
definiert). Um die Familienmetapher fortzusetzen: Wenn Modul A innerhalb von
Modul B enthalten ist, sagen wir, dass Modul A das *Kind* (child) von Modul B
ist und dass Modul B das *Elter* (parent) von Modul A ist. Beachte, dass der
gesamte Modulbaum als Wurzel das implizite Modul namens `crate` hat.

Der Modulbaum könnte dich an den Verzeichnisbaum des Dateisystems auf deinem
Computer erinnern; dies ist ein sehr treffender Vergleich! Genau wie
Verzeichnisse in einem Dateisystem verwendest du Module, um deinen Code zu
organisieren. Und genau wie Dateien in einem Verzeichnis brauchen wir einen
Weg, unsere Module zu finden.
