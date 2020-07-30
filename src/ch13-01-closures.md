## Funktionsabschlüsse (Closures): Anonyme Funktionen die ihre Umgebung erfassen können


Rusts Funktionsabschlüsse sind anonyme Funktionen, die du in einer Variable
speichern oder anderen Funktionen als Argument übergibst. Du kannst einen 
Funktionsabschluss erstellen und dann in einem anderen Zusammenhang aufrufen
und auswerten. Im Gegensatz zu Funktionen können Funktionsabschlüsse auf Werte 
(values) in dem Gültigkeitsbereich (scope) in dem sie erstellt wurden zugreifen.
Wir werden im Folgenden zeigen, wie die Funktionalität von Funktionsabschlüssen
die Wiederverwendung von Code erlaubt und sein Verhalten anpassen kann.

### Mit Funktionsabschlüssen Abstraktionen von Verhalten erzeugen

Lass uns an einem Beispiel einer Situation arbeiten, in der es nützlich ist, einen
Funktionsabschluss zu speichern, um ihn später auszuführen. In dieser Zeit werden
wir über Typinferenz, Merkmale (traits) und die Syntax von Funktionsabschlüssen
sprechen.

Ziehe diese hypothetische Situation in Betracht: Wir arbeiten für ein Start-up 
das eine App entwickelt die benutzerdefinierte Work-out-Trainingspläne generiert.
Das Backend, ist in Rust geschrieben und der Algorithmus der die Trainingspläne
erzeugt, berücksichtigt viele Faktoren: das Alter des Benutzers, Body Mass Index,
Übungsvoreinstellungen, kürzlich erfolgte Work-outs und eine Zahl, die deren
Intensität festlegt. Der eigentliche Algorithmus ist für unser Beispiel nicht
wichtig. Bemerkenswert ist, dass die Berechnung ein paar Sekunden Zeit benötigt,
um die Wartezeit für den Benutzer zu verkürzen, wollen wir daher den Algorithmus
nur einmal aufrufen, und zwar, dann wenn es notwendig ist.

Den Aufruf des hypothetischen Algorithmus werden wir mit der Funktion
`simulated_expensive_calculation` die im Codeblock 13-1 gezeigt wird und
`calculating slowly...`, ausgibt, zwei Sekunden lang wartet und dann die Nummer
zurückgibt die wir übergeben haben.

<span class="filename">Dateiname: src/main.rs</span>

```rust
use std::thread;
use std::time::Duration;

fn simulated_expensive_calculation(intensity: u32) -> u32 {
    println!("calculating slowly...");
    thread::sleep(Duration::from_secs(2));
    intensity
}
```
<span class="caption">Codeblock 13-1: Eine Funktion die für eine hypothetische
Berechnung steht, die etwa 2 Sekunden Laufzeit benötigt.</span>

Als Nächstes folgt die Hauptfunktion `main`, welche die für unser Beispiel
relevanten Teile beinhalten wird. Diese Funktion stellt den Code dar, den die App
aufrufen wird, wenn ein Benutzer einen Trainingsplan anfordert. Da die
Interaktion mit dem Frontend für die Benutzung von Funktionsabschlüssen nicht
von Bedeutung ist, werden Werte die Eingaben (inputs) repräsentieren fest
einprogrammiert (hardcoded) und Ausgaben (outputs) einfach mit `print`
ausgegeben.

Das sind die benötigten Eingaben:

* Eine Intensitätszahl mit der die Benutzer festlegen können ob ein Training
    von leichter oder hoher Intensität sein soll.
* Eine Zufallszahl, die für Abwechslung im Trainingsplan sorgt.

Ausgegeben wird der empfohlene Trainingsplan. Codeblock 13-2 zeigt die
Hauptfunktion die wir benutzen.

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let simulated_user_specified_value = 10;
    let simulated_random_number = 7;

    generate_workout(simulated_user_specified_value, simulated_random_number);
}

```
<span class="caption">Codeblock 13-2: Eine Hauptfunktion `main` mit fest
einprogrammierten Werten die Eingaben simulieren und Zufallszahlen-Erzeugung</span>

Die Variable `simulated_user_specified_value` wurde als 10 fest einprogrammiert
und die Variable `simulated_random_number` zur Vereinfachung als 7. In einem
tatsächlichen Programm würden wir die Intensitäts-Zahl vom App-Frontend bekommen
und wir würden die `rand`-Kiste (-crate) benutzen um eine Zufallszahl zu
erzeugen, so wie wir es im Ratespiel Beispiel im Kapitel 2 bereits gemacht
haben. Die Hauptfunktion `main` ruft eine `generate_workout`-Funktion mit
simulierten Eingabewerten auf.

Nun da wir einen Kontext haben, lass uns zum Algorithmus kommen. Die Funktion
`generate_workout` im Codeblock 13-3 beinhaltet die Anwendungslogik der App
mit der wir in diesem Beispiel am häufigsten zu tun haben werden, die folgenden
Veränderungen werden diese Funktion betreffen.

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn generate_workout(intensity: u32, random_number: u32) {
    if intensity < 25 {
        println!(
            "Today, do {} pushups!",
            simulated_expensive_calculation(intensity)
        );
        println!(
            "Next, do {} situps!",
            simulated_expensive_calculation(intensity)
        );
    } else {
        if random_number == 3 {
            println!("Take a break today! Remember to stay hydrated!");
        } else {
            println!(
                "Today, run for {} minutes!",
                simulated_expensive_calculation(intensity)
            );
        }
    }
}
```
<span class="caption">Codeblock 13-3: Die Anwendungslogik, die Trainingspläne anhand
der Eingaben und durch Aufrufe der `simulated_expensive_calculation`-Funktion
ausgibt</span>

