## Mit Pfaden auf ein Element im Modulbaum verweisen

Um Rust zu zeigen, wo ein Element in einem Modulbaum zu finden ist, verwenden
wir einen Pfad, auf gleiche Weise wie beim Navigieren durch ein Dateisystem.
Um eine Funktion aufzurufen, müssen wir ihren Pfad kennen.

Ein Pfad kann zwei Formen annehmen:

* Ein *absoluter Pfad* ist der vollständige Pfad ausgehend von einer
  Kistenwurzel; für Code aus einer externen Kiste beginnt der absolute Pfad mit
  der Kistenwurzel, und für Code aus der aktuellen Kiste beginnt er mit dem
  Literal `crate`.
* Ein *relativer Pfad* startet beim aktuellen Modul und benutzt `self`, `super`
  oder einen Bezeichner im aktuellen Modul.

Sowohl absolute als auch relative Pfade bestehen aus einem oder mehreren
Bezeichnern, die durch doppelte Doppelpunkte (`::`) getrennt sind.

Um zu Codeblock 7-1 zurückzukehren, nehmen wir an, wir wollen die Funktion
`add_to_waitlist` aufrufen. Das ist dasselbe wie die Frage, wie der Pfad der
Funktion `add_to_waitlist` ist. In Codeblock 7-3 haben wir unseren Code etwas
vereinfacht, indem wir einige der Module und Funktionen entfernt haben. Wir
zeigen zwei Möglichkeiten, wie die Funktion `add_to_waitlist` von einer neuen
Funktion `eat_at_restaurant` aus aufgerufen werden kann, die in der
Kistenwurzel definiert ist. Die Funktion `eat_at_restaurant` ist Teil der
öffentlichen Programmierschnittstelle (API) unserer Bibliothekskiste, daher
markieren wir sie mit dem Schlüsselwort `pub`. Im Abschnitt [„Pfade mit dem
Schlüsselwort `pub` öffnen“][pub] gehen wir näher auf `pub` ein. Beachte, dass
sich dieses Beispiel noch nicht kompilieren lässt; wir werden gleich erklären,
warum.

<span class="filename">Dateiname: src/lib.rs</span>

```rust,does_not_compile
mod front_of_house {
    mod hosting {
        fn add_to_waitlist() {}
    }
}

pub fn eat_at_restaurant() {
    // absoluter Pfad
    crate::front_of_house::hosting::add_to_waitlist();

    // relativer Pfad
    front_of_house::hosting::add_to_waitlist();
}
```

<span class="caption">Codeblock 7-3: Aufruf der Funktion `add_to_waitlist`
mittels absoluter und relativer Pfade</span>

Beim ersten Aufruf der Funktion `add_to_waitlist` in `eat_at_restaurant`
verwenden wir einen absoluten Pfad. Die Funktion `add_to_waitlist` ist in der
gleichen Kiste definiert wie `eat_at_restaurant`, daher können wir das
Schlüsselwort `crate` verwenden, um einen absoluten Pfad zu beginnen. Dann
geben wir jedes der aufeinanderfolgenden Module an, bis wir `add_to_waitlist`
erreichen. Du kannst dir ein Dateisystem mit der gleichen Struktur vorstellen:
Wir würden den Pfad `/front_of_house/hosting/add_to_waitlist` angeben, um das
Programm `add_to_waitlist` auszuführen; das Verwenden des Namens `crate`, um
von der Kistenwurzel aus zu beginnen, ist analog zu `/`, um vom
Dateisystem-Wurzelverzeichnis in deiner Eingabeaufforderung aus zu beginnen.

Beim zweiten Aufruf von `add_to_waitlist` in `eat_at_restaurant` verwenden wir
einen relativen Pfad. Der Pfad beginnt mit `front_of_house`, dem Namen des
Moduls, das auf der gleichen Ebene des Modulbaums definiert ist wie
`eat_at_restaurant`. Hier wäre das Dateisystem-Äquivalent die Verwendung des
Pfades `front_of_house/hosting/add_to_waitlist`. Mit einem Modulnamen zu
beginnen bedeutet, dass der Pfad relativ ist.

