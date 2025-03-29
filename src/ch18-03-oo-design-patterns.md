## Ein objektorientiertes Entwurfsmuster implementieren

Das _Zustandsmuster_ (state pattern) ist ein objektorientiertes Entwurfsmuster.
Der Kernpunkt des Musters besteht darin, dass wir eine Reihe von Zuständen
definieren, die ein Wert intern annehmen kann. Die Zustände werden durch eine
Reihe von _Zustandsobjekten_ (state objects) dargestellt, und das Verhalten des
Wertes ändert sich je nach Zustand. Wir werden ein Beispiel für eine
Blog-Post-Struktur durcharbeiten, die ein Feld für ihren Status hat, das ein
Statusobjekt mit den Möglichkeiten „Entwurf“, „Überprüfung“ und
„Veröffentlicht“ sein wird.

Die Zustandsobjekte haben eine gemeinsame Funktionalität: In Rust verwenden wir
Strukturen (structs) und Merkmale (traits) und nicht Objekte und Vererbung.
Jedes Zustandsobjekt ist für sein eigenes Verhalten verantwortlich und
bestimmt, wann es in einen anderen Zustand übergehen soll. Der Wert, den ein
Zustandsobjekt enthält, weiß nichts über das unterschiedliche Verhalten der
Zustände oder den Zeitpunkt des Übergangs zwischen den Zuständen.

Der Vorteil der Verwendung des Zustandsmusters besteht darin, dass wir, wenn
sich die geschäftlichen Anforderungen des Programms ändern, weder den Code des
Werts, der den Zustand hält, noch den Code, der den Wert verwendet, ändern
müssen. Wir müssen nur den Code in einem der Zustandsobjekte aktualisieren, um
seine Regeln zu ändern oder vielleicht weitere Zustandsobjekte hinzuzufügen.

Zunächst werden wir das Zustandsmuster auf eine traditionellere
objektorientierte Weise implementieren, dann werden wir einen Ansatz verwenden,
der in Rust etwas natürlicher ist. Beginnen wir mit der inkrementellen
Implementierung eines Blogpost-Workflows unter Verwendung des Zustandsmusters.

Die finale Funktionalität des Blogs wird wie folgt aussehen:

1. Ein Blog-Beitrag (post) beginnt als leerer Entwurf.
2. Wenn der Entwurf fertig ist, wird um eine Überprüfung des Beitrags gebeten.
3. Wenn der Beitrag genehmigt ist, wird er veröffentlicht.
4. Nur veröffentlichte Blog-Beiträge geben anzuzeigenden Inhalt zurück, sodass
   nicht genehmigte Beiträge nicht versehentlich veröffentlicht werden können.

Alle anderen Änderungen, die an einem Beitrag versucht werden, sollten keine
Auswirkungen haben. Wenn wir zum Beispiel versuchen, den Entwurf eines
Blog-Beitrags zu genehmigen, bevor wir eine Überprüfung beantragt haben, sollte
der Beitrag ein unveröffentlichter Entwurf bleiben.

Codeblock 18-11 zeigt diesen Workflow in Codeform: Dies ist eine
Beispielverwendung der API, die wir in einer Bibliothekskiste (library crate)
`blog` implementieren werden. Dieser Code wird sich noch nicht kompilieren
lassen, da wir die Kiste (crate) `blog` noch nicht implementiert haben.

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore,does_not_compile
use blog::Post;

fn main() {
    let mut post = Post::new();

    post.add_text("Ich habe heute Mittag einen Salat gegessen");
    assert_eq!("", post.content());

    post.request_review();
    assert_eq!("", post.content());

    post.approve();
    assert_eq!("Ich habe heute Mittag einen Salat gegessen", post.content());
}
```

<span class="caption">Codeblock 18-11: Code, der das gewünschte Verhalten
demonstriert, das wir für unsere Kiste `blog` haben wollen</span>

Wir möchten dem Benutzer erlauben, einen neuen Entwurf eines Blog-Beitrags mit
`Post::new` zu erstellen. Wir möchten dem Blog-Beitrag erlauben, Text
hinzuzufügen. Wenn wir versuchen, den Inhalt des Beitrags sofort, also vor der
Genehmigung, abzurufen, sollten wir keinen Text erhalten, da der Beitrag noch
ein Entwurf ist. Wir haben zu Demonstrationszwecken `assert_eq!` in den Code
eingefügt. Ein ausgezeichneter Modultest dafür wäre die Zusicherung, dass ein
Entwurf eines Blog-Beitrags eine leere Zeichenkette aus der Methode `content`
zurückgibt, aber wir werden für dieses Beispiel keine Tests schreiben.

Als nächstes wollen wir einen Antrag auf Überprüfung des Beitrags ermöglichen
und wir wollen, dass `content` eine leere Zeichenkette zurückgibt, solange wir
auf die Überprüfung warten. Wenn der Beitrag die Genehmigung erhält, soll er
veröffentlicht werden, d.h. der Text des Beitrags wird zurückgegeben, wenn
`content` aufgerufen wird.

Beachte, dass der einzige Typ, mit dem wir von der Kiste aus interagieren, der
`Post`-Typ ist. Dieser Typ verwendet das Zustandsmuster und enthält einen Wert,
der eines von drei Zustandsobjekten ist, die die verschiedenen Zustände
repräsentieren, in denen sich ein Beitrag im Entwurf befinden, auf eine
Überprüfung warten oder veröffentlicht werden kann. Der Wechsel von einem
Zustand in einen anderen wird intern innerhalb des `Post`-Typs verwaltet. Die
Zustände ändern sich als Reaktion auf die Methoden, die von den Benutzern
unserer Bibliothek auf der `Post`-Instanz aufgerufen werden, aber sie müssen
die Zustandsänderungen nicht direkt verwalten. Auch können die Benutzer keinen
Fehler mit den Zuständen machen, z.B. einen Beitrag veröffentlichen, bevor er
überprüft wurde.

### Definieren von `Post` und Erstellen einer neuen Instanz im Entwurfszustand

Fangen wir mit der Implementierung der Bibliothek an! Wir wissen, dass wir eine
öffentliche Struktur `Post` benötigen, die einige Inhalte enthält, also
beginnen wir mit der Definition der Struktur und einer zugehörigen öffentlichen
Funktion `new`, um eine Instanz von `Post` zu erzeugen, wie in Codeblock 18-12
gezeigt. Wir werden auch ein privates Merkmal `State` erstellen, das das
Verhalten definiert, das alle Zustandsobjekte für einen `Post` haben müssen.

Dann wird `Post` ein Merkmalsobjekt (trait object) von `Box<dyn State>`
innerhalb einer `Option<T>` in einem privaten Feld namens `state` halten, um
das Zustandsobjekt zu halten. Du wirst gleich sehen, warum die `Option<T>`
notwendig ist.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
pub struct Post {
    state: Option<Box<dyn State>>,
    content: String,
}

impl Post {
    pub fn new() -> Post {
        Post {
            state: Some(Box::new(Draft {})),
            content: String::new(),
        }
    }
}

trait State {}

struct Draft {}

impl State for Draft {}
```

