# Ein Ratespiel programmieren

Lass uns den Sprung in Rust wagen, indem wir gemeinsam ein praktisches Projekt
durcharbeiten! Dieses Kapitel führt dich in einige gängige Rust-Konzepte ein,
indem es dir zeigt, wie du diese in einem realen Programm verwenden kannst. Du
lernst `let`, `match`, Methoden, assoziierte Funktionen, das Verwenden externer
Kisten (crates) und mehr kennen! In den folgenden Kapiteln werden diese Ideen
ausführlicher behandelt. In diesem Kapitel wirst du die Grundlagen üben.

Wir werden ein klassisches Programmierproblem für Anfänger implementieren: Ein
Ratespiel. Und so funktioniert es: Das Programm erzeugt eine zufällige ganze
Zahl zwischen 1 und 100. Dann wird es den Spieler auffordern, eine Schätzung
einzugeben. Nachdem eine Schätzung eingegeben wurde, zeigt das Programm an, ob
die Schätzung zu niedrig oder zu hoch ist. Wenn die Schätzung korrekt ist, gibt
das Spiel eine Glückwunschnachricht aus und beendet sich.

## Aufsetzen eines neuen Projekts

Um ein neues Projekt aufzusetzen, gehe in das Verzeichnis *projects*, das du in
Kapitel 1 erstellt hast, und erstelle ein neues Projekt mit Cargo, wie folgt:

```console
$ cargo new guessing_game
$ cd guessing_game
```

Der erste Befehl `cargo new` nimmt den Namen des Projekts (`guessing_game`) als
erstes Argument. Der zweite Befehl wechselt in das Verzeichnis des neuen
Projekts.

Schaue dir die generierte Datei *Cargo.toml* an:

<span class="filename">Dateiname: Cargo.toml</span>

```toml
[package]
name = "guessing_game"
version = "0.1.0"
edition = "2018"

# See more keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html

[dependencies]
```

Der Inhalt Deiner Datei sollte ungefähr so aussehen wie hier. Falls es nicht ganz übereinstimmt, liegt das wahrscheinlich daran, dass Du schon eine neuere Version von `Cargo` verwendest. Wie im vorherigen Kapitel schon erwähnt, kann man den `author` Tag hinzufügen, muss es aber nicht.

