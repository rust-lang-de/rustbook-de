## Eine Aufzählung (enum) definieren

Während Strukturen (structs) eine Möglichkeit bieten, zusammengehörige Felder
und Daten zu gruppieren, wie ein `Rectangle` mit seiner `width` und `height`,
bieten Aufzählungen (enums) eine Möglichkeit, einen Wert als einen aus einer
möglichen Gruppe von Werten anzugeben. Wir können zum Beispiel sagen, dass
`Rectangle` eine von mehreren möglichen Formen ist, zu denen auch `Circle` und
`Triangle` gehören. Um dies zu tun, erlaubt Rust uns, diese Möglichkeiten als
Aufzählung zu kodieren.

Schauen wir uns eine Situation an, die wir vielleicht in Code ausdrücken
wollen, und sehen wir, warum Aufzählungen in diesem Fall nützlich und besser
geeignet sind als Strukturen. Angenommen, wir müssen mit IP-Adressen arbeiten.
Aktuell werden zwei Hauptstandards für IP-Adressen verwendet: Version vier und
Version sechs. Da dies die einzigen Möglichkeiten für eine IP-Adresse sind, auf
die unser Programm stößt, können wir alle möglichen Varianten _aufzählen_,
woher die Aufzählung ihren Namen hat.

Jede IP-Adresse kann entweder eine Adresse der Version vier oder der Version
sechs sein, aber nicht beides gleichzeitig. Diese Eigenschaft der IP-Adressen
passt zur Aufzählungs-Datenstruktur, da ein Aufzählungswert nur eine seiner
Varianten sein kann. Sowohl die Adressen der Version vier als auch der Version
sechs sind grundsätzlich immer noch IP-Adressen, sodass sie als der gleiche Typ
behandelt werden sollten, wenn der Code mit Situationen zu tun hat, die für
beide IP-Adressenarten gelten.

Wir können dieses Konzept im Code ausdrücken, indem wir eine Aufzählung
`IpAddrKind` definieren und die möglichen Varianten auflisten, die eine
IP-Adresse haben kann, `V4` und `V6`. Hier die Varianten der Aufzählung:

```rust
enum IpAddrKind {
    V4,
    V6,
}
#
# fn main() {
#     let four = IpAddrKind::V4;
#     let six = IpAddrKind::V6;
#
#     route(IpAddrKind::V4);
#     route(IpAddrKind::V6);
# }
#
# fn route(ip_kind: IpAddrKind) {}
```

`IpAddrKind` ist jetzt ein benutzerdefinierter Datentyp, den wir an anderer
Stelle in unserem Code verwenden können.

### Werte in Aufzählungen

Wir können Instanzen von beiden Varianten von `IpAddrKind` wie folgt erstellen:

```rust
# enum IpAddrKind {
#     V4,
#     V6,
# }
#
# fn main() {
    let four = IpAddrKind::V4;
    let six = IpAddrKind::V6;
#
#     route(IpAddrKind::V4);
#     route(IpAddrKind::V6);
# }
#
# fn route(ip_kind: IpAddrKind) {}
```

Beachte, dass die Varianten der Aufzählung mit dem Namensraum des Bezeichners
angegeben sind und wir einen doppelten Doppelpunkt verwenden, um die beiden zu
trennen. Das ist sinnvoll, weil beide Werte `IpAddrKind::V4` und
`IpAddrKind::V6` vom gleichen Typ sind: `IpAddrKind`. Wir können dann zum
Beispiel eine Funktion definieren, die jedes `IpAddrKind` annimmt:

```rust
# enum IpAddrKind {
#     V4,
#     V6,
# }
#
# fn main() {
#     let four = IpAddrKind::V4;
#     let six = IpAddrKind::V6;
#
#     route(IpAddrKind::V4);
#     route(IpAddrKind::V6);
# }
#
fn route(ip_kind: IpAddrKind) {}
```