<span class="caption">Codeblock 18-12: Definition einer Struktur `Post` und
einer Funktion `new`, die eine neue `Post`-Instanz erzeugt, einem Merkmal
`State` und einer Struktur `Draft`</span>

Das Merkmal `State` definiert das Verhalten, das die verschiedenen
Beitragszustände gemeinsam haben. Die Zustandsobjekte sind `Draft`,
`PendingReview` und `Published` und sie werden alle das Merkmal `State`
implementieren. Im Moment hat das Merkmal noch keine Methoden und wir werden
damit beginnen, nur den Zustand `Draft` zu definieren, weil das der Zustand
ist, in dem ein Beitrag beginnen soll.

Wenn wir einen neuen `Post` erstellen, setzen wir sein `state`-Feld auf einen
`Some`-Wert, der eine `Box` enthält. Diese `Box` verweist auf eine neue Instanz
der Struktur `Draft`. Dies stellt sicher, dass jedes Mal, wenn wir eine neue
Instanz von `Post` erzeugen, diese als Entwurf beginnt. Da das Feld `state` von
`Post` privat ist, gibt es keine Möglichkeit, einen `Post` in einem anderen
Zustand zu erzeugen! In der Funktion `Post::new` setzen wir das Feld `content`
auf einen neuen, leeren `String`.

### Speichern des Textes des Beitragsinhalts

Wir haben in Codeblock 18-11 gesehen, dass wir in der Lage sein wollen, eine
Methode namens `add_text` aufzurufen und ihr einen `&str` zu übergeben, die
dann als Textinhalt des Blog-Beitrags hinzugefügt wird. Wir implementieren dies
als Methode, anstatt das Feld `content` mit `pub` offenzulegen, damit wir
später eine Methode implementieren können, die steuert, wie die Daten des
Feldes `content` gelesen werden. Die Methode `add_text` ist ziemlich einfach,
also lass uns die Implementierung in Codeblock 18-13 zum Block `impl Post`
hinzufügen.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
# pub struct Post {
#     state: Option<Box<dyn State>>,
#     content: String,
# }
#
impl Post {
    // --abschneiden--
#     pub fn new() -> Post {
#         Post {
#             state: Some(Box::new(Draft {})),
#             content: String::new(),
#         }
#     }
#
    pub fn add_text(&mut self, text: &str) {
        self.content.push_str(text);
    }
}
#
# trait State {}
#
# struct Draft {}
#
# impl State for Draft {}
```

<span class="caption">Codeblock 18-13: Implementierung der Methode `add_text`
zum Hinzufügen von Text zum `content` eines Beitrags</span>

Die Methode `add_text` nimmt eine veränderbare Referenz auf `self`, weil wir
die `Post`-Instanz, auf der wir `add_text` aufrufen, ändern. Dann rufen wir
`push_str` auf den `String` in `content` auf und übergeben das Argument `text`,
um es zum gespeicherten `content` hinzuzufügen. Dieses Verhalten hängt nicht
vom Zustand ab, in dem sich der Beitrag befindet, es ist also nicht Teil des
Zustandsmusters. Die Methode `add_text` interagiert überhaupt nicht mit dem
Feld `state`, aber sie ist Teil des Verhaltens, das wir unterstützen wollen.

### Sicherstellen, dass der Inhalt eines Beitragsentwurfs leer ist

Selbst nachdem wir `add_text` aufgerufen und unserem Beitrag etwas Inhalt
hinzugefügt haben, wollen wir immer noch, dass die Methode `content` einen
leeren Zeichenkettenanteilstyp (string slice) zurückgibt, weil sich der Beitrag
noch im Entwurfszustand befindet, wie in Zeile 7 von Codeblock 18-11 gezeigt
wird. Lass uns fürs Erste die `content`-Methode mit der einfachsten Sache
implementieren, die diese Anforderung erfüllt: Immer einen leeren
Zeichenkettenanteilstyp zurückgeben. Wir werden dies später ändern, sobald wir
die Möglichkeit implementiert haben, den Zustand eines Beitrags zu ändern,
damit er veröffentlicht werden kann. Bislang können Beiträge nur im
Entwurfszustand sein, daher sollte der Beitragsinhalt immer leer sein.
Codeblock 18-14 zeigt diese Platzhalter-Implementierung.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
# pub struct Post {
#     state: Option<Box<dyn State>>,
#     content: String,
# }
#
impl Post {
    // --abschneiden--
#     pub fn new() -> Post {
#         Post {
#             state: Some(Box::new(Draft {})),
#             content: String::new(),
#         }
#     }
#
#     pub fn add_text(&mut self, text: &str) {
#         self.content.push_str(text);
#     }
#
    pub fn content(&self) -> &str {
        ""
    }
}
#
# trait State {}
#
# struct Draft {}
#
# impl State for Draft {}
```

