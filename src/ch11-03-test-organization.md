## Testverwaltung

Wie zu Beginn des Kapitels erwähnt, ist das Testen eine komplexe Disziplin, und
verschiedene Personen verwenden unterschiedliche Terminologien und
Organisationen. Die Rust-Gemeinschaft teilt Tests in zwei Hauptkategorien ein:
*Modultests* (unit tests) und *Integrationstests* (integration tests).
Modultests sind klein und zielgerichteter, testen jeweils ein Modul isoliert
und können private Schnittstellen testen. Integrationstests sind völlig
außerhalb deiner Bibliothek und verwenden deinen Code auf die gleiche Weise wie
jeder andere externe Code, wobei nur die öffentliche Schnittstelle verwendet
wird und möglicherweise mehrere Module pro Test ausgeführt werden.

Es ist wichtig, beide Testarten zu schreiben, um sicherzustellen, dass die
Teile deiner Bibliothek einzeln und zusammen das tun, was du von ihnen
erwartest.

### Modultests

Der Zweck von Modultests besteht darin, jede Code-Einheit isoliert vom Rest des
Codes zu testen, um schnell herauszufinden, welcher Code wie erwartet
funktioniert und welcher nicht. Modultests befinden sich im Verzeichnis *src*
in den Quellcodedateien, den sie testen. Die Konvention besteht darin, in jeder
Datei ein Modul namens `tests` zu erstellen, das die Testfunktionen enthält,
und das Modul mit `cfg(test)` zu annotieren.

#### Das Testmodul und `#[cfg(test)]`

Die Annotation `#[cfg(test)]` am Testmodul weist Rust an, den Testcode nur dann
zu kompilieren und auszuführen, wenn du `cargo test` ausführst, nicht aber,
wenn du `cargo build` ausführst. Dies spart Kompilierzeit, wenn du nur die
Bibliothek erstellen möchtest, und spart Platz im resultierenden, kompilierten
Artefakt, da die Tests nicht enthalten sind. Du wirst feststellen, dass
Integrationstests die Annotation `#[cfg(test)]` nicht benötigen, weil sie in
einem anderen Verzeichnis liegen. Da Modultests jedoch in den gleichen Dateien
wie der Code sind, wirst du `#[cfg(test)]` verwenden, um anzugeben, dass sie
nicht im kompilierten Ergebnis enthalten sein sollen.

Erinnere dich daran, dass Cargo diesen Code für uns generiert hat, als wir das
neue Projekt `adder` im ersten Abschnitt dieses Kapitels erstellt haben:

<span class="filename">Dateiname: src/lib.rs</span>

```rust,noplayground
#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        assert_eq!(2 + 2, 4);
    }
}
```

Dieser Code ist das automatisch generierte Testmodul. Das Attribut `cfg` steht
für *Konfiguration* und teilt Rust mit, dass das folgende Element nur bei einer
bestimmten Konfigurationsoption eingebunden werden soll. In diesem Fall ist die
Konfigurationsoption `test`, die von Rust beim Kompilieren und Ausführen von
Tests verwendet wird. Durch das Verwenden des Attributs `cfg` kompiliert Cargo
unseren Testcode nur dann, wenn wir die Tests aktiv mit `cargo test` ausführen.
Dies schließt alle Hilfsfunktionen ein, die sich innerhalb dieses Moduls
befinden könnten, zusätzlich zu den mit `#[test]` annotierten Funktionen.

#### Testen privater Funktionen

In der Testgemeinschaft wird darüber diskutiert, ob private Funktionen direkt
getestet werden sollten oder nicht, und andere Sprachen machen es schwierig
oder gar unmöglich, private Funktionen zu testen. Unabhängig davon, an welcher
Testideologie du festhältst, erlauben dir Rusts Datenschutzregeln, private
Funktionen zu testen. Betrachte den Code in Codeblock 11-12 mit der privaten
Funktion `internal_adder`.

<span class="filename">Dateiname: src/lib.rs</span>

```rust,noplayground
pub fn add_two(a: i32) -> i32 {
    internal_adder(a, 2)
}

fn internal_adder(a: i32, b: i32) -> i32 {
    a + b
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn internal() {
        assert_eq!(4, internal_adder(2, 2));
    }
}
```

