## Cargo-Arbeitsbereiche

In Kapitel 12 haben wir ein Paket erstellt, das eine binäre Kiste und eine
Bibliothekskiste enthält. Während dein Projekt entwickelt wird, wirst du
möglicherweise feststellen, dass die Bibliothekskiste immer größer wird und du
dein Paket weiter in mehrere Bibliothekskisten aufteilen möchtest. Cargo bietet
eine Funktion namens _Arbeitsbereiche_ (workspaces), mit denen mehrere
verwandte Pakete verwaltet werden können, die gemeinsam entwickelt werden.

### Einen Arbeitsbereich erstellen

Ein _Arbeitsbereich_ ist eine Reihe von Paketen, die dieselbe Datei
_Cargo.lock_ sowie dasselbe Ausgabeverzeichnis (output directory) verwenden.
Lass uns mithilfe eines Arbeitsbereiches ein Projekt erstellen. Wir verwenden
einfachen Programmcode, damit wir uns auf die Struktur des Arbeitsbereiches
konzentrieren können. Es gibt verschiedene Möglichkeiten, einen Arbeitsbereich
zu strukturieren. Wir werden nur einen einen üblichen Weg zeigen. Wir haben
einen Arbeitsbereich mit einer Binärdatei und zwei Bibliotheken. Die Binärdatei
stellt die Hauptfunktion bereit und hängt von den beiden Bibliotheken ab. Eine
Bibliothek stellt die Funktion `add_one` und eine andere Bibliothek die
Funktion `add_two` zur Verfügung. Diese drei Kisten werden Teil desselben
Arbeitsbereichs sein. Zunächst erstellen wir ein neues Verzeichnis für den
Arbeitsbereich:

```console
$ mkdir add
$ cd add
```

Als Nächstes erstellen wir im Verzeichnis _add_ die Datei _Cargo.toml_, mit der
der gesamte Arbeitsbereich konfiguriert wird. Diese Datei enthält keine
Abschnitt `[package]`. Stattdessen beginnt sie mit einem Abschnitt
`[workspace]`, in dem wir Mitglieder zum Arbeitsbereich hinzufügen können. Wir
stellen außerdem sicher, dass wir die neueste und beste Version des
Cargo-Auflösungsalgorithmus in unserem Arbeitsbereich verwenden, indem wir
den Wert von `resolver` auf `"3"` setzen:

<span class="filename">Dateiname: Cargo.toml</span>

```toml
[workspace]
resolver = "3"
```

Als nächstes erstellen wir die Binärkiste `adder`, indem wir `cargo new` im
Verzeichnis _add_ ausführen:

```console
$ cargo new adder
    Created binary (application) `adder` package
      Adding `adder` as member of workspace at `file:///projects/add`
```

Wenn du `cargo new` innerhalb eines Arbeitsbereichs ausführst, wird das neu
erstellte Paket automatisch zum Schlüssel `members` in der Definition
`[workspace]` der Datei _Cargo.toml_ hinzugefügt, etwa so:

```toml
[workspace]
resolver = "3"
members = ["adder"]
```

An dieser Stelle können wir den Arbeitsbereich erstellen, indem wir `cargo
 build` ausführen. Die Dateien in deinem _add_-Verzeichnis sollten
folgendermaßen aussehen: 

```text
├── Cargo.lock
├── Cargo.toml
├── adder
│   ├── Cargo.toml
│   └── src
│       └── main.rs
└── target
```

Der Arbeitsbereich verfügt auf der obersten Ebene über ein _Zielverzeichnis_
(target), in das die kompilierten Artefakte abgelegt werden; das Paket
`adder` hat kein eigenes _Zielverzeichnis_. Selbst wenn wir `cargo build` aus
dem Verzeichnis _adder_ heraus ausführen würden, landen die kompilierten
Artefakte noch immer in _add/target_ und nicht in _add/adder/target_. Cargo
strukturiert das _Zielverzeichnis_ in einem derartigen Arbeitsverzeichnis, da
die Kisten voneinander abhängig sein sollen. Wenn jede Kiste ihr eigenes
_Zielverzeichnis_ hätte, müssten für jede Kiste die anderen Kisten im
Arbeitsbereich neu kompiliert werden, damit die Artefakte ein eigenes
_Zielverzeichnis_ haben könnten. Durch die gemeinsame Nutzung eines
Verzeichnisses können die Kisten unnötig wiederholte Erstellung vermeiden.

### Erstellen des zweiten Pakets im Arbeitsbereich

Als Nächstes erstellen wir ein weiteres, dem Arbeitsbereich zugehöriges Paket
und nennen es `add_one`. Erzeuge eine neue Bibliothekskiste namens `add_one`:

```console
$ cargo new add_one --lib
    Created library `add_one` package
      Adding `add_one` as member of workspace at `file:///projects/add`
