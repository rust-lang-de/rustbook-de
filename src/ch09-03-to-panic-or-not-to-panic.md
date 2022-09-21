## Wann `panic!` aufrufen und wann nicht?

Wie entscheidest du also, wann du `panic!` aufrufen und wann `Result`
zurückgeben sollst? Wenn Code abbricht, gibt es keine Möglichkeit sich vom
Fehler zu erholen. Du könntest `panic!` in jeder Fehlersituation anrufen,
unabhängig davon, ob es eine Möglichkeit zur Fehlerbehebung gibt oder nicht,
aber dann triffst du die Entscheidung für den aufrufenden Code, dass eine
Situation nicht rettbar ist. Wenn du dich dafür entscheidest, einen
`Result`-Wert zurückzugeben, überlässt du dem aufrufenden Code die
Wahlmöglichkeit, anstatt die Entscheidung für ihn zu treffen. Der aufrufende
Code könnte sich dafür entscheiden, sich vom Fehler auf eine sinnvolle Weise
zu erholen, oder er könnte sich dafür entscheiden, dass ein `Err`-Wert in
diesem Fall nicht behebbar ist und `panic!` aufrufen, und so deinen behebbaren
Fehler in einen nicht behebbaren verwandeln. Daher ist die Rückgabe von
`Result` eine gute Standardwahl, wenn du eine Funktion definierst, die
fehlschlagen könnte.

In Beispielen, Prototyp-Code und Tests ist es sinnvoller, Code zu schreiben,
der das Programm abbricht, anstatt ein `Result` zurückzugeben. Lass uns
herausfinden, warum das so ist, und dann Situationen besprechen, in denen der
Compiler nicht feststellen kann, dass ein Fehler unmöglich ist, du als Mensch
aber schon. Das Kapitel schließt mit einigen allgemeinen Richtlinien zur
Entscheidung, ob in Bibliothekscode ein Programm abgebrochen werden soll.

### Beispiele, Code-Prototypen und Tests

Wenn du ein Beispiel schreibst, um ein Konzept zu veranschaulichen, kann die
Einbeziehung von robustem Fehlerbehandlungscode das Beispiel unklarer machen.
In Beispielen wird davon ausgegangen, dass der Aufruf einer Methode wie
`unwrap`, die das Programm abbrechen könnte, als Platzhalter für die Art und
Weise gedacht ist, wie deine Anwendung mit Fehlern umgehen soll, die je
nachdem, was der Rest deines Codes tut, unterschiedlich sein können.

In ähnlicher Weise sind die Methoden `unwrap` und `expect` bei Prototypen sehr
praktisch, wenn du noch nicht entscheiden willst, wie mit Fehlern umzugehen
ist. Du hinterlässt klare Markierungen in deinem Code für später, wenn du dein
Programm robuster machst.

Wenn ein Methodenaufruf in einem Test fehlschlägt, würdest du wollen, dass der
gesamte Test fehlschlägt, auch wenn diese Methode nicht die zu testende
Funktionalität ist. Da ein Test mit `panic!` als fehlgeschlagen markiert wird,
ist der Aufruf von `unwrap` und `expect` genau das, was passieren sollte.

### Fälle, in denen du mehr Informationen als der Compiler hast

Es wäre auch sinnvoll, `unwrap` oder `expect` aufzurufen, wenn du eine andere
Logik hast, die sicherstellt, dass `Result` einen `Ok`-Wert hat, aber die Logik
kann vom Compiler nicht verstanden werden. Du wirst immer noch ein `Result`
haben, mit dem du umgehen musst: Welche Operation auch immer du aufrufst, es
besteht immer noch die Möglichkeit, dass sie im Allgemeinen scheitert, auch
wenn es in deiner speziellen Situation logischerweise unmöglich ist. Wenn du
durch manuelle Codeinspektion sicherstellen kannst, dass du niemals eine
`Err`-Variante haben wirst, ist es vollkommen akzeptabel, `unwrap` aufzurufen,
und noch besser ist es, den Grund, warum du glaubst, dass du niemals eine
`Err`-Variante haben wirst, im `expect`-Text zu dokumentieren. Hier ist ein
Beispiel:

```rust
use std::net::IpAddr;

let home: IpAddr = "127.0.0.1"
    .parse()
    .expect("Fest programmierte IP-Adresse sollte gültig sein");
```

Wir erstellen eine `IpAddr`-Instanz, indem wir eine hartkodierte Zeichenkette
parsen. Wir können sehen, dass `127.0.0.1` eine gültige IP-Adresse ist, sodass
es akzeptabel ist, hier `expect` zu verwenden. Eine hartkodierte, gültige
Zeichenkette ändert jedoch nicht den Rückgabetyp der `parse`-Methode: Wir
erhalten immer noch einen `Result`-Wert und der Compiler wird von uns
verlangen, `Result` so zu behandeln, als ob die `Err`-Variante möglich wäre,
weil der Compiler nicht klug genug ist, um zu erkennen, dass diese
Zeichenkette stets eine gültige IP-Adresse ist. Wenn die
IP-Adressen-Zeichenkette von einem Benutzer kam, anstatt fest im Programm
kodiert zu sein, und daher möglicherweise fehlschlagen könnte, würden wir
stattdessen definitiv `Result` auf eine robustere Weise behandeln wollen.

### Richtlinien zur Fehlerbehandlung

Es ist ratsam, dass dein Code abbricht, wenn es möglich ist, dass dein Code in
einem schlechten Zustand enden könnte. In diesem Zusammenhang ist ein
*schlechter Zustand* (bad state) dann gegeben, wenn eine Annahme, eine
Garantie, ein Vertrag oder eine Invariante gebrochen wurde, z.B. wenn ungültige
Werte, widersprüchliche Werte oder fehlende Werte an deinen Code übergeben
werden &ndash; sowie eine oder mehrere der folgenden Punkte zutreffen:

* Der schlechte Zustand ist etwas Unerwartetes, im Gegensatz zu etwas, das
  wahrscheinlich gelegentlich vorkommt, wie die Eingabe von Daten in einem
  falschen Format durch einen Benutzer.
* Dein Code muss sich nach diesem Punkt darauf verlassen können, dass er sich
  in keinem schlechten Zustand befindet, anstatt bei jedem Schritt auf das
  Problem zu prüfen.
* Es gibt keine gute Möglichkeit, diese Informationen in den von dir
  verwendeten Typen zu kodieren. Wir werden im Abschnitt [„Kodieren von
  Zuständen und Verhalten als Typen“][encoding] in Kapitel 17 ein Beispiel
  dafür durcharbeiten.

Wenn jemand deinen Code aufruft und Werte übergibt, die keinen Sinn ergeben,
ist es am besten, einen Fehler zurückzugeben, damit der Benutzer der Bibliothek
entscheiden kann, was er in diesem Fall tun möchte. In Fällen, in denen eine
Fortsetzung unsicher oder schädlich sein könnte, ist es jedoch am besten,
`panic!` aufzurufen und die Person, die deine Bibliothek verwendet, auf den
Fehler in ihrem Code hinzuweisen, damit sie ihn während der Entwicklung beheben
kann. In ähnlicher Weise ist `panic!` oft angebracht, wenn du externen Code
aufrufst, der sich deiner Kontrolle entzieht und einen ungültigen Zustand
zurückgibt, den du nicht beheben kannst.

Wenn jedoch ein Fehler erwartet wird, ist es sinnvoller, ein `Result`
zurückzugeben, als `panic!` aufzurufen. Beispiele hierfür sind ein Parser, dem
fehlerhafte Daten übergeben werden, oder eine HTTP-Anfrage, die einen Status
zurückgibt, der anzeigt, dass du ein Aufruflimit erreicht hast. In diesen
Fällen zeigt der Rückgabetyp `Result` an, dass ein Fehler eine erwartete
Möglichkeit ist, bei der der aufrufende Code entscheiden muss, wie er damit
umgeht.

