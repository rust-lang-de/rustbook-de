## Cargo-Arbeitsbereiche

In Kapitel 12 haben wir ein Paket erstellt, das eine binäre Kiste und eine
Bibliothekskiste enthält. Während dein Projekt entwickelt wird, wirst du
möglicherweise feststellen, dass die Bibliothekskiste immer größer wird und du
dein Paket weiter in mehrere Bibliothekskisten aufteilen möchtest. Cargo bietet
eine Funktion namens *Arbeitsbereiche* (workspaces), mit denen mehrere
verwandte Pakete verwaltet werden können, die gemeinsam entwickelt werden.

### Einen Arbeitsbereich erstellen

Ein *Arbeitsbereich* ist eine Reihe von Paketen, die dieselbe Datei
*Cargo.lock* sowie dasselbe Ausgabeverzeichnis (output directory) verwenden.
Lass uns mithilfe eines Arbeitsbereiches ein Projekt erstellen. Wir verwenden
einfachen Programmcode, damit wir uns auf die Struktur des Arbeitsbereiches
konzentrieren können. Es gibt verschiedene Möglichkeiten, einen Arbeitsbereich
zu strukturieren. Wir werden nur einen einen üblichen Weg zeigen. Wir haben
einen Arbeitsbereich mit einer Binärdatei und zwei Bibliotheken. Die Binärdatei
stellt die Hauptfunktion bereit und hängt von den beiden Bibliotheken ab. Eine
Bibliothek stellt die Funktion `add_one` und die andere `add_two` zur
Verfügung. Diese drei Kisten werden Teil desselben Arbeitsbereichs sein.
Zunächst erstellen wir ein neues Verzeichnis für den Arbeitsbereich:

```console
$ mkdir add
$ cd add
```

Als Nächstes erstellen wir im Verzeichnis *add* die Datei *Cargo.toml*, mit der
der gesamte Arbeitsbereich konfiguriert wird. Diese Datei enthält keine
Abschnitt `[package]`. Stattdessen beginnt sie mit einem Abschnitt
`[workspace]`, in dem wir Mitglieder zum Arbeitsbereich hinzufügen können,
indem wir den Pfad zum Paket mit unserer Binärkiste angeben. In diesem Fall
lautet dieser Pfad *adder*:

<span class="filename">Dateiname: Cargo.toml</span>

```toml
[workspace]

members = [
    "adder",
]
```

Als nächstes erstellen wir die Binärkiste `adder`, indem wir `cargo new` im
Verzeichnis *add* ausführen:

```console
$ cargo new adder
     Created binary (application) `adder` package
```

An dieser Stelle können wir den Arbeitsbereich erstellen, indem wir `cargo build`
ausführen. Die Dateien in deinem *add*-Verzeichnis sollten folgendermaßen
aussehen: 

```text
├── Cargo.lock
├── Cargo.toml
├── adder
│   ├── Cargo.toml
│   └── src
│       └── main.rs
└── target
```

Der Arbeitsbereich verfügt auf der obersten Ebene über ein *Zielverzeichnis* 
(target), in das die kompilierten Artefakte abgelegt werden; das Paket
`adder` hat kein eigenes *Zielverzeichnis*. Selbst wenn wir `cargo build` aus
dem Verzeichnis *adder* heraus ausführen würden, landen die kompilierten
Artefakte noch immer in *add/target* und nicht in *add/adder/target*. Cargo
strukturiert das *Zielverzeichnis* in einem derartigen Arbeitsverzeichnis, da
die Kisten voneinander abhängig sein sollen. Wenn jede Kiste ihr eigenes
*Zielverzeichnis* hätte, müssten für jede Kiste die anderen Kisten im
Arbeitsbereich neu kompiliert werden, damit die Artefakte ein eigenes
*Zielverzeichnis* haben könnten. Durch die gemeinsame Nutzung eines
Verzeichnisses können die Kisten unnötig wiederholte Erstellung vermeiden.

### Erstellen des zweiten Pakets im Arbeitsbereich

Als Nächstes erstellen wir ein weiteres, dem Arbeitsbereich zugehöriges Paket
und nennen es `add_one`. Ändere die auf der obersten Ebene befindliche Datei
*Cargo.toml* um den *add_one*-Pfad in der Mitgliederliste anzugeben:

<span class="filename">Dateiname: Cargo.toml</span>

```toml
[workspace]

members = [
    "adder",
    "add_one",
]
```
Dann erzeuge eine neue Bibliothekskiste namens `add_one`:

