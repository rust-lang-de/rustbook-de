## Steuern wie Tests ausgeführt werden

So wie `cargo run` deinen Code kompiliert und dann die resultierende Binärdatei
ausführt, kompiliert `cargo test` deinen Code im Testmodus und führt die
resultierende Testbinärdatei aus. Das Standardverhalten der von `cargo test`
erzeugten Binärdatei besteht darin, alle Tests parallel auszuführen und die
während der Testläufe generierte Ausgabe zu erfassen, wodurch verhindert wird,
dass die Ausgabe angezeigt wird, und das Lesen der Ausgabe bezüglich der
Testergebnisse erleichtert wird. Du kannst jedoch Kommandozeilen-Optionen
angeben, um dieses Standardverhalten zu ändern.

Einige Kommandozeilen-Optionen betreffen `cargo test` und einige betreffen die
resultierende Testbinärdatei. Um diese beiden Argumentarten
auseinanderzuhalten, gibst du zuerst die Argumente für `cargo test`, gefolgt
vom Trennzeichen `--`, und danach die der Testbinärdatei an. Wenn du `cargo
test --help` ausführst, werden die Optionen angezeigt, die du für `cargo test`
verwenden kannst, und wenn du `cargo test -- --help` ausführst, werden die
Optionen angezeigt, die du nach dem Trennzeichen verwenden kannst.

### Tests parallel oder nacheinander ausführen

Wenn du mehrere Tests ausführst, werden diese standardmäßig parallel in
Strängen (threads) ausgeführt, das bedeutet, dass die Tests schneller
abgeschlossen werden und du schneller Rückmeldung erhältst. Da die Tests
gleichzeitig ausgeführt werden, musst du sicherstellen, dass deine Tests nicht
voneinander oder von einem gemeinsam genutzten Zustand abhängen, einschließlich
einer gemeinsam genutzten Umgebung, z.B. dem aktuellen Arbeitsverzeichnis oder
Umgebungsvariablen.

Angenommen, jeder deiner Tests führt einen Code aus, der eine Datei auf der
Festplatte mit dem Namen *test-output.txt* erstellt und einige Daten in diese
Datei schreibt. Dann liest jeder Test Daten aus dieser Datei und stellt fest,
dass die Datei einen bestimmten Wert enthält, der bei jedem Test anders ist. Da
die Tests zur gleichen Zeit laufen, kann es vorkommen, dass ein Test die Datei
überschreibt, während ein anderer Test die Datei schreibt und liest. Der zweite
Test wird dann fehlschlagen, nicht weil der Code falsch ist, sondern weil sich
die Tests bei der parallelen Ausführung gegenseitig beeinflusst haben. Eine
Lösung besteht darin, dafür zu sorgen, dass jeder Test in eine eigene Datei
schreibt; eine andere Lösung besteht darin, die Tests einzeln nacheinander
auszuführen.

Wenn du die Tests nicht parallel ausführen möchtest oder wenn du eine
feingranularere Kontrolle über die Anzahl der verwendeten Stränge haben willst,
kannst du den Schalter `--test-threads` mit der Anzahl der Stränge, die du
verwenden möchtest, an die Testbinärdatei übergeben. Sieh dir das folgende
Beispiel an:

```console
$ cargo test -- --test-threads=1
```

Wir setzen die Anzahl der Teststränge auf `1` und weisen das Programm an, keine
Parallelität zu verwenden. Die Ausführung der Tests mit einem Strang dauert
länger als die parallele Ausführung, aber die Tests stören sich nicht
gegenseitig, wenn sie den gleichen Zustand verwenden.

### Anzeigen der Funktionsausgabe

Standardmäßig erfasst die Testbibliothek von Rust bei einem bestandenen Test
alles, was in die Standardausgabe ausgegeben wurde. Wenn wir beispielsweise
`println!` in einem Test aufrufen und der Test erfolgreich ist, sehen wir die
Ausgabe von `println!` im Terminal nicht; wir sehen nur die Zeile, die den
bestandenen Test anzeigt. Wenn ein Test fehlschlägt, sehen wir das, was in die
Standardausgabe ausgegeben wurde, mit dem Rest der Fehlermeldung.

Als Beispiel hat Codebock 11-10 eine dumme Funktion, die den Wert ihres
Parameters ausgibt und 10 zurückgibt, sowie einen Test, der bestanden wird, und
einen Test, der fehlschlägt.

<span class="filename">Dateiname: src/lib.rs</span>

```rust,panics,noplayground
fn prints_and_returns_10(a: i32) -> i32 {
    println!("Ich habe den Wert {} erhalten.", a);
    10
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn this_test_will_pass() {
        let value = prints_and_returns_10(4);
        assert_eq!(10, value);
    }

    #[test]
    fn this_test_will_fail() {
        let value = prints_and_returns_10(8);
        assert_eq!(5, value);
    }
}
```