Wenn dein Code einen Vorgang ausführt, der einen Benutzer gefährden könnte,
wenn er mit ungültigen Werten aufgerufen wird, sollte dein Code zuerst
überprüfen, ob die Werte gültig sind, und das Programm abbrechen, wenn die
Werte nicht gültig sind. Dies geschieht hauptsächlich aus Sicherheitsgründen:
Der Versuch, mit ungültigen Daten zu operieren, kann deinen Code Schwachstellen
aussetzen. Dies ist der Hauptgrund dafür, dass die Standardbibliothek `panic!`
aufruft, wenn du versuchst, einen unzulässigen Speicherzugriff durchzuführen:
Der Versuch, auf Speicher zuzugreifen, der nicht zur aktuellen Datenstruktur
gehört, ist ein häufiges Sicherheitsproblem. Funktionen haben oft *Verträge*
(contracts): Ihr Verhalten ist nur dann garantiert, wenn die Eingaben bestimmte
Anforderungen erfüllen. Abzubrechen, wenn der Vertrag verletzt wird, ist
sinnvoll, weil eine Vertragsverletzung immer auf einen Fehler auf der
Anruferseite hinweist und es sich nicht um eine Fehlerart handelt, die der
aufgerufende Code explizit behandeln sollte. Tatsächlich gibt es keinen
vernünftigen Weg, wie sich der aufrufende Code vom Fehler erholen kann; die
aufrufenden *Programmierer* müssen den Code reparieren. Verträge zu einer
Funktion sollten in der API-Dokumentation der Funktion erläutert werden,
insbesondere wenn deren Verletzung zu einem Programmabbruch führt.

Zahlreiche Fehlerprüfungen in deinen Funktionen wären jedoch langatmig und
störend. Glücklicherweise kannst du das Typsystem von Rust (und damit die
Typprüfung durch den Compiler) verwenden, um viele Prüfungen für dich zu
übernehmen. Wenn deine Funktion einen besonderen Typ als Parameter hat, kannst
du mit der Logik deines Codes fortfahren, da du weißt, dass der Compiler
bereits sichergestellt hat, dass du einen gültigen Wert hast. Wenn du zum
Beispiel einen Typ anstatt einer `Option` hast, erwartet dein Programm *etwas*
statt *nichts*. Dein Code muss dann nicht zwei Fälle für die Varianten `Some`
und `None` behandeln: Er wird nur einen Fall mit definitiv einem Wert haben.
Code, der versucht, nichts an deine Funktion zu übergeben, lässt sich nicht
einmal kompilieren, sodass deine Funktion diesen Fall zur Laufzeit nicht prüfen
muss. Ein anderes Beispiel ist die Verwendung eines vorzeichenlosen
Ganzzahl-Typs wie `u32`, der sicherstellt, dass der Parameter niemals negativ
ist.

### Benutzerdefinierte Typen für die Validierung erstellen

Gehen wir noch einen Schritt weiter, indem wir das Typsystem von Rust verwenden,
um sicherzustellen, dass wir einen gültigen Wert haben, und betrachten wir die
Erstellung eines benutzerdefinierten Typs für die Validierung. Erinnere
dich an das Ratespiel in Kapitel 2, bei dem unser Code den Benutzer
aufforderte, eine Zahl zwischen 1 und 100 zu erraten. Wir haben nie überprüft,
ob die Schätzung des Benutzers zwischen diesen Zahlen lag, bevor wir sie mit
unserer Geheimzahl verglichen haben; wir haben nur überprüft, ob die Schätzung
richtig war. In diesem Fall waren die Folgen nicht sehr gravierend: Unsere
Ausgabe von „zu groß“ oder „zu klein“ wäre immer noch richtig. Aber es wäre
eine nützliche Erweiterung, um den Benutzer zu gültigen Rateversuchen zu führen
und ein unterschiedliches Verhalten zu zeigen, wenn ein Benutzer eine Zahl
eingibt, die außerhalb des Bereichs liegt, als wenn ein Benutzer stattdessen
z.B. Buchstaben eingibt.