<span class="caption">Codeblock 11-12: Testen einer privaten Funktion</span>

Beachte, dass die Funktion `internal_adder` nicht mit `pub` markiert ist. Tests
sind einfach nur Rust-Code, und das Modul `tests` ist nur ein weiteres Modul.
Wie im Abschnitt [„Mit Pfaden auf ein Element im Modulbaum verweisen“][paths]
beschrieben, können Elemente in Kind-Modulen die Elemente ihrer Eltern-Module
verwenden. In diesem Test bringen wir alle Elemente des Eltern-Moduls von
`test` mit `use super::*` in den Gültigkeitsbereich, und dann kann der Test
`internal_adder` aufrufen. Wenn du der Meinung bist, dass private Funktionen
nicht getestet werden sollten, gibt es in Rust nichts, was dich dazu zwingen
würde.

### Integrationstests

In Rust sind Integrationstests völlig außerhalb deiner Bibliothek angesiedelt.
Du verwendest deine Bibliothek auf die gleiche Weise wie jeder andere Code,
d.h. es können nur Funktionen aufgerufen werden, die Teil der öffentlichen
Programmierschnittstelle (API) deiner Bibliothek sind. Ihr Zweck ist es, zu
testen, ob viele Teile deiner Bibliothek korrekt zusammenarbeiten.
Code-Einheiten, die alleine korrekt funktionieren, könnten Probleme nach deren
Integration haben, daher ist auch die Testabdeckung des integrierten Codes
wichtig. Um Integrationstests zu erstellen, benötigst du zunächst ein
Verzeichnis *tests*.

#### Das Verzeichnis *tests*

Wir erstellen ein Verzeichnis *tests* auf der obersten Ebene unseres
Projektverzeichnisses, neben *src*. Cargo weiß, dass es in diesem Verzeichnis
nach Integrationstestdateien suchen soll. Wir können dann in diesem Verzeichnis
so viele Testdateien erstellen, wie wir wollen, und Cargo wird jede dieser
Dateien als eine einzelne Kiste (crate) kompilieren.

Lass uns einen Integrationstest erstellen. Wenn sich der Code in Codeblock
11-12 noch in der Datei *src/lib.rs* befindet, erstelle ein Verzeichnis
*tests* und eine neue Datei mit dem Namen *tests/integration_test.rs* und gib
den Code aus Codeblock 11-13 ein.

<span class="filename">Dateiname: tests/integration_test.rs</span>

```rust,ignore
use adder;

#[test]
fn it_adds_two() {
    assert_eq!(4, adder::add_two(2));
}
```

<span class="caption">Codeblock 11-13: Integrationstest einer Funktion in der
Kiste `adder`</span>

Wir haben am Anfang des Codes `use adder;` angegeben, was wir bei Modultests
nicht brauchten. Der Grund dafür ist, dass jede Datei im Verzeichnis `tests`
eine separate Kiste ist, sodass wir unsere Bibliothek in den Gültigkeitsbereich
jeder Testkiste bringen müssen.

Wir brauchen den Code in *tests/integration_test.rs* nicht mit `#[cfg(test)]`
zu annotieren. Cargo behandelt das Verzeichnis `tests` speziell und kompiliert
Dateien in diesem Verzeichnis nur dann, wenn wir `cargo test` ausführen. Führe
`cargo test` jetzt aus:

```console
$ cargo test
   Compiling adder v0.1.0 (file:///projects/adder)
    Finished test [unoptimized + debuginfo] target(s) in 0.73s
     Running unittests (target/debug/deps/adder-92948b65e88960b4)

running 1 test
test tests::internal ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out

     Running unittests (target/debug/deps/integration_test-82e7799c1bc62298)

running 1 test
test it_adds_two ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out

   Doc-tests adder

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out
```

Die drei Abschnitte der Ausgabe umfassen die Modultests, den Integrationstest
und die Dokumentationstests. Der erste Abschnitt für die Modultests ist
derselbe, wie wir ihn gesehen haben: Eine Zeile für jeden Modultest (eine Zeile
mit der Bezeichnung `internal`, die wir in Codeblock 11-12 hinzugefügt haben)
und dann eine zusammenfassende Zeile für die Modultests.

