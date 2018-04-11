# Der Stack und der Heap

Rust operiert auf einer sehr niedrigen Ebene im System.
Wenn du bereits Erfahrung mit Programmiersprachen hast,
bei denen Speicherverwaltung automatisiert wird,
dann sind dir eventuell einige Aspekte einer Systemsprache noch nicht vertraut.
Das wichtigste ist, wie Speicher funktioniert, mit Stack und Heap.
Wenn dir Speicherallokation in C-artigen Sprachen bereits vertraut ist,
dann sieh dieses Kapitel als Auffrischung.
Wenn nicht, dann lernst du hier Grundlagen, aus der Sicht von Rust.

## Speicherverwaltung

Die beiden Begriffe Stack und Heap beschreiben unterschiedliche Bereiche im Arbeitsspeicher und helfen uns dabei zu unterscheiden wann Speicher alloziert und dealloziert wird.

Hier zum Vergleich:

Der Stack ist sehr schnell und daher der Ort an dem Rust standardmäßig Speicher alloziert.
Der Speicher im Stack ist allerdings nur lokal innerhalb einer Funktion verfügbar.
Der Heap, auf der anderen Seite, ist langsamer, wird explizit für von deinem Programm alloziert aber ist dafür global erreichbar und hat prinzipiell keine Größenbeschränkung.


## Der Stack

*(engl. stack = **„Der Stapel“** )*

Nehmen wir mal ein Beispiel:

```rust
fn main() {
    let x = 42;
}
```

Dieses Programm besteht nur aus einer Variablenzuweisung, `x`.
Der Speicher für `x` muss irgendwo alloziert werden.
Rust ‚Stack-Alloziert‘ standardmäßig, das heißt Werte landen auf dem Stack.
Was heißt das?

Wenn eine Funktion aufgerufen wird, dann wird für jede ihrer lokalen Variablen, und etwas Zusatzinformation, Speicher auf ihrem Stack, dem Stackframe, reserviert.
Für diese Tutorial ignorieren wir die Zusatzinformationen erst einmal.
Wenn `main()` also ausgeführt wird, dann allozieren wir einen einzelnen 32-bit Integer auf dem Stackframe, das passiert hier ganz automatisch.
Wenn die Funktion terminiert wird der Stackframe freigegeben.
Auch vollautomatisch.

Das ist alles, für diese kleine Beispiel.
Der Kernpunkt an dieser Lektion ist, dass Stackallokation sehr sehr schnell ist,
da wir bereits vor dem Start des Programms die lokalen Variablen kennen und daher den Speicher für sie auch schon ganz am Anfang auf einmal reservieren können.
Da alle lokalen Variablen nach Ende der Funktion nicht mehr benötigt werden, können wir sie auch alle auf einmal wieder freigeben.

Der Nachteil hier ist jedoch, dass wir die Werte der Variablen nicht länger als für die Dauer einer einzelnen Funktion vorhalten können.
Dafür gibt es dann den Heap.

Doch was heißt Stack eigentlich.
Dafür hier ein etwas umfangreicheres Beispiel:


```rust
fn foo() {
    let y = 5;
    let z = 100;
}

fn main() {
    let x = 42;

    foo();
}
```

Dieses Programm hat insgesamt drei Variablen: zwei in `foo()` und eine in `main()`.
Just vor dem Aufruf von `main()` wird ein Integer auf deren Stack alloziert.
Die Sicht deines Betriebssystem auf den Speicher entspricht im Prinzip einer langen Liste von Adressen, von 0 bis `n`.
Wobei `n` von der Größe des Arbeitsspeichers abhängt.
Wenn du zum Beispiel nur 1 Gigabyte RAM haben solltest, ist `n` `1,073,741,823` (2<sup>30</sup>-1).

Hier eine Darstellung des Stackframes:

| Adresse | Name | Wert  |
|---------|------|-------|
| 0       | x    | 42    |

Wir haben `x` auf Adresse `0`, mit dem Wert `42`.

Wenn nun `foo()` aufgerufen wird, wird ein weiterer Stackframe alloziert:

Daher auch der Begriff „Stack“ = „Stapel“,
es wird immer etwas oben drauf gelegt und auch ausschließlich von oben wieder herunter genommen.
Wie bei einem Stapel Teller.
Solange `foo()` läuft, ist auch `main()` noch nicht beendet und der Speicher beider Funktionen ist noch vergeben.
Der Speicher von `main()` kann noch nicht freigegeben werden bevor `foo()` noch nicht beendet ist.
Jedoch kann `foo()` auch nicht direkt auf den Speicher von `main()` zugreifen.

| Adresse | Name | Wert  |
|---------|------|-------|
| 2       | z    | 100   |
| 1       | y    | 5     |
| 0       | x    | 42    |

Da `0` bereits im erst Stackframe vergeben war, verwendet `foo()` nun Adressen `1` und `2`. Der Stapel wächst sprichwörtlich nach oben mit jedem Funktionsaufruf.

Die Adressen `0` bis `2` sind allerdings rein zur Illustration gewählt,
im tatsächlichen Speicher hätten diese Adressen andere Werte und wären auch nicht direkt aufeinanderfolgend.

Nachdem `foo()` beendet ist wird sein Frame wieder vom Stapel genommen und wir sind wieder zurück bei:

| Adresse | Name | Wert  |
|---------|------|-------|
| 0       | x    | 42    |

Und dann, nachdem `main()` ebenfalls fertig ist wird auch diese Adresse wieder freigegeben. Ganz einfach!

Ein drittes Beispiel:

```rust
fn bar() {
    let i = 6;
}

fn foo() {
    let a = 5;
    let b = 100;
    let c = 1;

    bar();
}

fn main() {
    let x = 42;

    foo();
}
```

Als erstes `main()`:

| Adresse | Name | Wert  |
|---------|------|-------|
| 0       | x    | 42    |

`main()` ruft `foo()` auf:

| Adresse | Name | Wert  |
|---------|------|-------|
| 3       | c    | 1     |
| 2       | b    | 100   |
| 1       | a    | 5     |
| 0       | x    | 42    |

Dann ruft `foo()` `bar()` auf:

| Adresse | Name | Wert  |
|---------|------|-------|
| 4       | i    | 6     |
| 3       | c    | 1     |
| 2       | b    | 100   |
| 1       | a    | 5     |
| 0       | x    | 42    |

Puh! Unser Stapel wächst in die Höhe.

Nach dem `bar()` fertig ist, wird sein Stackframe dealloziert und es bleiben nur der von `foo()` und `main()`:

| Adresse | Name | Wert  |
|---------|------|-------|
| 3       | c    | 1     |
| 2       | b    | 100   |
| 1       | a    | 5     |
| 0       | x    | 42    |

Und dann wird `foo()` auch noch fertig und wir haben nur noch `main()`:

| Adresse | Name | Wert  |
|---------|------|-------|
| 0       | x    | 42    |

Wir sind fertig.
Kriegst du ein Gefühl für die Tellerstapel?
Wir legen einen drauf und nehmen einen wieder runter,
wir nehmen nie was aus der Mitte raus.

## Der Heap

*(engl. heap = **„Der Haufen“** )*

Wie bereits erwähnt können Funktionen nicht auf die lokalen variablen von anderen Funktionen zugreifen.
Manchmal möchte man jedoch etwas von einer Funktion an eine andere übergeben oder länger als für die Laufzeit einer Funktion im Speicher behalten.
Dafür haben wir den Heap.

In Rust allozieren wir Speicher auf dem Heap mit einer [`Box<T>`][box].
Hier ein Beispiel:

```rust
fn main() {
    let x = Box::new(5);
    let y = 42;
}
```

[box]: http://doc.rust-lang.org/stable/std/boxed/

Was also diesmal in `main()` passiert ist folgendes:

| Adresse | Name | Wert   |
|---------|------|--------|
| 1       | y    | 42     |
| 0       | x    | ?????? |

