## Kisten (crate) auf crates.io veröffentlichen

Wir haben Pakete von [crates.io](https://crates.io/) als
Abhängigkeiten (dependencies) unseres Projekts verwendet. Du kannst deinen
Programmcode jedoch auch für andere Personen freigeben, indem du eigene Pakete
veröffentlichst. Die Registrierung von Kisten auf [crates.io](https://crates.io/)
verteilt den Quellcode deiner Pakete, daher wird primär Open Source Programmcode
gehostet.

Rust und Cargo verfügen über Funktionalitäten, die es Benutzern erleichtern, ihr 
veröffentlichtes Paket zu verwenden und zu finden. Wir werden nun über einige
dieser Funktionalitäten sprechen und dann erklären, wie ein Paket veröffentlicht
wird.

### Sinnvolle Dokumentationskommentare erstellen

Die genaue Dokumentation deiner Pakete hilft anderen Benutzern zu verstehen,
wie diese zu verwenden sind, daher lohnt es sich, Zeit in das Schreiben von
Dokumentationen zu investieren. In Kapitel 3 haben wir besprochen, wie man
Rust-Code mit zwei Schrägstrichen `//` kommentiert. Rust hat auch eine eigene
Art von Kommentar für die Dokumentation, die passenderweise als 
*Dokumentationskommentar* bezeichnet wird und HTML-Dokumentation generiert.
Der HTML-Code zeigt den Inhalt von Dokumentationskommentaren für öffentliche
API-Elemente an, die für Programmierer bestimmt sind, die wissen möchten,
wie deine Kiste *benutzt* wird, und nicht, wie deine Kiste *implementiert*
ist.

Dokumentationskommentare verwenden drei Schrägstriche `///` anstelle von zwei
und unterstützen Markdown-Notation zum Formatieren des Textes. Platziere
Dokumentationskommentare nur vor dem zu dokumentierenden Element. 
Codeblock 14-1 zeigt Dokumentationskommentare für eine Funktion `add_one` in
einer Kiste mit dem Namen ` my_crate`:

<span class="filename">Dateiname: src/lib.rs</span>

```rust,ignore
/// Adds one to the number given 
///
/// # Examples 
///
/// ```
/// let arg = 5;
/// let answer = my_crate::add_one(arg);
///
/// assert_eq!(6, answer);
/// ```
pub fn add_one(x: i32) -> i32 {
    x + 1
}

```

<span class="caption">Codeblock 14-1: Ein Dokumentationskommentar für eine Funktion</span> 

Hier geben wir eine Beschreibung der Funktionsweise der Funktion `add_one` an,
beginnen einen Abschnitt mit der Überschrift `Examples` gefolgt vom
Programmcode, der die Verwendung der Funktion `add_one` demonstriert. Wir können
die HTML-Dokumentation aus diesem Dokumentationskommentar generieren, indem wir
`cargo doc` ausführen. Dieser Befehl führt das mit Rust verbreitete Werkzeug
`rustdoc` aus und legt die generierte HTML-Dokumentation im Verzeichnis
*target/doc* ab.

Wenn du `cargo doc --open` ausführst, wird der HTML-Code für die Dokumentation
deiner aktuellen Kiste (und auch die Dokumentation aller Abhängigkeiten
(dependencies) deiner Kiste) erstellt und das Ergebnis in einem Webbrowser
geöffnet. Wenn du zur Funktion `add_one` navigierst, wirst du sehen wie der Text
in den Dokumentationskommentaren gerendert wird. Siehe Abbildung 14-1:

<img alt="Gerenderte HTML-Dokumentation für die Funktion `add_one` von `my_crate`" src="img/trpl14-01.png" class="center" />

<span class="caption">Abbildung 14-1: HTML-Dokumentation für die Funktion
`add_one`</span>

#### Häufig verwendete Abschnitte

Wir haben die Markdown-Überschrift `# Examples` in Codeblock 14-1 verwendet um
einen Abschnitt im HTML-Code mit dem Titel `Examples` zu erstellen. Hier sind
einige andere Abschnitte, die Autoren von Kisten häufig in ihrer Dokumentation
verwenden:

* **Panics**: Die Szenarien, in denen die dokumentierte Funktion `panic`
    aufruft. Anwender der Funktion, die nicht möchten, dass ihre Programme
    `panic` aufrufen, sollten sicherstellen, dass sie die Funktion in solchen
    Situationen nicht aufrufen.
* **Errors**: Wenn die Funktion einen Typ `Result` zurückgibt, der die Arten von
    Fehlern die auftreten können beschreibt und unter welchen Bedingungen diese
    Fehler auftreten können, dies kann für Aufrufende hilfreich sein, um
    Programmcode zu schreiben der die verschiedenen Arten von Fehlern auf
    unterschiedliche Art behandelt.
* **Safety**: Wenn die Funktion aufzurufen unsicher (`unsafe`) ist (wir
    behandeln die Unsicherheit im Kapitel 19), sollte ein Abschnitt existieren,
    in dem erläutert wird, warum die Funktion unsicher ist, und die Invarianten
    behandelt werden die die Funktion vom Aufrufenden erwartet.

Die meisten Dokumentationskommentare benötigen nicht alle Abschnitte, aber dies
ist eine gute Checkliste um dich an die Aspekte deines Programmcodes erinnern,
die für andere Personen die ihn aufrufen interessant sein werden.


#### Dokumentationskommentare als Tests

Das Hinzufügen von Beispiel-Codeblöcken in deinen Dokumentationskommentaren kann
dabei hilfreich sein, die Verwendung deiner Programmbibliothek darzustellen.
Dies hat einen zusätzlichen Bonus: Das Ausführen von `cargo test` führt die
Codeblöcke in deiner Dokumentation als Test aus! Nichts ist besser als eine
Dokumentation mit Beispielen, aber nichts ist schlimmer als eine Dokumentation
mit Beispielen die nicht funktionieren, da sich der Code seit dem Schreiben der
Dokumentation geändert hat. Wenn wir `cargo test` für die Dokumentation der
Funktion `add_one` aus Codeblock 14-1 aufrufen, sehen wir folgenden Abschnitt in
den Testergebnissen:

```text
   Doc-tests my_crate

running 1 test
test src/lib.rs - add_one (line 5) ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out
```
Wenn wir nun entweder die Funktion oder das Beispiel so ändern, dass `assert_eq!`
im Beispiel `panic` aufruft und erneut `cargo test` aufrufen, werden wir
bemerken, das `cargo test` feststellt, dass das Beispiel und der Code nicht
synchron miteinander sind!

#### Enthaltene Elemente kommentieren

Ein anderer Stil des Dokumentationskommentars `//!` fügt dem Element, das die
Kommentare enthält, Dokumentation hinzu, anstatt den Elementen die auf die
Kommentare folgen Dokumentation hinzuzufügen. Wir verwenden diese
Dokumentationskommentare üblicherweise in der Wurzeldatei (laut Konvention
*src/lib.rs*) oder in einem Modul, um die Kiste oder das Modul als Ganzes zu
dokumentieren.

Wenn wir beispielsweise eine Dokumentation hinzufügen möchten, die den Zweck
der `my_crate`-Kiste beschreibt, die die Funktion `add_one` enthält, können wir
am Anfang der Datei *src/lib.rs* Dokumentationskommentare hinzufügen die mit
`//!` beginnen. Siehe Codeblock 14-2: 

<span class="filename">Dateiname: src/lib.rs</span>

```rust,ignore
//! # My Crate
//!
//! `my_crate` is a collection of utilities to make performing certain
//! calculations more convenient.

/// Adds one to the number given.
// --snip--
#///
#/// # Examples
#///
#/// ```
#/// let arg = 5;
#/// let answer = my_crate::add_one(arg);
#///
#/// assert_eq!(6, answer);
#/// ```
#pub fn add_one(x: i32) -> i32 {
#    x + 1
#}
```

<span class="caption">Codeblock 14-2: Dokumentation für die gesamte
`my_crate`-Kiste</span>

Beachte, dass nach der letzten Zeile, die mit `//!` beginnt, kein Programmcode
mehr vorhanden ist. Da wir die Kommentare mit `//!` anstatt `///` begonnen
haben, dokumentieren wir das Element, das diesen Kommentar enthält und nicht ein 
Element, das diesem Kommentar folgt. In diesem Fall ist das Element, das diesen
Kommentar enthält, die Datei *src/lib.rs*, dabei handelt es sich um das
Wurzelverzeichnis der Kiste. Diese Kommentare beschreiben die gesamte Kiste.

Wenn wir `cargo doc --open` ausführen, werden diese Kommentare auf der
Startseite der Dokumentation für `my_crate` angezeigt, oberhalb der Liste der
veröffentlichten Elemente in der Kiste. Siehe Abbildung 14-2:

<img alt="Gerenderte HTML-Dokumentation mit einem Kommentar für die gesamte Kiste" src="img/trpl14-02.png" class="center" />

<span class="caption">Abbildung 14-2: Gerenderte Dokumentation für `my_crate`,
einschließlich des Kommentars, der die Kiste als Ganzes beschreibt</span>

Dokumentationskommentare innerhalb von Elementen sind besonders nützlich, um
Kisten und Module zu beschreiben. Erkläre anhand dieser Informationen den
allgemeinen Zweck des Containers, damit seine Benutzer die Aufteilung der Kiste
besser verstehen können.

### Mit `pub use` eine benutzerfreundliche öffentliche API exportieren

In Kapitel 7 wurde erläutert, wie wir unseren Programmcode mithilfe des
Schlüsselworts `mod` in Module organisieren, Elemente mit dem Schlüsselwort 
`pub` veröffentlichen und Elemente mit dem Schlüsselwort `use` in einen
Gültigkeitsbereich (scope) bringen. Die Struktur, die für dich während der
Entwicklung einer Kiste sinnvoll ist, ist für ihre Benutzer jedoch möglicherweise
nicht sehr benutzerfreundlich. Vielleicht möchtest du Strukturen in einer 
Hierarchie mit mehreren Ebenen organisieren, aber Personen, die einen Typ
verwenden möchten, den du tief in der Hierarchie definiert hast, haben
möglicherweise Probleme, herauszufinden, ob dieser Typ vorhanden ist. Sie könnten
sich auch darüber ärgern, dass sie `use` ` my_crate::some_module::another_module::UsefulType;`
eingeben müssen anstatt `use` `my_crate::UsefulType;`.

Die Struktur deiner öffentlichen API spielt beim Veröffentlichen einer Kiste eine
wichtige Rolle. Personen, die deine Kiste verwenden, sind mit der Struktur weniger
vertraut als du und haben vielleicht Schwierigkeiten, die Teile zu finden,
die sie verwenden möchten, wenn deine Kiste eine große Modulhierarchie aufweist.

Die gute Nachricht ist, dass du die interne Organisation nicht neu anordnen
musst, wenn sie für andere aus einer anderen Bibliothek *nicht* geeignet ist.
Stattdessen kannst du Elemente erneut exportieren, um mit `pub use` eine
veränderte öffentliche Struktur von deiner privaten Struktur zu erstellen.
Beim Re-Exportieren wird ein öffentliches Element an einem Speicherort genommen 
und an einem anderen Speicherort öffentlich gemacht, als ob es stattdessen am
anderen Speicherort definiert worden wäre.

Nehmen wir zum Beispiel an, wir haben eine Bibliothek mit dem Namen `art`
erstellt, um künstlerische Konzepte zu modellieren. In dieser Bibliothek sind
zwei Module enthalten: Ein Modul `kinds` mit zwei Aufzählungen (enums) namens
`PrimaryColor` und `SecondaryColor` und ein Modul `utils` das eine Funktion
namens `mix` beinhaltet. Siehe Codeblock 14-3:

<span class="filename">Dateiname: src/lib.rs</span>

```rust
//! # Art
//!
//! A library for modeling artistic concepts.

pub mod kinds {
    /// The primary colors according to the RYB color model.
    pub enum PrimaryColor {
        Red,
        Yellow,
        Blue,
    }

    /// The secondary colors according to the RYB color model.
    pub enum SecondaryColor {
        Orange,
        Green,
        Purple,
    }
}

pub mod utils {
    use crate::kinds::*;

    /// Combines two primary colors in equal amounts to create
    /// a secondary color.
    pub fn mix(c1: PrimaryColor, c2: PrimaryColor) -> SecondaryColor {
        // --snip--
#        SecondaryColor::Orange
    }
}
#
# fn main() {}
```

<span class="caption">Codeblock 14-3: Eine Bibliothek `art` mit Elementen die in
Modulen `kinds` und `utils` organisiert sind</span>

Abbildung 14-3 zeigt wie die Startseite der Dokumentation für diese Kiste
generiert von `cargo doc` aussehen würde.

<img alt="Rendered documentation for the `art` crate that lists the `kinds` and `utils` modules" src="img/trpl14-03.png" class="center" />

<span class="caption">Abbildung 14-3: Startseite der Dokumentation für `art`
die Module `kinds` und `utils` auflistet</span>

Beachte, dass die Typen `PrimaryColor`, `SecondaryColor` und die Funktion `mix`
nicht auf der Startseite angeführt sind. Wir müssen auf `kinds` und `utils`
klicken um sie zu sehen.

Eine Kiste, die von dieser Bibliothek abhängt, würde `use`-Anweisungen
benötigen, die die Elemente aus `art` in den Gültigkeitsbereich bringen und die
derzeit definierte Modulstruktur angeben. Codeblock 14-4 zeigt ein Beispiel für
eine Kiste, in der die Elemente `PrimaryColor` und `mix` aus der `art`-Kiste
verwendet werden:

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore
use art::kinds::PrimaryColor;
use art::utils::mix;

fn main() {
    let red = PrimaryColor::Red;
    let yellow = PrimaryColor::Yellow;
    mix(red, yellow);
}
```

<span class="caption">Codeblock 14-4: Eine Kiste, die die Gegenstände der 
`art`-Kiste mit ihrer internen Struktur exportiert</span>

Der Autor des Programmcodes in Codeblock 14-4, der die Kiste `art` verwendet,
musste herausfinden, dass sich `PrimaryColor` im Modul `art` und `mix` im Modul
`utils` befindet. Die Modulstruktur der `art`-Kiste ist für Entwickler, die an
der `art`-Kiste arbeiten, relevanter als für Entwickler die die `art`-Kiste
verwenden. Die interne Struktur, die Teile der Kiste in das Modul `art` und das
Modul `utils` unterteilt, enthält keine nützlichen Informationen für jemanden,
der die `art`-Kiste benutzen möchte, sondern sorgt für Verwirrung, da Entwickler
herausfinden müssen wo sie suchen müssen und die Struktur ist unpraktisch, da
Entwickler die Modulnamen in den `use`-Anweisungen angeben müssen.

Um die interne Organisation aus der öffentlichen API zu entfernen, können wir den
Programmcode der `art`-Kiste ändern, um `pub use`-Anweisungen hinzuzufügen, um
die Elemente der obersten Ebene erneut zu exportieren, wie in Codeblock 14-5
gezeigt:

<span class="filename">Dateiname: src/lib.rs</span>

```rust,ignore
//! # Art
//!
//! A library for modeling artistic concepts.

pub use self::kinds::PrimaryColor;
pub use self::kinds::SecondaryColor;
pub use self::utils::mix;

pub mod kinds {
   // --snip--
#    /// The primary colors according to the RYB color model.
#    pub enum PrimaryColor {
#        Red,
#        Yellow,
#        Blue,
#    }
#
#    /// The secondary colors according to the RYB color model.
#    pub enum SecondaryColor {
#        Orange,
#        Green,
#        Purple,
#    }
}

pub mod utils {
    // --snip--
#    use crate::kinds::*;
#
#    /// Combines two primary colors in equal amounts to create
#    /// a secondary color.
#    pub fn mix(c1: PrimaryColor, c2: PrimaryColor) -> SecondaryColor {
#        SecondaryColor::Orange
#    }
}
```

<span class="caption">Codeblock 14-5: Hinzufügen von `pub use`-Anmerkungen um
Elemente erneut zu exportieren</span>

Die Dokumentation der API, die von `cargo doc` generiert wurde, wird nun
aufgelistet und die erneut exportierten Links werden auf der Startseite, wie in
Abbildung 14-4 ersichtlich, angezeigt, so sind die Typen `PrimaryColor` und
`SecondaryColor` leichter zu finden.

<img alt="Rendered documentation for the `art` crate with the re-exports on the front page" src="img/trpl14-04.png" class="center" />

<span class="caption">Abbildung 14-4: Die Startseite der Dokumentation von
`art` mit den aufgelisteten erneuten Exporten</span>

Die Benutzer der `art`-Kiste können weiterhin die interne Struktur aus Codeblock
14-3 sehen und verwenden, wie es in Codeblock 14-4 gezeigt wurde, oder sie
können die benutzerfreundliche Struktur in Codeblock 14-5 verwenden, wie es im
Codeblock 14-6 gezeigt wurde:

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore
use art::mix;
use art::PrimaryColor;

fn main() {
    // --snip--
#    let red = PrimaryColor::Red;
#    let yellow = PrimaryColor::Yellow;
#    mix(red, yellow);
}
```

<span class="caption">Codeblock 14-6: Ein Programm, das die erneut exportierten
Elemente der `art`-Kiste verwendet</span>

In Fällen, in denen es viele verschachtelte Module gibt, kann das erneute 
Exportieren der Typen auf der obersten Ebene mit `pub use` die Erfahrung der
Benutzer der Kiste signifikant verbessern.

Das Erstellen einer sinnvollen öffentlichen API-Struktur ist eher eine Kunst als
eine Wissenschaft, und du kannst iterieren, um die API zu finden, die für
Benutzer am besten geeignet ist. Wenn man `pub use` wählt, erhält man
Flexibilität bei der internen Strukturierung einer Kiste und entkoppelt diese
interne Struktur von dem, was man ihren Benutzern präsentiert. Sieh dir 
einige der Programmcodes von Kisten an die du installiert hast, um festzustellen,
ob sie intern strukturiert sind und ob sich ihre interne Struktur von der
öffentlichen API unterscheidet.


### Einrichten eines Kontos auf Crates.io

Bevor man eine Kiste veröffentlichen kann, muss man ein Konto auf 
[crates.io](https://crates.io/) erstellen um ein API-Token zu
erhalten. Besuche dazu die Homepage auf [crates.io](https://crates.io/)
und melde dich über ein GitHub-Konto an. (Derzeit ist ein GitHub-Konto eine
Voraussetzung, aber die Seite wird möglicherweise in Zukunft andere Wege einen
Account zu erstellen ermöglichen.) Sobald du angemeldet bist, gehe zu
Kontoeinstellungen (account settings) auf 
[https://crates.io/me/](https://crates.io/me/) und erhalte deinen 
API-Schlüssel. Rufe anschließend das Kommando `cargo login` mit deinem
API-Schlüssel auf:

```console
$ cargo login abcdefghijklmnopqrstuvwxyz012345
```
### Metadaten zu einer neuen Kiste hinzufügen

Angenommen, du hast ein Konto und eine Kiste, die du veröffentlichen möchtest.
Vor dem Veröffentlichen musst du deiner Kiste einige Metadaten hinzufügen,
indem du sie im Abschnitt `[package]` der Datei *Cargo.toml* der Kiste
hinzufügst.

Deine Kiste benötigt einen eindeutigen Namen. Während du vor Ort an einer Kiste
arbeitest, kannst du eine Kiste beliebig benennen. Allerdings werden Kistennamen
auf [crates.io](https://crates.io/) nach Verfügbarkeit vergeben.
Sobald ein Kistenname vergeben ist, kann niemand mehr eine Kiste mit
diesem Namen veröffentlichen. Suche vor dem Versuch, eine Kiste zu veröffentlichen,
nach dem Namen, den du auf der Webseite verwenden möchtest. Wenn
der Name von einer anderen Kiste verwendet wurde, wirst du einen anderen Namen
suchen müssen und das Feld `name` in der Datei *Cargo.toml* im Abschnitt
`[package]` bearbeiten, um den neuen Namen für die Veröffentlichung zu
verwenden:

<span class="filename">Dateiname: Cargo.toml</span>

```toml
[package]
name = "guessing_game"
```
Selbst wenn du einen eindeutigen Namen gewählt hast, wird beim Ausführen von
`cargo publish` zum Veröffentlichen der Kiste an dieser Stelle eine Warnung und 
anschließend ein Fehler angezeigt:

```console
$ cargo publish
    Updating crates.io index
warning: manifest has no description, license, license-file, documentation, homepage or repository.
See https://doc.rust-lang.org/cargo/reference/manifest.html#package-metadata for more info.
--snip--
error: api errors (status 200 OK): missing or empty metadata fields: description, license. Please see https://doc.rust-lang.org/cargo/reference/manifest.html for how to upload metadata
```

Der Grund dafür ist, dass einige wichtige Informationen fehlen: Eine
Beschreibung und eine Lizenz sind erforderlich, damit die Benutzer wissen, was
deine Kiste tut und unter welchen Bedingungen man sie verwenden kann. Um diesen
Fehler zu beheben, muss man diese Informationen in die Datei *Cargo.toml*
aufnehmen.

Füge eine Beschreibung hinzu, die nur ein oder zwei Sätze umfasst, da sie
zusammen mit deiner Kiste in den Suchergebnissen angezeigt wird. Für das Feld
`license` musst du einen *Lizenzkennungswert* (licence identifier value) angeben.
In [Linux Foundation’s Software Package Data Exchange (SPDX)][spdx]
sind die Bezeichner aufgeführt, die Sie für diesen Wert verwenden können. Um
beispielsweise anzugeben, dass du deine Kiste mit der MIT-Lizenz lizenziert
hast, füge die `MIT`-Identifikation hinzu:

[spdx]: http://spdx.org/licenses/

<span class="filename">Dateiname: Cargo.toml</span>

```toml
[package]
name = "guessing_game"
license = "MIT"
```
Wenn man eine Lizenz verwenden möchte, die nicht in SPDX angezeigt wird, muss man
den Text dieser Lizenz in eine Datei einfügen, die Datei in das Projekt aufnehmen
und dann `license-file` verwenden um den Namen dieser Lizenz zu spezifizieren 
anstelle der Verwendung des `license`-Schlüssels.

Die Anleitung, welche Lizenz für dein Projekt geeignet ist, geht über den Rahmen
dieses Buches hinaus. Viele Leute in der Rust Community lizenzieren ihre Projekte
genauso wie Rust mit einer Doppellizenz von `MIT OR Apache-2.0`. Diese Übung
zeigt, dass man durch `OR` auch mehrere Lizenzkennungen getrennt angeben kann,
um mehrere Lizenzen für ein Projekt zu haben.

Mit einem eindeutigen Namen, der Version, den Angaben des Autors, die beim
Erstellen der Kiste mit `cargo new` hinzugefügt wurden, deiner Beschreibung und
einer hinzugefügten Lizenz könnte die Datei *Cargo.toml* für ein Projekt,
das zur Veröffentlichung bereit ist, folgendermaßen aussehen:

<span class="filename">Dateiname: Cargo.toml</span>

```toml
[package]
name = "guessing_game"
version = "0.1.0"
authors = ["Dein Name <du@example.com>"]
edition = "2018"
description = "A fun game where you guess what number the computer has chosen."
license = "MIT OR Apache-2.0"

[dependencies]
```

[Cargos documentation](https://doc.rust-lang.org/cargo/) beschreibt andere 
Metadaten, die du angeben kannst, um sicherzustellen, dass andere deine Kiste
leichter entdecken und verwenden können.

### Veröffentlichung auf Crates.io

Nachdem man ein Konto erstellt, den API-Token gespeichert, einen Namen für seine
Kiste ausgewählt und die erforderlichen Metadaten angegeben hat, kann man
sie veröffentlichen! Durch das Veröffentlichen einer Kiste wird eine bestimmte
Version auf [crates.io](https://crates.io/) hochgeladen, damit andere sie
verwenden können.

Sei vorsichtig, wenn du eine Kiste veröffentlichst, da eine
Veröffentlichung *permanent* ist. Die Version kann niemals überschrieben und
der Programmcode nicht gelöscht werden. Ein Hauptziel von [crates.io](https://crates.io/)
ist es, als permanentes Archiv von Code zu fungieren, sodass alle Projekte
die erstellt werden und von Kisten aus [crates.io](https://crates.io/) abhängen
weiter funktionieren werden. Das Zulassen von Versionslöschungen würde das
Erreichen dieses Ziels unmöglich machen. Die Anzahl der Kistenversionen, die man
veröffentlichen kann, ist jedoch unbegrenzt.

Rufe `cargo publish` erneut auf. Diesmal sollte es funktionieren:

```console
$ cargo publish
    Updating crates.io index
   Packaging guessing_game v0.1.0 (file:///projects/guessing_game)
   Verifying guessing_game v0.1.0 (file:///projects/guessing_game)
   Compiling guessing_game v0.1.0
(file:///projects/guessing_game/target/package/guessing_game-0.1.0)
    Finished dev [unoptimized + debuginfo] target(s) in 0.19s
   Uploading guessing_game v0.1.0 (file:///projects/guessing_game)
```
Herzlichen Glückwunsch! Du hast deinen Programmcode nun für die Rust-Community
freigegeben. Jeder kann deine Kiste einfach als Abhängigkeit für sein Projekt
hinzufügen.

### Veröffentlichen einer neuen Version einer vorhandenen Kiste

Wenn du Änderungen an deiner Kiste vorgenommen hast und bereit bist, eine neue
Version zu veröffentlichen, ändere den in der *Cargo.toml*-Datei
angegebenen Versionswert und veröffentliche ihn erneut. Verwende die
[Regeln für die semantische Versionierung][semver], um auf den von dir 
vorgenommenen Änderungen basierend welche neue Versionsnummer geeignet ist.
Führe dann `cargo publish` aus, um die neue Version hochzuladen.

[semver]: https://semver.org/lang/de/

### Mit `cargo yank` Versionen von Crates.io entfernen

Obwohl man frühere Versionen einer Kiste nicht entfernen kann, kann man
verhindern, dass zukünftige Projekte sie als neue Abhängigkeit hinzufügen. Dies
ist nützlich, wenn eine Kistenversion aus dem einen oder anderen Grund defekt
ist. In solchen Situationen unterstützt Cargo das *herausziehen* (yanking)
einer Kistenversion.

Durch das Herausziehen einer Version wird verhindert, dass neue Projekte von
dieser Version abhängen, während alle vorhandenen Projekte, die davon abhängen,
weiterhin heruntergeladen werden können. Im Wesentlichen bedeutet Herausziehen
(yank), dass alle Projekte mit einem *Cargo.lock* nicht kaputt gehen und zukünftige
generierte *Cargo.lock*-Dateien nicht die herausgezogene Version verwenden.

Um eine Version einer Kiste herauszuziehen, rufe `cargo yank` auf und
spezifiziere welche Version du herausziehen möchtest:

```console
$ cargo yank --vers 1.0.1
```

Durch Hinzufügen von `--undo`, kann man das Herausziehen rückgängig machen und
Projekten wieder erlauben von der Version abzuhängen:

```console
$ cargo yank --vers 1.0.1 --undo
```

Das Herausziehen löscht *keinen* Programmcode. Beispielsweise ist die
Herausziehen-Funktion nicht zum Löschen versehentlich hochgeladener Geheimnisse
gedacht. Falls das passieren sollte musst du diese Geheimnisse sofort zurücksetzen.
