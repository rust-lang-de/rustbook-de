## Behebbare Fehler mit `Result`

Die meisten Fehler sind nicht so schwerwiegend, dass das Programm ganz
abgebrochen werden müsste. Manchmal, wenn eine Funktion fehlschlägt, hat das
einen Grund, den man leicht erkennen und darauf reagieren kann. Wenn du
beispielsweise versuchst, eine Datei zu öffnen, und dieser Vorgang schlägt
fehl, weil die Datei nicht existiert, könntest du die Datei erstellen, anstatt
den Vorgang zu beenden.

Erinnere dich an [„Behandeln potentieller Fehler mit dem Typ
`Result`“][handle_failure] in Kapitel 2, das die Aufzählung `Result` mit zwei
Varianten `Ok` und `Err` definiert, wie nachfolgend zu sehen ist:

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
Typparameter hat, können wir den `Result`-Typ und die Funktionen, die darauf
definiert sind, in vielen verschiedenen Situationen verwenden, in denen der
Erfolgswert und der Fehlerwert, den wir zurückgeben wollen, unterschiedlich
sein können.

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

Der Rückgabetyp von `File::open` ist `Result<T, E>`. Der generische Parameter
`T` wurde hier mit dem Typ des Erfolgswertes `std::fs::File`, der eine
Dateiressource (file handle) ist, gefüllt. Der Typ `E` für den Fehlerwert ist
`std::io::Error`. Dieser Rückgabetyp bedeutet, dass der Aufruf von `File::open`
erfolgreich sein könnte und eine Dateiressource zurückgibt, aus der wir lesen
oder in die wir schreiben können. Der Funktionsaufruf kann auch fehlschlagen:
Zum Beispiel könnte die Datei nicht existieren oder wir haben möglicherweise
keine Zugriffsberechtigung für die Datei. Die Funktion `File::open` muss eine
Möglichkeit haben, uns zu sagen, ob sie erfolgreich war oder fehlgeschlagen
ist, und uns gleichzeitig entweder die Dateiressource oder die
Fehlerinformationen liefern. Diese Informationen sind genau das, was die
Aufzählung `Result` übermittelt.

Falls `File::open` erfolgreich ist, wird der Wert der Variable
`f` eine Instanz von `Ok` sein, die eine Dateiressource
enthält. Im Fehlerfall ist der Wert von `f` eine Instanz von
`Err`, die mehr Informationen über die Art des aufgetretenen Fehlers enthält.

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