Der Abschnitt zu den Integrationstests beginnt mit der Zeile `Running
target/debug/deps/integration_test-82e7799c1bc62298` (der Hashwert am Ende
deiner Ausgabe ist anders). Als nächstes kommt eine Zeile für jede Testfunktion
in diesem Integrationstest und eine Zusammenfassung für die Ergebnisse des
Integrationstests, kurz bevor der Abschnitt `Doc-tests adder` beginnt.

Ähnlich wie das Hinzufügen weiterer Modultestfunktionen zu mehr Ergebniszeilen
im Modultest-Abschnitt führt, führt das Hinzufügen weiterer Testfunktionen in
der Integrationstestdatei zu mehr Ergebniszeilen im Abschnitt zu dieser
Integrationstestdatei. Jede Integrationstestdatei hat ihren eigenen Abschnitt,
wenn wir also weitere Dateien im Verzeichnis *tests* hinzufügen, wird es mehr
Integrationstest-Abschnitte geben.

Wir können immer noch eine bestimmte Integrationstestfunktion ausführen, indem
wir den Namen der Testfunktion als Argument bei `cargo test` angeben. Um alle
Tests in einer bestimmten Integrationstestdatei auszuführen, verwenden bei
`cargo test` das Argument `--test`, gefolgt vom Namen der Datei:

```console
$ cargo test --test integration_test
   Compiling adder v0.1.0 (file:///projects/adder)
    Finished test [unoptimized + debuginfo] target(s) in 0.64s
     Running unittests (target/debug/deps/integration_test-82e7799c1bc62298)

running 1 test
test it_adds_two ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out
```

Dieses Kommando führt nur die Tests in der Datei *tests/integration_test.rs*
aus.

#### Teilmodule in Integrationstests

Wenn du weitere Integrationstests hinzufügst, möchtest du vielleicht mehr als
eine Datei im Verzeichnis *tests* erstellen, um sie besser organisieren zu
können; beispielsweise kannst du die Testfunktionen nach der Funktionalität
gruppieren, die sie testen. Wie bereits erwähnt, wird jede Datei im Verzeichnis
*tests* als eine separate Kiste kompiliert.

Jede Integrationstestdatei wie eine eigene Kiste zu behandeln, ist nützlich, um
separate Bereiche zu erstellen, die eher der Art und Weise entsprechen, wie
Endbenutzer deine Kiste verwenden werden. Das bedeutet jedoch, dass Dateien im
Verzeichnis *tests* nicht das gleiche Verhalten wie Dateien in *src* haben, wie
du in Kapitel 7 über die Trennung von Code in Module und Dateien gelernt hast.

Das unterschiedliche Verhalten von Dateien im Verzeichnis *tests* ist am
deutlichsten, wenn du eine Reihe Hilfsfunktionen hast, die bei mehreren
Integrationstestdateien nützlich wären, und du versuchst, die Schritte im
Abschnitt [„Module in verschiedene Dateien
aufteilen“][separating-modules-into-files] in Kapitel 7 zu befolgen, um sie in
ein gemeinsames Modul zu extrahieren. Wenn wir zum Beispiel *tests/common.rs*
erstellen und eine Funktion namens `setup` darin platzieren, können wir `setup`
etwas Code hinzufügen, den wir von mehreren Testfunktionen in mehreren
Testdateien aufrufen wollen:

<span class="filename">Dateiname: tests/common.rs</span>

```rust
pub fn setup() {
    // Vorbereitungscode speziell für die Tests deiner Bibliothek
}
```

Wenn wir die Tests erneut ausführen, werden wir für die Datei *common.rs* einen
neuen Abschnitt in der Testausgabe sehen, obwohl diese Datei keine
Testfunktionen enthält und wir die Funktion `setup` nicht von irgendwo
aufgerufen haben:

```console
$ cargo test
   Compiling adder v0.1.0 (file:///projects/adder)
    Finished test [unoptimized + debuginfo] target(s) in 0.89s
     Running unittests (target/debug/deps/adder-92948b65e88960b4)

running 1 test
test tests::internal ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out

     Running unittests (target/debug/deps/common-7064e1b6d2e271be)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out

     Running unittests (target/debug/deps/integration_test-82e7799c1bc62298)

running 1 test
test it_adds_two ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out

   Doc-tests adder

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out
```

