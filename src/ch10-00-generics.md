# Generische Typen, Merkmale (traits) und Lebensdauer

Jede Programmiersprache verfügt über Werkzeuge, mit denen die Duplizierung von
Konzepten (duplication of concepts) effektiv gehandhabt werden kann. In Rust
ist ein solches Werkzeug der *generische Datentyp* (generics). Generische
Datentypen sind abstrakte Stellvertreter für konkrete Typen oder andere
Eigenschaften. Wenn wir Code schreiben, können wir das Verhalten generischer
Datentypen oder ihre Beziehung zu anderen generischen Datentypen ausdrücken,
ohne zu wissen, was an ihrer Stelle beim Kompilieren und Ausführen des Codes
stehen wird.

Ähnlich wie eine Funktion Parameter mit unbekannten Werten entgegennimmt, um
den gleichen Code auf mehreren konkreten Werten auszuführen, können Funktionen
Parameter irgendeines generischen Typs anstelle eines konkreten Typs, wie `i32`
oder `String`, haben. Tatsächlich haben wir generische Datentypen bereits in
Kapitel 6 mit `Option<T>`, in Kapitel 8 mit `Vec<T>` und `HashMap<K, V>` und in
Kapitel 9 mit `Result<T, E>` verwendet. In diesem Kapitel erfährst du, wie du
deine eigenen Typen, Funktionen und Methoden mit generischen Datentypen
definieren kannst!

Zunächst werden wir uns anschauen, wie eine Funktion extrahiert werden kann, um
Code-Duplizierung zu reduzieren. Danach verwenden wir dieselbe Technik, um aus
zwei Funktionen, die sich nur im Datentyp ihrer Parameter unterscheiden, eine
generische Funktion zu machen. Wir werden auch erklären, wie generische Typen
in Struktur- (struct) und Aufzählungsdefinitionen (enum) verwendet werden
können.

Dann wirst du lernen, wie man *Merkmale* (traits) verwendet, um Verhalten auf
generische Weise zu definieren. Du kannst Merkmale mit generischen Typen
kombinieren, um einen generischen Typ auf solche Typen einzuschränken, die ein
bestimmtes Verhalten aufweisen, im Gegensatz zu einem beliebigen Typ.

Schließlich werden wir die *Lebensdauer* (lifetimes) besprechen, eine Spielart
generischer Typen, die dem Compiler Informationen darüber gibt, wie
Referenzen zueinander in Beziehung stehen. Die Lebensdauer erlaubt es uns, in
vielen Situationen Werte auszuleihen und gleichzeitig dem Compiler die
Möglichkeit zu geben, die Gültigkeit der Referenzen zu überprüfen.

## Duplikate entfernen durch Extrahieren einer Funktion

Bevor wir in die Syntax der generischen Typen eintauchen, wollen wir uns
zunächst ansehen, wie man Duplikate, die keine generischen Typen betreffen,
durch Extrahieren einer Funktion entfernt. Dann werden wir diese Technik
anwenden, um eine generische Funktion zu extrahieren! Auf die gleiche Weise,
wie du doppelten Code erkennst, der zu einer Funktion extrahiert wird, wirst du
auch doppelten Code erkennen, der generische Typen verwenden kann.

Betrachte ein kurzes Programm, das die größte Zahl in einer Liste findet, wie
in Codeblock 10-1 gezeigt.

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let number_list = vec![34, 50, 25, 100, 65];

    let mut largest = number_list[0];

    for number in number_list {
        if number > largest {
            largest = number;
        }
    }

    println!("Die größte Zahl ist {}", largest);
#     assert_eq!(largest, 100);
}
```

<span class="caption">Codeblock 10-1: Code zum Finden der größten Zahl in einer
Liste von Zahlen</span>

Dieser Code enthält eine Liste von ganzen Zahlen in der Variablen `number_list`
und weist die erste Zahl der Liste einer Variablen namens `largest` zu. Dann
iteriert sie über alle Zahlen in der Liste und wenn die aktuelle Zahl größer
ist als die in `largest` gespeicherte Zahl, ersetzt sie die Zahl in dieser
Variablen. Wenn die aktuelle Zahl jedoch kleiner oder gleich der größten bisher
gefundenen Zahl ist, ändert sich die Variable nicht, und der Code geht zur
nächsten Zahl in der Liste weiter. Nach dem Durchlaufen aller Zahlen in der
Liste sollte `largest` die größte Zahl enthalten, in diesem Fall 100.

Um die größte Zahl in zwei verschiedenen Zahlenlisten zu finden, können wir den
Code in Codeblock 10-1 duplizieren und dieselbe Logik an zwei verschiedenen
Stellen im Programm verwenden, wie in Codeblock 10-2 gezeigt.

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let number_list = vec![34, 50, 25, 100, 65];

    let mut largest = number_list[0];

    for number in number_list {
        if number > largest {
            largest = number;
        }
    }

    println!("Die größte Zahl ist {}", largest);

    let number_list = vec![102, 34, 6000, 89, 54, 2, 43, 8];

    let mut largest = number_list[0];

    for number in number_list {
        if number > largest {
            largest = number;
        }
    }

    println!("Die größte Zahl ist {}", largest);
}
```

