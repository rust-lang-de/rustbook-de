## Merkmale (traits): Gemeinsames Verhalten definieren

Ein *Merkmal* (trait) definiert Funktionalität, den ein bestimmter Typ hat und
mit anderen Typen teilen kann. Wir können Merkmale verwenden, um gemeinsames
Verhalten auf abstrakte Weise zu definieren. Wir können Merkmalsabgrenzungen
(trait bounds) verwenden, um anzugeben, dass ein generischer Typ jeder Typ sein
kann, der ein bestimmtes Verhalten aufweist.

> Anmerkung: Merkmale sind einer Funktionalität recht ähnlich, die in anderen
> Sprachen oft *Schnittstelle* (interface) genannt wird, wenn auch mit einigen
> Unterschieden.

### Ein Merkmal definieren

Das Verhalten eines Typs besteht aus den Methoden, die wir auf diesen Typ
anwenden können. Verschiedene Typen haben das gleiche Verhalten, wenn wir bei
allen die gleichen Methoden aufrufen können. Merkmalsdefinitionen sind eine
Möglichkeit, Methodensignaturen zu gruppieren, um eine Reihe von
Verhaltensweisen zu definieren, die zum Erreichen eines bestimmten Zwecks
erforderlich sind.

Nehmen wir zum Beispiel an, wir haben mehrere Strukturen (structs), die
verschiedene Arten und Mengen von Text enthalten: Eine Struktur `NewsArticle`,
die eine Nachricht enthält, die sich auf einen bestimmten Ort bezieht, und ein
`Tweet`, der maximal 280 Zeichen umfassen kann, sowie Metadaten, die angeben,
ob es sich um eine neue Kurznachricht, eine Wiederholung oder eine Antwort auf
eine andere Kurznachricht handelt.

Wir wollen eine Medienaggregator-Bibliothekskiste namens `aggregator`
erstellen, die Zusammenfassungen von Daten anzeigen kann, die in einer
`NewsArticle`- oder `Tweet`-Instanz gespeichert sein könnten. Dazu brauchen wir
eine Zusammenfassung von jedem Typ, und wir werden diese Zusammenfassung
anfordern, indem wir eine Methode `summarize` auf einer Instanz aufrufen.
Codeblock 10-12 zeigt die Definition eines öffentlichen `Summary`-Merkmals, das
dieses Verhalten zum Ausdruck bringt.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
pub trait Summary {
    fn summarize(&self) -> String;
}
```

<span class="caption">Codeblock 10-12: Ein Merkmal `Summary`, dessen Verhalten
aus der Methode `summarize` besteht</span>

Hier deklarieren wir ein Merkmal mit dem Schlüsselwort `trait` und dann den
Namen des Merkmals, der in diesem Fall `Summary` lautet. Wir haben das Merkmal
auch als `pub` deklariert, sodass Kisten, die von dieser Kiste abhängen, dieses
Merkmal ebenfalls nutzen können, wie wir in einigen Beispielen sehen werden.
Innerhalb der geschweiften Klammern deklarieren wir die Methodensignaturen, die
das Verhalten der Typen beschreiben, die dieses Merkmal implementieren, was in
diesem Fall `fn summarize(&self) -> String` ist.

Nach der Methodensignatur verwenden wir statt einer Implementierung in
geschweiften Klammern ein Semikolon. Jeder Typ, der dieses Merkmal
implementiert, muss sein eigenes benutzerdefiniertes Verhalten für den
Methodenrumpf bereitstellen. Der Compiler wird sicherstellen, dass jeder
Typ, der das Merkmal `Summary` hat, die Methode `summarize` mit genau dieser
Signatur hat.

Ein Merkmal kann mehrere Methoden umfassen: Die Methodensignaturen werden
zeilenweise aufgelistet und jede Zeile endet mit einem Semikolon.

### Ein Merkmal für einen Typ implementieren

Nachdem wir nun die gewünschten Signaturen der Methoden des Merkmals `Summary`
definiert haben, können wir sie für die Typen in unserem Medienaggregator
implementieren. Codeblock 10-13 zeigt eine Implementierung des Merkmals
`Summary` für die Struktur `NewsArticle`, die die Überschrift, den Autor und
den Ort verwendet, um den Rückgabewert von `summarize` zu erzeugen. Für die
Struktur `Tweet` definieren wir `summarize` als den Benutzernamen, gefolgt vom
gesamten Text der Kurznachricht, wobei wir davon ausgehen, dass der Inhalt der
Kurznachricht bereits auf 280 Zeichen begrenzt ist.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
# pub trait Summary {
#     fn summarize(&self) -> String;
# }
#
pub struct NewsArticle {
    pub headline: String,
    pub location: String,
    pub author: String,
    pub content: String,
}

impl Summary for NewsArticle {
    fn summarize(&self) -> String {
        format!("{}, von {} ({})", self.headline, self.author, self.location)
    }
}

pub struct Tweet {
    pub username: String,
    pub content: String,
    pub reply: bool,
    pub retweet: bool,
}

impl Summary for Tweet {
    fn summarize(&self) -> String {
        format!("{}: {}", self.username, self.content)
    }
}
```

