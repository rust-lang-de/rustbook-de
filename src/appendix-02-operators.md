## Anhang B: Operatoren und Symbole

Dieser Anhang enthält ein Glossar der Rust-Syntax, einschließlich Operatoren
und anderer Symbole, die allein oder im Zusammenhang mit Pfaden, generischen
Datentypen (generics), Merkmalsabgrenzungen (trait bounds), Makros, Attributen,
Kommentaren, Tupeln und Klammern auftreten.

### Operatoren

Tabelle B-1 enthält die Operatoren in Rust, ein Beispiel, wie der Operator im
Kontext erscheinen würde, eine kurze Erklärung und ob dieser Operator überladen
werden kann. Wenn ein Operator überladen werden kann, wird das relevante
Merkmal (trait) aufgeführt, mit dem dieser Operator überladen werden kann.

<span class="caption">Tabelle B-1: Operatoren</span>

| Operator | Beispiel | Erklärung | Überladbar? |
|:---------|:---------|:----------|:------------|
| `!` | `ident!(...)`,<br> `ident!{...}`,<br> `ident![...]` | Makro-Expansion | |
| `!` | `!expr` | Bitweises oder logisches Komplement | `Not` |
| `!=` | `var != expr` | Vergleich auf Ungleichheit | `PartialEq` |
| `%` | `expr % expr` | Arithmetischer Restbetrag | `Rem` |
| `%=` | `var %= expr` | Arithmetischer Restbetrag und Zuweisung | `RemAssign` |
| `&` | `&expr`,<br> `&mut expr` | Ausleihe | |
| `&` | `&type`,<br> `&mut type`,<br> `&'a type`,<br> `&'a mut type` | Ausleih-Referenz-Typ | |
| `&` | `expr & expr` | Bitweises UND | `BitAnd` |
| `&=` | `var &= expr` | Bitweises UND und Zuweisung | `BitAndAssign` |
| `&&` | `expr && expr` | Logisches UND mit Kurzschlussauswertung | |
| `*` | `expr * expr` | Arithmetische Multiplikation | `Mul` |
| `*=` | `var *= expr` | Arithmetische Multiplikation und Zuweisung | `MulAssign` |
| `*` | `*expr` | Dereferenzierung | `Deref` |
| `*` | `*const type`,<br> `*mut type` | Roh-Referenz | |
| `+` | `trait + trait`,<br> `'a + trait` | Verbundtypabgrenzung | |
| `+` | `expr + expr` | Arithmetische Addition | `Add` |
| `+=` | `var += expr` | Arithmetische Addition und Zuweisung | `AddAssign` |
| `,` | `expr, expr` | Argument- und Elementseparator | |
| `-` | `- expr` | Arithmetische Negation | `Neg` |
| `-` | `expr - expr` | Arithmetische Subtraktion | `Sub` |
| `-=` | `var -= expr` | Arithmetische Subtraktion und Zuweisung | `SubAssign` |
| `->` | `fn(...) -> type`,<br> <code>&vert;...&vert; -> type</code> | Funktion und Funktionsabschlussrückgabetyp | |
| `.` | `expr.ident` | Elementzugriff | |
| `..` | `..`,<br> `expr..`,<br> `..expr`,<br> `expr..expr` | Rechts-ausschließendes Bereichsliteral | `PartialOrd` |
| `..=` | `..=expr`,<br> `expr..=expr` | Rechts-einschließendes Bereichsliteral | `PartialOrd` |
| `..` | `..expr` | Aktualisierungssyntax für Strukturliterale | |
| `..` | `variant(x, ..)`,<br> `struct_type { x, .. }` | „Und der Rest“-Musterbindung | |
| `...` | `expr...expr` | (Veraltet, verwende stattdessen `..=`) In einem Muster: inklusives Bereichsmuster | |
| `/` | `expr / expr` | Arithmetische Division | `Div` |
| `/=` | `var /= expr` | Arithmetische Division und Zuweisung | `DivAssign` |
| `:` | `pat: type`,<br> `ident: type` | Typabgrenzung | |
| `:` | `ident: expr` | Struktur-Feld-Initialisierer | |
| `:` | `'a: loop {...}` | Schleifen-Label | |
| `;` | `expr;` | Anweisungs- und Element-Endezeichen | |
| `;` | `[...; len]` | Syntaxteil für Array fester Größe | |
| `<<` | `expr << expr` | Bitweise Links-Schiebung | `Shl` |
| `<<=` | `var <<= expr` | Bitweise Links-Schiebung und Zuweisung | `ShlAssign` |
| `<` | `expr < expr` | Kleiner-als-Vergleich | `PartialOrd` |
| `<=` | `expr <= expr` | Kleiner-gleich-Vergleich | `PartialOrd` |
| `=` | `var = expr`,<br> `ident = type` | Zuweisung/Äquivalenz | |
| `==` | `expr == expr` | Gleichheitsvergleich | `PartialEq` |
| `=>` | `pat => expr` | Teilsyntax im Abgleichs-Zweig (match arm) | |
| `>` | `expr > expr` | Größer-als-Vergleich | `PartialOrd` |
| `>=` | `expr >= expr` | Größer-gleich-Vergleich | `PartialOrd` |
| `>>` | `expr >> expr` | Bitweise Rechts-Schiebung | `Shr` |
| `>>=` | `var >>= expr` | Bitweise Rechts-Schiebung und Zuweisung | `ShrAssign` |
| `@` | `ident @ pat` | Muster-Bindung | |
| `^` | `expr ^ expr` | Bitweises exklusives ODER | `BitXor` |
| `^=` | `var ^= expr` | Bitweises exklusives ODER und Zuweisung | `BitXorAssign` |
| <code>&vert;</code> | <code>pat &vert; pat</code> | Muster-Alternativen | |
| <code>&vert;</code> | <code>expr &vert; expr</code> | Bitweises ODER | `BitOr` |
| <code>&vert;=</code> | <code>var &vert;= expr</code> | Bitweises ODER und Zuweisung | `BitOrAssign` |
| <code>&vert;&vert;</code> | <code>expr &vert;&vert; expr</code> | Logisches ODER mit Kurzschlussauswertung | |
| `?` | `expr?` | Fehler-Weitergabe | |

