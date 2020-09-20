## Makros

Wir haben in diesem Buch Makros wie `println!` verwendet, aber wir haben noch
nicht vollständig erforscht, was ein Makro ist und wie es funktioniert. Der
Begriff *Makro* bezieht sich auf eine Familie von Funktionalitäten in Rust:
*Deklarative* Makros mit `macro_rules!` und drei Arten *prozeduraler* Makros:

* Benutzerdefinierte Makros mit `#[derive]`, die Code spezifizieren, der mit
  dem Attribut `derive` hinzugefügt wurde, das bei Strukturen (structs) und
  Aufzählungen (enums) verwendet wird
* Attribut-ähnliche Makros, die benutzerdefinierte Attribute definieren, die
  bei jedem Element verwendet werden können
* Funktions-ähnliche Makros, die wie Funktionsaufrufe aussehen, aber auf den
  als Argument angegebenen Token operieren

Wir werden der Reihe nach über jedes dieser Themen sprechen, aber zuerst wollen
wir uns ansehen, warum wir Makros überhaupt brauchen, wenn wir bereits
Funktionen haben.

### Der Unterschied zwischen Makros und Funktionen

Im Grunde genommen sind Makros eine Möglichkeit, Code zu schreiben, der anderen
Code schreibt, was als *Metaprogrammierung* bekannt ist. In Anhang C besprechen
wir das Attribut `derive`, das dir eine Implementierung verschiedener Merkmale
(traits) generiert. Wir haben im ganzen Buch auch die Makros `println!` und
`vec!` verwendet. All diese Makros werden *expandiert*, um mehr Code zu
erzeugen als der Code, den du manuell geschrieben hast.

Metaprogrammierung ist nützlich, um die Menge an Code zu reduzieren, die du
schreiben und pflegen musst, was auch eine der Aufgaben von Funktionen ist.
Makros haben jedoch einige zusätzliche Fähigkeiten, die Funktionen nicht haben.

Eine Funktionssignatur muss die Anzahl und den Typ der Parameter deklarieren,
die die Funktion hat. Makros hingegen können eine variable Anzahl von
Parametern entgegennehmen: Wir können `println!("Hallo")` mit einem Argument
oder `println!("Hallo {}", name)` mit zwei Argumenten aufrufen. Außerdem werden
Makros expandiert, bevor der Compiler die Bedeutung des Codes interpretiert,
sodass ein Makro beispielsweise ein Merkmal auf einen bestimmten Typ
implementieren kann. Eine Funktion kann das nicht, weil sie zur Laufzeit
aufgerufen wird und ein Merkmal zur Kompilierzeit implementiert werden muss.

Der Nachteil des Implementierens eines Makros anstelle einer Funktion besteht
darin, dass Makrodefinitionen komplexer sind als Funktionsdefinitionen, weil du
Rust-Code schreibst, der Rust-Code schreibt. Aufgrund dieser Indirektion sind
Makrodefinitionen im Allgemeinen schwieriger zu lesen, zu verstehen und zu
pflegen als Funktionsdefinitionen.

Ein weiterer wichtiger Unterschied zwischen Makros und Funktionen besteht
darin, dass du Makros definieren oder in den Gültigkeitsbereich bringen musst,
*bevor* du sie in einer Datei aufrufst, im Gegensatz zu Funktionen, die du
überall definieren und überall aufrufen kannst.

### Deklarative Makros mit `macro_rules!` für allgemeine Metaprogrammierung

Die am weitesten verbreitete Form von Makros in Rust sind *deklarative Makros*.
Diese werden manchmal auch als „Beispielmakros“ (macros by example),
„`macro_rules!`-Makros“ oder einfach nur „Makros“ bezeichnet. In ihrem Kern
erlauben deklarative Makros etwas Ähnliches wie einen Rust-Ausdruck zu
schreiben. Wie in Kapitel 6 besprochen, sind `match`-Ausdrücke
Kontrollstrukturen, die einen Ausdruck entgegennehmen, den resultierenden Wert
des Ausdrucks mit Mustern abgleichen und dann den Code ausführen, der mit dem
passenden Muster assoziiert ist. Makros vergleichen ebenfalls einen Wert mit
Mustern, die mit einem bestimmten Code assoziiert sind: In dieser Situation ist
der Wert der literale Rust-Quellcode, der an das Makro übergeben wird; die
Muster werden mit der Struktur dieses Quellcodes verglichen; und der mit jedem
Muster assoziierte Code ersetzt, wenn er passt, den an das Makro übergebenen
Code. Dies alles geschieht während der Kompilierung.