<span class="caption">Codebock 11-10: Tests einer Funktion, die `println!`
aufruft</span>

Wenn wir diese Tests mit `cargo test` ausführen, werden wir folgende Ausgabe
sehen:

```console
$ cargo test
   Compiling silly-function v0.1.0 (file:///projects/silly-function)
    Finished test [unoptimized + debuginfo] target(s) in 0.58s
     Running unittests src/lib.rs (target/debug/deps/silly_function-160869f38cff9166)

running 2 tests
test tests::this_test_will_fail ... FAILED
test tests::this_test_will_pass ... ok

failures:

---- tests::this_test_will_fail stdout ----
Ich habe den Wert 8 erhalten.
thread 'tests::this_test_will_fail' panicked at src/lib.rs:19:9:
assertion `left == right` failed
  left: 5
 right: 10
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace


failures:
    tests::this_test_will_fail

test result: FAILED. 1 passed; 1 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

error: test failed, to rerun pass `--lib`
```

Beachte, dass wir nirgendwo in dieser Ausgabe `Ich habe den Wert 4 erhalten.`
sehen, was beim erfolgreichen Testlauf ausgegeben wird. Diese Ausgabe wurde
aufgefangen. Die Ausgabe `Ich habe den Wert 8 erhalten.` des fehlgeschlagenen
Tests erscheint im Abschnitt der Testzusammenfassung, der auch die Ursache des
Testfehlers anzeigt.

Wenn wir auch die ausgegebenen Werte der bestandenen Tests sehen wollen, können
wir Rust mit `--show-output` anweisen, die Ausgabe erfolgreicher Tests mit
anzuzeigen.

```console
$ cargo test -- --show-output
```

Wenn wir die Tests in Codeblock 11-10 mit dem Schalter `--show-output` erneut
ausführen, sehen wir folgende Ausgabe:

```console
$ cargo test -- --show-output
   Compiling silly-function v0.1.0 (file:///projects/silly-function)
    Finished test [unoptimized + debuginfo] target(s) in 0.60s
     Running unittests src/lib.rs (target/debug/deps/silly_function-160869f38cff9166)

running 2 tests
test tests::this_test_will_fail ... FAILED
test tests::this_test_will_pass ... ok

successes:

---- tests::this_test_will_pass stdout ----
Ich habe den Wert 4 erhalten.


successes:
    tests::this_test_will_pass

failures:

---- tests::this_test_will_fail stdout ----
Ich habe den Wert 8 erhalten.
thread 'tests::this_test_will_fail' panicked at src/lib.rs:19:9:
assertion `left == right` failed
  left: 5
 right: 10
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace


failures:
    tests::this_test_will_fail

test result: FAILED. 1 passed; 1 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

error: test failed, to rerun pass `--lib`
```

### Ausführen einer Test-Teilmenge mittels Name

Manchmal kann die Ausführung einer vollständigen Testsammlung sehr lange
dauern. Wenn du an Code in einem bestimmten Bereich arbeitest, solltest du
vielleicht nur die Tests ausführen, die diesen Code betreffen. Du kannst
wählen, welche Tests ausgeführt werden sollen, indem du `cargo test` den oder
die Namen der Tests, die du ausführen willst, als Argument übergibst.

