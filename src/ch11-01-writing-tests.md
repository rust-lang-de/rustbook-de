## Tests schreiben

Tests sind Funktionen in Rust, die überprüfen, ob der zu testende Code in der
erwarteten Weise funktioniert. Der Rumpf von Testfunktionen führt in der Regel
diese drei Aktionen aus:

1. Bereite die benötigten Daten und Zustände vor.
2. Führe den Code aus, den du testen möchtest.
3. Stelle sicher, dass die Ergebnisse das sind, was du erwartest.

Schauen wir uns die Funktionalität an, die Rust speziell für das Schreiben von
Tests bereitstellt, die diese Aktionen ausführen. Dazu gehören das Attribut
`test`, einige Makros und das Attribut `hould_panic`.

### Anatomie einer Testfunktion

Im einfachsten Fall ist ein Test in Rust eine Funktion, die mit dem Attribut
`test` annotiert wird. Attribute sind Metadaten über Teile des Rust-Codes; ein
Beispiel ist das Attribut `derive`, das wir in Kapitel 5 bei Strukturen
verwendet haben. Um eine Funktion in eine Testfunktion zu verwandeln, füge
`#[test]` oberhalb der Zeile mit `fn` ein. Wenn du deine Tests mit dem Befehl
`cargo test` ausführst, erstellt Rust eine Testausführungs-Binärdatei (test
runner binary), die die mit dem Attribut `test` annotierten Funktionen ausführt
und darüber berichtet, ob jede Testfunktion erfolgreich war oder nicht.
                                           
Wenn wir ein neues Bibliotheksprojekt mit Cargo durchführen, wird für uns
automatisch ein Testmodul mit einer Testfunktion darin generiert. Dieses Modul
hilft dir, mit dem Schreiben deiner Tests zu beginnen, sodass du nicht jedes
Mal, wenn du ein neues Projekt startest, die genaue Struktur und Syntax der
Testfunktionen nachschlagen musst. Du kannst so viele zusätzliche
Testfunktionen und Testmodule hinzufügen, wie du möchtest!
                                   
Wir werden einige Aspekte der Funktionsweise von Tests untersuchen, indem wir
mit der für uns generierten Testvorlage experimentieren, ohne tatsächlich Code
zu testen. Dann schreiben wir einige Tests aus der realen Welt, die einen von
uns geschriebenen Code aufrufen und sicherstellen, dass sein Verhalten korrekt
ist.
           
Lass uns ein neues Bibliotheksprojekt namens `adder` erstellen:

```console
$ cargo new adder --lib
     Created library `adder` project
$ cd adder
```

Der Inhalt der Datei *src/lib.rs* in deiner Bibliothek `adder` sollte wie
Codeblock 11-1 aussehen.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        assert_eq!(2 + 2, 4);
    }
}
#
# fn main() {}
```

<span class="caption">Codeblock 11-1: Das Testmodul und die Funktion, die
automatisch von `cargo new` generiert werden</span>

Ignorieren wir vorerst die beiden oberen Zeilen und konzentrieren uns auf die
Funktion, um zu sehen, wie sie funktioniert. Beachte die Annotation `#[test]`
oberhalb der Zeile mit `fn`: Dieses Attribut zeigt an, dass es sich um eine
Testfunktion handelt, sodass die Testausführung weiß, dass es diese Funktion
als einen Test behandeln soll. Wir könnten auch Nicht-Test-Funktionen im Modul
`tests` haben, um gängige Szenarien aufzusetzen oder gängige Operationen
durchzuführen, daher müssen wir mit dem Attribut `#[test]` angeben, welche
Funktionen Tests sind.

Der Funktionsrumpf verwendet das Makro `assert_eq!`, um sicherzustellen, dass 2
+ 2 gleich 4 ist. Diese Prüfung dient als Beispiel für den Aufbau eines
typischen Tests. Lassen wir ihn laufen, um zu sehen, dass dieser Test
erfolgreich ist.

Das Kommando `cargo test` führt alle Tests in unserem Projekt aus, wie in
Codeblock 11-2 zu sehen ist.

```console
$ cargo test
   Compiling adder v0.1.0 (file:///projects/adder)
    Finished test [unoptimized + debuginfo] target(s) in 0.57s
     Running target/debug/deps/adder-92948b65e88960b4

running 1 test
test tests::it_works ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out

   Doc-tests adder

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out
```

<span class="caption">Codeblock 11-2: Ergebnis der Ausführung des automatisch
generierten Tests</span>

Cargo hat den Test kompiliert und ausgeführt. Nach den Zeilen `Compiling`,
`Finished` und `Running` folgt die Zeile `running 1 test`. Die nächste Zeile
zeigt den Namen der generierten Testfunktion `it_works` und das Ergebnis der
Testausführung: `ok`. Als nächstes wird die Gesamtzusammenfassung der
Testausführung angegeben. Der Text `test result: ok.` bedeutet, dass alle Tests
bestanden wurden, und der Teil `1 passed; 0 failed` gibt die Anzahl der Tests
an, die bestanden oder nicht bestanden wurden.

Da wir keine Tests haben, die wir als ignoriert markiert haben, zeigt die
Zusammenfassung `0 ignored`. Wir haben zudem die auszuführenden Tests nicht
gefiltert, sodass am Ende der Zusammenfassung `0 filtered out` steht. Wir
werden das Ignorieren und Herausfiltern von Tests im nächsten Abschnitt,
[„Steuern wie Tests ausgeführt werden“][controlling-how-tests-are-run],
besprechen.