Um ein Makro zu definieren, verwendest du das Konstrukt `macro_rules!`. Lass
uns untersuchen, wie man `macro_rules!` benutzt, indem wir uns ansehen, wie das
Makro `vec!` definiert wird. Kapitel 8 behandelte, wie wir das Makro `vec!`
verwenden können, um einen neuen Vektor mit bestimmten Werten zu erzeugen. Zum
Beispiel erzeugt das folgende Makro einen neuen Vektor, der drei ganze Zahlen
enthält:

```rust
let v: Vec<u32> = vec![1, 2, 3];
```

Wir könnten auch das Makro `vec!` verwenden, um einen Vektor aus zwei ganzen
Zahlen oder einen Vektor aus fünf Zeichenkettenanteilstypen (string slices) zu
erstellen. Wir wären nicht in der Lage, eine Funktion zu verwenden, um dasselbe
zu tun, weil wir die Anzahl oder den Typ der Werte nicht im Voraus kennen
würden.

Codeblock 19-28 zeigt eine leicht vereinfachte Definition des Makros `vec!`.

<span class="filename">Dateiname: src/lib.rs</span>

```rust
#[macro_export]
macro_rules! vec {
    ( $( $x:expr ),* ) => {
        {
            let mut temp_vec = Vec::new();
            $(
                temp_vec.push($x);
            )*
            temp_vec
        }
    };
}
```

<span class="caption">Codeblock 19-28: Eine vereinfachte Version der
Makrodefinition `vec!`</span>

> Hinweis: Die eigentliche Definition des Makros `vec!` in der
> Standardbibliothek enthält Code zum Vorbelegen der korrekten Speichermenge.
> Dieser Code ist eine Optimierung, die wir hier nicht angeben, um das Beispiel
> einfacher zu machen.

Die Annotation `#[macro_export]` gibt an, dass dieses Makro immer dann zur
Verfügung gestellt werden soll, wenn die Kiste (crate), in der das Makro
definiert ist, in den Gültigkeitsbereich gebracht wird. Ohne diese Annotation
kann das Makro nicht in den Gültigkeitsbereich gebracht werden.

Dann beginnen wir die Makrodefinition mit `macro_rules!` und dem Namen des
Makros, den wir *ohne* Ausrufezeichen definieren. Der Name, in diesem Fall
`vec`, wird von geschweiften Klammern gefolgt, die den Rumpf der
Makrodefinition kennzeichnen.

Die Struktur im `vec!` -Rumpf ähnelt der Struktur eines `match`-Ausdrucks. Hier
haben wir einen Zweig mit dem Muster `( $( $x:expr ),* )`, gefolgt von `=>` und
dem mit diesem Muster assoziierten Codeblock. Wenn das Muster passt, wird der
zugehörige Codeblock ausgegeben. Da dies das einzige Muster in diesem Makro
ist, gibt es nur einen gültigen Weg der passen kann; jedes andere Muster führt
zu einem Fehler. Komplexere Makros werden mehr als einen Zweig haben.

Die gültige Mustersyntax in Makrodefinitionen unterscheidet sich von der in
Kapitel 18 behandelten Mustersyntax, da Makromuster mit der Rust-Codestruktur
und nicht mit Werten abgeglichen werden. Lass uns durchgehen, was die
Musterteile in Listing 19-28 bedeuten; die vollständige Makromustersyntax
findest du in [der Referenz][macro-reference].

Zunächst umfasst eine Reihe von Klammern das gesamte Muster. Als Nächstes folgt
ein Dollarzeichen (`$`), gefolgt von einem Satz von Klammern, der Werte
erfasst, die mit dem Muster innerhalb der Klammern übereinstimmen, um sie im
Ersatzcode zu verwenden. Innerhalb von `$()` befindet sich `$x:expr`, das zu
jedem beliebigen Rust-Ausdruck passt und dem Ausdruck den Namen `$x` gibt.

Das Komma nach `$()` gibt an, dass ein literales Komma-Trennzeichen optional
nach dem Code erscheinen könnte, der dem Code in `$()` entspricht. Der `*` gibt
an, dass das Muster keinmal oder mehrmals zu dem passt, was vor dem `*` steht.