Die Überlegung, ob ein relativer oder absoluter Pfad verwendet wird, ist eine
Entscheidung, die du auf Basis deines Projekts treffen wirst, und hängt davon
ab, ob du den Code für die Elementdefinition eher separat oder zusammen mit dem
Code ablegen möchtest, der das Element verwendet. Wenn wir zum Beispiel das
Modul `front_of_house` und die Funktion `eat_at_restaurant` in ein Modul namens
`customer_experience` verschieben, müssten wir den absoluten Pfad in
`add_to_waitlist` ändern, aber der relative Pfad wäre immer noch gültig. Wenn
wir jedoch die Funktion `eat_at_restaurant` in ein separates Modul namens
`dining` verschieben würden, würde der absolute Pfad beim Aufruf
`add_to_waitlist` gleich bleiben, aber der relative Pfad müsste aktualisiert
werden. Wir bevorzugen generell die Angabe absoluter Pfade, da es
wahrscheinlicher ist, dass Codedefinitionen und Elementaufrufe unabhängig
voneinander verschoben werden.

Lass uns versuchen, Codeblock 7-3 zu kompilieren, und herausfinden, warum er
sich noch nicht kompilieren lässt! Der Fehler, den wir erhalten, ist in
Codeblock 7-4 zu sehen.

```console
$ cargo build
   Compiling restaurant v0.1.0 (file:///projects/restaurant)
error[E0603]: module `hosting` is private
 --> src/lib.rs:9:28
  |
9 |     crate::front_of_house::hosting::add_to_waitlist();
  |                            ^^^^^^^ private module
  |
note: the module `hosting` is defined here
 --> src/lib.rs:2:5
  |
2 |     mod hosting {
  |     ^^^^^^^^^^^

error[E0603]: module `hosting` is private
  --> src/lib.rs:12:21
   |
12 |     front_of_house::hosting::add_to_waitlist();
   |                     ^^^^^^^ private module
   |
note: the module `hosting` is defined here
  --> src/lib.rs:2:5
   |
2  |     mod hosting {
   |     ^^^^^^^^^^^

For more information about this error, try `rustc --explain E0603`.
error: could not compile `restaurant` due to 2 previous errors
```

<span class="caption">Codeblock 7-4: Kompilierfehler im Code in Codeblock
7-3</span>

Die Fehlermeldungen besagen, dass das Modul `hosting` privat ist. Mit anderen
Worten, wir haben die korrekten Pfade für das Modul `hosting` und die Funktion
`add_to_waitlist` angegeben, aber Rust lässt sie uns nicht nutzen, weil es
keinen Zugriff auf die privaten Abschnitte hat. In Rust sind alle Elemente
(Funktionen, Methoden, Strukturen, Aufzählungen, Module und Konstanten)
standardmäßig privat für übergeordnete Module. Wenn du ein Element wie eine
Funktion oder Struktur privat machen willst, setze es in ein Modul.

Objekte in einem übergeordneten Modul können die privaten Objekte in
untergeordneten Modulen nicht verwenden, aber Objekte in untergeordneten
Modulen können die Objekte in ihren übergeordneten Modulen verwenden. Der Grund
dafür ist, dass untergeordnete Module ihre Implementierungsdetails ein- und
ausblenden, aber die untergeordneten Module können den Gültigkeitsbereich
sehen, in dem sie definiert sind. Um mit unserer Metapher fortzufahren, stelle
dir die Datenschutzregeln wie das Backoffice eines Restaurants vor: Was dort
drinnen passiert, ist für Restaurantkunden privat, aber Büroleiter können alles
im Restaurant, in dem sie arbeiten, sehen und tun.

Rust entschied sich dafür, das Modulsystem auf diese Weise funktionieren zu
lassen, sodass das Ausblenden innerer Implementierungsdetails die Vorgabe ist.
Auf diese Weise weißt du, welche Teile des inneren Codes du ändern kannst, ohne
den äußeren Code zu brechen. Rust gibt dir jedoch die Möglichkeit, innere Teile
des Codes von Kindmodulen für äußere Vorgängermodule offenzulegen, indem du das
Schlüsselwort `pub` verwendest, um ein Element öffentlich zu machen.

