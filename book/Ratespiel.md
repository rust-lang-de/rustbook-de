# Ratespiel

Für unser erstes Projekt wollen wir eine
klassische Anfängeraufgabe implementieren: das Ratespiel.
So funktioniert es: Unser Programm wird eine zufällige
ganze Zahl zwischen eins und hundert erzeugen.
Es wird uns dann fragen sie zu erraten.
Bei einem Rateversuch wird es uns sagen, ob wir zu niedrig oder zu hoch liegen.
Sobald wir richtig raten, wird es uns gratulieren. Klingt das gut?

# Anlegen

Lass uns ein neues Projekt anlegen. Gehe in dein Projekteverzeichnis.
Erinnerst du dich wie wir die Verzeichnisstruktur und eine `Cargo.toml` für
`hallo_welt` anlegen mussten? Cargo hat ein Befehl dafür, welcher das für uns
erledigt. Lass uns den ausprobieren:

```bash
$ cd ~/projekte
$ cargo new ratespiel --bin
$ cd ratespiel
```

Wir übergeben den Namen unseres Projektes und – da wir eine Binärdatei
anstatt eine Bibliothek erstellen – `--bin` an `cargo new`.

Schau dir mal die erzeugte `Cargo.toml` an:

```toml
[package]

name = "ratespiel"
version = "0.1.0"
authors = ["Dein Name <du@example.com>"]
```

Cargo holt diese Informationen aus deiner Betriebssystemumgebung. Wenn diese
nicht korrekt sind, dann korrigiere sie ruhig.

Schließlich generiert Cargo noch ein `Hallo Welt` für uns.
Schau dir die `src/main.rs` an:

```rust
fn main() {
    println!("Hello, world!");
}
```

Lass uns versuchen das, was uns Cargo gegeben hat, zu kompilieren:

```{bash}
$ cargo build
   Compiling ratespiel v0.1.0 (file:///home/du/projekte/ratespiel)
```

Ausgezeichnet! Öffne nochmal deine `src/main.rs`. Wir werden unseren ganzen
Code in diese Datei schreiben.

Lass mich dir noch einen weiteren Cargo Befehl zeigen: `run`. `cargo run`
ist fast  wie `cargo build`, aber führt zusätzlich noch die erzeugte ausführbare
Datei aus.

```bash
$ cargo run
   Compiling ratespiel v0.1.0 (file:///home/du/projekte/ratespiel)
     Running `target/debug/ratespiel`
Hello, world!
```

Prima! Der `run` Befehl ist sehr praktisch, wenn man sein Projekt häufig
widerholt ausprobieren möchte. Unser Spiel ist ein solches Projekt und wir
müssen jeden Schritt zügig testen können bevor wir mit dem Nächsten fortfahren.

# Einen Rateversuch verarbeiten

Also lass uns anfangen! Das erste, was für unser Ratespiel tun müssen, ist dem
unserem Spieler zu erlauben eine Vermutung einzugeben. Schreib das hier
in deine `src/main.rs`:

```rust
use std::io;

fn main() {
    println!("Rate die Zahl!");

    println!("Bitte gib deine Vermutung ein.");

    let mut vermutung = String::new();

    io::stdin().read_line(&mut vermutung)
        .ok()
        .expect("Fehler beim Lesen der Zeile");

    println!("Deine Vermutung: {}", vermutung);
}
```

Das ist 'ne Menge! Lass es uns Stück für Stück durchgehen.

```rust
use std::io;
```

Wir werden Benutzereingaben entgegennehmen und dann das Ergebnis ausgeben
können. Dazu werden wir das `io` Modul aus der Standardbibliothek. Rust
importiert standardmäßig ein paar Dinge in jedes Programm,
das [das ‘Prelude’][prelude]. Wenn etwas nicht im Prelude ist, dann musst
du es mittels `use` importieren.

[prelude]: https://doc.rust-lang.org/std/prelude/index.html

```rust
fn main() {
```

Wie du zuvor schon gesehen hast, ist die `main()` Funktion der Startpunkt
in deinem Programm. Die `fn` Syntax deklariert eine neue Funktion, die `()`
zeigen an, dass es keine Argumente gibt und `{` beginnt den
Körper der Funktion. Weil wir keinen Rückgabewert angegeben haben, wird
automatisch angenommn, dass dieser `()`, ein leeres [Tupel][tuples] ist.

[tuples]: book/Primitive_Typen.md#Tupel

```rust
    println!("Rate die Zahl!");

    println!("Bitte gib deine Vermutung ein.");
```

Wir haben zuvor gelernt, dass `println!()` ein [Makro][macros] ist, dass
einen [String][strings] auf dem Bildschirm ausgibt.

[macros]: book/Makros.md
[strings]: book/Strings.md

```rust
    let mut vermutung = String::new();
```

Nun wird es interessant! In dieser kleinen Zeile ist eine Menge los.
Das erste, was man bemerken sollte, ist eine [let Anweisung][let],
welche verwendet wird um ‘Variablenbindungen’ zu erzeugen.
Sie nehmen diese Form an:

```rust
let foo = bar;
```

[let]: book/Variablenbindung.md

Dies wird eine neue Bindung namens `foo` erzeugen
und den Wert `bar` daran binden. In vielen Sprachen wird das eine ‘Variable’
genannt, aber Rusts Variablenbindungen haben ein paar Tricks in ihren Ärmeln.