<span class="caption">Codeblock 10-13: Implementierung des Merkmals `Summary`
für die Typen `NewsArticle` und `Tweet`</span>

Die Implementierung eines Merkmals für einen Typ ist ähnlich zur
Implementierung regulärer Methoden. Der Unterschied besteht darin, dass wir
nach `impl` den Namen des Merkmals schreiben, das wir implementieren wollen
und dann das Schlüsselwort `for` gefolgt vom Namen des Typs, für den wir
das Merkmal implementieren wollen. Innerhalb des `impl`-Blocks geben wir die
Methodensignaturen an, die das Merkmal vorgibt. Anstatt nach jeder Signatur ein
Semikolon zu schreiben, verwenden wir geschweifte Klammern und füllen den
Methodenrumpf mit dem spezifischen Verhalten, das die Methoden des Merkmals für
den jeweiligen Typ haben sollen.

Da die Bibliothek nun das Merkmal `Summary` auf `NewsArticle` und `Tweet`
implementiert hat, können Benutzer der Kiste die Merkmals-Methoden auf
Instanzen von `NewsArticle` und `Tweet` auf die gleiche Weise aufrufen, wie wir
reguläre Methoden aufrufen. Der einzige Unterschied besteht darin, dass der
Benutzer das Merkmal sowie die Typen in den Gültigkeitsbereich bringen muss, um
die zusätzlichen Merkmals-Methoden zu erhalten. Hier ist ein Beispiel dafür,
wie eine binäre Kiste unsere `aggregator`-Bibliothekskiste verwenden könnte:

```rust,ignore
# use aggregator::{self, Summary, Tweet};
#
# fn main() {
    let tweet = Tweet {
        username: String::from("horse_ebooks"),
        content: String::from(
            "natürlich, wie du wahrscheinlich schon weißt",
        ),
        reply: false,
        retweet: false,
    };

    println!("1 neue Kurznachricht: {}", tweet.summarize());
# }
```

Dieser Code gibt `1 neue Kurznachricht: horse_ebooks: natürlich, wie du
wahrscheinlich schon weißt` aus.

Andere Kisten, die von der `aggregator`-Kiste abhängen, können auch das Merkmal
`Summary` in den Gültigkeitsbereich bringen, um `Summary` auf ihren eigenen
Typen zu implementieren. Eine Einschränkung ist, dass wir ein Merkmal für einen
Typ nur dann implementieren können, wenn entweder das Merkmal oder der Typ
lokal in unserer Kiste vorhanden ist. Zum Beispiel können wir
Standard-Bibliotheksmerkmale wie `Display` auf einem benutzerdefinierten Typ
wie `Tweet` als Teil unserer `aggregator`-Kistenfunktionalität implementieren,
weil der Typ `Tweet` lokal zu unserer `aggregator`-Kiste gehört. Wir können
auch `Summary` auf `Vec<T>` in unserer `aggregator`-Kiste implementieren, weil
das Merkmal `Summary` lokal zu unserer `aggregator`-Kiste gehört.