### Pfade mit dem Schlüsselwort `pub` öffnen

Kehren wir zum Fehler in Codeblock 7-4 zurück, der uns sagte, das Modul
`hosting` sei privat. Wir wollen, dass die Funktion `eat_at_restaurant` im
übergeordneten Modul Zugriff auf die Funktion `add_to_waitlist` im
untergeordneten Modul hat, also markieren wir das Modul `hosting` mit dem
Schlüsselwort `pub`, wie in Codeblock 7-5 gezeigt.

<span class="filename">Dateiname: src/lib.rs</span>

```rust,does_not_compile
mod front_of_house {
    pub mod hosting {
        fn add_to_waitlist() {}
    }
}

pub fn eat_at_restaurant() {
    // Absolutet Pfad
    crate::front_of_house::hosting::add_to_waitlist();

    // Relativer Pfad
    front_of_house::hosting::add_to_waitlist();
}
```

<span class="caption">Codeblock 7-5: Deklarieren des Moduls `hosting` als
`pub`, um es von `eat_at_restaurant` aus zu benutzen</span>

Leider führt der Code in Codeblock 7-5 immer noch zu einem Fehler, wie
Codeblock 7-6 zeigt.

```console
$ cargo build
   Compiling restaurant v0.1.0 (file:///projects/restaurant)
error[E0603]: function `add_to_waitlist` is private
 --> src/lib.rs:9:37
  |
9 |     crate::front_of_house::hosting::add_to_waitlist();
  |                                     ^^^^^^^^^^^^^^^ private function
  |
note: the function `add_to_waitlist` is defined here
 --> src/lib.rs:3:9
  |
3 |         fn add_to_waitlist() {}
  |         ^^^^^^^^^^^^^^^^^^^^

error[E0603]: function `add_to_waitlist` is private
  --> src/lib.rs:12:30
   |
12 |     front_of_house::hosting::add_to_waitlist();
   |                              ^^^^^^^^^^^^^^^ private function
   |
note: the function `add_to_waitlist` is defined here
  --> src/lib.rs:3:9
   |
3  |         fn add_to_waitlist() {}
   |         ^^^^^^^^^^^^^^^^^^^^

For more information about this error, try `rustc --explain E0603`.
error: could not compile `restaurant` due to 2 previous errors
```

<span class="caption">Codeblock 7-6: Kompilierfehler im Code in Codeblock
7-5</span>

Was ist passiert? Das Hinzufügen des Schlüsselworts `pub` vor `mod hosting`
macht das Modul öffentlich. Wenn wir auf `front_of_house` zugreifen können,
können wir mit dieser Änderung auch auf `hosting` zugreifen. Aber die *Inhalte*
von `hosting` sind immer noch privat; das Modul öffentlich zu machen, macht
seinen Inhalt nicht öffentlich. Das Schlüsselwort `pub` für ein Modul erlaubt
es dem Code in seinen Vorgängermodulen nur, auf das Modul zu referenzieren,
nicht aber auf seinen inneren Code zuzugreifen. Da Module Container sind,
können wir nicht viel tun, indem wir nur das Modul öffentlich machen; wir
müssen weiter gehen und eines oder mehrere der Elemente innerhalb des Moduls
ebenfalls öffentlich machen.

Die Fehler in Codeblock 7-6 besagen, dass die Funktion `add_to_waitlist` privat
ist. Die Datenschutzregeln gelten für Strukturen, Aufzählungen, Funktionen und
Methoden sowie für Module.

Lass uns auch die Funktion `add_to_waitlist` öffentlich machen, indem wir das
Schlüsselwort `pub` vor ihre Definition hinzufügen, wie in Codeblock 7-7.

<span class="filename">Dateiname: src/lib.rs</span>