Wenn das Ergebnis `Ok` ist, gibt dieser Code den inneren `file`-Wert aus der
`Ok`-Variante zurück, und wir weisen diese Dateiressource der Variablen `f` zu.
Nach dem `match` können wir die Dateiressource zum Lesen und Schreiben verwenden.

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
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
```

Wie üblich sagt uns diese Ausgabe genau, was schiefgelaufen ist.

### Abgleich verschiedener Fehler

Der Code in Codeblock 9-4 wird abbrechen, egal aus welchem Grund `File::open`
fehlschlug. Nun wollen wir jedoch bei verschiedenen Fehlerursachen
unterschiedliche Maßnahmen ergreifen: Wenn `File::open` fehlgeschlagen ist,
weil die Datei nicht existiert, wollen wir die Datei erstellen und die
Dateiressource der neuen Datei zurückgeben. Wenn `File::open` aus irgendeinem
anderen Grund fehlschlug, z.B. weil wir keine Berechtigung zum Öffnen der Datei
hatten, wollen wir immer noch, dass der Code abbricht, so wie es in Codeblock
9-4 der Fall war. Dazu fügen wir einen inneren `match`-Ausdruck hinzu, wie in
Codeblock 9-5 gezeigt.

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
versuchen, noch nicht existiert. Wir werten also `f` aus,
als auch `error.kind()`.

Die Bedingung, die wir beim inneren Abgleich überprüfen wollen, ist, ob der von
`error.kind()` zurückgegebene Wert die Variante `NotFound` der Aufzählung
`ErrorKind` ist. Wenn das der Fall ist, versuchen wir, die Datei mit
`File::create` zu erstellen. Da `File::create` aber auch scheitern könnte,
brauchen wir einen zweiten Zweig im inneren `match`-Ausdruck. Wenn die Datei
nicht erstellt werden kann, wird eine andere Fehlermeldung ausgegeben. Der
zweite Zweig des äußeren `match` bleibt gleich, sodass das Programm bei jedem
Fehler, außer dem Fehler der fehlenden Datei, abbricht.

### Alternativen zur Verwendung von `match` mit `Result<T, E>`

> Das sind viele `match`! Der Ausdruck `match` ist sehr nützlich, aber auch
> sehr primitiv. In Kapitel 13 wirst du etwas über Funktionsabschlüsse
> (closures) lernen, die mit vielen der auf `Result<T, E>` definierten Methoden
> verwendet werden. Diese Methoden können prägnanter sein als die Verwendung
> von `match` bei der Behandlung von `Result<T, E>`-Werten in deinem Code.
>
> Hier ist zum Beispiel eine andere Möglichkeit, die gleiche Logik wie in
> Codeblock 9-5 zu schreiben, aber unter Verwendung von Funktionsabschlüssen
> und der Methode `unwrap_or_else`:
>
> ```rust
> use std::fs::File;
> use std::io::ErrorKind;
>
> fn main() {
>     let f = File::open("hallo.txt").unwrap_or_else(|error| {
>         if error.kind() == ErrorKind::NotFound {
>             File::create("hallo.txt").unwrap_or_else(|error| {
>                 panic!("Problem beim Erstellen der Datei: {:?}", error);
>             })
>         } else {
>             panic!("Problem beim Öffnen der Datei: {:?}", error);
>         }
>     });
> }
> ```
>
> Obwohl dieser Code dasselbe Verhalten wie Codeblock 9-5 aufweist, enthält er
> keine `match`-Ausdrücke und ist einfacher zu lesen. Kehre zu diesem Beispiel
> zurück, nachdem du Kapitel 13 gelesen hast, und schlage die Methode
> `unwrap_or_else` in der Standardbibliotheksdokumentation nach. Viele weitere
> dieser Methoden können große, verschachtelte `match`-Ausdrücke vermeiden,
> wenn du mit Fehlern zu tun hast.

### Abkürzungen zum Abbrechen im Fehlerfall: `unwrap` und `expect`

Das Verwenden von `match` funktioniert gut genug, aber es kann etwas langatmig
sein und vermittelt das Vorhaben nicht immer gut. Der Typ `Result<T, E>` bietet
viele Hilfsmethoden, um verschiedene, spezifischere Aufgaben zu erledigen. Die
Methode `unwrap` ist eine Abkürzungsmethode, implementiert wie der Ausdruck
`match`, den wir in Codeblock 9-4 verwendet haben. Wenn der `Result`-Wert die
Variante `Ok` ist, gibt `unwrap` den Wert innerhalb `Ok` zurück. Wenn `Result`
die Variante `Err` ist, ruft `unwrap` das Makro `panic!` für uns auf. Hier ist
ein Beispiel für `unwrap` im Einsatz:

<span class="filename">Dateiname: src/main.rs</span>

```rust,should_panic
use std::fs::File;

fn main() {
    let f = File::open("hallo.txt").unwrap();
}
```

Wenn wir diesen Code ohne eine Datei *hallo.txt* ausführen, werden wir die
Fehlermeldung des `panic!`-Aufrufs sehen, den die Methode `unwrap` macht:

```console
thread 'main' panicked at 'called `Result::unwrap()` on an `Err` value: Error {
repr: Os { code: 2, message: "No such file or directory" } }',
src/libcore/result.rs:906:4
```

In ähnlicher Weise können wir bei der Methode `expect` auch die Fehlermeldung
von `panic!` angeben. Das Verwenden von `expect` anstelle von `unwrap` und das
Angeben guter Fehlermeldungen kann deine Absicht vermitteln und das Aufspüren
der Fehlerursache erleichtern. Die Syntax von `expect` sieht wie folgt aus:

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
thread 'main' panicked at 'hello.txt should be included in this project: Error
{ repr: Os { code: 2, message: "No such file or directory" } }',
src/libcore/result.rs:906:4
```

