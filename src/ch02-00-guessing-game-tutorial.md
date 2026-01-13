# Ein Ratespiel programmieren

Lass uns den Sprung in Rust wagen, indem wir gemeinsam ein praktisches Projekt
durcharbeiten! Dieses Kapitel führt dich in einige gängige Rust-Konzepte ein,
indem es dir zeigt, wie du diese in einem realen Programm verwenden kannst. Du
lernst `let`, `match`, Methoden, assoziierte Funktionen, externe Kisten
(crates) und mehr kennen! In den folgenden Kapiteln werden wir diese Ideen
ausführlicher behandeln. In diesem Kapitel wirst du nur die Grundlagen üben.

Wir werden ein klassisches Programmierproblem für Anfänger implementieren: Ein
Ratespiel. Und so funktioniert es: Das Programm erzeugt eine zufällige ganze
Zahl zwischen 1 und 100. Dann wird es den Spieler auffordern, eine Schätzung
einzugeben. Nachdem eine Schätzung eingegeben wurde, zeigt das Programm an, ob
die Schätzung zu niedrig oder zu hoch ist. Wenn die Schätzung korrekt ist, gibt
das Spiel eine Glückwunschnachricht aus und beendet sich.

## Aufsetzen eines neuen Projekts

Um ein neues Projekt aufzusetzen, gehe in das Verzeichnis _projects_, das du in
Kapitel 1 erstellt hast, und erstelle ein neues Projekt mit Cargo, wie folgt:

```console
$ cargo new guessing_game
$ cd guessing_game
```

Der erste Befehl `cargo new` nimmt den Namen des Projekts (`guessing_game`) als
erstes Argument. Der zweite Befehl wechselt in das Verzeichnis des neuen
Projekts.

Schaue dir die generierte Datei _Cargo.toml_ an:

<span class="filename">Dateiname: Cargo.toml</span>

```toml
[package]
name = "guessing_game"
version = "0.1.0"
edition = "2024"

[dependencies]
```

Wie du in Kapitel 1 gesehen hast, generiert `cargo new` ein „Hello,
world!“-Programm für dich. Sieh dir die Datei _src/main.rs_ an:

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
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 1.50s
     Running `target/debug/guessing_game`
Hello, world!
```

Der Befehl `run` ist praktisch, wenn du ein Projekt schnell iterieren musst,
wie wir es in diesem Spiel tun werden, indem du jede Iteration schnell testest,
bevor du zur nächsten übergehst.

Öffne die Datei _src/main.rs_ erneut. Du wirst den gesamten Code in diese Datei
schreiben.

## Verarbeiten einer Schätzung

Der erste Teil des Ratespielprogramms fragt nach einer Benutzereingabe,
verarbeitet diese Eingabe und überprüft, ob die Eingabe in der erwarteten Form
vorliegt. Zu Beginn erlauben wir dem Spieler, eine Schätzung einzugeben. Gib
den Code aus Codeblock 2-1 in _src/main.rs_ ein.

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

    println!("Du hast geschätzt: {guess}");
}
```

<span class="caption">Codeblock 2-1: Code, der eine Schätzung vom Benutzer
erhält und ausgibt</span>

Dieser Code enthält eine Menge Informationen, also gehen wir ihn Zeile für
Zeile durch. Um eine Benutzereingabe zu erhalten und das Ergebnis dann als
Ausgabe auszugeben, müssen wir die Bibliothek `io` (input/output) in den
Gültigkeitsbereich bringen. Die `io`-Bibliothek stammt aus der
Standardbibliothek, bekannt als `std`:

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
#     println!("Du hast geschätzt: {guess}");
# }
```

Standardmäßig hat Rust einige Elemente in der Standardbibliothek definiert,
die es in den Gültigkeitsbereich jedes Programms bringt. Diese Menge wird
_Präludium_ genannt, und du kannst deren Inhalt [in der Dokumentation der
Standardbibliothek][prelude] sehen.

Wenn ein Typ, den du verwenden willst, nicht im Präludium enthalten ist, musst
du diesen Typ explizit mit einer `use`-Anweisung in den Gültigkeitsbereich
bringen. Das Verwenden der Bibliothek `std::io` bietet dir eine Reihe von
nützlichen Funktionalitäten, einschließlich der Möglichkeit, Benutzereingaben
entgegenzunehmen.

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
#     println!("Du hast geschätzt: {guess}");
# }
```

Die Syntax `fn` deklariert eine neue Funktion; die Klammern `()` zeigen an,
dass es keine Parameter gibt; und die geschweifte Klammer `{` beginnt den Rumpf
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
#     println!("Du hast geschätzt: {guess}");
# }
```

Dieser Code gibt eine Eingabeaufforderung aus, die angibt, um was für ein Spiel
es sich handelt, und den Benutzer zur Eingabe auffordert.

### Speichern von Werten mit Variablen

Als Nächstes erstellen wir eine _Variable_, um die Benutzereingabe zu
speichern, wie hier:

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
#     println!("Du hast geschätzt: {guess}");
# }
```

Jetzt wird das Programm interessant! Es ist viel los in dieser kleinen Zeile.
Wir verwenden eine `let`-Anweisung, um eine Variable zu erzeugen. Hier ist ein
weiteres Beispiel:

```rust,ignore
let apples = 5;
```

Diese Zeile erzeugt eine neue Variable namens `apples` und bindet sie an den
Wert `5`. In Rust sind Variablen standardmäßig unveränderbar (immutable), das
heißt, sobald wir der Variablen einen Wert gegeben haben, wird sich der Wert
nicht mehr ändern. Wir werden dieses Konzept im Abschnitt [„Variablen und
Veränderbarkeit“][variables-and-mutability] in Kapitel 3 ausführlich
besprechen. Um eine Variable veränderbar zu machen, ergänzen wir `mut` vor dem
Variablennamen:

```rust
let apples = 5; // unveränderbar
let mut bananas = 5; // veränderbar
```

> Anmerkung: Die Syntax `//` beginnt einen Kommentar, der bis zum Ende der
> Zeile weitergeht. Rust ignoriert alles in Kommentaren. Diese werden in
> Kapitel 3 ausführlicher besprochen.

Zurück zum Programm des Ratespiels. Du weißt jetzt, dass `let mut
guess` eine veränderbare Variable namens `guess` einführt. Das
Gleichheitszeichen (`=`) sagt Rust, dass wir jetzt etwas an die Variable binden
wollen. Auf der rechten Seite des Gleichheitszeichens steht der Wert, an den
`guess` gebunden ist, was das Ergebnis des Aufrufs von `String::new` ist, einer
Funktion, die eine neue Instanz eines `String` zurückgibt. [`String`][string]
ist ein von der Standardbibliothek bereitgestellter Zeichenketten-Typ, der ein
wachstumsfähiges, UTF-8-kodiertes Stück Text ist.

Die Syntax `::` in der Zeile `::new` zeigt an, dass `new` eine assoziierte
Funktion (associated function) vom Typ `String` ist. Eine _assoziierte
Funktion_ ist eine Funktion, die auf einem Typ, in diesem Fall `String`,
implementiert ist. Diese Funktion `new` erzeugt eine neue, leere Zeichenkette.
Du wirst eine Funktion `new` bei vielen Typen finden, weil es ein
gebräuchlicher Name für eine Funktion ist, die einen neuen Wert irgendeiner Art
erzeugt.

Insgesamt hat die Zeile `let mut guess = String::new();` eine veränderbare
Variable erzeugt, die derzeit an eine neue, leere Instanz eines `String`
gebunden ist. Uff!

### Empfangen von Benutzereingaben

Erinnere dich, dass wir die Ein-/Ausgabefunktionalität aus der
Standardbibliothek mit `use std::io;` in der ersten Zeile des Programms
eingebunden haben. Jetzt rufen wir die Funktion `stdin` aus dem Modul `io` auf,
die es uns ermöglichen wird, Benutzereingaben zu verarbeiten.


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
#     println!("Du hast geschätzt: {guess}");
# }
```

Hätten wir das Modul `io` nicht am Anfang des Programms mit `use std::io;`
importiert, könnten wir die Funktion trotzdem verwenden, indem wir den
Funktionsaufruf als `std::io::stdin` schreiben. Die Funktion `stdin` gibt eine
Instanz von [`std::io::Stdin`][iostdin] zurück, was ein Typ ist, der eine
Standardeingaberessource (handle to the standard input) für dein Terminal
darstellt.

Die nächste Zeile `.read_line(&mut guess)` ruft die Methode
[`read_line`][read_line] der Standardeingaberessource auf, um eine Eingabe vom
Benutzer zu erhalten. Wir übergeben auch das Argument `&mut guess` an
`read_line`, um ihm mitzuteilen, in welche Zeichenkette es die Benutzereingabe
speichern soll. Die Aufgabe von `read_line` ist es, alles, was der Benutzer in
die Standardeingabe eingibt, an eine Zeichenkette anzuhängen (ohne deren Inhalt
zu überschreiben), daher übergeben wir diese Zeichenkette als Argument. Das
Zeichenketten-Argument muss veränderbar sein, damit die Methode den Inhalt der
Zeichenkette ändern kann.

Das `&` zeigt an, dass es sich bei diesem Argument um eine _Referenz_ handelt,
die dir eine Möglichkeit bietet, mehrere Teile deines Codes auf einen Datenteil
zugreifen zu lassen, ohne dass du diese Daten mehrfach in den Speicher kopieren
musst. Referenzen sind eine komplexe Funktionalität, und einer der
Hauptvorteile von Rust ist, wie sicher und einfach es ist, Referenzen zu
verwenden. Du musst nicht viele dieser Details kennen, um dieses Programm
fertigzustellen. Im Moment musst du nur wissen, dass Referenzen wie Variablen
standardmäßig unveränderbar sind. Daher musst du `&mut guess` anstatt `&guess`
schreiben, um sie veränderbar zu machen. (In Kapitel 4 werden Referenzen
ausführlicher erklärt.)

### Behandeln potentieller Fehler mit `Result`

Wir arbeiten noch immer an dieser Codezeile. Wir besprechen jetzt eine dritte
Textzeile, aber beachte, dass sie immer noch Teil einer einzigen logischen
Codezeile ist. Der nächste Teil ist diese Methode:

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
#     println!("Du hast geschätzt: {guess}");
# }
```

Wir hätten diesen Code auch so schreiben können:

```rust,ignore
io::stdin().read_line(&mut guess).expect("Fehler beim Lesen der Zeile");
```

Eine lange Zeile ist jedoch schwer zu lesen, daher ist es am besten, sie
aufzuteilen. Es ist oft ratsam, einen Zeilenumbruch und andere Leerzeichen
einzufügen, um lange Zeilen aufzubrechen, wenn du eine Methode mit der
Syntax `.method_name()` aufrufst. Lass uns nun besprechen, was diese Zeile
bewirkt. 