Wenn wir dieses Makro mit `vec![1, 2, 3];` aufrufen, passt das Muster `$x`
dreimal zu den drei Ausdrücken `1`, `2` und `3`.

Betrachten wir nun das Muster im Hauptteil des mit diesem Zweig assoziierten
Codes: `temp_vec.push()` innerhalb von `$()*` wird für jeden Teil erzeugt, der
keinmal oder mehrmals mit `$()` im Muster übereinstimmt, je nachdem, wie oft
das Muster passt. Das `$x` wird durch jeden passenden Ausdruck ersetzt. Wenn
wir dieses Makro mit `vec![1, 2, 3];` aufrufen, wird der generierte Code, der
diesen Makroaufruf ersetzt, wie folgt aussehen:

```rust,ignore
{
    let mut temp_vec = Vec::new();
    temp_vec.push(1);
    temp_vec.push(2);
    temp_vec.push(3);
    temp_vec
}
```

Wir haben ein Makro definiert, das eine beliebige Anzahl von Argumenten
beliebigen Typs aufnehmen und Code erzeugen kann, um einen Vektor zu erstellen,
der die angegebenen Elemente enthält.

Es gibt einige seltsame Randfälle mit `macro_rules!`. In Zukunft wird Rust eine
zweite Art deklarativer Makros haben, die auf ähnliche Weise funktionieren,
aber einige dieser Randfälle beheben. Nach diesem Update wird `macro_rules!`
effektiv veraltet sein. Vor diesem Hintergrund und angesichts der Tatsache,
dass die meisten Rust-Programmierer Makros eher *verwenden* als Makros
*schreiben* werden, werden wir nicht weiter auf `macro_rules!` eingehen. Um
mehr darüber zu erfahren, wie man Makros schreibt, konsultiere die
Online-Dokumentation oder andere Ressourcen, wie zum Beispiel [„The Little Book
of Rust Macros“][tlborm] (engl. „Das kleine Buch der Rust-Makros“).

### Prozedurale Makros zur Code-Generierung aus Attributen

Die zweite Form von Makros sind *prozedurale Makros*, die sich eher wie
Funktionen verhalten (und eine Art Prozedur sind). Prozedurale Makros
akzeptieren etwas Code als Eingabe, operieren mit diesem Code und erzeugen
etwas Code als Ausgabe, anstatt gegen Muster abzugleichen und den Code durch
anderen Code zu ersetzen, wie es deklarative Makros tun.

Die drei Arten von prozeduralen Makros (benutzerdefinierte derive-Makros,
Attribut-ähnliche und Funktions-ähnliche) arbeiten alle auf ähnliche Weise.

Beim Erstellen von prozeduralen Makros müssen sich die Definitionen in einer
eigenen Kiste mit einem speziellen Kistentyp befinden. Dies geschieht aus
komplexen technischen Gründen, die wir hoffentlich in Zukunft eliminieren
werden. Das Verwenden von prozeduralen Makros sieht aus wie der Code in
Codeblock 19-29, wobei `some_attribute` ein Platzhalter für die Verwendung
eines bestimmten Makros ist.

<span class="filename">Dateiname: src/lib.rs</span>

```rust,ignore
use proc_macro;

#[some_attribute]
pub fn some_name(input: TokenStream) -> TokenStream {
}
```

<span class="caption">Codeblock 19-29: Beispiel für die Verwendung eines
prozeduralen Makros</span>

Die Funktion, die ein prozedurales Makro definiert, nimmt einen `TokenStream`
als Eingabe und erzeugt einen `TokenStream` als Ausgabe. Der Typ `TokenStream`
wird durch die Kiste `proc_macro` definiert, die in Rust enthalten ist und eine
Folge von Token darstellt. Dies ist der Kern des Makros: Der Quellcode, mit dem
das Makro arbeitet, bildet die Eingabe `TokenStream`, und der Code, den das
Makro erzeugt, ist die Ausgabe `TokenStream`. Die Funktion hat auch ein
Attribut, das angibt, welche Art prozedurales Makro wir erstellen. Wir können
mehrere Arten prozeduraler Makros in derselben Kiste haben.

Schauen wir uns die verschiedenen Arten prozeduraler Makros an. Wir beginnen
mit einem benutzerdefinierten derive-Makro und erklären dann die kleinen
Unterschiede, in denen sich die anderen Formen unterscheiden.

