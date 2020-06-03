## Behebbare Fehler mit `Result`

Die meisten Fehler sind nicht so schwerwiegend, dass das Programm ganz
abgebrochen werden müsste. Manchmal, wenn eine Funktion fehlschlägt, hat das
einen Grund, den man leicht erkennen und darauf reagieren kann. Wenn du
beispielsweise versuchst, eine Datei zu öffnen, und dieser Vorgang schlägt
fehl, weil die Datei nicht existiert, könntest du die Datei erstellen, anstatt
den Vorgang zu beenden.

Erinnere dich an [„Potentielles Fehlverhalten mit dem Typ `Result`
behandeln“][handle_failure] in Kapitel 2, das die Aufzählung `Result` mit zwei
Varianten `Ok` und `Err` definiert, wie nachfolgend zu sehen ist:

[handle_failure]: ch02-00-guessing-game-tutorial.html#handling-potential-failure-with-the-result-type

```rust
enum Result<T, E> {
    Ok(T),
    Err(E),
}
```

`T` und `E` sind generische Typparameter: Wir werden generische Datentypen in
Kapitel 10 ausführlicher besprechen. Was du jetzt wissen musst, ist, dass `T`
den Typ des Wertes darstellt, der im Erfolgsfall innerhalb der `Ok`-Variante
zurückgegeben wird, und `E` den Typ des Fehlers, der im Fehlerfall innerhalb
der `Err`-Variante zurückgegeben wird. Da `Result` diese generischen
Typparameter hat, können wir den `Result`-Typ und die Funktionen, die die
Standardbibliothek darauf definiert hat, in vielen verschiedenen Situationen
verwenden, in denen der Erfolgswert und der Fehlerwert, den wir zurückgeben
wollen, unterschiedlich sein können.

Rufen wir eine Funktion auf, die einen `Result`-Wert zurückgibt, weil die
Funktion fehlschlagen könnte. In Codeblock 9-3 versuchen wir, eine Datei zu
öffnen.

<span class="filename">Dateiname: src/main.rs</span>

```rust
use std::fs::File;

fn main() {
    let f = File::open("hallo.txt");
}
```

<span class="caption">Codeblock 9-3: Eine Datei öffnen</span>

Woher wissen wir, dass `File::open` ein `Result` zurückgibt? Wir könnten uns
die [Standard-Bibliotheks-API-Dokumentation][std-library-doc] ansehen oder wir
könnten den Compiler fragen! Wenn wir `f` eine Typ-Annotation geben, von der
wir wissen, dass sie *nicht* der Rückgabetyp der Funktion ist, und dann
versuchen, den Code zu kompilieren, wird der Kompilierer uns sagen, dass die
Typen nicht übereinstimmen. Die Fehlermeldung sagt uns dann, welchen Typ `f`
tatsächlich hat. Versuchen wir es! Wir wissen, dass der Rückgabetyp von
`File::open` nicht vom Typ `u32` ist, also lass uns die Anweisung `let f` wie
folgt ändern:

[std-library-doc]: https://doc.rust-lang.org/std/index.html

```rust,does_not_compile
# use std::fs::File;
#
# fn main() {
    let f: u32 = File::open("hello.txt");



# }
```

Der Versuch, zu kompilieren, liefert uns nun folgende Ausgabe:

```console
$ cargo run
   Compiling error-handling v0.1.0 (file:///projects/error-handling)
error[E0308]: mismatched types
 --> src/main.rs:4:18
  |
4 |     let f: u32 = File::open("hallo.txt");
  |            ---   ^^^^^^^^^^^^^^^^^^^^^^^ expected `u32`, found enum `std::result::Result`
  |            |
  |            expected due to this
  |
  = note: expected type `u32`
             found enum `std::result::Result<std::fs::File, std::io::Error>`

error: aborting due to previous error

For more information about this error, try `rustc --explain E0308`.
error: could not compile `error-handling`.

To learn more, run the command again with --verbose.
```

Dies sagt uns, dass die Funktion `File::open` den Rückgabetyp `Result<T, E>`
hat. Der generische Parameter `T` wurde hier mit dem Typ des Erfolgswertes
`std::fs::File`, der eine Dateiressource (file handle) ist, gefüllt. Der Typ
`E` für den Fehlerwert ist `std::io::Error`.