```

Die Datei _Cargo.toml_ auf der obersten Ebene enthält nun den Pfad _add_one_ in
der Liste `members`:

<span class="filename">Dateiname: Cargo.toml</span>

```toml
[workspace]
resolver = "3"
members = ["adder", "add_one"]
```

Dein Verzeichnis _add_ sollte nun so aussehen:

```text
├── Cargo.lock
├── Cargo.toml
├── add_one
│   ├── Cargo.toml
│   └── src
│       └── lib.rs
├── adder
│   ├── Cargo.toml
│   └── src
│       └── main.rs
└── target
```

Lass uns in der Datei _add_one/src/lib.rs_, eine Funktion `add_one` hinzufügen.

<span class="filename">Dateiname: add_one/src/lib.rs</span>

```rust,ignore
pub fn add_one(x: i32) -> i32 {
    x + 1
}
```

Nun können wir das `adder`-Paket von unserem `add_one`-Paket, das unsere
Bibliothek enthält, abhängig machen. Zuerst müssen wir _adder/Cargo.toml_ einen
Pfad zur Abhängigkeit von `add_one` hinzufügen.

<span class="filename">Dateiname: adder/Cargo.toml</span>

```toml
[dependencies]
add_one = { path = "../add_one" }
```

Cargo geht nicht davon aus, dass Kisten in einem Arbeitsbereich voneinander
abhängen, daher müssen wir die Abhängigkeit explizit angeben.

Als nächstes verwenden wir die Funktion `add_one` (aus der `add_one`-Kiste) in
der `adder`-Kiste. Öffne die Datei _adder/src/main.rs_ und ändere die Funktion
`main`, um die Funktion `add_one` aufzurufen, siehe Codeblock 14-7.

<span class="filename">Dateiname: adder/src/main.rs</span>

```rust,ignore
fn main() {
    let num = 10;
    println!("Hello, world! {num} plus one is {}!", add_one::add_one(num));
}
```

<span class="caption">Codeblock 14-7: Die `add_one`-Bibliothekskiste in der
Kiste `adder` verwenden</span>

Erstellen wir den Arbeitsbereich, indem wir `cargo build` im obersten
Verzeichnis _add_ ausführen!

 ```console