<span class="caption">Codeblock 10-2: Code zum Auffinden der größten Zahl in
*zwei* Zahlenlisten</span>

Obwohl dieser Code funktioniert, ist das Duplizieren von Code mühsam und
fehleranfällig. Außerdem müssen wir den Code an mehreren Stellen aktualisieren,
wenn wir ihn ändern wollen.

Um diese Redundanz zu eliminieren, können wir eine Abstraktion schaffen, indem
wir eine Funktion definieren, die auf einer beliebigen Liste ganzer Zahlen
operiert, die ihr als Parameter übergeben wird. Diese Lösung macht unseren Code
klarer und lässt uns das Konzept, die größte Zahl in einer Liste zu finden,
abstrakter ausdrücken.

In Codeblock 10-3 extrahierten wir den Code, der die größte Zahl findet, in
eine Funktion namens `largest`. Im Unterschied zum Code in Codeblock 10-1, der
die größte Zahl in nur einer bestimmten Liste finden kann, kann dieses Programm
die größte Zahl in zwei verschiedenen Listen finden.

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn largest(list: &[i32]) -> i32 {
    let mut largest = list[0];

    for &item in list {
        if item > largest {
            largest = item;
        }
    }

    largest
}

fn main() {
    let number_list = vec![34, 50, 25, 100, 65];

    let result = largest(&number_list);
    println!("Die größte Zahl ist {}", result);
#     assert_eq!(result, 100);

    let number_list = vec![102, 34, 6000, 89, 54, 2, 43, 8];

    let result = largest(&number_list);
    println!("Die größte Zahl ist {}", result);
#     assert_eq!(result, 6000);
}
```

<span class="caption">Codeblock 10-3: Abstrahierter Code, um die größte Zahl in
zwei Listen zu finden</span>

Die Funktion `largest` hat einen Parameter `list`, der einen beliebigen
Anteilstyp von `i32`-Werten repräsentiert, die wir an die Funktion übergeben
könnten. Wenn wir die Funktion aufrufen, läuft der Code also auf den
spezifischen Werten, die wir übergeben. Mach dir vorerst keine Gedanken über
die Syntax der `for`-Schleife. Wir verweisen hier nicht auf eine Referenz auf
ein `i32`; wir machen einen Musterabgleich und destrukturieren jedes `&i32`,
das die `for`-Schleife erhält, sodass `item` innerhalb des Schleifenrumpfs ein
`i32` ist. Wir werden den Musterabgleich im Detail in [Kapitel 18][ch18]
behandeln.

Zusammenfassend hier die Schritte, die wir unternommen haben, um den Code aus
Codeblock 10-2 in Codeblock 10-3 zu überführen:

1. Identifiziere doppelten Code.
2. Extrahiere den doppelten Code in den Funktionskörper und spezifiziere die
   Eingabe- und Rückgabewerte dieses Codes in der Funktionssignatur.
3. Aktualisiere die beiden Instanzen des doppelten Codes, um stattdessen die
   Funktion aufzurufen.

Als Nächstes werden wir dieselben Schritte auf generische Datentypen anwenden,
um doppelten Code auf unterschiedliche Weise zu reduzieren. Ähnlich wie der
Funktionsrumpf auf einer abstrakten Liste anstelle spezifischer Werte arbeiten
kann, erlauben es generische Datentypen, auf abstrakten Typen zu arbeiten.

Nehmen wir zum Beispiel an, wir hätten zwei Funktionen: Eine, die das größte
Element in einem Anteilstyp mit `i32`-Werten findet, und eine, die das größte
Element in einem Anteilstyp mit `char`-Werten findet. Wie würden wir diese
Duplizierung beseitigen? Lass es uns herausfinden!

[ch18]: ch18-00-patterns.html
