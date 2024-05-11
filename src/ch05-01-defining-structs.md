## Strukturen (structs) definieren und instanziieren

Strukturen (structs) ähneln Tupeln, die im Abschnitt [„Der Tupel-Typ“][tuples]
besprochen wurden. Wie bei Tupeln können die Teile einer Struktur verschiedene
Typen haben. Anders als bei Tupeln benennst du jedes Teil, so dass klar ist, was
die Werte bedeuten. Durch diese Namen sind Strukturen flexibler als Tupel: Du
musst dich nicht auf die Reihenfolge der Daten verlassen, um die Werte einer
Instanz zu spezifizieren oder auf sie zuzugreifen.

Um eine Struktur zu definieren, geben wir das Schlüsselwort `struct` an und
benennen die gesamte Struktur. Der Name einer Struktur sollte die Bedeutung der
Daten beschreiben, die gruppiert werden. Dann definieren wir innerhalb
geschweifter Klammern die Namen und Typen der Datenteile, die wir *Felder*
nennen. Beispielsweise zeigt Codeblock 5-1 eine Struktur, die Informationen
über ein Benutzerkonto speichert.

<span class="filename">Dateiname: src/main.rs</span>

```rust
struct User {
    active: bool,
    username: String,
    email: String,
    sign_in_count: u64,
}
```

<span class="caption">Codeblock 5-1: Definition der Struktur `User`</span>

Um eine Struktur zu verwenden, nachdem wir sie definiert haben, erstellen wir
eine *Instanz* dieser Struktur, indem wir für jedes Feld einen konkreten Wert
angeben. Wir erzeugen eine Instanz, indem wir den Namen der Struktur angeben
und dann in geschweiften Klammern die *Schlüssel: Wert*-Paare angeben, wobei
die Schlüssel die Namen der Felder und die Werte die Daten sind, die wir in
diesen Feldern speichern wollen. Wir müssen die Felder nicht in der gleichen
Reihenfolge angeben, in der wir sie in der Struktur deklariert haben. Anders
gesagt ist die Strukturdefinition wie eine allgemeine Typvorlage und Instanzen
füllen diese Vorlage mit bestimmten Daten aus, um Werte des Typs zu erzeugen.
Beispielsweise können wir einen bestimmten Benutzer deklarieren, wie in
Codeblock 5-2 zu sehen ist.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# struct User {
#     active: bool,
#     username: String,
#     email: String,
#     sign_in_count: u64,
# }
#
fn main() {
    let user1 = User {
        active: true,
        username: String::from("benutzername123"),
        email: String::from("jemand@example.com"),
        sign_in_count: 1,
    };
}
```

<span class="caption">Codeblock 5-2: Eine Instanz der Struktur `User`
erzeugen</span>

Um auf einen bestimmten Wert in einer Struktur zuzugreifen, verwenden wir die
Punktnotation. Um beispielsweise auf die E-Mail-Adresse dieses Benutzers
zuzugreifen, verwenden wir `user1.email`. Wenn die Instanz veränderbar ist,
können wir einen Wert ändern, indem wir die Punktnotation verwenden und ihn
einem bestimmten Feld zuweisen. Codeblock 5-3 gezeigt, wie der Wert im Feld
`email` einer veränderbaren `User`-Instanz geändert werden kann.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# struct User {
#     active: bool,
#     username: String,
#     email: String,
#     sign_in_count: u64,
# }
#
fn main() {
    let mut user1 = User {
        active: true,
        username: String::from("benutzername123"),
        email: String::from("jemand@example.com"),
        sign_in_count: 1,
    };

    user1.email = String::from("andere-email@example.com");
}
```

<span class="caption">Codeblock 5-3: Wert im Feld `email` einer `User`-Instanz ändern</span>

Beachte, dass die gesamte Instanz veränderbar sein muss. Rust erlaubt es
nicht, nur einzelne Felder als veränderbar zu markieren. Wie mit jedem
Ausdruck können wir eine neue Instanz der Struktur als letzten Ausdruck im
Funktionsrumpf erzeugen, um diese neue Instanz implizit zurückzugeben.