Wir allozieren Speicher für zwei Variablen auf dem Stack, wie gehabt.
`y` ist `42`, aber was ist `x`?
Nun, `x` ist ein `Box<i32>`, und `Box`en allozieren ihren Speicher auf dem Heap.
Der eigentliche Wert dieser Box ist ein `struct` das eine Adresse zu einem Stück Speicher (genug für einen `i32`) auf dem Heap beinhaltet.
Wenn wir nun die Funktion ausführen und `Box::new()` aufrufen,
wird der Speicher auf dem Heap alloziert und `5` dorthin geschrieben.
Der Speicher sieht also eigentlich etwa so aus:


| Adresse              | Name | Wert                   |
|----------------------|------|------------------------|
| (2<sup>30</sup>) - 1 |      | 5                      |
| ...                  | ...  | ...                    |
| 1                    | y    | 42                     |
| 0                    | x    | → (2<sup>30</sup>) - 1 |


Wir haben (2<sup>30</sup>) - 1 Adressen in unserem imaginären 1GB RAM.
Da der Stack von 0 nach oben wächst ist es am einfachsten die Adressen von Oben nach unten für den Heap zu verwenden.
Der erste Wert steht also an der höchsten Stelle im Speicher.
Das `struct` auf `x` hat einen [raw Zeiger](Raw_Zeiger.html) auf die Stelle an der wir den Speicher auf dem Heap alloziert haben, also den Wert (2<sup>30</sup>) - 1.

Wir habe noch nicht wirklich viel darüber gesprochen, was es eigentlich bedeutet in diesen Kontexten Speicher zu allozieren und zu deallozieren.
Das zu vertiefen würde den Rahmen dieses Tutorials sprengen,
aber was wichtig ist mitzunehmen, ist dass der Heap nicht einfach nur ein von oben nach unten wachsender Stack ist.
Im Gegensatz zum Stack muss der Heap nicht in einer festen Reihenfolge alloziert und freigegeben werden.
Dadurch kann er allerdings Löcher haben.
Dazu wird es später ein Beispiel geben.
Hier erst mal ein kleines Diagramm des Speicherlayouts eines Programms das schon ein Weilchen lief:

| Adresse              | Name | Wert                   |
|----------------------|------|------------------------|
| (2<sup>30</sup>) - 1 |      | 5                      |
| (2<sup>30</sup>) - 2 |      |                        |
| (2<sup>30</sup>) - 3 |      |                        |
| (2<sup>30</sup>) - 4 |      | 42                     |
| ...                  | ...  | ...                    |
| 3                    | y    | → (2<sup>30</sup>) - 4 |
| 2                    | y    | 42                     |
| 1                    | y    | 42                     |
| 0                    | x    | → (2<sup>30</sup>) - 1 |

In diesem Fall haben wir 4 Werte auf dem Heap alloziert, aber deallozieren zwei davon.
Es gibt eine Lücke zwischen (2<sup>30</sup>) - 1 und (2<sup>30</sup>) - 4,
die momentan nicht benutzt wird.
Die genauen Details wie und warum das passiert hängen davon ab mit welcher Strategie man seinen Heap verwaltet.
Verschiedene Programme können unterschiedliche Speicherallokatoren verwenden,
also Bibliotheken, die einem das abnehmen.
Rust Programme verwenden [jemalloc][jemalloc].

[jemalloc]: http://www.canonware.com/jemalloc/

Zurück zu unserem Beispiel.
Da sich diese Werte auf dem Heap befinden, können sie länger existieren als die Funktion die die Box erzeugt hat.
In diesem Fall jedoch nicht.[^1]
Wenn eine Funktion endet wird ihr Stackframe freigegeben.
`Box<T>` hat einen Trick: [Drop][drop].
Es implementiert `Drop` und gibt sobald ihr Wert auf dem Stack freigegeben wird ebenfalls den Speicher auf dem Heap frei.
Geil! Wenn also `x` verschwindet gibt es vorher seinen Speicher auf dem Heap frei:

| Adresse | Name | Wert   |
|---------|------|--------|
| 1       | y    | 42     |
| 0       | x    | ?????? |

[drop]: Drop.html


Sobald der Stackframe verschwindet, wird der gesamte verwendete Speicher freigegeben.

## Argumente und Ausleihen