Eine Möglichkeit, dies zu tun, wäre, die Eingabe als `i32` statt nur als `u32`
zu parsen, um potenziell negative Zahlen zuzulassen, und dann eine
Bereichsprüfung der Zahl zu ergänzen, etwa so:

```rust,ignore
# use rand::Rng;
# use std::cmp::Ordering;
# use std::io;
#
# fn main() {
#     println!("Rate eine Zahl!");
#
#     let secret_number = rand::thread_rng().gen_range(1, 101);
#
    loop {
        // --abschneiden--

#         println!("Bitte gib deine Vermutung ein.");
#
#         let mut guess = String::new();
#
#         io::stdin()
#             .read_line(&mut guess)
#             .expect("Fehler beim Lesen der Zeile");
#
        let guess: i32 = match guess.trim().parse() {
            Ok(num) => num,
            Err(_) => continue,
        };

        if guess < 1 || guess > 100 {
            println!("Die geheime Zahl wird zwischen 1 und 100 liegen.");
            continue;
        }

        match guess.cmp(&secret_number) {
            // --abschneiden--
#             Ordering::Less => println!("Zu klein!"),
#             Ordering::Greater => println!("Zu groß!"),
#             Ordering::Equal => {
#                 println!("Du hast gewonnen!");
#                 break;
#             }
#         }
    }
# }
```

Der `if`-Ausdruck prüft, ob unser Wert außerhalb des Bereichs liegt, informiert
den Benutzer über das Problem und ruft `continue` auf, um die nächste Iteration
der Schleife zu starten und um eine weitere Schätzung zu bitten. Nach dem
`if`-Ausdruck können wir mit dem Vergleich zwischen `guess` und der Geheimzahl
fortfahren, wobei wir wissen, dass `guess` zwischen 1 und 100 liegt.

Dies ist jedoch keine ideale Lösung: Wenn es zwingend erforderlich wäre, dass das
Programm nur mit Werten zwischen 1 und 100 arbeitet, und wir viele Funktionen
mit dieser Anforderung haben, wäre eine solche Prüfung in jeder Funktion mühsam
(und könnte die Leistung beeinträchtigen).

Stattdessen können wir einen neuen Typ erstellen und die Validierungen in eine
Funktion geben, um eine Instanz des Typs zu erzeugen, anstatt die Validierungen
überall zu wiederholen. Auf diese Weise ist es für die Funktionen sicher, den
neuen Typ in ihren Signaturen zu verwenden und die erhaltenen Werte
vertrauensvoll zu nutzen. Codeblock 9-13 zeigt eine Möglichkeit, einen Typ
`Guess` zu definieren, der nur dann eine Instanz von `Guess` erzeugt, wenn die
Funktion `new` einen Wert zwischen 1 und 100 erhält.

```rust
pub struct Guess {
    value: i32,
}

impl Guess {
    pub fn new(value: i32) -> Guess {
        if value < 1 || value > 100 {
            panic!("Der Schätzwert muss zwischen 1 und 100 liegen, ist jedoch {}.",
                   value);
        }

        Guess { value }
    }

    pub fn value(&self) -> i32 {
        self.value
    }
}
```

<span class="caption">Codeblock 9-13: Ein Typ `Guess`, der nur bei Werten
zwischen 1 und 100 fortsetzt</span>

Zuerst definieren wir eine Struktur `Guess`, die ein Feld `value` hat, das
einen `i32` enthält. Hier wird die Nummer gespeichert.