Dieser Rückgabetyp bedeutet, dass der Aufruf von `File::open` erfolgreich sein
könnte und eine Dateiressource zurückgibt, aus der wir lesen oder in die wir
schreiben können. Der Funktionsaufruf kann auch fehlschlagen: Zum Beispiel
könnte die Datei nicht existieren oder wir haben möglicherweise keine
Zugriffsberechtigung für die Datei. Die Funktion `File::open` muss eine
Möglichkeit haben, uns zu sagen, ob sie erfolgreich war oder fehlgeschlagen
ist, und uns gleichzeitig entweder die Dateiressource oder die
Fehlerinformationen liefern. Diese Informationen sind genau das, was die
Aufzählung `Result` übermittelt.

Falls `File::open` erfolgreich ist, wird der Wert der Variable `f` eine Instanz
von `Ok` sein, die eine Dateiressource enthält. Im Fehlerfall ist der Wert von
`f` eine Instanz von `Err`, die mehr Informationen über die Art des
aufgetretenen Fehlers enthält.

Wir müssen den Code in Codeblock 9-3 ergänzen, um abhängig vom Rückgabewert von
`File::open` unterschiedliche Aktionen durchzuführen. Codeblock 9-4 zeigt eine
Möglichkeit, `Result` mit Hilfe eines grundlegenden Werkzeugs, dem Ausdruck
`match`, den wir in Kapitel 6 besprochen haben, zu behandeln.

<span class="filename">Dateiname: src/main.rs</span>

```rust,should_panic
use std::fs::File;

fn main() {
    let f = File::open("hallo.txt");

    let f = match f {
        Ok(file) => file,
        Err(error) => panic!("Problem beim Öffnen der Datei: {:?}", error),
    };
}
```

<span class="caption">Codeblock 9-4: Verwenden eines `match`-Ausdrucks zum
Behandeln der `Result`-Varianten, die zurückgegeben werden könnten</span>

Beachte, dass die Aufzählung `Result` und ihre Varianten automatisch im
Gültigkeitsbereich verfügbar sind, genau wie bei der Aufzählung `Option`,
sodass wir in den `match`-Zweigen nicht mehr `Result::` vor den Varianten `Ok`
und `Err` angeben müssen.

Hier sagen wir Rust, dass wir, wenn das Ergebnis `Ok` ist, den inneren Wert
`file` aus der `Ok`-Variante zurückgeben, und dann weisen wir diese
Dateiressource der Variablen `f` zu. Nach dem `match` können wir die
Dateiressource zum Lesen und Schreiben verwenden.

Der andere Zweig von `match` behandelt den Fall, dass wir einen `Err`-Wert von
`File::open` erhalten. In diesem Beispiel haben wir uns dafür entschieden, das
Makro `panic!` aufzurufen. Wenn es keine Datei namens *hallo.txt* in unserem
aktuellen Verzeichnis gibt und wir diesen Code ausführen, sehen wir die
folgende Ausgabe des Makros `panic!`:

```console
$ cargo run
   Compiling error-handling v0.1.0 (file:///projects/error-handling)
    Finished dev [unoptimized + debuginfo] target(s) in 0.73s
     Running `target/debug/error-handling`
thread 'main' panicked at 'Problem opening the file: Os { code: 2, kind: NotFound, message: "No such file or directory" }', src/main.rs:8:23
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace.
```

Wie üblich sagt uns diese Ausgabe genau, was schiefgelaufen ist.

### Abgleich verschiedener Fehler

Der Code in Codeblock 9-4 wird abbrechen, egal aus welchem Grund `File::open`
fehlschlug. Was wir stattdessen tun wollen, ist, bei verschiedenen
Fehlerursachen unterschiedliche Maßnahmen zu ergreifen: Wenn `File::open`
fehlgeschlagen ist, weil die Datei nicht existiert, wollen wir die Datei
erstellen und die Dateiressource der neuen Datei zurückgeben. Wenn `File::open`
aus irgendeinem anderen Grund fehlschlug, z.B. weil wir keine Berechtigung zum
Öffnen der Datei hatten, wollen wir immer noch, dass der Code abbricht, so wie
es in Codeblock 9-4 der Fall war. Schau dir Codeblock 9-5 an, der zusätzlich
einen inneren `match`-Ausdruck hat.

<span class="filename">Dateiname: src/main.rs</span>