<span class="caption">Codeblock 18-14: Hinzufügen einer
Platzhalter-Implementierung für die `content`-Methode auf `Post`, die immer
einen leeren Zeichenkettenanteilstyp zurückgibt</span>

Mit dieser zusätzlichen Methode `content` funktioniert alles in Codeblock 18-11
bis hin zu Zeile 7 wie beabsichtigt.

### Antrag auf Überprüfung ändert den Zustand des Beitrags

Als nächstes müssen wir eine Funktionalität hinzufügen, um eine Überprüfung
eines Beitrags zu beantragen, die seinen Zustand von `Draft` in `PendingReview`
ändern sollte. Codeblock 18-15 zeigt diesen Code.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
# pub struct Post {
#     state: Option<Box<dyn State>>,
#     content: String,
# }
#
impl Post {
    // --abschneiden--
#     pub fn new() -> Post {
#         Post {
#             state: Some(Box::new(Draft {})),
#             content: String::new(),
#         }
#     }
#
#     pub fn add_text(&mut self, text: &str) {
#         self.content.push_str(text);
#     }
#
#     pub fn content(&self) -> &str {
#         ""
#     }
#
    pub fn request_review(&mut self) {
        if let Some(s) = self.state.take() {
            self.state = Some(s.request_review())
        }
    }
}

trait State {
    fn request_review(self: Box<Self>) -> Box<dyn State>;
}

struct Draft {}

impl State for Draft {
    fn request_review(self: Box<Self>) -> Box<dyn State> {
        Box::new(PendingReview {})
    }
}

struct PendingReview {}

impl State for PendingReview {
    fn request_review(self: Box<Self>) -> Box<dyn State> {
        self
    }
}
```

<span class="caption">Codeblock 18-15: Implementierung der Methoden
`request_review` für `Post` und des Merkmals `State`</span>

Wir geben `Post` eine öffentliche Methode namens `request_review`, die eine
veränderbare Referenz auf `self` nimmt. Dann rufen wir eine interne
`request_review`-Methode über den aktuellen Zustand von `Post` auf und diese
zweite `request_review`-Methode konsumiert den aktuellen Zustand und gibt einen
neuen Zustand zurück.

Wir fügen die Methode `request_review` zum Merkmal `State` hinzu; alle Typen,
die das Merkmal implementieren, müssen nun die Methode `request_review`
implementieren. Beachte, dass wir statt `self`, `&self` oder `&mut self` als
ersten Parameter der Methode `self: Box<Self>` haben. Diese Syntax bedeutet,
dass die Methode nur gültig ist, wenn sie auf einer `Box` mit dem Typ
aufgerufen wird. Diese Syntax übernimmt die Eigentümerschaft von `Box<Self>`,
wodurch der alte Zustand ungültig wird, sodass der Zustandswert von `Post` in
einen neuen Zustand transformiert werden kann.

Um den alten Zustand zu konsumieren, muss die `request_review`-Methode die
Eigentümerschaft des Zustandswerts übernehmen. Hier kommt die `Option` im Feld
`state` von `Post` ins Spiel: Wir rufen die Methode `take` auf, um den
`Some`-Wert aus dem `state`-Feld zu nehmen und an seiner Stelle ein `None` zu
hinterlassen, weil Rust es nicht zulässt, dass wir unbestückte Felder in
Strukturen haben. Dadurch können wir den Wert `state` aus `Post` herausnehmen,
anstatt ihn auszuleihen. Dann setzen wir den Wert `state` des Beitrags auf das
Ergebnis dieser Operation.

Wir müssen `state` vorübergehend auf `None` setzen, anstatt es direkt mit Code
wie `self.state = self.state.request_review();` zu setzen, um die
Eigentümerschaft des `state`-Wertes zu erhalten. Das stellt sicher, dass `Post`
nicht den alten `state`-Wert verwenden kann, nachdem wir ihn in einen neuen
Zustand transformiert haben.

Die Methode `request_review` auf `Draft` gibt eine neue, in einer Box
gespeicherte Instanz einer neuen `PendingReview`-Struktur zurück, die den
Zustand darstellt, in dem ein Beitrag auf eine Überprüfung wartet. Die Struktur
`PendingReview` implementiert auch die Methode `request_review`, führt aber
keine Transformationen durch. Vielmehr gibt sie sich selbst zurück, denn wenn
wir eine Überprüfung für einen Beitrag anfordern, der sich bereits im
`PendingReview`-Zustand befindet, sollte er im `PendingReview`-Zustand bleiben.

Jetzt können wir anfangen, die Vorteile des Zustandsmusters zu erkennen: Die
Methode `request_review` auf `Post` ist die gleiche, unabhängig von ihrem
`state`-Wert. Jeder Zustand ist für seine eigenen Regeln verantwortlich.

Wir lassen die Methode `content` auf `Post` so wie sie ist und geben einen
leeren Zeichenkettenanteilstyp zurück. Wir können jetzt einen `Post` sowohl im
Zustand `PendingReview` als auch im Zustand `Draft` haben, aber wir wollen das
gleiche Verhalten im Zustand `PendingReview`. Codeblock 18-11 funktioniert
jetzt bis Zeile 10!

### Hinzufügen von `approve`, um das Verhalten von `content` zu ändern

Die Methode `approve` ähnelt der Methode `request_review`: Sie setzt den
`state` auf den Wert, den der aktuelle Zustand nach der Genehmigung haben
sollte, wie in Codeblock 18-16 gezeigt:

<span class="filename">Dateiname: src/lib.rs</span>

```rust
# pub struct Post {
#     state: Option<Box<dyn State>>,
#     content: String,
# }
#
impl Post {
    // --abschneiden--
#     pub fn new() -> Post {
#         Post {
#             state: Some(Box::new(Draft {})),
#             content: String::new(),
#         }
#     }
#
#     pub fn add_text(&mut self, text: &str) {
#         self.content.push_str(text);
#     }
#
#     pub fn content(&self) -> &str {
#         ""
#     }
#
#     pub fn request_review(&mut self) {
#         if let Some(s) = self.state.take() {
#             self.state = Some(s.request_review())
#         }
#     }
#
    pub fn approve(&mut self) {
        if let Some(s) = self.state.take() {
            self.state = Some(s.approve())
        }
    }
}