Und wir können diese Funktion mit beiden Varianten aufrufen:

```rust
# enum IpAddrKind {
#     V4,
#     V6,
# }
#
# fn main() {
#     let four = IpAddrKind::V4;
#     let six = IpAddrKind::V6;
#
    route(IpAddrKind::V4);
    route(IpAddrKind::V6);
# }
#
# fn route(ip_kind: IpAddrKind) {}
```

Aufzählungen haben noch weitere Vorteile. Wenn wir weiter über unseren
IP-Adresstyp nachdenken, haben wir im Moment keine Möglichkeit, den _Wert_ der
tatsächlichen IP-Adresse zu speichern; wir wissen nur, um welche _Variante_ es
sich handelt. Mit dem was du gerade erst in Kapitel 5 über Strukturen gelernt
hast, könntest du versucht sein, dieses Problem mit Strukturen zu lösen, wie in
Listing 6-1.

```rust
enum IpAddrKind {
    V4,
    V6,
}

struct IpAddr {
    kind: IpAddrKind,
    address: String,
}

let home = IpAddr {
    kind: IpAddrKind::V4,
    address: String::from("127.0.0.1"),
};

let loopback = IpAddr {
    kind: IpAddrKind::V6,
    address: String::from("::1"),
};
```

<span class="caption">Listing 6-1: Speichern des Wertes und der
`IpAddrKind`-Variante einer IP-Adresse mittels `struct`</span>

Hier haben wir eine Struktur `IpAddr` definiert, die zwei Felder hat:  Ein Feld
`kind` vom Typ `IpAddrKind` (die zuvor definierte Aufzählung) und ein Feld
`address` vom Typ `String`. Wir haben zwei Instanzen dieser Struktur erzeugt.
Die erste ist `home` und hat die Variante `IpAddrKind::V4` und die zugehörige
Adresse `127.0.0.1`. Die zweite Instanz ist `loopback` und hat die Variante
`V6` von `IpAddrKind` als ihren Wert für `kind` und die zugehörige Adresse
`::1`. Wir haben eine Struktur verwendet, um die Werte `kind` und `address` zu
bündeln, sodass jetzt die Variante mit dem Wert verbunden ist.

Allerdings ist die Darstellung desselben Konzepts mit einer Aufzählung
prägnanter: Anstelle einer Aufzählung innerhalb einer Struktur können wir die
Daten direkt in jede Aufzählungsvariante einfügen. Diese neue Definition der
Aufzählung `IpAddr` legt fest, dass sowohl die Variante `V4` als auch `V6`
zugehörige `String`-Werte haben:

```rust
enum IpAddr {
    V4(String),
    V6(String),
}

let home = IpAddr::V4(String::from("127.0.0.1"));

let loopback = IpAddr::V6(String::from("::1"));
```

Wir hängen die Daten direkt an jede Variante der Aufzählung an, so dass keine
zusätzliche Struktur erforderlich ist. Hier ist es auch einfacher, ein weiteres
Detail der Funktionsweise von Aufzählungen zu betrachten: Der Name jeder
Aufzählungs-Variante, die wir definieren, wird auch zu einer Funktion, die eine
Instanz der Aufzählung konstruiert. Das heißt, `IpAddr::V4()` ist ein
Funktionsaufruf der ein `String`-Argument entgegennimmt und eine Instanz des
Typs `IpAddr` zurückgibt. Diese Konstruktorfunktion wird automatisch definiert
als Ergebnis der Definition der Aufzählung.

Es gibt noch einen weiteren Vorteil, eine Aufzählung statt einer Struktur zu
verwenden: Jede Variante kann verschiedene Typen und verschieden viele
zugehöriger Daten haben. IP-Adressen der Version vier haben stets vier
numerische Komponenten, die Werte zwischen 0 und 255 haben. Wenn wir
`V4`-Adressen als vier `u8`-Werte speichern und `V6`-Adressen als einen
`String`-Wert ausdrücken wollten, wäre das mit einer Struktur nicht möglich.
Aufzählungen lösen diesen Fall ganz einfach:

```rust
enum IpAddr {
    V4(u8, u8, u8, u8),
    V6(String),
}

let home = IpAddr::V4(127, 0, 0, 1);

let loopback = IpAddr::V6(String::from("::1"));
```

Wir haben verschiedene Möglichkeiten zur Definition von Datenstrukturen
gezeigt, die Version vier und sechs einer IP-Adresse speichern können.
Wie sich jedoch herausstellt, ist der Wunsch, IP-Adressen inklusive deren
Variante zu speichern, so verbreitet, dass [die Standardbibliothek eine
Definition bereitstellt][IpAddr], die wir verwenden können! Schauen wir uns an,
wie die Standardbibliothek `IpAddr` definiert. Es hat genau die Aufzählung und
die Varianten, die wir definiert und verwendet haben, aber es bettet die
Adressdaten innerhalb der Varianten in Form von zwei verschiedenen Strukturen
ein, die für jede Variante unterschiedlich definiert sind:

```rust
struct Ipv4Addr {
    // --abschneiden--
}

struct Ipv6Addr {
    // --abschneiden--
}

enum IpAddr {
    V4(Ipv4Addr),
    V6(Ipv6Addr),
}
```

Dieser Code veranschaulicht, dass du jede Art von Daten in eine
Aufzählungsvariante einfügen kannst: Zeichenketten, numerische Typen,
Strukturen usw. Du kannst sogar eine weitere Aufzählung einfügen! Außerdem sind
Standardbibliothekstypen oft nicht viel komplizierter als das, was du dir
vielleicht ausdenkst. Beachte, dass wir, obwohl die Standardbibliothek eine
Definition für `IpAddr` enthält, konfliktfrei unsere eigene Definition
erstellen und verwenden können, da wir die Definition der Standardbibliothek
nicht in unseren Gültigkeitsbereich aufgenommen haben. Wir werden in Kapitel 7
mehr darauf eingehen, wie man Typen in den Gültigkeitsbereich aufnimmt.

Schauen wir uns ein weiteres Beispiel für eine Aufzählung in Listing 6-2 an:
In dieser Aufzählung ist eine Vielzahl von Typen in ihren Varianten eingebettet.

```rust
enum Message {
    Quit,
    Move { x: i32, y: i32 },
    Write(String),
    ChangeColor(i32, i32, i32),
}
#
# fn main() {}
```

<span class="caption">Listing 6-2: Eine Aufzählung `Message`, deren Varianten
jeweils eine unterschiedliche Anzahl an Werttypen speichern</span>

Diese Aufzählung hat vier Varianten mit unterschiedlichen Typen:

- `Quit`: Hat überhaupt keine Daten.
- `Move`: Hat benannte Felder wie eine Struktur.
- `Write`: Enthält einen einzelnen `String`.
- `ChangeColor`: Enthält drei `i32`-Werte.

Die Definition einer Aufzählung mit Varianten wie in Listing 6-2 ist ähnlich
zur Definition verschiedener Arten von Strukturdefinitionen, außer dass die
Aufzählung nicht das Schlüsselwort `struct` verwendet und alle Varianten unter
dem Typ `Message` zusammengefasst sind. Die folgenden Strukturen könnten die
gleichen Daten aufnehmen wie die vorhergehenden Aufzählungsvarianten:

```rust
struct QuitMessage; // leere Struktur
struct MoveMessage {
    x: i32,
    y: i32,
}
struct WriteMessage(String); // Tupelstruktur
struct ChangeColorMessage(i32, i32, i32); // Tupelstruktur
#
# fn main() {}
```