### Wie man ein benutzerdefiniertes Makro mit `derive` schreibt

Lass uns eine Kiste namens `hello_macro` erstellen, die ein Merkmal namens
`HelloMacro` mit einer assoziierten Funktion namens `hello_macro` definiert.
Anstatt unsere Kisten-Benutzer dazu zu bringen, das Merkmal `HelloMacro` für
jeden ihrer Typen zu implementieren, werden wir ein prozedurales Makro zur
Verfügung stellen, damit die Benutzer ihren Typ mit `#[derive(HelloMacro)]`
annotieren können, um eine Standardimplementierung der Funktion `hello_macro`
zu erhalten. Die Standardimplementierung gibt `Hallo Makro! Mein Name ist
TypeName!` aus, wobei `TypeName` der Name des Typs ist, auf dem dieses Merkmal
definiert wurde. Mit anderen Worten, wir werden eine Kiste schreiben, die es
einem anderen Programmierer ermöglicht, mit unserer Kiste Code wie Codeblock
19-30 zu schreiben.

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore,does_not_compile
use hello_macro::HelloMacro;
use hello_macro_derive::HelloMacro;

#[derive(HelloMacro)]
struct Pancakes;

fn main() {
    Pancakes::hello_macro();
}
```

<span class="caption">Codeblock 19-30: Code, den ein Benutzer unserer Kiste
schreiben kann, wenn er unser prozedurales Makro benutzt</span>

Dieser Code gibt `Hallo Makro! Mein Name ist Pancakes!` aus, wenn wir fertig
sind. Der erste Schritt ist das Erstellen einer neuen Bibliothekskiste (library
crate), etwa so:

```console
$ cargo new hello_macro --lib
```

Als Nächstes definieren wir das Merkmal `HelloMacro` und die damit assoziierte
Funktion:

<span class="filename">Dateiname: src/lib.rs</span>

```rust
pub trait HelloMacro {
    fn hello_macro();
}
```

Wir haben ein Merkmal und seine Funktion. An diesem Punkt könnte unser
Kistenbenutzer das Merkmal so implementieren, dass die gewünschte
Funktionalität erreicht wird:

```rust,ignore
use hello_macro::HelloMacro;

struct Pancakes;

impl HelloMacro for Pancakes {
    fn hello_macro() {
        println!("Hallo Makro! Mein Name ist Pancakes!");
    }
}

fn main() {
    Pancakes::hello_macro();
}
```

Allerdings müssten sie den Implementierungsblock für jeden Typ, den sie mit
`hello_macro` verwenden wollten, schreiben; wir wollen ihnen diese Arbeit
ersparen.

Außerdem können wir die Funktion `hello_macro` noch nicht mit einer
Standardimplementierung versehen, die den Namen des Typs ausgibt, auf dem das
Merkmal implementiert ist: Rust hat keine Reflektionsfähigkeiten, sodass es den
Namen des Typs zur Laufzeit nicht nachschlagen kann. Wir benötigen ein Makro,
um zur Kompilierzeit Code zu generieren.

Der nächste Schritt ist das Definieren des prozeduralen Makros. Zum Zeitpunkt
der Abfassung dieses Dokuments müssen sich die prozeduralen Makros in einer
eigenen Kiste befinden. Irgendwann könnte diese Einschränkung aufgehoben
werden. Die Konvention für die Strukturierung von Kisten und Makrokisten lautet
wie folgt: Für eine Kiste mit dem Namen `foo` wird eine prozedurale Makrokiste
mit einem benutzerdefinierten derive-Makro als `foo_derive` bezeichnet.
Beginnen wir eine neue Kiste mit dem Namen `hello_macro_derive` innerhalb
unseres `hello_macro`-Projekts:

```console
$ cargo new hello_macro_derive --lib
```

Unsere beiden Kisten sind eng miteinander verwandt, daher erstellen wir die
prozedurale Makrokiste innerhalb des Verzeichnisses unserer Kiste
`hello_macro`. Wenn wir die Merkmalsdefinition in `hello_macro` ändern, müssen
wir auch die Implementierung des prozeduralen Makros in `hello_macro_derive`
ändern. Die beiden Kisten müssen getrennt veröffentlicht werden und
Programmierer, die diese Kisten verwenden, müssen beide als Abhängigkeiten
hinzufügen und beide in den Gültigkeitsbereich bringen. Wir könnten stattdessen
die Kiste `hello_macro` als Abhängigkeit `hello_macro_derive` verwenden lassen
und den prozeduralen Makrocode erneut exportieren. Wie auch immer, die Art und
Weise, wie wir das Projekt strukturiert haben, ermöglicht es den
Programmierern, `hello_macro`  zu benutzen, selbst wenn sie die
`derive`-Funktionalität nicht wollen.

Wir müssen die Kiste `hello_macro_derive` als prozedurale Makro-Kiste
deklarieren. Wie du gleich sehen wirst, benötigen wir auch Funktionalität von
den Kisten `syn` und `quote`, also müssen wir sie als Abhängigkeiten angeben.
Füge das Folgende zur Datei *Cargo.toml* für `hello_macro_derive` hinzu:

<span class="filename">Dateiname: hello_macro_derive/Cargo.toml</span>

```toml
[lib]
proc-macro = true