trait State {
    fn request_review(self: Box<Self>) -> Box<dyn State>;
    fn approve(self: Box<Self>) -> Box<dyn State>;
}

struct Draft {}

impl State for Draft {
    // --abschneiden--
#     fn request_review(self: Box<Self>) -> Box<dyn State> {
#         Box::new(PendingReview {})
#     }
#
    fn approve(self: Box<Self>) -> Box<dyn State> {
        self
    }
}

struct PendingReview {}

impl State for PendingReview {
    // --abschneiden--
#     fn request_review(self: Box<Self>) -> Box<dyn State> {
#         self
#     }
#
    fn approve(self: Box<Self>) -> Box<dyn State> {
        Box::new(Published {})
    }
}

struct Published {}

impl State for Published {
    fn request_review(self: Box<Self>) -> Box<dyn State> {
        self
    }

    fn approve(self: Box<Self>) -> Box<dyn State> {
        self
    }
}
```

<span class="caption">Codeblock 18-16: Implementierung der Methode `approve`
bei `Post` und des Merkmals `State`</span>

Wir fügen die Methode `approve` zum Merkmal `State` hinzu und fügen eine neue
Struktur `Published` hinzu, die den Zustand `Published` implementiert.

Ähnlich wie `request_review` bei `PendingReview` funktioniert, hat der Aufruf
der Methode `approve` bei einem `Draft` keine Wirkung, weil `approve` den Wert
`self` zurückgibt. Wenn wir die Methode `approve` bei `PendingReview` aufrufen,
gibt sie eine neue, geschlossene Instanz der Struktur `Published` zurück. Die
Struktur `Published` implementiert das Merkmal `State` und sowohl bei der
Methode `request_review` als auch bei der Methode `approve` gibt sie sich
selbst zurück, weil der Beitrag in diesen Fällen im Zustand `Published` bleiben
sollte.

Jetzt müssen wir die Methode `content` auf `Post` aktualisieren: Wir wollen,
dass der von `content` zurückgegebene Wert vom aktuellen Zustand von `Post`
abhängt, also delegieren wir `Post` an eine `content`-Methode, die auf seinen
`state` definiert ist, wie in Codeblock 18-17 gezeigt:

<span class="filename">Dateiname: src/lib.rs</span>

```rust,does_not_compile
# pub struct Post {
#     state: Option<Box<dyn State>>,
#     content: String,
# }
#
impl Post {
    // --abschneiden--
#     pub fn new() -> Post {
#         Post {
#             state: Some(Box::new(Draft {})),
#             content: String::new(),
#         }
#     }
#
#     pub fn add_text(&mut self, text: &str) {
#         self.content.push_str(text);
#     }
#
    pub fn content(&self) -> &str {
        self.state.as_ref().unwrap().content(self)
    }
    // --abschneiden--
#
#     pub fn request_review(&mut self) {
#         if let Some(s) = self.state.take() {
#             self.state = Some(s.request_review())
#         }
#     }
#
#     pub fn approve(&mut self) {
#         if let Some(s) = self.state.take() {
#             self.state = Some(s.approve())
#         }
#     }
}
#
# trait State {
#     fn request_review(self: Box<Self>) -> Box<dyn State>;
#     fn approve(self: Box<Self>) -> Box<dyn State>;
# }
#
# struct Draft {}
#
# impl State for Draft {
#     fn request_review(self: Box<Self>) -> Box<dyn State> {
#         Box::new(PendingReview {})
#     }
#
#     fn approve(self: Box<Self>) -> Box<dyn State> {
#         self
#     }
# }
#
# struct PendingReview {}
#
# impl State for PendingReview {
#     fn request_review(self: Box<Self>) -> Box<dyn State> {
#         self
#     }
#
#     fn approve(self: Box<Self>) -> Box<dyn State> {
#         Box::new(Published {})
#     }
# }
#
# struct Published {}
#
# impl State for Published {
#     fn request_review(self: Box<Self>) -> Box<dyn State> {
#         self
#     }
#
#     fn approve(self: Box<Self>) -> Box<dyn State> {
#         self
#     }
# }
```

<span class="caption">Codeblock 18-17: Aktualisieren der Methode `content` auf
`Post` zum Delegieren an eine Methode `content` auf `State`</span>

Da das Ziel darin besteht, all diese Regeln innerhalb der Strukturen zu halten,
die `State` implementieren, rufen wir eine Methode `content` auf dem Wert in
`state` auf und übergeben die Post-Instanz (d.h. `self`) als Argument. Dann
geben wir den Wert zurück, der von der Verwendung der Methode `content` für den
`state`-Wert zurückgegeben wird.

Wir rufen die Methode `as_ref` auf `Option` auf, weil wir eine Referenz auf den
Wert innerhalb `Option` wollen und nicht die Eigentümerschaft am Wert. Weil
`State` eine `Option<Box<dyn State>>` ist, wird beim Aufruf von `as_ref` eine
`Option<&Box<dyn State>>` zurückgegeben. Würden wir nicht `as_ref` aufrufen,
bekämen wir einen Fehler, weil wir `state` nicht aus dem ausgeliehenen `&self`
im Funktionsparameter herausverschieben können.

Wir rufen dann die `unwrap`-Methode auf, von der wir wissen, dass sie das
Programm niemals abstürzen lassen wird, weil wir wissen, dass die Methoden auf
`Post` sicherstellen, dass `state` stets einen `Some`-Wert enthält, wenn diese
Methoden zu Ende sind. Dies ist einer der Fälle, über die wir in [„Fälle, in
denen du mehr Informationen als der Compiler hast“][more-info-than-rustc] in
Kapitel 9 gesprochen haben, wenn wir wissen, dass ein `None`-Wert niemals
möglich ist, obwohl der Compiler nicht in der Lage ist, das zu verstehen.

Wenn wir nun `content` auf der `&Box<dyn State>` aufrufen, wird eine
automatische Umwandlung (deref coercion) auf `&` und `Box` stattfinden, sodass
die `content`-Methode letztlich auf dem Typ aufgerufen wird, der das Merkmal
`State` implementiert. Das bedeutet, dass wir die Definition des Merkmals
`State` um `content` erweitern müssen, und hier werden wir die Logik dafür
unterbringen, welcher Inhalt je nach Zustand zurückgegeben wird, wie in
Codeblock 18-18 gezeigt wird:

<span class="filename">Dateiname: src/lib.rs</span>

```rust
# pub struct Post {
#     state: Option<Box<dyn State>>,
#     content: String,
# }
#
# impl Post {
#     pub fn new() -> Post {
#         Post {
#             state: Some(Box::new(Draft {})),
#             content: String::new(),
#         }
#     }
#
#     pub fn add_text(&mut self, text: &str) {
#         self.content.push_str(text);
#     }
#
#     pub fn content(&self) -> &str {
#         self.state.as_ref().unwrap().content(self)
#     }
#
#     pub fn request_review(&mut self) {
#         if let Some(s) = self.state.take() {
#             self.state = Some(s.request_review())
#         }
#     }
#
#     pub fn approve(&mut self) {
#         if let Some(s) = self.state.take() {
#             self.state = Some(s.approve())
#         }
#     }
# }
#
trait State {
    // --abschneiden--
#     fn request_review(self: Box<Self>) -> Box<dyn State>;
#     fn approve(self: Box<Self>) -> Box<dyn State>;
#
    fn content<'a>(&self, post: &'a Post) -> &'a str {
        ""
    }
}

