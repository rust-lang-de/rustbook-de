# Generische Typen, Merkmale (traits) und Lebensdauer

Jede Programmiersprache verfügt über Werkzeuge, mit denen die Duplizierung von
Konzepten (duplication of concepts) effektiv gehandhabt werden kann. In Rust
ist ein solches Werkzeug der *generische Datentyp* (generics): Abstrakte
Stellvertreter für konkrete Typen oder andere Eigenschaften. Wir können das
Verhalten generischer Datentypen oder ihre Beziehung zu anderen generischen
Datentypen ausdrücken, ohne zu wissen, was an ihrer Stelle beim Kompilieren und
Ausführen des Codes stehen wird.

Funktionen können Parameter eines generischen Typs anstelle eines konkreten
Typs wie `i32` oder `String` annehmen, so wie eine Funktion Parameter mit
unbekannten Werten annimmt, um denselben Code auf mehrere konkrete Werte
anzuwenden. Tatsächlich haben wir generische Datentypen bereits in Kapitel 6
mit `Option<T>`, in Kapitel 8 mit `Vec<T>` und `HashMap<K, V>` und in Kapitel
9 mit `Result<T, E>` verwendet. In diesem Kapitel erfährst du, wie du deine
eigenen Typen, Funktionen und Methoden mit generischen Datentypen definieren
kannst!

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

Schließlich werden wir die *Lebensdauer* (lifetimes) besprechen: Eine Spielart
generischer Typen, die dem Compiler Informationen darüber gibt, wie
Referenzen zueinander in Beziehung stehen. Lebensdauern ermöglichen es uns, dem
Compiler genügend Informationen über ausgeliehene Werte zu geben, sodass er
sicherstellen kann, dass Referenzen in mehr Situationen gültig sind, als er es
ohne unsere Hilfe könnte.

## Duplikate entfernen durch Extrahieren einer Funktion

Mit Hilfe von generischen Typen können wir spezifische Typen durch einen
Platzhalter ersetzen, der mehrere Typen repräsentiert, um Code-Duplizierung zu
vermeiden. Bevor wir uns mit der generischen Syntax befassen, wollen wir uns
zunächst ansehen, wie man Duplikate auf eine Weise entfernt, die keine
generischen Typen erfordert, indem man eine Funktion extrahiert, die
spezifische Werte durch einen Platzhalter ersetzt, der mehrere Werte
repräsentiert. Dann wenden wir die gleiche Technik an, um eine generische
Funktion zu extrahieren! Wenn du dir ansiehst, wie du doppelten Code
erkennst, den du in eine Funktion extrahieren kannst, wirst du beginnen,
doppelten Code zu erkennen, der generische Typen verwenden kann.

Wir beginnen mit dem kurzen Programm in Codeblock 10-1, das die größte Zahl in
einer Liste findet.

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let number_list = vec![34, 50, 25, 100, 65];

    let mut largest = &number_list[0];

    for number in &number_list {
        if number > largest {
            largest = number;
        }
    }

    println!("Die größte Zahl ist {largest}");
#     assert_eq!(*largest, 100);
}
```

<span class="caption">Codeblock 10-1: Finden der größten Zahl in einer Liste
von Zahlen</span>

Wir speichern eine Liste von ganzen Zahlen in der Variablen `number_list` und
weisen eine Referenz der ersten Zahl der Liste einer Variablen namens `largest`
zu. Dann iterieren wir über alle Zahlen in der Liste und wenn die aktuelle Zahl
größer als die in `largest` gespeicherte Zahl ist, ersetzen wir die Referenz in
dieser Variablen. Wenn die aktuelle Zahl jedoch kleiner oder gleich der größten
bisher gefundenen Zahl ist, ändert sich die Variable nicht, und der Code geht
zur nächsten Zahl in der Liste weiter. Nach dem Durchlaufen aller Zahlen in der
Liste sollte `largest` auf die größte Zahl referenzieren, in diesem Fall 100.

Wir haben nun die Aufgabe bekommen, die größte Zahl in zwei verschiedenen
Zahlenlisten zu finden. Zu diesem Zweck können wir den Code in Codeblock 10-1
duplizieren und dieselbe Logik an zwei verschiedenen Stellen im Programm
verwenden, wie in Codeblock 10-2 gezeigt.

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let number_list = vec![34, 50, 25, 100, 65];

    let mut largest = &number_list[0];

    for number in &number_list {
        if number > largest {
            largest = number;
        }
    }

    println!("Die größte Zahl ist {largest}");

    let number_list = vec![102, 34, 6000, 89, 54, 2, 43, 8];

    let mut largest = &number_list[0];

    for number in &number_list {
        if number > largest {
            largest = number;
        }
    }

    println!("Die größte Zahl ist {largest}");
}
```