$ cargo build
   Compiling add_one v0.1.0 (file:///projects/add/add_one)
   Compiling adder v0.1.0 (file:///projects/add/adder)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.68s
```

Um die Binärkiste aus dem Verzeichnis _add_ auszuführen, können wir mithilfe
des Arguments `-p` und des Paketnamens mit `cargo run` angeben, welches Paket
im Arbeitsbereich ausgeführt werden soll:

```console
$ cargo run -p adder
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.0s
     Running `target/debug/adder`
Hello, world! 10 plus one is 11!
```

Dadurch wird der Programmcode in _adder/src/main.rs_ ausgeführt, der von der
Kiste `add_one` abhängt.

#### Abhängigkeiten zu externen Paketen

Beachte, dass der Arbeitsbereich nur eine Datei _Cargo.lock_ auf der obersten
Ebene enthält, anstatt einer in jeder Kiste. Dies stellt sicher, dass alle
Kisten dieselbe Version aller Abhängigkeiten verwenden. Wenn wir das Paket
`rand` zu den Dateien _adder/Cargo.toml_ und _add_one/Cargo.toml_ hinzufügen,
löst Cargo beide dieser Versionen zu einer auf und fügt diese in der
_Cargo.lock_-Datei hinzu. Wenn alle Kisten im Arbeitsbereich dieselben
Abhängigkeiten verwenden, sind die Kisten immer miteinander kompatibel. Lass
uns die Kiste `rand` in der Datei _add_one/Cargo.toml_ zum Abschnitt
`[dependencies]` hinzufügen, damit wir die Kiste `rand` in der Kiste `add_one`
verwenden können:

<span class="filename">Dateiname: add_one/Cargo.toml</span>

```toml
[dependencies]
rand = "0.8.5"
```

Wir können nun `use rand;` zur Datei _add_one/src/lib.rs_ hinzufügen, und wenn
du den gesamten Arbeitsbereich durch Ausführen von `cargo build` im Verzeichnis
_add_ erstellst, wird die Kiste `rand` eingefügt und kompiliert. Wir erhalten
eine Warnung, weil wir nicht auf `rand` referenzieren, das wir in den
Gültigkeitsbereich gebracht haben:

```console
$ cargo build
    Updating crates.io index
  Downloaded rand v0.8.5
   --abschneiden--
   Compiling rand v0.8.5
   Compiling add_one v0.1.0 (file:///projects/add/add_one)
warning: unused import: `rand`
 --> add_one/src/lib.rs:1:5
  |
1 | use rand;
  |     ^^^^
  |
  = note: `#[warn(unused_imports)]` on by default

warning: `add_one` (lib) generated 1 warning (run `cargo fix --lib -p add_one` to apply 1 suggestion)
   Compiling adder v0.1.0 (file:///projects/add/adder)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 10.18s
```

Die Datei _Cargo.lock_ der obersten Ebene enthält nun Informationen über die
Abhängigkeit von `add_one` von `rand`. Obwohl `rand` irgendwo im Arbeitsbereich
verwendet wird, können wir es nicht in anderen Kisten im Arbeitsbereich
verwenden, es sei denn, wir fügen `rand` zu ihren _Cargo.toml_-Dateien hinzu.
Wenn wir beispielsweise `use rand;` zur Datei _adder/src/main.rs_ für das Paket
`adder` hinzufügen, wird folgende Fehlermeldung angezeigt:


```console
$ cargo build
  --abschneiden--
   Compiling adder v0.1.0 (file:///projects/add/adder)
error[E0432]: unresolved import `rand`
 --> adder/src/main.rs:2:5
  |
2 | use rand;
  |     ^^^^ no external crate `rand`
```

Um dies zu beheben, bearbeiten wir die Datei _Cargo.toml_ für das Paket `adder`
und geben an, dass `rand` auch eine Abhängigkeit davon ist. Durch das Erstellen
des Pakets `adder` wird `rand` zur Liste der Abhängigkeiten für `adder` in
_Cargo.lock_ hinzugefügt, es werden jedoch keine zusätzlichen Kopien von `rand`
heruntergeladen. Cargo stellt sicher, dass jede Kiste in jedem Paket im
Arbeitsbereich, das das `rand`-Paket verwendet, die gleiche Version verwendet,
solange sie kompatible Versionen von `rand` angeben, was uns Platz spart und
sicherstellt, dass die Kisten im Arbeitsbereich miteinander kompatibel sind.

Wenn Kisten im Arbeitsbereich inkompatible Versionen der gleichen Abhängigkeit
angeben, löst Cargo jede von ihnen auf, versucht aber trotzdem, so wenige
Versionen wie möglich aufzulösen.

#### Hinzufügen eines Tests zu einem Arbeitsbereich

Füge für eine weitere Verbesserung innerhalb der `add_one`-Kiste einen Test der
Funktion `add_one::add_one` hinzu:

<span class="filename">Dateiname: add_one/src/lib.rs</span>

```rust
pub fn add_one(x: i32) -> i32 {
    x + 1
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        assert_eq!(3, add_one(2));
    }
}
```

Führen wir nun `cargo test` in der obersten Ebene im Verzeichnis _add_ aus. Die
Ausführung von `cargo test` in einem Arbeitsbereich, der wie dieser
strukturiert ist, führt die Tests für alle Kisten im Arbeitsbereich aus:

```console
$ cargo test
   Compiling add_one v0.1.0 (file:///projects/add/add_one)
   Compiling adder v0.1.0 (file:///projects/add/adder)
    Finished test [unoptimized + debuginfo] target(s) in 0.27s
     Running unittests src/lib.rs (target/debug/deps/add_one-f0253159197f7841)

running 1 test
test tests::it_works ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

     Running unittests src/main.rs (target/debug/deps/adder-49979ff40686fa8e)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

   Doc-tests add_one

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
```

Der erste Abschnitt der Ausgabe zeigt, dass der Test `it_works` in der Kiste
`add_one` bestanden wurde. Der nächste Abschnitt zeigt, dass in der Kiste
`adder` keine Tests gefunden wurden, und der letzte Abschnitt zeigt, dass in
der Kiste `add_one` keine Dokumentationstests gefunden wurden.

Wir können auch Tests für eine bestimmte Kiste in einem Arbeitsbereich aus dem
Verzeichnis der obersten Ebene ausführen, indem wir die Option `-p` verwenden
und den Namen der Kiste angeben, die wir testen möchten:

```console
$ cargo test -p add_one
    Finished test [unoptimized + debuginfo] target(s) in 0.00s
     Running unittests src/lib.rs (target/debug/deps/add_one-b3235fea9a156f74)

running 1 test
test tests::it_works ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

   Doc-tests add_one

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
```

Die Ausgabe zeigt, dass `cargo test` nur die Tests der Kiste `add_one` aber
nicht der Kiste `adder` ausgeführt hat.

Wenn du die Kisten im Arbeitsbereich unter [crates.io][crates] veröffentlichst,
muss jede Kiste im Arbeitsbereich separat veröffentlicht werden. Der Befehl
`cargo publish` hat keine Option `--all` oder `-p`, daher musst du in das
Verzeichnis jeder Kiste wechseln und `cargo publish` für jede Kiste im
Arbeitsbereich ausführen, um die Kisten zu veröffentlichen.

Als zusätzliche Übung, füge ähnlich der Kiste `add_one` diesem Arbeitsbereich
eine Kiste `add-two` hinzu!

Wenn dein Projekt wächst, solltest du einen Arbeitsbereich verwenden: Es
ermöglicht dir, mit kleineren, leichter zu verstehenden Komponenten zu arbeiten
als mit einem großen Klumpen von Code. Darüber hinaus kann die Verwaltung von
Kisten in einem Arbeitsbereich die Koordination zwischen Kisten erleichtern,
wenn sie häufig zur gleichen Zeit verändert werden.

[crates]: https://crates.io/