// --abschneiden--
#
# struct Draft {}
#
# impl State for Draft {
#     fn request_review(self: Box<Self>) -> Box<dyn State> {
#         Box::new(PendingReview {})
#     }
#
#     fn approve(self: Box<Self>) -> Box<dyn State> {
#         self
#     }
# }
#
# struct PendingReview {}
#
# impl State for PendingReview {
#     fn request_review(self: Box<Self>) -> Box<dyn State> {
#         self
#     }
#
#     fn approve(self: Box<Self>) -> Box<dyn State> {
#         Box::new(Published {})
#     }
# }
#
struct Published {}

impl State for Published {
    // --abschneiden--
#     fn request_review(self: Box<Self>) -> Box<dyn State> {
#         self
#     }
#
#     fn approve(self: Box<Self>) -> Box<dyn State> {
#         self
#     }
#
    fn content<'a>(&self, post: &'a Post) -> &'a str {
        &post.content
    }
}
```

<span class="caption">Codeblock 18-18: Hinzufügen der Methode `content` zum
Merkmal `State`</span>

Wir fügen eine Standard-Implementierung für die Methode `content` hinzu, die
einen leeren Zeichenkettenanteilstyp zurückgibt. Das bedeutet, dass wir
`content` in den Strukturen `Draft` und `PendingReview` nicht implementieren
müssen. Die Struktur `Published` überschreibt die Methode `content` und gibt
den Wert in `post.content` zurück.

Beachte, dass wir Lebensdauer-Annotationen bei dieser Methode benötigen, wie
wir in Kapitel 10 besprochen haben. Wir nehmen eine Referenz auf ein `post` als
Argument und geben eine Referenz auf einen Teil dieses `post` zurück, sodass
die Lebensdauer der zurückgegebenen Referenz mit der Lebensdauer des
`post`-Arguments zusammenhängt.

Und wir sind fertig &ndash; der Codeblock 18-11 funktioniert jetzt! Wir haben
das Zustandsmuster mit den Regeln des Blog-Beitrags-Workflows implementiert.
Die Logik, die sich auf die Regeln bezieht, lebt in den Zustandsobjekten und
ist nicht über den gesamten `Post` verstreut.

> ### Warum keine Aufzählung?
>
> Vielleicht hast du dich gefragt, warum wir nicht ein `enum` mit den
> verschiedenen möglichen Poststatus als Varianten verwendet haben. Das ist
> sicherlich eine mögliche Lösung. Probiere es aus und vergleiche die
> Endergebnisse, um zu sehen, was du bevorzugst! Ein Nachteil der Verwendung
> einer Aufzählung ist, dass jede Stelle, die den Wert der Aufzählung prüft,
> einen `match`-Ausdruck oder ähnliches benötigt, um jede mögliche Variante zu
> behandeln. Dies könnte zu mehr Wiederholungen führen als die Lösung mit dem
> Merkmals-Objekt.

### Kompromisse des Zustandsmusters

Wir haben gezeigt, dass Rust in der Lage ist, das objektorientierte
Zustandsmuster zu implementieren, um die verschiedenen Verhaltensweisen, die
ein Beitrag im jeweiligen Zustand haben sollte, zu kapseln. Die Methoden auf
`Post` wissen nichts über die verschiedenen Verhaltensweisen. So, wie wir den
Code organisiert haben, müssen wir nur an einem einzigen Ort suchen, um zu
wissen, wie sich ein veröffentlichter Beitrag verhalten kann: Die
Implementierung des Merkmals `State` auf der Struktur `Published`.

Wenn wir eine alternative Implementierung erstellen würden, die nicht das
Zustandsmuster verwendet, könnten wir stattdessen `match`-Ausdrücke in den
Methoden auf `Post` oder sogar im `main`-Code verwenden, die den Zustand des
Beitrags überprüfen und das Verhalten an diesen Stellen ändern. Das würde
bedeuten, dass wir an mehreren Stellen nachschauen müssten, um alle
Auswirkungen eines Beitrags im veröffentlichten Zustand zu verstehen! Dies
würde sich nur noch erhöhen, je mehr Zustände wir hinzufügen: Jeder dieser
`match`-Ausdrücke würde einen weiteren Zweig benötigen.

Mit dem Zustandsmuster, den `Post`-Methoden und den Stellen, an denen wir
`Post` verwenden, brauchen wir keine `match`-Ausdrücke, und um einen neuen
Zustand hinzuzufügen, müssten wir nur eine neue Struktur hinzufügen und die
Merkmalsmethoden auf dieser einen Struktur implementieren.

Die Implementierung unter Verwendung des Zustandsmusters ist leicht zu
erweitern, um weitere Funktionalität hinzuzufügen. Um zu sehen, wie einfach es
ist, Code zu pflegen, der das Zustandsmuster verwendet, probiere einige dieser
Vorschläge aus:

- Füge eine `reject`-Methode hinzu, die den Zustand des Beitrags von
  `PendingReview` zurück zu `Draft` ändert.
- Verlange zwei `approve`-Aufrufe, bevor der Zustand in `Published` geändert
  werden kann.
- Erlaube Benutzern das Hinzufügen von Textinhalten nur dann, wenn sich ein
  Beitrag im Zustand `Draft` befindet. Hinweis: Lasse das Zustandsobjekt dafür
  verantwortlich sein, was sich am Inhalt ändern könnte, aber nicht für die
  Änderung des Beitrags.

Ein Nachteil des Zustandsmusters besteht darin, dass einige der Zustände
miteinander gekoppelt sind, weil die Zustände die Übergänge zwischen den
Zuständen implementieren. Wenn wir einen weiteren Zustand zwischen
`PendingReview` und `Published` hinzufügen, z.B. `Scheduled`, müssten wir den
Code in `PendingReview` ändern und stattdessen zu `Scheduled` übergehen. Es
wäre weniger Arbeit, wenn `PendingReview` nicht mit dem Hinzufügen eines neuen
Zustands geändert werden müsste, aber das würde bedeuten, zu einem anderen
Entwurfsmuster zu wechseln.

Ein weiterer Nachteil ist, dass wir eine gewisse Logik dupliziert haben. Um
einen Teil der Duplikation zu eliminieren, könnten wir versuchen,
Standard-Implementierungen für die Methoden `request_review` und `approval` für
das Merkmal `State` zu erstellen, die `self` zurückgeben; dies würde jedoch
nicht funktionieren: Bei der Verwendung von `State` als Merkmals-Objekt weiß
das Merkmal nicht, was das konkrete `self` genau sein wird, sodass der
Rückgabetyp zur Kompilierzeit nicht bekannt ist. (Dies ist eine der bereits
erwähnten dyn-Kompatibilitätsregeln).

Eine weitere Duplikation sind die ähnlichen Implementierungen der Methoden
`request_review` und `approve` auf `Post`. Beide Methoden verwenden
`Option::take` mit dem Feld `state` von `Post`, und wenn `state` den Wert
`Some` hat, delegieren sie den Aufruf an die gleiche Methode des umschlossenen
Werts und speichern das Ergebnis im Feld `state`. Wenn wir viele Methoden auf
`Post` hätten, die diesem Muster folgen, könnten wir in Erwägung ziehen, ein
Makro zu definieren, um die Wiederholung zu eliminieren (siehe
[„Makros“][macros] in Kapitel 20).

Indem wir das Zustandsmuster genau so implementieren, wie es für
objektorientierte Sprachen definiert ist, nutzen wir die Stärken Rusts nicht so
aus, wie wir es könnten. Sehen wir uns einige Änderungen an, die wir an der
Kiste `blog` vornehmen können, die ungültige Zustände und Übergänge in
Kompilierzeitfehler verwandeln können.

#### Kodieren von Zuständen und Verhalten als Typen

Wir werden dir zeigen, wie du das Zustandsmuster überdenken kannst, um andere
Kompromisse zu erzielen. Anstatt die Zustände und Übergänge vollständig zu
kapseln, sodass Außenstehende keine Kenntnis von ihnen haben, werden wir die
Zustände in verschiedene Typen kodieren. Folglich wird Rusts
Typprüfungssystem Versuche verhindern, Entwurfsbeiträge zu verwenden, bei denen
nur veröffentlichte Beiträge erlaubt sind, indem ein Kompilierfehler ausgegeben
wird.

Betrachten wir den ersten Teil von `main` in Codeblock 18-11:

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore
# use blog::Post;
#
fn main() {
    let mut post = Post::new();

    post.add_text("Ich habe heute Mittag einen Salat gegessen");
    assert_eq!("", post.content());
#
#     post.request_review();
#     assert_eq!("", post.content());
#
#     post.approve();
#     assert_eq!("Ich habe heute Mittag einen Salat gegessen", post.content());
}
```