Die Statistik `0 measured` ist für Benchmark-Tests, die die Performanz messen.
Benchmark-Tests sind zum Zeitpunkt, als dieser Text verfasst wurde, nur im
nächtlichen (nightly) Rust verfügbar. Siehe [„Dokumentation über
Benchmark-Tests“][bench], um mehr zu erfahren.

[bench]: https://doc.rust-lang.org/unstable-book/library-features/test.html

Der nächste Teil der Testausgabe, der mit `Doc-tests adder` beginnt, ist für
die Ergebnisse von Dokumentationstests. Wir haben noch keine
Dokumentationstests, aber Rust kann alle Code-Beispiele kompilieren, die in
unserer API-Dokumentation erscheinen. Diese Funktionalität hilft uns dabei,
unsere Dokumentation und unseren Code synchron zu halten! Wie man
Dokumentationstests schreibt, werden wir im Abschnitt
[„Dokumentationskommentare als Tests“][doc-comments] in Kapitel 14 besprechen.
Vorerst ignorieren wir die Ausgabe von `Doc-tests`.

Lass uns den Namen unseres Tests ändern, um zu sehen, wie sich dadurch die
Testausgabe ändert. Ändere die Funktion `it_works` auf einen anderen Namen,
z.B. `exploration`, etwa so:

<span class="filename">Dateiname: src/lib.rs</span>

```rust
#[cfg(test)]
mod tests {
    #[test]
    fn exploration() {
        assert_eq!(2 + 2, 4);
    }
}
#
# fn main() {}
```

Dann führe `cargo test` erneut aus. Die Ausgabe zeigt nun `exploration`
anstelle von `it_works`:

```console
$ cargo test
   Compiling adder v0.1.0 (file:///projects/adder)
    Finished test [unoptimized + debuginfo] target(s) in 0.59s
     Running target/debug/deps/adder-92948b65e88960b4

running 1 test
test tests::exploration ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out

   Doc-tests adder

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out
```

Fügen wir einen weiteren Test hinzu, aber dieses Mal machen wir einen Test, der
fehlschlägt! Tests schlagen fehl, wenn etwas die Testfunktion zum Abbrechen
bringt. Jeder Test wird in einem neuen Strang (thread) ausgeführt und wenn der
Hauptstrang (main thread) sieht, dass ein Teststrang (test thread) gestorben
ist, wird der Test als fehlgeschlagen markiert. Über den einfachsten Weg, ein
Programm abzubrechen, sprachen wir in Kapitel 9, und zwar durch den Aufruf des
Makros `panic!`. Erstelle einen neuen Test `another`, sodass deine Datei
*src/lib.rs* wie in Codeblock 11-3 aussieht.

<span class="filename">Dateiname: src/lib.rs</span>

```rust,panics
#[cfg(test)]
mod tests {
    #[test]
    fn exploration() {
        assert_eq!(2 + 2, 4);
    }

    #[test]
    fn another() {
        panic!("Lasse diesen Test fehlschlagen");
    }
}
#
# fn main() {}
```

<span class="caption">Codeblock 11-3: Hinzufügen eines zweiten Tests, der
fehlschlägt, weil wir das Makro `panic!` aufrufen</span>

Führe die Tests erneut mit `cargo test` aus. Die Ausgabe sollte wie in
Codeblock 11-4 aussehen, was zeigt, dass unser Test `exploration` bestanden und
`another` fehlgeschlagen ist.

```console
$ cargo test
   Compiling adder v0.1.0 (file:///projects/adder)
    Finished test [unoptimized + debuginfo] target(s) in 0.72s
     Running target/debug/deps/adder-92948b65e88960b4

running 2 tests
test tests::another ... FAILED
test tests::exploration ... ok

failures:

---- tests::another stdout ----
thread 'main' panicked at 'Lasse diesen Test fehlschlagen', src/lib.rs:10:9
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace.

failures:
    tests::another

test result: FAILED. 1 passed; 1 failed; 0 ignored; 0 measured; 0 filtered out

error: test failed, to rerun pass '--lib'
```

<span class="caption">Codeblock 11-4: Testergebnisse, wenn ein Test bestanden
und ein Test nicht bestanden wird</span>

Statt `ok` zeigt die Zeile `test tests::another` das Ergebnis `FAILED`.
Zwischen den Einzelergebnissen und der Zusammenfassung erscheinen zwei neue
Abschnitte: Der erste Abschnitt zeigt die detaillierte Ursache für jeden
fehlgeschlagenen Test an. In diesem Fall scheiterte `another` mit der Meldung
`panicked at 'Lasse diesen Test fehlschlagen'` in Zeile 10 der Datei
*src/lib.rs*. Der nächste Abschnitt listet nur die Namen aller fehlgeschlagenen
Tests auf, was nützlich ist, wenn es viele Tests und viele detaillierte
Ausgaben von fehlgeschlagenen Tests gibt. Wir können den Namen eines
fehlgeschlagenen Tests verwenden, um genau diesen Test auszuführen, um ihn
leichter zu debuggen; wir werden im Abschnitt [„Steuern wie Tests ausgeführt
werden“][controlling-how-tests-are-run] mehr über Möglichkeiten zur Ausführung
von Tests sprechen.

Die Zusammenfassungszeile zeigt am Ende an: Insgesamt ist unser Testergebnis
`FAILED`. Wir hatten einen Test bestanden und einen Test nicht bestanden.

