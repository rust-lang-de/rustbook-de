## Unsicheres (unsafe) Rust

Bei allem Code, den wir bisher besprochen haben, wurden Rusts
Speichersicherheitsgarantien zur Kompilierzeit erzwungen. Allerdings ist in
Rust eine zweite Sprache versteckt, die diese Speichersicherheitsgarantien
nicht erzwingt: Sie heißt _unsicheres Rust_ (unsafe Rust) und funktioniert
genau wie das normale Rust, gibt uns aber zusätzliche Superkräfte.

Unsicheres Rust existiert, weil die statische Analyse von Natur aus konservativ
ist. Wenn der Compiler versucht festzustellen, ob der Code die Garantien
einhält oder nicht, ist es besser für ihn, einige gültige Programme
zurückzuweisen, als einige ungültige Programme zu akzeptieren. Obwohl der Code
_möglicherweise_ in Ordnung ist, wird der Rust-Compiler den Code ablehnen, wenn
er nicht genügend Informationen hat, um sicher zu sein. In diesen Fällen kannst
du unsicheren Code verwenden, um dem Compiler zu sagen: „Vertraue mir, ich
weiß, was ich tue.“ Sei jedoch gewarnt, dass du unsicheres Rust auf eigenes
Risiko verwendest: Wenn du unsicheren Code falsch verwendest, können Probleme
aufgrund von Speicherunsicherheiten auftreten, z.B. Dereferenzierung von
Null-Zeigern.

Ein weiterer Grund, warum Rust ein unsicheres zweites Ich hat, ist, dass die
zugrunde liegende Computer-Hardware von Natur aus unsicher ist. Wenn Rust dich
keine unsicheren Operationen durchführen ließe, könntest du bestimmte Aufgaben
nicht ausführen. Rust muss es dir ermöglichen, Low-Level-Systemprogrammierung
zu machen, z.B. direkt mit dem Betriebssystem zu interagieren oder sogar dein
eigenes Betriebssystem zu schreiben. Arbeiten mit
Low-Level-Systemprogrammierung ist eines der Ziele der Sprache. Lass uns
untersuchen, was wir mit unsicherem Rust tun können und wie wir es tun können.

### Unsichere Superkräfte einsetzen

Um auf unsicheres Rust umzuschalten, verwendest du das Schlüsselwort `unsafe`
und startest dann einen neuen Block, der den unsicheren Code enthält. In
unsicherem Rust kannst du fünf Aktionen ausführen, die du in sicherem Rust
nicht ausführen kannst, die wir _unsichere Superkräfte_ nennen. Zu diesen
Superkräften gehören folgende Fähigkeiten:

1. Dereferenzieren eines Rohzeigers
2. Aufrufen einer unsicheren Funktion oder Methode
3. Zugreifen auf oder Ändern einer veränderbaren statischen Variablen
4. Implementieren eines unsicheren Merkmals (trait)
5. Zugreifen auf Feldern in `union`

Es ist wichtig zu verstehen, dass `unsafe` weder den Ausleihenprüfer (borrow
checker) abschaltet noch andere Sicherheitsprüfungen von Rust deaktiviert: Wenn
du eine Referenz in einem unsicheren Code verwendest, wird diese trotzdem
geprüft. Das Schlüsselwort `unsafe` gibt dir nur Zugriff auf diese fünf
Funktionalitäten, die dann vom Compiler nicht auf Speichersicherheit geprüft
werden. In einem unsicheren Block erhältst du immer noch ein gewisses Maß an
Sicherheit.

Darüber hinaus bedeutet `unsafe` nicht, dass der Code innerhalb des Blocks
notwendigerweise gefährlich ist oder dass er definitiv
Speichersicherheitsprobleme haben wird: Das Ziel ist, dass du als Programmierer
sicherstellst, dass der Code innerhalb eines `unsafe`-Blocks auf gültige Weise
auf den Speicher zugreifen wird.

Menschen sind fehlbar und Fehler werden passieren, aber wenn du verlangst, dass
diese fünf unsicheren Operationen innerhalb von Blöcken mit dem Vermerk
`unsafe` durchgeführt werden müssen, weißt du, dass alle Fehler im Zusammenhang
mit der Speichersicherheit innerhalb eines `unsafe`-Blocks liegen müssen. Halte
`unsafe`-Blöcke klein; du wirst später dankbar sein, wenn du Speicherfehler
untersuchst.

Um unsicheren Code so weit wie möglich zu isolieren, ist es am besten, solchen
Code in eine sichere Abstraktion einzupacken und eine sichere API
bereitzustellen, auf die wir später im Kapitel eingehen werden, wenn wir
unsichere Funktionen und Methoden untersuchen. Teile der Standardbibliothek
sind als sichere Abstraktionen über unsicheren, geprüften Code implementiert.
Das Einpacken von unsicherem Code in eine sichere Abstraktion verhindert, dass
sich die Verwendung von `unsafe` auf alle Stellen auswirkt, an denen du oder
deine Benutzer die mit `unsafe`-Code implementierte Funktionalität verwenden
möchtest, da das Verwenden einer sicheren Abstraktion sicher ist.

Betrachten wir der Reihe nach jede der fünf unsicheren Superkräfte. Wir werden
uns auch einige Abstraktionen ansehen, die eine sichere Schnittstelle zu
unsicheren Codes bieten.

### Dereferenzieren eines Rohzeigers

