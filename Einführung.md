# Die Programmiersprache Rust

Willkommen! Dieses Buch wird dir die [Programmiersprache Rust][rust] beibrigen.
Rust ist eine Systemprogrammiersprache mit dem Fokus auf drei Ziele:
Sicherheit, Geschwindigkeit und Nebenläufigkeit (Safety, Speed, Concurrency).
Sie hält diese Ziele ohne Garbage Collector aufrecht,
was sie zu einer nützlichen Sprache für eine Reihe von Anwendungsfällen macht
in denen andere Sprachen nicht so gut sind: Einbettung in anderen Sprachen,
Programme mit besonderen Anforderungen an Platz oder Zeit und low-level code schreiben,
wie zum Beispiel Gerätetreiber und Betriebssysteme.
Sie übertrifft derzeitige Sprachen, die auf diesen Bereich abzielen, indem sie
eine Reihe von Checks zur Kompilierzeit durchführt – ohne Kosten zur Laufzeit –,
währenddessen sie alle *data races* vermeidet.
Rust zielt auch darauf ab "kostenfreihe Abstraktionen" zu realisieren obwohl
einige dieser Abstraktionen sich anfühlen wie die einer Hochsprache.
Selbst dann erlaubt Rust eine genaue Kontrolle wie es eine low-level
Sprache würde.

[rust]: https://www.rust-lang.org

“Die Programmiersprache Rust” ist in acht Abschnitte unterteilt.
Diese Einführung ist der Erste. Danach folgen:

* [Erste Schritte][es] - Richte deinen Computer für die Entwicklung mit Rust ein.
* [Lerne Rust][lr] - Lerne Rust Programmierung durch kleine Projekte.
* [Effektives Rust][er] - Fortgeschrittene Konzepte um ausgezeichneten Rust Code zu schreiben.
* [Syntax und Semantik][ss] - Jedes Stück Rust auf kleine Stücke heruntergebrochen.
* [Nightly Rust][nr] - *Cutting-edge features* die noch nicht im stabilen Compiler verfügbar sind.
* [Glossar][gl] - Erklärungen von Begriffen die in diesem Buch verwendet werden.
* [Akademische Forschung][bi] - Literatur die Rust beeinflusst hat.

[es]: book/Erste_Schritte.md
[lr]: book/Lerne_Rust.md
[er]: book/Effektives_Rust.md
[ss]: book/Syntax_und_Semantik.md
[nr]: book/Nightly_Rust.md
[gl]: book/Glossar.md
[bi]: book/Bibliografie.md

Nach dem Lesen dieser Einführung möchtest du wahrscheinlich, je nach Vorliebe,
entweder ‘[Lerne Rust][lr]’ oder ‘[Syntax and Semantics][ss]’ lesen:
‘[Lerne Rust][lr]’ wenn du mit einem Projekt anfangen möchtest,
oder ‘[Syntax and Semantics][ss]’ wenn du lieber klein anfangen und jeweils ein
einziges Konzept ausführlich lernen möchtest bevor du mit dem Nächsten weiter machst.
Reichliche Querverweise verbinden diese beiden Teile miteinander.

### Mithelfen
Dieses Buch ist eine Community-Übersetzung von dem offiziellen Buch “The Rust Programming Language”.

