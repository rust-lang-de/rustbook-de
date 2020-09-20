## Fortgeschrittene Typen

Das Rust-Typsystem weist einige Funktionalitäten auf, die wir in diesem Buch
erwähnt, aber noch nicht besprochen haben. Wir beginnen mit einer allgemeinen
Diskussion über Newtypes, während wir untersuchen, warum Newtypes als Typen
nützlich sind. Dann gehen wir zu Typ-Alias über, einer Funktionalität, die den
Newtypes ähnlich ist, aber eine etwas andere Semantik hat. Wir werden auch den
Typ `!` und dynamisch große Typen besprechen.

> Hinweis: Der nächste Abschnitt geht davon aus, dass du den früheren Abschnitt
> [„Verwenden des Newtype-Musters zum Implementieren von externen Merkmalen auf
> externen Typen“][using-the-newtype-pattern] gelesen hast.

### Verwenden des Newtype-Musters für Typsicherheit und Abstraktion

Das Newtype-Muster ist nützlich für Aufgaben, die über die bisher besprochenen
hinausgehen, einschließlich statisch sicherzustellen, dass Werte niemals
verwechselt werden, und dem Angeben von Einheiten eines Wertes. Ein Beispiel
für die Verwendung von Newtypes zum Angeben von Einheiten hast du in Codeblock
19-15 gesehen: Erinnere dich daran, dass die Strukturen `Millimeters` und
`Meters` `u32`-Werte in einem Newtype einpacken. Wenn wir eine Funktion mit
einem Parameter vom Typ `Millimeters` schreiben würden, könnten wir kein
Programm kompilieren, das versehentlich versucht, diese Funktion mit einem Wert
vom Typ `Meters` oder einem einfachen `u32` aufzurufen.

Eine weitere Verwendung des Newtype-Musters besteht darin, einige
Implementierungsdetails eines Typs zu abstrahieren: Der neue Typ kann eine
öffentliche API bereitstellen, die sich von der API des privaten, inneren Typs
unterscheidet, wenn wir den neuen Typ z.B. direkt verwendet haben, um die
verfügbare Funktionalität einzuschränken.

Newtypes können auch die interne Implementierung verbergen. Zum Beispiel
könnten wir einen Typ `People` zur Verfügung stellen, um eine `HashMap<i32,
String>` einzupacken, die die ID einer Person in Verbindung mit ihrem Namen
speichert. Code, der `People` verwendet, würde nur mit der öffentlichen API
interagieren, die wir zur Verfügung stellen, z.B. eine Methode, um eine
Namenszeichenkette zur `People`-Kollektion hinzuzufügen; dieser Code müsste
nicht wissen, dass wir Namen intern eine `i32`-ID zuordnen. Das Newtype-Muster
ist ein leichtgewichtiger Weg, eine Kapselung zu erreichen, um
Implementierungsdetails zu verbergen, die wir im Abschnitt [„Kapselung, die
Implementierungsdetails verbirgt“][encapsulation] in Kapitel 17 besprochen
haben.

### Erstellen von Typ-Synonymen mit Typ-Alias

Zusammen mit dem Newtype-Muster bietet Rust die Möglichkeit, einen *Typ-Alias*
zu deklarieren, um einem vorhandenen Typ einen anderen Namen zu geben. Hierfür
verwenden wir das Schlüsselwort `type`. Zum Beispiel können wir den Alias
`Kilometers` für `i32` so anlegen:

```rust
    type Kilometers = i32;
#
#     let x: i32 = 5;
#     let y: Kilometers = 5;
#
#     println!("x + y = {}", x + y);
```

Der Alias `Kilometers` ist ein *Synonym* für `i32`; im Gegensatz zu den Typen
`Millimeters` und `Meters`, die wir in Codeblock 19-15 erstellt haben, ist
`Kilometers` kein separater, neuer Typ. Werte, die den Typ `Kilometers` haben,
werden genauso behandelt wie Werte des Typs `i32`:

```rust
    type Kilometers = i32;

    let x: i32 = 5;
    let y: Kilometers = 5;

    println!("x + y = {}", x + y);
```

Da `Kilometers` und `i32` vom gleichen Typ sind, können wir Werte beider Typen
addieren und wir können `Kilometers`-Werte an Funktionen übergeben, die
`i32`-Parameter verwenden. Mit dieser Methode erhalten wir jedoch nicht die
Vorteile der Typprüfung, die wir vom zuvor besprochenen Newtype-Muster haben.