Da du nun gesehen hast, wie die Testergebnisse in verschiedenen Szenarien
aussehen, wollen wir uns einige Makros neben `panic!` ansehen, die bei Tests
nützlich sind.

### Ergebnisse überprüfen mit dem Makro `assert!`

Das Makro `assert!`, das von der Standardbibliothek bereitgestellt wird, ist
nützlich, wenn du sicherstellen willst, dass eine Bedingung in einem Test als
wahr (true) bewertet wird. Wir geben dem Makro `assert!` ein Argument, das
boolesch ausgewertet wird. Wenn der Wert `true` ist, tut `assert!` nichts und
der Test ist bestanden. Wenn der Wert `false` ist, ruft das Makro `assert!` das
Makro `panic!` auf, wodurch der Test fehlschlägt. Das Verwenden des Makros
`assert!` hilft uns zu überprüfen, ob unser Code so funktioniert, wie wir es
beabsichtigen.

In Codeblock 5-15 in Kapitel 5 haben wir eine Struktur `Rectangle` und eine
Methode `can_hold` verwendet, die hier in Codeblock 11-5 wiederholt werden.
Lass uns diesen Code in die Datei *src/lib.rs* packen und einige Tests dafür
mit dem Makro `assert!` schreiben.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32,
}

impl Rectangle {
    fn can_hold(&self, other: &Rectangle) -> bool {
        self.width > other.width && self.height > other.height
    }
}
#
# fn main() {}
```

<span class="caption">Codeblock 11-5: Verwenden der Struktur `Rectangle` und
ihrer Methode `can_hold` aus Kapitel 5</span>

Die Methode `can_hold` gibt ein Boolean zurück, was bedeutet, dass es ein
perfekter Anwendungsfall für das Makro `assert!` ist. In Codeblock 11-6
schreiben wir einen Test, der die Methode `can_hold` überprüft, indem wir eine
`Rectangle`-Instanz mit einer Breite von 8 und einer Höhe von 7 erstellen und
sicherstellen, dass es eine weitere `Rectangle`-Instanz mit einer Breite von 5
und einer Höhe von 1 enthalten kann.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
#[derive(Debug)]
# struct Rectangle {
#     width: u32,
#     height: u32,
# }
#
# impl Rectangle {
#     fn can_hold(&self, other: &Rectangle) -> bool {
#         self.width > other.width && self.height > other.height
#     }
# }
#
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn larger_can_hold_smaller() {
        let larger = Rectangle {
            width: 8,
            height: 7,
        };
        let smaller = Rectangle {
            width: 5,
            height: 1,
        };

        assert!(larger.can_hold(&smaller));
    }
}
#
# fn main() {}
```

<span class="caption">Codeblock 11-6: Ein Test für `can_hold`, der prüft, ob in
ein größeres Rechteck tatsächlich ein kleineres Rechteck passt</span>

Beachte, dass wir eine neue Zeile innerhalb des Moduls `tests` hinzugefügt
haben: `use super::*;`. Das Modul `tests` ist ein reguläres Modul, das den
üblichen Sichtbarkeitsregeln folgt, die wir in Kapitel 7 im Abschnitt [„Mit
Pfaden auf ein Element im Modulbaum
verweisen“][paths-for-referring-to-an-item-in-the-module-tree] behandelt haben.
Da das Modul `tests` ein inneres Modul ist, müssen wir den Code, der im äußeren
Modul getestet wird, in den Gültigkeitsbereich des inneren Moduls bringen. Wir
verwenden hier einen Stern (glob), sodass alles, was wir im äußeren Modul
definieren, auch in diesem Modul `tests` zur Verfügung steht.

Wir haben unseren Test `larger_can_hold_smaller` genannt und wir haben die
beiden `Rectangle`-Instanzen erzeugt, die wir benötigen. Dann haben wir das
Makro `assert!` aufgerufen und ihm das Aufrufergebnis von
`larger.can_hold(&smaller)` übergeben. Dieser Ausdruck soll `true` zurückgeben,
also sollte unser Test erfolgreich sein. Lass es uns herausfinden!

```console
$ cargo test
   Compiling rectangle v0.1.0 (file:///projects/rectangle)
    Finished test [unoptimized + debuginfo] target(s) in 0.66s
     Running target/debug/deps/rectangle-6584c4561e48942e

running 1 test
test tests::larger_can_hold_smaller ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out

   Doc-tests rectangle

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out
```

Es funktioniert! Fügen wir noch einen weiteren Test hinzu, diesmal mit der
Zusicherung, dass ein kleineres Rechteck nicht in ein größeres Rechteck passt:

<span class="filename">Dateiname: src/lib.rs</span>

```rust
#[derive(Debug)]
# struct Rectangle {
#     width: u32,
#     height: u32,
# }
#
# impl Rectangle {
#     fn can_hold(&self, other: &Rectangle) -> bool {
#         self.width > other.width && self.height > other.height
#     }
# }
#
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn larger_can_hold_smaller() {
        // --abschneiden--
#         let larger = Rectangle {
#             width: 8,
#             height: 7,
#         };
#         let smaller = Rectangle {
#             width: 5,
#             height: 1,
#         };
#
#         assert!(larger.can_hold(&smaller));
    }

    #[test]
    fn smaller_cannot_hold_larger() {
        let larger = Rectangle {
            width: 8,
            height: 7,
        };
        let smaller = Rectangle {
            width: 5,
            height: 1,
        };

        assert!(!smaller.can_hold(&larger));
    }
}
#
# fn main() {}
```