In produktivem Code wählen die meisten Rust-Entwickler `expect` statt
`unwrap` und geben mehr Kontext darüber an, warum die Operation voraussichtlich
immer erfolgreich sein wird. Auf diese Weise hast du mehr Informationen, die du
bei der Fehlersuche verwenden kannst, falls sich deine Annahmen als falsch
erweisen sollten.

### Fehler weitergeben

Wenn die Implementierung einer Funktion etwas aufruft, das fehlschlagen könnte,
kannst du, anstatt den Fehler innerhalb dieser Funktion zu behandeln, den
Fehler an den aufrufenden Code zurückgeben, damit dieser entscheiden kann, was
zu tun ist. Dies wird als *Weitergeben* (propagating) des Fehlers bezeichnet
und gibt dem aufrufenden Code mehr Kontrolle, wo mehr Informationen und Logik
zur Fehlerbehandlung vorhanden sein könnte, als im Kontext deines Codes zur
Verfügung steht.

Beispielsweise zeigt Codeblock 9-6 eine Funktion, die einen Benutzernamen aus
einer Datei liest. Wenn die Datei nicht existiert oder nicht gelesen werden
kann, gibt diese Funktion den Fehler an den Code zurück, der die Funktion
aufgerufen hat.

<span class="filename">Dateiname: src/main.rs</span>

```rust
use std::fs::File;
use std::io::{self, Read};

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
aber wir wollen für den Anfang viel davon manuell machen, um die
Fehlerbehandlung kennen zu lernen; am Ende werden wir den kürzeren Weg zeigen. Sehen
wir uns zunächst den Rückgabetyp der Funktion an: `Result<String, io::Error>`.
Das bedeutet, dass die Funktion einen Wert vom Typ `Result<T, E>` zurückgibt,
wobei der generische Typ `T` mit dem konkreten Typ `String` und der generische
Typ `E` mit dem konkreten Typ `io::Fehler` gefüllt wurde.

Wenn diese Funktion erfolgreich ist, erhält der aufrufende Code einen
`Ok`-Wert, der einen `String` enthält &ndash; den Benutzernamen, den diese
Funktion aus der Datei liest. Wenn diese Funktion auf Probleme stößt, erhält
der aufrufende Code einen `Err`-Wert, der eine Instanz von `io::Error` enthält,
mit weiteren Informationen darüber, was die Probleme waren. Wir wählten
`io::Error` als Rückgabetyp dieser Funktion, weil dies zufällig der Typ des
Fehlerwertes ist, der von beiden Operationen zurückgegeben wird, die wir im
Funktionsrumpf aufrufen und fehlschlagen könnten: Die Funktion `File::open` und
die Methode `read_to_string`.

Der Funktionsrumpf beginnt mit dem Aufruf der Funktion `File::open`. Dann
behandeln wir den `Result`-Wert, der von `match` zurückgegeben wird, auf
ähnliche Weise wie bei `match` in Codeblock 9-4. Wenn `File::open` erfolgreich
ist, erhält die Dateiressource in der Mustervariablen `file` den Wert in der
veränderlichen Variablen `username_file` und die Funktion wird fortgesetzt. Im
Fall von `Err` verwenden wir das Schlüsselwort `return`, anstatt `panic!`
aufzurufen, um die Funktion vorzeitig ganz zu verlassen und den Fehlerwert von
`File::open` in der Mustervariablen `e` als Fehlerwert dieser Funktion an den
aufrufenden Code zurückzugeben.

Wenn wir also eine Dateiressource in `username_file` haben, erzeugt die
Funktion einen neuen `String` in der Variablen `username` und ruft die Methode
`read_to_string` für die Dateiressource in `username_file` auf, um den Inhalt
der Datei in die Variable `username` zu lesen. Die Methode `read_to_string`
gibt ebenfalls ein `Result` zurück, weil sie fehlschlagen könnte, obwohl
`File::open` erfolgreich war. Wir brauchen also ein weiteres `match`, um dieses
`Result` zu verarbeiten: Wenn `read_to_string` erfolgreich ist, dann war unsere
Funktion erfolgreich und wir geben den Benutzernamen aus der Datei zurück, die
jetzt in `username` innerhalb `Ok` enthalten ist. Wenn `read_to_string`
fehlschlägt, geben wir den Fehlerwert auf die gleiche Weise zurück, wie wir den
Fehlerwert in `match` zurückgegeben haben, das den Rückgabewert von
`File::open` behandelt hat. Wir brauchen jedoch nicht ausdrücklich `return`
anzugeben, weil dies der letzte Ausdruck in der Funktion ist.

Der Code, der diesen Code aufruft, wird dann damit zurechtkommen, entweder
einen `Ok`-Wert zu erhalten, der einen Benutzernamen enthält, oder einen
`Err`-Wert, der einen `io::Error` enthält. Es ist Sache des aufrufenden Codes,
zu entscheiden, was mit diesen Werten geschehen soll. Wenn der aufrufende Code
einen `Err`-Wert erhält, könnte er `panic!` aufrufen und das Programm zum
Absturz bringen, einen Standardbenutzernamen verwenden oder den Benutzernamen
von irgendwo anders als z.B. einer Datei nachschlagen. Wir haben nicht genug
Informationen darüber, was der aufrufende Code tatsächlich versucht, also
propagieren wir alle Erfolgs- und Fehlerinformationen nach oben, damit sie
angemessen behandelt werden. Dieses Muster der Fehlerweitergabe ist in Rust so
verbreitet, dass Rust den Fragezeichen-Operator `?` bereitstellt, um dies zu
erleichtern.

#### Abkürzung zum Weitergeben von Fehlern: Der Operator `?`

Codeblock 9-7 zeigt eine Implementierung von `read_username_from_file`, die
dasselbe Verhalten wie Codeblock 9-6 hat, aber diese Implementierung verwendet
den `?`-Operator.

<span class="filename">Dateiname: src/main.rs</span>

```rust
use std::fs::File;
use std::io::{self, Read};

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
Werten eines Typs in einen anderen verwendet wird. Wenn der `?`-Operator die
Funktion `from` aufruft, wird der empfangene Fehlertyp in den Fehlertyp
umgewandelt, der als Rückgabetyp der aktuellen Funktion definiert ist. Das ist
hilfreich, wenn eine Funktion einen einzigen Fehlertyp zurückgibt, um alle
möglichen Fehlerarten einer Funktion darzustellen, auch wenn Teile aus vielen
verschiedenen Gründen versagen könnten.

