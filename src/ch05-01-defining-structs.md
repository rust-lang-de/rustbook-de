## Strukturen (structs) definieren und instanziieren

Strukturen (structs) ähneln Tupeln, die in Kapitel 3 besprochen wurden. Wie
bei Tupeln können die Teile einer Struktur verschiedene Typen haben. Anders als
bei Tupeln benennst du jedes Teil, damit ist klar, was die Werte bedeuten.
Durch diese Namen sind Strukturen flexibler als Tupel: Du musst dich nicht auf
die Reihenfolge der Daten verlassen, um die Werte einer Instanz zu
spezifizieren oder auf sie zuzugreifen.

Um eine Struktur zu definieren, geben wir das Schlüsselwort `struct` an und
benennen die gesamte Struktur. Der Name einer Struktur sollte die Bedeutung der
Daten beschreiben, die gruppiert werden. Dann definieren wir innerhalb
geschweifter Klammern die Namen und Typen der Datenteile, die wir *Felder*
nennen. Beispielsweise zeigt Codeblock 5-1 eine Struktur, die Informationen
über ein Benutzerkonto speichert.

```rust
struct User {
    username: String,
    email: String,
    sign_in_count: u64,
    active: bool,
}
```

<span class="caption">Codeblock 5-1: Definition der Struktur `User`</span>

Um eine Struktur zu verwenden, nachdem wir sie definiert haben, erstellen wir
eine *Instanz* dieser Struktur, indem wir für jedes Feld einen konkreten Wert
angeben. Wir erzeugen eine Instanz, indem wir den Namen der Struktur angeben
und dann in geschweiften Klammern die `Schlüssel: Wert`-Paare angeben, wobei
die Schlüssel die Namen der Felder und die Werte die Daten sind, die wir in
diesen Feldern speichern wollen. Wir müssen die Felder nicht in der gleichen
Reihenfolge angeben, in der wir sie in der Struktur deklariert haben. Anders
gesagt ist die Strukturdefinition wie eine allgemeine Typvorlage und Instanzen
füllen diese Vorlage mit bestimmten Daten aus, um Werte des Typs zu erzeugen.
Beispielsweise können wir einen bestimmten Benutzer deklarieren, wie in
Codeblock 5-2 zu sehen ist.

```rust
# struct User {
#     username: String,
#     email: String,
#     sign_in_count: u64,
#     active: bool,
# }
#
# fn main() {
    let user1 = User {
        email: String::from("jemand@example.com"),
        username: String::from("benutzername123"),
        active: true,
        sign_in_count: 1,
    };
# }
```

<span class="caption">Codeblock 5-2: Eine Instanz der Struktur `User`
erzeugen</span>

Um auf einen bestimmten Wert in einer Struktur zuzugreifen, können wir die
Punktnotation verwenden. Wenn wir nur die E-Mail-Adresse dieses Benutzers
wollen, können wir `user1.email` überall dort einsetzen, wo wir diesen Wert
verwenden wollen. Wenn die Instanz veränderlich ist, können wir einen Wert
mittels Punktnotation verändern. Codeblock 5-3 gezeigt, wie der Wert im
Feld `email` einer veränderlichen `User`-Instanz geändert werden kann.

```rust
# struct User {
#     username: String,
#     email: String,
#     sign_in_count: u64,
#     active: bool,
# }
#
# fn main() {
    let mut user1 = User {
        email: String::from("jemand@example.com"),
        username: String::from("benutzername123"),
        active: true,
        sign_in_count: 1,
    };

    user1.email = String::from("andere-email@example.com");
# }
```

<span class="caption">Codeblock 5-3: Wert im Feld `email` einer `User`-Instanz ändern</span>

Beachte, dass die gesamte Instanz veränderlich sein muss. Rust erlaubt es
nicht, nur einzelne Felder als veränderlich zu markieren. Wie mit jedem
Ausdruck können wir eine neue Instanz der Struktur als letzten Ausdruck im
Funktionsrumpf erzeugen, um diese neue Instanz implizit zurückzugeben.

Codeblock 5-4 zeigt eine Funktion `build_user`, die eine `User`-Instanz mit der
angegebenen E-Mail und dem Benutzernamen zurückgibt. Das Feld `active` erhält
den Wert `true` und das Feld `sign_in_count` den Wert `1`.