Zum Beispiel sind sie standardmäßig *immutable* [unveränderbar]. Deswegen
benutzt unser Beispiel `mut`: Es macht eine Bindung *mutable* [veränderbar]
anstatt *immutable*. Auf der linken Seite der Zuweisung akzeptiert `let`
nicht einfach nur einen Namen, es akzeptiert sogar ‘[Muster][patterns]’.
Wir werden Muster später noch verwenden. Es ist fürs erste leicht genug
zu benutzen:

```rust
let foo = 5; // immutable (unveränderbar)
let mut bar = 5; // mutable (veränderbar)
```

[immutable]: book/Veränderbarkeit.md
[patterns]: book/Muster.md

Oh, und `//` leitet einen Kommentar bis zum Ende der Zeile ein.
Rust ignoriert alles in [Kommentaren][comments].

[comments]: Kommentare.md

So, nun wissen wissen wir, dass `let mut vermutung` eine neue Variablenbindung
namens `vermutung` einführt, aber wir müssen noch auf die andere Seite des `=`
schauen woran sie gebunden ist: `String::new()`.

`String` ist ein String typ, welcher von der Standardbibliothek zur Verfügung
gestellt wird. Ein [`String`][string] ist ein UTF-8 kodierter Text,
der wachsen kann.

[string]: https://doc.rust-lang.org/std/string/struct.String.html

Die `::new()` Syntax benutzt `::` weil es eine ‘assoziierte Funktion’ eines
bestimmten Typs ist. Sprich, es ist mit `String` selbst assoziiert,
anstatt mit einer Instanz von `String`. Manche Sprachen nennen das eine
‘statische Methode’.

Diese Funktion heißt `new()`, da sie einen neuen, leeren `String`.
Du wirst bei vielen Typen eine `new()` Funktion finden, da es ein typischer
Name ist um irgendeine Art von neuen Wert zu erzeugen.

Lass uns weiter machen:

```rust
    io::stdin().read_line(&mut vermutung)
        .ok()
        .expect("Fehler beim Lesen der Zeile");
```

Das ist eine Menge mehr! Lass uns das wieder Schritt für Schritt durchgehen.
Die erste Zeile besteht aus zwei Teilen. Hier ist der erste:

```rust
io::stdin()
```

Erinnerst du dich wie wir `use` in der ersten Zeile des Programmes benutzt
haben um `std::io` zu importieren? Wir rufen nun eine Assozierte Funktion davon
auf. Wenn wir `use std::io` nicht verwendet hätten, dann hätten wir diese
Zeile als als `std::io::stdin()` schreiben können.

Diese spezielle Funktion gibt uns ein Handle für die Standardeingabe deines
Terminals. Genauer gesagt ein [std::io::Stdin][iostdin].

[iostdin]: https://doc.rust-lang.org/std/io/struct.Stdin.html

Der nächste Teil wird dieses Handle verwenden um an die Eingaben des Benutzers
zu gelangen:

```rust
.read_line(&mut vermutung)
```

Here rufen wir die [`read_line()`][read_line] Methode unseres Handle auf.
[Methoden][method] sind wie assoziierte Funktionen, aber sind nur für eine
jeweilige Instanz eines Types verfügbar, anstatt für den Typ selbst. Wir
übergeben außerdem ein Argument an `read_line()`: `&mut vermutung`.

[read_line]: https://doc.rust-lang.org/std/io/struct.Stdin.html#method.read_line
[method]: book/Methodensyntax.md

Erinnerst du dich wir oben `vermutung` gebunden haben? Wir hatten gesagt, dass
es *mutable* ist. Jedoch nimmt `read_line` keinen `String` als Argument: Es
nimmt einen `&mut String`. Rust hat ein Feature namens
‘[Referenzen][references]’, welches einem erlaubt mehrere Referenzen auf ein
Stück Daten zu haben, was kopieren reduzieren kann. Referenzen sind ein
komplexes Feature, da eines von Rusts haupt Verkaufsargumenten ist wie sicher
und einfach es ist Referenzen zu benutzen. Wir müssen jedoch nicht viele dieser
Details wissen um unser Programm im Moment zu vollenden.
Fürs Erste ist alles was wir kennen müssen, dass, ähnlich wie `let`
Bindungen, Referenzen standardmäßig *immutable* sind. Daher müssen wir
`&mut vermutung` schreiben anstatt `&vermutung`.

Warum nimmt `read_line()` eine *mutable* Referenz eines String? Der Job dieser
Funktion ist es die Eingaben des Benutzers auf der Standardeingabe zu nehmen
und in einem String zu platzieren. Also nimmt sie einen String als
Argument, und um die Eingabe hinzuzufügen muss dieser *mutable* sein.

[references]: book/Referenzen_Und_Ausleihen.md

Aber wir sind noch nicht ganz fertig mit dieser Zeile Code.
Während es sich um eine einzelne Textzeile handelt, ist es nur der erste
Teil einer einzelnen logischen Zeile an Code:

```rust
        .ok()
        .expect("Fehler beim Lesen der Zeile");
```

Wenn man eine Methode mit der `.foo()` Syntax aufruft, dann darf man eine
neue Zeile oder andere Leerzeichen einführen.
Dies hilft einem lange Zeilen aufzuteilen. Wir _hätten_ auch das tun können:

```rust
    io::stdin().read_line(&mut vermutung).ok().expect("Fehler beim Lesen der Zeile");
```