Codeblock 5-4 zeigt eine Funktion `build_user`, die eine `User`-Instanz mit der
angegebenen E-Mail und dem Benutzernamen zurückgibt. Das Feld `active` erhält
den Wert `true` und das Feld `sign_in_count` den Wert `1`.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# struct User {
#     active: bool,
#     username: String,
#     email: String,
#     sign_in_count: u64,
# }
#
fn build_user(email: String, username: String) -> User {
    User {
        active: true,
        username: username,
        email: email,
        sign_in_count: 1,
    }
}
#
# fn main() {
#     let user1 = build_user(
#         String::from("jemand@example.com"),
#         String::from("benutzername123"),
#     );
# }
```

<span class="caption">Codeblock 5-4: Funktion `build_user`, die eine E-Mail und
einen Benutzernamen entgegennimmt und eine `User`-Instanz zurückgibt</span>

Es ist sinnvoll, den Funktionsparametern dieselben Namen wie die der
Strukturfelder zu geben, jedoch ist das Wiederholen der Feldnamen `email` und
`username` etwas mühsam. Wenn die Struktur mehr Felder hätte, würde das
Wiederholen jedes Namens noch lästiger werden. Glücklicherweise gibt es eine
praktische Kurznotation!

### Kurznotation der Feld-Initialisierung verwenden

Da die Parameter und die Strukturfelder in Codeblock 5-4 die gleichen Namen
haben, können wir die *Kurznotation der Feld-Initialisierung* (field init
shorthand syntax) verwenden, um die Funktion `build_user` so umzuschreiben,
dass sie sich unverändert gleich verhält, ohne `email` und `username` zu
wiederholen, siehe Codeblock 5-5.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# struct User {
#     active: bool,
#     username: String,
#     email: String,
#     sign_in_count: u64,
# }
#
fn build_user(email: String, username: String) -> User {
    User {
        active: true,
        username,
        email,
        sign_in_count: 1,
    }
}
#
# fn main() {
#     let user1 = build_user(
#         String::from("jemand@example.com"),
#         String::from("benutzername123"),
#     );
# }
```

<span class="caption">Codeblock 5-5: Funktion `build_user` mit Kurznotation der
Feld-Initialisierung, weil die Parameternamen `email` und `username` identisch
mit den Strukturfeldern sind</span>

Hier erzeugen wir eine neue Instanz der Struktur `User`, die ein Feld namens
`email` hat. Wir wollen den Wert des Feldes `email` auf den Wert des Parameters
`email` der Funktion `build_user` setzen. Da das Feld `email` und der Parameter
`email` den gleichen Namen haben, brauchen wir nur `email` statt `email: email`
zu schreiben.

### Instanzen aus anderen Instanzen erzeugen mit der Strukturaktualisierungssyntax

Oft ist es hilfreich, eine neue Instanz einer Struktur zu erstellen, die die
meisten Werte einer alten Instanz verwendet und nur einige davon verändert. Du
kannst dazu die *Strukturaktualisierungssyntax* (struct update syntax)
verwenden.

Zunächst zeigt Codeblock 5-6, wie wir eine neue `User`-Instanz `user2` ohne
Aktualisierungssyntax erstellen. Wir setzen einen neuen Wert für `email`,
verwenden aber ansonsten die gleichen Werte von `user1`, die wir in Codeblock
5-2 erstellt haben.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# struct User {
#     active: bool,
#     username: String,
#     email: String,
#     sign_in_count: u64,
# }
#
fn main() {
    // --abschneiden--
#     let user1 = User {
#         email: String::from("jemand@example.com"),
#         username: String::from("benutzername123"),
#         active: true,
#         sign_in_count: 1,
#     };

    let user2 = User {
        active: user1.active,
        username: user1.username,
        email: String::from("andere@example.com"),
        sign_in_count: user1.sign_in_count,
    };
}
```

<span class="caption">Codeblock 5-6: Erstellen einer neuen `User`-Instanz unter
Verwendung aller Werte von `user1` bis auf einen.</span>

Durch Verwenden der Strukturaktualisierungssyntax können wir dasselbe Ergebnis
mit weniger Code erreichen, wie Codeblock 5-7 zeigt. Die Syntax `..` gibt an,
dass die restlichen Felder, die nicht explizit gesetzt wurden, den gleichen
Wert haben sollen wie die Felder in der gegebenen Instanz.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# struct User {
#     active: bool,
#     username: String,
#     email: String,
#     sign_in_count: u64,
# }
#
fn main() {
    // --abschneiden--
#     let user1 = User {
#         email: String::from("jemand@example.com"),
#         username: String::from("benutzername123"),
#         active: true,
#         sign_in_count: 1,
#     };

    let user2 = User {
        email: String::from("andere@example.com"),
        ..user1
    };
}
```