Der Code im Codeblock 13-3 ruft die langsame Berechnungsfunktion mehrfach auf.
Der erste `if`-Block verwendet `simulated_expensive_calculation` zweifach, das
`if` im äußeren `else` verwendet die Berechnung nicht und der Code im zweiten
`else` einmal.

Das gewünschte Verhalten der `generate_workout`-Funktion ist, als erstes zu
überprüfen, ob der Benutzer ein Training von niedriger Intensität möchte
(gekennzeichnet durch eine Zahl kleiner 25) oder ein Training von hoher
Intensität (eine Zahl größer oder gleich 25). 

Trainingspläne von niedriger Intensität empfehlen eine mittels simulierten 
Algorithmus berechnete Anzahl von Liegestützen und Sit-ups.

Falls der Benutzer ein Training von hoher Intensität anfordert, gibt es eine 
zusätzliche Logik: ergibt der Wert der ermittelten Zufallszahl 3, wird die App
dem Benutzer eine Trinkpause empfehlen, falls sich eine andere Zahl ergibt,
werden dem Benutzer einige Minuten Lauftraining, berechnet durch den simulierten 
Algorithmus, empfohlen.

Lass uns nun annehmen, dass das Datenforschungsteam einige Änderungen anordnet.
Das Programm funktioniert zwar soweit wie gewünscht, aber
`simulated_expensive_calculation` wird unnötigerweise mehrfach aufgerufen.
Wir sollen daher den Programmcode umformen und vereinfachen, damit die Funktion
nur noch einmal aufgerufen wird, wenn es notwendig ist.

#### Umformen (Refactoring) mit Funktionen

Wir könnten den Programmcode auf viele Arten umstrukturieren, aber zuerst, werden
wir versuchen den doppelten Aufruf der `simulated_expensive_calculation`-Funktion
in eine Variable zu extrahieren, wie es im Codeblock 13-4 gezeigt wird.

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn generate_workout(intensity: u32, random_number: u32) {
    let expensive_result = simulated_expensive_calculation(intensity);

    if intensity < 25 {
        println!("Today, do {} pushups!", expensive_result);
        println!("Next, do {} situps!", expensive_result);
    } else {
        if random_number == 3 {
            println!("Take a break today! Remember to stay hydrated!");
        } else {
            println!("Today, run for {} minutes!", expensive_result);
        }
    }
}
```

<span class="caption">Codeblock 13-4: Extraktion der `simulated_expensive_calculation`
zu einem Ort und Speichern des Ergebnisses in der `expensive_result`-Variable</span>

Diese Änderung vereinigt alle Aufrufe von `simulated_expensive_calculation` und
löst das Problem mit deren unnötigen doppelten Aufruf im ersten `if`-Block.
Leider rufen wir nun die Funktion auf und warten in jeden Fall auf das Ergebnis,
sogar im inneren `if`-Block der den Ergebniswert überhaupt nicht verwendet.

Wir wollen den Code an einer Stelle in unserem Programm definieren, aber
ausschließlich dort ausführen, wo wir das Ergebnis tatsächlich brauchen.

#### Umformen mit Funktionsabschlüssen um Programmcode zu speichern

Anstatt die `simulated_expensive_calculation`-Funktion vor den `if`-Blöcken
immer aufzurufen, können wir einen *Funktionsabschluss* definieren und diesen
anstatt des Resultates in einer Variable abspeichern, wie es im 
Codeblock 13-5 gezeigt wird. Eigentlich können wir den gesamten Rumpf von
`simulated_expensive_calculation` in einen Funktionsabschluss verschieben.

<span class="filename">Dateiname: src/main.rs</span>

```rust
let expensive_closure = |num| {
        println!("calculating slowly...");
        thread::sleep(Duration::from_secs(2));
        num
    };