<span class="caption">Codeblock 10-2: Code zum Auffinden der größten Zahl in
*zwei* Zahlenlisten</span>

Obwohl dieser Code funktioniert, ist das Duplizieren von Code mühsam und
fehleranfällig. Außerdem müssen wir daran denken, den Code an mehreren Stellen
zu aktualisieren, wenn wir ihn ändern wollen.

Um diese Redundanz zu eliminieren, können wir eine Abstraktion schaffen, indem
wir eine Funktion definieren, die auf einer beliebigen Liste ganzer Zahlen
operiert, die ihr als Parameter übergeben wird. Diese Lösung macht unseren Code
klarer und lässt uns das Konzept, die größte Zahl in einer Liste zu finden,
abstrakter ausdrücken.

In Codeblock 10-3 extrahieren wir den Code, der die größte Zahl findet, in eine
Funktion namens `largest`. Dann rufen wir die Funktion auf, um die größte Zahl
in den beiden Listen aus Codeblock 10-2 zu finden. Wir könnten die Funktion
auch auf jede andere Liste von `i32`-Werten anwenden, die wir in Zukunft haben
könnten.

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn largest(list: &[i32]) -> &i32 {
    let mut largest = &list[0];

    for item in list {
        if item > largest {
            largest = item;
        }
    }

    largest
}

fn main() {
    let number_list = vec![34, 50, 25, 100, 65];

    let result = largest(&number_list);
    println!("Die größte Zahl ist {result}");
#     assert_eq!(*result, 100);

    let number_list = vec![102, 34, 6000, 89, 54, 2, 43, 8];

    let result = largest(&number_list);
    println!("Die größte Zahl ist {result}");
#     assert_eq!(*result, 6000);
}
```

<span class="caption">Codeblock 10-3: Abstrahierter Code, um die größte Zahl in
zwei Listen zu finden</span>

Die Funktion `largest` hat einen Parameter `list`, der einen beliebigen
Anteilstyp von `i32`-Werten repräsentiert, die wir an die Funktion übergeben
könnten. Wenn wir die Funktion aufrufen, läuft der Code also auf den
spezifischen Werten, die wir übergeben.

Zusammenfassend hier die Schritte, die wir unternommen haben, um den Code aus
Codeblock 10-2 in Codeblock 10-3 zu überführen:

1. Identifiziere doppelten Code.
2. Extrahiere den doppelten Code in den Funktionskörper und spezifiziere die
   Eingabe- und Rückgabewerte dieses Codes in der Funktionssignatur.
3. Aktualisiere die beiden Instanzen des doppelten Codes, um stattdessen die
   Funktion aufzurufen.

Als Nächstes werden wir dieselben Schritte auf generische Datentypen anwenden,
um doppelten Code zu reduzieren. Ähnlich wie der Funktionsrumpf auf einer
abstrakten Liste anstelle spezifischer Werte arbeiten kann, erlauben es
generische Datentypen, auf abstrakten Typen zu arbeiten.

Nehmen wir zum Beispiel an, wir hätten zwei Funktionen: Eine, die das größte
Element in einem Anteilstyp mit `i32`-Werten findet, und eine, die das größte
Element in einem Anteilstyp mit `char`-Werten findet. Wie würden wir diese
Duplizierung beseitigen? Lass es uns herausfinden!

[ch18]: ch18-00-patterns.html