Wie bereits erwähnt, schreibt `read_line` die Benutzereingabe in die übergebene
Zeichenketten-Variable, gibt aber darüber hinaus auch einen `Result`-Wert
zurück. [`Result`][result] ist eine [_Aufzählung_][enums] (enumeration, oder
kurz enum), die einen Datentyp darstellt, der einem von mehreren möglichen
Zuständen annehmen kann. Wir nennen jeden möglichen Zustand eine _Variante_.

In Kapitel 6 werden [Aufzählungen][enums] ausführlicher behandelt. Der Zweck
dieser `Result`-Typen ist es, Informationen zur Fehlerbehandlung zu kodieren.

Die Varianten von `Result` sind `Ok` und `Err`. Die Variante `Ok` gibt an, dass
die Operation erfolgreich war, und enthält den erfolgreich generierten Wert.
Die Variante `Err` bedeutet, dass die Operation fehlgeschlagen ist, und enthält
Informationen darüber, wie oder warum die Operation fehlgeschlagen ist.

Für Werte vom Typ `Result` sind, wie für Werte jedes Typs, Methoden definiert.
Eine Instanz von `Result` hat eine [Methode `expect`][expect], die du
aufrufen kannst. Wenn diese `io::Result`-Instanz ein `Err`-Wert ist, wird
`expect` das Programm zum Absturz bringen und die Meldung anzeigen, die du als
Argument an `expect` übergeben hast. Wenn die Methode `read_line` ein `Err`
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
   |     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
   |
   = note: this `Result` may be an `Err` variant, which should be handled
   = note: `#[warn(unused_must_use)]` on by default
help: use `let _ = ...` to ignore the resulting value
   |
10 |     let _ = io::stdin().read_line(&mut guess);
   |     +++++++

warning: `guessing_game` (bin "guessing_game") generated 1 warning
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.59s
```

Rust warnt, dass du den von `read_line` zurückgegebenen `Result`-Wert nicht
verwendet hast, was darauf hinweist, dass das Programm einen möglichen Fehler
nicht behandelt hat.

Der richtige Weg, die Warnung zu unterdrücken, ist eine Fehlerbehandlung zu
schreiben, aber da wir dieses Programm einfach nur abstürzen lassen wollen,
wenn ein Problem auftritt, können wir `expect` verwenden. In [Kapitel
9][recover] erfährst du, wie man sich von Fehlern erholt.

### Ausgeben von Werten mit `println!`-Platzhaltern

Abgesehen von der schließenden geschweiften Klammer gibt es in dem bisher
hinzugefügten Code nur noch eine weitere Zeile zu besprechen: 

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
    println!("Du hast geschätzt: {guess}");
# }
```

Diese Zeile gibt die Zeichenkette aus, die jetzt die Eingabe des Benutzers
enthält. Der Satz geschweifte Klammern `{}` ist ein Platzhalter:
Stelle dir `{}` wie kleine Krebszangen vor, die einen Wert an Ort und Stelle
halten. Wenn du den Wert einer Variablen ausgibst, kann der Variablenname
innerhalb der geschweiften Klammern stehen. Wenn du das Ergebnis der Auswertung
eines Ausdrucks ausgeben willst, füge leere geschweifte Klammern in die
Formatierungszeichenkette ein und gib dann nach der Formatierungszeichenkette
eine durch Komma getrennte Liste von Ausdrücken ein, die in jedem leeren
geschweiften Klammerplatzhalter in derselben Reihenfolge ausgegeben werden
sollen. Das Ausgeben einer Variablen und des Ergebnisses eines Ausdrucks in
einem Aufruf von `println!` würde wie folgt aussehen:

```rust
let x = 5;
let y = 10;

println!("x = {x} und y + 2 = {}", y + 2);
```

Dieser Code würde `x = 5 und y + 2 = 12` ausgeben.

### Testen des ersten Teils

Testen wir den ersten Teil des Ratespiels. Führe ihn mit `cargo run` aus:

```console
$ cargo run
   Compiling guessing_game v0.1.0 (file:///projects/guessing_game)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 6.44s
     Running `target/debug/guessing_game`
Rate die Zahl!
Bitte gib deine Schätzung ein.
6
Du hast geschätzt: 6
```

An diesem Punkt ist der erste Teil des Spiels abgeschlossen: Wir erhalten
eine Eingabe über die Tastatur und geben sie dann aus.

## Generieren einer Geheimzahl

Als Nächstes müssen wir eine Geheimzahl generieren, die der Benutzer versucht 
zu erraten. Die Geheimzahl sollte jedes Mal anders sein, damit das Spiel mehr als
einmal Spaß macht. Wir werden eine Zufallszahl zwischen 1 und 100 verwenden,
damit das Spiel nicht zu schwierig wird. Rust enthält noch keine
Zufallszahl-Funktionalität in seiner Standardbibliothek. Das Rust-Team stellt
jedoch eine [Kiste `rand`][randcrate] mit besagter Funktionalität zur
Verfügung.

### Mehr Funktionalität mit einer Kiste

Denke daran, dass eine Kiste eine Sammlung von Rust-Quellcode-Dateien ist. Unser
Projekt "Ratespiel" ist eine _binäre Kiste_ (binary crate), die eine
ausführbare Datei ist. Die Kiste `rand` ist eine _Bibliotheks-Kiste_ (library
crate), die Code enthält, der in anderen Programmen verwendet werden soll.

Das Koordinieren von externen Kisten ist der Bereich, in dem Cargo glänzt.
Bevor wir Code schreiben können, der `rand` benutzt, müssen wir die Datei
_Cargo.toml_ so modifizieren, dass die Kiste `rand` als Abhängigkeit
eingebunden wird. Öffne jetzt diese Datei und füge die folgende Zeile unten
unter der Überschrift des Abschnitts `[dependencies]` hinzu, den Cargo für dich
erstellt hat. Stelle sicher, dass du `rand` genau so angibst, wie wir es hier
getan haben, andernfalls funktionieren die Codebeispiele in dieser Anleitung
möglicherweise nicht.