<span class="caption">Codeblock 5-7: Verwenden der
Strukturaktualisierungssyntax, um einen neuen Wert für `email` in der
`User`-Instanz zu setzen und die restlichen Werte aus der Instanz `user1` zu
übernehmen</span>

Der Code in Codeblock 5-7 erzeugt auch eine Instanz `user2`, die einen anderen
Wert für `email` hat, aber die gleichen Werte der Felder `username`, `active`
und `sign_in_count` wie `user1`. Das `..user1` muss an letzter Stelle stehen um
festzulegen, dass alle verbleibenden Felder ihre Werte von den entsprechenden
Feldern in `user1` beziehen sollen, aber wir können Werte für so viele Felder
in beliebiger Reihenfolge angeben, unabhängig von der Reihenfolge der Felder in
der Strukturdefinition.

Beachte, dass die Strukturaktualisierungssyntax wie eine Zuweisung mit `=` ist,
da sie die Daten verschiebt, wie wir im Abschnitt [„Variablen und Daten im
Zusammenspiel mit Move“][move] gesehen haben. In diesem Beispiel können wir
`user1` nicht mehr als Ganzes verwenden, nachdem wir `user2` erzeugt haben,
weil der `String` im Feld `username` von `user1` in `user2` verschoben wurde.
Hätten wir `user2` neue `String`-Werte für beide Felder `email` und `username`
gegeben und somit nur die Werte `active` und `sign_in_count` von `user1`
verwendet, wäre `user1` auch nach dem Erstellen von `user2` noch gültig. Die
Typen `active` und `sign_in_count` sind Typen, die das Merkmal `Copy`
implementieren, sodass das Verhalten, das wir im Abschnitt [„Nur
Stapelspeicher-Daten: Kopieren (copy)“][copy] besprochen haben, zutreffen
würde.

### Verwenden von Tupel-Strukturen ohne benannte Felder um verschiedene Typen zu erzeugen

Du kannst auch Strukturen definieren, die wie Tupel aussehen, sogenannte
*Tupel-Strukturen* (tuple structs). Tupel-Strukturen sind Strukturen, die
keine Feldnamen haben, sondern nur die Typen der Felder. Tupel-Strukturen sind
hilfreich, wenn du dem gesamten Tupel einen Namen geben und erreichen willst,
dass das Tupel einen anderen Typ als die anderen Tupel hat und Feldnamen wie in
einer regulären Struktur langatmig oder unnötig wären.

Um eine Tupel-Struktur zu definieren, starte mit dem Schlüsselwort `struct`,
gefolgt vom Strukturnamen und den Typen im Tupel. Nachfolgend ein Beispiel mit
Definition und Verwendung zweier Tupel-Strukturen `Color` und `Point`:

<span class="filename">Dateiname: src/main.rs</span>

```rust
struct Color(i32, i32, i32);
struct Point(i32, i32, i32);

fn main() {
    let black = Color(0, 0, 0);
    let origin = Point(0, 0, 0);
}
```

Beachte, dass die Werte `black` und `origin` unterschiedliche Typen haben, weil
sie Instanzen unterschiedlicher Tupel-Strukturen sind. Jede von dir definierte
Struktur ist ein eigenständiger Typ, auch wenn die Felder innerhalb der
Struktur die gleichen Typen haben könnten. Zum Beispiel kann eine Funktion, die
einen Parameter vom Typ `Color` hat, keinen `Point` als Argument nehmen, obwohl
beide Typen aus drei `i32`-Werten bestehen. Ansonsten ähneln
Tupel-Struktur-Instanzen den Tupeln insofern, als dass sie in ihre einzelnen
Teile zerlegt werden können, und du kannst ein `.` gefolgt vom Index verwenden,
um auf einen einzelnen Wert zuzugreifen.

### Einheitstyp-ähnliche Strukturen ohne Felder

Du kannst auch Strukturen definieren, die gar keine Felder haben! Diese werden
*Einheitstyp* (unit-like structs) genannt, weil sie sich ähnlich zum leeren
Tupel `()` verhalten, das wir im Abschnitt [„Der Tupel-Typ“][tuples] erwähnt
haben. Einheitstypen können in Situationen nützlich sein, in denen du ein
Merkmal (trait) zu einem Typ implementieren musst, du aber keine Daten hast,
die im Typ gespeichert werden sollen. Wir werden Merkmale in Kapitel 10
besprechen. Hier ist ein Beispiel für die Deklaration und Instanziierung einer
Unit-Struktur namens `AlwaysEqual`:

<span class="filename">Dateiname: src/main.rs</span>

```rust
struct AlwaysEqual;

fn main() {
    let subject = AlwaysEqual;
}
```

Um `AlwaysEqual` zu definieren, verwenden wir das Schlüsselwort `struct`, den
gewünschten Namen und dann ein Semikolon. Geschweifte Klammern und Klammern
sind nicht erforderlich! Dann können wir eine Instanz von `AlwaysEqual` in der
Variable `subject` auf ähnliche Weise erhalten: Mit dem Namen, den wir
definiert haben, ohne geschweifte Klammern oder Klammern. Stell dir vor, wir
implementieren ein Verhalten für diesen Typ, bei dem jede Instanz immer gleich
ist mit jeder Instanz jedes anderen Typs, vielleicht um ein bekanntes Ergebnis
für Testzwecke zu haben. Wir bräuchten keine Daten, um dieses Verhalten
umzusetzen! In Kapitel 10 wirst du sehen, wie man Merkmale definiert und sie
für jeden Typ implementiert, auch für unit-ähnliche Strukturen.

> ### Eigentümerschaft von Strukturdaten
>
> In der Strukturdefinition `User` in Codeblock 5-1 haben wir den Typ `String`
> anstelle von `&str` verwendet. Dies ist eine bewusste Entscheidung, denn wir
> wollen, dass Instanzen dieser Struktur all ihre Daten besitzen und diese
> Daten so lange gültig sind, wie die gesamte Struktur gültig ist.
>
> Bei Strukturen ist es möglich, Referenzen auf Daten zu speichern, die im
> Besitz von etwas anderem sind, aber das erfordert die Verwendung von
> *Lebensdauern*, einer Rust-Funktionalität, die wir in Kapitel 10 besprechen
> werden. Die Lebensdauer stellt sicher, dass die von einer Struktur
> referenzierten Daten so lange gültig sind, wie die Struktur gültig ist.
> Angenommen, du versuchst eine Referenz in einer Struktur zu speichern, ohne
> eine Lebensdauer anzugeben, wird das nicht funktionieren:
>
> <span class="filename">Dateiname: src/main.rs</span>
>
> ```rust,does_not_compile
> struct User {
>     active: bool,
>     username: &str,
>     email: &str,
>     sign_in_count: u64,
> }
>
> fn main() {
>     let user1 = User {
>         active: true,
>         username: "benutzername123",
>         email: "jemand@example.com",
>         sign_in_count: 1,
>     };
> }
> ```
>
> Der Compiler wird sich beschweren, dass die Lebensdauer nicht angegeben ist:
>
> ```console
> $ cargo run
>    Compiling structs v0.1.0 (file:///projects/structs)
> error[E0106]: missing lifetime specifier
>  --> src/main.rs:3:15
>   |
> 3 |     username: &str,
>   |               ^ expected named lifetime parameter
>   |
> help: consider introducing a named lifetime parameter
>   |
> 1 ~ struct User<'a> {
> 2 |     active: bool,
> 3 ~     username: &'a str,
>   |
>
> error[E0106]: missing lifetime specifier
>  --> src/main.rs:4:12
>   |
> 4 |     email: &str,
>   |            ^ expected named lifetime parameter
>   |
> help: consider introducing a named lifetime parameter
>   |
> 1 ~ struct User<'a> {
> 2 |     active: bool,
> 3 |     username: &str,
> 4 ~     email: &'a str,
>   |
>
> For more information about this error, try `rustc --explain E0106`.
> error: could not compile `structs` (bin "structs") due to 2 previous errors
> ```
>
> In Kapitel 10 werden wir klären, wie man diese Fehler behebt und Referenzen
> in Strukturen speichern kann. Aber für den Moment werden wir Fehler wie diese
> vermeiden, indem wir Typen wie `String` anstelle von Referenzen wie `&str`
> verwenden.

[copy]: ch04-01-what-is-ownership.html#nur-stapelspeicher-daten-kopieren-copy
[move]: ch04-01-what-is-ownership.html#variablen-und-daten-im-zusammenspiel-mit-move
[tuples]: ch03-02-data-types.html#der-tupel-typ