[dependencies]
syn = "1.0"
quote = "1.0"
```

Um mit der Definition des prozeduralen Makros zu beginnen, platziere den Code
in Codeblock 19-31 in deine Datei *src/lib.rs* der Kiste `hello_macro_derive`.
Beachte, dass dieser Code nicht kompiliert werden kann, bis wir eine Definition
für die Funktion `impl_hello_macro` hinzufügen.

<span class="filename">Dateiname: hello_macro_derive/src/lib.rs</span>

```rust,ignore,does_not_compile
extern crate proc_macro;

use proc_macro::TokenStream;
use quote::quote;
use syn;

#[proc_macro_derive(HelloMacro)]
pub fn hello_macro_derive(input: TokenStream) -> TokenStream {
    // Konstruiere eine Repräsentation des Rust-Codes als Syntaxbaum,
    // den wir manipulieren können
    let ast = syn::parse(input).unwrap();

    // Baue die Merkmal-Implementierung
    impl_hello_macro(&ast)
}
```

<span class="caption">Codeblock 19-31: Code, den die meisten prozeduralen
Makrokisten benötigen, um Rust-Code zu verarbeiten</span>

Beachte, dass wir den Code aufgeteilt haben in die Funktion
`hello_macro_derive`, die für das Parsen des `TokenStream` verantwortlich ist,
und die Funktion `impl_hello_macro`, die für die Transformation des Syntaxbaums
verantwortlich ist: Dies macht das Schreiben eines prozeduralen Makros
bequemer. Der Code in der äußeren Funktion (in diesem Fall
`hello_macro_derive`) wird für fast jede prozedurale Makro-Kiste, die du siehst
oder erstellst, derselbe sein. Der Code, den du im Rumpf der inneren Funktion
(in diesem Fall `impl_hello_macro`) angibst, wird je nach Zweck deines
prozeduralen Makros unterschiedlich sein.

Wir haben drei neue Kisten eingeführt: `proc_macro`, [`syn`][syn-crates] und
[`quote`][quote-crates]. Die Kiste `proc_macro` kommt mit Rust, sodass wir das
nicht zu den Abhängigkeiten in *Cargo.toml* hinzufügen mussten. Die Kiste
`proc_macro` ist die API des Compilers, die es uns erlaubt, den Rust-Code aus
unserem Code zu lesen und zu manipulieren.

Die Kiste `syn` parst den Rust-Code von einer Zeichenkette in eine
Datenstruktur, auf der wir Operationen durchführen können. Die Kiste `quote`
wandelt `syn`-Datenstrukturen wieder in Rust-Code um. Diese Kisten machen es
viel einfacher, jede Art von Rust-Code zu parsen, den wir vielleicht
verarbeiten wollen: Einen vollständigen Parser für Rust-Code zu schreiben, ist
keine einfache Aufgabe.

Die Funktion `hello_macro_derive` wird aufgerufen, wenn ein Benutzer unserer
Bibliothek `#[derive(HelloMacro)]` an einen Typ spezifiziert. Dies ist möglich,
weil wir die Funktion `hello_macro_derive` hier mit `proc_macro_derive`
annotiert und den Namen `HelloMacro` angegeben haben, der unserem Merkmalsnamen
entspricht; dies ist die Konvention, der die meisten prozeduralen Makros
folgen.