Aber wir können externe Merkmale nicht auf externe Typen anwenden. Zum Beispiel
können wir das Merkmal `Display` auf `Vec<T>` in unserer `aggregator`-Kiste
nicht implementieren, weil `Display` und `Vec<T>` in der Standardbibliothek
definiert sind und nicht lokal zu unserer `aggregator`-Kiste gehören. Diese
Beschränkung ist Teil einer Eigenschaft von Programmen namens *Kohärenz*
(coherence), genauer gesagt der *Waisenregel* (orphan rule), die so genannt
wird, weil der übergeordnete Typ nicht vorhanden ist. Diese Regel stellt
sicher, dass der Code anderer Personen deinen Code nicht brechen kann und
umgekehrt. Ohne diese Regel könnten zwei Kisten dasselbe Merkmal für denselben
Typ implementieren und Rust wüsste nicht, welche Implementierung es verwenden
sollte.

### Standard-Implementierungen

Manchmal ist es nützlich, ein Standardverhalten für einige oder alle Methoden
eines Merkmals zu haben, anstatt Implementierungen für alle Methoden für jeden
Typ zu verlangen. Wenn wir dann das Merkmal für einen bestimmten Typ
implementieren, können wir das Standardverhalten jeder Methode beibehalten oder
überschreiben.

In Codeblock 10-14 geben wir eine Standard-Zeichenkette für die Methode
`summarize` des Merkmals `Summary` an, anstatt nur die Methodensignatur zu
definieren, wie wir es in Codeblock 10-12 getan haben.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
pub trait Summary {
    fn summarize(&self) -> String {
        String::from("(Lies mehr ...)")
    }
}
```

<span class="caption">Codeblock 10-14: Definieren eines Merkmals `Summary` mit
einer Standard-Implementierung der Methode `summarize`</span>

Um eine Standard-Implementierung zu verwenden, um Instanzen von `NewsArticle`
zusammenzufassen, geben wir einen leeren `impl`-Block mit `impl Summary for
NewsArticle {}` an.

Auch wenn wir die Methode `summarize` nicht mehr direkt für `NewsArticle`
definieren, haben wir eine Standard-Implementierung bereitgestellt und
festgelegt, dass `NewsArticle` das Merkmal `Summary` implementiert.
Infolgedessen können wir immer noch die Methode `summarize` einer
`NewsArticle`-Instanz aufrufen, etwa so:

```rust,ignore
# use aggregator::{self, NewsArticle, Summary};
#
# fn main() {
    let article = NewsArticle {
        headline: String::from("Pinguine gewinnen die Stanley-Cup-Meisterschaft!"),
        location: String::from("Pittsburgh, PA, USA"),
        author: String::from("Iceburgh"),
        content: String::from("Die Pittsburgh Penguins sind erneut die beste \
                               Eishockeymannschaft in der NHL.",
        ),
    };

    println!("Neuer Artikel verfügbar! {}", article.summarize());
# }
```

Dieser Code gibt `Neuer Artikel verfügbar! (Lies mehr ...)` aus.

Das Erstellen einer Standard-Implementierung erfordert nicht, dass wir an der
Implementierung von `Summary` für `Tweet` in Codeblock 10-13 etwas ändern. Der
Grund dafür ist, dass die Syntax für das Überschreiben einer
Standard-Implementierung die gleiche ist wie die Syntax für die Implementierung
einer Merkmalsmethode, die keine Standard-Implementierung hat.

Standard-Implementierungen können andere Methoden desselben Merkmals aufrufen,
selbst wenn diese anderen Methoden keine Standard-Implementierung haben. Auf
diese Weise kann ein Merkmal eine Menge nützlicher Funktionalität bereitstellen
und von den Implementierern nur die Angabe eines kleinen Teils verlangen. Zum
Beispiel könnten wir das Merkmal `Summary` so definieren, dass wir eine Methode
`summarize_author` haben, deren Implementierung erforderlich ist, und dann eine
Methode `summarize` definieren, die eine Standard-Implementierung hat und die
Methode `summarize_author` aufruft:

```rust
pub trait Summary {
    fn summarize_author(&self) -> String;