Aber wenn wir die verschiedenen Strukturen verwenden würden, die jeweils ein
eigener Typ sind, könnten wir nicht so einfach eine Funktion definieren, die
eine dieser Nachrichtenarten entgegennimmt, wie wir es mit der in Listing 6-2
definierten Aufzählung `Message` gemacht haben, bei der es sich um einen
einzigen Typ handelt.

Es gibt noch eine weitere Ähnlichkeit zwischen Aufzählungen und Strukturen: So
wie wir Methoden für Strukturen mit `impl` definieren können, können wir auch
Methoden für Aufzählungen definieren. Hier ist eine Methode namens `call`, die
wir für unsere Aufzählung `Message` definieren könnten:

```rust
# fn main() {
#     enum Message {
#         Quit,
#         Move { x: i32, y: i32 },
#         Write(String),
#         ChangeColor(i32, i32, i32),
#     }
#
    impl Message {
        fn call(&self) {
            // Methodenrumpf
        }
    }

    let m = Message::Write(String::from("hallo"));
    m.call();
# }
```

Der Methodenrumpf würde `self` benutzen, um den Wert zu erhalten, auf den wir
die Methode aufgerufen haben. In diesem Beispiel haben wir eine Variable `m`
erstellt, die den Wert `Message::Write(String::from("hallo"))` hat. Genau
diesen Wert wird `self` im Rumpf der Methode `call` haben, wenn `m.call()`
ausgeführt wird.

Sehen wir uns eine weitere Aufzählung in der Standardbibliothek an, die sehr
verbreitet und hilfreich ist: `Option`

### Die Aufzählung `Option`

Dieser Abschnitt befasst sich mit einer Fallstudie zu `Option`, einer weiteren
Aufzählung, die von der Standardbibliothek definiert wird. Der Typ `Option`
kodiert das sehr häufige Szenario, in dem ein Wert etwas oder nichts sein kann.

Wenn du zum Beispiel das erste Element einer nichtleeren Liste anforderst,
erhältst du einen Wert. Wenn du das erste Element einer leeren Liste abfragst,
erhältst du nichts. Im Sinne des Typsystems bedeutet das, dass der Compiler
überprüfen kann, ob du alle Fälle behandelt hast, die du behandelt haben solltest.
Diese Funktionalität kann Fehler vermeiden, die in anderen Programmiersprachen
extrem häufig auftreten.

Bei der Entwicklung von Programmiersprachen wird oft überlegt, welche
Funktionalität aufgenommen werden soll, aber auch die auszuschließende
Funktionalität ist wichtig. Rust hat nicht die Funktionalität „null“, die es in
vielen anderen Sprachen gibt. _Null_ ist ein Wert, der bedeutet, dass kein Wert
vorhanden ist. In Sprachen mit null können sich Variablen immer in einem von
zwei Zuständen befinden: null oder nicht null.

In seinem Vortrag „Nullreferenzen: Der milliardenschwere Fehler“ von 2009 hat
Tony Hoare, der Erfinder von null, folgendes gesagt:

> Ich nenne es meinen milliardenschweren Fehler. Zu dieser Zeit entwarf ich das
> erste umfangreiche Typsystem für Referenzen in einer objektorientierten
> Sprache. Mein Ziel war es, sicherzustellen, dass jede Verwendung von
> Referenzen absolut sicher sein sollte, wobei die Überprüfung automatisch
> durch den Compiler durchgeführt wird. Aber ich konnte der Versuchung nicht
> widerstehen, eine Nullreferenz einzuführen, nur weil sie so einfach
> umzusetzen war. Dies hat zu unzähligen Fehlern, Schwachstellen und
> Systemabstürzen geführt, die in den letzten vierzig Jahren wahrscheinlich
> eine Milliarde Dollar Schmerz und Schaden verursacht haben.

Das Problem mit Nullwerten besteht darin, dass du einen Fehler erhältst, wenn
du versuchst, einen Nullwert als Nicht-Nullwert zu verwenden. Da diese Null-
oder Nicht-Null-Eigenschaft allgegenwärtig ist, ist es extrem einfach, einen
derartigen Fehler zu machen.