Die Quelldateien dieser Übersetzung befinden sich auf Github:
[github.com/panicbit/rustbook-de](https://github.com/panicbit/rustbook-de)

Die Quelldateien des englischen Originals befinden sich ebenfalls auf Github:
[github.com/rust-lang/rust/tree/master/src/doc/trpl](https://github.com/rust-lang/rust/tree/master/src/doc/trpl)

## Eine kurze Einführung in Rust

Ist Rust eine Sprache in der du interessiert sein könntest? Lass uns ein paar 
Code Beispiele anschauen um ein Paar ihrer Stärken zu demonstrieren.

Das Hauptkonzept, welches Rust einmalig macht, wird
‘*ownership*’ [engl.: Eigentum] genannt. Betrachte dieses kleine Beispiel:

```rust
fn main() {
    let mut x = vec!["Hallo", "Welt"];
}
```

Dieses Programm macht eine [Variablenbindung][var] namens `x`. Der Wert dieser 
Bindung ist ein `Vec<T>`, ein ‘Vektor’, den wir durch ein [Makro][macro] 
aus der Standardbibliothek erzeugt haben. Dieses Makro heißt `vec` und wir rufen 
Makros mit einem `!` auf. Dies folgt einem allgemeinem Prinzip von Rust:
Mache Dinge klar. Makros können bedeutend mehr komplizierte Dinge tun als 
Funktionsaufrufe und damit sind sie optisch eindeutig. Das `!` hilft auch beim 
Parsen, was es erleichtert Werkzeuge zu schreiben und ebenfalls wichtig ist.

Wir haben `mut` benutzt um `x` *mutable* [engl.: veränderbar] zu machen:
Bindungen sind standardmäßig *immutable* [engl.: unveränderbar].
Wir werden den Vektor noch später in diesem Beispiel verändern.

Es ist ebenfalls beachtenswert, dass hier keine Typangaben notwendig waren: 
Obwohl Rust statisch typisiert ist mussten wir den Typ nicht ausdrücklich 
angeben. Rust hat *type inference* [engl.: Typinferenz, Typableitung] um 
die Stärke statischer Typen und der Ausführlichkeit des Angeben von Typen 
auszubalancieren.

Rust allokiert Daten bevorzugt auf dem Stack als auf dem Heap: `x` wird direkt
auf dem Stack platziert. Der `Vec<T>` Typ jedoch reserviert Speicher für die
Elemente des Vektors auf dem Heap. Falls du nicht mit dieser Unterscheidung
vertraut bist, dann kannst du sie fürs erste ignorieren oder einen Blick in
[‘Der Stack und der Heap’][heap] werfen. Als eine Systemprogrammiersprache
gibt Rust dir die Möglichkeit zu bestimmen wie dein Speicher alloziert wird,
aber wenn du gerade erst beginnst ist das keine so große Sache.

[var]: book/Variablenbindung.md
[macro]: book/Makros.md
[heap]: book/Der_Stack_Und_Der_Heap.md

Zuvor haben wir erwähnt, dass ‘ownership’ das entscheidende neue Konzept in Rust ist.
Im Rust Jargon sagen wir, dass `x` den Vektor ‘besitzt’. Dies bedeutet, dass,
wenn `x` den Scope [engl.: Geltungsbereich] verlässt, der Speicher des Vektors
freigegeben wird. Dieser Vorgang wird deterministisch vom Rust Compiler
vorgenommen, anstatt durch einen Mechanismus wie einen Garbage Collector.
Das bedeutet, dass man in Rust selber keine Funktionen wie `malloc` und
`free` aufruft: Der Compiler bestimmt statisch wann du Speicher allozieren oder
freigeben musst und fügt diese Aufrufe selber ein. Irren ist Menschlich, aber
Compiler vergessen nie.

Lass uns eine weitere Zeile unserem Beispiel hinzufügen:

```rust
fn main() {
    let mut x = vec!["Hallo", "Welt"];

    let y = &x[0];
}
```

Wir haben eine weitere Variablenbindung `y` hinzugefügt. In diesem Fall ist
`y` eine ‘Referenz’ auf das erste Element des Vektors. Rusts Referenzen sind
ähnlich wie Zeiger in anderen Sprachen, aber mit zusätzlichen Überprüfungen zur
Kompilierzeit. Referenzen interagieren mit dem *ownership* System durch das
[‘Ausleihen’][borrowing] (borrowing) dessen worauf sie zeigen.
Der Unterschied ist, dass, wenn die Referenz den Scope verlässt,
sie nicht den zugrunde liegenden Speicher freigibt. Falls sie das täte,
dann würden wir zweimal freigeben, was schlecht ist!

[borrowing]: book/Referenzen_Und_Ausleihen.md

Lass uns eine dritte Zeile hinzufügen. Sie schaut harmlos aus, erzeugt aber
einen Kompilierfehler.

```rust
fn main() {
    let mut x = vec!["Hallo", "Welt"];

    let y = &x[0];

    x.push("foo");
}
```

`push` ist eine Methode auf Vektoren, welche ein weiteres Element an das Ende
des Vektors anhängt. Wenn wir versuchen dieses Programm zu kompilieren, erhalten
wir einen Fehler:

```text
error: cannot borrow `x` as mutable because it is also borrowed as immutable
    x.push("foo");
    ^
note: previous borrow of `x` occurs here; the immutable borrow prevents
subsequent moves or mutable borrows of `x` until the borrow ends
    let y = &x[0];
             ^
note: previous borrow ends here
fn main() {

}
^
```
Uff! Der Rust compiler erzeugt manchmal recht detailierte Fehler und dies ist
ein solches mal. Wie der Fehler erklärt ist zwar unsere Variablenbindung veränderbar,
aber wir können immernoch nicht `push` aufrufen. Das ist so, weil wir bereits
eine Referenz auf ein Element des Vektors, nämlich `y`, haben. Etwas zu verändern
wärend eine weitere Referenz darauf existiert ist gefährlich, weil wir die
Referenz ungültig machen könnten. In diesem konkreten Fall könnte es sein, dass
wir beim erstellen des Vektors nur Platz für zwei Elemente reserviert haben.
Ein drittes hinzuzufügen würde dazu führen einen neuen Speicherbereich für all
diese Elemente zu allozieren, hinüber zu kopieren und den internen Zeiger auf
diesen Speicher zu setzen. Das alles funktioniert problemlos. Das Problem ist,
das `y` nicht aktualisiert werden würde und wir somit einen ‘baumelnden Zeiger’
(dangling pointer) hätten. Das ist schlecht. Jegliche Benutzung von `y` wäre ein
Fehler in diesem Fall und somit hat der Compiler diesen für uns abgefangen.

Wie lösen wir also dieses Problem? Es gibt zwei mögliche Lösungsansätze.
Der Erste ist eine Kopie zu machen anstatt eine Referenz zu benutzen:

```rust
fn main() {
    let mut x = vec!["Hallo", "Welt"];

    let y = x[0].clone();

    x.push("foo");
}
```

Rust hat standardmäßig [Move Semantics][move], daher rufen wir die `clone()`
Methode auf, wenn wir eine Kopie von irgendwelchen Daten machen wollen.
In diesem Beispiel ist `y` nicht länger eine Referenz auf den Vektor, der in `x`
gespeichert ist, sondern eine Kopie des ersten Elements, `"Hallo"`. Nun, da wir
keine Referenz haben, funktioniert unser `push()` einwandfrei.

[move]: Besitz#move-semantics

Wenn wir wirklich eine Referenz haben wollen, dann brauchen wir die andere
Option: Sicherstellen, dass unsere Referenzen den Scope verlassen bevor wir die
Veränderung am Vektor vornehmen. Das sieht so aus:

```rust
fn main() {
    let mut x = vec!["Hallo", "Welt"];

    {
        let y = &x[0];
    }

    x.push("foo");
}
```

Wir haben einen inneren Scope mittels einem weiteren Paar geschweifter Klammern
erzeugt. `y` wird den Scope verlassen bevor wir `push()` aufrufen, und damit
ist alles in Ordnung.

Dieses Konzept des Besitzes ist nicht nur dazu gut hängende Zeiger zu verhindern,
sondern auch eine ganze Reihe verwandter Probleme zu lösen, wie zum Beispiel
*iterator invalidation*, Nebenläufigkeit und mehr.