```rust,noplayground,test_harness
mod front_of_house {
    pub mod hosting {
        pub fn add_to_waitlist() {}
    }
}

pub fn eat_at_restaurant() {
    // absoluter Path
    crate::front_of_house::hosting::add_to_waitlist();

    // relativer Path
    front_of_house::hosting::add_to_waitlist();
}
```

<span class="caption">Codeblock 7-7: Das Hinzufügen des Schlüsselworts `pub` zu
`mod hosting` und `fn add_to_waitlist` lässt uns die Funktion in
`eat_at_restaurant` aufrufen</span>

Jetzt kompiliert der Code! Um zu sehen, warum das Hinzufügen des Schlüsselworts
`pub` uns erlaubt, diese Pfade in `add_to_waitlist` im Hinblick auf die
Datenschutzregeln zu verwenden, sehen wir uns die absoluten und relativen Pfade
an.

Auf dem absoluten Pfad beginnen wir mit `crate`, der Wurzel des Modulbaums
unserer Kiste. Dann wird das Modul `front_of_house` in der Kistenwurzel
definiert. Da das Modul `front_of_house` ist nicht öffentlich, weil die
`eat_at_restaurant`-Funktion im gleichen Modul wie `front_of_house` definiert
ist (d.h. `eat_at_restaurant` und `front_of_house` sind Geschwister), können
wir auf `front_of_house` von `eat_at_restaurant` aus zugreifen. Als nächstes
wird das Modul `hosting` mit `pub` gekennzeichnet. Wir können auf das
übergeordnete Modul von `hosting` zugreifen, also können wir auf `hosting`
zugreifen. Schließlich wird die Funktion `add_to_waitlist` mit `pub` markiert
und wir können auf ihr Elternmodul zugreifen, sodass dieser Funktionsaufruf
klappt!

Beim relativen Pfad ist die Logik die gleiche wie beim absoluten Pfad, mit
Ausnahme des ersten Schritts: Anstatt von der Kistenwurzel auszugehen, beginnt
der Pfad mit `front_of_house`. Das Modul `front_of_house` wird innerhalb
desselben Moduls wie `eat_at_restaurant` definiert, sodass der relative Pfad
ausgehend vom Modul, in dem `eat_at_restaurant` definiert ist, funktioniert.
Weil `hosting` und `add_to_waitlist` nun mit `pub` markiert sind, funktioniert
der Rest des Pfades, und dieser Funktionsaufruf ist gültig!

Wenn du vorhast, deine Bibliothekskiste weiterzugeben, damit andere Projekte
deinen Code verwenden können, ist deine öffentliche API dein Vertrag mit den
Benutzern deiner Kiste, der festlegt, wie sie mit deinem Code interagieren
können. Es gibt viele Überlegungen zum Umgang mit Änderungen an deiner
öffentlichen API, um es für andere einfacher zu machen, sich auf deine Kiste zu
verlassen. Diese Überlegungen liegen außerhalb des Rahmens dieses Buches; wenn
du an diesem Thema interessiert bist, lies [The Rust API
Guidelines][api-guidelines].

> #### Bewährte Praktiken für Pakete mit einer Binärdatei und einer Bibliothek
>
> Wir haben bereits erwähnt, dass ein Paket sowohl eine Binärkistenwurzel
> *src/main.rs* als auch eine Bibliothekskistenwurzel *src/lib.rs* enthalten
> kann, und beide Kisten tragen standardmäßig den Paketnamen. Normalerweise
> haben Pakete mit diesem Muster, die sowohl eine Bibliothek als auch eine
> Binärkiste enthalten, gerade genug Code in der Binärkiste, um eine
> ausführbare Datei zu starten, die Code aus der Bibliothekskiste aufruft.
> Dadurch können andere Projekte von den meisten Funktionen des Pakets
> profitieren, da der Code der Bibliothekskiste gemeinsam genutzt werden kann.
>
> Der Modulbaum sollte in *src/lib.rs* definiert werden. Dann können alle
> öffentlichen Elemente in der Binärkiste verwendet werden, indem die Pfade
> mit dem Namen des Pakets beginnen. Die binäre Kiste wird zu einem Benutzer
> der Bibliothekskiste, so wie eine vollständig externe Kiste die
> Bibliothekskiste verwenden würde: Sie kann nur die öffentliche API
> verwenden. Dies hilft dir, eine gute API zu entwerfen; Du bist nicht nur der
> Autor, sondern auch ein Kunde!
>
> In [Kapitel 12][ch12] werden wir diese organisatorische Praxis anhand eines
> Befehlszeilenprogramms demonstrieren, das sowohl eine Binärkiste als auch
> eine Bibliothekskiste enthält.