Um zu demonstrieren, wie man eine Teilmenge von Tests ausführt, werden wir
zuerst drei Tests für unsere Funktion `add_two` erstellen, wie in Codeblock
11-11 zu sehen ist, und auswählen, welche wir ausführen wollen.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
pub fn add_two(a: i32) -> i32 {
    a + 2
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn add_two_and_two() {
        assert_eq!(4, add_two(2));
    }

    #[test]
    fn add_three_and_two() {
        assert_eq!(5, add_two(3));
    }

    #[test]
    fn one_hundred() {
        assert_eq!(102, add_two(100));
    }
}
```

<span class="caption">Codeblock 11-11: Drei Tests mit drei verschiedenen
Namen</span>

Wenn wir die Tests ohne Argumente durchführen, wie vorhin gesehen, werden alle
Tests parallel laufen:

```console
$ cargo test
   Compiling adder v0.1.0 (file:///projects/adder)
    Finished test [unoptimized + debuginfo] target(s) in 0.62s
     Running unittests src/lib.rs (target/debug/deps/adder-92948b65e88960b4)

running 3 tests
test tests::add_three_and_two ... ok
test tests::add_two_and_two ... ok
test tests::one_hundred ... ok

test result: ok. 3 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

   Doc-tests adder

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
```

#### Ausführen einzelner Tests

Wir können den Namen einer beliebigen Testfunktion an `cargo test` übergeben,
um nur diesen Test auszuführen:

```console
$ cargo test one_hundred
   Compiling adder v0.1.0 (file:///projects/adder)
    Finished test [unoptimized + debuginfo] target(s) in 0.69s
     Running unittests src/lib.rs (target/debug/deps/adder-92948b65e88960b4)

running 1 test
test tests::one_hundred ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 2 filtered out; finished in 0.00s
```

Nur der Test mit dem Namen `one_hundred` lief; die beiden anderen Tests passten
nicht zu diesem Namen. Die Testausgabe lässt uns wissen, dass wir mehrere Tests
hatten, als dieser Befehl ausgeführt wurde, indem am Ende der
Zusammenfassungszeile `2 filtered out` angezeigt wird.

Wir können die Namen mehrerer Tests nicht auf diese Weise angeben; es wird nur
der erste Wert verwendet, der bei `cargo test` angegeben wird. Aber es gibt
eine Möglichkeit, mehrere Tests auszuführen.

#### Filtern um mehrerer Tests auszuführen

Wir können einen Teil eines Testnamens angeben und jeder Test, dessen Name zu
diesem Wert passt, wird ausgeführt. Da zum Beispiel zwei der Namen unserer
Tests `add` enthalten, können wir diese beiden Tests ausführen, indem wir
`cargo test add` ausführen:

```console
$ cargo test add
   Compiling adder v0.1.0 (file:///projects/adder)
    Finished test [unoptimized + debuginfo] target(s) in 0.61s
     Running unittests src/lib.rs (target/debug/deps/adder-92948b65e88960b4)

running 2 tests
test tests::add_three_and_two ... ok
test tests::add_two_and_two ... ok

test result: ok. 2 passed; 0 failed; 0 ignored; 0 measured; 1 filtered out; finished in 0.00s
```

Dieser Befehl führte alle Tests mit `add` im Namen aus und filterte den Test
mit dem Namen `one_hundred` heraus. Beachte auch, dass das Modul, in dem sich
ein Test befindet, Teil des Testnamens wird, sodass wir alle Tests in einem
Modul ausführen können, indem wir nach dem Namen des Moduls filtern.

### Tests ignorieren, die nicht ausdrücklich verlangt werden

Manchmal kann die Ausführung einiger spezifischer Tests sehr zeitaufwendig
sein, sodass du diese bei den meisten `cargo test`-Aufrufen ausschließen
solltest. Anstatt alle Tests, die du ausführen möchtest, als Argumente
aufzulisten, kannst du die zeitaufwendigen Tests stattdessen mit dem Attribut
`ignore` annotieren, um sie auszuschließen, wie hier gezeigt: 

<span class="filename">Dateiname: src/lib.rs</span>

```rust,noplayground
#[test]
fn it_works() {
    assert_eq!(2 + 2, 4);
}

#[test]
#[ignore]
fn expensive_test() {
    // Code, dessen Ausführung eine Stunde dauert
}
```

Unterhalb `#[test]` fügen wir die Zeile `#[ignore]` beim Test ein, den wir
ausschließen wollen. Wenn wir nun unsere Tests ausführen, läuft `it_works`,
aber `expensive_test` nicht:

```console
$ cargo test
   Compiling adder v0.1.0 (file:///projects/adder)
    Finished test [unoptimized + debuginfo] target(s) in 0.60s
     Running unittests src/lib.rs (target/debug/deps/adder-92948b65e88960b4)

running 2 tests
test expensive_test ... ignored
test it_works ... ok

test result: ok. 1 passed; 0 failed; 1 ignored; 0 measured; 0 filtered out; finished in 0.00s

   Doc-tests adder

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
```

Die Funktion `expensive_test` wird als `ignored` aufgeführt. Wenn wir nur die
ignorierten Tests ausführen wollen, können wir `cargo test -- --ignored`
angeben:

```console
$ cargo test -- --ignored
   Compiling adder v0.1.0 (file:///projects/adder)
    Finished test [unoptimized + debuginfo] target(s) in 0.61s
     Running unittests src/lib.rs (target/debug/deps/adder-92948b65e88960b4)

running 1 test
test expensive_test ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 1 filtered out; finished in 0.00s

   Doc-tests adder

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
```

Indem du kontrollierst, welche Tests durchgeführt werden, kannst du
sicherstellen, dass dein `cargo test`-Aufruf schnell zu Ergebnissen führt. Wenn
du an einem Punkt angelangt bist, an dem es sinnvoll ist, die Ergebnisse der
`ignored`-Tests zu überprüfen, und du Zeit hast, auf die Ergebnisse zu warten,
kannst du stattdessen `cargo test -- --ignored` ausführen. Wenn du alle Tests
ausführen willst, egal ob sie ignoriert werden oder nicht, kannst du `cargo
test -- --include-ignored` ausführen.