Der Hauptanwendungsfall für Typ-Synonyme ist das Reduzieren von Wiederholungen.
Zum Beispiel könnten wir einen längeren Typ wie diesen haben:

```rust,ignore
Box<dyn Fn() + Send + 'static>
```

Das Schreiben dieses langen Typs in Funktionssignaturen und als
Typ-Annotationen im gesamten Code kann ermüdend und fehleranfällig sein. Stelle
dir vor, du hättest ein Projekt voller Code wie das in Codeblock 19-24.

```rust
    let f: Box<dyn Fn() + Send + 'static> = Box::new(|| println!("hallo"));

    fn takes_long_type(f: Box<dyn Fn() + Send + 'static>) {
        // --abschneiden--
    }

    fn returns_long_type() -> Box<dyn Fn() + Send + 'static> {
        // --abschneiden--
#         Box::new(|| ())
    }
```

<span class="caption">Codeblock 19-24: Verwenden eines langen Typs an vielen
Stellen</span>

Ein Typ-Alias macht diesen Code leichter handhabbar, indem er die Wiederholung
reduziert. In Codeblock 19-25 haben wir einen Alias namens `Thunk` für den
verbosen Typ eingeführt und können alle Verwendungen des Typs durch den
kürzeren Alias `Thunk` ersetzen.

```rust
    type Thunk = Box<dyn Fn() + Send + 'static>;

    let f: Thunk = Box::new(|| println!("hallo"));

    fn takes_long_type(f: Thunk) {
        // --abschneiden--
    }

    fn returns_long_type() -> Thunk {
        // --abschneiden--
#         Box::new(|| ())
    }
```

<span class="caption">Codeblock 19-25: Einführen eines Typ-Alias `Thunk` zur
Reduzierung von Wiederholungen</span>

Dieser Code ist viel einfacher zu lesen und zu schreiben! Die Wahl eines
aussagekräftigen Namens für einen Typ-Alias kann auch helfen, deine Absicht zu
kommunizieren (*thunk* ist ein Wort für Code, der zu einem späteren Zeitpunkt
ausgewertet wird, also ein passender Name für einen Funktionsabschluss
(closure), der gespeichert wird).

Typ-Alias werden auch häufig mit dem Typ `Result<T, E>` verwendet, um
Wiederholungen zu reduzieren. Betrachte das Modul `std::io` in der
Standardbibliothek. E/A-Operationen geben oft ein `Result<T, E>` zurück, um
Situationen zu behandeln, in denen Operationen nicht funktionieren. Diese
Bibliothek hat eine Struktur `std::io::Error`, die alle möglichen E/A-Fehler
repräsentiert. Viele der Funktionen in `std::io` geben `Result<T, E>` zurück,
wobei für `E` der Typ `std::io::Error` verwendet wird, so wie bei diesen
Funktionen im Merkmal (trait) `Write`:

```rust
use std::fmt;
use std::io::Error;

pub trait Write {
    fn write(&mut self, buf: &[u8]) -> Result<usize, Error>;
    fn flush(&mut self) -> Result<(), Error>;

    fn write_all(&mut self, buf: &[u8]) -> Result<(), Error>;
    fn write_fmt(&mut self, fmt: fmt::Arguments) -> Result<(), Error>;
}
```

`Result<..., Error>` wird oft wiederholt. Daher hat `std::io` diese Art von
Alias-Deklaration:

```rust
# use std::fmt;
#
type Result<T> = std::result::Result<T, std::io::Error>;
#
# pub trait Write {
#     fn write(&mut self, buf: &[u8]) -> Result<usize>;
#     fn flush(&mut self) -> Result<()>;
#
#     fn write_all(&mut self, buf: &[u8]) -> Result<()>;
#     fn write_fmt(&mut self, fmt: fmt::Arguments) -> Result<()>;
# }
#
# fn main() {}
```

Da sich diese Deklaration im Modul `std::io` befindet, können wir den
vollständig qualifizierten Alias `std::io::Result<T>` verwenden &ndash; das ist
ein `Result<T, E>` mit `E` als `std::io::Error`. Die Funktionssignaturen des
Merkmals `Write` sehen am Ende so aus:

```rust
# use std::fmt;
#
# type Result<T> = std::result::Result<T, std::io::Error>;
#
pub trait Write {
    fn write(&mut self, buf: &[u8]) -> Result<usize>;
    fn flush(&mut self) -> Result<()>;

    fn write_all(&mut self, buf: &[u8]) -> Result<()>;
    fn write_fmt(&mut self, fmt: fmt::Arguments) -> Result<()>;
}
#
# fn main() {}
```

Der Typ-Alias hilft in zweierlei Hinsicht: Er macht es einfacher, Code zu
schreiben *und* er gibt uns eine konsistente Schnittstelle innerhalb `std::io`.
Weil es ein Alias ist, ist es nur ein weiteres `Result<T, E>`, was bedeutet,
dass wir alle Methoden, die mit `Result<T, E>` funktionieren, mit ihm verwenden
können, einschließlich spezieller Syntax wie der `?`-Operator.

### Der Niemals-Typ, der niemals zurückkehrt

Rust hat einen speziellen Typ namens `!`, der im Fachjargon der Typtheorie als
*leerer Typ* (empty type) bekannt ist, weil er keine Werte hat. Wir ziehen es
vor, ihn den *Niemals-Typ* (never type) zu nennen, weil er an der Stelle des
Rückgabetyps steht, wenn eine Funktion niemals zurückkehrt. Hier ist ein
Beispiel:

```rust
fn bar() -> ! {
    // --abschneiden--
#     panic!();
}
#
# fn main() {}
```

Dieser Code wird als „die Funktion `bar` kehrt niemals zurück“ gelesen.
Funktionen, die niemals zurückkehren, werden *divergierende Funktionen*
(diverging functions) genannt. Wir können keine Werte vom Typ `!` erzeugen,
also kann `bar` niemals zurückkehren.

Aber was nützt ein Typ, für den man niemals Werte erzeugen kann? Erinnere dich
an den Code aus Codeblock 2-5; wir haben einen Teil davon hier in Codeblock
19-26 wiedergegeben.

```rust,ignore
# use rand::Rng;
# use std::cmp::Ordering;
# use std::io;
#
# fn main() {
#     println!("Rate die Zahl!");
#
#     let secret_number = rand::thread_rng().gen_range(1, 101);
#
#     println!("Die Geheimzahl ist: {}", secret_number);
#
#     loop {
#         println!("Bitte gib deine Schätzung ein.");
#
#         let mut guess = String::new();
#
#         // --abschneiden--
#
#         io::stdin()
#             .read_line(&mut guess)
#             .expect("Fehler beim Lesen der Zeile");
#
        let guess: u32 = match guess.trim().parse() {
            Ok(num) => num,
            Err(_) => continue,
        };
#
#         println!("Du hast geschätzt: {}", guess);
#
#         // --abschneiden--
#
#         match guess.cmp(&secret_number) {
#             Ordering::Less => println!("Zu klein!"),
#             Ordering::Greater => println!("Zu groß!"),
#             Ordering::Equal => {
#                 println!("Du hast gewonnen!");
#                 break;
#             }
#         }
#     }
# }
```

<span class="caption">Codeblock 19-26: Ein `match` mit einem Zweig, der in
`continue` endet</span>

Damals haben wir einige Details in diesem Code übersprungen. In Kapitel 6 des
Abschnitts [„Der Kontrollflussoperator `match`“][match-operator] haben wir
erwähnt, dass alle Zweige den gleichen Typ zurückgeben müssen. So funktioniert
zum Beispiel der folgende Code nicht:

```rust,does_not_compile
#     let guess = "3";
    let guess = match guess.trim().parse() {
        Ok(_) => 5,
        Err(_) => "hallo",
    };
```

Der Typ von `guess` in diesem Code müsste eine ganze Zahl *und* eine
Zeichenkette sein und Rust verlangt, dass `guess` nur einen Typ hat. Was gibt
also `continue` zurück? Wie war es uns erlaubt, ein `u32` von einem Zweig
zurückzugeben und einen anderen Zweig zu haben, der in Codeblock 19-26 mit
`continue` endet?