Aber das ist schwerer zu lesen.Also haben wir es aufgeteilt in drei Zeilen für
drei Methodenaufrufe. Wir haben bereits über `read_line()` geredet,
aber was ist mit `ok()` und `expect()`? Nun, wir haben bereits erwähnt,
dass `read_line()` das, was der Benutzer eingibt, in den `&mut String` steckt,
den wir ihr übergeben. Aber sie gibt auch einen Wert zurück:
In diesem Fall ein [`io::Result`][ioresult]. Rust hat eine Reihe von Typen
namens `Result` in seiner Standardbibliothek:
Einen allgemeines [`Result`][result] und spezifische Versionen für
unter-bibliotheken, wie z.B. `io::Result`.

[ioresult]: https://doc.rust-lang.org/std/io/type.Result.html
[result]: https://doc.rust-lang.org/std/result/enum.Result.html

Der Zweck dieser `Result` Typen ist Informationen zur Fehlerbehandung bereit
zu stellen. Werte des `Result` Typ besitzen, wie jeder Typ, Methoden.
In diesem Fall hat `io::Result` eine `ok()` Methode, welche sagt
"wir möchten annehmen, dass dieser Wert ein erfolgreicher ist". Falls nicht,
schmeißen wir einfach die Fehlerinformation weg. Warum sie wegwerfen? Nun,
für ein einfaches Programm wollen wir einfach einen allgemeinen Fehler
ausgeben, da im Grunde jeder Fehler bedeutet, dass wir nicht
fortfahren können. Die [`ok()` Methode][ok] gibt einen Wert zurück, welcher
eine weitere Methode besitzt: `expect()`. Die [`expect()` Methode][expect]
nimmt einen Wert auf dem sie aufgerufen wird und, falls dieser kein
erfolgreicher ist, wird eine [`panic`][panic] mit der Nachricht, die man
Übergeben hat, erzeugt. Eine `panic` wie diese sorgt dafür, dass unser Programm
abstürzt und die Nachricht anzeigt.

[ok]: https://doc.rust-lang.org/std/result/enum.Result.html#method.ok
[expect]: https://doc.rust-lang.org/std/option/enum.Option.html#method.expect
[panic]: book/Fehlerbehandlung.md

Falls wir diese beiden Methodenaufrufe weglassen wird unser Programm zwar
kompilieren, aber wir werden eine Warnung bekommen:

```bash
$ cargo build
   Compiling ratespiel v0.1.0 (file:///home/du/projekte/ratespiel)
src/main.rs:10:5: 10:39 warning: unused result which must be used,
#[warn(unused_must_use)] on by default
src/main.rs:10     io::stdin().read_line(&mut vermutung);
                   ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
```

Rust warnt uns, dass wir den `Result` Wert nicht verwendet haben.
Diese Warnung stammt von einer speziellen Anmerkung, die `io::Result` hat.
Rust versucht dir zu sagen, dass du einen möglichen Fehler nicht behandelt
hast. Der richtige Weg um den Fehler zu unterdrücken ist eigentlich
Fehlerbehandlung zu schreiben. Glücklicherweise können wir diese zwei kleinen
Methoden verwenden, falls uns ein Crash in Ordnung ist, wenn es einen Fehler
gibt. Falls wir uns von dem Fehler irgendwie erholen können, dann würden
wir etwas anderes machen, aber das bewahren wir uns für ein zukünftiges
Projekt auf.

Es gibt nurnoch eine übrige Zeile dieses ersten Beispiels:

```rust
    println!("Deine Vermutung: {}", vermutung);
```

Dies gibt den, in dem wir unsere Eingabe gespeichert haben, aus.
Die `{}` sind Platzhalter, und somit übergeben wir `vermutung` daran.
Hätten wir mehrere `{}`, dann würde wir mehrere Argumente übergeben:

```rust
let x = 5;
let y = 10;

println!("x und y: {} und {}", x, y);
```

Einfach.

Jedenfalls war das die Tour.  Mit `cargo run` können wir ausführen,
was wir bereits haben:

```bash
$ cargo run
   Compiling ratespiel v0.1.0 (file:///home/du/projekte/ratespiel)
     Running `target/debug/ratespiel`
Rate die Zahl!
Bitte gib deine Vermutung ein.
6
Deine Vermutung:  6
```

Also gut! Unser erster Teil ist fertig: Wir können Eingaben von der Tastatur
holen und sie wieder ausgeben.

# Eine geheime Zahl erzeugen

Als nächstes müssen wir eine zufällige Zahl erzeugen. Rust hat noch keine
Möglichkeit um Zufallszahlen zu erzeugen in seiner Standardbibliothek.
Das Rust Team hat jedoch eine [`rand` Crate][randcrate] zur Verfügung gestellt.
Eine ‘Crate’ [engl.: Kiste] ist ein Paket aus Rust Code.
Wir haben bereits eine ‘binary crate’ gebaut,
was eine ausführbare Datei ist.
`rand` ist eine ‘library crate’, welche den Code enthält,
der dazu Gedacht ist von anderen Programmen als Bibliothek verwendet zu
werden.

[randcrate]: https://crates.io/crates/rand

Cargo ist wirklich gut darin externe Crates zu verwenden. Bevor wir Code
schreiben können der `rand` verwendet, müssen wir unsere `Cargo.toml`
anpassen. Öffne sie und füge diese paar Zeilen am Ende an:

```toml
[dependencies]

rand="0.3.0"
```