```rust
use std::fs::File;
use std::io::ErrorKind;

fn main() {
    let f = File::open("hallo.txt");

    let f = match f {
        Ok(file) => file,
        Err(error) => match error.kind() {
            ErrorKind::NotFound => match File::create("hallo.txt") {
                Ok(fc) => fc,
                Err(e) => panic!("Problem beim Erstellen der Datei: {:?}", e),
            },
            other_error => {
                panic!("Problem beim Öffnen der Datei: {:?}", other_error)
            }
        },
    };
}
```

<span class="caption">Codeblock 9-5: Unterschiedliche Arten von Fehlern auf
unterschiedliche Weise behandeln</span>

Der Typ des Wertes, den `File::open` innerhalb der Variante `Err` zurückgibt,
ist `io::Error`, eine Struktur (struct), die von der Standardbibliothek zur
Verfügung gestellt wird. Diese Struktur hat eine Methode `kind`, die wir
aufrufen können, um einen `io::ErrorKind`-Wert zu erhalten. Die Aufzählung
`io::ErrorKind` wird von der Standardbibliothek zur Verfügung gestellt und
enthält Varianten, die die verschiedenen Fehlerarten repräsentieren, die bei
einer `io`-Operation auftreten können. Die Variante, die wir verwenden wollen,
ist `ErrorKind::NotFound`, was bedeutet, dass die Datei, die wir zu öffnen
versuchen, noch nicht existiert. Wir werten also `f` aus, als auch
`error.kind()`.

Die Bedingung, die wir beim inneren Abgleich überprüfen wollen, ist, ob der von
`error.kind()` zurückgegebene Wert die Variante `NotFound` der Aufzählung
`ErrorKind` ist. Wenn das der Fall ist, versuchen wir, die Datei mit
`File::create` zu erstellen. Da `File::create` aber auch scheitern könnte,
brauchen wir einen zweiten Zweig im inneren `match`-Ausdruck. Wenn die Datei
nicht erstellt werden kann, wird eine andere Fehlermeldung ausgegeben. Der
zweite Zweig des äußeren `match` bleibt gleich, sodass das Programm bei jedem
Fehler außer dem Fehler der fehlenden Datei abbricht.

Das sind viele `match`! Der Ausdruck `match` ist sehr nützlich, aber auch sehr
primitiv. In Kapitel 13 erfährst du etwas über Funktionsabschlüsse (closures);
der Typ `Result<T, E>` hat viele Methoden, die einen Funktionsabschluss
akzeptieren und mittels `match`-Ausdrücke implementiert sind. Das Verwenden
dieser Methoden wird deinen Code prägnanter machen. Ein erfahrenerer
Rust-Entwickler könnte diesen Code anstelle von Codeblock 9-5 schreiben:

```rust
use std::fs::File;
use std::io::ErrorKind;

fn main() {
    let f = File::open("hallo.txt").unwrap_or_else(|error| {
        if error.kind() == ErrorKind::NotFound {
            File::create("hallo.txt").unwrap_or_else(|error| {
                panic!("Problem beim Erstellen der Datei: {:?}", error);
            })
        } else {
            panic!("Problem beim Öffnen der Datei: {:?}", error);
        }
    });
}
```

Obwohl dieser Code dasselbe Verhalten wie Codeblock 9-5 aufweist, enthält er
keine `match`-Ausdrücke und ist einfacher zu lesen. Kehre zu diesem Beispiel
zurück, nachdem du Kapitel 13 gelesen hast, und schlage die Methode
`unwrap_or_else` in der Standardbibliotheksdokumentation nach. Viele weitere
dieser Methoden können große, verschachtelte `match`-Ausdrücke vermeiden, wenn
du mit Fehlern zu tun hast.

### Abkürzungen zum Abbrechen im Fehlerfall: `unwrap` und `expect`

Das Verwenden von `match` funktioniert gut genug, aber es kann etwas wortreich
sein und vermittelt das Vorhaben nicht immer gut. Der Typ `Result<T, E>` bietet
viele Hilfsmethoden, um verschiedene Aufgaben zu erledigen. Eine dieser
Methoden, genannt `unwrap`, ist eine Abkürzungsmethode, die genauso
implementiert ist wie der Ausdruck `match`, den wir in Codeblock 9-4
geschrieben haben. Wenn der `Result`-Wert die Variante `Ok` ist, gibt `unwrap`
den Wert innerhalb `Ok` zurück. Wenn `Result` die Variante `Err` ist, ruft
`unwrap` das Makro `panic!` für uns auf. Hier ist ein Beispiel für `unwrap` in
Aktion:

<span class="filename">Dateiname: src/main.rs</span>

```rust,should_panic
use std::fs::File;

fn main() {
    let f = File::open("hallo.txt").unwrap();
}
```

Wenn wir diesen Code ohne eine Datei *hallo.txt* ausführen, werden wir die
Fehlermeldung des `panic!`-Aufrufs sehen, den die Methode `unwrap` macht:

```text
thread 'main' panicked at 'called `Result::unwrap()` on an `Err` value: Error {
repr: Os { code: 2, message: "No such file or directory" } }',
src/libcore/result.rs:906:4
```

Des Weiteren gibt es die Methode `expect`, die ähnlich wie `unwrap`
funktioniert und uns zusätzlich die `panic!`-Fehlermeldung angeben lässt. Das
Verwenden von `expect` anstelle von `unwrap` und das Angeben guter
Fehlermeldungen kann deine Absicht vermitteln und das Aufspüren der
Fehlerursache erleichtern. Die Syntax von `expect` sieht wie folgt aus:

<span class="filename">Dateiname: src/main.rs</span>

```rust,should_panic
use std::fs::File;

fn main() {
    let f = File::open("hallo.txt").expect("Problem beim Öffnen von hallo.txt");
}
```

Wir benutzen `expect` auf die gleiche Weise wie `unwrap`: Um die Dateiressource
zurückzugeben oder das Makro `panic!` aufzurufen. Die Fehlermeldung, die
`expect` beim Aufruf von `panic!` mitgibt, wird als Parameter an `expect`
übergeben, anstelle der standardmäßigen `panic!`-Nachricht, die `unwrap`
verwendet. So sieht sie aus:

```text
thread 'main' panicked at 'Problem beim Öffnen von hallo.txt: Os { code: 2,
kind: NotFound, message: "No such file or directory" }', src/main.rs:4:13
```

Da diese Fehlermeldung mit dem von uns angegebenen Text `Problem beim Öffnen
von hallo.txt` beginnt, ist es einfacher herauszufinden, woher diese
Fehlermeldung im Code kommt. Wenn wir `unwrap` an mehreren Stellen verwenden,
kann es länger dauern, genau herauszufinden, welches `unwrap` zum
Programmabbruch geführt hat, weil alle `unwrap`-Aufrufe die gleiche Nachricht
ausgeben.

### Fehler weitergeben

Wenn du eine Funktion schreibst, deren Implementierung etwas aufruft, das
fehlschlagen könnte, kannst du, anstatt den Fehler innerhalb dieser Funktion
zu behandeln, den Fehler an den aufrufenden Code zurückgeben, damit dieser
entscheiden kann, was zu tun ist. Dies wird als *Weitergeben* (propagating) des
Fehlers bezeichnet und gibt dem aufrufenden Code mehr Kontrolle, wo mehr
Informationen und Logik zur Fehlerbehandlung vorhanden sein könnte, als im
Kontext deines Codes zur Verfügung steht.

Beispielsweise zeigt Codeblock 9-6 eine Funktion, die einen Benutzernamen aus
einer Datei liest. Wenn die Datei nicht existiert oder nicht gelesen werden
kann, gibt diese Funktion den Fehler an den Code zurück, der diese Funktion
aufgerufen hat.

<span class="filename">Dateiname: src/main.rs</span>

```rust
use std::fs::File;
use std::io;
use std::io::Read;

fn read_username_from_file() -> Result<String, io::Error> {
    let f = File::open("hallo.txt");

    let mut f = match f {
        Ok(file) => file,
        Err(e) => return Err(e),
    };

    let mut s = String::new();

    match f.read_to_string(&mut s) {
        Ok(_) => Ok(s),
        Err(e) => Err(e),
    }
}
```

<span class="caption">Codeblock 9-6: Eine Funktion, die mit `match` Fehler an
den aufrufenden Code zurückgibt</span>