Das Konzept, das die Null zum Ausdruck bringen will, ist jedoch nach wie vor
nützlich: Null ist ein Wert, der aktuell ungültig ist oder aus irgendeinem
Grund nicht vorhanden ist.

Das Problem liegt nicht wirklich im Konzept, sondern in der konkreten
Umsetzung. Als solches hat Rust keine Nullen, aber es hat eine Aufzählung, die
das Konzept des Vorhandenseins oder Nichtvorhandenseins eines Wertes abbilden
kann. Diese Aufzählung heißt `Option<T>` und ist
[in der Standardbibliothek][Option] wie folgt definiert:

```rust
enum Option<T> {
    None,
    Some(T),
}
```

Die Aufzählung `Option<T>` ist so nützlich, dass sie sogar im Präludium
enthalten ist; du musst sie nicht explizit in den Gültigkeitsbereich bringen.
Ihre Varianten sind ebenfalls im Präludium enthalten: Du kannst `Some` und
`None` direkt ohne Präfix `Option::` verwenden. Die Aufzählung `Option<T>` ist
dennoch nur eine normale Aufzählung, und `Some(T)` und `None` sind nur
Varianten des Typs `Option<T>`.

Die Syntax `<T>` ist eine Funktionalität von Rust, über die wir noch nicht
gesprochen haben. Es handelt sich um einen generischen Typparameter, auf den
wir in Kapitel 10 näher eingehen werden. Für den Moment musst du nur wissen,
dass `<T>` bedeutet, dass die Variante `Some` der Aufzählung `Option` einen
Wert eines beliebigen Typs enthalten kann und dass jeder konkrete Typ, der
anstelle von `T` verwendet wird, den Gesamttyp `Option<T>` zu einem anderen Typ
macht. Hier sind einige Beispiele für die Verwendung von `Option`-Werten zur
Aufnahme von Zahlentypen und Zeichentypen:

```rust
let some_number = Some(5);
let some_char = Some('e');

let absent_number: Option<i32> = None;
```

Der Typ von `some_number` ist `Option<i32>`. Der Typ von `some_char` ist
`Option<char>`, was ein anderer Typ ist. Rust kann diese Typen ableiten, weil
wir einen Wert innerhalb der `Some`-Variante angegeben haben. Für
`absent_number` verlangt Rust den gesamten Typ `Option` zu annotieren: Der
Compiler kann den Typ, den die entsprechende `Some`-Variante haben wird, nicht
ableiten, wenn sie nur einen `None`-Wert enthält. Hier sagen wir Rust, dass
`absent_number` vom Typ `Option<i32>` sein soll.

Wenn wir einen Wert `Some` haben, wissen wir, dass ein Wert vorhanden ist und
der Wert innerhalb von `Some` gehalten wird. Wenn wir einen Wert `None` haben,
bedeutet das in gewisser Weise dasselbe wie Null: Wir haben keinen gültigen
Wert. Warum ist nun besser `Option<T>` anstelle von Null zu verwenden?

Kurz gesagt, weil `Option<T>` und `T` (wobei `T` ein beliebiger Typ sein kann)
unterschiedliche Typen sind, erlaubt es der Compiler nicht `Option<T>` so zu
verwenden als wäre es definitiv ein gültiger Wert. Beispielsweise lässt sich
dieser Code nicht kompilieren, weil er versucht, ein `i8` mit einem
`Option<i8>` zu addieren:

```rust,does_not_compile
let x: i8 = 5;
let y: Option<i8> = Some(5);

let sum = x + y;
```

Wenn wir diesen Code ausführen, erhalten wir eine Fehlermeldung wie diese:

```console
$ cargo run
   Compiling enums v0.1.0 (file:///projects/enums)
error[E0277]: cannot add `Option<i8>` to `i8`
 --> src/main.rs:5:17
  |
5 |     let sum = x + y;
  |                 ^ no implementation for `i8 + Option<i8>`
  |
  = help: the trait `Add<Option<i8>>` is not implemented for `i8`
  = help: the following other types implement trait `Add<Rhs>`:
            `&i8` implements `Add<i8>`
            `&i8` implements `Add`
            `i8` implements `Add<&i8>`
            `i8` implements `Add`

For more information about this error, try `rustc --explain E0277`.
error: could not compile `enums` (bin "enums") due to 1 previous error
```

Stark! Tatsächlich bedeutet diese Fehlermeldung, dass Rust nicht versteht, wie
man ein `i8` und eine `Option<i8>` addiert, da es sich um unterschiedliche Typen
handelt. Wenn wir einen Wert eines Typs wie `i8` in Rust haben, stellt der
Compiler sicher, dass wir immer einen gültigen Wert haben. Wir können getrost fortfahren, ohne vor der Verwendung dieses Wertes auf Null prüfen zu
müssen. Nur wenn wir eine `Option<i8>` (oder einen anderen Werttyp) haben,
müssen wir befürchten, dass wir möglicherweise keinen Wert haben, und der
Compiler wird sicherstellen, dass wir diesen Fall behandeln, bevor wir den
Wert verwenden.

Mit anderen Worten musst du eine `Option<T>` in ein `T` konvertieren, bevor du
`T`-Operationen darauf durchführen kannst. Im Allgemeinen hilft dies, eines der
häufigsten Probleme mit Null abzufangen: Anzunehmen, dass etwas nicht null ist,
obwohl es tatsächlich null ist.

Durch Vermeiden des Risikos, fälschlicherweise einen Nicht-Null-Wert
anzunehmen, gewinnst du mehr Vertrauen in deinen Code. Um einen Wert zu haben,
der möglicherweise null sein kann, musst du dich explizit dafür entscheiden,
indem du als Typ `Option<T>` verwendest. Wenn du dann diesen Wert verwendest,
musst du den Fall null explizit behandeln. Überall dort, wo ein Wert nicht den
Typ `Option<T>` hat, kannst du _sicher_ sein, dass der Wert nicht null ist.
Dies war eine bewusste Konstruktionsentscheidung bei Rust, um die Verbreitung
von Null einzuschränken und die Sicherheit von Rust-Code zu erhöhen.

Wie erhältst du nun den `T`-Wert aus einer Variante `Some`, wenn du einen Wert
vom Typ `Option<T>` hast? Die Aufzählung `Option<T>` enthält eine große Anzahl
von Methoden, die in einer Vielzahl von Situationen nützlich sind; mehr dazu
findest du in [der Dokumentation][docs]. Sich mit den Methoden von `Option<T>`
vertraut zu machen, wird dir auf deiner Reise mit Rust äußerst nützlich sein.

Um einen `Option<T>`-Wert zu verwenden, benötigst du im Allgemeinen Code, der
jede Variante behandelt. Du möchtest einen Code, der nur läuft, wenn du einen
Wert `Some(T)` hast, und dieser Code darf das innere `T` benutzen. Du möchtest,
dass ein anderer Code ausgeführt wird, wenn du einen Wert `None` hast, und
dieser Code hat keinen `T`-Wert. Der Ausdruck `match` ist ein
Kontrollflusskonstrukt, das genau dies tut, wenn es mit Aufzählungen verwendet
wird: Es führt unterschiedlichen Code aus, je nachdem, welche Variante der
Aufzählung es hat, und dieser Code kann die Daten innerhalb des passenden
Wertes verwenden.

[docs]: https://doc.rust-lang.org/std/option/enum.Option.html
[IpAddr]: https://doc.rust-lang.org/std/net/enum.IpAddr.html
[option]: https://doc.rust-lang.org/std/option/enum.Option.html