Wir könnten zum Beispiel die Funktion `read_username_from_file` in Codeblock
9-7 so ändern, dass sie einen von uns definierten Fehlertyp namens `OurError`
zurückgibt. Wenn wir auch `impl From<io::Error> for OurError` definieren, um
eine Instanz von `OurError` aus einem `io::Error` zu konstruieren, dann werden
die `?`-Operator-Aufrufe im Rumpf von `read_username_from_file` `from` aufrufen
und die Fehlertypen konvertieren, ohne dass weiterer Code zur Funktion
hinzugefügt werden muss.

Im Zusammenhang mit Codeblock 9-7 gibt das `?` am Ende des Aufrufs von
`File::open` den Wert innerhalb eines `Ok` an die Variable `f`
zurück. Wenn ein Fehler auftritt, beendet der Operator vorzeitig die gesamte
Funktion und gibt dem aufrufenden Code einen `Err`-Wert zurück. Dasselbe gilt
für das `?` am Ende des `read_to_string`-Aufrufs.

Der `?`-Operator eliminiert viel umständlichen Code und macht die
Implementierung dieser Funktion einfacher. Wir können diesen Code sogar noch
weiter verkürzen, indem wir die Methodenaufrufe unmittelbar nach dem `?`
verketten, wie in Codeblock 9-8 zu sehen ist.

<span class="filename">Dateiname: src/main.rs</span>

```rust
use std::fs::File;
use std::io::{self, Read};

fn read_username_from_file() -> Result<String, io::Error> {
    let mut s = String::new();

    File::open("hallo.txt")?.read_to_string(&mut s)?;

    Ok(s)
}
```

<span class="caption">Codeblock 9-8: Verketten von Methodenaufrufen nach dem
`?`-Operator</span>