```

<span class="caption">Codeblock 13-5: Definition eines Funktionsabschlusses 
und dessen Speicherung in der`expensive_closure`-Variable</span>

Die Definition des Funktionsabschlusses folgt dem `=` um es der Variable
`expensive_closure` zuzuweisen. Wir beginnen mit einem Paar vertikaler
Pipes (`|`), worin wir die Parameter des Funktionsabschlusses spezifizieren.
Diese Syntax wurde ausgewählt, da sie so ähnlich ist wie die Definition von
Funktionsabschlüssen in Ruby und Smalltalk. Dieser Funktionsabschluss hat ein
Parameter `num`: Sollten mehrere Parameter benötigt werden, würden wir diese von
Beistrichen getrennt schreiben `|param1, param2|`.

Hinter den Parameter, kommen geschweifte Klammern `{}` die den Rumpf des
Funktionsabschlusses beinhalten. Diese Klammern sind optional, wenn der Rumpf nur
einen Ausdruck beinhaltet. Zum Schluss benötigen wir, nach den geschweiften
Klammern, ein Semikolon aufgrund der `let`-Anweisung. Der Wert, der vom
Funktionsabschluss bei Aufruf zurückgegeben wird, ist der Wert der letzten Zeile
im Rumpf des Funktionsabschlusses (`num`), da diese Zeile nicht mit einem
Semikolon endet, wie auch bei Funktionsrümpfen.

Merke, die `let`-Anweisung bedeutet, dass `expensive_closure` die *Definition*
einer anonymen Funktion beinhaltet und nicht den *Wert des Ergebnisses* des
Aufrufs der anonymen Funktion. Wir benutzen, zur Erinnerung, einen
Funktionsabschluss da wir den Aufruf des Programmcodes an einer Stelle definieren
wollen, speichern und es später aufrufen wollen. Dieser Programmteil ist nun in
`expensive_closure` gespeichert.

Da wir nun einen Funktionsabschluss definiert haben, können wir nun den Code im
`if`-Block so ändern, damit der Funktionsabschluss aufgerufen wird um dessen
Code auszuführen und einen Ergebniswert zu erhalten. Der Aufruf eines
Funktionsabschlusses gleicht dem einer Funktion: Dem Namen der Variable die
unseren Funktionsabschluss beinhaltet werden runde Klammern, mit den Werten der
Argumente die wir verwenden wollen, angehängt. Siehe Codeblock 13-6

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn generate_workout(intensity: u32, random_number: u32) {
    let expensive_closure = |num| {
        println!("calculating slowly...");
        thread::sleep(Duration::from_secs(2));
        num
    };

    if intensity < 25 {
        println!("Today, do {} pushups!", expensive_closure(intensity));
        println!("Next, do {} situps!", expensive_closure(intensity));
    } else {
        if random_number == 3 {
            println!("Take a break today! Remember to stay hydrated!");
        } else {
            println!(
                "Today, run for {} minutes!",
                expensive_closure(intensity)
            );
        }
    }
}
```

<span class="caption">Codeblock 13-6: Aufruf des neu definierten
`expensive_closure`</span>

Nun wird die langsame Berechnung nur mehr an einer Stelle aufgerufen und wir
führen sie nur durch, wenn wir Resultate benötigten.
Wir haben jedoch eines der Probleme von Codeblock 13-3 wieder eingeführt.
Im ersten `if`-Block rufen wir den Funktionsabschluss mehrfach auf und lassen
somit den Benutzer doppelt solange warten als notwendig. Wir könnten das Problem
beheben, indem wir eine lokale Variable definieren die das Ergebnis des
Funktionsabschluss-Aufrufs hält. Funktionsabschlüsse bieten uns eine andere
Lösung. Wir werden diese Lösung in Kürze erklären, aber lass uns zuerst über die
fehlenden Typzuweisungen in der Definition des Funktionsabschlusses und den
Merkmalen (traits) von Funktionsabschlüssen sprechen.

### Typinferenz und Zuweisung bei Funktionsabschlüssen

Bei Funktionsabschlüssen musst du die Typen der Parameter und Rückgabewerte nicht,
wie bei Funktionen, mit Anmerkungen versehen. Für Funktionen sind Typanmerkungen 
erforderlich, da sie Bestandteil einer expliziten Benutzerschnittstelle sind.
Die starre Festlegung dieser Schnittstelle ist wichtig, damit sichergestellt
ist, dass jeder damit übereinstimmt, welche Arten von Werten von der Funktion
angenommen und zurückgegeben werden. Funktionsabschlüsse werden hingegen nicht
in einer Schnittstelle verwendet, sie werden in einer Variable gespeichert und 
aufgerufen, ohne sie zu benennen und Benutzern unserer Bibliothek (library)
zugänglich zu machen.

Funktionsabschlüsse sind für gewöhnlich kurz und eher in einem begrenzten Kontext
relevant, als in einem beliebigen Szenario. Innerhalb diesem beschränkten
Einsatzbereich ist der Compiler verlässlich in der Lage, Typen, Parameter und
Rückgabewerte zu inferieren, ähnlich wie er meistens bei Variablen die Typen
herleiten kann.

Dem Programmierer die Typen in diesen kurzen anonymen Funktionen anmerken zu
lassen wäre nur störend und überflüssig, da der Compiler bereits über die
dafür notwendigen Informationen verfügt.