Die Funktion `hello_macro_derive` wandelt zunächst `input` aus einem
`TokenStream` in eine Datenstruktur um, die wir dann interpretieren und
Operationen darauf ausführen können. Hier kommt `syn` ins Spiel. Die Funktion
`parse` in `syn` nimmt einen `TokenStream` und gibt eine `DeriveInput`-Struktur
zurück, die den geparsten Rust-Code repräsentiert. Codeblock 19-32 zeigt die
relevanten Teile der Struktur `DeriveInput`, die wir vom Parsen der
Zeichenkette `struct Pancakes;` erhalten:

```rust,ignore
DeriveInput {
    // --abschneiden--

    ident: Ident {
        ident: "Pancakes",
        span: #0 bytes(95..103)
    },
    data: Struct(
        DataStruct {
            struct_token: Struct,
            fields: Unit,
            semi_token: Some(
                Semi
            )
        }
    )
}
```

<span class="caption">Codeblock 19-32: Die `DeriveInput`-Instanz erhalten wir
beim Parsen des Codes, den das Attribut des Makros in Codeblock 19-30
hat</span>

Die Felder dieser Struktur zeigen, dass der Rust-Code, den wir geparst haben,
eine Einheitsstruktur (unit struct) mit dem `ident` (identifier, engl.
Bezeichner, d.h. dem Namen) von `Pancakes` ist. Es gibt weitere Felder in
dieser Struktur zur Beschreibung aller Arten von Rust-Code; weitere
Informationen findest du in der [`syn`-Dokumentation für
`DeriveInput`][syn-docs].

Bald werden wir die Funktion `impl_hello_macro` definieren, wo wir den neuen
Rust-Code bauen werden, den wir einbinden wollen. Aber bevor wir das tun,
beachte, dass die Ausgabe für unser derive-Makro ebenfalls ein `TokenStream`
ist. Der zurückgegebene `TokenStream` wird dem Code hinzugefügt, den unsere
Kisten-Benutzer schreiben. Wenn sie also ihre Kiste kompilieren, erhalten sie
die zusätzliche Funktionalität, die wir im modifizierten `TokenStream` zur
Verfügung stellen.

Du hast vielleicht bemerkt, dass wir `unwrap` aufrufen, um die Funktion
`hello_macro_derive` abstürzen zu lassen, wenn der Aufruf der Funktion
`syn::parse` hier fehlschlägt. Es ist notwendig, dass unser prozedurales Makro
bei Fehlern abstürzt, weil `proc_macro_derive`-Funktionen einen `TokenStream`
zurückgeben müssen, kein `Result`, um mit der prozeduralen Makro-API konform zu
sein. Wir haben dieses Beispiel vereinfacht, indem wir `unwrap` verwendet
haben; in Produktionscode solltest du spezifischere Fehlermeldungen darüber
angeben, was schief gelaufen ist, indem du `panic!` oder `expect` verwendest.

Da wir nun den Code haben, um den annotierten Rust-Code aus einem `TokenStream`
in eine `DeriveInput`-Instanz zu verwandeln, lass uns den Code generieren, der
das Merkmal `HelloMacro` auf dem annotierten Typ implementiert, wie in
Codeblock 19-33 gezeigt.

<span class="filename">Dateiname: hello_macro_derive/src/lib.rs</span>

```rust,ignore
# extern crate proc_macro;
#
# use proc_macro::TokenStream;
# use quote::quote;
# use syn;
#
# #[proc_macro_derive(HelloMacro)]
# pub fn hello_macro_derive(input: TokenStream) -> TokenStream {
#     // Konstruiere eine Repräsentation des Rust-Codes als Syntaxbaum,
#     // den wir manipulieren können
#     let ast = syn::parse(input).unwrap();
#
#     // Baue die Merkmal-Implementierung
#     impl_hello_macro(&ast)
# }
#
fn impl_hello_macro(ast: &syn::DeriveInput) -> TokenStream {
    let name = &ast.ident;
    let gen = quote! {
        impl HelloMacro for #name {
            fn hello_macro() {
                println!("Hallo Makro! Mein Name ist {}!", stringify!(#name));
            }
        }
    };
    gen.into()
}
```

<span class="caption">Codeblock 19-33: Implementierung des Merkmals
`HelloMacro` unter Verwendung des geparsten Rust-Codes</span>