    fn summarize(&self) -> String {
        format!("(Lies mehr von {}...)", self.summarize_author())
    }
}
```

Um diese Version von `Summary` zu verwenden, müssen wir `summarize_author` nur
dann definieren, wenn wir das Merkmal für einen Typ implementieren:

```rust
# pub trait Summary {
#     fn summarize_author(&self) -> String;
#
#     fn summarize(&self) -> String {
#         format!("(Lies mehr von {}...)", self.summarize_author())
#     }
# }
#
# pub struct Tweet {
#     pub username: String,
#     pub content: String,
#     pub reply: bool,
#     pub retweet: bool,
# }
#
impl Summary for Tweet {
    fn summarize_author(&self) -> String {
        format!("@{}", self.username)
    }
}
```

Nachdem wir `summarize_author` definiert haben, können wir `summarize` auf
Instanzen der `Tweet`-Struktur aufrufen, und die Standard-Implementierung von
`summarize` wird die Definition von `summarize_author` aufrufen, die wir
bereitgestellt haben. Da wir `summarize_author` implementiert haben, hat uns
das Merkmal `Summary` das Verhalten der `summarize`-Methode mitgeliefert, ohne
dass wir weiteren Code schreiben müssen. 

```rust,ignore
# use aggregator::{self, Summary, Tweet};
#
# fn main() {
    let tweet = Tweet {
        username: String::from("horse_ebooks"),
        content: String::from("natürlich, wie du wahrscheinlich schon weißt"),
        reply: false,
        retweet: false,
    };

    println!("1 neue Kurznachricht: {}", tweet.summarize());