Dann implementieren wir die zugehörige Funktion `new` auf `Guess`, die
Instanzen von `Guess` erzeugt. Die Funktion `new` ist so definiert, dass sie
einen Parameter `value` vom Typ `i32` nimmt und eine `Guess`-Instanz
zurückgibt. Der Code im Funktionsrumpf von `new` testet den Wert in `value`, um
sicherzustellen, dass er zwischen 1 und 100 liegt. Wenn `value` diesen Test
nicht besteht, rufen wir `panic!` auf, was den Programmierer des aufrufenden
Codes darauf aufmerksam macht, dass er einen Fehler hat, den er beheben muss,
denn ein `Guess` mit einem Wert außerhalb dieses Bereichs zu erzeugen, würde
den Vertrag verletzen, auf den sich `Guess::new` verlässt. Die Bedingungen,
unter denen `Guess::new` das Programm abbricht, sollten in der öffentlich
zugänglichen API-Dokumentation genannt werden; wir werden die
Dokumentationskonventionen, die auf die Möglichkeit eines `panic!`-Aufrufs
hinweisen, in der API-Dokumentation behandeln, die du in Kapitel 14 erstellst. 
Wenn `value` den Test besteht, erstellen wir eine neue `Guess`-Instanz, deren
Feld `value` den Parameterwert `value` erhält, und geben die Instanz zurück.

Als nächstes implementieren wir eine Methode namens `value`, die `self`
ausleiht, keine anderen Parameter hat und ein `i32` zurückgibt. Diese
Methodenart wird manchmal als *Abfragemethode* (getter) bezeichnet, weil ihr
Zweck darin besteht, Daten aus ihren Feldern zurückzugeben. Diese öffentliche
Methode ist notwendig, weil das Feld `value` der Struktur `Guess` privat ist.
Es ist wichtig, dass das Feld `value` privat ist, damit Code, der die Struktur
`Guess` verwendet, `value` nicht direkt setzen kann: Code außerhalb des Moduls
*muss* die Funktion `Guess::new` verwenden, um eine Instanz von `Guess` zu
erzeugen, wodurch sichergestellt wird, dass es keine Möglichkeit gibt, dass
`Guess` einen `Wert` hat, der nicht durch die Bedingungen in der Funktion
`Guess::new` überprüft wurde.

Eine Funktion, die einen Parameter hat oder nur Zahlen zwischen 1 und 100
zurückgibt, könnte dann in ihrer Signatur angeben, dass sie ein `Guess`
anstelle eines `i32` entgegennimmt oder zurückgibt und bräuchte dann in ihrem
Rumpf keine zusätzlichen Prüfungen durchzuführen.

## Zusammenfassung

Die Fehlerbehandlungsfunktionen von Rust sollen dir helfen, robusteren Code zu
schreiben. Das Makro `panic!` signalisiert, dass sich dein Programm in einem
Zustand befindet, mit dem es nicht umgehen kann, und ermöglicht es dir, den
Prozess anzuhalten, anstatt zu versuchen, mit ungültigen oder falschen Werten
fortzufahren. Die Aufzählung `Result` verwendet das Typsystem von Rust, um
anzuzeigen, dass Operationen so fehlschlagen könnten, dass dein Code sich davon
wieder erholen könnte. Du kannst `Result` verwenden, um dem Code, der deinen
Code aufruft, mitzuteilen, dass er auch mit potentiellem Erfolg und Misserfolg
umgehen muss. Das Verwenden von `panic!` und `Result` in den entsprechenden
Situationen wird deinen Code angesichts unvermeidlicher Probleme zuverlässiger
machen.

Nachdem du nun nützliche Möglichkeiten gesehen hast, wie die Standardbibliothek
generische Datentypen mit den Enums `Option` und `Result` verwendet, werden wir
darüber sprechen, wie generische Datentypen funktionieren und wie du sie in
deinem Code verwenden kannst.

[encoding]: ch17-03-oo-design-patterns.html#kodieren-von-zuständen-und-verhalten-als-typen