Wir erhalten eine `Ident`-Strukturinstanz, die den Namen (Bezeichner) des
annotierten Typs enthält, indem wir `ast.ident` verwenden. Die Struktur in
Codeblock 19-32 zeigt, dass, wenn wir die Funktion `impl_hello_macro` auf den
Code in Codeblock 19-30 anwenden, das erhaltene `ident` ein Feld `ident` mit
dem Wert `"Pancakes"` enthält. So wird die Variable `name` in Codeblock 19-33
eine Instanz der Struktur `Ident` enthalten, die die Zeichenkette `"Pancakes"`
ausgibt, der Name der Struktur in Codeblock 19-30.

Mit dem Makro `quote!` können wir den Rust-Code definieren, den wir zurückgeben
wollen. Der Compiler erwartet etwas anderes als das direkte Ergebnis der
Ausführung des `quote!`-Makros, also müssen wir es in einen `TokenStream`
konvertieren. Wir tun dies, indem wir die `into`-Methode aufrufen, die diese
Zwischendarstellung konsumiert und einen Wert des erforderlichen Typs
`TokenStream` zurückgibt.

Das Makro `quote!` bietet auch einige sehr coole Vorlage-Mechanismen: Wir
können `#name` eingeben und `quote!` wird es durch den Wert in der Variablen
`name` ersetzen. Du kannst sogar einige Wiederholungen machen, ähnlich wie
normale Makros funktionieren. Schaue dir die [Dokumentation der Kiste
`quote!`][quote-docs] für eine gründliche Einführung an.

Wir wollen, dass unser prozedurales Makro eine Implementierung unseres Merkmals
`HelloMacro` für den Typ, den der Benutzer annotiert hat, erzeugt, die wir mit
`#name` erhalten können. Die Merkmalssimplementierung hat eine Funktion
`hello_macro`, deren Rumpf die Funktionalität enthält, die wir zur Verfügung
stellen wollen: Ausgeben von `Hallo Makro! Mein Name ist` und dann der Name des
annotierten Typs.

Das hier verwendete Makro `stringify!` ist in Rust eingebaut. Es nimmt einen
Rust-Ausdruck, z.B. `1 + 2`, und verwandelt diesen zur Kompilierzeit in ein
Zeichenketten-Literal, z.B. `"1 + 2"`. Dies unterscheidet sich von `format!`
oder `println!`; Makros, die den Ausdruck auswerten und dann das Ergebnis in
einen `String` umwandeln. Es besteht die Möglichkeit, dass die Eingabe `#Name`
ein Ausdruck ist, der literal auszugeben ist, also verwenden wir `stringify!`.
Die Verwendung von `stringify!` erspart zudem eine Speicherzuweisung, indem
`#name` zur Kompilierzeit in ein Zeichenketten-Literal umgewandelt wird.

An diesem Punkt sollte `cargo build` sowohl bei `hello_macro` als auch bei
`hello_macro_derive` erfolgreich durchlaufen. Schließen wir diese Kisten an den
Code in Codeblock 19-30 an, um das prozedurale Makro in Aktion zu sehen!
Erstelle ein neues Binärprojekt in deinem *projects*-Verzeichnis durch Aufrufen
von `cargo new pancakes`. 