Der `[dependencies]` Abschnitt der `Cargo.toml` ist wie der `[package]`
Abschnitt: Alles was diesem folgt gehört dazu, bis ein nächster Abschnitt
beginnt. Cargo benutzt den *dependencies* Abschnitt um zu wissen, welche
Abhängigkeiten an externen Crates du hast und welche Version du benötigst.
In diesem Fall haben wir Version `0.3.0` spezifiziert, was Cargo als ein
Release versteht, der mit dieser spezifischen Version kompatibel ist.
Cargo versteht [Semantische Versionierung][semver], was ein Standard ist
um Versionsnummern zu schreiben. Falls wir nur exakt `0.3.0` verwenden wollten,
dann könnten wir `=0.3.0` schreiben. Falls wir die neueste Version verwenden
wollten, dann könnten wir `*` verwenden; wir könnten eine Bereich von
Versionen verwenden. [Cargos Dokumentation][cargodoc] enthält mehr Details.

[semver]: http://semver.org
[cargodoc]: http://doc.crates.io/crates-io.html

Nun lass uns, ohne unseren Code zu ändern, das Projekt neu kompilieren:

```bash
$ cargo build
    Updating registry `https://github.com/rust-lang/crates.io-index`
 Downloading rand v0.3.8
 Downloading libc v0.1.6
   Compiling libc v0.1.6
   Compiling rand v0.3.8
   Compiling ratespiel v0.1.0 (file:///home/du/projekte/ratespiel)
```

(Du könntest natürlich andere Versionen sehen.)

Das ist eine Menge an neuer Ausgabe! Nun da wir eine externe Abhängigkeit
haben holt Cargo die aktuellste Version von allem aus der Registry, was
eine Kopie der Daten auf [Crates.io][cratesio] ist. Crates.io ist der Ort,
wo Leute im Rust Ökosystem ihre Open-Source Projekte veröffentlichen
um sie für andere zur Verfügung zu stellen.

[cratesio]: https://crates.io

Nach dem aktualisieren der Registry prüft Cargo unsere `[dependencies]` und
lädt alle, die wir noch nicht haben, herunter. In diesem Fall laden wir uns
auch eine Kopie der `libc` Crate, obwohl wir gesagt haben, dass wir nur von
der `rand` Crate abhängen wollen. Das ist so weil `rand` von `libc` abhängt
um zu funktionieren. Nach dem herunterladen kompiliert Cargo diese und danach
unser Projekt.

Falls wir `cargo build` nochmal ausführen,
dann werden wir eine andere Ausgabe bekommen:

```bash
$ cargo build
```

Genau, keine Ausgabe! Cargo weis, dass unser Projekt schon kompiliert wurde
und, dass alle unsere Abhängigkeiten kompiliert sind, also gibt es keinen
Grund diesen ganzen Kram zu machen. Da es nichts zu tun gibt, beendet es sich
einfach. Falls wir die `src/main.rs` nochmal öffnen und eine trviale Änderung
vornehmen und speichern, dann werden wir nur eine Zeile sehen:

```bash
$ cargo build
   Compiling ratespiel v0.1.0 (file:///home/du/projekte/ratespiel)
```

So, wir haben Cargo gesagt, dass wir irgendeine `0.3.x` Version von `rand`
wollen, also hat es die aktuellste Version
(zur der Zeit als dies hier verfasst wurde) `v0.3.8` heruntergeladen.
Aber was passiert, wenn nächste Woche Version `v0.3.9` mit einem wichtigen
Bugfix herauskommt? Während Bugfixes zwar wichtig sind, was ist wenn `0.3.9`
Regressionen enthält, die das kompilieren mit unserem Code verhindern?

Die Antwort auf dieses Problem ist die `Cargo.lock` Datei, die du nun in
deinem Projektvrzeichniss finden wirst. Wenn du ein Projekt das erste mal
kompilierst, dann findet Cargo die ganzen Versionen heraus, die deinen
Kriterien entsprechen, und schreibt sie in die `Cargo.toml`. Wenn du dein
Projekt in der Zukunft kompilierst, dann sieht Cargo, dass die `Cargo.lock`
existiert und benutzt dann nur die darin spezifizierten Versionen, anstatt
nochmal alles erneut herauszufinden. Damit hat man automatisch
reproduzierbare Builds. In anderen Worten, du bleibst solange bei Version
`0.3.8` bis wir ausdrücklich upgraden, das gleiche gilt für jeden mit dem
wir unseren Code teilen, dank dieser Sperrdatei.

Was ist nun, wenn wir `v0.3.9` _doch_ nutzen wollen? Cargo hat einen anderen
Befehl, `update`, der besagt "ignoriere die Sperrdatei, finde die neusten
Versionen heraus die zu meiner Spezifikation passen. Falls das funktioniert,
schreibe diese Versionen in die Sperrdatei". Aber standardmäßig wird
Cargo nur nach Versionen größer als `0.3.0` und kleiner als `0.4.0` schauen.
Falls wir weiter zu `0.4.x` wollten, dann müssten wir das direkt in die
`Cargo.toml` eintragen. Wenn wir das täten, dann würde Cargo beim nächsten
`cargo build` den Index neu laden und unsere `rand` Anforderungen neu
auswerten. 

Es gibt noch eine Menge mehr über [Cargo][doccargo] und seinem
[Ökosystem][doccratesio] zu erzählen, aber für das erste ist das alles
was wir wissen müssen. Cargo macht es wirklich einfach Bibliotheken
wiederzuverwenden und deswegen neigen Rustler dazu kleinere Projekte zu
schreiben, welche aus einer Reihe von Unterpaketen zusammengebaut sind.

[doccargo]: http://doc.crates.io
[doccratesio]: http://doc.crates.io/crates-io.html

Lass uns beginnen die `rand` Crate tasächlich zu _benutzen_. Hier ist unser
nächster Schritte:

```rust
extern crate rand;

use std::io;
use rand::Rng;

fn main() {
    println!("Rate die Zahl!");

    let geheime_zahl = rand::thread_rng().gen_range(1, 101);

    println!("Die geheime Zahl ist: {}", geheime_zahl);

    println!("Bitte gib deine Vermutung ein.");

    let mut vermutung = String::new();

    io::stdin().read_line(&mut vermutung)
        .ok()
        .expect("Fehler beim Lesen der Zeile");

    println!("Deine Vermutung: {}", vermutung);
}
```

Das erste was wir gemacht haben ist die erste Zeile zu ändern. Dort steht nun
`extern crate rand`. Weil wir `rand` in unseren `[dependencies]` deklariert
deklariert haben, können wir `extern crate` benutzen um Rust wissen zu lassen,
dass wir sie benutzen. Dies ist außerdem das äquivalent zu einem `use rand;`,
sodass wir alles in der `rand` Crate erreichen können, indem wir es mit
`rand::` einleiten.

Als nächstes fügen wir noch eine weitere `use` Zeile hinzu: `use rand::Rng`.
Wir werden gleich eine Methode verwenden, welche erfordert, dass `Rng`
im Scope ist. Die grundlegende Idee ist folgende: Methoden können auf
sogenannten `Traits` definiert werden und, damit diese Methoden funktionieren,
müssen sie im aktuellen Scope sein. Für weitere Details lies den
[Traits][traits] Abschnitt.

[traits]: book/Traits.md

Es gibt zwei weitere Zeilen, die wir in der Mitte hinzugefügt haben:

```rust
    let geheime_zahl = rand::thread_rng().gen_range(1, 101);

    println!("Die geheime Zahl ist: {}", geheime_zahl);
```

Wir benutzen die `rand__thread_rng()` Funktion eine Kopie des
Zufallszahlengenerators zu erhalten, welcher dem aktuellen 
[Thread][concurrency] in dem wir sind, angehört.
Weil wir oben `use rand::Rng` verwendet haben, hat dieser Generator eine
`gen_range()` Methode zur Verfügung. Diese Methode nimmt zwei Argumente und
generiert eine Zahl, die zwischen diesen beiden liegt.
Der Bereich ist einschließlich dem unteren Ende und ausschließlich dem oberen
Ende, also brauchen wir `1` und `101` um eine Zahl zwischen eins bis hundert
zu erhalten.

[concurrency]: Nebenläufigkeit.md

Die zweite Zeile gibt einfach die geheime Zahl aus. Das ist nützlich während
wir unser Programm entwickeln, damit wir es leicht testen können.
Aber wir werden es aus der finalen Version entfernen. Es ist wohl kaum ein
Spiel, wenn es die Antwort schon beim Start ausgibt!

Versuche unser neues Programm ein paar mal auszuführen:

```bash
$ cargo run
   Compiling ratespiel v0.1.0 (file:///home/du/projekte/ratespiel)
     Running `target/debug/ratespiel`
Rate die Zahl!
Die geheime Zahl ist: 7
Bitte gib deine Vermutung ein.
4
Deine Vermutung: 4
$ cargo run
     Running `target/debug/ratespiel`
Rate die Zahl!
Die geheime Zahl ist: 83
Bitte gib deine Vermutung ein.
5
Deine Vermutung: 5
```

Super! Weiter: Lass uns die Vermutung mit der geheimen Zahl vergleichen.

# Vermutungen vergleichen

Nun da wir unsere Benutzereingabe haben, lass uns unsere Vermutung mit der
Zufallszahl vergleichen. Hier ist unser nächster Schritt, auch wenn er
**noch nicht wirklich kompiliert**:

```rust
extern crate rand;

use std::io;
use std::cmp::Ordering;
use rand::Rng;

fn main() {
    println!("Rate die Zahl!");

    let geheime_zahl = rand::thread_rng().gen_range(1, 101);

    println!("Die geheime Zahl ist: {}", geheime_zahl);

    println!("Bitte gib deine Vermutung ein.");

    let mut vermutung = String::new();

    io::stdin().read_line(&mut vermutung)
        .ok()
        .expect("Fehler beim Lesen der Zeile");

    println!("Deine Vermutung: {}", vermutung);

    match vermutung.cmp(&geheime_zahl) {
        Ordering::Less    => println!("Zu klein!"),
        Ordering::Greater => println!("Zu groß!"),
        Ordering::Equal   => println!("Gewonnen!"),
    }
}
```

Es gibt ein paar neue Sachen hier. Das erste ist ein weiteres `use`.
Wir importieren einen Typ namens `std::cmp::Ordering` in den aktuellen Scope.
Dann benutzen wir ihn ein paar Zeilen später:

```rust
    match vermutung.cmp(&geheime_zahl) {
        Ordering::Less    => println!("Zu klein!"),
        Ordering::Greater => println!("Zu groß!"),
        Ordering::Equal   => println!("Gewonnen!"),
    }
```

Die `cmp()` Methode kann auf allem aufgerufen werden,
was verglichen werden kann und nimmt eine Referenz auf die Sache, mit der wir
vergleichen es wollen. Es gibt den Typ `Ordering` zurück, den wir zuvor
mit `use` importiert haben. Wir benutzen eine [`Match`][match] Anweisung um
festzustellen welche `Ordering` genau vorliegt. `Ordering` ist ein
[`Enum`][enum], kurz für ‘enumeration’ [engl.: Aufzählung], was so aussieht:

```rust
enum Foo {
    Bar,
    Baz,
}
```

[match]: book/Match.md
[enum]: book/Enums.md

Mit dieser Definition ist der mögliche Wert des Typs `Foo`
entweder `Foo::Bar` oder `Foo::Baz`. Wir benutzen die `::` um den Namensraum
einer jeweiligen `enum` Variante anzuzeigen.

Das [`Ordering`][ordering] `enum` hat drei mögliche Varianten:
`Less`, `Equal` und `Greater`. Die `match` Anweisung nimmt den Wert eines Typen
und lässt dich einen ‘Zweig’ für jeden möglichen Wert erstellen. Da wir drei
Arten von `Ordering` haben, haben wir drei Zweige:

```rust
    match vermutung.cmp(&geheime_zahl) {
        Ordering::Less    => println!("Zu klein!"),
        Ordering::Greater => println!("Zu groß!"),
        Ordering::Equal   => println!("Gewonnen!"),
    }
```

[ordering]: https://doc.rust-lang.org/std/cmp/enum.Ordering.html

Falls der Wert `Less` ist, geben wir `Zu klein!` aus, falls er `Greater` ist,
`Zu groß!` und ist er `Equal`, dann `Gewonnen!`. `match` ist sehr nützlich und
wird häufig in Rust verwendet.

Ich hatte aber erwähnt, dass dieser Code so noch nicht ganz kompiliert.
Mal probieren:

```bash
$ cargo build
   Compiling ratespiel v0.1.0 (file:///home/du/projekte/ratespiel)
src/main.rs:28:25: 28:40 error: mismatched types:
 expected `&collections::string::String`,
    found `&_`
(expected struct `collections::string::String`,
    found integral variable) [E0308]
src/main.rs:28     match vermutung.cmp(&geheime_zahl) {
                                       ^~~~~~~~~~~~~
error: aborting due to previous error
Could not compile `ratespiel`.
```

Uff! Das ist ein großer Fehler. Sein Kern ist, dass wir `mismatched types`,
also nicht zusammenpassende Typen haben. Rust hat ein starkes, statisches
Typensystem. Es hat jedoch auch Typinferenz.
Als wir `let vermutung = String::new()` geschrieben haben war Rust in der Lage
abzuleiten, dass `vermutung` ein `String` sein sollte und somit mussten wir
nicht den Typ ausdrücklich aufschreiben. Und bei unserer `geheime_zahl` Variable
gibt es eine Reihe von Typen, die den Wert eins bis hundert annehmen können:
`i32`, eine 32-bit Ganzzahl, oder `u32`, eine vorzeichenlose 32-bit
Ganzzahl, oder `i64`, eine 64-bit Ganzzahl, oder andere.
Soweit war das nicht wichtig, weswegen Rust standardmäßig `i32` gewählt hat.
Jedoch weis Rust hier nicht wie es `vermutung` und die `geheime_zahl`
vergleichen soll. Sie müssen vom selben Typ sein. Letztlich wollen wir für
den Vergleich den `String`, den wir von der Eingabe lesen,
in eine richtigen Zahlentyp umwandeln. Wir können das mit drei weiteren Zeilen
erledigen. Hier ist unser neues Programm:

```rust
extern crate rand;

use std::io;
use std::cmp::Ordering;
use rand::Rng;

fn main() {
    println!("Rate die Zahl!");

    let geheime_zahl = rand::thread_rng().gen_range(1, 101);

    println!("Die geheime Zahl ist: {}", geheime_zahl);

    println!("Bitte gib deine Vermutung ein.");

    let mut vermutung = String::new();

    io::stdin().read_line(&mut vermutung)
        .ok()
        .expect("Fehler beim Lesen der Zeile");

    let vermutung: u32 = vermutung.trim().parse()
        .ok()
        .expect("Bitte eine Zahl eintippen!");

    println!("Deine Vermutung: {}", vermutung);

    match vermutung.cmp(&geheime_zahl) {
        Ordering::Less    => println!("Zu klein!"),
        Ordering::Greater => println!("Zu groß!"),
        Ordering::Equal   => println!("Gewonnen!"),
    }
}
```

Die drei neuen Zeilen sind:

```rust
    let vermutung: u32 = vermutung.trim().parse()
        .ok()
        .expect("Bitte eine Zahl eintippen!");
```

Augenblick mal, ich dachte wir hätten bereits eine `vermutung`? Ja, haben wir,
aber Rust erlaubt uns die vorherige `vermutung` mit einer neuen zu verdecken.
Dies wird häufig in genau dieser Situationen benutzt, wo `vermutung` als
`String` beginnt, wir es es aber in ein `u32` umwandeln möchten. Verdeckung von
Variablen lässt uns den Name `vermutung` wiederverwenden, anstatt wir gezwungen
sind uns einen neuen eindeutigen Namen wie `vermutung_str` und `vermutung`,
oder ähnlich, auszudenken.

Wir binden `vermutung` an einen Ausdruck, der so ähnlich wie ein vorheriger
aussieht:

```rust
vermutung.trim().parse()
```

Gefolgt von einem `ok().expect()` Aufruf. Hier verweist `vermutung` noch auf
die alte `vermutung`, jene, die ein String mit unserer Eingabe war. Die `trim()`
Methode auf `String`s eliminiert jegliche Form von Leerzeichen am Anfang und
am Ende unseres Strings. Das ist wichtig, da wir die Entertaste drücken mussten
um `read_line()` zufrieden zu stellen. Das bedeutet, dass, wenn wir `5`
eingeben und Enter drücken, `vermutung` so aussieht: `5\n`. Das `\n` stellt
eine neue Zeile dar (erzeugt durch die Entertaste). `trim()` entfernt das und
in unserem String bleibt nur die `5` übrig.
Die [`parse()` Methode auf Strings][parse] parst unseren String in einen
Zahlentyp. Da es verschiedene mögliche Zahlentypen gibt, müssen wir Rust einen
Hinweis geben welchen Zahlentyp wir denn genau haben wollen.
Deswegen `let vermutung: u32`.
Der Doppelpunkt (`:`) nach `vermutung` sagt Rust,
dass wir dessen Typ anmerken wollen.
`u32` ist eine vorzeichenlose 32-bit Ganzzahl.
Rust hat [eine Reihe eingebauter Zahlentypen][number],
aber wir haben `u32` gewählt.
Es ist eine gute Standardwahl für eine kleine positive Zahl.

[parse]: https://doc.rust-lang.org/std/primitive.str.html#method.parse
[number]: book/Primitive_Typen#numerische-typen

Genauso wie `read_line()`, kann unser Aufruf von `parse()` einen Fehler
verursachen. Was ist, wenn unser String `A❤%` enthielte? Es gibt keine
Möglichkeit das in eine Zahl umzuwandeln. Deswegen werden wir dasselbe
wie mit `read_line()` gemachen: Wir benutzen die `ok()` und `expect()`
Methoden um unser Programm bei einem Fehler zu crashen.

Lass uns unser Programm ausprobieren!

```bash
$ cargo run
   Compiling ratespiel v0.1.0 (file:///home/you/projects/ratespiel)
     Running `target/ratespiel`
Rate die Zahl!
Die geheime Zahl ist: 58
Bitte gib deine Vermutung ein.
  76
Deine Vermutung: 76
Zu groß!
```

Schön! Du kannst sehen, dass ich vor meiner Vermutung sogar ein paar
Leerzeichen eingetippt hat und das Programm immernoch wusste, dass Ich
76 geraten habe. Führe das Programm ein paar mal aus und stelle sicher,
dass sowohl das Raten der korrekten Zahl, als auch das Raten einer zu
kleinen Zahl funktioniert.

Nun funktioniert auch schon der größte Teil des Spiels,
aber wir haben nur einen Versuch. Lass uns das durch das Hinzufügen von
Schleifen ändern!

# Wiederholungen mit Schleifen

Das `loop` Schlüsselwort gibt uns eine Endlosschleife.
Lass uns das hinzufügen:

```rust
extern crate rand;

use std::io;
use std::cmp::Ordering;
use rand::Rng;

fn main() {
    println!("Rate die Zahl!");

    let geheime_zahl = rand::thread_rng().gen_range(1, 101);

    println!("Die geheime Zahl ist: {}", geheime_zahl);

    loop {
        println!("Bitte gib deine Vermutung ein.");

        let mut vermutung = String::new();

        io::stdin().read_line(&mut vermutung)
            .ok()
            .expect("Fehler beim Lesen der Zeile");

        let vermutung: u32 = vermutung.trim().parse()
            .ok()
            .expect("Bitte eine Zahl eintippen!");

        println!("Deine Vermutung: {}", vermutung);

        match vermutung.cmp(&geheime_zahl) {
            Ordering::Less    => println!("Zu klein!"),
            Ordering::Greater => println!("Zu groß!"),
            Ordering::Equal   => println!("Gewonnen!"),
        }
    }
}
```

Und probier es aus. Aber warte, haben wir nicht gerade eine
Endlosschleife hinzugefügt? Japp.
Erinnerst du dich an unsere Diskussion über `parse()`?
Wenn wir einen "nicht-Zahl" eingeben, dann brechen wir ab und beenden das
Programm. Beobachte:

```bash
$ cargo run
   Compiling ratespiel v0.1.0 (file:///home/du/projekte/ratespiel)
     Running `target/ratespiel`
Rate die Zahl!
Die geheime Zahl ist: 59
Bitte gib deine Vermutung ein.
45
Deine Vermutung: 45
Zu klein!
Bitte gib deine Vermutung ein.
60
Deine Vermutung: 60
Zu groß!
Bitte gib deine Vermutung ein.
59
Deine Vermutung: 59
Du gewinnst!
Bitte gib deine Vermutung ein.
ende
thread '<main>' panicked at 'Bitte eine Zahl eintippen!'
```

Ha! `ende` beended sogar das Programm. Genauso wie jede andere Eingabe, die
keine Zahl ist. Nun, das ist, milde ausgedrückt, eher suboptimal.
Zuerst lass uns tatsächlich beenden, wenn man das Spiel gewinnt:

```rust
extern crate rand;

use std::io;
use std::cmp::Ordering;
use rand::Rng;

fn main() {
    println!("Rate die Zahl!");

    let geheime_zahl = rand::thread_rng().gen_range(1, 101);

    println!("Die geheime Zahl ist: {}", geheime_zahl);

    loop {
        println!("Bitte gib deine Vermutung ein.");

        let mut vermutung = String::new();

        io::stdin().read_line(&mut vermutung)
            .ok()
            .expect("Fehler beim Lesen der Zeile");

        let vermutung: u32 = vermutung.trim().parse()
            .ok()
            .expect("Bitte eine Zahl eintippen!");

        println!("Deine Vermutung: {}", vermutung);

        match vermutung.cmp(&geheime_zahl) {
            Ordering::Less    => println!("Zu klein!"),
            Ordering::Greater => println!("Zu groß!"),
            Ordering::Equal   => {
                println!("Gewonnen!");
                break;
            }
        }
    }
}
```

Durch das Hinzufügen der `break` Zeile nach dem `Gewonnen!` verlassen
wir die Schleife, wenn wir gewinnen. Die Schleife zu verlassen bedeutet auch
das Programm zu beenden, da sie das letzte in unserer `main()` ist.
Wir haben noch eine weitere Anpassung zu machen: Wenn jemand eine "nicht-Zahl"
eingibt, dann wollen wir nicht beenden, sondern es einfach ignorieren.
Das können wir so machen:

```rust
extern crate rand;

use std::io;
use std::cmp::Ordering;
use rand::Rng;

fn main() {
    println!("Rate die Zahl!");

    let geheime_zahl = rand::thread_rng().gen_range(1, 101);

    println!("Die geheime Zahl ist: {}", geheime_zahl);

    loop {
        println!("Bitte gib deine Vermutung ein.");

        let mut vermutung = String::new();

        io::stdin().read_line(&mut vermutung)
            .ok()
            .expect("Fehler beim Lesen der Zeile");

        let vermutung: u32 = match vermutung.trim().parse() {
            Ok(zahl) => zahl,
            Err(_) => continue,
        };

        println!("Deine Vermutung: {}", vermutung);

        match vermutung.cmp(&geheime_zahl) {
            Ordering::Less    => println!("Zu klein!"),
            Ordering::Greater => println!("Zu groß!"),
            Ordering::Equal   => {
                println!("Gewonnen!");
                break;
            }
        }
    }
}
```

Diese Zeilen wurden geändert:

```rust
let vermutung: u32 = match vermutung.trim().parse() {
    Ok(zahl) => zahl,
    Err(_) => continue,
};
```

So geht man in der Regel von "stürze bei einem Fehler ab" zu
"behandle den Fehler tatsächlich", indem man von `ok().expect()`
zu einer `match` Anweisung wechselt. Das `Result`, welches von `parse()`
zurückgegeben wird, ist tatsächlich ein `enum`, genau wie `Ordering`,
aber in diesem Fall enthält jede Variante ein paar Daten:
`Ok` ist ein Erfolg und `Err` ist ein Fehlschlag. Jeder davon enthält
ein paar Daten:  Die erfolgreich geparste Zahl oder einen Fehlertyp.
In diesem Fall, "matchen" wir `Ok(zahl)`, was den inneeren Wert von `Ok`
an den Name `num` bindet und danach diesen Wert auf der rechten Seite
zurückgibt. Im `Err` Fall interessieren wir uns nicht für die Art des
Fehlers, also benutzen wir einfach `_` anstatt einen Namen.
Dies ignoriert den Fehler und `continue` sorgt dafür, dass wir mit der
nächsten Iteration der Schleife fortfahren.

Nun sollte alles in Ordnung sein! Mal ausprobieren:

```bash
$ cargo run
   Compiling ratespiel v0.1.0 (file:///home/du/projekte/ratespiel)
     Running `target/ratespiel`
Rate die Zahl!
Die geheime Zahl ist: 61
Bitte gib deine Vermutung ein.
10
Deine Vermutung: 10
Zu klein!
Bitte gib deine Vermutung ein.
99
Deine Vermutung: 99
Zu groß!
Bitte gib deine Vermutung ein.
foo
Bitte gib deine Vermutung ein.
61
Deine Vermutung: 61
Gewonnen!
```

Wunderbar! Es fehlt noch eine winzig kleine Änderung damit das
Ratespiel fertig ist. Kannst du dir vorstellen welche?
Genau, wir wollen unsere geheime Zahl nicht ausgeben.
Die Ausgabe war gut zum Testen, aber sie nimmt dem Spiel ein wenig
den Sinn. Hier ist der fertige Code:

```rust
extern crate rand;

use std::io;
use std::cmp::Ordering;
use rand::Rng;

fn main() {
    println!("Rate die Zahl!");

    let geheime_zahl = rand::thread_rng().gen_range(1, 101);

    loop {
        println!("Bitte gib deine Vermutung ein.");

        let mut vermutung = String::new();

        io::stdin().read_line(&mut vermutung)
            .ok()
            .expect("Fehler beim Lesen der Zeile");

        let vermutung: u32 = match vermutung.trim().parse() {
            Ok(zahl) => zahl,
            Err(_) => continue,
        };

        println!("Deine Vermutung: {}", vermutung);

        match vermutung.cmp(&geheime_zahl) {
            Ordering::Less    => println!("Zu klein!"),
            Ordering::Greater => println!("Zu groß!"),
            Ordering::Equal   => {
                println!("Gewonnen!");
                break;
            }
        }
    }
}
```

# Fertig!

Jetzt hast du erfolgreich das Ratespiel gebaut! Gratuliere!

Dieses erste Projekt hat dir eine Menge gezeigt: `let`, `match`,
Methoden, assoziierte Funktionen, wie man externe Crates verwendet, und mehr.
Unser nächstes Projekt wird soger noch mehr demonstrieren.