```rust
# struct User {
#     username: String,
#     email: String,
#     sign_in_count: u64,
#     active: bool,
# }
#
fn build_user(email: String, username: String) -> User {
    User {
        email: email,
        username: username,
        active: true,
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

### Kurznotation der Feld-Initialisierung verwenden, wenn Variablen und Felder den gleichen Namen haben

Da die Parameter und die Strukturfelder in Codeblock 5-4 die gleichen Namen
haben, können wir die *Kurznotation der Feld-Initialisierung* (field init
shorthand syntax) verwenden, um die Funktion `build_user` so umzuschreiben,
dass sie sich unverändert gleich verhält, ohne `email` und `username` zu
wiederholen, siehe Codeblock 5-5.

```rust
# struct User {
#     username: String,
#     email: String,
#     sign_in_count: u64,
#     active: bool,
# }
#
fn build_user(email: String, username: String) -> User {
    User {
        email,
        username,
        active: true,
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
Aktualisierungssyntax erstellen. Wir setzen neue Werte für `email` und
`username`, verwenden aber ansonsten die gleichen Werte von `user1`, die wir in
Codeblock 5-2 erstellt haben.

```rust
# struct User {
#     username: String,
#     email: String,
#     sign_in_count: u64,
#     active: bool,
# }
#
# fn main() {
#     let user1 = User {
#         email: String::from("jemand@example.com"),
#         username: String::from("benutzername123"),
#         active: true,
#         sign_in_count: 1,
#     };
#
    let user2 = User {
        email: String::from("andere@example.com"),
        username: String::from("andererbenutzername567"),
        active: user1.active,
        sign_in_count: user1.sign_in_count,
    };
# }
```

<span class="caption">Codeblock 5-6: Erstellen einer neuen `User`-Instanz unter
Verwendung einiger der Werte von `user1`.</span>

Durch Verwenden der Strukturaktualisierungssyntax können wir dasselbe Ergebnis
mit weniger Code erreichen, wie Codeblock 5-7 zeigt. Die Syntax `..` gibt an,
dass die restlichen Felder, die nicht explizit gesetzt wurden, den gleichen
Wert haben sollen wie die Felder in der gegebenen Instanz.

```rust
# struct User {
#     username: String,
#     email: String,
#     sign_in_count: u64,
#     active: bool,
# }
#
# fn main() {
#     let user1 = User {
#         email: String::from("jemand@example.com"),
#         username: String::from("benutzername123"),
#         active: true,
#         sign_in_count: 1,
#     };
#
    let user2 = User {
        email: String::from("andere@example.com"),
        username: String::from("andererbenutzername567"),
        ..user1
    };
# }
```

<span class="caption">Codeblock 5-7: Verwenden der
Strukturaktualisierungssyntax, um neue Werte für `email` und `username` in der
`User`-Instanz zu setzen und die restlichen Werte aus den Feldern der Instanz
`user1` zu übernehmen</span>

Der Code in Codeblock 5-7 erzeugt auch eine Instanz `user2`, die andere Werte
für `email` und `username` hat, aber die gleichen Werte der Felder `active` und
`sign_in_count` wie `user1`.

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

```rust
struct Color(i32, i32, i32);
struct Point(i32, i32, i32);

let black = Color(0, 0, 0);
let origin = Point(0, 0, 0);
```

Beachte, dass die Werte `black` und `origin` unterschiedliche Typen haben, weil
sie Instanzen unterschiedlicher Tupel-Strukturen sind. Jede von dir definierte
Struktur ist ein eigenständiger Typ, auch wenn die Felder innerhalb der
Struktur die gleichen Typen haben. Zum Beispiel kann eine Funktion, die einen
Parameter vom Typ `Color` hat, keinen `Point` als Argument nehmen, obwohl beide
Typen aus drei `i32`-Werten bestehen. Ansonsten verhalten sich
Tupel-Struktur-Instanzen wie Tupel: Du kannst sie in ihre Einzelteile zerlegen,
indem du `.` gefolgt vom Index schreibst, um auf einen einzelnen Wert
zuzugreifen, und so weiter.

### Einheitstyp

Du kannst auch Strukturen definieren, die gar keine Felder haben! Diese werden
*Einheitstyp* (unit-like structs) genannt, weil sie sich ähnlich zum leeren
Tupel `()` verhalten. Einheitstypen können in Situationen nützlich sein, in
denen du ein Merkmal (trait) zu einem Typ implementieren musst, du aber keine
Daten hast, die im Typ gespeichert werden sollen. Wir werden Merkmale in
Kapitel 10 besprechen.

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
>     username: &str,
>     email: &str,
>     sign_in_count: u64,
>     active: bool,
> }
>
> fn main() {
>     let user1 = User {
>         email: "jemand@example.com",
>         username: "benutzername123",
>         active: true,
>         sign_in_count: 1,
>     };
> }
> ```
>
> Der Compiler wird sich beschweren, dass die Lebensdauer nicht angegeben ist:
>
> ```console
> $ cargo run
>    Compiling playground v0.0.1 (/playground)
> error[E0106]: missing lifetime specifier
>  --> src/main.rs:2:15
>   |
> 2 |     username: &str,
>   |               ^ expected named lifetime parameter
>   |
> help: consider introducing a named lifetime parameter
>   |
> 1 | struct User<'a> {
> 2 |     username: &'a str,
>   |
>
> error[E0106]: missing lifetime specifier
>  --> src/main.rs:3:12
>   |
> 3 |     email: &str,
>   |            ^ expected named lifetime parameter
>   |
> help: consider introducing a named lifetime parameter
>   |
> 1 | struct User<'a> {
> 2 |     username: &str,
> 3 |     email: &'a str,
>   |
>
> error: aborting due to 2 previous errors
> 
> For more information about this error, try `rustc --explain E0106`.
> error: could not compile `playground`
>
> To learn more, run the command again with --verbose.
> ```
>
> In Kapitel 10 werden wir klären, wie man diese Fehler behebt und Referenzen
> in Strukturen speichern kann. Aber für den Moment werden wir Fehler wie diese
> vermeiden, indem wir Typen wie `String` anstelle von Referenzen wie `&str`
> verwenden.