Wir ermöglichen nach wie vor das Erstellen neuer Beiträge im Entwurfsstadium
unter Verwendung von `Post::new` und der Möglichkeit, dem Inhalt des Beitrags
Text hinzuzufügen. Aber anstatt eine `content`-Methode bei einem
Beitragsentwurf zu haben, die eine leere Zeichenkette zurückgibt, werden wir
es so einrichten, dass Beitragsentwürfe überhaupt keine `content`-Methode
haben. Wenn wir auf diese Weise versuchen, den Inhalt eines Beitragsentwurfs
zu erhalten, erhalten wir einen Kompilierfehler, der uns sagt, dass die Methode
nicht existiert. Infolgedessen wird es für uns unmöglich, versehentlich den
Inhalt eines Beitragsentwurfs in der Produktion anzuzeigen, weil sich dieser
Code nicht einmal kompilieren lässt. Codeblock 18-19 zeigt die Definition einer
Struktur `Post` und einer Struktur `DraftPost` sowie die Methoden dieser
Strukturen.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
pub struct Post {
    content: String,
}

pub struct DraftPost {
    content: String,
}

impl Post {
    pub fn new() -> DraftPost {
        DraftPost {
            content: String::new(),
        }
    }

    pub fn content(&self) -> &str {
        &self.content
    }
}