Im Abschnitt [„Hängende Referenzen“][dangling-references] in Kapitel 4 haben
wir erwähnt, dass der Compiler sicherstellt, dass Referenzen immer gültig sind.
Unsicheres Rust hat zwei neue Typen namens _Rohzeiger_ (raw pointers), die
ähnlich wie Referenzen sind. Wie bei Referenzen können Rohzeiger unveränderbar
oder veränderbar sein und werden als `_const T` bzw. `_mut T` geschrieben. Das
Sternchen ist nicht der Dereferenzierungsoperator (dereference operator); es
ist Teil des Typnamens. Im Zusammenhang mit Rohzeigern bedeutet _unveränderbar_
(immutable), dass der Zeiger nach der Dereferenzierung nicht direkt zugewiesen
werden kann.

Rohzeiger sind anders als Referenzen und intelligente Zeiger:

- Sie dürfen die Ausleihregeln ignorieren, indem sie sowohl unveränderbare als
  auch veränderbare Zeiger oder mehrere veränderbare Zeiger auf die gleiche
  Stelle haben.
- Sie zeigen nicht garantiert auf gültigen Speicher.
- Sie dürfen null sein.
- Sie implementieren kein automatisches Aufräumen.

Wenn du dich dagegen entscheidest, diese Garantien von Rust erzwingen zu
lassen, kannst du auf garantierte Sicherheit verzichten und stattdessen eine
höhere Performanz oder die Möglichkeit der Interaktion mit einer anderen
Sprache oder Hardware erhalten, für die die Rust-Garantien nicht gelten.

Codeblock 20-1 zeigt, wie man aus Referenzen einen unveränderbaren und einen
veränderbaren Rohzeiger erzeugt.

```rust
# fn main() {
    let mut num = 5;

    let r1 = &raw const num;
    let r2 = &raw mut num;
# }
```

<span class="caption">Codeblock 20-1: Erstellen von Rohzeigern aus
Referenzen</span>

Beachte, dass wir das Schlüsselwort `unsafe` in diesem Code nicht verwenden.
Wir können Rohzeiger in sicherem Code erzeugen; wir können nur keine Rohzeiger
außerhalb eines unsicheren Blocks dereferenzieren, wie du gleich sehen wirst.

Wir haben Rohzeiger mit Hilfe des Operators `&raw` erstellt: `&raw const num`
erzeugt einen unveränderbaren Rohzeiger `*const i32`, und `&raw mut num`
erzeugt einen veränderbaren Rohzeiger `*mut i32`. Da wir sie direkt aus
lokalen Variablen erstellt haben, wissen wir, dass diese speziellen Rohzeiger
gültig sind, aber wir können diese Annahme nicht für jeden beliebigen Rohzeiger
treffen.

Um dies zu demonstrieren, werden wir als Nächstes einen Rohzeiger erstellen,
dessen Gültigkeit wir nicht so sicher sein können. Wir verwenden das
Schlüsselwort `as` anstelle des Operators `&raw`, um einen Wert umzuwandeln
(cast). Codeblock 20-2 zeigt, wie man einen Rohzeiger auf eine willkürliche
Stelle im Speicher erstellt. Der Versuch, willkürlichen Speicher zu verwenden,
ist undefiniert: Es könnten Daten an dieser Adresse vorhanden sein oder auch
nicht, der Compiler könnte den Code so optimieren, dass es keinen
Speicherzugriff gibt, oder das Programm könnte mit einer Schutzverletzung
(segmentation fault) abbrechen. Normalerweise gibt es keinen guten Grund,
solchen Code zu schreiben, vor allem, wenn man stattdessen den Operator `&raw`
verwenden kann, aber es ist möglich.

```rust
# fn main() {
    let address = 0x012345usize;
    let r = address as *const i32;
# }
```

<span class="caption">Codeblock 20-2: Erzeugen eines Rohzeigers auf eine
willkürliche Speicheradresse</span>

Erinnere dich, dass wir Rohzeiger in sicherem Code erstellen können, aber wir
können keine Rohzeiger dereferenzieren und die Daten lesen, auf die gezeigt
wird. In Codeblock 20-3 wenden wir den Dereferenzierungsoperator `*` auf einen
Rohzeiger an, was einen `unsafe`-Block erfordert.

```rust
# fn main() {
    let mut num = 5;

    let r1 = &num as *const i32;
    let r2 = &mut num as *mut i32;

    unsafe {
        println!("r1 ist: {}", *r1);
        println!("r2 ist: {}", *r2);
    }
# }
```

<span class="caption">Codeblock 20-3: Dereferenzieren von Rohzeigern innerhalb
eines `unsafe`-Blocks</span>

Das Erstellen eines Zeigers schadet nicht; erst wenn wir versuchen, auf den
Wert zuzugreifen, auf den er zeigt, könnten wir es am Ende mit einem ungültigen
Wert zu tun haben.

Beachte auch, dass wir in den Codeblöcken 20-1 und 20-3 die Rohzeiger `*const
 i32` und `*mut i32` erstellt haben, die beide auf die gleiche Speicherstelle
zeigten, in der `num` gespeichert ist. Wenn wir stattdessen versucht hätten,
eine unveränderbare und einen veränderbare Referenz auf `num` zu erstellen,
hätte sich der Code nicht kompilieren lassen, weil die Eigentumsregeln von Rust
eine veränderbare Referenz nicht gleichzeitig mit unveränderbaren Referenzen
zulassen. Mit Rohzeigern können wir einen veränderbaren und einen
unveränderbaren Zeiger auf denselben Ort erstellen und Daten über den
veränderbaren Zeiger ändern, wodurch möglicherweise eine
Daten-Wettlaufsituation (data race) entsteht. Sei vorsichtig!