<span class="filename">Dateiname: Cargo.toml</span>

```toml
[dependencies]
rand = "0.8.5"
```

In der Datei _Cargo.toml_ ist alles, was nach einer Überschrift folgt, Teil
dieses Abschnitts, der so lange andauert, bis ein anderer Abschnitt beginnt. Im
Abschnitt `[dependencies]` teilst du Cargo mit, von welchen externen Kisten
dein Projekt abhängt und welche Versionen dieser Kisten du benötigst. In diesem
Fall spezifizieren wir die Kiste `rand` mit dem semantischen
Versionsspezifikator `0.8.5`. Cargo versteht [semantische
Versionierung][semver] (manchmal auch _SemVer_ genannt), was ein Standard zum
Schreiben von Versionsnummern ist. Die Angabe `0.8.5` ist eigentlich die
Abkürzung für `^0.8.5`, was für alle Versionen ab `0.8.5` und kleiner als
`0.9.0` steht.

Cargo geht davon aus, dass die öffentliche API dieser Versionen kompatibel zur
Version 0.8.5 ist und diese Angabe stellt sicher, dass du die neueste
Patch-Version erhältst, die noch mit dem Code in diesem Kapitel kompiliert
werden kann. Ab Version `0.9.0` ist nicht garantiert, dass die API mit der in
den folgenden Beispielen verwendeten übereinstimmt.

Lass uns nun, ohne den Code zu ändern, das Projekt bauen, wie in Codeblock 2-2
gezeigt.

```console
$ cargo build
  Updating crates.io index
   Locking 15 packages to latest Rust 1.85.0 compatible versions
    Adding rand v0.8.5 (available: v0.9.0)
 Compiling proc-macro2 v1.0.93
 Compiling unicode-ident v1.0.17
 Compiling libc v0.2.170
 Compiling cfg-if v1.0.0
 Compiling byteorder v1.5.0
 Compiling getrandom v0.2.15
 Compiling rand_core v0.6.4
 Compiling quote v1.0.38
 Compiling syn v2.0.98
 Compiling zerocopy-derive v0.7.35
 Compiling zerocopy v0.7.35
 Compiling ppv-lite86 v0.2.20
 Compiling rand_chacha v0.3.1
 Compiling rand v0.8.5
 Compiling guessing_game v0.1.0 (file:///projects/guessing_game)
  Finished `dev` profile [unoptimized + debuginfo] target(s) in 2.48s
```

<span class="caption">Codeblock 2-2: Die Ausgabe beim Ausführen von `cargo
build` nach dem Hinzufügen der Kiste `rand` als Abhängigkeit</span>

Möglicherweise siehst du unterschiedliche Versionsnummern (aber dank SemVer
sind sie alle mit dem Code kompatibel!) und unterschiedliche Zeilen (je nach
Betriebssystem), und die Zeilen können in einer anderen Reihenfolge erscheinen.

Wenn wir eine externe Abhängigkeit einfügen, holt Cargo die neuesten
Versionen von allem was die Abhängigkeit aus der _Registry_ benötigt, was eine
Kopie der Daten von [Crates.io][cratesio] ist. Crates.io ist der Ort, an dem
die Menschen im Rust-Ökosystem ihre Open-Source-Rustprojekte für andere zur
Nutzung bereitstellen.

Nach dem Aktualisieren der Registry überprüft Cargo den Abschnitt
`[dependencies]` und lädt alle aufgelisteten Kisten herunter, die noch nicht
heruntergeladen wurden. Obwohl wir nur `rand` als Abhängigkeit aufgelistet
haben, hat sich Cargo in diesem Fall auch andere Kisten geschnappt, von denen
`rand` abhängig ist, um zu funktionieren. Nachdem die Kisten heruntergeladen
wurden, kompiliert Rust sie und kompiliert dann das Projekt mit den verfügbaren
Abhängigkeiten.

Wenn du gleich wieder `cargo build` ausführst, ohne irgendwelche Änderungen
vorzunehmen, erhältst du keine Ausgabe außer der Zeile `Finished`. Cargo weiß,
dass es die Abhängigkeiten bereits heruntergeladen und kompiliert hat, und du
hast in deiner Datei _Cargo.toml_ nichts daran geändert. Cargo weiß auch, dass
du nichts an deinem Code geändert hast, also wird dieser auch nicht neu
kompiliert. Ohne etwas zu tun zu haben, wird es einfach beendet.

Wenn du die Datei _src/main.rs_ öffnest, eine triviale Änderung vornimmst und
sie dann speicherst und neu baust, siehst du nur zwei Zeilen Ausgabe:

```console
$ cargo build
   Compiling guessing_game v0.1.0 (file:///projects/guessing_game)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 2.53 secs
```

Diese Zeilen zeigen, dass Cargo nur den Build mit deiner winzigen Änderung an
der Datei _src/main.rs_ aktualisiert. Deine Abhängigkeiten haben sich nicht
geändert, sodass Cargo weiß, dass es wiederverwenden kann, was es bereits
heruntergeladen und kompiliert hat.

#### Sicherstellen reproduzierbarer Builds

