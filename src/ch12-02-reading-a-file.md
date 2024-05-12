## Eine Datei einlesen

Jetzt fügen wir Funktionalität zum Lesen der Datei hinzu, die im
Befehlszeilenargument `file_path` angegeben ist. Zuerst brauchen wir eine
Beispieldatei, um sie zu testen: Die beste Art von Datei, die wir benutzen
können, um sicherzustellen, dass `minigrep` funktioniert, ist eine Datei mit
einer kleinen Menge Text über mehrere Zeilen mit einigen sich wiederholenden
Wörtern. In Codeblock 12-3 ist ein Gedicht von Emily Dickinson, das gut
funktionieren wird! Erstelle eine Datei namens *poem.txt* im Hauptverzeichnis
deines Projekts und gib das Gedicht „I'm Nobody! Who are you?“ ein.

<span class="filename">Dateiname: poem.txt</span>

```text
I'm nobody! Who are you?
Are you nobody, too?
Then there's a pair of us - don't tell!
They'd banish us, you know.

How dreary to be somebody!
How public, like a frog
To tell your name the livelong day
To an admiring bog!
```

<span class="caption">Codeblock 12-3: Ein Gedicht von Emily Dickinson ist ein
guter Testfall</span>

Wenn der Text vorhanden ist, editiere *src/main.rs* und füge Code zum Lesen der
Datei hinzu, wie in Codeblock 12-4 gezeigt.

<span class="filename">Dateiname: src/main.rs</span>

```rust,noplayground
use std::env;
use std::fs;

fn main() {
    // --abschneiden--
#     let args: Vec<String> = env::args().collect();
#
#     let query = &args[1];
#     let file_path = &args[2];
#
#     println!("Suche nach {query}");
    println!("In Datei {file_path}");

    let contents = fs::read_to_string(file_path)
        .expect("Etwas ging beim Lesen der Datei schief");

    println!("Mit text:\n{contents}");
}
```

<span class="caption">Codeblock 12-4: Lesen des Inhalts der Datei, die durch
das zweite Argument angegeben wurde</span>

Zuerst fügen wir eine weitere `use`-Anweisung hinzu, um einen relevanten Teil
der Standardbibliothek einzubringen: Wir brauchen `std::fs`, um Dateien zu
verwenden.

In `main` haben wir eine neue Anweisung hinzugefügt: `fs::read_to_string` nimmt
den `file_path`, öffnet diese Datei und gibt ein `Result<String>` mit dem
Inhalt der Datei zurück.

Nach dieser Anweisung haben wir wieder eine temporäre `println!`-Anweisung
hinzugefügt, die den Wert von `contents` ausgibt, nachdem die Datei eingelesen
wurde, sodass wir überprüfen können, ob das Programm soweit funktioniert.

Lassen wir diesen Code mit einer beliebigen Zeichenkette als erstes
Kommandozeilenargument laufen (weil wir den Suchteil noch nicht implementiert
haben) und die Datei *poem.txt* als zweites Argument:

```console
$ cargo run -- the poem.txt
   Compiling minigrep v0.1.0 (file:///projects/minigrep)
    Finished dev [unoptimized + debuginfo] target(s) in 0.0s
     Running `target/debug/minigrep the poem.txt`
Suche nach the
In Datei poem.txt
Mit text:
I'm nobody! Who are you?
Are you nobody, too?
Then there's a pair of us - don't tell!
They'd banish us, you know.

How dreary to be somebody!
How public, like a frog
To tell your name the livelong day
To an admiring bog!
```

Großartig! Der Code wurde eingelesen und dann der Inhalt der Datei ausgegeben.
Aber der Code hat ein paar Mängel. Die Funktion `main` hat momentan mehrere
Verantwortlichkeiten: Im Allgemeinen sind Funktionen klarer und einfacher zu
warten, wenn jede Funktion nur für eine Idee verantwortlich ist. Das andere
Problem ist, dass wir mit Fehlern nicht so gut umgehen, wie wir es könnten. Das
Programm ist noch klein, sodass diese Fehler kein großes Problem darstellen,
aber je größer das Programm wird, desto schwieriger wird es, sie sauber zu
beheben. Es ist eine gute Praxis, schon früh mit dem Umformen (refactor) zu
beginnen, wenn man ein Programm entwickelt, denn es ist viel einfacher,
kleinere Code-Mengen umzuformen. Das werden wir als Nächstes tun.