Warum solltest du bei all diesen Gefahren jemals Rohzeiger verwenden? Ein
Hauptanwendungsfall ist die Kopplung mit C-Code, wie du im nächsten Abschnitt
sehen wirst. Ein anderer Fall ist der Aufbau von sicheren Abstraktionen, die
der Ausleihenprüfer nicht versteht. Wir stellen unsichere Funktionen vor und
betrachten dann ein Beispiel für eine sichere Abstraktion, die unsicheren
Code verwendet.

### Aufrufen einer unsicheren Funktion oder Methode

Die zweite Art von Operationen, die du in einem unsicheren Block ausführen
kannst, sind Aufrufe von unsicheren Funktionen. Unsichere Funktionen und
Methoden sehen genau wie reguläre Funktionen und Methoden aus, aber sie haben
ein zusätzliches `unsafe` vor dem Rest der Definition. Das Schlüsselwort
`unsafe` weist in diesem Zusammenhang darauf hin, dass die Funktion
Anforderungen hat, die wir einhalten müssen, wenn wir diese Funktion aufrufen,
denn Rust kann nicht garantieren, dass wir diese Anforderungen erfüllt haben.
Indem wir eine unsichere Funktion innerhalb eines `unsafe`-Blocks aufrufen,
sagen wir, dass wir die Dokumentation dieser Funktion gelesen haben und wir die
Verantwortung für die Einhaltung der Verträge der Funktion übernehmen.

Hier ist eine unsichere Funktion namens `dangerous`, die in ihrem Rumpf nichts
tut:

```rust
# fn main() {
    unsafe fn dangerous() {}

    unsafe {
        dangerous();
    }
# }
```

Wir müssen die Funktion `dangerous` innerhalb eines separaten `unsafe`-Blocks
aufrufen. Wenn wir versuchen, `dangerous` ohne den `unsafe`-Block aufzurufen,
erhalten wir einen Fehler:

```console
$ cargo run
   Compiling unsafe-example v0.1.0 (file:///projects/unsafe-example)
error[E0133]: call to unsafe function is unsafe and requires unsafe function or block
 --> src/main.rs:4:5
  |
4 |     dangerous();
  |     ^^^^^^^^^^^ call to unsafe function
  |
  = note: consult the function's documentation for information on how to avoid undefined behavior

For more information about this error, try `rustc --explain E0133`.
error: could not compile `unsafe-example` (bin "unsafe-example") due to 1 previous error
```

Mit dem `unsafe`-Block versichern wir Rust, dass wir die Dokumentation der
Funktion gelesen haben, dass wir verstehen, wie sie richtig zu benutzen ist,
und dass wir überprüft haben, dass wir den Vertrag der Funktion erfüllen.

Um unsichere Operationen im Rumpf einer `unsafe`-Funktion auszuführen, musst du
wie bei einer regulären Funktion einen `unsafe`-Block verwenden, und der
Compiler wird dich warnen, wenn du dies vergisst. Dies hilft dabei,
`unsafe`-Blöcke so klein wie möglich zu halten, da unsichere Operationen
möglicherweise nicht im gesamten Funktionsrumpf benötigt werden.

#### Erstellen einer sicheren Abstraktion von unsicherem Code

Nur weil eine Funktion unsicheren Code enthält, bedeutet das nicht, dass wir
die gesamte Funktion als unsicher markieren müssen. Tatsächlich ist das
Einpacken von unsicherem Codes in eine sichere Funktion eine gängige
Abstraktion. Als Beispiel betrachten wir die Funktion `split_at_mut` aus der
Standardbibliothek, die unsicheren Code verwendet. Wir untersuchen, wie wir sie
implementieren könnten. Diese sichere Methode ist auf veränderbaren
Anteilstypen definiert: Sie nimmt einen Anteilstyp und macht zwei daraus, indem
sie den Anteilstyp an dem als Argument angegebenen Index teilt. Codeblock 20-4
zeigt, wie man `split_at_mut` verwendet.

```rust
# fn main() {
    let mut v = vec![1, 2, 3, 4, 5, 6];

    let r = &mut v[..];

    let (a, b) = r.split_at_mut(3);

    assert_eq!(a, &mut [1, 2, 3]);
    assert_eq!(b, &mut [4, 5, 6]);
# }
```

<span class="caption">Codeblock 20-4: Verwenden der sicheren Funktion
`split_at_mut`</span>

Wir können diese Funktion nicht nur mit sicherem Rust implementieren. Ein
Versuch könnte in etwa wie in Codeblock 20-5 aussehen, der sich nicht
kompilieren lässt. Der Einfachheit halber implementieren wir `split_at_mut` als
Funktion und nicht als Methode und nur für Anteilstypen von `i32`-Werten, nicht
für einen generischen Typ `T`.

```rust,does_not_compile
fn split_at_mut(values: &mut [i32], mid: usize) -> (&mut [i32], &mut [i32]) {
    let len = values.len();

    assert!(mid <= len);

    (&mut values[..mid], &mut values[mid..])
}
#
# fn main() {
#     let mut vector = vec![1, 2, 3, 4, 5, 6];
#     let (left, right) = split_at_mut(&mut vector, 3);
# }
```

<span class="caption">Codeblock 20-5: Versuch einer Implementierung von
`split_at_mut` unter ausschließlicher Verwendung von sicherem Rust</span>

Diese Funktion ermittelt zunächst die Gesamtlänge des Anteilstypen. Dann stellt
sie fest, dass der als Parameter angegebene Index innerhalb des Anteilstypen
liegt, indem sie prüft, ob er kleiner oder gleich der Länge ist. Die
Zusicherung (assertion) bedeutet, dass die Funktion abstürzt, wenn wir einen
Index übergeben, der größer als die Länge ist, bei der der Anteilstyp geteilt
werden soll, bevor sie versucht, diesen Index zu verwenden.