Wir müssen `hello_macro` und `hello_macro_derive` als Abhängigkeiten in der
Datei *Cargo.toml* der Kiste `pancakes` hinzufügen. Wenn du deine Versionen von
`hello_macro` und `hello_macro_derive` in [crates.io](https://crates.io/)
veröffentlichst, wären das reguläre Abhängigkeiten; wenn nicht, kannst du sie
wie folgt als `path`-Abhängigkeiten angeben:

```toml
[dependencies]
hello_macro = { path = "../hello_macro" }
hello_macro_derive = { path = "../hello_macro/hello_macro_derive" }
```

Gib den Code in Codeblock 19-30 in *src/main.rs* ein und rufe `cargo run` auf:
Es sollte `Hallo Makro! Mein Name ist Pancakes!` ausgeben. Die Implementierung
des Merkmals `HelloMacro` aus dem prozeduralen Makro wurde eingefügt, ohne dass
die Kiste `pancakes` es implementieren musste; `#[derive(HelloMacro)]` fügte
die Merkmalsimplementierung hinzu.

Als Nächstes wollen wir untersuchen, inwiefern sich die anderen Arten
prozeduraler Makros von den benutzerdefinierten derive-Makros unterscheiden.

### Attribut-ähnliche Makros

Attribut-ähnliche Makros ähneln den benutzerdefinierten derive-Makros, aber
anstatt Code für das `derive`-Attribut zu generieren, erlauben sie dir, neue
Attribute zu erstellen. Sie sind auch flexibler: `derive` funktioniert nur bei
Strukturen und Aufzählungen; Attribute können auch auf andere Elemente, z.B.
Funktionen, angewendet werden. Hier ist ein Beispiel für die Verwendung eines
Attribut-ähnlichen Makros: Nehmen wir an, du hast ein Attribut namens `route`,
das Funktionen annotiert, wenn du ein Webapplikations-Framework verwendest:

```rust,ignore
#[route(GET, "/")]
fn index() {
```

Dieses Attribut `#[route]` würde durch das Framework als prozedurales Makro
definiert werden. Die Signatur der Makrodefinitionsfunktion würde wie folgt
aussehen:

```rust,ignore
#[proc_macro_attribute]
pub fn route(attr: TokenStream, item: TokenStream) -> TokenStream {
```

Hier haben wir zwei Parameter vom Typ `TokenStream`. Der erste ist für die
Inhalte `GET, "/"` des Attributs. Der zweite ist für den Rumpf des Elements, an
den das Attribut angehängt ist: In diesem Fall `fn index() {}` und der Rest des
Funktionsrumpfs.

Abgesehen davon funktionieren Attribut-ähnliche Makros auf die gleiche Weise
wie benutzerdefinierte derive-Makros: Sie erstellen eine Kiste mit dem
Kistentyp `proc-macro` und implementieren eine Funktion, die den gewünschten
Code generiert!

### Funktions-ähnliche Makros

Funktions-ähnliche Makros definieren Makros, die wie Funktionsaufrufe aussehen.
Ähnlich wie `macro_rules!`-Makros sind sie flexibler als Funktionen; sie können
zum Beispiel eine unbekannte Anzahl von Argumenten aufnehmen. Makros können
jedoch nur mit der `match`-ähnlichen Syntax definiert werden, die wir im
Abschnitt [„Deklarative Makros mit `macro_rules!` für allgemeine
Metaprogrammierung“][decl] besprochen haben. Funktions-ähnliche Makros nehmen
einen `TokenStream`-Parameter und ihre Definition manipuliert diesen
`TokenStream` unter Verwendung von Rust-Code, wie es die beiden anderen Arten
prozeduraler Makros tun. Ein Beispiel für ein Funktions-ähnliches Makro ist ein
Makro `sql!`, das auf diese Weise aufgerufen werden könnte:

```rust,ignore
let sql = sql!(SELECT * FROM posts WHERE id=1);
```

Dieses Makro würde die darin enthaltene SQL-Anweisung parsen und prüfen, ob sie
syntaktisch korrekt ist, was eine viel komplexere Verarbeitung ist, als es ein
`macro_rules!`-Makro tun kann. Das Makro `sql!` würde wie folgt definiert
werden:

```rust,ignore
#[proc_macro]
pub fn sql(input: TokenStream) -> TokenStream {
```

Diese Definition ähnelt der Signatur des benutzerdefinierten derive-Makros: Wir
erhalten die Token, die sich innerhalb der Klammern befinden, und geben den
Code zurück, den wir generieren wollen.

## Zusammenfassung

Puh! Jetzt hast du einige Rust-Funktionalitäten in deinem Werkzeugkasten, die
du nicht oft verwenden wirst, aber du wirst wissen, dass sie unter ganz
bestimmten Umständen verfügbar sind. Wir haben mehrere komplexe Themen
eingeführt, sodass du diese Konzepte und Syntax erkennen kannst, wenn du ihnen
in Vorschlägen für Fehlermeldungen oder im Code anderer Leute begegnest.
Verwende dieses Kapitel als Referenz, um Lösungen zu finden.

Als Nächstes werden wir alles, was wir im Laufe des Buches besprochen haben, in
die Praxis umsetzen und ein weiteres Projekt durchführen!

[decl]: #deklarative-makros-mit-macro_rules-für-allgemeine-metaprogrammierung
[macro-reference]: https://doc.rust-lang.org/reference/macros-by-example.html
[quote-crates]: https://crates.io/crates/quote
[quote-docs]: https://docs.rs/quote
[syn-crates]: https://crates.io/crates/syn
[syn-docs]: https://docs.rs/syn/1.0/syn/struct.DeriveInput.html
[tlborm]: https://danielkeep.github.io/tlborm/book/index.html