Wie du in Kapitel 1 gesehen hast, generiert `cargo new` ein „Hello,
world!“-Programm für dich. Sieh dir die Datei *src/main.rs* an:

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    println!("Hello, world!");
}
```

Kompilieren wir nun dieses „Hello, world!“-Programm und führen es im gleichen
Schritt aus mit dem Befehl `cargo run`:

```console
$ cargo run
   Compiling guessing_game v0.1.0 (file:///projects/guessing_game)
    Finished dev [unoptimized + debuginfo] target(s) in 1.50s
     Running `target/debug/guessing_game`
Hello, world!
```

Der Befehl `run` ist praktisch, wenn du ein Projekt schnell iterieren musst,
wie wir es in diesem Spiel tun werden, indem du jede Iteration schnell testest,
bevor du zur nächsten übergehst.

Öffne die Datei *src/main.rs* erneut. Du wirst den gesamten Code in diese Datei
schreiben.

## Verarbeiten einer Schätzung

Der erste Teil des Ratespielprogramms fragt nach einer Benutzereingabe,
verarbeitet diese Eingabe und überprüft, ob die Eingabe in der erwarteten Form
vorliegt. Zu Beginn erlauben wir dem Spieler, eine Schätzung einzugeben. Gib
den Code aus Codeblock 2-1 in *src/main.rs* ein.

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore
use std::io;

fn main() {
    println!("Rate die Zahl!");

    println!("Bitte gib deine Schätzung ein.");

    let mut guess = String::new();

    io::stdin()
        .read_line(&mut guess)
        .expect("Fehler beim Lesen der Zeile");

    println!("Du hast geschätzt: {}", guess);
}
```

<span class="caption">Codeblock 2-1: Code, der eine Schätzung vom Benutzer
erhält und ausgibt</span>

Dieser Code enthält eine Menge Informationen, also gehen wir ihn Zeile für
Zeile durch. Um eine Benutzereingabe zu erhalten und das Ergebnis dann als
Ausgabe auszugeben, müssen wir die Bibliothek `io` (input/output) in den
Gültigkeitsbereich bringen. Die `io`-Bibliothek stammt aus der
Standardbibliothek (die als `std` bekannt ist):

```rust,ignore
use std::io;
#
# fn main() {
#     println!("Rate die Zahl!");
#
#     println!("Bitte gib deine Schätzung ein.");
#
#     let mut guess = String::new();
#
#     io::stdin()
#         .read_line(&mut guess)
#         .expect("Fehler beim Lesen der Zeile");
#
#     println!("Du hast geschätzt: {}", guess);
# }
```

Standardmäßig bringt Rust im [*Präludium*][prelude] nur einige wenige Typen in
den Gültigkeitsbereich jedes Programms. Wenn ein Typ, den du verwenden willst,
nicht im Präludium ist, musst du diesen Typ explizit mit einer `use`-Anweisung
in den Gültigkeitsbereich bringen. Das Verwenden der Bibliothek `std::io`
bietet dir eine Reihe von nützlichen Funktionalitäten, einschließlich der
Möglichkeit, Benutzereingaben entgegenzunehmen.

Wie du in Kapitel 1 gesehen hast, ist die Funktion `main` der Einstiegspunkt in
das Programm:

```rust,ignore
# use std::io;
#
fn main() {
#     println!("Rate die Zahl!");
#
#     println!("Bitte gib deine Schätzung ein.");
#
#     let mut guess = String::new();
#
#     io::stdin()
#         .read_line(&mut guess)
#         .expect("Fehler beim Lesen der Zeile");
#
#     println!("Du hast geschätzt: {}", guess);
# }
```

Die Syntax `fn` deklariert eine neue Funktion, die Klammern `()` zeigen an,
dass es keine Parameter gibt, und die geschweifte Klammer `{` beginnt den Rumpf
der Funktion.

Wie du auch in Kapitel 1 gelernt hast, ist `println!` ein Makro, das eine
Zeichenkette auf dem Bildschirm ausgibt:

```rust,ignore
# use std::io;
#
# fn main() {
    println!("Rate die Zahl!");

    println!("Bitte gib deine Schätzung ein.");
#
#     let mut guess = String::new();
#
#     io::stdin()
#         .read_line(&mut guess)
#         .expect("Fehler beim Lesen der Zeile");
#
#     println!("Du hast geschätzt: {}", guess);
# }
```

Dieser Code gibt eine Eingabeaufforderung aus, die angibt, um was für ein Spiel
es sich handelt, und den Benutzer zur Eingabe auffordert.

### Speichern von Werten mit Variablen

Als Nächstes erstellen wir einen Ort, an dem die Benutzereingabe gespeichert
wird, wie hier:

```rust,ignore
# use std::io;
#
# fn main() {
#     println!("Rate die Zahl!");
#
#     println!("Bitte gib deine Schätzung ein.");
#
    let mut guess = String::new();
#
#     io::stdin()
#         .read_line(&mut guess)
#         .expect("Fehler beim Lesen der Zeile");
#
#     println!("Du hast geschätzt: {}", guess);
# }
```

Jetzt wird das Programm interessant! Es ist viel los in dieser kleinen Zeile.
Beachte, dass dies eine `let`-Anweisung ist, die benutzt wird, um eine
*Variable* zu erzeugen. Hier ist ein weiteres Beispiel:

```rust,ignore
let apples = 5;
```

Diese Zeile erzeugt eine neue Variable namens `apples` und bindet sie an den Wert
5. In Rust sind Variablen standardmäßig unveränderlich (immutable). Wir werden
dieses Konzept im Abschnitt [„Variablen und
Veränderlichkeit“][variables-and-mutability] in Kapitel 3 ausführlich
besprechen. Das folgende Beispiel zeigt, wie man `mut` vor dem Variablennamen
verwendet, um eine Variable veränderlich zu machen:

```rust
let apples = 5; // unveränderlich
let mut bananas = 5; // veränderlich
```

> Anmerkung: Die Syntax `//` beginnt einen Kommentar, der bis zum Ende der
> Zeile weitergeht. Rust ignoriert alles in Kommentaren. Diese werden in
> Kapitel 3 ausführlicher besprochen.

Kommen wir zurück zum Programm des Ratespiels. Du weißt jetzt, dass `let mut
guess` eine veränderliche Variable namens `guess` einführt. Auf der anderen
Seite des Gleichheitszeichens (`=`) steht der Wert, an den `guess` gebunden
ist. Dieser Wert ist das Ergebnis des Aufrufs von `String::new`, einer Funktion, die
eine neue Instanz eines `String` zurückgibt. [`String`][string] ist ein von der
Standardbibliothek bereitgestellter Zeichenketten-Typ, der ein
wachstumsfähiges, UTF-8-kodiertes Stück Text ist.

Die Syntax `::` in der Zeile `::new` zeigt an, dass `new` eine *assoziierte
Funktion* (associated function) vom Typ `String` ist. Eine assoziierte Funktion
ist auf einem Typ implementiert, in diesem Fall `String`.

Diese Funktion `new` erzeugt eine neue, leere Zeichenkette. Du wirst eine
Funktion `new` bei vielen Typen finden, weil es ein gebräuchlicher Name für
eine Funktion ist, die einen neuen Wert irgendeiner Art erzeugt.

Zusammenfassend lässt sich sagen, dass die Zeile `let mut guess =
String::new();` eine veränderlich Variable erzeugt hat, die derzeit an eine
neue, leere Instanz eines `String` gebunden ist. Uff!

Erinnere dich, dass wir die Ein-/Ausgabefunktionalität aus der
Standardbibliothek mit `use std::io;` in der ersten Zeile des Programms
eingebunden haben. Jetzt rufen wir die Funktion `stdin` aus dem Modul `io` auf:

```rust,ignore
# use std::io;
#
# fn main() {
#     println!("Rate die Zahl!");
#
#     println!("Bitte gib deine Schätzung ein.");
#
#     let mut guess = String::new();
#
    io::stdin()
        .read_line(&mut guess)
#         .expect("Fehler beim Lesen der Zeile");
#
#     println!("Du hast geschätzt: {}", guess);
# }
```

Hätten wir nicht die Zeile `use std::io` an den Anfang des Programms gestellt,
hätten wir diesen Funktionsaufruf als `std::io::stdin` schreiben können. Die
Funktion `stdin` gibt eine Instanz von [`std::io::Stdin`][iostdin] zurück, was
ein Typ ist, der eine Standardeingaberessource (handle to the standard input)
für dein Terminal darstellt.

Der nächste Teil des Codes `.read_line(&mut guess)` ruft die Methode
[`read_line`][read_line] der Standardeingaberessource auf, um eine Eingabe vom
Benutzer zu erhalten. Wir übergeben auch ein Argument an `read_line`:
`&mut guess`.

Die Aufgabe von `read_line` ist es, alles, was der Benutzer in die
Standardeingabe eingibt, an eine Zeichenkette anzuhängen (ohne deren Inhalt zu
überschreiben), daher nimmt es diese Zeichenkette als Argument. Das
Zeichenketten-Argument muss veränderlich sein, damit die Methode den Inhalt der
Zeichenkette durch Hinzufügen der Benutzereingabe ändern kann.

Das `&` zeigt an, dass es sich bei diesem Argument um eine *Referenz* handelt,
die dir eine Möglichkeit bietet, mehrere Teile deines Codes auf einen Datenteil
zugreifen zu lassen, ohne dass du diese Daten mehrfach in den Speicher kopieren
musst. Referenzen sind eine komplexe Funktionalität, und einer der
Hauptvorteile von Rust ist, wie sicher und einfach es ist, Referenzen zu
verwenden. Du musst nicht viele dieser Details kennen, um dieses Programm
fertigzustellen. Im Moment musst du nur wissen, dass Referenzen wie Variablen
standardmäßig unveränderlich sind. Daher musst du `&mut guess` anstatt `&guess`
schreiben, um sie veränderlich zu machen. (In Kapitel 4 werden Referenzen
ausführlicher erklärt.)

### Behandeln potentieller Fehler mit dem Typ `Result`

Wir arbeiten noch immer an dieser Codezeile. Obwohl wir jetzt eine dritte
Textzeile besprechen, ist sie immer noch Teil einer einzigen logischen
Codezeile. Der nächste Teil ist diese Methode:

```rust,ignore
# use std::io;
#
# fn main() {
#     println!("Rate die Zahl!");
#
#     println!("Bitte gib deine Schätzung ein.");
#
#     let mut guess = String::new();
#
#     io::stdin()
#         .read_line(&mut guess)
        .expect("Fehler beim Lesen der Zeile");
#
#     println!("Du hast geschätzt: {}", guess);
# }
```

Wenn du eine Methode mit der Syntax `.method_name()` aufrufst, ist es oft
ratsam, einen Zeilenumbruch und weitere Leerzeichen anzugeben, um lange Zeilen
aufzuteilen. Wir hätten diesen Code auch so schreiben können:

```rust,ignore
io::stdin().read_line(&mut guess).expect("Fehler beim Lesen der Zeile");
```

Eine lange Zeile ist jedoch schwer zu lesen, daher ist es am besten, sie
aufzuteilen. Lass uns nun besprechen, was diese Zeile bewirkt. 

Wie bereits erwähnt, schreibt `read_line` das, was der Benutzer eingibt, in die
Zeichenkette, die wir ihm übergeben, aber sie gibt auch einen Wert zurück
&ndash; in diesem Fall ein [`io::Result`][ioresult]. Rust hat eine Reihe von
Typen namens `Result` in seiner Standardbibliothek: Ein generisches
[`Result`][result] sowie spezifische Versionen für Untermodule, z.B.
`io::Result`.

Die `Result`-Typen sind [*Aufzählungen*][enums] (enumerations), die oft als
*enums* bezeichnet werden. Eine Aufzählung ist ein Typ, der einen festen Satz
von Werten haben kann, und diese Werte werden die *Varianten* (variants) der
Aufzählung genannt. In Kapitel 6 werden Aufzählungen ausführlicher behandelt.

Für `Result` sind die Varianten `Ok` und `Err`. Die Variante `Ok` gibt an, dass
die Operation erfolgreich war, und innerhalb von `Ok` steht der erfolgreich
generierte Wert. Die Variante `Err` bedeutet, dass die Operation fehlgeschlagen
ist, und `Err` enthält Informationen darüber, wie oder warum die Operation
fehlgeschlagen ist.

Der Zweck dieser `Result`-Typen ist es, Informationen zur Fehlerbehandlung zu
kodieren. Für Werte vom Typ `Result` sind, wie für Werte jedes Typs, Methoden
definiert. Eine Instanz von `io::Result` hat eine [Methode `expect`][expect],
die du aufrufen kannst. Wenn diese `io::Result`-Instanz ein `Err`-Wert ist,
wird `expect` das Programm zum Absturz bringen und die Meldung anzeigen, die du
als Argument an `expect` übergeben hast. Wenn die Methode `read_line` ein `Err`
zurückgibt, ist dies wahrscheinlich das Ergebnis eines Fehlers, der vom
zugrundeliegenden Betriebssystem herrührt. Wenn diese `io::Result`-Instanz ein
`Ok`-Wert ist, wird `expect` den Wert, den `Ok` hält, als Rückgabewert
verwenden, damit du ihn verwenden kannst. In diesem Fall ist dieser Wert die
Anzahl der Bytes, die der Benutzer in die Standardeingabe eingegeben hat.

Wenn du nicht `expect` aufrufst, wird das Programm kompiliert, aber du erhältst
eine Warnung:

```console
$ cargo build
   Compiling guessing_game v0.1.0 (file:///projects/guessing_game)
warning: unused `Result` that must be used
  --> src/main.rs:10:5
   |
10 |     io::stdin().read_line(&mut guess);
   |     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
   |
   = note: `#[warn(unused_must_use)]` on by default
   = note: this `Result` may be an `Err` variant, which should be handled

warning: `guessing_game` (bin "guessing_game") generated 1 warning

    Finished dev [unoptimized + debuginfo] target(s) in 0.59s
```

Rust warnt, dass du den von `read_line` zurückgegebenen `Result`-Wert nicht
verwendet hast, was darauf hinweist, dass das Programm einen möglichen Fehler
nicht behandelt hat.

Der richtige Weg, die Warnung zu unterdrücken, ist, tatsächlich eine
Fehlerbehandlung zu schreiben, aber da du dieses Programm einfach nur abstürzen
lassen willst, wenn ein Problem auftritt, kannst du `expect` verwenden. In
Kapitel 9 erfährst du, wie man sich von Fehlern erholt.

### Ausgeben von Werten mit `println!`-Platzhaltern

Abgesehen von der schließenden geschweiften Klammer gibt es in dem bisher
hinzugefügten Code nur noch eine weitere Zeile zu besprechen, nämlich die
folgende: 

```rust,ignore
# use std::io;
#
# fn main() {
#     println!("Rate die Zahl!");
#
#     println!("Bitte gib deine Schätzung ein.");
#
#     let mut guess = String::new();
#
#     io::stdin()
#         .read_line(&mut guess)
#         .expect("Fehler beim Lesen der Zeile");
#
    println!("Du hast geschätzt: {}", guess);
# }
```

Diese Zeile gibt die Zeichenkette aus, in der wir die Eingabe des Benutzers
gespeichert haben. Der Satz geschweifte Klammern `{}` ist ein Platzhalter:
Stelle dir `{}` wie kleine Krebszangen vor, die einen Wert an Ort und Stelle
halten. Mit geschweiften Klammern kannst du mehr als einen Wert ausgeben: Der
erste Satz geschweifte Klammern enthält den ersten Wert, der nach der
Formatierungszeichenkette aufgeführt ist, der zweite Satz enthält den zweiten
Wert usw. Das Ausgeben mehrerer Werte in einem Aufruf von `println!` würde
folgendermaßen aussehen:

```rust
let x = 5;
let y = 10;

println!("x = {} und y = {}", x, y);
```

Dieser Code würde `x = 5 und y = 10` ausgeben.

### Testen des ersten Teils

Testen wir den ersten Teil des Ratespiels. Führe ihn mit `cargo run` aus:

```console
$ cargo run
   Compiling guessing_game v0.1.0 (file:///projects/guessing_game)
    Finished dev [unoptimized + debuginfo] target(s) in 6.44s
     Running `target/debug/guessing_game`
Rate die Zahl!
Bitte gib deine Schätzung ein.
6
Du hast geschätzt: 6
```

An diesem Punkt ist der erste Teil des Spiels abgeschlossen: Wir erhalten
eine Eingabe über die Tastatur und geben sie dann aus.

## Generieren einer Geheimzahl

Als nächstes müssen wir eine Geheimzahl generieren, die der Benutzer zu erraten
versucht. Die Geheimzahl sollte jedes Mal anders sein, damit das Spiel mehr als
einmal Spaß macht. Lass uns eine Zufallszahl zwischen 1 und 100 verwenden,
damit das Spiel nicht zu schwierig wird. Rust enthält noch keine
Zufallszahl-Funktionalität in seiner Standardbibliothek. Das Rust-Team stellt
jedoch eine [Kiste `rand`][randcrate] zur Verfügung.

### Verwenden einer Kiste um mehr Funktionalität zu erhalten

Denke daran, dass eine Kiste eine Sammlung von Rust-Quellcode-Dateien ist. Das
Projekt, das wir gebaut haben, ist eine *binäre Kiste* (binary crate), die eine
ausführbare Datei ist. Die Kiste `rand` ist eine *Bibliotheks-Kiste* (library
crate), die Code enthält, der in anderen Programmen verwendet werden soll.

Das Koordinieren von externen Kisten ist der Bereich, in dem Cargo glänzt.
Bevor wir Code schreiben können, der `rand` benutzt, müssen wir die Datei
*Cargo.toml* so modifizieren, dass die Kiste `rand` als Abhängigkeit
eingebunden wird. Öffne jetzt diese Datei und füge die folgende Zeile unten
unter der Überschrift des Abschnitts `[dependencies]` hinzu, den Cargo für dich
erstellt hat. Stelle sicher, dass du `rand` genau so angibst, wie wir es hier
getan haben, andernfalls funktionieren die Codebeispiele in dieser Anleitung
möglicherweise nicht.

<span class="filename">Dateiname: Cargo.toml</span>

```toml
[dependencies]
rand = "0.8.3"
```

In der Datei *Cargo.toml* ist alles, was nach einer Überschrift folgt, Teil
eines Abschnitts, der so lange andauert, bis ein anderer Abschnitt beginnt. Im
Abschnitt `[dependencies]` teilst du Cargo mit, von welchen externen Kisten
dein Projekt abhängt und welche Versionen dieser Kisten du benötigst. In diesem
Fall spezifizieren wir die Kiste `rand` mit dem semantischen
Versionsspezifikator `0.8.3`. Cargo versteht [semantische
Versionierung][semver] (manchmal auch *SemVer* genannt), was ein Standard zum
Schreiben von Versionsnummern ist. Die Zahl `0.8.3` ist eigentlich die
Abkürzung für `^0.8.3`, was für alle Versionen ab `0.8.3` und kleiner als
`0.9.0` steht. Cargo geht davon aus dass die öffentliche API dieser Versionen
kompatibel zur Version 0.8.3 ist und diese Angabe stellt sicher, dass du die
neueste Patch-Version erhälten, die noch mit dem Code in diesem Kapitel
kompiliert werden kann. Ab Version `0.9.0` ist nicht garantiert, dass die API
mit der in den folgenden Beispielen verwendeten übereinstimmt.

Lass uns nun, ohne den Code zu ändern, das Projekt bauen, wie in Codeblock 2-2
gezeigt.

```console
$ cargo build
    Updating crates.io index
  Downloaded rand v0.8.3
  Downloaded libc v0.2.62
  Downloaded rand_core v0.2.2
  Downloaded rand_core v0.3.1
  Downloaded rand_core v0.4.2
   Compiling rand_core v0.4.2
   Compiling libc v0.2.62
   Compiling rand_core v0.3.1
   Compiling rand_core v0.2.2
   Compiling rand v0.8.3
   Compiling guessing_game v0.1.0 (file:///projects/guessing_game)
    Finished dev [unoptimized + debuginfo] target(s) in 2.53s
```

<span class="caption">Codeblock 2-2: Die Ausgabe beim Ausführen von `cargo
build` nach dem Hinzufügen der Kiste rand als Abhängigkeit</span>

Möglicherweise siehst du unterschiedliche Versionsnummern (aber dank SemVer
sind sie alle mit dem Code kompatibel!), unterschiedliche Zeilen (je nach
Betriebssystem) und die Zeilen können in einer anderen Reihenfolge erscheinen.

Jetzt, wo wir eine externe Abhängigkeit haben, holt Cargo die neuesten
Versionen von allem aus der *Registry*, das eine Kopie der Daten von
[Crates.io][cratesio] ist. Crates.io ist der Ort, an dem die Menschen im
Rust-Ökosystem ihre Open-Source-Rustprojekte für andere zur Nutzung
bereitstellen.

Nach dem Aktualisieren der Registry überprüft Cargo den Abschnitt
`[dependencies]` und lädt alle Kisten herunter, die du noch nicht hast. Obwohl
wir nur `rand` als Abhängigkeit aufgelistet haben, hat sich Cargo in diesem
Fall auch andere Kisten geschnappt, von denen `rand` abhängig ist, um zu
funktionieren. Nachdem die Kisten heruntergeladen wurden, kompiliert
Rust sie und kompiliert dann das Projekt mit den verfügbaren Abhängigkeiten.

Wenn du gleich wieder `cargo build` ausführst, ohne irgendwelche Änderungen
vorzunehmen, erhältst du keine Ausgabe außer der Zeile `Finished`. Cargo weiß,
dass es die Abhängigkeiten bereits heruntergeladen und kompiliert hat, und du
hast in deiner Datei *Cargo.toml* nichts daran geändert. Cargo weiß auch, dass
du nichts an deinem Code geändert hast, also wird dieser auch nicht neu
kompiliert. Ohne etwas zu tun zu haben, wird es einfach beendet.

Wenn du die Datei *src/main.rs* öffnest, eine triviale Änderung vornimmst und
sie dann speicherst und neu baust, siehst du nur zwei Zeilen Ausgabe:

```console
$ cargo build
   Compiling guessing_game v0.1.0 (file:///projects/guessing_game)
    Finished dev [unoptimized + debuginfo] target(s) in 2.53 secs
```

Diese Zeilen zeigen, dass Cargo nur den Build mit deiner winzigen Änderung an
der Datei *src/main.rs* aktualisiert. Deine Abhängigkeiten haben sich nicht
geändert, sodass Cargo weiß, dass es wiederverwenden kann, was es bereits
heruntergeladen und kompiliert hat. Es baut nur deinen Teil des Codes neu.

#### Sicherstellen reproduzierbarer Builds mit der Datei *Cargo.lock*

Cargo verfügt über einen Mechanismus, der sicherstellt, dass du jedes Mal, wenn
du oder jemand anderes deinen Code baut, dasselbe Artefakt neu erstellen
kannst: Cargo wird nur die Versionen der von dir angegebenen Abhängigkeiten
verwenden, bis du etwas anderes angibst. Was passiert z.B., wenn nächste Woche
Version 0.8.4 der Kiste `rand` herauskommt und eine wichtige Fehlerbehebung
enthält, aber auch eine Regression, die deinen Code bricht?

Die Antwort auf dieses Problem ist die Datei *Cargo.lock*, die beim ersten
Ausführen von `cargo build` erstellt wurde und sich jetzt in deinem
*guessing_game*-Verzeichnis befindet. Wenn du ein Projekt zum ersten Mal baust,
ermittelt Cargo alle Versionen der Abhängigkeiten, die den Kriterien
entsprechen, und schreibt sie dann in die Datei *Cargo.lock*. Wenn du dein
Projekt in der Zukunft baust, wird Cargo sehen, dass die Datei *Cargo.lock*
existiert und die dort angegebenen Versionen verwenden, anstatt die ganze
Arbeit der Versionsfindung erneut zu machen. Auf diese Weise erhältst du
automatisch einen reproduzierbaren Build. Mit anderen Worten, dein Projekt
bleibt dank der Datei *Cargo.lock* auf `0.8.3`, bis du explizit die
Versionsnummer erhöhst.

#### Aktualisieren einer Kiste, um eine neue Version zu erhalten

Wenn du eine Kiste aktualisieren *willst*, bietet Cargo einen weiteren Befehl
`update` an, der die Datei *Cargo.lock* ignoriert und alle neuesten Versionen,
die deinen Spezifikationen entsprechen, in *Cargo.toml* herausfindet. Wenn das
funktioniert, wird Cargo diese Versionen in die Datei *Cargo.lock* schreiben.

Standardmäßig sucht Cargo jedoch nur nach Versionen, die größer als `0.8.3` und
kleiner als `0.9.0` sind. Wenn die Kiste `rand` zwei neue Versionen `0.8.4` und
`0.9.0` veröffentlicht hat, würdest du folgendes sehen, wenn du `cargo update`
ausführst:

```console
$ cargo update
    Updating crates.io index
    Updating rand v0.8.3 -> v0.8.4
```

An diesem Punkt würdest du auch eine Änderung in deiner Datei *Cargo.lock*
bemerken, die feststellt, dass die Version der Kiste `rand`, die du jetzt
benutzt, `0.8.4` ist.

Wenn du die `rand`-Version `0.9.0` oder irgendeine Version aus der
`0.9.x`-Serie verwenden wolltest, müsstest du stattdessen die Datei
*Cargo.toml* anpassen, damit sie wie folgt aussieht:

```toml
[dependencies]
rand = "0.9.0"
```

Wenn du das nächste Mal `cargo build` ausführst, wird Cargo die Registry der
verfügbaren Kisten aktualisieren und deine `rand`-Anforderungen entsprechend
der von dir angegebenen neuen Version neu bewerten.

Es gibt noch viel mehr über [Cargo][doccargo] und [seinem
Ökosystem][doccratesio] zu sagen, das wir in Kapitel 14 besprechen werden, aber
für den Moment ist das alles, was du wissen musst. Cargo macht es sehr einfach,
Bibliotheken wiederzuverwenden, sodass die Rust-Entwickler in der Lage sind,
kleinere Projekte zu schreiben, die aus einer Reihe von Paketen
zusammengestellt werden.

### Generieren einer Zufallszahl

Nun, da du die Kiste `rand` zu *Cargo.toml* hinzugefügt hast, lass uns mit
`rand` beginnen. Der nächste Schritt ist *src/main.rs* zu ändern, wie in
Codeblock 2-3 gezeigt.

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore
use std::io;
use rand::Rng;

fn main() {
    println!("Rate die Zahl!");

    let secret_number = rand::thread_rng().gen_range(1..101);

    println!("Die Geheimzahl ist: {}", secret_number);

    println!("Bitte gib deine Schätzung ein.");

    let mut guess = String::new();

    io::stdin()
        .read_line(&mut guess)
        .expect("Fehler beim Lesen der Zeile");

    println!("Du hast geschätzt: {}", guess);
}
```

<span class="caption">Codeblock 2-3: Hinzufügen von Code zum Generieren einer
Zufallszahl</span>

Zuerst fügen wir eine Zeile `use` hinzu: `use rand::Rng`. Das Merkmal (trait)
`Rng` definiert Methoden, die Zufallszahlengeneratoren implementieren, und
dieses Merkmal muss im Gültigkeitsbereich sein, damit wir diese Methoden
verwenden können. In Kapitel 10 werden Merkmale im Detail behandelt.

Als nächstes fügen wir zwei Zeilen in der Mitte hinzu. Die Funktion
`rand::thread_rng` gibt uns den speziellen Zufallszahlengenerator, den wir
verwenden werden: Einen, der lokal zum aktuellen Ausführungsstrang (thread) ist
und vom Betriebssystem initialisiert (seeded) wird. Dann rufen wir die Methode
`gen_range` des Zufallszahlengenerators auf. Diese Methode wird durch das
Merkmal `Rng` definiert, das wir mit der Anweisung `use rand::Rng` in den
Gültigkeitsbereich gebracht haben. Die Methode `gen_range` nimmt einen
Bereichsausdruck als Argument und generiert eine Zufallszahl in diesem Bereich.
Ein Bereichsausdruck hat die Form `start..end`. Er beinhaltet die
Untergrenze, nicht jedoch die Obergrenze, sodass wir `1..101` angeben müssen,
um eine Zahl zwischen 1 und 100 zu erhalten. Alternativ könnten wir den Bereich
`1..=100` angeben, was äquivalent ist.

> Hinweis: Du wirst nicht immer wissen, welche Merkmale du verwenden sollst und
> welche Methoden und Funktionen einer Kiste du aufrufen musst. Anleitungen zur
> Verwendung einer Kiste findest du in der Dokumentation jeder Kiste. Eine
> weitere nette Funktionalität von Cargo ist, dass du das Kommando `cargo doc
> --open` ausführen kannst, das die von all deinen Abhängigkeiten
> bereitgestellte Dokumentation lokal bereitstellt und in deinem Browser
> öffnet. Wenn du an anderen Funktionen der Kiste `rand` interessiert bist,
> führe zum Beispiel `cargo doc --open` aus und klicke auf `rand` in der
> Seitenleiste links.

Die zweite Zeile, die wir in der Mitte des Codes hinzugefügt haben, gibt die
Geheimzahl aus. Das ist hilfreich während wir das Programm entwickeln, um es
testen zu können, aber wir werden es aus der finalen Version entfernen. Es ist
kein echtes Spiel, wenn das Programm die Antwort ausgibt, sobald es startet!

Versuche, das Programm einige Male auszuführen:

```console
$ cargo run
   Compiling guessing_game v0.1.0 (file:///projects/guessing_game)
    Finished dev [unoptimized + debuginfo] target(s) in 2.53s
     Running `target/debug/guessing_game`
Rate die Zahl!
Die Geheimzahl ist: 7
Bitte gib deine Schätzung ein.
4
Du hast geschätzt: 4

$ cargo run
    Finished dev [unoptimized + debuginfo] target(s) in 0.02s
     Running `target/debug/guessing_game`
Rate die Zahl!
Die Geheimzahl ist: 83
Bitte gib deine Schätzung ein.
5
Du hast geschätzt: 5
```

Du solltest verschiedene Zufallszahlen erhalten und sie sollten alle zwischen 1
und 100 sein. Großartige Arbeit!

## Vergleichen der Schätzung mit der Geheimzahl

Jetzt, da wir eine Benutzereingabe und eine Zufallszahl haben, können wir sie
vergleichen. Dieser Schritt ist in Codeblock 2-4 dargestellt. Beachte, dass
sich dieser Code noch nicht ganz kompilieren lässt, wie wir erklären werden.

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore,does_not_compile
use rand::Rng;
use std::cmp::Ordering;
use std::io;

fn main() {
    // --abschneiden--
#     println!("Rate die Zahl!");
#
#     let secret_number = rand::thread_rng().gen_range(1..101);
#
#     println!("Die Geheimzahl ist: {}", secret_number);
#
#     println!("Bitte gib deine Schätzung ein.");
#
#     let mut guess = String::new();
#
#     io::stdin()
#         .read_line(&mut guess)
#         .expect("Fehler beim Lesen der Zeile");

    println!("Du hast geschätzt: {}", guess);

    match guess.cmp(&secret_number) {
        Ordering::Less => println!("Zu klein!"),
        Ordering::Greater => println!("Zu groß!"),
        Ordering::Equal => println!("Du hast gewonnen!"),
    }
}
```

<span class="caption">Codeblock 2-4: Behandeln der möglichen Rückgabewerte beim
Vergleich zweier Zahlen</span>

Das erste neue Element hier ist eine weitere `use`-Anweisung, die einen Typ
namens `std::cmp::Ordering` aus der Standardbibliothek in den
Gültigkeitsbereich bringt. Wie `Result` ist `Ordering` eine weitere Aufzählung,
aber die Varianten für `Ordering` sind `Less`, `Greater` und `Equal`. Dies sind
die drei Ergebnisse, die möglich sind, wenn man zwei Werte vergleicht.

Dann fügen wir unten fünf neue Zeilen hinzu, die den Typ `Ordering` verwenden.
Die `cmp`-Methode vergleicht zwei Werte und kann auf alles, was verglichen
werden kann, angewendet werden. Sie braucht eine Referenz auf das, was du
vergleichen willst: Hier wird `guess` mit `secret_number` verglichen. Dann gibt
sie eine Variante der `Ordering`-Aufzählung zurück, die wir mit der
`use`-Anweisung in den Gültigkeitsbereich gebracht haben. Wir verwenden einen
[`match`][match]-Ausdruck, um zu entscheiden, was als nächstes zu tun ist,
basierend darauf, welche `Ordering`-Variante vom Aufruf von `cmp` mit den
Werten in `guess` und `secret_number` zurückgegeben wurde.

Ein `match`-Ausdruck besteht aus *Zweigen* (arms). Ein Zweig besteht aus einem
*Muster* (pattern) und dem Code, der ausgeführt werden soll, wenn der Wert, der
am Anfang des `match`-Ausdrucks steht, zum Muster dieses Zweigs passt. Rust
nimmt den Wert, der bei `match` angegeben wurde, und schaut nacheinander durch
das Muster jedes Zweigs. Das `match`-Konstrukt und die Muster sind mächtige
Funktionalitäten in Rust, mit denen du eine Vielzahl von Situationen ausdrücken
kannst, auf die dein Code stoßen könnte, und die sicherstellen, dass du sie
alle behandelst. Diese Funktionalitäten werden ausführlich in Kapitel 6 bzw.
Kapitel 18 behandelt.

Gehen wir ein Beispiel dafür durch, was mit dem hier verwendeten
`match`-Ausdruck geschehen würde. Angenommen, der Benutzer hat 50 geschätzt und die
zufällig generierte Geheimzahl ist diesmal 38. Wenn der Code 50 mit 38
vergleicht, gibt die `cmp`-Methode `Ordering::Greater` zurück, weil 50 größer
als 38 ist. Der `match`-Ausdruck erhält den Wert `Ordering::Greater` und
beginnt mit der Überprüfung des Musters jedes Zweigs. Er schaut auf das Muster
`Ordering::Less` des ersten Zweigs und sieht, dass der Wert `Ordering::Greater`
nicht mit `Ordering::Less` übereinstimmt, also ignoriert er den Code in diesem
Zweig und geht zum nächsten Zweig über. Das Muster `Ordering::Greater` des
nächsten Zweigs *passt* zu `Ordering::Greater`! Der dazugehörige Code in diesem
Zweig wird ausgeführt und `Zu groß!` auf den Bildschirm ausgegeben. Der
`match`-Ausdruck endet, weil er in diesem Szenario nicht auf den letzten Zweig
zu schauen braucht.

Der Code in Codeblock 2-4 lässt sich jedoch noch nicht kompilieren. Lass es uns
versuchen:

```console
$ cargo build
   Compiling libc v0.2.51
   Compiling rand_core v0.4.0
   Compiling rand_core v0.3.1
   Compiling rand v0.5.6
   Compiling guessing_game v0.1.0 (file:///projects/guessing_game)
error[E0308]: mismatched types
  --> src/main.rs:22:21
   |
22 |     match guess.cmp(&secret_number) {
   |                     ^^^^^^^^^^^^^^ expected struct `String`, found integer
   |
   = note: expected reference `&String`
              found reference `&{integer}`

For more information about this error, try `rustc --explain E0308`.
error: could not compile `guessing_game` due to previous error
```

Der Kernbotschaft besagt, dass es *nicht übereinstimmende Typen* (mismatched
types) gibt. Rust hat ein starkes, statisches Typsystem. Es hat jedoch auch
eine Typ-Inferenz. Als wir `let mut guess = String::new()` schrieben, konnte
Rust daraus schließen, dass `guess` ein `String` sein sollte, und zwang uns
nicht, den Typ anzugeben. Die `secret_number` hingegen ist ein Zahlentyp.
Einige Zahlentypen können einen Wert zwischen 1 und 100 haben: `i32`, eine
32-Bit-Zahl; `u32`, eine 32-Bit-Zahl ohne Vorzeichen; `i64`, eine 64-Bit-Zahl;
sowie andere. Rust verwendet standardmäßig `i32`, was der Typ von
`secret_number` ist, es sei denn, du fügst an anderer Stelle Typinformationen
hinzu, die Rust veranlassen würden, auf einen anderen numerischen Typ zu
schließen. Der Grund für den Fehler liegt darin, dass Rust eine Zeichenkette
und einen Zahlentyp nicht vergleichen kann.

Letztendlich wollen wir den `String`, den das Programm als Eingabe liest, in
einen echten Zahlentyp umwandeln, damit wir ihn numerisch mit der Geheimzahl
vergleichen können. Das können wir tun, indem wir eine weitere Zeile zum
`main`-Funktionsrumpf hinzufügen:

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore
# use rand::Rng;
# use std::cmp::Ordering;
# use std::io;
#
# fn main() {
#     println!("Rate die Zahl!");
#
#     let secret_number = rand::thread_rng().gen_range(1..101);
#
#     println!("Die Geheimzahl ist: {}", secret_number);
#
#     println!("Bitte gib deine Schätzung ein.");
#
    // --abschneiden--

    let mut guess = String::new();

    io::stdin()
        .read_line(&mut guess)
        .expect("Fehler beim Lesen der Zeile");

    let guess: u32 = guess.trim().parse().expect("Bitte gib eine Zahl ein!");

    println!("Du hast geschätzt: {}", guess);

    match guess.cmp(&secret_number) {
        Ordering::Less => println!("Zu klein!"),
        Ordering::Greater => println!("Zu groß!"),
        Ordering::Equal => println!("Du hast gewonnen!"),
    }
}
```

Die Zeile lautet:

```rust,ignore
let guess: u32 = guess.trim().parse().expect("Bitte gib eine Zahl ein!");
```

Wir erstellen eine Variable mit dem Namen `guess`. Aber warte, hat das Programm
nicht bereits eine Variable namens `guess`? Ja, aber Rust erlaubt uns, den
vorherigen Wert von `guess` mit einem neuen Wert zu *beschatten* (shadow).
Diese Funktionalität wird häufig in Situationen verwendet, in denen du einen
Wert von einem Typ in einen anderen Typ konvertieren möchtest. Durch das
Beschatten können wir den Variablennamen `guess` wiederverwenden, anstatt uns
zu zwingen, zwei eindeutige Variablen zu erstellen, z.B. `guess_str` und
`guess`. (Kapitel 3 behandelt das Beschatten ausführlicher.)

Wir binden `guess` an den Ausdruck `guess.trim().parse()`. Das `guess` im
Ausdruck bezieht sich auf das ursprüngliche `guess`, das ein `String` mit der
Eingabe darin war. Die `trim`-Methode der `String`-Instanz wird alle
Leerzeichen am Anfang und am Ende entfernen. Obwohl `u32` nur numerische
Zeichen enthalten kann, muss der Benutzer die <span
class="keystroke">Eingabetaste</span> drücken, um `read_line`
zufriedenzustellen. Wenn der Benutzer die <span
class="keystroke">Eingabetaste</span> drückt, wird der Zeichenkette ein
Zeilenumbruchszeichen (newline character) hinzugefügt. Wenn der Benutzer z.B.
<span class="keystroke">5</span> eingibt und die <span
class="keystroke">Eingabetaste</span> drückt, sieht `guess` wie folgt aus:
`5\n`. Das `\n` steht für „Zeilenumbruch“ (newline), das Ergebnis des Drückens
der <span class="keystroke">Eingabetaste</span>. (Unter Windows ergibt das
Drücken der <span class="keystroke">Eingabetaste</span> einen Wagenrücklauf
(carriage return) und einen Zeilenumbruch (newline): `\r\n`) Die `trim`-Methode
entfernt `\n` und `\r\n`, was nur `5` ergibt.

Die [`parse`-Methode für Zeichenketten][parse] zerlegt eine Zeichenkette in
eine Art Zahl. Da diese Methode eine Vielzahl von Zahlentypen parsen kann,
müssen wir Rust den genauen Zahlentyp mitteilen, den wir wollen, indem wir `let
guess: u32` verwenden. Der Doppelpunkt (`:`) nach `guess` sagt Rust, dass wir
den Typ der Variablen annotieren werden. Rust hat ein paar eingebaute
Zahlentypen; `u32`, das du hier siehst, ist eine vorzeichenlose
32-Bit-Ganzzahl. Es ist eine gute Standardwahl für eine kleine positive Zahl.
Über andere Zahlentypen erfährst du in Kapitel 3. Zusätzlich bedeuten die
Annotation `u32` in diesem Beispielprogramm und der Vergleich mit
`secret_number`, dass Rust daraus ableiten wird, dass `secret_number` ebenfalls
ein `u32` sein sollte. Nun wird also der Vergleich zwischen zwei Werten
desselben Typs durchgeführt!

Der Aufruf von `parse` könnte leicht einen Fehler verursachen. Wenn die
Zeichenkette zum Beispiel `A👍%` enthielte, gäbe es keine Möglichkeit, dies in
eine Zahl umzuwandeln. Da dies fehlschlagen könnte, gibt die `parse`-Methode
einen `Result`-Typ zurück, ähnlich wie die `read_line`-Methode (weiter oben in
[„Behandeln potentieller Fehler mit dem Typ
`Result`“](#behandeln-potentieller-fehler-mit-dem-typ-result)). Wir werden
dieses `Result` auf die gleiche Weise behandeln, indem wir erneut `expect`
verwenden. Wenn `parse` eine `Err`-Variante von `Result` zurückgibt, weil es
keine Zahl aus der Zeichenkette erzeugen konnte, wird der `expect`-Aufruf das
Spiel zum Absturz bringen und die Nachricht ausgeben, die wir ihm geben. Wenn
`parse` die Zeichenkette erfolgreich in eine Zahl umwandeln kann, gibt es die
`Ok`-Variante von `Result` zurück, und `expect` gibt die Zahl zurück, die wir
vom `Ok`-Wert erwarten.

Lassen wir das Programm jetzt laufen!

```console
$ cargo run
   Compiling guessing_game v0.1.0 (file:///projects/guessing_game)
    Finished dev [unoptimized + debuginfo] target(s) in 0.43s
     Running `target/debug/guessing_game`
Rate die Zahl!
Die Geheimzahl ist: 58
Bitte gib deine Schätzung ein.
  76
Du hast geschätzt: 76
Zu groß!
```

Schön! Auch wenn vor der Schätzung Leerzeichen eingegeben wurden, fand das
Programm dennoch heraus, dass der Benutzer 76 geschätzt hat. Führe das Programm
einige Male aus, um das unterschiedliche Verhalten bei verschiedenen
Eingabearten zu überprüfen: Schätze die Zahl richtig, schätze eine zu große Zahl
und schätze eine zu kleine Zahl.

Der Großteil des Spiels funktioniert jetzt, aber der Benutzer kann nur *eine*
Schätzung anstellen. Ändern wir das, indem wir eine Schleife hinzufügen!

## Zulassen mehrerer Schätzungen mittels Schleife

Das Schlüsselwort `loop` erzeugt eine Endlosschleife. Wir fügen diese jetzt
hinzu, um den Benutzern mehr Chancen zu geben, die Zahl zu erraten:

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore
# use rand::Rng;
# use std::cmp::Ordering;
# use std::io;
#
# fn main() {
#     println!("Rate die Zahl!");
#
#     let secret_number = rand::thread_rng().gen_range(1..101);
#
    // --abschneiden--

    println!("Die Geheimzahl ist: {}", secret_number);

    loop {
        println!("Bitte gib deine Schätzung ein.");

        // --abschneiden--

#         let mut guess = String::new();
#
#         io::stdin()
#             .read_line(&mut guess)
#             .expect("Fehler beim Lesen der Zeile");
#
#         let guess: u32 = guess.trim().parse().expect("Bitte gib eine Zahl ein!");
#
#         println!("Du hast geschätzt: {}", guess);
#
        match guess.cmp(&secret_number) {
            Ordering::Less => println!("Zu klein!"),
            Ordering::Greater => println!("Zu groß!"),
            Ordering::Equal => println!("Du hast gewonnen!"),
        }
    }
}
```

Wie du sehen kannst, haben wir alles ab der Eingabeaufforderung für die
Schätzung in eine Schleife verschoben. Achte darauf, die Zeilen innerhalb der
Schleife jeweils um weitere vier Leerzeichen einzurücken und das Programm
erneut auszuführen. Beachte, dass es ein neues Problem gibt, weil das Programm
genau das tut, was wir ihm gesagt haben: Frage für immer nach einer weiteren
Schätzung! Es sieht nicht so aus, als könne der Benutzer das Programm beenden!

Der Benutzer könnte das Programm jederzeit mit dem Tastaturkürzel <span
class="keystroke">Strg+c</span> unterbrechen. Aber es gibt noch eine andere
Möglichkeit, diesem unersättlichen Monster zu entkommen, wie in der
`parse`-Diskussion in [„Vergleichen der Schätzung mit der
Geheimzahl“](#vergleichen-der-schätzung-mit-der-geheimzahl) erwähnt: Wenn der
Benutzer eine Antwort ohne Zahl eingibt, stürzt das Programm ab. Der Benutzer
kann das ausnutzen, um das Programm zu beenden, wie hier gezeigt:

```console
$ cargo run
   Compiling guessing_game v0.1.0 (file:///projects/guessing_game)
    Finished dev [unoptimized + debuginfo] target(s) in 1.50s
     Running `target/debug/guessing_game`
Rate die Zahl!
Die Geheimzahl ist: 59
Bitte gib deine Schätzung ein.
45
Du hast geschätzt: 45
Zu klein!
Bitte gib deine Schätzung ein.
60
Du hast geschätzt: 60
Zu groß!
Bitte gib deine Schätzung ein.
59
Du hast geschätzt: 59
Du hast gewonnen!
Bitte gib deine Schätzung ein.
quit
thread 'main' panicked at 'Bitte gib eine Zahl ein!: ParseIntError { kind: InvalidDigit }', src/libcore/result.rs:999:5
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
```

Mit der Eingabe von `quit` wird das Spiel tatsächlich beendet, aber das gilt
auch für alle anderen Eingaben, die keine Zahlen sind. Dies ist jedoch, gelinde
gesagt, suboptimal. Wir wollen, dass das Spiel automatisch beendet wird, wenn
die richtige Zahl erraten wird.

### Beenden nach einer korrekten Schätzung

Programmieren wir das Spiel so, dass es beendet wird, wenn der Benutzer
gewinnt, indem wir eine `break`-Anweisung hinzufügen:

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore
# use rand::Rng;
# use std::cmp::Ordering;
# use std::io;
#
# fn main() {
#     println!("Rate die Zahl!");
#
#     let secret_number = rand::thread_rng().gen_range(1..101);
#
#     println!("Die Geheimzahl ist: {}", secret_number);
#
#     loop {
#         println!("Bitte gib deine Schätzung ein.");
#
#         let mut guess = String::new();
#
#         io::stdin()
#             .read_line(&mut guess)
#             .expect("Fehler beim Lesen der Zeile");
#
#         let guess: u32 = guess.trim().parse().expect("Bitte gib eine Zahl ein!");
#
#         println!("Du hast geschätzt: {}", guess);
#
        // --abschneiden--

        match guess.cmp(&secret_number) {
            Ordering::Less => println!("Zu klein!"),
            Ordering::Greater => println!("Zu groß!"),
            Ordering::Equal => {
                println!("Du hast gewonnen!");
                break;
            }
        }
    }
}
```

Das Hinzufügen der `break`-Zeile nach `Du hast gewonnen!` bewirkt, dass das
Programm die Schleife verlässt, wenn der Benutzer die Geheimzahl richtig errät.
Die Schleife zu verlassen bedeutet auch, das Programm zu beenden, da die
Schleife der letzte Teil von `main` ist.

### Behandeln ungültiger Eingaben

Um das Verhalten des Spiels weiter zu verfeinern, sollten wir das Programm
nicht abstürzen lassen, wenn der Benutzer keine gültige Zahl eingibt, sondern
dafür sorgen, dass das Spiel ungültige Zahlen ignoriert, damit der Benutzer
weiter raten kann. Das können wir erreichen, indem wir die Zeile ändern, in der
`guess` von `String` in `u32` umgewandelt wird, wie in Codeblock 2-5 gezeigt.

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore
# use rand::Rng;
# use std::cmp::Ordering;
# use std::io;
#
# fn main() {
#     println!("Rate die Zahl!");
#
#     let secret_number = rand::thread_rng().gen_range(1..101);
#
#     println!("Die Geheimzahl ist: {}", secret_number);
#
#     loop {
#         println!("Bitte gib deine Schätzung ein.");
#
#         let mut guess = String::new();
#
        // --abschneiden--

        io::stdin()
            .read_line(&mut guess)
            .expect("Fehler beim Lesen der Zeile");

        let guess: u32 = match guess.trim().parse() {
            Ok(num) => num,
            Err(_) => continue,
        };

        println!("Du hast geschätzt: {}", guess);

        // --abschneiden--
#
#         match guess.cmp(&secret_number) {
#             Ordering::Less => println!("Zu klein!"),
#             Ordering::Greater => println!("Zu groß!"),
#             Ordering::Equal => {
#                 println!("Du hast gewonnen!");
#                 break;
#             }
#         }
#     }
# }
```

<span class="caption">Codeblock 2-5: Ignorieren einer ungültigen Zahl und
Auffordern zu einer weiteren Schätzung, anstatt das Programm zum Absturz zu
bringen</span>

Das Umstellen von einem `expect`-Aufruf zu einem `match`-Ausdruck ist eine
Möglichkeit für den Übergang vom Absturz bei einem Fehler zur Behandlung des
Fehlers. Denke daran, dass `parse` einen `Result`-Typ zurückgibt und `Result`
eine Aufzählung ist, die die Varianten `Ok` und `Err` hat. Wir benutzen hier
einen `match`-Ausdruck, wie wir es mit dem `Ordering`-Ergebnis der
`cmp`-Methode getan haben.

Wenn `parse` in der Lage ist, die Zeichenkette erfolgreich in eine Zahl
umzuwandeln, gibt es einen `Ok`-Wert zurück, der die resultierende Zahl
enthält. Dieser `Ok`-Wert wird mit dem Muster des ersten Zweigs übereinstimmen
und der `match`-Ausdruck wird nur den `num`-Wert zurückgeben, der durch `parse`
erzeugt und in den `Ok`-Wert eingefügt wurde. Diese Zahl wird in der neuen
`guess`-Variable, die wir erzeugen, genau dort landen, wo wir sie haben wollen.

Wenn `parse` *nicht* in der Lage ist, die Zeichenkette in eine Zahl
umzuwandeln, gibt es einen `Err`-Wert zurück, der mehr Informationen über den
Fehler enthält. Der `Err`-Wert stimmt nicht mit dem `Ok(num)`-Muster im ersten
`match`-Zweig überein, aber er stimmt mit dem `Err(_)`-Muster im zweiten Zweig
überein. Der Unterstrich `_` ist ein Sammelbehälter; in diesem Beispiel sagen
wir, dass alle `Err`-Werte übereinstimmen sollen, egal welche Informationen sie
enthalten. Das Programm wird also den Code `continue` des zweiten Zweigs
ausführen, der das Programm anweist, zur nächsten `loop`-Iteration zu gehen und
nach einer weiteren Schätzung zu fragen. Effektiv ignoriert das Programm also
alle Fehler, die bei `parse` auftreten könnten!

Jetzt sollte alles im Programm wie erwartet funktionieren. Lass es uns
versuchen:

```console
$ cargo run
   Compiling guessing_game v0.1.0 (file:///projects/guessing_game)
     Running `target/debug/guessing_game`
Rate die Zahl!
Die Geheimzahl ist: 61
Bitte gib deine Schätzung ein.
10
Du hast geschätzt: 10
Zu klein!
Bitte gib deine Schätzung ein.
99
Du hast geschätzt: 99
Zu groß!
Bitte gib deine Schätzung ein.
foo
Bitte gib deine Schätzung ein.
61
Du hast geschätzt: 61
Du hast gewonnen!
```

Fantastisch! Mit einem winzigen letzten Feinschliff beenden wir das Ratespiel.
Denke daran, dass das Programm immer noch die Geheimzahl ausgibt. Das hat beim
Testen gut funktioniert, aber es ruiniert das Spiel. Löschen wir das
`println!`, das die Geheimzahl ausgibt. Codeblock 2-6 zeigt den finalen Code.

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore
use rand::Rng;
use std::cmp::Ordering;
use std::io;

fn main() {
    println!("Rate die Zahl!");

    let secret_number = rand::thread_rng().gen_range(1..101);

    loop {
        println!("Bitte gib deine Schätzung ein.");

        let mut guess = String::new();

        io::stdin()
            .read_line(&mut guess)
            .expect("Fehler beim Lesen der Zeile");

        let guess: u32 = match guess.trim().parse() {
            Ok(num) => num,
            Err(_) => continue,
        };

        println!("Du hast geschätzt: {}", guess);

        match guess.cmp(&secret_number) {
            Ordering::Less => println!("Zu klein!"),
            Ordering::Greater => println!("Zu groß!"),
            Ordering::Equal => {
                println!("Du hast gewonnen!");
                break;
            }
        }
    }
}
```

<span class="caption">Codeblock 2-6: Vollständiger Code des
Ratespiels</span>

## Zusammenfassung

An diesem Punkt hast du das Ratespiel erfolgreich aufgebaut. Herzlichen
Glückwunsch!

Dieses Projekt war eine praktische Möglichkeit, dich mit vielen neuen
Rust-Konzepten vertraut zu machen: `let`, `match`, Funktionen, das Verwenden
von externen Kisten und mehr. In den nächsten Kapiteln erfährst du mehr über
diese Konzepte. Kapitel 3 behandelt Konzepte, über die die meisten
Programmiersprachen verfügen, z.B. Variablen, Datentypen und Funktionen, und
zeigt, wie man sie in Rust verwendet. Kapitel 4 untersucht die
Eigentümerschaft, eine Funktionalität, die Rust von anderen Sprachen
unterscheidet. In Kapitel 5 werden Strukturen (structs) und die Methodensyntax
besprochen und in Kapitel 6 wird die Funktionsweise von Aufzählungen erläutert.

[cratesio]: https://crates.io/
[doccargo]: http://doc.crates.io
[doccratesio]: http://doc.crates.io/crates-io.html
[enums]: ch06-00-enums.html
[expect]: https://doc.rust-lang.org/std/result/enum.Result.html#method.expect
[ioresult]: https://doc.rust-lang.org/std/io/type.Result.html
[iostdin]: https://doc.rust-lang.org/std/io/struct.Stdin.html
[match]: ch06-02-match.html
[parse]: https://doc.rust-lang.org/std/primitive.str.html#method.parse
[prelude]: https://doc.rust-lang.org/std/prelude/index.html
[randcrate]: https://crates.io/crates/rand
[read_line]: https://doc.rust-lang.org/std/io/struct.Stdin.html#method.read_line
[result]: https://doc.rust-lang.org/std/result/enum.Result.html
[semver]: https://semver.org/lang/de/
[string]: https://doc.rust-lang.org/std/string/struct.String.html
[variables-and-mutability]: ch03-01-variables-and-mutability.html