Dass in den Testergebnissen `common` erscheint und dabei `running 0 tests`
angezeigt wird, ist nicht das, was wir wollten. Wir wollten nur etwas Code mit
den anderen Integrationstestdateien teilen.

Um zu vermeiden, dass `common` in der Testausgabe erscheint, werden wir statt
*tests/common.rs* die Datei *tests/common/mod.rs* erstellen. Dies ist eine
alternative Namenskonvention, die auch Rust versteht. Durch diese Benennung der
Datei wird Rust angewiesen, das Modul `common` nicht als Integrationstestdatei
zu behandeln. Wenn wir den Funktionscode `setup` in *tests/common/mod.rs*
verschieben und die Datei *tests/common.rs* löschen, erscheint der Abschnitt in
der Testausgabe nicht mehr. Dateien in Unterverzeichnissen des Verzeichnisses
*tests* werden nicht als separate Kisten kompiliert und erzeugen keine
Abschnitte in der Testausgabe.

Nachdem wir *tests/common/mod.rs* erstellt haben, können wir es von jeder der
Integrationstestdateien als Modul verwenden. Hier ist ein Beispiel für den
Aufruf der Funktion `setup` aus dem Test `it_adds_two` in
*tests/integration_test.rs*:

<span class="filename">Dateiname: tests/integration_test.rs</span>

```rust,ignore
use adder;

mod common;

#[test]
fn it_adds_two() {
    common::setup();
    assert_eq!(4, adder::add_two(2));
}
```

Beachte, dass die Deklaration `mod common;` die gleiche ist wie die
Moduldeklaration, die wir in Codeblock 7-21 gezeigt haben. In der Testfunktion
können wir dann die Funktion `common::setup()` aufrufen.

#### Integrationstests für binäre Kisten

Wenn unser Projekt eine binäre Kiste ist, die nur eine Datei *src/main.rs*
enthält und keine Datei *src/lib.rs*, können wir keine Integrationstests im
*tests*-Verzeichnis erstellen und Funktionen, die in der *src/main.rs*-Datei
definiert sind, mit einer `use`-Anweisung in den Gültigkeitsbereich bringen.
Nur Bibliothekskisten stellen Funktionen zur Verfügung, die auch von anderen
Kisten verwendet werden können; binäre Kisten sind für den eigenständigen
Betrieb gedacht.

Dies ist einer der Gründe, warum Rust-Projekte, die eine Binärdatei
bereitstellen, eine einfache *src/main.rs*-Datei haben, die Logik aufruft, die
in der *src/lib.rs*-Datei lebt. Unter Verwendung dieser Struktur können
Integrationstests die Bibliothekskiste mit `use` testen, um wichtige
Funktionalität verfügbar zu machen. Wenn die Hauptfunktionalität korrekt ist,
funktionieren auch die kleinen Codestücke in der Datei *src/main.rs*, und diese
kleinen Codestücke müssen nicht getestet werden.

## Zusammenfassung

Die Testfunktionalitäten von Rust bieten eine Möglichkeit, zu spezifizieren,
wie der Code funktionieren soll, um sicherzustellen, dass er weiterhin so
funktioniert, wie du es erwartest, auch wenn du Änderungen vornimmst. Modultests prüfen
verschiedene Teile einer Bibliothek separat und können private
Implementierungsdetails testen. Integrationstests prüfen, ob viele Teile der
Bibliothek korrekt zusammenarbeiten, und sie verwenden die öffentliche
Programmierschnittstelle (API) der Bibliothek, um den Code auf die gleiche
Weise zu testen, wie externer Code ihn verwenden wird. Auch wenn das Typsystem
und die Eigentümerschaftsregeln von Rust dazu beitragen, einige Fehlerarten zu
verhindern, sind Tests immer noch wichtig, um Logikfehler zu reduzieren, die
damit zu tun haben, wie sich dein Code voraussichtlich verhalten wird.

Lass uns das Wissen, das du in diesem und in den vorhergehenden Kapiteln
gelernt hast, für die Arbeit an einem Projekt einsetzen!

[paths]: ch07-03-paths-for-referring-to-an-item-in-the-module-tree.html
[separating-modules-into-files]:
ch07-05-separating-modules-into-different-files.html