### Nicht-Operator-Symbole

Die folgende Liste enthält alle nicht-Buchstaben, die nicht als Operatoren
fungieren, d.h. sich nicht wie ein Funktions- oder Methodenaufruf verhalten.

Tabelle B-2 zeigt Symbole, die für sich allein stehen und an verschiedenen
Stellen gültig sind.

<span class="caption">Tabelle B-2: Eigenständige Syntax</span>

| Symbol | Erklärung |
|:-------|:----------|
| `'ident` | Benannte Lebensdauer oder Schleifenbeschriftung |
| `...u8`,<br> `...i32`,<br> `...f64`,<br> `...usize`<br> usw. | Numerisches Literal eines bestimmten Typs |
| `"..."` | Zeichenketten-Literal |
| `r"..."`,<br> `r#"..."#`,<br> `r##"..."##`<br> usw. | Roh-Zeichenketten-Literal, Escape-Zeichen werden nicht verarbeitet |
| `b"..."` | Byte-Zeichenkettenliteral, konstruiert ein `[u8]` anstelle einer Zeichenkette |
| `br"..."`,<br> `br#"..."#`,<br> `br##"..."##`<br> usw. | Roh-Byte-Zeichenkettenliteral, Kombination aus Roh- und Byte-Zeichenkettenliteral |
| `'...'` | Zeichen-Literal |
| `b'...'` | ASCII-Byte-Literal |
| <code>&vert;...&vert; expr</code> | Funktionsabschluss (closure) |
| `!` | Leerer Typ (bottom type) für nicht-endende Funktionen |
| `_` | Musterbindung für „sonstige“; wird auch verwendet, um Ganzzahl-Literale lesbar zu machen |

Tabelle B-3 zeigt Symbole, die im Zusammenhang mit Pfaden für die
Modulhierarchie eines Elements vorkommen.

<span class="caption">Tabelle B-3: Pfad-bezogene Syntax</span>

| Symbol | Erklärung |
|:-------|:----------|
| `ident::ident` | Namensraum-Pfad |
| `::path` | Pfad relativ zur Kistenwurzel<br> (d.h. ein explizit absoluter Pfad) |
| `self::path` | Pfad relativ zum aktuellen Modul<br> (d.h. ein explizit relativer Pfad) |
| `super::path` | Pfad relativ zum Elternmodul |
| `type::ident`,<br> `<type as trait>::ident` | Zugehörige Konstanten, Funktionen<br> und Typen |
| `<type>::...` | Zugehöriges Element für einen Typ,<br> der nicht direkt benannt werden kann<br> (z.B. `<&T>::...`, `<[T]>:::...` usw.) |
| `trait::method(...)` | Methodenaufruf durch Angeben des<br> Merkmals eindeutig machen |
| `type::method(...)` | Methodenaufruf durch Angeben des<br> Typs eindeutig machen |
| `<type as trait>::method(...)` | Methodenaufruf durch Angeben des<br> Merkmals und Typs eindeutig machen |

Tabelle B-4 zeigt Symbole, die im Zusammenhang mit generischen Typparametern
auftreten.

<span class="caption">Tabelle B-4: Generische Datentypen</span>