Cargo verfügt über einen Mechanismus, der sicherstellt, dass du jedes Mal, wenn
du oder jemand anderes deinen Code baut, dasselbe Artefakt neu erstellen
kannst: Cargo wird nur die Versionen der von dir angegebenen Abhängigkeiten
verwenden, bis du etwas anderes angibst. Nehmen wir beispielsweise an, dass
nächste Woche Version 0.8.6 der Kiste `rand` herauskommt und eine wichtige
Fehlerkorrektur enthält, aber auch eine Regression, die deinen Code bricht. Um
dies zu handhaben, erstellt Rust die Datei _Cargo.lock_ beim ersten Mal, wenn
du `cargo build` ausführst, die nun im _guessing_game_-Verzeichnis liegt.

Wenn du ein Projekt zum ersten Mal baust, ermittelt Cargo alle Versionen der
Abhängigkeiten, die den Kriterien entsprechen, und schreibt sie dann in die
Datei _Cargo.lock_. Wenn du dein Projekt in der Zukunft baust, wird Cargo
sehen, dass die Datei _Cargo.lock_ existiert und die dort angegebenen Versionen
verwenden, anstatt die ganze Arbeit der Versionsfindung erneut zu machen. Auf
diese Weise erhältst du automatisch einen reproduzierbaren Build. Mit anderen
Worten, dein Projekt bleibt dank der Datei _Cargo.lock_ auf 0.8.5, bis du
explizit die Versionsnummer erhöhst. Da die Datei _Cargo.lock_ für das
reproduzierbare Bauen wichtig ist, wird sie oft zusammen mit dem restlichen
Code deines Projekts in die Versionskontrolle eingecheckt.

#### Aktualisieren einer Kiste, um eine neue Version zu erhalten

Wenn du eine Kiste aktualisieren _willst_, bietet Cargo den Befehl `update` an,
der die Datei _Cargo.lock_ ignoriert und alle neuesten Versionen, die deinen
Spezifikationen entsprechen, in _Cargo.toml_ herausfindet. Cargo schreibt diese
Versionen dann in die Datei _Cargo.lock_. Andernfalls wird Cargo standardmäßig
nur nach Versionen größer als 0.8.5 und kleiner als 0.9.0 suchen. Wenn die
Kiste `rand` zwei neue Versionen 0.8.6 und 0.999.0 veröffentlicht hat, würdest du
folgendes sehen, wenn du `cargo update` ausführst:

```console
$ cargo update
    Updating crates.io index
     Locking 1 package to latest Rust 1.85.0 compatible version
    Updating rand v0.8.5 -> v0.8.6 (available: v0.999.0)
```

Cargo ignoriert die Version 0.999.0. An diesem Punkt würdest du auch eine
Änderung in deiner Datei _Cargo.lock_ bemerken, die feststellt, dass die
Version der Kiste `rand`, die du jetzt benutzt, 0.8.6 ist. Um die
`rand`-Version 0.999.0 oder irgendeine Version aus der 0.999._x_-Serie zu
verwenden, müsstest du stattdessen die Datei _Cargo.toml_ anpassen, damit sie
wie folgt aussieht. (Führe diese Änderung nicht durch, da die folgenden
Beispiele davon ausgehen, dass du `rand` 0.8 verwendest.)

```toml
[dependencies]
rand = "0.999.0"
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

Beginnen wir mit `rand`, um eine Zahl zum Raten zu erzeugen. Der nächste
Schritt ist _src/main.rs_ zu ändern, wie in Codeblock 2-3 gezeigt.

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore
use std::io;
use rand::Rng;

fn main() {
    println!("Rate die Zahl!");

    let secret_number = rand::thread_rng().gen_range(1..=100);

    println!("Die Geheimzahl ist: {secret_number}");

    println!("Bitte gib deine Schätzung ein.");

    let mut guess = String::new();

    io::stdin()
        .read_line(&mut guess)
        .expect("Fehler beim Lesen der Zeile");

    println!("Du hast geschätzt: {guess}");
}
```

<span class="caption">Codeblock 2-3: Hinzufügen von Code zum Generieren einer
Zufallszahl</span>

Zuerst fügen wir die Zeile `use rand::Rng;` hinzu. Das Merkmal (trait)
`Rng` definiert Methoden, die Zufallszahlengeneratoren implementieren, und
dieses Merkmal muss im Gültigkeitsbereich sein, damit wir diese Methoden
verwenden können. In Kapitel 10 werden Merkmale im Detail behandelt.

Als nächstes fügen wir zwei Zeilen in der Mitte hinzu. In der ersten Zeile
rufen wir die Funktion `rand::thread_rng` auf, die uns den speziellen
Zufallszahlengenerator zurückgibt, den wir verwenden werden: Einen, der lokal
zum aktuellen Ausführungsstrang (thread) ist und vom Betriebssystem
initialisiert (seeded) wird. Dann rufen wir die Methode `gen_range` des
Zufallszahlengenerators auf. Diese Methode wird durch das Merkmal `Rng`
definiert, das wir mit der Anweisung `use rand::Rng;` in den Gültigkeitsbereich
gebracht haben. Die Methode `gen_range` nimmt einen Bereichsausdruck als
Argument und generiert eine Zufallszahl in diesem Bereich. Ein Bereichsausdruck
hat die Form `start..=end` und er beinhaltet die Untergrenze und die
Obergrenze, sodass wir `1..=100` angeben müssen, um eine Zahl zwischen 1 und 100
zu erhalten.