Wie du vielleicht schon vermutet hast, hat `continue` einen `!`-Wert. Das
heißt, wenn Rust den Typ von `guess` berechnet, betrachtet es beide
`match`-Zweige, den ersten mit einem Wert von `u32` und den zweiten mit einem
`!`-Wert. Da `!` niemals einen Wert haben kann, entscheidet Rust, dass `guess`
den Typ `u32` hat.

Der formale Weg, dieses Verhalten zu beschreiben, besteht darin, dass Ausdrücke
vom Typ `!` in jeden anderen Typ umgewandelt werden können. Es ist uns erlaubt,
diesen `match`-Zweig mit `continue` zu beenden, weil `continue` keinen Wert
zurückgibt; stattdessen bringt es die Kontrolle zurück an den Anfang der
Schleife, sodass wir im `Err`-Fall `guess` niemals einen Wert zuweisen.

Der Niemals-Typ ist auch beim Makro `panic!` nützlich. Erinnere dich an die
Funktion `unwrap`, die wir auf `Option<T>` Werte aufrufen, um einen Wert zu
erzeugen oder das Programm abstürzen zu lassen. Hier ist ihre Definition:

```rust
# enum Option<T> {
#     Some(T),
#     None,
# }
#
# use crate::Option::*;
#
impl<T> Option<T> {
    pub fn unwrap(self) -> T {
        match self {
            Some(val) => val,
            None => panic!("called `Option::unwrap()` on a `None` value"),
        }
    }
}
#
# fn main() {}
```

In diesem Code geschieht dasselbe wie bei `match` in Codeblock 19-26: Rust
sieht, dass `val` den Typ `T` und `panic!` den Typ `!` hat, sodass das Ergebnis
des gesamten `match`-Ausdrucks `T` ist. Dieser Code funktioniert, weil `panic!`
keinen Wert produziert; es beendet das Programm. Im Fall von `None` geben wir
keinen Wert von `unwrap` zurück, also ist dieser Code gültig.

Ein letzter Ausdruck, der den Typ `!` hat, ist `loop`:

```rust
    print!("für immer ");

    loop {
        print!("und ewig ");
    }
```

Hier endet die Schleife nie, also ist `!` der Typ des Ausdrucks. Dies wäre
jedoch nicht der Fall, wenn wir `break` einfügen würden, da die Schleife enden
würde, wenn sie bei `break` ankommt.

### Dynamisch große Typen und das Merkmal `Sized`

Aufgrund Rusts Bedürfnis, bestimmte Details zu kennen, z.B. wie viel Platz für
einen Wert eines bestimmten Typs zuzuweisen ist, gibt es eine Ecke seines
Typsystems, die verwirrend sein kann: Das Konzept der *dynamisch großen Typen*
(dynamically sized types). Diese Typen, die manchmal als *DSTs* oder *Typen
ohne Größe* (unsized types) bezeichnet werden, erlauben es uns, Code mit Werten
zu schreiben, deren Größe wir nur zur Laufzeit kennen können.

Schauen wir uns die Details eines dynamisch großen Typs namens `str` an, den
wir im ganzen Buch verwendet haben. Das stimmt, nicht `&str`, sondern `str` an
sich ist ein DST. Wir können nicht wissen, wie lang die Zeichenkette zur
Laufzeit ist, d.h. wir können weder eine Variable vom Typ `str` erzeugen, noch
können wir ein Argument vom Typ `str` nehmen. Betrachte den folgenden Code, der
nicht funktioniert:

```rust,does_not_compile
    let s1: str = "Guten Tag!";
    let s2: str = "Wie geht es dir?";

```

Rust muss wissen, wie viel Speicher jedem Wert eines bestimmten Typs zuzuweisen
ist, und alle Werte eines Typs müssen die gleiche Speichermenge verwenden. Wenn
Rust uns erlauben würde, diesen Code zu schreiben, müssten diese beiden
`str`-Werte die gleiche Speichermenge beanspruchen. Aber sie haben
unterschiedliche Längen: `s1` benötigt 10 Bytes Speicherplatz und `s2` 16
Bytes. Aus diesem Grund ist es nicht möglich, eine Variable zu erzeugen, die
einen dynamisch großen Typ enthält.