impl DraftPost {
    pub fn add_text(&mut self, text: &str) {
        self.content.push_str(text);
    }
}
```

<span class="caption">Codeblock 18-19: Ein `Post` mit einer Methode `content`
und ein `DraftPost` ohne Methode `content`</span>

Die beiden Strukturen `Post` und `DraftPost` haben ein privates Feld `content`,
in dem der Text des Blog-Beitrags gespeichert wird. Die Strukturen haben nicht
mehr das `state`-Feld, weil wir die Kodierung des Zustands auf die Typen der
Strukturen verlagert haben. Die Struktur `Post` wird einen veröffentlichten
Beitrag repräsentieren und sie hat eine Methode `content`, die den `content`
zurückgibt.

Wir haben immer noch die Funktion `Post::new`, aber anstatt eine Instanz von
`Post` zurückzugeben, gibt sie eine Instanz von `DraftPost` zurück. Da
`content` privat ist und es keine Funktion gibt, die `Post` zurückgibt, ist es
im Moment nicht möglich, eine Instanz von `Post` zu erzeugen.

Die Struktur `DraftPost` hat eine Methode `add_text`, sodass wir wie bisher
Text zum `content` hinzufügen können, aber beachte, dass `DraftPost` keine
Methode `content` definiert hat! Daher stellt das Programm jetzt sicher, dass
alle Beiträge als Beitragsentwürfe beginnen und dass der Inhalt von
Beitragsentwürfen nicht zur Anzeige verfügbar ist. Jeder Versuch, diese
Einschränkungen zu umgehen, führt zu einem Kompilierfehler.

#### Umsetzen von Übergängen als Transformationen in verschiedene Typen

Wie bekommen wir also einen veröffentlichten Beitrag? Wir wollen die Regel
durchsetzen, dass ein Beitragsentwurf geprüft und genehmigt werden muss, bevor
er veröffentlicht werden kann. Ein Beitrag, der sich im Stadium der Überprüfung
befindet, sollte noch immer keinen Inhalt haben. Lass uns diese Bedingung
implementieren, indem wir eine weitere Struktur `PendingReviewPost` hinzufügen,
indem wir die Methode `request_review` auf `DraftPost` definieren, um einen
`PendingReviewPost` zurückzugeben, und eine Methode `approve` auf
`PendingReviewPost`, um einen `Post` zurückzugeben, wie in Codeblock 18-20
gezeigt.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
# pub struct Post {
#     content: String,
# }
#
# pub struct DraftPost {
#     content: String,
# }
#
# impl Post {
#     pub fn new() -> DraftPost {
#         DraftPost {
#             content: String::new(),
#         }
#     }
#
#     pub fn content(&self) -> &str {
#         &self.content
#     }
# }
#
impl DraftPost {
    // --abschneiden--
#     pub fn add_text(&mut self, text: &str) {
#         self.content.push_str(text);
#     }
#
    pub fn request_review(self) -> PendingReviewPost {
        PendingReviewPost {
            content: self.content,
        }
    }
}

pub struct PendingReviewPost {
    content: String,
}

impl PendingReviewPost {
    pub fn approve(self) -> Post {
        Post {
            content: self.content,
        }
    }
}
```

<span class="caption">Codeblock 18-20: Ein `PendingReviewPost`, der durch
Aufrufen von `request_review` auf `DraftPost` erzeugt wird, und eine
`approve`-Methode, die einen `PendingReviewPost` in einen veröffentlichten
`Post` verwandelt</span>