Dann geben wir zwei veränderbare Anteilstypen in einem Tupel zurück: Einen vom
Anfang des ursprünglichen Anteilstyps bis zum Index `mid` und einen weiteren
von `mid` bis zum Ende des Anteilstyps.

Wenn wir versuchen, den Code in Codeblock 20-5 zu kompilieren, erhalten wir
einen Fehler.

```console
$ cargo run
   Compiling unsafe-example v0.1.0 (file:///projects/unsafe-example)
error[E0499]: cannot borrow `*values` as mutable more than once at a time
 --> src/main.rs:6:31
  |
1 | fn split_at_mut(values: &mut [i32], mid: usize) -> (&mut [i32], &mut [i32]) {
  |                         - let's call the lifetime of this reference `'1`
...
6 |     (&mut values[..mid], &mut values[mid..])
  |     --------------------------^^^^^^--------
  |     |     |                   |
  |     |     |                   second mutable borrow occurs here
  |     |     first mutable borrow occurs here
  |     returning this value requires that `*values` is borrowed for `'1`

For more information about this error, try `rustc --explain E0499`.
error: could not compile `unsafe-example` (bin "unsafe-example") due to 1 previous error
```

Der Ausleihenprüfer von Rust kann nicht verstehen, dass wir verschiedene Teile
des Anteilstyps ausleihen; er weiß nur, dass wir zweimal vom selben Anteilstyp
ausleihen. Das Ausleihen verschiedener Teile eines Anteilstyps ist
grundsätzlich in Ordnung, weil sich die beiden Anteilstypen nicht überlappen,
aber Rust ist nicht schlau genug, um das zu wissen. Wenn wir wissen, dass der
Code in Ordnung ist, Rust aber nicht, ist es an der Zeit, unsicheren Code zu
verwenden.

Codeblock 20-6 zeigt, wie man einen `unsafe`-Block, einen Rohzeiger und einige
Aufrufe unsicherer Funktionen verwendet, um die Implementierung von
`split_at_mut` zum Funktionieren zu bringen.

```rust
use std::slice;

fn split_at_mut(values: &mut [i32], mid: usize) -> (&mut [i32], &mut [i32]) {
    let len = values.len();
    let ptr = values.as_mut_ptr();

    assert!(mid <= len);

    unsafe {
        (
            slice::from_raw_parts_mut(ptr, mid),
            slice::from_raw_parts_mut(ptr.add(mid), len - mid),
        )
    }
}
#
# fn main() {
#     let mut vector = vec![1, 2, 3, 4, 5, 6];
#     let (left, right) = split_at_mut(&mut vector, 3);
# }
```

<span class="caption">Codeblock 20-6: Verwenden von unsicherem Codes bei der
Implementierung der Funktion `split_at_mut`</span>

Erinnere dich an den Abschnitt [„Der Anteilstyp (slice)“][the-slice-type] in
Kapitel 4, dass Anteilstypen Zeiger auf Daten und die Länge des Anteilstyps
sind. Wir verwenden die Methode `len`, um die Länge eines Anteilstyps zu
erhalten, und die Methode `as_mut_ptr`, um auf den Rohzeiger eines Anteilstyps
zuzugreifen. Da wir in diesem Fall einen veränderbaren Anteilstyp von
`i32`-Werten haben, gibt `as_mut_ptr` einen Rohzeiger vom Typ `*mut i32`
zurück, den wir in der Variable `ptr` gespeichert haben.

Wir halten an der Zusicherung fest, dass der Index `mid` innerhalb des
Anteilstyps liegt. Dann kommen wir zum unsicheren Code: Die Funktion
`slice::from_raw_parts_mut` nimmt einen Rohzeiger und eine Länge und erzeugt
einen Anteilstyp. Wir verwenden diese Funktion, um einen Anteilstyp zu
erstellen, der mit `ptr` beginnt und `mid` Elemente lang ist. Dann rufen wir
die Methode `add` auf `ptr` mit `mid` als Argument auf, um einen Rohzeiger
zu erhalten, der bei `mid` beginnt, und wir erzeugen einen Anteilstyp mit
diesem Zeiger und der verbleibenden Anzahl von Elementen nach `mid`.

Die Funktion `slice::from_raw_parts_mut` ist unsicher, weil sie einen Rohzeiger
nimmt und darauf vertrauen muss, dass dieser Zeiger gültig ist. Die Methode
`add` auf dem Rohzeiger ist ebenfalls unsicher, weil sie darauf vertrauen muss,
dass die Offset-Position ebenfalls ein gültiger Zeiger ist. Deshalb mussten wir
einen `unsafe`-Block um unsere Aufrufe von `slice::from_raw_parts_mut` und
`add` legen, damit wir sie aufrufen konnten. Wenn wir uns den Code ansehen und
die Zusicherung hinzufügen, dass `mid` kleiner oder gleich `len` sein muss,
können wir sagen, dass alle Rohzeiger innerhalb des `unsafe`-Blocks gültige
Zeiger auf Daten innerhalb des Anteilstyps sind. Dies ist eine akzeptable und
angemessene Verwendung von `unsafe`.

Beachte, dass wir die resultierende Funktion `split_at_mut` nicht als `unsafe`
markieren müssen, und wir können diese Funktion aus dem sicheren Rust aufrufen.
Wir haben eine sichere Abstraktion des unsicheren Codes mit einer
Implementierung der Funktion geschaffen, die `unsafe` Code auf sichere Weise
verwendet, weil sie nur gültige Zeiger aus den Daten erzeugt, auf die diese
Funktion Zugriff hat.

Im Gegensatz dazu würde die Verwendung von `slice::from_raw_parts_mut` in
Codeblock 20-7 wahrscheinlich abstürzen, wenn der Anteilstyp verwendet wird.
Dieser Code nimmt einen beliebigen Speicherplatz und erzeugt einen Anteilstyp
mit einer Länge von 10.000 Elementen.

```rust
# fn main() {
    use std::slice;

    let address = 0x01234usize;
    let r = address as *mut i32;

    let values: &[i32] = unsafe { slice::from_raw_parts_mut(r, 10000) };