Da das korrekte Ergebnis der Funktion `can_hold` in diesem Fall `false` ist,
müssen wir dieses Ergebnis negieren, bevor wir es an das Makro `assert!`
übergeben. Als Ergebnis wird unser Test bestehen, wenn `can_hold` den
Rückgabewert `false` hat:

```console
$ cargo test
   Compiling rectangle v0.1.0 (file:///projects/rectangle)
    Finished test [unoptimized + debuginfo] target(s) in 0.66s
     Running target/debug/deps/rectangle-6584c4561e48942e

running 2 tests
test tests::larger_can_hold_smaller ... ok
test tests::smaller_cannot_hold_larger ... ok

test result: ok. 2 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out

   Doc-tests rectangle

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out
```

Zwei Tests, die erfolgreich sind! Nun wollen wir sehen, was mit unseren
Testergebnissen passiert, wenn wir einen Fehler in unseren Code einbringen.
Lass uns die Implementierung der Methode `can_hold` ändern, indem wir das
größer-als-Zeichen durch ein kleiner-als-Zeichen ersetzen, wenn sie die Breiten
vergleicht:

```rust,not_desired_behavior
# #[derive(Debug)]
# struct Rectangle {
#     width: u32,
#     height: u32,
# }
#
// --abschneiden--
impl Rectangle {
    fn can_hold(&self, other: &Rectangle) -> bool {
        self.width < other.width && self.height > other.height
    }
}
#
# #[cfg(test)]
# mod tests {
#     use super::*;
#
#     #[test]
#     fn larger_can_hold_smaller() {
#         let larger = Rectangle {
#             width: 8,
#             height: 7,
#         };
#         let smaller = Rectangle {
#             width: 5,
#             height: 1,
#         };
#
#         assert!(larger.can_hold(&smaller));
#     }
#
#     #[test]
#     fn smaller_cannot_hold_larger() {
#         let larger = Rectangle {
#             width: 8,
#             height: 7,
#         };
#         let smaller = Rectangle {
#             width: 5,
#             height: 1,
#         };
#
#         assert!(!smaller.can_hold(&larger));
#     }
# }
#
# fn main() {}
```

Das Ausführen der Tests ergibt nun Folgendes:

```console
$ cargo test
   Compiling rectangle v0.1.0 (file:///projects/rectangle)
    Finished test [unoptimized + debuginfo] target(s) in 0.66s
     Running target/debug/deps/rectangle-6584c4561e48942e

running 2 tests
test tests::larger_can_hold_smaller ... FAILED
test tests::smaller_cannot_hold_larger ... ok

failures:

---- tests::larger_can_hold_smaller stdout ----
thread 'main' panicked at 'assertion failed: larger.can_hold(&smaller)', src/lib.rs:28:9
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace.


failures:
    tests::larger_can_hold_smaller

test result: FAILED. 1 passed; 1 failed; 0 ignored; 0 measured; 0 filtered out

error: test failed, to rerun pass '--lib'
```

Unsere Tests haben den Fehler entdeckt! Da `larger.width` gleich 8 ist und
`smaller.width` gleich 5, ergibt der Vergleich der Breiten in `can_hold` jetzt
`false`: 8 ist nicht weniger als 5.

### Prüfung auf Gleichheit mit den Makros `assert_eq!` und `assert_ne!`

Eine übliche Methode zum Testen der Funktionalität besteht darin, das Ergebnis
des zu testenden Codes mit dem Wert zu vergleichen, den du vom Code erwartest,
um sicherzustellen, dass sie gleich sind. Du könntest dies mit dem Makro
`assert!` tun und ihm einen Ausdruck mit dem Operator `==` übergeben. Dies ist
jedoch ein so häufiger Testfall, dass die Standardbibliothek zwei Makros zur
Verfügung stellt, um diesen Test bequemer durchzuführen: `assert_eq!` und
`assert_ne!`. Diese Makros vergleichen zwei Argumente auf Gleichheit bzw.
Ungleichheit. Sie geben auch die beiden Werte aus, wenn die Zusicherung
fehlschlägt, was es einfacher macht zu erkennen, *warum* der Test
fehlgeschlagen ist; umgekehrt zeigt das Makro `assert!` nur an, dass der
Ausdruck `==` den Wert `false` ergeben hat, nicht die Werte, die zum falschen
Testergebnis führen.

