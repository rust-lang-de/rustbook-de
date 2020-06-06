## Anhang A: Schlüsselwörter

Die folgende Liste enthält Schlüsselwörter, die für die gegenwärtige oder
zukünftige Verwendung durch die Sprache Rust reserviert sind. Als solche können
sie nicht als Bezeichner verwendet werden (außer als Roh-Bezeichner, die wir im
Abschnitt [„Roh-Bezeichner“][raw-identifiers] besprechen werden),
einschließlich Namen von Funktionen, Variablen, Parametern, Strukturfeldern
(struct fields), Modulen, Kisten (crates), Konstanten, Makros, statischen
Werten, Attributen, Typen, Merkmalen (traits) und Lebensdauern (lifetimes).

[raw-identifiers]: #roh-bezeichner

### Derzeit verwendete Schlüsselwörter

Die folgenden Schlüsselwörter haben derzeit die beschriebene Funktionalität.

* `as` &ndash; primitive Typen umwandeln; ein spezifisches Merkmal mit einem
  Element eindeutig machen; Elemente in `use`- und `extern crate`-Anweisungen
  umbenennen 
* `async` &ndash; ein `Future` zurückgeben, anstatt den aktuellen Strang
  (thread) zu blockieren
* `await` &ndash; Ausführung anhalten, bis das Ergebnis eines `Future` vorliegt
* `break` &ndash; Schleife sofort verlassen
* `const` &ndash; konstante Elemente oder konstante Roh-Referenzen definieren
* `continue` &ndash; weiter zur nächsten Schleifeniteration
* `crate` &ndash; externe Kiste (crate) oder Makrovariable, die die Kiste
  repräsentiert, in der das Makro definiert ist, verlinken
* `dyn` &ndash; dynamischer Aufruf (dispatch) eines Merkmalsobjekts (trait
  object)
* `else` &ndash; Ersatzkontrollflusszweig bei `if` und `if let`
* `enum` &ndash; eine Aufzählung (enumeration) definieren
* `extern` &ndash; externe Kiste (crate), Funktion oder Variable verlinken
* `false` &ndash; Boolesches Literal für „falsch“
* `fn` &ndash; Funktion oder Funktionsreferenztyp definieren
* `for` &ndash; wiederhole über Elemente einer Iteration; ein Merkmal (trait)
  implementieren; eine höherrangige Lebensdauer angeben
* `if` &ndash; Verzweigen abhängig vom Ergebnis eines Bedingungsausdrucks
* `impl` &ndash; Implementieren einer inhärenten oder Merkmalsfunktionalität
  (trait functionality)
* `in` &ndash; Teil der `for`-Schleifensyntax
* `let` &ndash; eine Variable binden
* `loop` &ndash; wiederhole bedingungslos
* `match` &ndash; einen Wert mit Muster abgleichen
* `mod` &ndash; ein Modul definieren
* `move` &ndash; Funktionsabschluss (closure) übernimmt Eigentümerschaft
  (ownership) all seiner Parameter
* `mut` &ndash; Referenzen, Roh-Referenzen und Variablenbindungen als
  veränderlich kennzeichnen
* `pub` &ndash; Strukturfelder (struct fields), `impl`-Blöcke und Module als
  öffentlich sichtbar kennzeichnen 
* `ref` &ndash; als Referenz binden
* `return` &ndash; aus Funktion zurückkehren
* `Self` &ndash; Typ-Alias für den zu definierenden oder implementierenden Typ
* `self` &ndash; Methoden-Instanzobjekt; aktuelles Modul
* `static` &ndash; globale Variable oder Lebensdauer während der gesamten
  Programmausführung
* `struct` &ndash; eine Struktur definieren
* `super` &ndash; Elternmodul des aktuellen Moduls
* `trait` &ndash; ein Merkmal (trait) definieren
* `true` &ndash; Boolesches Literal für „wahr“
* `type` &ndash; einen Typ-Alias oder assoziierten Typ definieren
* `union` &ndash; eine [Vereinigung (union)][union] definieren; ist nur ein
  Schlüsselwort innerhalb einer Vereinigungdeklaration
* `unsafe` &ndash; Code, Funktionen, Merkmale (traits) und Implementierungen
  als unsicher kennzeichnen
* `use` &ndash; Symbole in den Gültigkeitsbereich bringen
* `where` &ndash; Klauseln zur Typabgrenzung angeben
* `while` &ndash; wiederhole abhängig vom Ergebnis eines Bedingungsausdrucks

[union]: https://doc.rust-lang.org/reference/items/unions.html

### Schlüsselwörter reserviert für zukünftige Verwendung

Die folgenden Schlüsselwörter haben keine Funktionalität, sondern sind von Rust
für eine mögliche zukünftige Verwendung reserviert.

* `abstract`
* `become`
* `box`
* `do`
* `final`
* `macro`
* `override`
* `priv`
* `try`
* `typeof`
* `unsized`
* `virtual`
* `yield`

### Roh-Bezeichner

*Roh-Bezeichner* (raw identifiers) sind eine Syntax, die es dir ermöglicht,
Schlüsselwörter dort zu verwenden, wo sie normalerweise nicht erlaubt wären. Du
verwendest einen Roh-Bezeichner, indem du einem Schlüsselwort das Präfix `r#`
voranstellst.

Zum Beispiel ist `match` ein Schlüsselwort. Versuche, folgende Funktion zu
kompilieren, die `match` als Namen benutzt:

<span class="filename">Dateiname: src/main.rs</span>

```rust,does_not_compile
fn match(needle: &str, haystack: &str) -> bool {
    haystack.contains(needle)
}
```

Dann erhältst du diesen Fehler:

```text
error: expected identifier, found keyword `match`
 --> src/main.rs:4:4
  |
4 | fn match(needle: &str, haystack: &str) -> bool {
  |    ^^^^^ expected identifier, found keyword
```

Der Fehler zeigt, dass du das Schlüsselwort `match` nicht als
Funktionsbezeichner verwenden kannst. Um `match` als Funktionsnamen zu
verwenden, musst du die Syntax für Roh-Bezeichner wie folgt verwenden:

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn r#match(needle: &str, haystack: &str) -> bool {
    haystack.contains(needle)
}

fn main() {
    assert!(r#match("foo", "foobar"));
}
```

Dieser Code lässt sich fehlerfrei kompilieren. Beachte das `r#`-Präfix im
Funktionsnamen in seiner Definition sowie an der Stelle, an der die Funktion in
`main` aufgerufen wird.

Roh-Bezeichner erlauben es dir, jedes beliebige Wort als Bezeichner zu
verwenden, auch wenn dieses Wort ein reserviertes Schlüsselwort ist. Darüber
hinaus ermöglicht dir der Roh-Bezeichner das Verwenden von Bibliotheken, die in
einer anderen Rust-Ausgabe, als deine Kiste verwendet, geschrieben wurden. Zum
Beispiel ist `try` in Ausgabe 2015 kein Schlüsselwort, aber in Ausgabe 2018
schon. Wenn du auf eine Bibliothek angewiesen bist, die mit Ausgabe 2015
geschrieben wurde und eine Funktion `try` hat, musst du die
Roh-Bezeichner-Syntax verwenden, in diesem Fall `r#try`, um diese Funktion von
deinem Code der Ausgabe 2018 aus aufzurufen. Siehe [Anhang E][appendix-e] für
weitere Informationen zu Ausgaben.

[appendix-e]: appendix-05-editions.html