Diese Funktion kann auf eine viel kürzere Art und Weise geschrieben werden,
aber wir wollen für den Anfang viel davon manuell zu machen, um die
Fehlerbehandlung zu erkunden; am Ende werden wir den kürzeren Weg zeigen. Sehen
wir uns zunächst den Rückgabetyp der Funktion an: `Result<String, io::Error>`.
Das bedeutet, dass die Funktion einen Wert vom Typ `Result<T, E>` zurückgibt,
wobei der generische Typ `T` mit dem konkreten Typ `String` und der generische
Typ `E` mit dem konkreten Typ `io::Fehler` gefüllt wurde. Wenn diese Funktion
erfolgreich ist, erhält der aufrufende Code einen `Ok`-Wert, der einen `String`
enthält &ndash; den Benutzernamen, den diese Funktion aus der Datei liest. Wenn
diese Funktion auf Probleme stößt, erhält der aufrufende Code einen `Err`-Wert,
der eine Instanz von `io::Error` enthält, mit weiteren Informationen darüber,
was die Probleme waren. Wir wählten `io::Error` als Rückgabetyp dieser
Funktion, weil dies zufällig der Typ des Fehlerwertes ist, der von beiden
Operationen zurückgegeben wird, die wir im Funktionsrumpf aufrufen und
fehlschlagen könnten: Die Funktion `File::open` und die Methode
`read_to_string`.

Der Funktionsrumpf beginnt mit dem Aufruf der Funktion `File::open`. Dann
behandeln wir den `Result`-Wert, der von `match` zurückgegeben wird, auf
ähnliche Weise wie bei `match` in Codeblock 9-4, allerdings anstatt `panic!` im
`Err`-Fall aufzurufen, beenden wir die Funktion vorzeitig und übergeben den
Fehlerwert von `File::open` als Fehlerwert dieser Funktion an den aufrufenden
Code. Wenn `File::open` erfolgreich ist, speichern wir die Dateiressource in
der Variable `f` und fahren fort.

Dann erstellen wir einen neuen `String` in der Variable `s` und rufen die
Methode `read_to_string` auf der Dateiressource in `f` auf, um den Inhalt der
Datei in `s` einzulesen. Die Methode `read_to_string` gibt ebenfalls ein
`Result` zurück, weil sie fehlschlagen könnte, obwohl `File::open` erfolgreich
war. Wir brauchen also ein weiteres `match`, um dieses `Result` zu verarbeiten:
Wenn `read_to_string` erfolgreich ist, dann war unsere Funktion erfolgreich und
wir geben den Benutzernamen aus der Datei zurück, die jetzt in `s` innerhalb
`Ok` enthalten ist. Wenn `read_to_string` fehlschlägt, geben wir den Fehlerwert
auf die gleiche Weise zurück, wie wir den Fehlerwert in `match` zurückgegeben
haben, das den Rückgabewert von `File::open` behandelt hat. Wir brauchen jedoch
nicht ausdrücklich `return` anzugeben, weil dies der letzte Ausdruck in der
Funktion ist.

Der Code, der diesen Code aufruft, wird dann damit zurechtkommen, entweder
einen `Ok`-Wert zu erhalten, der einen Benutzernamen enthält, oder einen
`Err`-Wert, der einen `io::Error` enthält. Wir wissen nicht, was der Aufrufcode
mit diesen Werten machen wird. Wenn der aufrufende Code einen `Err`-Wert
erhält, könnte er `panic!` aufrufen und das Programm zum Absturz bringen, einen
Standardbenutzernamen verwenden oder den Benutzernamen von irgendwo anders als
z.B. einer Datei nachschlagen. Wir haben nicht genug Informationen darüber, was
der aufrufende Code tatsächlich versucht, also propagieren wir alle Erfolgs-
und Fehlerinformationen nach oben, damit sie angemessen behandelt werden.
Dieses Muster der Fehlerweitergabe ist in Rust so verbreitet, dass Rust den
Fragezeichen-Operator `?` bereitstellt, um dies zu erleichtern.

#### Abkürzung zum Weitergeben von Fehlern: Der Operator `?`

Codeblock 9-7 zeigt eine Implementierung von `read_username_from_file`, die
dasselbe Verhalten wie in Codeblock 9-6 hat, aber diese Implementierung
verwendet den `?`-Operator.

<span class="filename">Dateiname: src/main.rs</span>

```rust
use std::fs::File;
use std::io;
use std::io::Read;

fn read_username_from_file() -> Result<String, io::Error> {
    let mut f = File::open("hallo.txt")?;
    let mut s = String::new();
    f.read_to_string(&mut s)?;
    Ok(s)
}
```

<span class="caption">Codeblock 9-7: Eine Funktion, die Fehler an den
aufrufenden Code zurückgibt, indem sie den `?`-Operator verwendet</span>