Wir haben das Erstellen des neuen `String` in `s` an den Anfang der
Funktion verlegt; dieser Teil hat sich nicht geändert. Anstatt eine Variable
`f` zu erzeugen, haben wir den Aufruf von `read_to_string` direkt
an das Ergebnis von `File::open("hallo.txt")?` gehängt. Wir haben immer noch
ein `?` am Ende des Aufrufs von `read_to_string`, und wir geben immer noch
einen `Ok`-Wert zurück, der `s` enthält, wenn sowohl `File::open` als
auch `read_to_string` erfolgreich sind, anstatt Fehler zurückzugeben. Die
Funktionalität ist wieder die gleiche wie in Codeblock 9-6 und Codeblock 9-7;
das ist nur eine andere, ergonomischere Schreibweise.

Codeblock 9-9 zeigt, dass es einen Weg gibt, diese Funktion noch kürzer zu
machen.

<span class="filename">Dateiname: src/main.rs</span>

```rust
use std::fs;
use std::io;

fn read_username_from_file() -> Result<String, io::Error> {
    fs::read_to_string("hallo.txt")
}
```

<span class="caption">Codeblock 9-9: Verwenden von `fs::read_to_string`,
anstatt die Datei zu öffnen und dann zu lesen</span>

Das Einlesen einer Datei in eine Zeichenkette ist eine ziemlich häufig
benötigte Operation, daher bringt die Standardbibliothek die praktische Funktion
`fs::read_to_string` mit, die die Datei öffnet, einen neuen `String` erzeugt,
den Inhalt der Datei einliest, den Inhalt in den `String` einfügt und ihn
zurückgibt. Natürlich gibt uns die Verwendung von `fs::read_to_string` nicht
die Möglichkeit, die ganze Fehlerbehandlung zu erklären, also haben wir es
zuerst auf dem längeren Weg gemacht.

#### Wo der Operator `?` verwendet werden kann

Der Operator `?` kann nur in Funktionen verwendet werden, deren Rückgabetyp mit
dem Wert, auf den `?` angewendet wird, kompatibel ist. Das liegt daran, dass
der Operator `?` so definiert ist, dass er einen Wert frühzeitig aus der
Funktion zurückgibt, genauso wie der Ausdruck `match`, den wir in Codeblock 9-6
definiert haben. In Codeblock 9-6 verwendet `match` einen `Result`-Wert, und
der frühe Rückgabezweig liefert einen `Err(e)`-Wert. Der Rückgabetyp der
Funktion muss ein `Result` sein, damit er mit `return` kompatibel ist.

Schauen wir uns in Codeblock 9-10 an, was passiert, wenn wir den `?`-Operator
in einer `main`-Funktion verwenden, deren Rückgabetyp nicht mit dem Typ des
Wertes, für den wir "?" verwenden, kompatibel ist:

<span class="filename">Dateiname: src/main.rs</span>

```rust,does_not_compile
use std::fs::File;

fn main() {
    let f = File::open("hallo.txt")?;
}
```

<span class="caption">Codeblock 9-10: Der Versuch, das `?` in der
`main`-Funktion zu verwenden, die `()` zurückgibt, lässt sich nicht
kompilieren</span>

Dieser Code öffnet eine Datei, was fehlschlagen kann. Der `?`-Operator folgt
dem `Result`-Wert, der von `File::open` zurückgegeben wird, aber diese
`main`-Funktion hat den Rückgabetyp `()`, nicht `Result`. Wenn wir diesen Code
kompilieren, erhalten wir folgende Fehlermeldung:

```console
$ cargo run
   Compiling error-handling v0.1.0 (file:///projects/error-handling)
error[E0277]: the `?` operator can only be used in a function that returns `Result` or `Option` (or another type that implements `FromResidual`)
   --> src/main.rs:4:13
    |
3   | / fn main() {
4   | |     let f = File::open("hallo.txt")?;
    | |                                    ^ cannot use the `?` operator in a function that returns `()`
5   | | }
    | |_- this function should return `Result` or `Option` to accept `?`
    |
    = help: the trait `FromResidual<Result<Infallible, std::io::Error>>` is not implemented for `()`
    = note: required by `from_residual`

For more information about this error, try `rustc --explain E0277`.
error: could not compile `error-handling` due to previous error
```

Dieser Fehler weist darauf hin, dass wir den `?`-Operator nur in einer Funktion
verwenden dürfen, die `Result` oder `Option` oder einen anderen Typ, der
`FromResidual` implementiert, zurückgibt.