Die Methoden `request_review` und `approve` übernehmen die Eigentümerschaft von
`self`, wodurch die Instanzen `DraftPost` und `PendingReviewPost` verbraucht
und in einen `PendingReviewPost` bzw. einen veröffentlichten `Post` umgewandelt
werden. Auf diese Weise werden wir keine `DraftPost`-Instanzen mehr haben,
nachdem wir `request_review` darauf aufgerufen haben, und so weiter. Die
`PendingReviewPost`-Struktur hat keine `content`-Methode definiert, sodass der
Versuch, ihren Inhalt zu lesen, zu einem Kompilierfehler führt, wie bei
`DraftPost`. Da der einzige Weg, eine veröffentlichte `Post`-Instanz zu
erhalten, die eine `content`-Methode definiert hat, der Aufruf der
`approve`-Methode auf einem `PendingReviewPost` ist, und der einzige Weg, einen
`PendingReviewPost` zu erhalten, der Aufruf der `request_review`-Methode auf
einem `DraftPost` ist, haben wir jetzt den Blog-Beitrags-Workflow in das
Typsystem kodiert.

Aber wir müssen auch einige kleine Änderungen an `main` vornehmen. Die Methoden
`request_review` und `approve` geben neue Instanzen zurück, anstatt die
Struktur, auf der sie aufgerufen werden, zu modifizieren, sodass wir mehr `let
post =` Verschattungs-Zuweisungen (shadowing assignments) hinzufügen müssen, um
die zurückgegebenen Instanzen zu speichern. Wir können auch nicht zulassen,
dass die Zusicherungen über den Inhalt des Entwurfs und der anstehenden
Überprüfungsbeiträge leere Zeichenketten sind, und wir brauchen sie auch nicht:
Wir können keinen Code mehr kompilieren, der versucht, den Inhalt von Beiträgen
in diesen Zuständen zu verwenden. Der aktualisierte Code in `main` ist in
Codeblock 18-21 aufgeführt.

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore
use blog::Post;

fn main() {
    let mut post = Post::new();

    post.add_text("Ich habe heute Mittag einen Salat gegessen");

    let post = post.request_review();

    let post = post.approve();

    assert_eq!("Ich habe heute Mittag einen Salat gegessen", post.content());
}
```

<span class="caption">Codeblock 18-21: Änderungen an `main`, um die neue
Implementierung des Blog-Beitrags-Workflows zu nutzen</span>

Die Änderungen, die wir an `main` vornehmen mussten, um `post` neu zuzuweisen,
bedeuten, dass diese Implementierung nicht mehr ganz dem objektorientierten
Zustandsmuster folgt: Die Transformationen zwischen den Zuständen sind nicht
mehr vollständig in der `Post`-Implementierung gekapselt. Unser Vorteil ist
jedoch, dass ungültige Zustände aufgrund des Typsystems und der Typprüfung, die
zur Kompilierzeit stattfindet, jetzt unmöglich sind! Dadurch wird
sichergestellt, dass bestimmte Fehler, z.B. das Anzeigen des Inhalts eines
unveröffentlichten Beitrags, entdeckt werden, bevor sie in die Produktion
gelangen.

Versuche es mit den Aufgaben, die wir zu Beginn dieses Abschnitts über die
Kiste `blog` nach Codeblock 18-20 erwähnt haben, um zu sehen, was du über das
Design dieser Version des Codes denkst. Beachte, dass einige der Aufgaben
möglicherweise bereits in diesem Entwurf abgeschlossen sind.

Wir haben gesehen, dass, obwohl Rust in der Lage ist, objektorientierte
Entwurfsmuster zu implementieren, auch andere Muster, z.B. das Kodieren des
Zustands in das Typsystem, in Rust verfügbar sind. Diese Muster weisen
unterschiedliche Kompromisse auf. Auch wenn du mit objektorientierten Mustern
sehr vertraut bist, kann ein Überdenken des Problems, um die Funktionen von
Rust zu nutzen, Vorteile bringen, z.B. das Vermeiden einiger Fehler zur
Kompilierzeit. Objektorientierte Muster werden in Rust nicht immer die beste
Lösung sein, da objektorientierte Sprachen bestimmte Funktionalitäten, z.B.
Eigentümerschaft, nicht haben.

## Zusammenfassung

Unabhängig davon, ob du nach der Lektüre dieses Kapitels der Meinung bist, dass
Rust eine objektorientierte Sprache ist, weißt du jetzt, dass du Merkmalsobjekte
verwenden kannst, um einige objektorientierte Funktionalitäten in Rust zu
erhalten. Dynamische Aufrufe können deinem Code eine gewisse Flexibilität im
Austausch gegen ein wenig Laufzeitperformanz verleihen. Du kannst diese
Flexibilität nutzen, um objektorientierte Muster zu implementieren, die die
Wartbarkeit deines Codes verbessern können. Rust hat auch andere
Funktionalitäten, z.B. Eigentümerschaft, die objektorientierte Sprachen nicht
haben. Ein objektorientiertes Muster wird nicht immer der beste Weg sein, um
die Stärken von Rust zu nutzen, aber es ist eine verfügbare Option.

Als nächstes werden wir uns mit Mustern befassen, die eine weitere
Funktionalität von Rust sind und viel Flexibilität ermöglichen. Wir haben sie
uns im Laufe des Buches kurz angeschaut, haben aber noch nicht ihre volle
Leistungsfähigkeit gesehen. Los geht's!

[more-info-than-rustc]: ch09-03-to-panic-or-not-to-panic.html#fälle-in-denen-du-mehr-informationen-als-der-compiler-hast
[macros]: ch20-06-macros.html