> Hinweis: Du wirst nicht immer wissen, welche Merkmale du verwenden sollst und
> welche Methoden und Funktionen einer Kiste du aufrufen musst, daher hat jede
> Kiste eine Dokumentation mit einer Anleitungen zur Verwendung der Kiste.
> Eine weitere nette Funktionalität von Cargo ist, dass das Ausführen des
> Kommandos `cargo doc --open` die von all deinen Abhängigkeiten
> bereitgestellte Dokumentation lokal zusammenstellt und in deinem Browser
> öffnet. Wenn du an anderen Funktionen der Kiste `rand` interessiert bist,
> führe zum Beispiel `cargo doc --open` aus und klicke auf `rand` in der
> Seitenleiste links.

Die zweite neue Zeile gibt die Geheimzahl aus. Das ist hilfreich während wir
das Programm entwickeln, um es testen zu können, aber wir werden es aus der
finalen Version entfernen. Es ist kein echtes Spiel, wenn das Programm die
Antwort ausgibt, sobald es startet!

Versuche, das Programm einige Male auszuführen:

```console
$ cargo run
   Compiling guessing_game v0.1.0 (file:///projects/guessing_game)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 2.53s
     Running `target/debug/guessing_game`
Rate die Zahl!
Die Geheimzahl ist: 7
Bitte gib deine Schätzung ein.
4
Du hast geschätzt: 4

$ cargo run
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.02s
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
#     let secret_number = rand::thread_rng().gen_range(1..=100);
#
#     println!("Die Geheimzahl ist: {secret_number}");
#
#     println!("Bitte gib deine Schätzung ein.");
#
#     let mut guess = String::new();
#
#     io::stdin()
#         .read_line(&mut guess)
#         .expect("Fehler beim Lesen der Zeile");

    println!("Du hast geschätzt: {guess}");

    match guess.cmp(&secret_number) {
        Ordering::Less => println!("Zu klein!"),
        Ordering::Greater => println!("Zu groß!"),
        Ordering::Equal => println!("Du hast gewonnen!"),
    }
}
```

<span class="caption">Codeblock 2-4: Behandeln der möglichen Rückgabewerte beim
Vergleich zweier Zahlen</span>

Zuerst fügen wir eine weitere `use`-Anweisung hinzu, die einen Typ namens
`std::cmp::Ordering` aus der Standardbibliothek in den Gültigkeitsbereich
bringt. Der Typ `Ordering` ist eine weitere Aufzählung und hat die Varianten
`Less`, `Greater` und `Equal`. Dies sind die drei Ergebnisse, die möglich sind,
wenn man zwei Werte vergleicht.

Dann fügen wir unten fünf neue Zeilen hinzu, die den Typ `Ordering` verwenden.
Die Methode `cmp` vergleicht zwei Werte und kann auf alles, was verglichen
werden kann, angewendet werden. Sie braucht eine Referenz auf das, was du
vergleichen willst: Hier wird `guess` mit `secret_number` verglichen. Dann gibt
sie eine Variante der `Ordering`-Aufzählung zurück, die wir mit der
`use`-Anweisung in den Gültigkeitsbereich gebracht haben. Wir verwenden einen
[`match`][match]-Ausdruck, um zu entscheiden, was als nächstes zu tun ist,
basierend darauf, welche `Ordering`-Variante vom Aufruf von `cmp` mit den
Werten in `guess` und `secret_number` zurückgegeben wurde.

Ein `match`-Ausdruck besteht aus _Zweigen_ (arms). Ein Zweig besteht aus einem
_Muster_ (pattern) und dem Code, der ausgeführt werden soll, wenn der Wert, der
am Anfang des `match`-Ausdrucks steht, zum Muster dieses Zweigs passt. Rust
nimmt den Wert, der bei `match` angegeben wurde, und schaut nacheinander durch
das Muster jedes Zweigs. Das `match`-Konstrukt und die Muster sind mächtige
Funktionalitäten in Rust, mit denen du eine Vielzahl von Situationen ausdrücken
kannst, auf die dein Code stoßen könnte, und die sicherstellen, dass du sie
alle behandelst. Diese Funktionalitäten werden ausführlich in Kapitel 6 bzw.
Kapitel 18 behandelt.

Gehen wir ein Beispiel dafür durch, was mit dem hier verwendeten
`match`-Ausdruck geschehen würde. Angenommen, der Benutzer hat 50 geschätzt und
die zufällig generierte Geheimzahl ist diesmal 38.

Wenn der Code 50 mit 38 vergleicht, gibt die Methode `cmp` `Ordering::Greater`
zurück, weil 50 größer als 38 ist. Der `match`-Ausdruck erhält den Wert
`Ordering::Greater` und beginnt mit der Überprüfung des Musters jedes Zweigs.
Er schaut auf das Muster `Ordering::Less` des ersten Zweigs und sieht, dass der
Wert `Ordering::Greater` nicht mit `Ordering::Less` übereinstimmt, also
ignoriert er den Code in diesem Zweig und geht zum nächsten Zweig über. Das
Muster `Ordering::Greater` des nächsten Zweigs _passt_ zu `Ordering::Greater`!
Der dazugehörige Code in diesem Zweig wird ausgeführt und `Zu groß!` auf den
Bildschirm ausgegeben. Der `match`-Ausdruck endet nach der ersten erfolgreichen
Übereinstimmung, sodass der letzte Zweig in diesem Szenario nicht
berücksichtigt wird.

Der Code in Codeblock 2-4 lässt sich jedoch noch nicht kompilieren. Lass es uns
versuchen:

```console
$ cargo build
   Compiling libc v0.2.86
   Compiling getrandom v0.2.2
   Compiling cfg-if v1.0.0
   Compiling ppv-lite86 v0.2.10
   Compiling rand_core v0.6.2
   Compiling rand_chacha v0.3.0
   Compiling rand v0.8.5
   Compiling guessing_game v0.1.0 (file:///projects/guessing_game)
error[E0308]: mismatched types
  --> src/main.rs:22:21
   |
22 |     match guess.cmp(&secret_number) {
   |                 --- ^^^^^^^^^^^^^^ expected `&String`, found `&{integer}`
   |                 |
   |                 arguments to this method are incorrect
   |
   = note: expected reference `&String`
              found reference `&{integer}`
note: method defined here
  --> /rustc/07dca489ac2d933c78d3c5158e3f43beefeb02ce/library/core/src/cmp.rs:814:8

For more information about this error, try `rustc --explain E0308`.
error: could not compile `guessing_game` (bin "guessing_game") due to 1 previous error
```

Die Kernbotschaft des Fehlers besagt, dass es _nicht übereinstimmende Typen_ 
(mismatched types) gibt. Rust hat ein starkes, statisches Typsystem. Es hat jedoch 
auch eine Typ-Inferenz. Als wir `let mut guess = String::new()` schrieben, konnte
Rust daraus schließen, dass `guess` ein `String` sein sollte, und zwang uns
nicht, den Typ anzugeben. Die `secret_number` hingegen ist ein Zahlentyp.
Einige Zahlentypen können einen Wert zwischen 1 und 100 haben: `i32`, eine
32-Bit-Zahl; `u32`, eine 32-Bit-Zahl ohne Vorzeichen; `i64`, eine 64-Bit-Zahl;
sowie andere. Solange nicht anders angegeben, verwendet Rust standardmäßig
`i32`, was der Typ von `secret_number` ist, es sei denn, du fügst an anderer
Stelle Typinformationen hinzu, die Rust veranlassen würden, auf einen anderen
numerischen Typ zu schließen. Der Grund für den Fehler liegt darin, dass Rust
eine Zeichenkette und einen Zahlentyp nicht vergleichen kann.

Letztendlich wollen wir den `String`, den das Programm als Eingabe liest, in
einen Zahlentyp umwandeln, damit wir ihn numerisch mit der Geheimzahl
vergleichen können. Das tun wir, indem wir folgendes zum `main`-Funktionsrumpf
hinzufügen:

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore
# use rand::Rng;
# use std::cmp::Ordering;
# use std::io;
#
# fn main() {
#     println!("Rate die Zahl!");
#
#     let secret_number = rand::thread_rng().gen_range(1..=100);
#
#     println!("Die Geheimzahl ist: {secret_number}");
#
#     println!("Bitte gib deine Schätzung ein.");
#
    // --abschneiden--

    let mut guess = String::new();

    io::stdin()
        .read_line(&mut guess)
        .expect("Fehler beim Lesen der Zeile");

    let guess: u32 = guess.trim().parse().expect("Bitte gib eine Zahl ein!");

    println!("Du hast geschätzt: {guess}");

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
vorherigen Wert von `guess` mit einem neuen Wert zu verschatten (shadow). Durch
das _Verschatten_ können wir den Variablennamen `guess` wiederverwenden, anstatt
uns zu zwingen, zwei eindeutige Variablen zu erstellen, z.B. `guess_str` und
`guess`. Wir werden dies in [Kapitel 3][shadowing] ausführlicher behandeln,
aber für den Moment solltst du wissen, dass diese Funktionalität oft verwendet
wird, wenn du einen Wert von einem Typ in einen anderen Typ konvertieren
willst.

Wir binden `guess` an den Ausdruck `guess.trim().parse()`. Das `guess` im
Ausdruck bezieht sich auf das ursprüngliche `guess`, das ein `String` mit der
Eingabe darin war. Die Methode `trim` der `String`-Instanz wird alle
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
(carriage return) und einen Zeilenumbruch (newline): `\r\n`) Die Methode `trim`
entfernt `\n` und `\r\n`, was nur `5` ergibt.

Die [Methode `parse` für Zeichenketten][parse] konvertiert eine Zeichenkette in
einen anderen Typ. Hier verwenden wir sie, um eine Zeichenkette in eine Zahl
umzuwandeln. Wir müssen Rust den genauen Zahlentyp mitteilen, den wir wollen,
indem wir `let guess: u32` verwenden. Der Doppelpunkt (`:`) nach `guess` sagt
Rust, dass wir den Typ der Variablen annotieren werden. Rust hat ein paar
eingebaute Zahlentypen; `u32`, das du hier siehst, ist eine vorzeichenlose
32-Bit-Ganzzahl. Es ist eine gute Standardwahl für eine kleine positive Zahl.
Über andere Zahlentypen erfährst du in [Kapitel 3][integers].

Zusätzlich bedeuten die Annotation `u32` in diesem Beispielprogramm und der
Vergleich mit `secret_number`, dass Rust daraus ableiten wird, dass
`secret_number` ebenfalls ein `u32` sein sollte. Nun wird also der Vergleich
zwischen zwei Werten desselben Typs durchgeführt!