Um den Fehler zu beheben, hast du zwei Möglichkeiten. Eine Möglichkeit besteht
darin, den Rückgabetyp deiner Funktion so zu ändern, dass er mit dem Wert
kompatibel ist, für den du den Operator `?` verwendest, wenn dem nichts
entgegensteht. Die andere Möglichkeit besteht darin, `match` oder eine der
Methoden von `Result<T, E>` zu verwenden, um `Result<T, E>` in geeigneter Weise
zu behandeln.

Die Fehlermeldung hat auch erwähnt, dass `?` ebenso mit `Option<T>`-Werten
verwendet werden kann. Wie bei der Verwendung von `?` für `Result`, kannst du
`?` für `Option` nur in einer Funktion verwenden, die eine `Option` zurückgibt.
Das Verhalten des `?`-Operators beim Aufruf auf eine `Option<T>` ist ähnlich
dem Verhalten, wenn er auf ein `Result<T, E>` aufgerufen wird: Wenn der Wert
`None` ist, wird `None` zu diesem Zeitpunkt von der Funktion zurückgegeben.
Wenn der Wert `Some` ist, ist der Wert innerhalb von `Some` der resultierende
Wert des Ausdrucks und die Funktion wird fortgesetzt. Codeblock 9-11 zeigt ein
Beispiel für eine Funktion, die das letzte Zeichen der ersten Zeile in einem
gegebenen Text findet:

```rust
fn last_char_of_first_line(text: &str) -> Option<char> {
    text.lines().next()?.chars().last()
}
#
# fn main() {
#     assert_eq!(
#         last_char_of_first_line("Hallo Welt\nWie geht es dir heute?"),
#         Some('t')
#     );
#
#     assert_eq!(last_char_of_first_line(""), None);
#     assert_eq!(last_char_of_first_line("\nhi"), None);
# }
```

<span class="caption">Codeblock 9-11: Verwenden des `?`-Operators auf einem
`Option<T>`-Wert</span>

Diese Funktion gibt `Option<char>` zurück, weil es möglich ist, dass ein
Zeichen vorhanden ist, aber es ist auch möglich, dass keines vorhanden ist.
Dieser Code nimmt das Zeichenkettenanteilstyp-Argument `text` und ruft die
Methode `lines` darauf auf, die einen Iterator über die Zeilen der Zeichenkette
zurückgibt. Da diese Funktion die erste Zeile untersuchen will, ruft sie `next`
auf dem Iterator auf, um den ersten Wert vom Iterator zu erhalten. Wenn `text`
die leere Zeichenkette ist, gibt dieser Aufruf von `next` `None` zurück, und
hier können wir `?` benutzen, um zu stoppen und `None` von
`last_char_of_first_line` zurückgeben, wenn dies der Fall ist. Wenn `text`
nicht die leere Zeichenkette ist, gibt `next` einen `Some`-Wert zurück, der
einen Zeichenkettenanteilstyp der ersten Zeile in `text` enthält.

Das `?` extrahiert den Zeichenkettenanteilstyp, und wir können `chars` auf
diesem Zeichenkettenanteilstyp aufrufen, um einen Iterator für seine Zeichen zu
erhalten. Wir sind am letzten Zeichen in dieser ersten Zeile interessiert, also
rufen wir `last` auf, um das letzte Element im Iterator über die Zeichen
zurückzugeben. Dies ist eine `Option`, weil die erste Zeile die leere
Zeichenkette sein kann, wenn `text` mit einer Leerzeile beginnt, aber Zeichen
in anderen Zeilen enthält, wie in `"\nhi"`. Wenn es jedoch ein letztes Zeichen
in der ersten Zeile gibt, wird es in der Variante `Some` zurückgegeben. Der
`?`-Operator in der Mitte gibt uns eine prägnante Möglichkeit, diese Logik
auszudrücken, und diese Funktion kann in einer Zeile implementiert werden. Wenn
wir den `?`-Operator nicht auf `Option` verwenden könnten, müssten wir diese
Logik mit weiteren Methodenaufrufen oder einem Ausdruck implementieren.

