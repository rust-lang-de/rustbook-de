## Hallo Cargo

Cargo ist das Bau-System (build system) und der Paketmanager von Rust. Die
meisten Rust-Entwickler verwenden dieses Werkzeug, um ihre Rust-Projekte zu
verwalten, weil Cargo viele Aufgaben für dich erledigt, z.B. Bauen deines
Codes, Herunterladen der Bibliotheken, von denen dein Code abhängt, und das
Bauen dieser Bibliotheken. (Wir nennen Bibliotheken, die dein Code benötigt,
_Abhängigkeiten_ (dependencies).)

Die einfachsten Rust-Programme, wie das, das wir bisher geschrieben haben,
haben keine Abhängigkeiten. Wenn wir also das „Hallo Welt!“-Projekt mit Cargo
gebaut hätten, würde es nur den Teil von Cargo verwenden, der für das Bauen
deines Codes zuständig ist. Wenn du komplexere Rust-Programme schreibst, wirst
du Abhängigkeiten hinzufügen, und wenn du ein Projekt mit Cargo beginnst, wird
das Hinzufügen von Abhängigkeiten viel einfacher sein.

Da die überwiegende Mehrheit der Rust-Projekte Cargo verwendet, geht der Rest
dieses Buches davon aus, dass auch du Cargo verwendest. Cargo wird mit Rust
installiert, wenn du die offiziellen Installationsprogramme verwendet hast, die
im Abschnitt [„Installation“][installation] besprochen werden. Wenn du Rust auf
eine andere Weise installiert hast, prüfe, ob Cargo installiert ist, indem du
Folgendes in dein Terminal eingibst:

```console
$ cargo --version
```

Wenn du eine Versionsnummer siehst, hast du es! Wenn du einen Fehler siehst,
z.B. `command not found`, schaue in der Dokumentation zu deiner
Installationsmethode nach, um festzustellen, wie du Cargo separat installieren
kannst.

### Projekt mit Cargo erstellen

Lass uns mit Cargo ein neues Projekt erstellen und uns ansehen, wie es sich von
unserem ursprünglichen „Hallo Welt!“-Projekt unterscheidet. Navigiere zurück zu
deinem _projects_-Verzeichnis (oder wo auch immer du dich entschieden hast,
deinen Code zu speichern). Führe dann auf einem beliebigen Betriebssystem die
folgenden Schritte aus:

```console
$ cargo new hello_cargo
$ cd hello_cargo
```

Der erste Befehl erstellt ein neues Verzeichnis und ein Projekt namens
_hello_cargo_. Wir haben unser Projekt _hello_cargo_ genannt und Cargo
erstellt seine Dateien in einem Verzeichnis mit demselben Namen.

Gehe in das Verzeichnis _hello_cargo_ und liste die Dateien auf. Du wirst
sehen, dass Cargo zwei Dateien und ein Verzeichnis für uns generiert hat: Eine
Datei _Cargo.toml_ und ein Verzeichnis _src_ mit einer Datei _main.rs_ darin.

Es hat auch ein neues Git-Repository zusammen mit einer Datei _.gitignore_
initialisiert. Git-Dateien werden nicht erzeugt, wenn du `cargo new` innerhalb
eines existierenden Git-Repositories ausführst; du kannst dieses Verhalten
überschreiben, indem du `cargo new --vcs=git` verwendest. 

> Hinweis: Git ist ein gebräuchliches Versionskontrollsystem. Du kannst `cargo
> new` anpassen, um ein anderes Versionskontrollsystem oder kein
> Versionskontrollsystem zu verwenden, indem du das Flag `--vcs` verwendest.
> Führe `cargo new --help` aus, um die verfügbaren Optionen zu sehen.

Öffne _Cargo.toml_ in einem Texteditor deiner Wahl. Es sollte ähnlich wie der
Code in Codeblock 1-2 aussehen.

<span class="filename">Dateiname: Cargo.toml</span>

```toml
[package]
name = "hello_cargo"
version = "0.1.0"
edition = "2024"

[dependencies]
```

<span class="caption">Codeblock 1-2: Inhalt von _Cargo.toml_ erzeugt durch
`cargo new`</span>

Diese Datei liegt im Format [_TOML_][toml] (_Tom's Obvious, Minimal
Language_) vor, welches das Konfigurationsformat von Cargo ist.

Die erste Zeile `[package]` ist eine Abschnittsüberschrift, die anzeigt, dass
die folgenden Anweisungen ein Paket konfigurieren. Wenn wir weitere
Informationen zu dieser Datei hinzufügen, werden wir weitere Abschnitte
hinzufügen.

Die nächsten drei Zeilen legen die Konfigurationsinformationen fest, die Cargo
benötigt, um dein Programm zu kompilieren: Den Namen, die Version und die zu 
verwendende Rust-Ausgabe. Über den Schlüssel `edition` sprechen wir in [Anhang
E][appendix-e].