# }
```

<span class="caption">Codeblock 20-7: Erstellen eines Anteilstyps aus einer
beliebigen Speicherstelle</span>

Wir besitzen den Speicher an dieser beliebigen Stelle nicht und es gibt keine
Garantie, dass der von diesem Code erzeugte Anteilstyp gültige `i32`-Werte
enthält. Der Versuch, `values` so zu benutzen, als ob er ein gültiger
Anteilstyp ist, führt zu undefiniertem Verhalten.

#### Verwenden von `extern`-Funktionen um externen Code aufzurufen

Manchmal muss dein Rust-Code möglicherweise mit Code interagieren, der in einer
anderen Sprache geschrieben wurde. Hierfür hat Rust das Schlüsselwort `extern`,
das das Erstellen und Verwenden einer _Fremdfunktionsschnittstelle_ (Foreign
Function Interface, kurz FFI) erleichtert, was eine Möglichkeit für eine
Programmiersprache ist, Funktionen zu definieren und es einer anderen (fremden)
Programmiersprache zu ermöglichen, diese Funktionen aufzurufen.

In Codeblock 20-8 wird gezeigt, wie eine Integration der Funktion `abs` aus der
C-Standardbibliothek erfolgt. Funktionen, die in `extern`-Blöcken deklariert
sind, sind normalerweise unsicher, wenn sie aus Rust Code aufgerufen werden,
und müssen daher mit `unsafe` gekennzeichnet werden. Der Grund dafür ist, dass
andere Sprachen die Regeln und Garantien von Rust nicht erzwingen und Rust sie
nicht überprüfen kann, sodass die Verantwortung für die Sicherheit beim
Programmierer liegt.

<span class="filename">Dateiname: src/main.rs</span>

```rust
extern "C" {
    fn abs(input: i32) -> i32;
}

fn main() {
    unsafe {
        println!("Absolutwert von -3 gemäß C: {}", abs(-3));
    }
}
```

<span class="caption">Codeblock 20-8: Deklarieren und Aufrufen einer
`extern`-Funktion, die in einer anderen Sprache definiert wurde</span>

Innerhalb des Blocks `unsafe extern "C"` listen wir die Namen und Signaturen
von externen Funktionen aus einer anderen Sprache auf, die wir aufrufen wollen.
Der Teil `"C"` definiert, welche _Binärschnittstelle_ (application binary
interface, kurz ABI) die externe Funktion benutzt: Die ABI definiert, wie die
Funktion auf der technischen Ebene (assembly level) aufgerufen wird. Die ABI
`"C"` ist die gebräuchlichste und folgt der ABI der Programmiersprache C.
Informationen über alle von Rust unterstützten ABIs finden Sie in der
[Rust-Referenz][ABI].

Jedes Element, das innerhalb eines `unsafe extern`-Blocks deklariert wird, ist
implizit `unsafe`. Einige FFI-Funktionen sind jedoch _sicher aufrufbar_. Zum
Beispiel hat die Funktion `abs` aus der C-Standardbibliothek keine Überlegungen
zur Speichersicherheit und wir wissen, dass sie mit jedem `i32` aufgerufen
werden kann. In solchen Fällen können wir das Schlüsselwort `safe` verwenden,
um zu sagen, dass der Aufruf dieser speziellen Funktion sicher ist, obwohl sie
sich in einem `unsafe extern`-Block befindet. Sobald wir diese Änderung
vorgenommen haben, erfordert der Aufruf der Funktion keinen `unsafe`-Block
mehr, wie in Codeblock 20-9 gezeigt.

<span class="filename">Dateiname: src/main.rs</span>

```rust
unsafe extern "C" {
    safe fn abs(input: i32) -> i32;
}