Was sollen wir also tun? In diesem Fall kennst du die Antwort bereits: Wir
machen die Typen `s1` und `s2` zu einem `&str` anstatt zu einem `str`. Erinnere
dich, dass wir im Abschnitt [„Zeichenkettenanteilstypen
(string slices)“][string-slices] in Kapitel 4 gesagt haben, dass die
Anteilstypen-Datenstruktur die Startposition und die Länge des Anteilstyps
speichert.

Obwohl also `&T` ein einzelner Wert ist, der die Speicheradresse des Ortes
speichert, an dem sich `T` befindet, hat `&str` *zwei* Werte: Die Adresse von
`str` und seine Länge. Als solches können wir die Größe eines `&str`-Wertes zur
Kompilierzeit kennen: Er ist doppelt so lang wie ein `usize`. Das heißt, wir
wissen immer die Größe einer `&str`, egal wie lang die Zeichenkette ist, auf
die sie sich bezieht. Im Allgemeinen werden in Rust Typen mit dynamischer Größe
auf diese Weise verwendet: Sie haben ein zusätzliches Stück Metadaten, das die
Größe der dynamischen Information speichert. Die goldene Regel für Typen
dynamischer Größe lautet, dass wir Werte von Typen mit dynamischer Größe immer
hinter eine Art Zeiger stellen müssen.

Wir können `str` mit allen Arten von Zeigern kombinieren: Zum Beispiel
`Box<str>` oder `Rc<str>`. Tatsächlich hast du das schon einmal gesehen, aber
mit einem anderen dynamisch großen Typ: Merkmale (traits). Jedes Merkmal ist
ein dynamisch großer Typ, auf den wir uns beziehen können, indem wir den Namen
des Merkmals verwenden. In Kapitel 17 im Abschnitt [„Merkmalsobjekte (trait
objects) die Werte unterschiedlicher Typen erlauben“][using-trait-objects]
haben wir erwähnt, dass wir, um Merkmale als Merkmalsobjekte zu verwenden,
diese hinter einen Zeiger setzen müssen, z.B. `&dyn Trait` oder `Box<dyn
Trait>` (`Rc<dyn Trait>` würde auch funktionieren).

Um mit DSTs zu arbeiten, hat Rust ein bestimmtes Merkmal, das `Sized` genannt
wird, um zu bestimmen, ob die Größe eines Typs zur Kompilierzeit bekannt ist
oder nicht. Dieses Merkmal wird automatisch für alles implementiert, dessen
Größe zur Kompilierzeit bekannt ist. Zusätzlich fügt Rust implizit jeder
generischen Funktion eine Merkmalsabgrenzung auf `Sized` hinzu. Das heißt, eine
generische Funktionsdefinition wie diese:

```rust
fn generic<T>(t: T) {
    // --abschneiden--
}
```

wird tatsächlich so behandelt, als hätten wir das geschrieben:

```rust
fn generic<T: Sized>(t: T) {
    // --abschneiden--
}
```

Standardmäßig funktionieren generische Funktionen nur bei Typen, die zur
Kompilierzeit eine bekannte Größe haben. Du kannst jedoch die folgende
spezielle Syntax verwenden, um diese Einschränkung zu lockern:

```rust
fn generic<T: ?Sized>(t: &T) {
    // --abschneiden--
}
```

Eine Merkmalsabgrenzung durch `?Sized` ist das Gegenteil einer
Merkmalsabgrenzung durch `Sized`: Wir würden dies lesen als „`T` kann aber muss
nicht `Sized` sein“. Diese Syntax ist nur für `Sized` verfügbar, nicht für
andere Merkmale.

Beachte auch, dass wir den Typ des Parameters `t` von `T` auf `&T` geändert
haben. Da der Typ möglicherweise nicht `Sized` ist, müssen wir ihn hinter einer
Art Zeiger verwenden. In diesem Fall haben wir eine Referenz gewählt.

Als nächstes werden wir über Funktionen und Funktionsabschlüsse sprechen!

[encapsulation]:
ch17-01-what-is-oo.html#kapselung-die-implementierungsdetails-verbirgt
[string-slices]: ch04-03-slices.html#zeichenkettenanteilstypen-string-slices
[match-operator]: ch06-02-match.html
[using-trait-objects]: ch17-02-trait-objects.html
[using-the-newtype-pattern]:
ch19-03-advanced-traits.html#verwenden-des-newtype-musters-zum-implementieren-von-externen-merkmalen-auf-externen-typen