Wir können wie bei Variablen Typanmerkungen hinzufügen, wenn wir die Klarheit
und Aussagekraft über das notwendige Maß hinaus erhöhen möchten.
Das Anmerken der Typen für den in Codeblock 13-5 definierten Funktionsabschluss
würde wie die Definition in Codeblock 13-7 aussehen.

<span class="filename">Dateiname: src/main.rs</span>

```rust
let expensive_closure = |num: u32| -> u32 {
        println!("calculating slowly...");
        thread::sleep(Duration::from_secs(2));
        num
    };
```

<span class="caption">Codeblock 13-7: Hinzufügen optionaler Typanmerkungen
der Parameter- und Rückgabewert-Typen im Funktionsabschluss
</span><span class="filename">Dateiname: src/main.rs</span>

Die Syntax eines Funktionsabschlusses mit Typanmerkungen, sieht der Syntax einer
Funktion sehr ähnlich. Es folgt ein vertikaler Vergleich der Syntax einer
Funktionsdefinition, die 1 zu ihren Parameter hinzufügt und einem
Funktionsabschluss mit dem gleichen Verhalten. Wir haben einige Abstände hinzugefügt,
um die relevanten Teile besser darzustellen. Dies zeigt wie ähnlich die Syntax
von Funktionen der von Funktionsabschlüssen, abgesehen von Pipes- und der 
Möglichkeit, einen Teil der Syntax wegzulassen, ist:

```rust,ignore
fn  add_one_v1   (x: u32) -> u32 { x + 1 }
let add_one_v2 = |x: u32| -> u32 { x + 1 };
let add_one_v3 = |x|             { x + 1 };
let add_one_v4 = |x|               x + 1  ;
```

Die erste Zeile zeigt eine Funktionsdefinition und die zweite eine Definition
eines Funktionsabschlusses mit allen Typanmerkungen. Bei der dritten Zeile
werden die Typanmerkungen in der Definition des Funktionsabschlusses weggelassen,
in der vierten Zeile das Gleiche ohne Klammern - da diese optional sind da der
Rumpf des Funktionsabschlusses nur einen Ausdruck beinhaltet. Dies sind alle
gültigen Ausdrücke die sich bei Aufruf gleich Verhalten. Für `add_one_v3` und
`add_one_v4` wird der Aufruf zum Kompilieren des Codes benötigt, da die Typen
hier, abhängig von der Benutzung bestimmt werden.

Bei Funktionsabschlüssen wird für jeden Parameter und für den Rückgabewert ein
konkreter Typ abgeleitet. Codeblock 13-8 zeigt zum Beispiel die Definition eines
kurzen Funktionsabschlusses, der nur den Wert zurückgibt, den er als Parameter
erhält. Dieser Funktionsabschluss ist abgesehen von seinem Zweck als Beispiel zu
dienen nicht weiter nützlich. Beachte, dass wir der Definition keine
Typanmerkungen hinzugefügt haben. Wenn wir nun versuchen, die Funktion zweimal
aufzurufen, und beim ersten einen String und beim zweiten Aufruf ein `u32`,
erhalten wir eine Fehlermeldung.


<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore,does_not_compile
 let example_closure = |x| x;

    let s = example_closure(String::from("hello"));
    let n = example_closure(5);