Das `?` hinter dem `Result`-Wert bewirkt fast das gleiche wie die
`match`-Ausdrücke, die wir zum Behandeln der `Result`-Werte in Codeblock 9-6
definiert haben. Wenn der Wert von `Result` ein `Ok` ist, wird der Wert
innerhalb `Ok` zurückgegeben und das Programm fortgesetzt. Wenn der Wert ein
`Err` ist, wird er als Funktionsergebnis zurückgegeben, als ob wir das
Schlüsselwort `return` verwendet hätten.

Es gibt einen Unterschied zwischen dem, was der `match`-Ausdruck aus Codeblock
9-6 tut, und dem, was der `?`-Operator tut: Fehlerwerte, bei denen der
`?`-Operator aufgerufen wird, durchlaufen die Funktion `from`, die im Merkmal
`From` der Standardbibliothek definiert ist und die zur Konvertierung von
Fehlern eines Typs in einen anderen verwendet wird. Wenn der `?`-Operator die
Funktion `from` aufruft, wird der empfangene Fehlertyp in den Fehlertyp
umgewandelt, der als Rückgabetyp der aktuellen Funktion definiert ist. Das ist
hilfreich, wenn eine Funktion einen einzigen Fehlertyp zurückgibt, um alle
möglichen Fehlerarten einer Funktion darzustellen, auch wenn Teile aus vielen
verschiedenen Gründen versagen könnten. Solange jeder Fehlertyp die Funktion
`from` implementiert, um festzulegen, wie er sich selbst in den
zurückzugebenden Fehlertyp konvertieren soll, kümmert sich der `?`-Operator
automatisch um die Konvertierung.

Im Zusammenhang mit Codeblock 9-7 gibt das `?` am Ende des Aufrufs von
`File::open` den Wert innerhalb eines `Ok` an die Variable `f` zurück. Wenn ein
Fehler auftritt, beendet der Operator vorzeitig die gesamte Funktion und gibt
dem aufrufenden Code einen `Err`-Wert zurück. Dasselbe gilt für das `?` am Ende
des `read_to_string`-Aufrufs.

Der `?`-Operator eliminiert viel umständlichen Code und macht die
Implementierung dieser Funktion einfacher. Wir können diesen Code sogar noch
weiter verkürzen, indem wir die Methodenaufrufe unmittelbar nach dem `?`
verketten, wie in Codeblock 9-8 zu sehen ist.

<span class="filename">Dateiname: src/main.rs</span>

```rust
use std::fs::File;
use std::io;
use std::io::Read;

fn read_username_from_file() -> Result<String, io::Error> {
    let mut s = String::new();

    File::open("hallo.txt")?.read_to_string(&mut s)?;

    Ok(s)
}
```

<span class="caption">Codeblock 9-8: Verketten von Methodenaufrufen nach dem
`?`-Operator</span>

Wir haben das Erstellen des neuen `String` in `s` an den Anfang der Funktion
verlegt; dieser Teil hat sich nicht geändert. Anstatt eine Variable `f` zu
erzeugen, haben wir den Aufruf von `read_to_string` direkt an das Ergebnis von
`File::open("hallo.txt")?` gehängt. Wir haben immer noch ein `?` am Ende des
Aufrufs von `read_to_string`, und wir geben immer noch einen `Ok`-Wert zurück,
der den Benutzernamen in `s` enthält, wenn sowohl `File::open` als auch
`read_to_string` erfolgreich sind, anstatt Fehler zurückzugeben. Die
Funktionalität ist wieder die gleiche wie in Codeblock 9-6 und Codeblock 9-7;
das ist nur eine andere, ergonomischere Schreibweise.

Wenn wir schon von verschiedenen Schreibweisen dieser Funktion sprechen, zeigt
Codeblock 9-9, dass es einen Weg gibt, diese Funktion noch kürzer zu machen.

<span class="filename">Dateiname: src/main.rs</span>

```rust
use std::fs;
use std::io;

fn read_username_from_file() -> Result<String, io::Error> {
    fs::read_to_string("hello.txt")
}
```

<span class="caption">Codeblock 9-9: Verwenden von `fs::read_to_string`,
anstatt die Datei zu öffnen und dann zu lesen</span>