Wir hatten bereits ein paar grundlegende Beispiele für Stack und Heap,
aber was ist mit Funktionsargumenten und Ausleihen?

```rust
fn foo(i: &i32) {
    let z = 42;
}

fn main() {
    let x = 5;
    let y = &x;

    foo(y);
}
```


Wenn wir `main()` betreten sieht der Speicher so aus:

| Adresse | Name | Wert   |
|---------|------|--------|
| 1       | y    | → 0    |
| 0       | x    | 5      |

`x` ist einfach wieder `5` und `y` ist eine Referenz auf `x`.
Sein Wert ist also die Speicheradresse von `x`, in diesem Fall also `0`.

Was passiert wenn wir nun `foo()` aufrufen und `y` übergeben?

| Adresse | Name | Wert   |
|---------|------|--------|
| 3       | z    | 42     |
| 2       | i    | → 0    |
| 1       | y    | → 0    |
| 0       | x    | 5      |

Stackframes sind nicht nur für lokale Zuweisungen, sie sind auch für Argumente gedacht.
In diesem Fall also brauchen wir sowohl `i`, das Argument und `z`, die lokale Variable.
`i` ist die Kopie des Arguments `y`, also auch `0`.

Das ist der Grund dafür, dass man ausgeliehenen Speicher nicht deallozieren kann. Wenn wir nun `x` freigeben würden, würden `y` und `i` auf ungültigen Speicher zeigen.
Das ist in Sprachen wie C möglich, aber nicht in Rust.

## Ein komplexes Beispiel

Gehen wir das hier mal Schritt für Schritt durch:

```rust
fn foo(x: &i32) {
    let y = 10;
    let z = &y;

    baz(z);
    bar(x, z);
}

fn bar(a: &i32, b: &i32) {
    let c = 5;
    let d = Box::new(5);
    let e = &d;

    baz(e);
}

fn baz(f: &i32) {
    let g = 100;
}

fn main() {
    let h = 3;
    let i = Box::new(20);
    let j = &h;

    foo(j);
}
```

Als erstes rufen wir `main()` auf:


| Adresse              | Name | Wert                   |
|----------------------|------|------------------------|
| (2<sup>30</sup>) - 1 |      | 20                     |
| ...                  | ...  | ...                    |
| 2                    | j    | → 0                    |
| 1                    | i    | → (2<sup>30</sup>) - 1 |
| 0                    | h    | 3                      |

Wir allozieren Speicher für `j`, `i` und `h`.
`i` liegt auf dem Heap, beinhaltet also einen Adresswert dort hin.

Als nächstes wird am Ende von `main()` `foo()` aufgerufen:


| Adresse              | Name | Wert                   |
|----------------------|------|------------------------|
| (2<sup>30</sup>) - 1 |      | 20                     |
| ...                  | ...  | ...                    |
| 5                    | z    | → 4                    |
| 4                    | y    | 10                     |
| 3                    | x    | → 0                    |
| 2                    | j    | → 0                    |
| 1                    | i    | → (2<sup>30</sup>) - 1 |
| 0                    | h    | 3                      |

Speicher wird für `x`, `y` und `z` belegt.
Das Argument `x` hat den gleichen Wert wie `j`, da wird das ja übergeben haben, ein Zeiger auf die Adresse `0`, da `j` auf `h` zeigt.

Danach ruft `foo()` `baz()` auf und übergibt `z`:

| Adresse              | Name | Wert                   |
|----------------------|------|------------------------|
| (2<sup>30</sup>) - 1 |      | 20                     |
| ...                  | ...  | ...                    |
| 7                    | g    | 100                    |
| 6                    | f    | → 4                    |
| 5                    | z    | → 4                    |
| 4                    | y    | 10                     |
| 3                    | x    | → 0                    |
| 2                    | j    | → 0                    |
| 1                    | i    | → (2<sup>30</sup>) - 1 |
| 0                    | h    | 3                      |

Wir haben Speicher für `f` und `g` alloziert.
`baz()` ist sehr kurz und wenn es vorbei ist wird sein Stackframe freigegeben:

| Adresse              | Name | Wert                   |
|----------------------|------|------------------------|
| (2<sup>30</sup>) - 1 |      | 20                     |
| ...                  | ...  | ...                    |
| 5                    | z    | → 4                    |
| 4                    | y    | 10                     |
| 3                    | x    | → 0                    |
| 2                    | j    | → 0                    |
| 1                    | i    | → (2<sup>30</sup>) - 1 |
| 0                    | h    | 3                      |

Danach ruft `foo()` `bar()` mit `x` und `z` auf:

| Adresse              | Name | Wert                   |
|----------------------|------|------------------------|
| (2<sup>30</sup>) - 1 |      | 20                     |
| (2<sup>30</sup>) - 2 |      | 5                      |
| ...                  | ...  | ...                    |
| 10                   | e    | → 9                    |
| 9                    | d    | → (2<sup>30</sup>) - 2 |
| 8                    | c    | 5                      |
| 7                    | b    | → 4                    |
| 6                    | a    | → 0                    |
| 5                    | z    | → 4                    |
| 4                    | y    | 10                     |
| 3                    | x    | → 0                    |
| 2                    | j    | → 0                    |
| 1                    | i    | → (2<sup>30</sup>) - 1 |
| 0                    | h    | 3                      |

Wir allozieren also einen weiteren Wert auf dem Heap und müssen eins von (2<sup>30</sup>) - 1 abziehen.
Das ist einfacher das zu schreiben als `1,073,741,822` ☺.
Jedenfalls, hier die Variablen wie gewohnt.

Am Ende von `bar()` wird wieder `baz()` aufgerufen:

| Adresse              | Name | Wert                   |
|----------------------|------|------------------------|
| (2<sup>30</sup>) - 1 |      | 20                     |
| (2<sup>30</sup>) - 2 |      | 5                      |
| ...                  | ...  | ...                    |
| 12                   | g    | 100                    |
| 11                   | f    | → 9                    |
| 10                   | e    | → 9                    |
| 9                    | d    | → (2<sup>30</sup>) - 2 |
| 8                    | c    | 5                      |
| 7                    | b    | → 4                    |
| 6                    | a    | → 0                    |
| 5                    | z    | → 4                    |
| 4                    | y    | 10                     |
| 3                    | x    | → 0                    |
| 2                    | j    | → 0                    |
| 1                    | i    | → (2<sup>30</sup>) - 1 |
| 0                    | h    | 3                      |

So, jetzt haben wir den tiefsten Punkt in unserer Schachtelung erreicht,
Glückwunsch, du bist bist jetzt noch dran geblieben.

Nachdem `baz()` nun zu Ende ist können wir `f` und `g` wegwerfen:

| Adresse              | Name | Wert                   |
|----------------------|------|------------------------|
| (2<sup>30</sup>) - 1 |      | 20                     |
| (2<sup>30</sup>) - 2 |      | 5                      |
| ...                  | ...  | ...                    |
| 10                   | e    | → 9                    |
| 9                    | d    | → (2<sup>30</sup>) - 2 |
| 8                    | c    | 5                      |
| 7                    | b    | → 4                    |
| 6                    | a    | → 0                    |
| 5                    | z    | → 4                    |
| 4                    | y    | 10                     |
| 3                    | x    | → 0                    |
| 2                    | j    | → 0                    |
| 1                    | i    | → (2<sup>30</sup>) - 1 |
| 0                    | h    | 3                      |

Danach endet `bar()`. `d` ist hier ja eine `Box<T>`, also geben wir noch den Speicher an der Adresse frei, auf die sie zeigt:(2<sup>30</sup>) - 2.


| Adresse              | Name | Wert                   |
|----------------------|------|------------------------|
| (2<sup>30</sup>) - 1 |      | 20                     |
| ...                  | ...  | ...                    |
| 5                    | z    | → 4                    |
| 4                    | y    | 10                     |
| 3                    | x    | → 0                    |
| 2                    | j    | → 0                    |
| 1                    | i    | → (2<sup>30</sup>) - 1 |
| 0                    | h    | 3                      |

Dann ist `foo()` fertig:

| Adresse              | Name | Wert                   |
|----------------------|------|------------------------|
| (2<sup>30</sup>) - 1 |      | 20                     |
| ...                  | ...  | ...                    |
| 2                    | j    | → 0                    |
| 1                    | i    | → (2<sup>30</sup>) - 1 |
| 0                    | h    | 3                      |

Und endlich auch `main()`.
Hiernach wir der Rest aufgeräumt.
Sobald `i` ge`Drop`pt wird, wird auch der Rest vom Heap geleert.

## Was machen andere Sprachen?

Viele Sprachen verwenden heutzutage einen Garbage Collector.
Das hat einige Vorteile, die Beschreibung würde allerdings den Rahmen dieses Tutorials sprengen.
Dort hat man keinen manuellen Einfluss darauf, ob Speicher auf dem Heap oder Stack verwendet wird.
Stattdessen liegt fast alles auf dem Heap und der Garbage Collector hält regelmäßig das Programm kurz an und räumt auf.

Bei Sprachen wie C/C++ kann man zwischen Stack und Heap unterscheiden, muss allerdings manuell seinen Speicher aufräumen.
Hier gibt es bereits moderne Mechanismen, u.a. SmartPointer, die ähnliche Charakteristika haben wie Rust `Box<T>` etc, Konzepte wie „Besitz“ und „Ausleihen“ sind allerdings noch kein Kernfeature der Sprache.

## Was soll ich benutzen?

Der Stack ist schneller und einfacher zu handhaben, wofür also den Heap?
Ein wichtiger Grund ist, dass Stack-allozieren alleine nur LIFO[^2]-Verhalten bietet.
Heapallokation ist vielseitiger und erlaubt schnelles Übergeben von großen Werten ohne Kopieren.

Allgemein ist Stackallokation zu bevorzugen, weshalb Rust standardmäßig den Stack nutzt, das ist grundlegend einfacher und meistens effizienter.

## Laufzeiteffizienz

Speicher auf dem Stack verwalten ist trivial:
Die Maschine inkrementiert und dekrementiert einfach den sogenannten *Stack-Pointer*.
Speicher auf dem Heap verwalten ist nicht trivial:
Speicher auf dem Heap kann beliebig freigegeben werden und jeder Block auf dem Heap kann eine beliebige Größe haben. Es ist allgemein schwerer, wiederverwendbare Bereiche zu identifizieren.

Um hier noch tiefer einzusteigen kannst du [diese Paper][wilson] (englisch) lesen oder Grundstudiums-Vorlesungen „Betriebssysteme“ der Uni deiner Wahl besuchen :D

[wilson]: http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.143.4688

## Semantische Bedeutung

Stackallokation beeinflusst nicht nur Rust selbst, sondern auch das mentale Modell des Entwicklers.
LIFO-Semantik definiert Rusts automatische Speicherverwaltung.
Selbst die Freigabe von Heap-allozierten Boxen mit einem einzelnen Besitzer wird von der LIFO-Semantik des Stacks bestimmt, wie bereits oben demonstriert.
Nicht-LIFO-Semantik würde zwar mehr Flexibilität bieten,
jedoch könnte dann nicht automatisch zur Compile-Zeit abgeleitet werden,
wann Speicher freigegeben werden kann.
Ein Compiler müsste sich auf dynamische Protokolle, potentiell außerhalb der Sprache selbst, verlassen (zum Beispiel *reference counting* wie in `Rc<T>` und `Arc<T>`).

Wenn man es übertreibt kann man sagen, dass die erhöhte Freiheit durch Heapallokation mit signifikanten Kosten verbunden ist, entweder in Form von Laufzeit-Performance (z. B. durch einen Garbage Collector) oder durch erhöhten Aufwand für den Entwickler in Form von expliziten Mechanismen zur Speicherverwaltung (`new`, `delete`), welche Rust nicht vorsieht.

[^1]: Wir können den Speicher länger leben lassen indem wir den Besitz übertragen das heißt manchmal ‚moving out of the box‘. Komplexere Beispiele folgen später.

[^2]: Last in first out.