### Relative Pfade mit `super` beginnen

Wir können relative Pfade konstruieren, die im übergeordneten Modul beginnen
und nicht im aktuellen Modul oder der Kistenwurzel, indem wir `super` am Anfang
des Pfades verwenden. Dies ist so, als würde man einen Dateisystempfad mit der
Syntax `..` beginnen. Dies erlaubt es uns, auf ein Element zu referenzieren,
von dem wir wissen, dass es sich im übergeordneten Modul befindet, was die
Neuordnung des Modulbaums erleichtern kann, wenn das Modul eng mit dem
übergeordneten Modul verwandt ist, aber das übergeordnete Modul eines Tages an
eine andere Stelle im Modulbaum verschoben werden könnte.

Betrachte den Code in Codeblock 7-8, der die Situation nachbildet, in der ein
Koch eine falsche Bestellung korrigiert und persönlich zum Kunden bringt. Die
Funktion `fix_incorrect_order`, die im Modul `back_of_house` definiert ist,
ruft die im übergeordneten Modul definierte Funktion `deliver_order` auf, indem
sie den Pfad zu `deliver_order` angibt, der mit `super` beginnt:

<span class="filename">Dateiname: src/lib.rs</span>

```rust
fn deliver_order() {}

mod back_of_house {
    fn fix_incorrect_order() {
        cook_order();
        super::deliver_order();
    }

    fn cook_order() {}
}
```

<span class="caption">Codeblock 7-8: Aufrufen einer Funktion unter Verwendung
eines relativen Pfades, der mit `super` beginnt</span>

Die Funktion `fix_incorrect_order` befindet sich im Modul `back_of_house`,
sodass wir `super` benutzen können, um zum Elternmodul von `back_of_house` zu
gelangen, was in diesem Fall die Wurzel `crate` ist. Von dort aus suchen wir
nach `deliver_order` und finden es. Erfolg! Wir denken, dass das Modul
`back_of_house` und die Funktion `deliver_order` wahrscheinlich in der gleichen Beziehung zueinander stehen und zusammen verschoben werden, sollten wir uns dazu
entschließen, den Modulbaum der Kiste neu zu organisieren. Deshalb haben wir
`super` verwendet, sodass wir in Zukunft weniger Codestellen zu aktualisieren
haben, wenn dieser Code in ein anderes Modul verschoben wird.

### Strukturen und Aufzählungen öffentlich machen

Wir können auch `pub` verwenden, um Strukturen und Aufzählungen als öffentlich
zu kennzeichnen, aber es gibt ein paar zusätzliche Details zur Verwendung von
`pub` mit Strukturen und Aufzählungen. Wenn wir `pub` vor einer
Struktur-Definition verwenden, machen wir die Struktur öffentlich, aber die
Felder der Struktur sind immer noch privat. Wir können jedes Feld von Fall zu
Fall öffentlich machen oder auch nicht. In Codeblock 7-9 haben wir eine
öffentliche Struktur `back_of_house::Breakfast` mit einem öffentlichen Feld
`toast`, aber einem privaten Feld `seasonal_fruit` definiert. Dies ist der Fall
in einem Restaurant, in dem der Kunde die Brotsorte auswählen kann, die zu
einer Mahlzeit gehört, aber der Küchenchef entscheidet, welche Früchte die
Mahlzeit begleiten, je nach Saison und Vorrat. Das verfügbare Obst ändert sich
schnell, sodass die Kunden nicht wählen oder gar sehen können, welches Obst sie
bekommen.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
mod back_of_house {
    pub struct Breakfast {
        pub toast: String,
        seasonal_fruit: String,
    }