fn main() {
    println!("Absolutwert von -3 gemäß C: {}", abs(-3));
}
```

<span class="caption">Codeblock 20-9: Explizite Kennzeichnung einer Funktion
mit `safe` innerhalb eines `unsafe extern`-Blocks und sicherer Aufruf dieser
Funktion</span>

Die Kennzeichnung einer Funktion mit `safe` macht sie nicht von sich aus
sicher! Vielmehr ist es ein Versprechen, das du Rust gegenüber abgibst, dass
sie sicher ist. Es bleibt in deiner Verantwortung, dafür zu sorgen, dass dieses
Versprechen eingehalten wird!

> #### Aufrufen von Rust-Funktionen aus anderen Sprachen
>
> Wir können auch `extern` verwenden, um eine Schnittstelle zu schaffen, die es
> anderen Sprachen erlaubt, Rust-Funktionen aufzurufen. Anstelle eines
> `extern`-Blocks fügen wir das Schlüsselwort `extern` hinzu und geben die zu
> verwendende ABI unmittelbar vor dem Schlüsselwort `fn` der relevanten
> Funktion an. Wir müssen auch eine Annotation `#[unsafe(no_mangle)]`
> hinzufügen, um dem Rust-Compiler mitzuteilen, dass er den Namen dieser
> Funktion nicht verändern soll. _Mangling_ bedeutet, dass ein Compiler den
> Namen, den wir einer Funktion gegeben haben, in einen anderen Namen ändert,
> der mehr Informationen für andere Teile des Kompiliervorgangs enthält, aber
> weniger menschenlesbar ist. Jeder Programmiersprachen-Compiler verändert
> Namen etwas anders. Damit eine Rust-Funktion von anderen Sprachen aufgerufen
> werden kann, müssen wir also die Namensveränderung des Rust-Compilers
> deaktivieren. Dies ist unsicher, da es ohne die eingebaute
> Namensveränderung-Funktion zu Namenskollisionen in verschiedenen Bibliotheken
> kommen kann. Es liegt also in unserer Verantwortung, sicherzustellen, dass
> der von uns gewählte Name ohne Namensveränderung sicher exportiert werden
> kann.
>
> Im folgenden Beispiel machen wir die Funktion `call_from_c` von C-Code aus
> zugänglich, nachdem sie in eine gemeinsame Bibliothek kompiliert und von C
> gelinkt wurde:
>
> ```rust
> #[unsafe(no_mangle)]
> pub extern "C" fn call_from_c() {
>     println!("Rust-Funktion von C aufgerufen!");
> }
> ```
>
> Diese Verwendung von `extern` erfordert `unsafe` nur im Attribut, nicht im
> `extern`-Block.

### Zugreifen oder Ändern einer veränderbaren, statischen Variable

In diesem Buch haben wir noch nicht über _globale Variablen_ gesprochen, die
Rust zwar unterstützt, die aber wegen der Eigentumsregeln von Rust
problematisch sein können. Wenn zwei Stränge (threads) auf dieselbe
veränderbare, globale Variable zugreifen, kann dies zu einer
Daten-Wettlaufsituation (data race) führen.

In Rust werden globale Variablen als _statische_ Variablen bezeichnet.
Codeblock 20-10 zeigt ein Beispiel für die Deklaration und Verwendung einer
statischen Variablen mit einem Zeichenkettenanteilstyp als Wert.

<span class="filename">Dateiname: src/main.rs</span>

```rust
static HELLO_WORLD: &str = "Hallo Welt!";

fn main() {
    println!("Name ist: {HELLO_WORLD}");
}
```

<span class="caption">Codeblock 20-10: Definieren und Verwenden einer
unveränderbaren, statischen Variablen</span>

Statische Variablen ähneln Konstanten, die wir in [„Konstanten
deklarieren“][constants] in Kapitel 3 besprochen haben. Die Namen von
statischen Variablen stehen per Konvention in `SCHREIENDER_SCHLANGENSCHRIFT`.
Statische Variablen können nur Referenzen mit der Lebensdauer `'static`
speichern, was bedeutet, dass der Rust-Compiler die Lebensdauer herausfinden
kann, und wir brauchen sie nicht explizit anzugeben. Der Zugriff auf eine
unveränderbare, statische Variable ist sicher.

Ein feiner Unterschied zwischen Konstanten und unveränderbaren, statischen
Variablen besteht darin, dass Werte in einer statischen Variable eine feste
Adresse im Speicher haben. Beim Verwenden des Wertes wird immer auf die
gleichen Daten zugegriffen. Konstanten hingegen dürfen ihre Daten duplizieren,
wann immer sie verwendet werden. Ein weiterer Unterschied besteht darin, dass
statische Variablen veränderbar sein können. Der Zugriff auf und die Änderung
von veränderbaren, statischen Variablen ist _unsicher_. Codeblock 20-11 zeigt,
wie man eine veränderbare, statische Variable namens `COUNTER` deklariert, auf
sie zugreift und sie modifiziert.

<span class="filename">Dateiname: src/main.rs</span>

```rust
static mut COUNTER: u32 = 0;

/// SAFETY: Calling this from more than a single thread at a time is undefined
/// behavior, so you *must* guarantee you only call it from a single thread at
/// a time.
unsafe fn add_to_count(inc: u32) {
    COUNTER += inc;
}

fn main() {
    unsafe {
        // SAFETY: This is only called from a single thread in `main`.
        add_to_count(3);
        println!("COUNTER: {}", COUNTER);
    }
}
```

<span class="caption">Codeblock 20-11: Lesen von und Schreiben in eine
veränderbare, statische Variable ist unsicher</span>

Wie bei regulären Variablen spezifizieren wir die Veränderbarkeit mit dem
Schlüsselwort `mut`. Jeder Code, der `COUNTER` liest oder schreibt, muss
innerhalb eines `unsafe`-Blocks liegen. Der Code in Codeblock 20-11 kompiliert
und gibt `COUNTER: 3` so, wie wir es erwarten würden, weil er nur einen
einzigen Strang hat. Wenn mehrere Stränge auf `COUNTER` zugreifen, würde dies
wahrscheinlich zu einer Daten-Wettlaufsituation führen, es handelt sich also um
ein undefiniertes Verhalten. Daher müssen wir die gesamte Funktion als `unsafe`
kennzeichnen und die Sicherheitseinschränkung dokumentieren, damit jeder, der
die Funktion aufruft, weiß, was er sicher tun darf und was nicht.

Immer wenn wir eine `unsafe`-Funktion schreiben, ist es idiomatisch, einen
Kommentar anzugeben, der mit `SAFETY` beginnt und erklärt, was der Aufrufer tun
muss, um die Funktion sicher aufzurufen. Ebenso ist es idiomatisch, beim Aufruf
einer `unsafe`-Operation einen Kommentar zu schreiben, der mit `SAFETY`
beginnt, um zu erklären, wie die Sicherheitsregeln eingehalten werden.