Die letzte Zeile `[dependencies]` ist der Anfang eines Abschnitts, in dem du
alle Abhängigkeiten deines Projekts auflisten kannst. In Rust werden
Code-Pakete als _Kisten_ (crates) bezeichnet. Wir werden keine anderen Kisten
für dieses Projekt benötigen, aber wir werden es im ersten Projekt in Kapitel 2
tun, also werden wir dann diesen Abhängigkeits-Abschnitt verwenden.

Öffne nun _src/main.rs_ und wirf einen Blick darauf:

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    println!("Hello, world!");
}
```

Cargo hat für dich ein „Hello, world!“-Programm generiert, genau wie das, das
wir in Codeblock 1-1 geschrieben haben! Die Unterschiede zwischen unserem
Projekt und dem Projekt, das Cargo generiert hat, bestehen bisher darin, dass
Cargo den Code im Verzeichnis _src_ abgelegt hat, und wir haben eine
Konfigurationsdatei _Cargo.toml_ im obersten Verzeichnis.

Cargo erwartet, dass deine Quelldateien innerhalb des _src_-Verzeichnisses
liegen. Das Projektverzeichnis der obersten Ebene ist nur für README-Dateien,
Lizenzinformationen, Konfigurationsdateien und alles andere, was nicht mit
deinem Code zusammenhängt. Das Verwenden von Cargo hilft dir, deine Projekte zu
organisieren. Es gibt einen Platz für alles und alles ist an seinem Platz.

Wenn du ein Projekt begonnen hast, das Cargo nicht verwendet, wie wir es mit
dem Projekt „Hallo Welt!“ getan haben, kannst du es in ein Projekt umwandeln,
das Cargo verwendet. Verschiebe den Projektcode in das Verzeichnis _src_ und
erstelle eine entsprechende _Cargo.toml_-Datei. Eine einfache Möglichkeit, die
Datei _Cargo.toml_ zu erstellen, besteht darin, `cargo init` auszuführen.

### Bauen und Ausführen eines Cargo-Projekts

Schauen wir uns nun an, was anders ist, wenn wir das „Hello, world!“-Programm
mit Cargo bauen und ausführen. Von deinem _hello_cargo_-Verzeichnis aus baust
du dein Projekt, indem du den folgenden Befehl eingibst:

```console
$ cargo build
   Compiling hello_cargo v0.1.0 (file:///projects/hello_cargo)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 2.85 secs
```

Dieser Befehl erzeugt eine ausführbare Datei in _target/debug/hello_cargo_
(oder _target\debug\hello_cargo.exe_ unter Windows) und nicht in deinem
aktuellen Verzeichnis. Da standardmäßig für den Debug-Modus gebaut wird, legt
Cargo die Binärdatei in einem Verzeichnis namens _debug_ ab. Mit diesem Befehl
kannst du die ausführbare Datei ausführen:

```console
$ ./target/debug/hello_cargo # oder .\target\debug\hello_cargo.exe unter Windows
Hello, world!
```

Wenn alles gut geht, sollte `Hello, world!` im Terminal ausgegeben werden. Wenn
`cargo build` zum ersten Mal ausgeführt wird, erzeugt Cargo auch eine neue
Datei auf der obersten Ebene: _Cargo.lock_. Diese Datei verfolgt die genauen
Versionen der Abhängigkeiten in deinem Projekt. Dieses Projekt hat keine
Abhängigkeiten, daher ist die Datei etwas spärlich. Du musst diese Datei
niemals manuell ändern; Cargo verwaltet ihren Inhalt für dich.

Wir haben gerade ein Projekt mit `cargo build` gebaut und es mit
`./target/debug/hello_cargo` ausgeführt, aber wir können auch `cargo run`
verwenden, um den Code zu kompilieren und dann die resultierende ausführbare
Datei mit einem einzigen Befehl auszuführen:

```console
$ cargo run
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.0 secs
     Running `target/debug/hello_cargo`
Hello, world!
```

Das Verwenden von `cargo run` ist bequemer, als sich daran erinnern zu müssen,
`cargo build` auszuführen und dann den gesamten Pfad zur Binärdatei zu
verwenden, daher verwenden die meisten Entwickler `cargo run`.

Beachte, dass wir diesmal keine Ausgabe gesehen haben, die darauf hinweist,
dass Cargo `hello_cargo` kompiliert hat. Cargo fand heraus, dass sich die
Dateien nicht geändert hatten, also hat es nicht neu gebaut, sondern ließ
einfach die Binärdatei laufen. Wenn du deinen Quellcode geändert hättest, hätte
Cargo das Projekt vor der Ausführung neu kompiliert, und du hättest diese
Ausgabe gesehen:

```console
$ cargo run
   Compiling hello_cargo v0.1.0 (file:///projects/hello_cargo)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.33 secs
     Running `target/debug/hello_cargo`
Hello, world!
```

Cargo bietet auch einen Befehl namens `cargo check`. Dieser Befehl überprüft
schnell deinen Code, um sicherzustellen, dass er kompiliert, erzeugt aber keine
ausführbare Datei:

```console
$ cargo check
   Checking hello_cargo v0.1.0 (file:///projects/hello_cargo)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.32 secs
```

Warum willst du keine ausführbare Datei? Häufig ist `cargo check` viel
schneller als `cargo build`, weil es den Schritt der Erstellung einer
ausführbaren Datei überspringt. Wenn du deine Arbeit während des Schreibens des
Codes ständig überprüfst, wird das Verwenden von `cargo check` den Prozess
beschleunigen! Daher führen viele Rust-Entwickler während des Schreibens ihres
Programms regelmäßig `cargo check` aus, um sicherzustellen, dass das Programm
kompiliert. Dann lassen sie `cargo build` laufen, wenn sie bereit sind, die
ausführbare Datei zu benutzen.

Lasse uns zusammenfassen, was wir bisher über Cargo gelernt haben:

- Wir können ein Projekt mit `cargo new` erstellen.
- Wir können ein Projekt mit `cargo build` bauen.
- Wir können ein Projekt mit `cargo run` in einem Schritt bauen und ausführen.
- Wir können ein Projekt mit `cargo check` bauen, ohne eine Binärdatei zu
  erzeugen, um auf Fehler zu prüfen.
- Anstatt das Ergebnis des Bauvorgangs im selben Verzeichnis wie unser Code
  abzulegen, legt Cargo es im Verzeichnis _target/debug_ ab.

Ein zusätzlicher Vorteil der Verwendung von Cargo ist, dass die Befehle
unabhängig vom Betriebssystem sind, mit dem du arbeitest. Daher werden wir an
dieser Stelle keine spezifischen Anweisungen für Linux und macOS gegenüber
Windows mehr geben.

### Bauen einer Freigabe (release)

Wenn dein Projekt schließlich zur Freigabe bereit ist, kannst du `cargo build
--release` verwenden, um es mit Optimierungen zu kompilieren. Dieser Befehl
erzeugt eine ausführbare Datei in _target/release_ anstelle von _target/debug_.
Durch die Optimierungen läuft dein Rust-Code schneller, aber wenn du sie
einschaltest, verlängert sich die Zeit, die dein Programm zum Kompilieren
benötigt. Aus diesem Grund gibt es zwei verschiedene Profile: Eines für die
Entwicklung, wenn du schnell und oft neu bauen willst, und ein anderes für das
Erstellen des endgültigen Programms, das du einem Benutzer gibst, das nicht
wiederholt neu gebaut wird und das so schnell wie möglich läuft. Wenn du einen
Laufzeit-Benchmark deines Codes durchführst, stelle sicher, dass du `cargo
build --release` ausführst und den Benchmark mit der ausführbaren Datei in
_target/release_ durchführst.

### Cargo als Konvention

Bei einfachen Projekten bietet Cargo nicht viel mehr Wert als das bloße
Verwenden von `rustc`, aber es wird sich in dem Maße bewähren, wie deine
Programme immer komplizierter werden. Sobald Programme auf mehrere Dateien
anwachsen oder eine Abhängigkeit benötigen, ist es viel einfacher, Cargo den
Bauvorgang koordinieren zu lassen.

Auch wenn das Projekt `hello_cargo` einfach ist, so verwendet es jetzt einen
Großteil der realen Werkzeuge, die du im Rest deiner Rust-Karriere verwenden
wirst. Tatsächlich kannst du, um an bestehenden Projekten zu arbeiten, die
folgenden Befehle verwenden, um den Code mit Git auszuchecken, in das
Verzeichnis dieses Projekts zu wechseln und zu bauen:

```console
$ git clone example.org/someproject
$ cd someproject
$ cargo build
```

Weitere Informationen über Cargo findest du unter seiner
[Dokumentation][cargo-doc].

## Zusammenfassung

Du hast deine Rust-Reise bereits gut begonnen! In diesem Kapitel hast du
gelernt, wie es geht:

- Installiere die neueste stabile Version von Rust mit `rustup`.
- Aktualisiere auf eine neuere Rust-Version.
- Öffne die lokal installierte Dokumentation.
- Schreibe und führe ein „Hallo Welt!“-Programm aus, direkt mittels `rustc`.
- Schreibe und führe ein neues Projekt aus mittels Cargo-Konventionen.

Dies ist ein guter Zeitpunkt, ein umfangreicheres Programm zu erstellen, um
sich an das Lesen und Schreiben von Rust-Code zu gewöhnen. In Kapitel 2 werden
wir also ein Ratespielprogramm erstellen. Wenn du lieber damit beginnen
möchtest, zu lernen, wie gängige Programmierkonzepte in Rust funktionieren,
lies Kapitel 3 und kehre dann zu Kapitel 2 zurück.

[appendix-e]: appendix-05-editions.html
[cargo-doc]: https://doc.rust-lang.org/cargo/
[installation]: ch01-01-installation.html
[toml]: https://toml.io