Beachte, dass du den `?`-Operator auf ein `Result` in einer Funktion anwenden
kannst, die `Result` zurückgibt, und du kannst den `?`-Operator auf eine
`Option` in einer Funktion anwenden, die `Option` zurückgibt, aber du kannst
nicht beides mischen. Der Operator `?` konvertiert nicht automatisch ein
`Result` in eine `Option` oder umgekehrt; in diesen Fällen kannst du Methoden
wie `ok` für `Result` oder `ok_or` für `Option` verwenden, die die Umwandlung
explizit vornehmen.

Bis jetzt haben alle `main`-Funktionen, die wir benutzt haben, `()`
zurückgegeben. Die Funktion `main` ist etwas Besonderes, weil sie der Ein- und
Ausstiegspunkt von ausführbaren Programmen ist, und es gibt Einschränkungen
hinsichtlich ihres Rückgabetyps, damit sich die Programme wie erwartet
verhalten.

Glücklicherweise kann `main` auch ein `Result<(), E>` zurückgeben. Codeblock
9-12 enthält den Code aus Codeblock 9-10, aber wir haben den Rückgabetyp von
`main` in `Result<(), Box<dyn Error>>` geändert und am Ende einen Rückgabewert
`Ok(())` hinzugefügt. Dieser Code wird nun kompilieren:

```rust,ignore
use std::error::Error;
use std::fs::File;

fn main() -> Result<(), Box<dyn Error>> {
    let f = File::open("hallo.txt")?;

    Ok(())
}
```

<span class="caption">Codeblock 9-12: Die Änderung von `main` zur Rückgabe von
`Result<(), E>` erlaubt die Verwendung des `?`-Operators für
`Result`-Werte</span>

Der Typ `Box<dyn Error>` ist ein *Merkmalsobjekt* (trait object), über das wir
im Abschnitt [„Merkmalsobjekte (trait objects) die Werte unterschiedlicher
Typen erlauben“][trait-objects] in Kapitel 17 sprechen werden. Vorerst kannst
du `Box<dyn Error>` als „eine beliebige Fehlerart“ ansehen. Das Verwenden von
`?` auf einen `Result`-Wert in einer `main`-Funktion mit dem Fehlertyp `Box<dyn
Error>` ist erlaubt, weil dadurch ein `Err`-Wert frühzeitig zurückgegeben
werden kann. Obwohl der Rumpf dieser `main`-Funktion nur Fehler des Typs
`std::io::Error` zurückgibt, ist diese Signatur durch die Angabe von
`Box<dyn Error>` auch dann noch korrekt, wenn weiterer Code, der andere Fehler
zurückgibt, dem Rumpf von `main` hinzugefügt wird.

Wenn eine `main`-Funktion ein `Result<(), E>` zurückgibt, beendet sich die
ausführbare Datei mit einem Wert von `0`, wenn `main` den Wert `Ok(())`
zurückgibt, und mit einem Wert ungleich Null, wenn `main` einen `Err`-Wert
zurückgibt. In C geschriebene ausführbare Programme geben beim Beenden ganze
Zahlen zurück: Programme, die erfolgreich beendet werden, geben die Zahl `0`
zurück, und Programme, die einen Fehler machen, geben eine Zahl ungleich `0`
zurück. Rust gibt ebenfalls ganze Zahlen aus ausführbaren Dateien zurück, um
mit dieser Konvention kompatibel zu sein.

Die Funktion `main` kann jeden Typ zurückgeben, der [das Merkmal
`std::process::Termination`][termination] implementiert, das eine Funktion
`report` enthält, die einen `ExitCode` zurückgibt. Weitere Informationen zur
Implementierung des Merkmals `Termination` für deine eigenen Typen findest du
in der Dokumentation der Standardbibliothek.

Nachdem wir nun die Einzelheiten des Aufrufs von `panic!` und der Rückgabe von
`Result` besprochen haben, wollen wir zum Thema zurückkehren, wie wir
entscheiden können, was in welchen Fällen angemessen ist.

[handle_failure]: ch02-00-guessing-game-tutorial.html#behandeln-potentieller-fehler-mit-dem-typ-result
[termination]: https://doc.rust-lang.org/std/process/trait.Termination.html
[trait-objects]: ch17-02-trait-objects.html