Darüber hinaus lehnt der Compiler durch die Compiler-Lint-Prüfung jeden Versuch
ab, Referenzen auf eine veränderbare statische Variable zu erstellen. Du musst
entweder die Schutzmaßnahmen der Lint-Prüfung explizit deaktivieren, indem du
eine Anmerkung `#[allow(static_mut_refs)]` hinzufügst, oder auf die
veränderbare statische Variable über einen Roh-Zeiger zugreifst, der mit einem
der Roh-Ausleihen-Operatoren erstellt wurde. Dies gilt auch für Fälle, in denen
die Referenz unsichtbar erstellt wird, wie beispielsweise bei der Verwendung in
`println!` in diesem Codeblock. Die Anforderung, dass Referenzen auf statische
veränderbare Variablen über Roh-Zeiger erstellt werden müssen, trägt dazu bei,
die Sicherheitsanforderungen deutlicher zu machen.

Bei veränderbaren Daten, die global zugänglich sind, ist es schwierig,
sicherzustellen, dass es keine Daten-Wettlaufsituationen gibt, weshalb Rust
veränderbare, statische Variablen als unsicher betrachtet. Wann immer möglich,
ist es vorzuziehen, die in Kapitel 16 besprochenen Nebenläufigkeitstechniken
und Strang-sicheren, intelligenten Zeiger zu verwenden, damit der Compiler
prüft, ob der Datenzugriff von verschiedenen Strängen sicher ist.

### Implementieren eines unsicheren Merkmals

Wir können `unsafe` zum Implementieren eines unsicheren Merkmals (unsafe trait)
verwenden. Ein Merkmal ist unsicher, wenn mindestens eine ihrer Methoden eine
Invariante hat, die der Compiler nicht verifizieren kann. Wir können erklären,
dass ein Merkmal `unsafe` ist, indem wir das Schlüsselwort `unsafe` vor `trait`
einfügen und die Implementierung des Merkmals ebenfalls mit `unsafe` markieren,
wie in Codeblock 20-12 gezeigt.

```rust
unsafe trait Foo {
    // Methoden kommen hierhin
}

unsafe impl Foo for i32 {
    // Methoden-Implementierungen kommen hierhin
}
#
# fn main() {}
```

<span class="caption">Codeblock 20-12: Definition und Implementierung eines
unsicheren Merkmals</span>

Indem wir `unsafe impl` verwenden, versprechen wir, dass wir die Invarianten
aufrechterhalten, die der Compiler nicht verifizieren kann.

Erinnere dich als Beispiel an die Marker-Merkmale `Send` und `Sync`, die wir im
Abschnitt [„Erweiterbare Nebenläufigkeit mit `Send` und `Sync`“][send-and-sync]
in Kapitel 16 besprochen haben: Der Compiler implementiert diese Merkmale
automatisch, wenn unsere Typen vollständig aus anderen Typen zusammengesetzt
sind, die `Send` und `Sync` implementieren. Wenn wir einen Typ implementieren,
der einen Typ enthält, der nicht `Send` oder `Sync` implementiert, z.B.
Rohzeiger, und wir diesen Typ als `Send` oder `Sync` markieren wollen, müssen
wir `unsafe` verwenden. Rust kann nicht überprüfen, ob unser Typ die Garantien
aufrechterhält, dass er sicher über Stränge gesendet oder von mehreren Strängen
aus zugegriffen werden kann; daher müssen wir diese Prüfungen manuell
durchführen und als solche mit `unsafe` kennzeichnen.

### Zugreifen auf Felder einer Vereinigung (union)

Die letzte Aktion, die nur mit `unsafe` funktioniert, ist der Zugriff auf
Felder einer Vereinigungen. Eine _Vereinigung_ ähnelt einer `struct`, jedoch
wird in einer bestimmten Instanz jeweils nur ein deklariertes Feld verwendet.
Vereinigungen werden hauptsächlich als Schnittstelle zu Vereinigungen in C-Code
verwendet. Der Zugriff auf Vereinigungsfelder ist unsicher, da Rust den Typ der
Daten, die derzeit in der Vereinigungsinstanz gespeichert sind, nicht
garantieren kann. Weitere Informationen über Vereinigung findest du in der
[Unions-Referenz][unions].

### Miri zur Überprüfung von `unsafe`-Code verwenden

Wenn du unsicheren Code schreibst, möchtest du vielleicht überprüfen, ob das,
was du geschrieben hast, tatsächlich sicher und korrekt ist. Eine der besten
Möglichkeiten, dies zu tun, ist die Verwendung von Miri, einem offiziellen
Rust-Werkzeug zur Erkennung von undefiniertem Verhalten. Während der
Ausleihenprüfer ein _statisches_ Werkzeug ist, das zur Kompilierzeit arbeitet,
ist Miri ein _dynamisches_ Werkzeug, das zur Laufzeit arbeitet. Es prüft deinen
Code, indem es dein Programm oder deine Testfälle ausführt und erkennt, ob du
Rust-Regeln verletzt.

Die Verwendung von Miri erfordert einen Nightly-Build von Rust (über das wir in
[Anhang G: Wie Rust erstellt wird und „nächtliches Rust“][nightly] sprechen).
Du kannst sowohl eine nächtliche Version von Rust als auch das Miri-Tool
installieren, indem du `rustup +nightly component add miri` ausführst. Dies
ändert nicht die Rust-Version deines Projekts, sondern fügt das Werkzeug nur zu
deinem System hinzu, damit du es verwenden kannst, wenn du willst. Du kannst
Miri für ein Projekt ausführen, indem du `cargo +nightly miri run` oder `cargo
 +nightly miri test` eingibst.