```

<span class="caption">Codeblock 13-8: Versuchter Aufruf eines Funktionsabschluss
den zwei unterschiedliche Typen zugewiesen wurden</span>

Der Compiler gibt diesen Fehler aus:

```console
$ cargo run
   Compiling closure-example v0.1.0 (file:///projects/closure-example)
error[E0308]: mismatched types
 --> src/main.rs:5:29
  |
5 |     let n = example_closure(5);
  |                             ^
  |                             |
  |                             expected struct `std::string::String`, found integer
  |                             help: try using a conversion method: `5.to_string()`

error: aborting due to previous error

For more information about this error, try `rustc --explain E0308`.
error: could not compile `closure-example`.

To learn more, run the command again with --verbose.
```
Beim ersten Aufruf von `example_closure` wird dem Typ von `x` und dem
Rückgabewert des Funktionsabschlusses der Typ `String` zugewiesen. Diese Typen
sind dann für den Funktionsabschluss `example_closure` festgeschrieben und daher
bekommen wir eine Fehlermeldung, wenn wir versuchen einen anderen Typ mit dem
gleichen Funktionsabschluss zu benutzen.

### Speichern von Funktionsabschlüssen unter Verwendung generischer Parameter und `Fn`-Merkmale (-Traits)

Lass uns auf unser Trainingsplan-Erstellungsprogramm zurückkommen. Im Codeblock
13-6 hat unser Programm, noch immer häufiger als notwendig, den
`expensive_closure`-Funktionsabschluss aufgerufen. Eine Möglichkeit, dieses
Problem zu beheben, besteht darin, das Ergebnis des Funktionsabschlusses in
einer Variable zu speichern und diese Variable zu benutzen, wann immer wir das
Resultat brauchen. Diese Methode würde allerdings zu ziemlich viel wiederholtem
Code führen.

Glücklicherweise steht uns eine andere Lösung zur Verfügung. Wir können eine
Struktur (struct) anlegen die den Funktionsabschluss und dessen Rückgabewert, bei
Aufruf, hält. Die Struktur wird den Funktionsabschluss nur dann ausführen, falls
wir ein Ergebnis benötigen und es wird unseren Resultatswert zwischenspeichern
damit der Rest unseres Programmcodes nicht mehr für das Speichern und 
Wiederverwenden verantwortlich ist. Dieses Muster (pattern) ist dir vielleicht
als *Memoisation* (memoization) oder *Lazy Evaluation* bekannt.

Um eine Struktur für unseren Funktionsabschluss herzustellen, müssen wir dessen
Typ spezifizieren, da die Definition einer Struktur den Typ aller ihrer Felder
kennen muss. Jede Instanz eines Funktionsabschlusses besitzt ihren einzigartigen
anonymen Typ, der selbst wenn zwei Funktionsabschlüsse identische Signaturen
haben, immer noch als verschieden betrachtet wird. Um Strukturen, Aufzählungen
(enums) oder Funktionen zu definieren, die Funktionsabschlüsse verwenden,
benutzen wir generische Datentypen (generics) und Merkmalsabgrenzungen (trait bounds),
die wir bereits im Kapitel 10 besprochen haben.

Die `Fn`-Merkmale werden von der Standardbibliothek (standard library) zur
Verfügung gestellt. Alle Funktionsabschlüsse implementieren mindestens eines der
Merkmale: `Fn`, `FnMut` oder `FnOnce`. Wir werden den Unterschied dieser
Merkmale in der [“Mit Funktionsabschlüssen die Umgebung erfassen”](#mit-funktionsabschlüssen-die-umgebung-erfassen)<!-- ignore --> Sektion besprechen. 
Für unser Beispiel können wir das `Fn`-Merkmal benutzen.

Den `Fn`-Merkmalsabgrenzungen fügen wir Typanmerkungen für die Typen, die mit dem
Funktionsabschluss übereinstimmen müssen, hinzu. In diesem Fall hat unser
Funktionsabschluss ein Parameter vom Typ `u32` und gibt einen `u32` zurück,
daher spezifizieren wir die Merkmalsabgrenzung als `Fn(u32) -> u32`.

Codeblock 13-9 zeigt die Definition der `Cacher`-Struktur, die einen
Funktionsabschluss und optional einen Rückgabewert hält.

<span class="filename">Dateiname: src/main.rs</span>

```rust
struct Cacher<T>
where
    T: Fn(u32) -> u32,
{
    calculation: T,
    value: Option<u32>,
}
```

<span class="caption">Codeblock 13-9: Definition einer `Cacher`-Struktur, die einen
Funktionsabschluss in `calculation` enthält und in `value` optional ein Resultat
</span>

Die `Cacher`-Struktur hat ein Feld `calculation` vom generischen Datentyp `T`.
Die Merkmalsabgrenzungen auf `T` legen das `Fn`-Merkmal für den
Funktionsabschluss fest. Jeder Funktionsabschluss den wir im `calculation`-Feld
speichern, muss einen `u32`-Parameter (spezifiziert innerhalb der runden Klammern
hinter `Fn`) und einen `u32` (festgelegt nach dem `->`) zurückgeben.

> Merke: Auch Funktionen können alle drei `Fn`-Merkmale implementieren.
> Falls eine Problemstellung das Erfassen eines Wertes der Umgebung nicht erfordert,
> können wir eine Funktion anstatt eines Funktionsabschlusses benutzen, der etwas
> benötigt, um für ihn das `Fn`-Merkmal zu implementieren.

Das `value`-Feld hat den Typ `Option<u32>`. Bevor wir den Funktionsabschluss
ausführen, ist `value` `None`. Wenn Programmcode mit einem `Cacher` nach dem
*Ergebnis* des Funktionsabschlusses fragt, wird der `Cacher` zu diesem Zeitpunkt
den Funktionsabschluss ausführen und das Ergebnis in einer `Some`-Variante im
Feld `value` speichern. Wenn der Code später wieder nach dem Resultat des
Funktionsabschlusses fragt, wird anstatt der erneuten Ausführung der Berechnung
der `Cacher` den Wert zurückgeben, der in der `Some`-Variante enthalten ist.
 
Im Codeblock 13-10, wird die Logik um das soeben beschriebene Feld `value`
definiert.

<span class="filename">Dateiname: src/main.rs</span>

```rust
impl<T> Cacher<T>
where
    T: Fn(u32) -> u32,
{
    fn new(calculation: T) -> Cacher<T> {
        Cacher {
            calculation,
            value: None,
        }
    }

    fn value(&mut self, arg: u32) -> u32 {
        match self.value {
            Some(v) => v,
            None => {
                let v = (self.calculation)(arg);
                self.value = Some(v);
                v
            }
        }
    }
}
```

<span class="caption">Codeblock 13-10: Die Zwischenspeicherungs-Logik von `Cacher`</span>

Wir möchten das `Cacher` die Felder der Struktur verwaltet, anstatt dem
aufrufenden Code die Werte unter Umständen direkt ändern zu lassen, sodass diese
Felder privat sind.

Die `Cacher::new`-Funktion nimmt einen generischen Datentyp-Parameter `T`,
welchen wir so definiert haben, dass er dieselbe Merkmalsabgrenzung wie die
`Cacher`-Struktur hat. Anschließend gibt `Cacher::new` eine `Cacher`-Instanz aus
die den Funktionsabschluss enthält der im `calculation`-Feld spezifiziert wurde
und den Wert `None` in seinem `value`-Feld enthält da wir den Funktionsabschluss
bisher noch nicht ausgeführt haben.

Wenn der aufrufende Code das Auswertungsergebnis des Funktionsabschlusses
benötigt, ruft er die Methode `value`, anstatt direkt den Funktionsabschluss,
auf. Diese Methode überprüft, ob wir bereits einen Rückgabewert in `self.value`
in einen `Some` gespeichert haben, falls ja, gibt es den Wert, der in `Some`
enthalten ist zurück ohne den Funktionsabschluss erneut auszuführen.

Falls `self.value` ein `None` ist, ruft der Programmcode den Funktionsabschluss
auf, der in `self.calculation` gespeichert ist, speichert das Resultat in
`self.value` für seine zukünftige Verwendung und gibt den Wert zurück.

Codeblock 13-11 zeigt wie wir die `Cacher`-Struktur in der
`generate_workout`-Funktion vom Codeblock 13-6 verwenden können.

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn generate_workout(intensity: u32, random_number: u32) {
    let mut expensive_result = Cacher::new(|num| {
        println!("calculating slowly...");
        thread::sleep(Duration::from_secs(2));
        num
    });

    if intensity < 25 {
        println!("Today, do {} pushups!", expensive_result.value(intensity));
        println!("Next, do {} situps!", expensive_result.value(intensity));
    } else {
        if random_number == 3 {
            println!("Take a break today! Remember to stay hydrated!");
        } else {
            println!(
                "Today, run for {} minutes!",
                expensive_result.value(intensity)
            );
        }
    }
}
```

<span class="caption">Codeblock 13-11: Die Verwendung von `Cacher` in der
`generate_workout`-Funktion zur Abstraktion der Zwischenspeicherungs-Logik</span>

Anstatt den Funktionsabschluss direkt in einer Variable zu speichern, speichern
wir eine neue Instanz von `Cacher` die den Funktionsabschluss beinhaltet. An
jeder Stelle, an der wir ein Resultat benötigen, rufen wir dann die
`value`-Methode an der `Cacher`-Instanz auf. Egal ob wir nun die `value`-Methode
mehrmals aufrufen oder gar nicht wird die aufwendige Berechnung nur einmal 
ausgeführt.

### Einschränkungen der `Cacher`-Implementierung

Das Zwischenspeichern von Werten ist allgemein eine nützliche Vorgehensweise,
die wir möglicherweise auch an anderen Programmteilen mit verschieden
Funktionsabschlüssen verwenden möchten. Jedoch gibt es zwei Probleme der aktuellen
Implementierung von "Cacher", die eine Wiederverwendung in verschiedenen Kontexten
erschweren würden.

Das erste Problem ist, dass eine `Cacher`-Instanz davon ausgeht das sie immer
den gleichen Wert für den `arg`-Parameter zur `value`-Methode bekommt. Das
bedeutet, dass dieser Test fehlschlagen wird:

```rust,ignore,panics
 #[test]
    fn call_with_different_values() {
        let mut c = Cacher::new(|a| a);

        let v1 = c.value(1);
        let v2 = c.value(2);

        assert_eq!(v2, 2);
    }
```

Dieser Test erzeugt eine neue `Cacher`-Instanz mit einem Funktionsabschluss, der
den Wert zurückgibt, den er erhalten hat. Wir rufen nun die `Cacher`-Instanz
mit der `value`-Methode auf, zuerst mit einen `arg`-Wert 1 und dann mit einen
`arg`-Wert 2 und erwarten, dass beim zweiten Aufruf 2 zurückgegeben wird.

Führe diesen Test mit der Implementierung von `Cacher` vom Codeblock 13-9 und
13-10 durch und der Test wird an `assert_eq!` mit folgender Meldung
fehlschlagen:

```console
$ cargo test
   Compiling cacher v0.1.0 (file:///projects/cacher)
    Finished test [unoptimized + debuginfo] target(s) in 0.72s
     Running target/debug/deps/cacher-4116485fb32b3fff

running 1 test
test tests::call_with_different_values ... FAILED

failures:

---- tests::call_with_different_values stdout ----
thread 'main' panicked at 'assertion failed: `(left == right)`
  left: `1`,
 right: `2`', src/lib.rs:43:9
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace.


failures:
    tests::call_with_different_values

test result: FAILED. 0 passed; 1 failed; 0 ignored; 0 measured; 0 filtered out

error: test failed, to rerun pass '--lib'
```

Das Problem ist, dass beim ersten Aufruf von `c.value` mit 1, die `Cacher`-Instanz
den Wert `Some(1)` in `self.value` gespeichert hat. Egal was wir danach der
`value`-Methode als Wert  mitgeben, wir werden immer 1 zurückbekommen.

Versuche `Cacher` so zu verändern, dass er anstatt eines Wertes eine Hash-Tabelle
(hash map) enthält. Die Schlüssel (keys) der Hash-Tabelle werden die `arg`-Werte
die mitgegeben werden sein und die Werte der werden das Resultat des Aufrufs des
Funktionsabschlusses mit dem jeweiligen Schlüssel sein. Anstatt `value` direkt
zu betrachten, ob es einen `Some` oder `None` enthält, wird die `value`-Funktion
nach `arg` in der Hash-Tabelle suchen und den Wert, falls vorhanden, zurückgeben.
Falls der Wert nicht vorhanden ist, wird der `Cacher` den Funktionsabschluss
aufrufen und den Rückgabewert in der Hash-Tabelle verbunden mit seinem `arg`-Wert
speichern.

Das zweite Problem mit der derzeitigen Implementierung von `Cacher` ist, dass
sie nur Funktionsabschlüsse annimmt die ein Parameter vom Typ `u32` bekommen und 
ein `u32` zurückgeben. Möglicherweise möchten wir zum Beispiel Ergebnisse von
Funktionsabschlüssen zwischenspeichern die einen Zeichenketten-Anteilstyp (string
slice) nehmen und `usize`-Werte zurückgeben. Um dieses Problem zu beheben,
versuche generische Datentypen zu verwenden, um die `Cacher`-Funktionalität
flexibler zu machen.

### Mit Funktionsabschlüssen die Umgebung erfassen

Im Trainingsplan-Erstellungs Beispiel haben wir Funktionsabschlüsse nur als
anonyme Inline-Funktionen verwendet, Funktionsabschlüsse jedoch, verfügen über
eine Fähigkeit die Funktionen nicht haben: Sie können ihre Umgebung erfassen und
auf Variablen die im selben Gültigkeitsbereich definiert wurden zugreifen.

Codeblock 13-12 beinhaltet ein Beispiel eines Funktionsabschlusses der in einer
Variable `equal_to_x` gespeichert ist und eine Variable `x` aus ihrer Umgebung
verwendet.

<span class="filename">Dateiname: src/main.rs</span>

```rust
fn main() {
    let x = 4;

    let equal_to_x = |z| z == x;

    let y = 4;

    assert!(equal_to_x(y));
}
```

<span class="caption">Codeblock 13-12: Beispiel eines Funktionsabschlusses, der
sich auf eine Variable im umgebenden Gültigkeitsbereich bezieht.</span>

Auch wenn `x` hier keines der Parameter von `equal_to_x` ist, darf der
`equal_to_x`-Funktionsabschluss die Variable `x` benutzen, die im gleichen
Gültigkeitsbereich definiert wurde wie `equal_to_x`.

Mit Funktionen können wir dasselbe nicht machen, wenn wir es, wie im folgenden
Beispiel versuchen wird der Programmcode nicht kompiliert:

<span class="filename">Filename: src/main.rs</span>

```rust,ignore,does_not_compile
fn main() {
    let x = 4;

    fn equal_to_x(z: i32) -> bool {
        z == x
    }

    let y = 4;

    assert!(equal_to_x(y));
}
```

Wir bekommen eine Fehlermeldung:

```console
$ cargo run
   Compiling equal-to-x v0.1.0 (file:///projects/equal-to-x)
error[E0434]: can't capture dynamic environment in a fn item
 --> src/main.rs:5:14
  |
5 |         z == x
  |              ^
  |
  = help: use the `|| { ... }` closure form instead
```
Der Compiler erinnert uns sogar daran, dass dies nur mit Funktionsabschlüssen
funktioniert!

Wenn ein Funktionsabschluss einen Wert aus seiner Umgebung erfasst, benutzt er
Speicher, um die Werte im Funktionsabschluss-Rumpf für die Benutzung zu halten.
Diesen zusätzlichen Aufwand an Speichernutzung (overhead), wollen wir wenn wir
Code ausführen möchten der seine Umgebung nicht erfasst, nicht verursachen. Da
Funktionen ihre Umgebung niemals erfassen können, kann das Definieren und
Ausführen von Funktionen auch nie diesen Speichernutzungsmehraufwand
verursachen.

Es gibt drei Möglichkeiten wie Funktionsabschlüsse ihre Umgebung erfassen
können, den drei Möglichkeiten entsprechend wie Funktionen ein Parameter
erhalten können: Eigentümerschaft übernehmen (taking ownership), veränderliches
Ausleihen (borrowing mutably) und unveränderliches Ausleihen (borrowing immutably).
Diese sind wie folgt, in den drei `Fn`-Merkmalen codiert:

* `FnOnce` verbraucht die Variablen, die vom umgebenden Gültigkeitsbereich
    erfasst werden, dieser Bereich wird als Funktionsabschluss-Umgebung
    (closure’s *enviroment*) bezeichnet. Um die erfassten Variablen verbrauchen
    zu können, muss der Funktionsabschluss die Eigentümerschaft dieser Variablen
    übernehmen und sie bei dessen Definition, in den Funktionsabschluss bewegen
    (move). Der Namensteil `Once` repräsentiert die Tatsache, dass der
    Funktionsabschluss nur einmal die Eigentümerschaft der gleichen Variablen
    übernehmen kann, daher kann es nur einmal aufgerufen werden.
* `FnMut` kann die Funktionsabschluss-Umgebung verändern, da es Werte
    veränderlich ausleiht.
* `Fn` leiht Werte des umgebenden Gültigkeitsbereiches unveränderlich.

Wenn du einen Funktionsabschluss erstellst, schließt Rust, welches Merkmal
verwendet werden soll, aus der Verwendungsweise der vom Funktionsabschluss 
erfassten Variablen. Alle Funktionsabschlüsse implementieren `FnOnce`, da sie
mindestens einmal aufgerufen werden können. Funktionsabschlüsse, die erfasste
Variablen nicht bewegen implementieren zusätzlich `FnMut` und
Funktionsabschlüsse die keinen veränderlichen Zugriff auf die erfassten Werte
benötigen implementieren des weiteren `Fn`. Im Codeblock 13-12, leiht der
`equal_to_x`-Funktionsabschluss `x` unveränderlich (dadurch hat `equal_to_x` das
`Fn`-Merkmal), da der Funktionsabschluss-Rumpf den Variablenwert `x` nur liest.

Falls du erzwingen möchtest, dass ein Funktionsabschluss die Eigentümerschaft
der aus dem umgebenden Gültigkeitsbereich verwendeten Werte übernimmt, kannst du
vor der Parameterliste das `move`-Schlagwort verwenden. Diese Technik ist vor
allem dann nützlich, wenn ein Funktionsabschluss an einen neuen Strang (thread) 
übergeben wird, um die Daten so zu verschieben, dass sie dem neuen Strang
gehören.

Weitere Beispiele für `move` bei Funktionsabschlüssen folgen im Kapitel 16, wenn
wir über Parallelität sprechen. Einstweilen ist hier der Programmcode von
Codeblock 13-12 mit dem Schlagwort-`move`, das der Funktionsabschlussdefinition
hinzugefügt wurde und Vektoren statt Ganzzahlen (integers) verwendet, da
Ganzzahlen kopiert und nicht bewegt werden. Beachte, dass dieser Programmcode
noch nicht kompiliert wird.

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore,does_not_compile
fn main() {
    let x = vec![1, 2, 3];

    let equal_to_x = move |z| z == x;

    println!("can't use x here: {:?}", x);

    let y = vec![1, 2, 3];

    assert!(equal_to_x(y));
}
```

Wir erhalten folgende Fehlermeldung:

```console
$ cargo run
   Compiling equal-to-x v0.1.0 (file:///projects/equal-to-x)
error[E0382]: borrow of moved value: `x`
 --> src/main.rs:6:40
  |
2 |     let x = vec![1, 2, 3];
  |         - move occurs because `x` has type `std::vec::Vec<i32>`, which does not implement the `Copy` trait
3 | 
4 |     let equal_to_x = move |z| z == x;
  |                      --------      - variable moved due to use in closure
  |                      |
  |                      value moved into closure here
5 | 
6 |     println!("can't use x here: {:?}", x);
  |                                        ^ value borrowed here after move

error: aborting due to previous error

For more information about this error, try `rustc --explain E0382`.
error: could not compile `equal-to-x`.

To learn more, run the command again with --verbose.

```

Der Wert `x` wurde bei der Funktionsabschlussdefinition in diesen hineinbewegt,
da wir das `move`-Schlagwort hinzugefügt haben. Der Funktionsabschluss hat
dadurch die Eigentümerschaft von `x` und `main` kann daher `x` nicht mehr 
im `println!`-Statement benutzen. Durch Entfernen von `println!` wird dieser
Fehler behoben.

Wenn du eine `Fn`-Merkmalsabgrenzung spezifiziert, reicht es zumeist wenn du mit
`Fn` beginnst und der Compiler wird melden wenn es notwendig ist `FnMut` oder
`FnOnce` basierend auf dem, was im Funktionsabschluss-Rumpf passiert. 

Um Situationen zu veranschaulichen, die die Nützlichkeit von
Umgebung erfassenden Funktionsabschlüssen als Funktionsparameter demonstrieren,
fahren wir mit unserem nächsten Thema fort: Iteratoren.
