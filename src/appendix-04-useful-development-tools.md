## Anhang D - Nützliche Entwicklungswerkzeuge

In diesem Anhang sprechen wir über einige nützliche Entwicklungswerkzeuge, die
das Rust-Projekt bietet. Wir werden uns mit automatischer Formatierung,
schnellen Möglichkeiten zum Beheben von Warnhinweisen, einem Tool zur
statischen Code-Analyse (linter) und der Integration in integrierte
Entwicklungsumgebungen (IDEs) befassen.

### Automatische Formatierung mit `rustfmt`

Das Tool `rustfmt` formatiert deinen Code entsprechend des Community-Codestils.
Viele kollaborative Projekte verwenden `rustfmt`, um Diskussionen zum Stil beim
Schreiben von Rust zu vermeiden: Jeder formatiert seinen Code mithilfe des
Tools.

Um `rustfmt` zu installieren, gib folgendes ein:

```console
$ rustup component add rustfmt
```

Dieser Befehl stellt dir `rustfmt` und `cargo-fmt` zur Verfügung, ähnlich wie
Rust sowohl `rustc` als auch `cargo` bereitstellt. Um ein beliebiges
Cargo-Projekt zu formatieren, gib folgendes ein:

```console
$ cargo fmt
```

Durch Ausführen dieses Befehls wird der gesamte Rust-Code in der aktuellen
Kiste (crate) neu formatiert. Dies sollte nur den Codestil, nicht aber die
Codesemantik ändern. Weitere Informationen zu `rustfmt` findest du in [seiner
Dokumentation][rustfmt].

[rustfmt]: https://github.com/rust-lang/rustfmt

### Korrigiere deinen Code mit `rustfix`

Das Werkzeug rustfix ist in Rust-Installationen enthalten und kann automatisch
Compiler-Warnungen beheben, die eine Möglichkeit haben, das Problem zu beheben,
was wahrscheinlich das ist, was du willst. Wahrscheinlich hast du schon einmal
Compiler-Warnungen gesehen. Betrachte zum Beispiel diesen Code:

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn do_something() {}

fn main() {
    for i in 0..100 {
        do_something();
    }
}
```

Hier rufen wir die Funktion `do_something` 100 Mal auf, aber wir verwenden die
Variable `i` im Rumpf der `for`-Schleife nicht. Rust warnt uns davor:

```console
$ cargo build
   Compiling myprogram v0.1.0 (file:///projects/myprogram)
warning: unused variable: `i`
 --> src/main.rs:4:9
  |
4 |     for i in 1..100 {
  |         ^ help: consider using `_i` instead
  |
  = note: #[warn(unused_variables)] on by default

    Finished dev [unoptimized + debuginfo] target(s) in 0.50s
```

Die Warnung empfiehlt, stattdessen `_i` als Namen zu verwenden: Der Unterstrich
zeigt an, dass wir diese Variable nicht verwenden wollen. Wir können diesen
Vorschlag mit dem Werkzeug `rustfix` automatisch übernehmen, indem wir das
Kommando `cargo fix` ausführen:

```console
$ cargo fix
    Checking myprogram v0.1.0 (file:///projects/myprogram)
      Fixing src/main.rs (1 fix)
    Finished dev [unoptimized + debuginfo] target(s) in 0.59s
```

Wenn wir uns *src/main.rs* noch einmal ansehen, werden wir sehen, dass
`cargo fix` den Code geändert hat:

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn do_something() {}

fn main() {
    for _i in 0..100 {
        do_something();
    }
}
```

Die `for`-Schleifenvariable heißt jetzt `_i` und die Warnung erscheint nicht
mehr.

Du kannst den Befehl `cargo fix` auch dazu verwenden, deinen Code zwischen
verschiedenen Rust-Ausgaben zu konvertieren. Die Ausgaben sind in [Anhang
E](appendix-05-editions.md) aufgeführt.

### Mehr statische Codeanalyse mit Clippy

Das Tool Clippy ist eine Sammlung von Tools zur statischen Codeanalyse, mit dem
du häufige Fehler aufspüren und deinen Rust-Code verbessern kannst.

Um Clippy zu installieren, gib folgendes ein:

```console
$ rustup component add clippy
```

Um Clippy bei einem Cargo-Projekt auszuführen, gib folgendes ein:

```console
$ cargo clippy
```

Angenommen, du schreibst ein Programm, das eine Annäherung an eine
mathematische Konstante wie Pi verwendet, wie dieses Programm es tut:

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let x = 3.1415;
    let r = 8.0;
    println!("Die Kreisfläche ist {}", x * r * r);
}
```

Das Ausführen von `cargo clippy` in diesem Projekt führt zu diesem Fehler:

```text
error: approximate value of `f{32, 64}::consts::PI` found. Consider using it directly
 --> src/main.rs:2:13
  |
2 |     let x = 3.1415;
  |             ^^^^^^
  |
  = note: #[deny(clippy::approx_constant)] on by default
  = help: for further information visit https://rust-lang-nursery.github.io/rust-clippy/master/index.html#approx_constant
```

Dieser Fehler weist dich darauf hin, dass in Rust bereits eine präzisere
Konstante `PI` definiert ist und dass dein Programm korrekter wäre, wenn du
stattdessen diese Konstante verwenden würdest. Du würdest dann deinen Code
ändern, um die Konstante `PI` zu verwenden. Der folgende Code führt zu keinen
Fehlern oder Warnungen von Clippy:

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let x = std::f64::consts::PI;
    let r = 8.0;
    println!("Die Kreisfläche ist {}", x * r * r);
}
```

Für weitere Informationen über Clippy siehe [seine Dokumentation][clippy].

[clippy]: https://github.com/rust-lang/rust-clippy

### IDE-Integration mittels `rust-analyzer`

Um die IDE-Integration zu erleichtern, empfiehlt die Rust-Gemeinschaft die
Verwendung des [`rust-analyzer`][rust-analyzer]. Bei diesem Werkzeug handelt es
sich um eine Reihe von Compiler-zentrierten Hilfsprogrammen, die das
[Sprach-Server-Protokoll (Language Server Protocol)][lsp] beherrschen, eine
Spezifikation für IDEs und Programmiersprachen zur Kommunikation untereinander.
Verschiedene Clients können `rust-analyzer` verwenden, wie zum Beispiel [das
Rust-Plugin für Visual Studio Code][vscode].

Besuche die [Homepage][rust-analyzer] des Projekts `rust-analyzer`, um
Installationsanweisungen zu erhalten, und installiere dann die
Sprachserver-Unterstützung in deiner speziellen IDE. Deine IDE wird
Fähigkeiten wie Autovervollständigung, Sprung zur Definition und im Code
eingeblendete Fehlermeldungen erhalten.

[lsp]: http://langserver.org/
[rust-analyzer]: https://rust-analyzer.github.io
[vscode]: https://marketplace.visualstudio.com/items?itemName=rust-lang.rust-analyzer
