# Der Stack und der Heap

Rust operiert auf einer sehr niedrigen Ebene im System.
Wenn du bereits Erfahrung mit Programmiersprachen hast,
bei denen Speicherverwaltung automatisiert wird,
dann sind dir eventuell einige Aspekte einer Systemsprache noch nicht vertraut.
Das wichtigste ist, wie Speicher funktioniert, mit Stack und Heap.
Wenn dir Speicherallokation in C-artigen Sprachen bereits vertraut ist,
dann sieh dieses Kapitel als Auffrischung.
Wenn nicht, dann lernst du hier Grundlagen, aus der Sicht von Rust.

# Speicher Verwaltung

Die beiden Begriffe Stack und Heap beschreiben unterschiedliche Bereiche im Arbeitsspeicher und helfen uns dabei zu unterscheiden wann Speicher alloziert und dealloziert wird.

Hier zum Vergleich:

Der Stack ist sehr schnell und daher der Ort an dem Rust standardmäßig Speicher alloziert.
Der Speicher im Stack ist allerdings nur lokal innerhalb einer Funktion verfügbar.
Der Heap, auf der anderen Seite, ist langsamer, wird explizit für von deinem Programm alloziert aber ist dafür global erreichbar und hat prinzipiell keine Größenbeschränkung.


# Der Stack

*(engl. stack = **"Der Stapel"** )*

Nehmen wir mal ein Beispiel:

```rust
fn main() {
    let x = 42;
}
```

Dieses Programm besteht nur aus einer Variablenzuweisung, `x`.
Der Speicher für `x` muss irgendwo alloziert werden.
Rust ‘Stack-Alloziert‘ standardmäßig, das heißt Werte landen auf dem Stack.
Was heißt das?

Wenn eine Funktion aufgerufen wird, dann wird für jede ihrer lokalen Variablen, und etwas extra Information, Speicher auf ihrem Stack, dem Stackframe,  reserviert.
Für diese Tutorial ignorieren wir die extra Informationen erstmal.
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

Wenn nun `foo()` aufgerufen wird, wird ein weiter Stackframe alloziert:

Daher auch der Begriff "Stack" = "Stapel",
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
im tatsächlichen Speicher hätten diese Adressen andere werte und wären auch nicht direkt aufeinander folgend.

Nachdem `foo()` beendet ist wird sein frame wieder vom Stapel genommen und wird sind wieder zurück bei:

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

# Der Heap

*(engl. heap = **"Der Haufen"** )*

Wie bereits erwähnt können Funktionen nicht auf die lokalen variablen von anderen Funktionen Zugreifen.
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
Das `struct` auf `x` hat einen [Raw Pointer][Raw Zeiger] auf die Stelle an der wir den Speicher auf dem Heap alloziert haben, also den Wert (2<sup>30</sup>) - 1.

[Raw Zeiger]: book/Raw Zeiger.html