Das Einlesen einer Datei in eine Zeichenkette ist eine ziemlich häufig
benötigte Operation, daher bringt Rust die praktische Funktion
`fs::read_to_string` mit, die die Datei öffnet, einen neuen `String` erzeugt,
den Inhalt der Datei einliest, den Inhalt in den `String` einfügt und ihn
zurückgibt. Natürlich gibt uns die Verwendung von `fs::read_to_string` nicht
die Möglichkeit, die ganze Fehlerbehandlung zu erklären, also haben wir es
zuerst auf dem längeren Weg gemacht.

#### Der `?`-Operator kann in Funktionen verwendet werden, die `Result` zurückgeben

Der `?`-Operator kann in Funktionen verwendet werden, die den Rückgabetyp
`Result` haben, weil er so definiert ist, dass er auf die gleiche Weise
arbeitet wie der `match`-Ausdruck, den wir in Codeblock 9-6 definiert haben. 
Der Teil von `match`, der den Rückgabetyp `Result` erfordert, ist
`return Err(e)`, daher kann der Rückgabetyp der Funktion `Result` sein, um mit
`return` kompatibel zu sein.

Schauen wir uns an, was passiert, wenn wir den `?`-Operator in der Funktion
`main` verwenden, die, wie du dich erinnern wirst, den Rückgabetyp `()` hat:

```rust,does_not_compile
use std::fs::File;

fn main() {
    let f = File::open("hallo.txt")?;
}
```

Wenn wir diesen Code kompilieren, erhalten wir folgende Fehlermeldung:

```console
$ cargo run
   Compiling error-handling v0.1.0 (file:///projects/error-handling)
error[E0277]: the `?` operator can only be used in a function that returns `Result` or `Option` (or another type that implements `std::ops::Try`)
 --> src/main.rs:4:13
  |
3 | / fn main() {
4 | |     let f = File::open("hallo.txt")?;
  | |             ^^^^^^^^^^^^^^^^^^^^^^^^ cannot use the `?` operator in a function that returns `()`
5 | | }
  | |_- this function should return `Result` or `Option` to accept `?`
  |
  = help: the trait `std::ops::Try` is not implemented for `()`
  = note: required by `std::ops::Try::from_error`

error: aborting due to previous error

For more information about this error, try `rustc --explain E0277`.
error: could not compile `error-handling`.

To learn more, run the command again with --verbose.
```

Dieser Fehler weist darauf hin, dass wir den `?`-Operator nur in einer Funktion
verwenden dürfen, die `Result` oder `Option` oder einen anderen Typ, der
`std::ops::Try` implementiert, zurückgibt. Wenn du Code in einer Funktion
schreibst, die keinen dieser Typen zurückgibt, und du `?` verwenden willst,
wenn du andere Funktionen mit dem Rückgabetyp `Result<T, E>` aufrufst, hast du
zwei Möglichkeiten, dieses Problem zu lösen. Eine Technik besteht darin, den
Rückgabetyp deiner Funktion in `Result<T, E>` zu ändern, wenn dem nichts
entgegensteht. Die andere Technik besteht darin, `match` oder eine der Methoden
von `Result<T, E>` zu verwenden, um das `Result<T, E>` in geeigneter Weise zu
behandeln.

Die Funktion `main` ist etwas Besonderes und es gibt Einschränkungen
hinsichtlich ihres Rückgabetyps. Ein gültiger Rückgabetyp für main ist `()` und
bequemerweise auch `Result<T, E>`, wie hier zu sehen ist:

```rust,should_panic
use std::error::Error;
use std::fs::File;

fn main() -> Result<(), Box<dyn Error>> {
    let f = File::open("hallo.txt")?;

    Ok(())
}
```

Der Typ `Box<dyn Error>` wird als Markmalsobjekt (trait object) bezeichnet,
über das wir im Abschnitt [„Merkmalsobjekte (trait objects) die Werte
unterschiedlicher Typen erlauben“][trait-objects] in Kapitel 17 sprechen
werden. Vorerst kannst du `Box<dyn Fehler>` als „eine beliebige Fehlerart“
ansehen. Das Verwenden von `?` in einer `main`-Funktion mit diesem Rückgabetyp
ist erlaubt.

Nachdem wir nun die Einzelheiten des Aufrufs von `panic!` und der Rückgabe von
`Result` besprochen haben, wollen wir zum Thema zurückkehren, wie wir
entscheiden können, was in welchen Fällen angemessen ist.

[trait-objects]: ch17-02-trait-objects.html#using-trait-objects-that-allow-for-values-of-different-types