```console
$ cargo new add_one --lib
     Created library `add_one` package
```

Dein *add*-Verzeichnis sollte nun so aussehen:

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

Lass uns in der Datei *add_one/src/lib.rs*, eine Funktion `add_one` hinzufügen.

<span class="filename">Dateiname: add_one/src/lib.rs</span>

```rust
pub fn add_one(x: i32) -> i32 {
    x + 1
}
```

Nun können wir das `adder`-Paket von unserem `add_one`-Paket, das unsere
Bibliothek enthält, abhängig machen. Zuerst müssen wir *adder/Cargo.toml*
einen Pfad zur Abhängigkeit von `add_one` hinzufügen.

<span class="filename">Dateiname: adder/Cargo.toml</span>

```toml
[dependencies]

add_one = { path = "../add_one" }
```

Cargo geht nicht davon aus, dass Kisten in einem Arbeitsbereich voneinander
abhängen, daher müssen wir die Abhängigkeit explizit angeben.

Als nächstes verwenden wir die Funktion `add_one` (aus der `add_one`-Kiste) in
der `adder`-Kiste. Öffne die Datei *adder/src/main.rs* und füge oben eine Zeile
`use` hinzu, um die neue Bibliothekskiste `add_one` in den Gültigkeitsbereich
(scope) zu bringen. Ändere dann die Funktion `main`, um die Funktion `add_one`
aufzurufen, siehe Codeblock 14-7.

<span class="filename">Dateiname: adder/src/main.rs</span>

```rust,ignore
use add_one;

fn main() {
    let num = 10;
    println!(
        "Hello, world! {} plus one is {}!",
        num,
        add_one::add_one(num)
    );
}
```

<span class="caption">Codeblock 14-7: Die `add_one`-Bibliothekskiste aus der 
`adder`-Kiste verwenden</span>

Erstellen wir den Arbeitsbereich, indem wir `cargo build` im obersten
Verzeichnis *add* ausführen!

 ```console
$ cargo build
   Compiling add_one v0.1.0 (file:///projects/add/add_one)
   Compiling adder v0.1.0 (file:///projects/add/adder)
    Finished dev [unoptimized + debuginfo] target(s) in 0.68s
```

Um die Binärkiste aus dem Verzeichnis *add* auszuführen, können wir mithilfe des
Arguments `-p` und des Paketnamens mit `cargo run` angeben, welches Paket im
Arbeitsbereich ausgeführt werden soll:

```console
$ cargo run -p adder
    Finished dev [unoptimized + debuginfo] target(s) in 0.0s
     Running `target/debug/adder`
Hello, world! 10 plus one is 11!
```

Dadurch wird der Programmcode in *adder/src/main.rs* ausgeführt, der von der
Kiste `add_one` abhängt.

#### Abhängigkeiten zu externen Paketen in einem Arbeitsbereich

Beachte, dass der Arbeitsbereich nur eine *Cargo.lock*-Datei auf der obersten
Ebene enthält, anstatt einer in jeder Kiste. Dies stellt sicher, dass alle
Kisten dieselbe Version aller Abhängigkeiten verwenden. Wenn wir das Paket
`rand` zu den Dateien *adder/Cargo.toml* und *add_one/Cargo.toml* hinzufügen,
löst Cargo beide dieser Versionen zu einer auf und fügt diese in der
*Cargo.lock*-Datei hinzu. Wenn alle Kisten im Arbeitsbereich dieselben
Abhängigkeiten verwenden, sind die Kisten immer miteinander kompatibel. Lass
uns die `rand`-Kiste in der Datei *add_one/Cargo.toml* zum Abschnitt
`[dependencies]` hinzufügen, damit wir die Kiste `rand` in der `add_one`-Kiste
verwenden können:

<span class="filename">Dateiname: add_one/Cargo.toml</span>

```toml
[dependencies]
rand = "0.8.3"
```

Wir können nun `use rand;` zur Datei *add_one/src/lib.rs* hinzufügen, und wenn
du den gesamten Arbeitsbereich durch Ausführen von `cargo build` im Verzeichnis
*add* erstellst, wird die Kiste `rand` eingefügt und kompiliert. Wir erhalten
eine Warnung, weil wir nicht auf `rand` referenzieren, das wir in den
Gültigkeitsbereich gebracht haben:

```console
$ cargo build
    Updating crates.io index
  Downloaded rand v0.8.3
   --abschneiden--
   Compiling rand v0.8.3
   Compiling add_one v0.1.0 (file:///projects/add/add_one)
warning: unused import: `rand`
 --> add_one/src/lib.rs:1:5
  |
1 | use rand;
  |     ^^^^
  |
  = note: `#[warn(unused_imports)]` on by default

warning: 1 warning emitted

   Compiling adder v0.1.0 (file:///projects/add/adder)
    Finished dev [unoptimized + debuginfo] target(s) in 10.18s
```

Die *Cargo.lock*-Datei der obersten Ebene enthält nun Informationen über die
Abhängigkeit von `add_one` von `rand`. Obwohl `rand` irgendwo im Arbeitsbereich
verwendet wird, können wir es nicht in anderen Kisten im Arbeitsbereich
verwenden, es sei denn, wir fügen `rand` zu ihren *Cargo.toml*-Dateien hinzu.
Wenn wir beispielsweise `use rand;` zur Datei *adder/src/main.rs* für das Paket
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

Um dies zu beheben, bearbeiten wir die Datei *Cargo.toml* für das Paket `adder`
und geben an, dass `rand` auch eine Abhängigkeit davon ist. Durch das Erstellen
des Pakets `adder` wird `rand` zur Liste der Abhängigkeiten für `adder` in
*Cargo.lock* hinzugefügt, es werden jedoch keine zusätzlichen Kopien von `rand`
heruntergeladen. Cargo hat dafür gesorgt, dass jede Kiste in jedem Paket im
Arbeitsbereich, das das `rand`-Paket verwendet, die gleiche Version verwendet,
was uns Platz spart und sicherstellt, dass die Kisten im Arbeitsbereich
miteinander kompatibel sind.

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

Führen wir nun `cargo test` in der obersten Ebene im Verzeichnis *add* aus. Die
Ausführung von `cargo test` in einem Arbeitsbereich, der wie dieser
strukturiert ist, führt die Tests für alle Kisten im Arbeitsbereich aus:

```console
$ cargo test
   Compiling add_one v0.1.0 (file:///projects/add/add_one)
   Compiling adder v0.1.0 (file:///projects/add/adder)
    Finished test [unoptimized + debuginfo] target(s) in 0.27s
     Running target/debug/deps/add_one-f0253159197f7841

running 1 test
test tests::it_works ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out

     Running target/debug/deps/adder-49979ff40686fa8e

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out

   Doc-tests add_one

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out
```

Der erste Abschnitt der Ausgabe zeigt, dass der Test `it_works` in der
`add_one`-Kiste bestanden wurde. Der nächste Abschnitt zeigt, dass in der Kiste
`adder` keine Tests gefunden wurden, und der letzte Abschnitt zeigt, dass in der
Kiste `add_one` keine Dokumentationstests gefunden wurden.

Wir können auch Tests für eine bestimmte Kiste in einem Arbeitsbereich aus dem
Verzeichnis der obersten Ebene ausführen, indem wir die Option `-p` verwenden und
den Namen der Kiste angeben, die wir testen möchten:

```console
$ cargo test -p add_one
    Finished test [unoptimized + debuginfo] target(s) in 0.00s
     Running target/debug/deps/add_one-b3235fea9a156f74

running 1 test
test tests::it_works ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out

   Doc-tests add_one

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out
```

Die Ausgabe zeigt, dass `cargo test` nur die Tests für die Kiste `add_one` aber
nicht die `adder`-Tests ausgeführt hat.

Wenn du die Kisten im Arbeitsbereich unter [crates.io](https://crates.io/)
veröffentlichst, muss jede Kiste im Arbeitsbereich separat veröffentlicht
werden. Der Befehl `cargo publish` hat kein Flag `--all` oder `-p`, daher musst
du in das Verzeichnis jeder Kiste wechseln und `cargo publish` auf jeder Kiste
im Arbeitsbereich ausführen, um die Kisten zu veröffentlichen.

Als zusätzliche Übung, füge ähnlich der Kiste `add_one` diesem Arbeitsbereich
eine `add-two`-Kiste hinzu!

Wenn dein Projekt wächst, solltest du einen Arbeitsbereich verwenden, es ist
einfacher kleinere, einzelne Komponenten zu verstehen, als ein großes
Programmcode-Objekt. Darüber hinaus kann die Verwaltung von Kisten in einem
Arbeitsbereich die Koordination zwischen Kisten erleichtern, wenn sie häufig
zur gleichen Zeit verändert werden.