In Codeblock 11-7 schreiben wir eine Funktion namens `add_two`, die zu ihrem
Parameter `2` addiert und das Ergebnis zurückgibt. Dann testen wir diese
Funktion mit dem Makro `assert_eq!`.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
pub fn add_two(a: i32) -> i32 {
    a + 2
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_adds_two() {
        assert_eq!(4, add_two(2));
    }
}
#
# fn main() {}
```

<span class="caption">Codeblock 11-7: Testen der Funktion `add_two` mit dem
Makro `assert_eq!`</span>

Lass uns prüfen, ob sie den Test besteht!

```console
$ cargo test
   Compiling adder v0.1.0 (file:///projects/adder)
    Finished test [unoptimized + debuginfo] target(s) in 0.58s
     Running target/debug/deps/adder-92948b65e88960b4

running 1 test
test tests::it_adds_two ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out

   Doc-tests adder

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out
```

Das erste Argument `4`, das wir dem Makro `assert_eq!` übergeben haben, ist
identisch mit dem Ergebnis des Aufrufs `add_two(2)`. Die Zeile für diesen Test
lautet `test tests::it_adds_two ... ok`, und der Text `ok` zeigt an, dass unser
Test bestanden wurde!

Lass uns einen Fehler in unseren Code einbringen, um zu sehen, wie es aussieht,
wenn ein Test, der `assert_eq!` verwendet, fehlschlägt. Ändern wir die
Implementierung der Funktion `add_two`, sodass sie stattdessen `3` addiert:

```rust,not_desired_behavior
pub fn add_two(a: i32) -> i32 {
    a + 3
}

# #[cfg(test)]
# mod tests {
#     use super::*;
#
#     #[test]
#     fn it_adds_two() {
#         assert_eq!(4, add_two(2));
#     }
# }
#
# fn main() {}
```

Führe die Tests erneut aus:

```console
$ cargo test
   Compiling adder v0.1.0 (file:///projects/adder)
    Finished test [unoptimized + debuginfo] target(s) in 0.61s
     Running target/debug/deps/adder-92948b65e88960b4

running 1 test
test tests::it_adds_two ... FAILED

failures:

---- tests::it_adds_two stdout ----
thread 'main' panicked at 'assertion failed: `(left == right)`
  left: `4`,
 right: `5`', src/lib.rs:11:9
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace.

failures:
    tests::it_adds_two

test result: FAILED. 0 passed; 1 failed; 0 ignored; 0 measured; 0 filtered out

error: test failed, to rerun pass '--lib'
```

Unser Test hat den Fehler entdeckt! Der Test `it_adds_two` schlug fehl mit der
Meldung ``assertion failed: `(left == right)` `` und dass `left` den Wert `4`
und `right` den Wert `5` hatte. Diese Nachricht ist nützlich und hilft uns, mit
 der Fehlersuche zu beginnen: Sie bedeutet, dass das Argument `left` von
 `assert_eq!` den Wert `4` hatte, aber das Argument `right`, wo wir
 `add_two(2)` hatten, war `5`.

Beachte, dass in einigen Sprachen und Test-Bibliotheken die Parameter der
Funktionen, die zwei Werte auf Gleichheit prüfen, `expected` und `actual`
genannt werden und deren Reihenfolge wichtig ist. In Rust werden sie jedoch
`left` und `right` genannt und die Reihenfolge, in der wir den erwarteten Wert
und den vom zu testenden Code produzierten Wert angeben, spielt keine Rolle.
Wir könnten die Zusicherung in diesem Test als `assert_eq!(add_two(2), 4)`
schreiben, was zur Fehlermeldung ``assertion failed: `(left == right)` ``
führen würde und dass `left` den Wert `5` und `right` den Wert `4` hatte.

Das Makro `assert_ne!` prüft, ob die beiden Werte, die wir ihm übergeben,
ungleich sind und scheitert, wenn sie gleich sind. Dieses Makro ist am
nützlichsten in Fällen, in denen wir nicht sicher sind, *welchen* Wert wir
bekommen werden, aber wir wissen, welcher Wert es definitiv *nicht* sein wird,
wenn unser Code so funktioniert, wie wir es beabsichtigen. Wenn wir zum
Beispiel eine Funktion testen, die ihre Eingabe garantiert in irgendeiner Weise
verändert, aber die Art und Weise, wie die Eingabe verändert wird, vom
Wochentag abhängt, an dem wir unsere Tests ausführen, ist es vielleicht am
besten sicherzustellen, dass die Ausgabe der Funktion nicht gleich der Eingabe
ist.

Unter der Haube verwenden die Makros `assert_eq!` und `assert_ne!` die
Operatoren `==` bzw. `!=`. Wenn die Zusicherungen fehlschlagen, geben diese
Makros ihre Argumente unter Verwendung der Debug-Formatierung aus, was
bedeutet, dass die zu vergleichenden Werte die Merkmale `PartialEq` und
`Debug` implementieren müssen. Alle primitiven Typen und die meisten
Standardbibliothekstypen implementieren diese Merkmale. Für Strukturen und
Aufzählungen, die du definierst, musst du `PartialEq` implementieren, um
prüfen zu können, dass Werte dieser Typen gleich oder ungleich sind. Du musst
`Debug` implementieren, um die Werte zu auszugeben, wenn die Zusicherung
fehlschlägt. Da es sich bei beiden Merkmalen um ableitbare Merkmale handelt,
wie in Codeblock 5-12 in Kapitel 5 erwähnt, genügt normalerweise das Ergänzen
der Annotation `#[derive(PartialEq, Debug)]` bei deiner Struktur- und
Aufzählungsdefinition. Siehe Anhang C [„Ableitbare Merkmale
(traits)“][derivable-traits] für weitere Einzelheiten über diese und andere
ableitbare Merkmale.

### Benutzerdefinierte Fehlermeldungen angeben

Du kannst den Makros `assert!`, `assert_eq!` und `assert_ne!` optional auch
eine benutzerdefinierte Nachricht mitgeben, die mit der Fehlermeldungen
ausgegeben wird. Alle Argumente, die nach dem einen erforderlichen Argument für
`assert!` oder den beiden erforderlichen Argumenten für `assert_eq!` und
`assert_ne!` angegeben werden, werden an das Makro `format!` übergeben (siehe
Kapitel 8, Abschnitt [„Aneinanderhängen mit dem Operator `+` und dem Makro
`format!`“][concatenation-with-the--operator-or-the-format-macro]), sodass du
eine Formatierungs-Zeichenkette übergeben kannst, die Platzhalter `{}` und
Werte enthält, die in diese Platzhalter gehören. Benutzerdefinierte Nachrichten
sind nützlich, um zu dokumentieren, was eine Zusicherung bedeutet; wenn ein
Test fehlschlägt, hast du eine bessere Vorstellung davon, wo das Problem im
Code liegt.

Nehmen wir zum Beispiel an, wir haben eine Funktion, die Leute mit Namen
begrüßt, und wir wollen testen, ob der Name, den wir an die Funktion übergeben,
in der Ausgabe auftaucht:

<span class="filename">Dateiname: src/lib.rs</span>

```rust
pub fn greeting(name: &str) -> String {
    format!("Hallo {}!", name)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn greeting_contains_name() {
        let result = greeting("Carol");
        assert!(result.contains("Carol"));
    }
}
#
# fn main() {}
```

Die Anforderungen für dieses Programm sind noch nicht abgestimmt worden und wir
sind ziemlich sicher, dass sich der Text `Hallo` zu Beginn der Begrüßung ändern
wird. Wir haben beschlossen, dass wir den Test nicht aktualisieren wollen, wenn
sich die Anforderungen ändern. Anstatt also zu prüfen, ob der Test exakt dem
von der Funktion `greeting` zurückgegebenen Wert entspricht, stellen wir
einfach sicher, dass die Ausgabe den Text des Eingabeparameters enthält.

Lass uns einen Fehler in diesen Code einbringen, indem wir `greeting` so
ändern, dass `name` nicht enthalten ist, um zu sehen, wie dieses Testversagen
aussieht:

```rust,not_desired_behavior
pub fn greeting(name: &str) -> String {
    String::from("Hallo!")
}

# #[cfg(test)]
# mod tests {
#     use super::*;
#
#     #[test]
#     fn greeting_contains_name() {
#         let result = greeting("Carol");
#         assert!(result.contains("Carol"));
#     }
# }
#
# fn main() {}
```

Das Ausführen dieses Tests führt zu folgender Ausgabe:

```console
$ cargo test
   Compiling greeter v0.1.0 (file:///projects/greeter)
    Finished test [unoptimized + debuginfo] target(s) in 0.91s
     Running target/debug/deps/greeter-170b942eb5bf5e3a

running 1 test
test tests::greeting_contains_name ... FAILED

failures:

---- tests::greeting_contains_name stdout ----
thread 'main' panicked at 'assertion failed: result.contains("Carol")', src/lib.rs:12:9
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace.

failures:
    tests::greeting_contains_name

test result: FAILED. 0 passed; 1 failed; 0 ignored; 0 measured; 0 filtered out

error: test failed, to rerun pass '--lib'
```

Dieses Ergebnis zeigt nur an, dass die Zusicherung fehlgeschlagen ist und in
welcher Zeile die Zusicherung steht. Eine nützlichere Fehlermeldung würde in
diesem Fall den Wert ausgeben, den wir von der Funktion `greeting` erhalten
haben. Lass uns die Testfunktion ändern, indem wir ihr eine benutzerdefinierte
Fehlermeldung angeben, die aus einer Formatierungszeichenkette mit einem
Platzhalter besteht, der mit dem tatsächlichen Wert gefüllt ist, den wir von
der Funktion `greeting` erhalten haben:

```rust
# pub fn greeting(name: &str) -> String {
#     String::from("Hallo!")
# }
#
#[cfg(test)]
# mod tests {
#     use super::*;
#
    #[test]
    fn greeting_contains_name() {
        let result = greeting("Carol");
        assert!(
            result.contains("Carol"),
            "Begrüßung enthielt nicht den Namen, Wert war `{}`",
            result
        );
    }
# }
```

Wenn wir jetzt den Test ausführen, erhalten wir eine aussagekräftigere
Fehlermeldung:

```console
$ cargo test
   Compiling greeter v0.1.0 (file:///projects/greeter)
    Finished test [unoptimized + debuginfo] target(s) in 0.93s
     Running target/debug/deps/greeter-170b942eb5bf5e3a

running 1 test
test tests::greeting_contains_name ... FAILED

failures:

---- tests::greeting_contains_name stdout ----
thread 'main' panicked at 'Begrüßung enthielt nicht den Namen, Wert war `Hallo!`', src/lib.rs:12:9
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace.

failures:
    tests::greeting_contains_name

test result: FAILED. 0 passed; 1 failed; 0 ignored; 0 measured; 0 filtered out

error: test failed, to rerun pass '--lib'
```

Wir können den Wert, den wir tatsächlich erhalten haben, in der Testausgabe
sehen, was uns helfen wird, das zu debuggen, was passiert ist, anstatt das,
was wir erwartet hatten.

### Mit `should_panic` auf Programmabbrüche prüfen

Neben der Prüfung, ob unser Code die von uns erwarteten korrekten Werte
zurückgibt, ist es auch wichtig zu prüfen, ob unser Code Fehlerbedingungen so
behandelt, wie wir es erwarten. Denke zum Beispiel an den Typ `Guess`, den wir
in Kapitel 9 in Codeblock 9-10 erstellt haben. Anderer Code, der `Guess`
verwendet, hängt von der Garantie ab, dass `Guess`-Instanzen nur Werte zwischen
1 und 100 enthalten. Wir können einen Test schreiben, der sicherstellt, dass
der Versuch, eine `Guess`-Instanz mit einem Wert außerhalb dieses Bereichs zu
erzeugen, zum Programmabbrucht führt.

Wir tun dies, indem wir ein weiteres Attribut `should_panic` zu unserer
Testfunktion hinzufügen. Dieses Attribut bewirkt, dass ein Test als bestanden
gilt, wenn der Code innerhalb der Funktion abbricht; der Test schlägt fehl,
wenn der Code innerhalb der Funktion nicht abbricht.

Codeblock 11-8 zeigt einen Test, der prüft, ob die Fehlerbedingungen von
`Guess::new` eintreten, wenn wir dies erwarten.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
pub struct Guess {
    value: i32,
}

impl Guess {
    pub fn new(value: i32) -> Guess {
        if value < 1 || value > 100 {
            panic!("Schätzwert muss zwischen 1 und 100 liegen, ist {}.", value);
        }

        Guess { value }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    #[should_panic]
    fn greater_than_100() {
        Guess::new(200);
    }
}
#
# fn main() {}
```

<span class="caption">Codeblock 11-8: Testet, dass eine Bedingung zum
Programmabbruch führt</span>

Wir setzen das Attribut `#[should_panic]` hinter das Attribut `#[test]` und vor
die Testfunktion, auf die sie sich bezieht. Schauen wir uns das Ergebnis an,
wenn dieser Test bestanden ist:

```console
$ cargo test
   Compiling guessing_game v0.1.0 (file:///projects/guessing_game)
    Finished test [unoptimized + debuginfo] target(s) in 0.58s
     Running target/debug/deps/guessing_game-57d70c3acb738f4d

running 1 test
test tests::greater_than_100 ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out

   Doc-tests guessing_game

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out
```

Sieht gut aus! Lass uns nun einen Fehler in unseren Code einbringen, indem wir
die Bedingung entfernen, bei der die Funktion `new` das Programm abbricht, wenn
der Wert größer als 100 ist:

```rust,not_desired_behavior
# pub struct Guess {
#     value: i32,
# }
# 
// --abschneiden--
impl Guess {
    pub fn new(value: i32) -> Guess {
        if value < 1 {
            panic!("Schätzwert muss zwischen 1 und 100 liegen, ist {}.", value);
        }

        Guess { value }
    }
}
#
# #[cfg(test)]
# mod tests {
#     use super::*;
#
#     #[test]
#     #[should_panic]
#     fn greater_than_100() {
#         Guess::new(200);
#     }
# }
# 
# fn main() {}
```

Wenn wir den Test in Codeblock 11-8 ausführen, wird er fehlschlagen:

```console
$ cargo test
   Compiling guessing_game v0.1.0 (file:///projects/guessing_game)
    Finished test [unoptimized + debuginfo] target(s) in 0.62s
     Running target/debug/deps/guessing_game-57d70c3acb738f4d

running 1 test
test tests::greater_than_100 ... FAILED

failures:

---- tests::greater_than_100 stdout ----
note: test did not panic as expected

failures:
    tests::greater_than_100

test result: FAILED. 0 passed; 1 failed; 0 ignored; 0 measured; 0 filtered out

error: test failed, to rerun pass '--lib'
```

Wir erhalten in diesem Fall keine sehr hilfreiche Meldung, aber wenn wir uns
die Testfunktion ansehen, sehen wir, dass sie mit `#[should_panic]` annotiert
ist. Der Fehler, den wir erhielten, bedeutet, dass der Code in der Testfunktion
keinen Programmabbruch verursacht hat.

Tests, die `should_panic` verwenden, können ungenau sein, weil sie nur
anzeigen, dass der Code einen Programmabbruch verursacht hat. Ein Test mit
`should_panic` würde auch dann bestanden werden, wenn der Test aus einem
anderen Grund zum Programmabbrucht führt als dem, den wir erwartet haben. Um
Tests mit `should_panic` präziser zu machen, können wir beim
`should_panic`-Attribut einen optionalen Parameter `expected` ergänzen. Das
Testsystem stellt sicher, dass die Fehlermeldung den angegebenen Text enthält.
Betrachte zum Beispiel den modifizierten Code für `Guess` in Codeblock 11-9, wo
die Funktion `new` mit unterschiedlichen Meldungen das Programm abbricht, je
nachdem, ob der Wert zu klein oder zu groß ist.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
# pub struct Guess {
#     value: i32,
# }
#
// --abschneiden--
impl Guess {
    pub fn new(value: i32) -> Guess {
        if value < 1 {
            panic!("Schätzwert muss größer oder gleich 1 sein, ist {}.", value);
        } else if value > 100 {
            panic!("Schätzwert muss kleiner oder gleich 100 sein, ist {}.", value);
        }

        Guess { value }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    #[should_panic(expected = "Schätzwert muss kleiner oder gleich 100 sein")]
    fn greater_than_100() {
        Guess::new(200);
    }
}
#
#fn main() {}
```

<span class="caption">Codeblock 11-9: Testet, ob ein Zustand einen
Programmabbruch mit einer bestimmten Abbruchsmeldung auslöst</span>

Dieser Test wird bestanden werden, weil der Wert, den wir beim Parameter
`expected` des `should_panic`-Attributs angeben, eine Teilzeichenkette der
Nachricht ist, mit der die Funktion `Guess::new` das Programm abbricht. Wir
hätten die gesamte erwartete Abbruchsnachricht angeben können, in diesem Fall
also `Schätzwert muss kleiner oder gleich 100 sein, ist 200`. Was du im
Parameter `expected` für `should_panic` angibst, hängt davon ab, wie viel von
der Abbruchsnachricht eindeutig oder dynamisch ist und wie präzise dein Test
sein soll. In diesem Fall reicht eine Teilzeichenkette der Abbruchsnachricht
aus, um sicherzustellen, dass der Code in der Testfunktion den Fall `else if
value > 100` ausführt.

Um zu sehen, was passiert, wenn ein Test mit `should_panic` und einer
`expected`-Nachricht fehlschlägt, wollen wir wieder einen Fehler in unseren
Code einbringen, indem wir die Zweige `if value < 1`  und `else if value > 100`
vertauschen:

```rust,not_desired_behavior
# pub struct Guess {
#     value: i32,
# }
#
# impl Guess {
#     pub fn new(value: i32) -> Guess {
        if value < 1 {
            panic!("Schätzwert muss kleiner oder gleich 100 sein, ist {}.",
                   value);
        } else if value > 100 {
            panic!("Schätzwert muss größer oder gleich 1 sein, ist {}.", value);
        }
#
#         Guess { value }
#     }
# }
#
# #[cfg(test)]
# mod tests {
#     use super::*;
#
#     #[test]
#     #[should_panic(expected = "Guess value must be less than or equal to 100")]
#     fn greater_than_100() {
#         Guess::new(200);
#     }
# }
```

Wenn wir diesmal den `should_panic`-Test ausführen, wird er fehlschlagen:

```console
$ cargo test
   Compiling guessing_game v0.1.0 (file:///projects/guessing_game)
    Finished test [unoptimized + debuginfo] target(s) in 0.66s
     Running target/debug/deps/guessing_game-57d70c3acb738f4d

running 1 test
test tests::greater_than_100 ... FAILED

failures:

---- tests::greater_than_100 stdout ----
thread 'main' panicked at 'Schätzwert muss größer oder gleich 1 sein, ist 200.', src/lib.rs:13:13
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace.
note: panic did not contain expected string
      panic message: `"Schätzwert muss größer oder gleich 1 sein, ist 200."`,
 expected substring: `"Schätzwert muss kleiner oder gleich 100 sein"`

failures:
    tests::greater_than_100

test result: FAILED. 0 passed; 1 failed; 0 ignored; 0 measured; 0 filtered out

error: test failed, to rerun pass '--lib'
```

Die Fehlermeldung zeigt an, dass dieser Test tatsächlich wie erwartet das
Programm abgebrochen hat, aber die Abbruchsmeldung enthielt nicht die erwartete
Zeichenfolge `'Schätzwert muss kleiner oder gleich 100 sein'`. Die
Abbruchsmeldung, die wir in diesem Fall erhielten, lautete: `Schätzwert muss
größer oder gleich 1 sein, ist 200.` Jetzt können wir anfangen herauszufinden,
wo unser Fehler liegt!

### Verwenden von `Result<T, E>` in Tests

Bisher haben wir Tests geschrieben, die das Programm abbrechen, wenn sie
fehlschlagen. Wir können auch Tests schreiben, die `Result<T, E>` verwenden!
Hier ist der Test aus Codeblock 11-1 so umgeschrieben, dass er `Result<T, E>`
verwendet und `Err` zurückgibt, anstatt das Programm abzubrechen:

```rust
#[cfg(test)]
mod tests {
    #[test]
    fn it_works() -> Result<(), String> {
        if 2 + 2 == 4 {
            Ok(())
        } else {
            Err(String::from("zwei plus zwei ist nicht gleich vier"))
        }
    }
}
```

Die Funktion `it_works` hat jetzt den Rückgabetyp `Result<(), String>`. Anstatt
das Makro `assert_eq!` aufzurufen, geben wir im Funktionsrumpf `Ok(())` zurück,
wenn der Test bestanden ist, und ein `Err` mit einem `String` im Inneren, wenn
der Test fehlschlägt.

Wenn du Tests so schreibst, dass sie ein `Result<T, E>` zurückgeben, kannst du
den Fragezeichen-Operator im Testrumpf verwenden, was eine bequeme Möglichkeit
sein kann, Tests zu schreiben, die fehlschlagen sollten, wenn irgendeine
Operation darin eine `Err`-Variante zurückgibt.

Du kannst die Annotation `#[should_panic]` nicht für Tests verwenden, die
`Result<T, E>` verwenden. Stattdessen solltest du direkt einen `Err`-Wert
zurückgeben, wenn der Test fehlschlagen soll.

Da du nun verschiedene Möglichkeiten kennst, Tests zu schreiben, lass uns einen
Blick darauf werfen, was passiert, wenn wir unsere Tests ausführen, und die
verschiedenen Optionen untersuchen, die wir mit `cargo test` verwenden können.

[concatenation-with-the--operator-or-the-format-macro]:
ch08-02-strings.html#aneinanderhängen-mit-dem-operator--und-dem-makro-format
[controlling-how-tests-are-run]: ch11-02-running-tests.html
[derivable-traits]: appendix-03-derivable-traits.html
[doc-comments]: ch14-02-publishing-to-crates-io.html#dokumentationskommentare-als-tests
[paths-for-referring-to-an-item-in-the-module-tree]: ch07-03-paths-for-referring-to-an-item-in-the-module-tree.html