# }
```

Dieser Code gibt `1 neue Kurznachricht: (Lies mehr von @horse_ebooks...)` aus.

Beachte, dass es nicht möglich ist, die Standardimplementierung von einer
übergeordneten Implementierung derselben Methode aus aufzurufen.

### Merkmale als Parameter

Da du jetzt weißt, wie man Merkmale definiert und implementiert, können wir
untersuchen, wie man Merkmale zur Definition von Funktionen verwendet, die
viele verschiedene Typen akzeptieren. Wir verwenden das Merkmal `Summary`, das
wir für die Typen `NewsArticle` und `Tweet` in Codeblock 10-13 implementiert
haben, um eine Funktion `notify` zu definieren, die die Methode `summarize` für
ihren Parameter `item` aufruft, der von einem Typ ist, der das Merkmal
`Summary` implementiert. Um dies zu tun, können wir die Syntax `impl Trait`
verwenden, etwa so:

```rust
# pub trait Summary {
#     fn summarize(&self) -> String;
# }
#
pub fn notify(item: impl Summary) {
    println!("Eilmeldung! {}", item.summarize());
}
```

Anstelle eines konkreten Typs für den Parameter `item` geben wir das
Schlüsselwort `impl` und den Merkmalsnamen an. Dieser Parameter akzeptiert
jeden Typ, der das angegebene Merkmal implementiert. Im Rumpf von `notify`
können wir alle Methoden von `item` aufrufen, die vom Merkmal `Summary`
herrühren, zum Beispiel `summarize`. Wir können `notify` aufrufen und jede
Instanz von `NewsArticle` und `Tweet` angeben. Code, der die Funktion mit einem
anderen Typ aufruft, z.B. `String` oder `i32`, lässt sich nicht kompilieren, da
diese Typen kein `Summary` implementieren.


#### Merkmalsabgrenzungs-Syntax

Die Syntax `impl Trait` funktioniert für einfache Fälle, ist aber eigentlich
syntaktischer Zucker für eine längere Form, die *Merkmalsabgrenzung* (trait
bound) genannt wird; sie sieht so aus:

```rust
# pub trait Summary {
#     fn summarize(&self) -> String;
# }
#
pub fn notify<T: Summary>(item: &T) {
    println!("Eilmeldung! {}", item.summarize());
}
```

Diese längere Form entspricht dem Beispiel im vorigen Abschnitt, ist aber
wortreicher. Wir platzieren Merkmalsabgrenzungen in der Deklaration des
generischen Typparameters nach einem Doppelpunkt und innerhalb spitzer
Klammern.

Die Syntax `impl Trait` ist bequem und ermöglicht in einfachen Fällen einen
prägnanteren Code, während die umfassendere Merkmalsabgrenzungs-Syntax mehr
Komplexität ausdrücken kann. Zum Beispiel können wir zwei Parameter haben, die
`Summary` implementieren. Das Verwenden der Syntax `impl Trait` sieht
folgendermaßen aus:

```rust,ignore
pub fn notify(item1: &impl Summary, item2: &impl Summary) {
```

Die Verwendung von `impl Trait` ist angemessen, wenn wir wollten, dass diese
Funktion bei `item1` und `item2` unterschiedliche Typen haben kann (solange
beide Typen `Summary` implementieren). Wenn beide Parameter aber den gleichen
Typ haben sollen, müssen wir eine Merkmalsabgrenzung verwenden, so wie hier:

```rust,ignore
pub fn notify<T: Summary>(item1: &T, item2: &T) {
```

Der als Parametertyp für `item1` und `item2` angegebene generische Typ `T`
schränkt die Funktion so ein, dass der konkrete Typ der als Argument für
`item1` und `item2` übergebenen Werte derselbe sein muss.

#### Angeben mehrerer Merkmalsabgrenzungen mit der Syntax `+`

Wir können auch mehr als eine Merkmalsabgrenzung angeben. Nehmen wir an, wir
wollen, dass sowohl `notify` als auch die Methode `summarize` die
Bildschirmausgabe für `item` formatieren: Spezifizieren wir in der
`notify`-Definition, dass `item` sowohl `Display` als auch `Summary`
implementieren muss. Wir können dies mit der Syntax `+` tun:

```rust,ignore
pub fn notify(item: &(impl Summary + Display)) {
```

Die Syntax `+` ist auch bei Merkmalsabgrenzungen mit generischen Typen gültig:

```rust,ignore
pub fn notify<T: Summary + Display>(item: &T) {
```

Mit den beiden angegebenen Merkmalsabgrenzungen kann der Rumpf von `notify` die
Methode `summarize` aufrufen und `{}` verwenden, um `item` zu formatieren.

#### Klarere Merkmalsabgrenzungen mit `where`-Klauseln

Zu viele Merkmalsabgrenzungen zu verwenden, hat seine Schattenseiten. Jeder
generische Datentyp hat seine eigenen Merkmalsabgrenzungen, sodass Funktionen
mit mehreren generischen Typparametern viele Merkmalsabgrenzungsangaben
zwischen Funktionsname und Parameterliste enthalten können, wodurch die
Funktionssignatur schwer lesbar wird. Aus diesem Grund hat Rust für die Angabe
von Merkmalsabgrenzungen eine alternative Syntax in Form einer `where`-Klausel
nach der Funktionssignatur. Anstatt das hier zu schreiben:

```rust,ignore
fn some_function<T: Display + Clone, U: Clone + Debug>(t: &T, u: &U) -> i32 {
```

können wir eine `where`-Klausel wie folgt verwenden:

```rust,ignore
fn some_function<T, U>(t: &T, u: &U) -> i32
where
    T: Display + Clone,
    U: Clone + Debug,
{
```

Die Signatur dieser Funktion ist übersichtlicher: Der Funktionsname, die
Parameterliste und der Rückgabetyp liegen nahe beieinander, ähnlich wie bei
einer Funktion ohne viele Merkmalsabgrenzungen.

### Rückgabetypen, die Merkmale implementieren

Wir können die Syntax `impl Trait` auch für den Rückgabetyp verwenden, wie hier
gezeigt:

```rust
# pub trait Summary {
#     fn summarize(&self) -> String;
# }
#
# pub struct Tweet {
#     pub username: String,
#     pub content: String,
#     pub reply: bool,
#     pub retweet: bool,
# }
#
# impl Summary for Tweet {
#     fn summarize(&self) -> String {
#         format!("{}: {}", self.username, self.content)
#     }
# }
#
fn returns_summarizable() -> impl Summary {
    Tweet {
        username: String::from("horse_ebooks"),
        content: String::from("natürlich, wie du wahrscheinlich schon weißt"),
        reply: false,
        retweet: false,
    }
}
```

Durch Verwenden von `impl Summary` für den Rückgabetyp legen wir fest, dass die
Funktion `returns_summarizable` einen Typ zurückgibt, der das Merkmal `Summary`
implementiert, ohne den konkreten Typ zu nennen. In diesem Fall gibt
`returns_summarizable` einen `Tweet` zurück, aber der Code, der diese Funktion
aufruft, muss das nicht wissen.

Die Fähigkeit, einen Rückgabetyp nur durch das Merkmal, das er implementiert,
zu spezifizieren, ist besonders nützlich im Zusammenhang mit
Funktionsabschlüssen und Iteratoren, die wir in Kapitel 13 behandeln.
Funktionsabschlüsse und Iteratoren erzeugen Typen, die nur der Compiler
kennt oder deren Spezifikation sehr lang ist. Mit der Syntax `impl Trait`
kannst du prägnant angeben, dass eine Funktion einen Typ zurückgibt, der das
Merkmal `Iterator` implementiert, ohne dass du einen sehr langen Typ schreiben
musst.

Du kannst `impl Trait` jedoch nur verwenden, wenn du einen einzigen Typ
zurückgibst. Beispielsweise würde dieser Code, der entweder einen `NewsArticle`
oder einen `Tweet` mit dem Rückgabetyp `impl Summary` zurückgibt, nicht
funktionieren:

```rust,does_not_compile
# pub trait Summary {
#     fn summarize(&self) -> String;
# }
#
# pub struct NewsArticle {
#     pub headline: String,
#     pub location: String,
#     pub author: String,
#     pub content: String,
# }
#
# impl Summary for NewsArticle {
#     fn summarize(&self) -> String {
#         format!("{}, von {} ({})", self.headline, self.author, self.location)
#     }
# }
#
# pub struct Tweet {
#     pub username: String,
#     pub content: String,
#     pub reply: bool,
#     pub retweet: bool,
# }
#
# impl Summary for Tweet {
#     fn summarize(&self) -> String {
#         format!("{}: {}", self.username, self.content)
#     }
# }
#
fn returns_summarizable(switch: bool) -> impl Summary {
    if switch {
        NewsArticle {
            headline: String::from(
                "Pinguine gewinnen die Stanley-Cup-Meisterschaft!",
            ),
            location: String::from("Pittsburgh, PA, USA"),
            author: String::from("Iceburgh"),
            content: String::from(
                "Die Pittsburgh Penguins sind erneut die beste \
                 Eishockeymannschaft in der NHL.",
            ),
        }
    } else {
        Tweet {
            username: String::from("horse_ebooks"),
            content: String::from(
                "natürlich, wie du wahrscheinlich schon weißt",
            ),
            reply: false,
            retweet: false,
        }
    }
}
```

Die Rückgabe entweder eines `NewsArticle` oder eines `Tweet` ist aufgrund von
Einschränkungen hinsichtlich der Implementierung der Syntax `impl Trait` im
Compiler nicht erlaubt. Wie man eine Funktion mit diesem Verhalten schreibt,
wird im Abschnitt [„Merkmalsobjekte (trait objects) die Werte unterschiedlicher
Typen erlauben“][using-trait-objects-that-allow-for-values-of-different-types]
in Kapitel 17 behandelt.

### Verwenden von Merkmalsabgrenzungen zur bedingten Implementierung von Methoden

Durch Verwenden einer Merkmalsabgrenzung mit einem `impl`-Block, der generische
Typparameter verwendet, können wir Methoden bedingt für Typen implementieren,
die das angegebene Merkmal implementieren. Beispielsweise implementiert der Typ
`Pair<T>` in Codeblock 10-15 immer die Funktion `new`, um eine neue Instanz von
`Pair<T>` zurückzugeben (erinnere dich an den Abschnitt [„Definieren von
Methoden“][methods] in Kapitel 5, dass `Self` ein Typ-Alias für den Typ des
`impl`-Blocks ist, der in diesem Fall `Pair<T>` ist). Aber im nächsten
`impl`-Block implementiert `Pair<T>` die Methode `cmp_display` nur, wenn ihr
innerer Typ `T` die Merkmale `PartialOrd` *und* `Display` implementiert, die
den Vergleich bzw. eine Ausgabe ermöglichen.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
use std::fmt::Display;

struct Pair<T> {
    x: T,
    y: T,
}

impl<T> Pair<T> {
    fn new(x: T, y: T) -> Self {
        Self { x, y }
    }
}

impl<T: Display + PartialOrd> Pair<T> {
    fn cmp_display(&self) {
        if self.x >= self.y {
            println!("Das größte Element ist x = {}", self.x);
        } else {
            println!("Das größte Element ist y = {}", self.y);
        }
    }
}
```

<span class="caption">Codeblock 10-15: Bedingte Implementierung von Methoden
für einen generischen Typ in Abhängigkeit von Merkmalsabgrenzungen</span>

Wir können auch ein Merkmal für beliebige Typen bedingt implementieren, die ein
anderes Merkmal implementieren. Implementierungen eines Merkmals für Typen, die
Merkmalsabgrenzungen erfüllen, werden als *Pauschal-Implementierungen* (blanket
implementations) bezeichnet und kommen in der Rust-Standardbibliothek ausgiebig
zur Anwendung. Beispielsweise implementiert die Standardbibliothek das Merkmal
`ToString` für jeden Typ, der das Merkmal `Display` implementiert. Der
`impl`-Block in der Standardbibliothek sieht in etwa so aus:

```rust,ignore
impl<T: Display> ToString for T {
    // --abschneiden--
}
```

Da die Standardbibliothek diese Pauschal-Implementierungen hat, können wir die
`to_string`-Methode, die durch das Merkmal `ToString` definiert ist, bei jedem
Typ aufrufen, der das Merkmal `Display` implementiert. Zum Beispiel können wir
ganze Zahlen in ihre entsprechenden `String`-Werte umwandeln, weil ganze
Zahlen `Display` implementieren:

```rust
let s = 3.to_string();
```

Pauschal-Implementierungen erscheinen in der Dokumentation des Merkmals im
Abschnitt „Implementierer“ (implementors).

Mithilfe von Merkmalen und Merkmalsabgrenzungen können wir Code schreiben, der
generische Typparameter verwendet, um Duplikationen zu reduzieren, aber auch
dem Compiler gegenüber angeben, dass der generische Typ ein bestimmtes
Verhalten haben soll. Der Compiler kann dann die Merkmalsabgrenzungen
verwenden, um zu überprüfen, ob alle konkreten Typen, die von unserem Code
verwendet werden, das richtige Verhalten aufweisen. In dynamisch typisierten
Sprachen würden wir einen Laufzeitfehler erhalten, wenn wir eine Methode bei
einem Typ aufrufen, der die Methode nicht definiert hat. Rust verschiebt diese
Fehler jedoch in die Kompilierzeit und verlangt damit, dass wir die Probleme
beheben, bevor unser Code überhaupt lauffähig ist. Außerdem müssen wir keinen
Code schreiben, der das Verhalten zur Laufzeit überprüft, da wir es bereits zur
Kompilierzeit überprüft haben. Auf diese Weise wird die Performanz verbessert,
ohne die Flexibilität der generischen Datentypen aufgeben zu müssen.

[methods]: ch05-03-method-syntax.html#definieren-von-methoden
[using-trait-objects-that-allow-for-values-of-different-types]:
ch17-02-trait-objects.html