| Symbol | Erklärung |
|:-------|:----------|
| `path<...>` | Spezifiziert Parameter zum generischen Typ in einem Typ<br> (z.B. `Vec<u8>`) |
| `path::<...>`,<br> `method::<...>` | Spezifiziert Parameter zu einem generischen Typ,<br> einer Funktion oder Methode in einem Ausdruck;<br> oft als „turbofish“ bezeichnet (z.B. `"42".parse::<i32>()`) |
| `fn ident<...> ...` | Generische Funktion definieren |
| `struct ident<...> ...` | Generische Struktur definieren |
| `enum ident<...> ...` | Generische Aufzählung definieren |
| `impl<...> ...` | Generische Implementierung definieren |
| `for<...> type` | Höherstufige Lebensdauerbegrenzungen |
| `type<ident=type>` | Generischer Typ, bei dem ein oder mehrere assoziierte<br> Typen bestimmte Zuordnungen haben<br> (z.B. `Iterator<Item=T>`) |

Tabelle B-5 zeigt Symbole, die im Zusammenhang mit generischen Typparametern
mit Merkmalsabgrenzung (trait bounds) auftreten.

<span class="caption">Tabelle B-5: Merkmalsabgrenzungen</span>

| Symbol | Erklärung |
|:-------|:----------|
| `T: U` | Generischer Parameter `T`, beschränkt auf Typen,<br> die `U` implementieren |
| `T: 'a` | Generischer Typ `T`, der die Lebensdauer `'a` überdauert<br> (d.h. der Typ darf transitiv keine Referenzen mit einer<br> kürzeren Lebensdauer als `'a` enthalten) |
| `T : 'static` | Generischer Typ `T` mit Lebensdauer `'static` |
| `'b: 'a` | Generische Lebensdauer `'b`, muss Lebensdauer `'a` überdauern |
| `T: ?Sized` | Erlaube einen generischen Typparameter, der ein<br> dynamisch dimensionierter Typ ist |
| `'a + trait`,<br> `trait + trait` | Zusammengesetzte Typabgrenzung |

Tabelle B-6 zeigt Symbole, die im Zusammenhang mit dem Aufruf oder der
Definition von Makros und der Angabe von Attributen an einem Element
vorkommen.

<span class="caption">Tabelle B-6: Makros und Attribute</span>

| Symbol | Erklärung |
|:-------|:----------|
| `#[meta]` | Äußeres Attribut |
| `#![meta]` | Inneres Attribut |
| `$ident` | Makro-Ersetzung |
| `$ident:kind` | Makro-Erfassung |
| `$(…)…` | Makro-Wiederholung |
| `ident!(...)`,<br> `ident!{...}`,<br> `ident![...]` | Makro-Aufruf |

Tabelle B-7 zeigt Symbole, die Kommentare erzeugen.

<span class="caption">Tabelle B-7: Kommentare</span>

| Symbol | Erklärung |
|:-------|:----------|
| `//` | Einzeiliger Kommentar |
| `//!` | Einzeiliger Dokumentationskommentar innen |
| `///` | Einzeiliger Dokumentationskommentar außen |
| `/*...*/` | Block-Kommentar |
| `/*!...*/` | Mehrzeiliger Dokumentationskommentar innen |
| `/**...*/` | Mehrzeiliger Dokumentationskommentar außen |

Tabelle B-8 zeigt Symbole, die im Zusammenhang mit der Verwendung von Tupeln
auftreten.

<span class="caption">Tabelle B-8: Tupel</span>

| Symbol | Erklärung |
|:-------|:----------|
| `()` | Leeres Tupel (auch Einheit (unit) genannt), Literal und Typ |
| `(expr)` | Eingeklammerter Ausdruck |
| `(expr,)` | Ein-Element-Tupel-Ausdruck |
| `(type,)` | Ein-Element-Tupel-Typ |
| `(expr, ...)` | Tupel-Ausdruck |
| `(type, ...)` | Tupel-Typ |
| `expr(expr, ...)` | Funktionsaufruf-Ausdruck; wird auch zur Initialisierung von<br> Tupel-Strukturen und Tupel-Aufzählungs-Varianten verwendet |
| `expr.0`,<br> `expr.1` usw. | Tupel-Indexierung |

Tabelle B-9 zeigt die Kontexte, in denen geschweifte Klammern verwendet werden.

<span class="caption">Tabelle B-9: Geschweifte Klammern</span>

| Context | Erklärung |
|:--------|:----------|
| `{...}` | Block-Ausdruck |
| `Type {...}` | `struct`-Literal |

Tabelle B-10 zeigt die Kontexte, in denen eckige Klammern verwendet werden.

<span class="caption">Tabelle B-10: Eckige Klammern</span>

| Context | Erklärung |
|:--------|:----------|
| `[...]` | Array-Literal |
| `[expr; len]` | Array-Literal mit `len` Kopien von `expr` |
| `[type; len]` | Array-Typ mit `len` Instanzen von `type` |
| `expr[expr]` | Sammlungs-Indexierung, ist überladbar (`Index`, `IndexMut`) |
| `expr[..]`,<br> `expr[a..]`,<br> `expr[..b]`,<br> `expr[a..b]` | Sammlungs-Indexierung, die wie ein Sammlungsanteil aussieht,<br> unter Verwendung von `Range`, `RangeFrom`, `RangeTo` oder<br> `RangeFull` als „Index“ |