Ein Beispiel dafür, wie hilfreich dies sein kann, siehst du beim Ausführen mit
Codeblock 20-7:

```console
$ cargo +nightly miri run
   Compiling unsafe-example v0.1.0 (file:///projects/unsafe-example)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.01s
     Running `file:///home/.rustup/toolchains/nightly/bin/cargo-miri runner target/miri/debug/unsafe-example`
warning: integer-to-pointer cast
 --> src/main.rs:5:13
  |
5 |     let r = address as *mut i32;
  |             ^^^^^^^^^^^^^^^^^^^ integer-to-pointer cast
  |
  = help: this program is using integer-to-pointer casts or (equivalently) `ptr::with_exposed_provenance`, which means that Miri might miss pointer bugs in this program
  = help: see https://doc.rust-lang.org/nightly/std/ptr/fn.with_exposed_provenance.html for more details on that operation
  = help: to ensure that Miri does not miss bugs in your program, use Strict Provenance APIs (https://doc.rust-lang.org/nightly/std/ptr/index.html#strict-provenance, https://crates.io/crates/sptr) instead
  = help: you can then set `MIRIFLAGS=-Zmiri-strict-provenance` to ensure you are not relying on `with_exposed_provenance` semantics
  = help: alternatively, `MIRIFLAGS=-Zmiri-permissive-provenance` disables this warning
  = note: BACKTRACE:
  = note: inside `main` at src/main.rs:5:13: 5:32

error: Undefined Behavior: pointer not dereferenceable: pointer must be dereferenceable for 40000 bytes, but got 0x1234[noalloc] which is a dangling pointer (it has no provenance)
 --> src/main.rs:7:35
  |
7 |     let values: &[i32] = unsafe { slice::from_raw_parts_mut(r, 10000) };
  |                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Undefined Behavior occurred here
  |
  = help: this indicates a bug in the program: it performed an invalid operation, and caused Undefined Behavior
  = help: see https://doc.rust-lang.org/nightly/reference/behavior-considered-undefined.html for further information
  = note: BACKTRACE:
  = note: inside `main` at src/main.rs:7:35: 7:70

note: some details are omitted, run with `MIRIFLAGS=-Zmiri-backtrace=full` for a verbose backtrace

error: aborting due to 1 previous error; 1 warning emitted
```

Miri warnt uns richtigerweise, dass wir gemeinsame Referenzen auf veränderbare
Daten haben. Hier gibt Miri nur eine Warnung aus, da in diesem Fall nicht
garantiert ist, dass es sich um undefiniertes Verhalten handelt, und es sagt
uns nicht, wie wir das Problem beheben können. In einigen Fällen kann Miri auch
eindeutige Fehler erkennen &ndash; Codemuster, die _mit Sicherheit_ falsch sind
&ndash; und Empfehlungen geben, wie diese Fehler behoben werden können.

Miri deckt nicht alles auf, was man beim Schreiben von unsicherem Code falsch
machen könnte. Miri ist ein dynamisches Analysewerkzeug, d.h. es erkennt nur
Probleme mit Code, der tatsächlich ausgeführt wird. Das bedeutet, dass du es in
Verbindung mit guten Testverfahren verwenden musst, um dein Vertrauen in den
von dir geschriebenen unsicheren Code zu erhöhen. Miri deckt auch nicht alle
Möglichkeiten ab, in denen dein Code unsauber sein kann.

Mit anderen Worten: Wenn Miri ein Problem _findet_, weißt du, dass es einen
Fehler gibt, aber nur weil Miri _keinen_ Fehler findet, heißt das nicht, dass
kein Problem vorhanden ist. Es kann allerdings eine Menge finden. Versuche, es
auf die anderen Beispiele mit unsicherem Code in diesem Kapitel anzuwenden und
sieh, was es sagt!

Mehr über Miri erfährst du in seinem [GitHub-Repository][miri].

### Unsicheren Code verwenden

Die Verwendung von `unsafe` für eine der fünf gerade besprochenen Superkräfte
ist nicht falsch oder gar verpönt, aber es ist kniffliger, `unsafe` Code
korrekt zu schreiben, weil der Compiler nicht helfen kann, die
Speichersicherheit aufrechtzuerhalten. Wenn du einen Grund hast, `unsafe` Code
zu verwenden, kannst du dies tun, und die explizite `unsafe`-Annotation macht
es einfacher, die Quelle von Problemen aufzuspüren, wenn sie auftreten. Wann
immer du unsicheren Code schreibst, kannst du Miri verwenden, um dich zu
vergewissern, dass der von dir geschriebene Code die Rust-Regeln einhält.

Wenn du dich eingehender mit der effektiven Arbeit mit unsicherem Rust befassen
möchtest, lies den offiziellen Rust-Leitfaden zum Thema `unsafe`:
[Rustonomicon][nomicon]

[ABI]: https://doc.rust-lang.org/nightly/reference/items/external-blocks.html#abi
[dangling-references]: ch04-02-references-and-borrowing.html#hängende-referenzen
[constants]: ch03-01-variables-and-mutability.html#konstanten-deklarieren
[send-and-sync]: ch16-04-extensible-concurrency-sync-and-send.html
[miri]: https://github.com/rust-lang/miri
[nightly]: appendix-07-nightly-rust.html
[nomicon]: https://doc.rust-lang.org/nomicon/
[the-slice-type]: ch04-03-slices.html
[unions]: https://doc.rust-lang.org/reference/items/unions.html
[unsafe-call]: #aufrufen-einer-unsicheren-funktion-oder-methode