    impl Breakfast {
        pub fn summer(toast: &str) -> Breakfast {
            Breakfast {
                toast: String::from(toast),
                seasonal_fruit: String::from("Pfirsiche"),
            }
        }
    }
}

pub fn eat_at_restaurant() {
    // Bestelle im Sommer ein Frühstück mit Roggentoast
    let mut meal = back_of_house::Breakfast::summer("Roggen");
    // Ändere unsere Meinung darüber, welche Brotsorte wir gerne hätten
    meal.toast = String::from("Weizen");
    println!("Ich möchte {}-Toast", meal.toast);

    // Die nächste Zeile lässt sich nicht kompilieren, wenn wir sie nicht
    // auskommentieren; wir dürfen die Früchte der Saison, die wir mit der
    // Mahlzeit bekommen, weder sehen noch verändern.
    // meal.seasonal_fruit = String::from("Heidelbeeren");
}
```

<span class="caption">Codeblock 7-9: Eine Struktur mit öffentlichen und
privaten Felder</span>

Da das Feld `toast` in der Struktur `back_of_house::Breakfast` öffentlich ist,
können wir in `eat_at_restaurant` in das Feld `toast` schreiben und lesen,
indem wir die Punktnotation verwenden. Beachte, dass wir das Feld
`seasonal_fruit` in `eat_at_restaurant` nicht verwenden können, weil
`seasonal_fruit` privat ist. Versuche, die Kommentarzeichen in der Zeile, die
den Feldwert `seasonal_fruit` modifiziert, zu entfernen, um zu sehen, welchen
Fehler du erhältst!

Beachte auch, dass, weil `back_of_house::Breakfast` ein privates Feld hat, die
Struktur eine öffentliche Funktion (hier haben wir sie `summer` genannt) zum
Erzeugen einer Instanz von `Breakfast` bereitstellen muss. Wenn `Breakfast`
keine solche Funktion hätte, könnten wir keine Instanz von `Breakfast` in
`eat_at_restaurant` erzeugen, weil wir den Wert des privaten Feldes
`seasonal_fruit` in `eat_at_restaurant` nicht setzen könnten.

Wenn wir dagegen eine Aufzählung veröffentlichen, dann sind alle ihre
Varianten öffentlich. Wir brauchen nur das Schlüsselwort `pub` vor dem
Schlüsselwort `enum`, wie in Codeblock 7-10 gezeigt.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
mod back_of_house {
    pub enum Appetizer {
        Soup,
        Salad,
    }
}

pub fn eat_at_restaurant() {
    let order1 = back_of_house::Appetizer::Soup;
    let order2 = back_of_house::Appetizer::Salad;
}
```

<span class="caption">Codeblock 7-10: Kennzeichnen einer Aufzählung als
öffentlich macht alle ihre Varianten öffentlich</span>

Da wir die Aufzählung `Appetizer` öffentlich gemacht haben, können wir die
Varianten `Soup` und `Salad` in `eat_at_restaurant` verwenden.

Aufzählungen wären ohne öffentliche Varianten nicht sehr nützlich; es wäre
ärgerlich, alle Aufzählungs-Varianten stets mit `pub` annotieren zu müssen,
daher sind die Aufzählungs-Varianten standardmäßig öffentlich. Strukturen sind
auch ohne öffentliche Felder nützlich, daher folgen Strukturfelder
standardmäßig der allgemeinen Regel, dass alles privat ist, es sei denn, es
wird mit `pub` annotiert.

Es gibt noch eine weitere Situation mit `pub`, die wir noch nicht behandelt
haben, und das ist unser letztes Modulsystem-Feature: Das Schlüsselwort `use`.
Zuerst werden wir `use` an sich behandeln, und dann zeigen wir, wie man `pub`
und `use` kombiniert.

[api-guidelines]: https://rust-lang.github.io/api-guidelines/
[ch12]: ch12-00-an-io-project.html
[pub]: #pfade-mit-dem-schlüsselwort-pub-öffnen