Die Methode `parse` funktioniert nur bei Zeichen, die logisch in Zahlen
umgewandelt werden können und kann daher leicht Fehler verursachen. Wenn die
Zeichenkette zum Beispiel `A👍%` enthielte, gäbe es keine Möglichkeit, dies in
eine Zahl umzuwandeln. Da dies fehlschlagen könnte, gibt die Methode `parse`
einen `Result`-Typ zurück, ähnlich wie die Methode `read_line` (weiter oben in
[„Behandeln potentieller Fehler mit
`Result`“](#behandeln-potentieller-fehler-mit-result)). Wir werden dieses
`Result` auf die gleiche Weise behandeln, indem wir erneut `expect` verwenden.
Wenn `parse` eine `Err`-Variante von `Result` zurückgibt, weil es keine Zahl
aus der Zeichenkette erzeugen konnte, wird der `expect`-Aufruf das Spiel zum
Absturz bringen und die Nachricht ausgeben, die wir ihm geben. Wenn `parse` die
Zeichenkette erfolgreich in eine Zahl umwandeln kann, gibt es die `Ok`-Variante
von `Result` zurück, und `expect` gibt die Zahl zurück, die wir vom `Ok`-Wert
erwarten.

Lassen wir das Programm jetzt laufen:

```console
$ cargo run
   Compiling guessing_game v0.1.0 (file:///projects/guessing_game)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.43s
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

Der Großteil des Spiels funktioniert jetzt, aber der Benutzer kann nur _eine_
Schätzung anstellen. Ändern wir das, indem wir eine Schleife hinzufügen!

## Zulassen mehrerer Schätzungen mittels Schleife

Das Schlüsselwort `loop` erzeugt eine Endlosschleife. Wir fügen jetzt eine
Schleife hinzu, um den Benutzern mehr Chancen zu geben, die Zahl zu erraten:

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore
# use rand::Rng;
# use std::cmp::Ordering;
# use std::io;
#
# fn main() {
#     println!("Rate die Zahl!");
#
#     let secret_number = rand::thread_rng().gen_range(1..=100);
#
    // --abschneiden--

    println!("Die Geheimzahl ist: {secret_number}");

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
#         println!("Du hast geschätzt: {guess}");
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

Der Benutzer könnte das Programm jederzeit mit dem Tastaturkürzel
<kbd>Strg</kbd>+<kbd>c</kbd> unterbrechen. Aber es gibt noch eine andere
Möglichkeit, diesem unersättlichen Monster zu entkommen, wie in der
`parse`-Diskussion in [„Vergleichen der Schätzung mit der
Geheimzahl“](#vergleichen-der-schätzung-mit-der-geheimzahl) erwähnt: Wenn der
Benutzer eine Antwort ohne Zahl eingibt, stürzt das Programm ab. Wir können das
ausnutzen, um dem Benutzer zu erlauben das Programm zu beenden, wie hier
gezeigt:

```console
$ cargo run
   Compiling guessing_game v0.1.0 (file:///projects/guessing_game)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 1.50s
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

thread 'main' panicked at src/main.rs:28:47:
Please type a number!: ParseIntError { kind: InvalidDigit }
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
```

Mit der Eingabe von `quit` wird das Spiel beendet, aber das gilt
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
#     let secret_number = rand::thread_rng().gen_range(1..=100);
#
#     println!("Die Geheimzahl ist: {secret_number}");
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
#         println!("Du hast geschätzt: {guess}");
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
#     let secret_number = rand::thread_rng().gen_range(1..=100);
#
#     println!("Die Geheimzahl ist: {secret_number}");
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

        println!("Du hast geschätzt: {guess}");

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
einen `match`-Ausdruck, wie wir es mit dem `Ordering`-Ergebnis der Methode
`cmp` getan haben.

Wenn `parse` in der Lage ist, die Zeichenkette erfolgreich in eine Zahl
umzuwandeln, gibt es einen `Ok`-Wert zurück, der die resultierende Zahl
enthält. Dieser `Ok`-Wert wird mit dem Muster des ersten Zweigs übereinstimmen
und der `match`-Ausdruck wird nur den `num`-Wert zurückgeben, der durch `parse`
erzeugt und in den `Ok`-Wert eingefügt wurde. Diese Zahl wird in der neuen
`guess`-Variable, die wir erzeugen, genau dort landen, wo wir sie haben wollen.

Wenn `parse` _nicht_ in der Lage ist, die Zeichenkette in eine Zahl
umzuwandeln, gibt es einen `Err`-Wert zurück, der mehr Informationen über den
Fehler enthält. Der `Err`-Wert stimmt nicht mit dem `Ok(num)`-Muster im ersten
`match`-Zweig überein, aber er stimmt mit dem `Err(_)`-Muster im zweiten Zweig
überein. Der Unterstrich `_` ist ein Auffangwert; in diesem Beispiel sagen
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

    let secret_number = rand::thread_rng().gen_range(1..=100);

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

        println!("Du hast geschätzt: {guess}");

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

An diesem Punkt hast du das Ratespiel erfolgreich aufgebaut. Herzlichen
Glückwunsch!

## Zusammenfassung

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
[doccargo]: https://doc.rust-lang.org/cargo/
[doccratesio]: https://doc.rust-lang.org/cargo/reference/publishing.html
[enums]: ch06-00-enums.html
[expect]: https://doc.rust-lang.org/std/result/enum.Result.html#method.expect
[integers]: ch03-02-data-types.html#ganzzahl-typen
[iostdin]: https://doc.rust-lang.org/std/io/struct.Stdin.html
[match]: ch06-02-match.html
[parse]: https://doc.rust-lang.org/std/primitive.str.html#method.parse
[prelude]: https://doc.rust-lang.org/std/prelude/index.html
[randcrate]: https://crates.io/crates/rand
[read_line]: https://doc.rust-lang.org/std/io/struct.Stdin.html#method.read_line
[recover]: ch09-02-recoverable-errors-with-result.html
[result]: https://doc.rust-lang.org/std/result/enum.Result.html
[semver]: https://semver.org/lang/de/
[shadowing]: ch03-01-variables-and-mutability.html#verschatten-shadowing
[string]: https://doc.rust-lang.org/std/string/struct.String.html
[variables-and-mutability]: ch03-01-variables-and-mutability.html
