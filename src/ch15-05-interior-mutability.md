## `RefCell<T>` und das innere Veränderlichkeitsmuster

*Innere Veränderlichkeit* (interior mutability) ist ein Entwurfsmuster in Rust,
mit dem man Daten auch dann verändern kann, wenn unveränderliche Referenzen auf
diese Daten vorhanden sind. Normalerweise ist diese Aktion nach den
Ausleihregeln nicht zulässig. Um Daten zu verändern, verwendet das Muster
„unsicheren“ Programmcode (`unsafe` code) innerhalb einer Datenstruktur, um Rusts
übliche Regeln, die Veränderlichkeit und Ausleihen betreffen, zu verändern. Wir
haben unsicheren Code noch nicht behandelt. Wir werden in Kapitel 19 darauf
eingehen. Wir können Typen verwenden, die das innere Veränderlichkeitsmuster
verwenden, wenn wir sicherstellen können, dass die Ausleihregeln zur Laufzeit
eingehalten werden, obwohl der Compiler dies nicht garantieren kann. Der
betreffende unsichere Programmcode wird dann in eine sichere API
eingeschlossen und der äußere Typ ist immer noch unveränderlich.

Lass uns dieses Konzept untersuchen, indem wir uns den Typ `RefCell<T>` ansehen,
der dem inneren Veränderlichkeitsmuster folgt.

### Mit `RefCell<T>` Ausleihregeln zur Laufzeit durchsetzen

Im Gegensatz zu `Rc<T>` repräsentiert der Typ `RefCell<T>` die
einzige Eigentümerschaft (ownership) für die darin enthaltenen Daten. Was unterscheidet
`RefCell<T>` von einem Typ wie `Box<T>`? Erinnere dich an die Ausleihregeln die
wir im Kapitel 4 gelernt haben:

* Zu jeder Zeit kann man *entweder* eine veränderliche Referenz oder eine
  beliebige Anzahl unveränderlicher Referenzen haben (nicht aber beides).
* Referenzen müssen immer gültig sein.

Mit Referenzen und `Box<T>` werden die Invarianten der Ausleihregeln beim
Kompilieren erzwungen. Mit `RefCell<T>` werden diese Invarianten *zur Laufzeit*
erzwungen. Wenn man mit Referenzen gegen diese Regeln verstößt wird beim
Kompilieren ein Fehler angezeigt. Wenn man mit `RefCell<T>` gegen diese Regeln
verstößt, wird das Programm mit `panic` beendet.

Die Überprüfung der Ausleihregeln zur Kompilierzeit hat den Vorteil, dass
Fehler früher im Entwicklungsprozess erkannt werden und die Laufzeitperformanz
nicht beeinträchtigt wird, da die gesamte Analyse im Voraus abgeschlossen
wurde. Aus diesen Gründen ist es in den meisten Fällen die beste Wahl, die
Ausleihregeln zur Kompilierzeit zu überprüfen. Aus diesem Grund ist dies die
Standardeinstellung von Rust.

Der Vorteil der Überprüfung der Ausleihregeln zur Laufzeit besteht darin, dass
bestimmte speichersichere Szenarien zulässig sind, während sie durch die
Überprüfung zur Kompilierzeit nicht zulässig sind. Die statische Analyse
ist wie der Rust-Compiler von Natur aus konservativ. Einige Eigenschaften des
Programmcodes lassen sich durch Analyse des Programmcodes nicht erkennen: Das
bekannteste Beispiel ist das Halteproblem, das den Rahmen dieses Buches sprengt,
aber ein interessantes Thema zum Nachforschen darstellt.

Da eine Analyse nicht möglich ist, lehnt der Rust-Compiler möglicherweise ein
ein korrektes Programm ab, wenn er nicht sicher sein kann, dass der Programmcode
den Eigentümerschaftsregeln entspricht. Auf diese Art ist Rust konservativ. Wenn
es ein falsches Programm akzeptiert, können Benutzer den Garantien von Rust
nicht vertrauen. Wenn Rust jedoch ein korrektes Programm ablehnt, wird der
Programmierer belästigt, obwohl nichts negatives passieren kann. Der Typ
`RefCell<T>` ist nützlich, wenn man sicher ist, dass der Programmcode den
Ausleihregeln entspricht, der Compiler dies jedoch nicht verstehen und
garantieren kann.

Ähnlich wie `Rc<T>` ist `RefCell<T>` nur für die Verwendung in einsträngigen
(single-threaded) Szenarien vorgesehen und gibt einen Fehler beim Kompilieren
aus, wenn man versucht, es in einem mehrsträngigen (multi-threaded) Kontext zu
verwenden. Wir werden in Kapitel 16 darüber sprechen, wie man die Funktionalität 
von `RefCell<T>` in einem mehrsträngigen Programm erhält.

Eine Zusammenfassung der Gründe für die Wahl von `Box<T>`, `Rc<T>` oder
`RefCell<T>`:

* `Rc<T>` erlaubt mehrere Eigentümer derselben Daten. Mit `Box<T>` und
  `RefCell<T>` haben Daten nur einen Eigentümer.
* `Box<T>` ermöglicht unveränderliches oder veränderliches Ausleihen, das zur
  Kompilierzeit überprüft wird. `Rc<T>` erlaubt nur unveränderliches
  Ausleihen, das zur Kompilierzeit geprüft wird und `RefCell<T>`
  erlaubt unveränderliches oder veränderliches Ausleihen, das zur Laufzeit
  überprüft wird.
* Da `RefCell<T>` zur Laufzeit überprüfbares veränderliches Ausleihen zulässt,
  kann man den Wert innerhalb von `RefCell<T>` auch dann ändern, wenn
  `RefCell<T>` unveränderlich ist.

Das Ändern des Werts innerhalb eines unveränderlichen Werts ist das *innere
Veränderlichkeitsmuster*. Schauen wir uns eine Situation an, in der innere
Veränderlichkeit nützlich ist, und untersuchen, wie dies möglich ist.

### Innere Veränderlichkeit: Das veränderliche Ausleihen eines unveränderlichen Wertes

Eine Konsequenz der Ausleihregeln ist, dass man einen unveränderlichen Wert
nicht veränderlich ausleihen kann. Dieser Programmcode wird beispielsweise nicht
kompilieren:

```rust,does_not_compile
fn main() {
let x = 5;
let y = &mut x;
}
```

Wenn man versucht, diesen Programmcode zu kompilieren, wird die folgende
Fehlermeldung angezeigt:

```console
$ cargo run
   Compiling borrowing v0.1.0 (file:///projects/borrowing)
error[E0596]: cannot borrow `x` as mutable, as it is not declared as mutable
 --> src/main.rs:3:13
  |
2 |     let x = 5;
  |         - help: consider changing this to be mutable: `mut x`
3 |     let y = &mut x;
  |             ^^^^^^ cannot borrow as mutable

error: aborting due to previous error

For more information about this error, try `rustc --explain E0596`.
error: could not compile `borrowing`.

To learn more, run the command again with --verbose.
```
Es gibt jedoch Situationen, in denen es nützlich wäre, wenn ein Wert in
seinen Methoden selbst veränderlich ist, aber für einen anderen Programmcode 
unveränderlich erscheint. Programmcode außerhalb der Methoden des Werts kann
diesen nicht verändern. Die Verwendung von `RefCell<T>` ist eine Möglichkeit,
die Fähigkeit zur inneren Veränderlichkeit zu erhalten, allerdings
umgeht `RefCell<T>` die Ausleihregeln nicht vollständig: Der Ausleihenprüfer (borrow checker) im
Compiler ermöglicht diese innere Veränderlichkeit, und die Ausleihregeln werden
stattdessen zur Laufzeit überprüft. Wenn man gegen die Regeln verstößt wird
`panic` anstelle eines Fehlers beim Kompilieren ausgelöst.

Lass uns ein praktisches Beispiel durcharbeiten, in dem wir `RefCell<T>`
verwenden können, um einen unveränderlichen Wert zu ändern und herauszufinden,
warum dies nützlich ist.

#### Ein Anwendungsfall für die innere Veränderlichkeit: Mock-Objekte (Mock Objects)

Ein *Testdoppel* (test double) ist das allgemeine Programmierkonzept für einen 
Typ, der beim Testen anstelle eines anderen Typs verwendet wird. *Mock-Objekte* 
sind bestimmte Arten von Testdoppeln, die aufzeichnen, was während eines Tests
passiert, damit man bestätigen kann, dass die richtigen Aktionen ausgeführt
wurden.

Rust verfügt nicht im gleichen Sinne wie andere Programmiersprachen über
Objekte und in die Standardbibliothek integrierte Mock-Objekt-Funktionen. Man
kann jedoch definitiv eine Struktur erstellen, die denselben Zwecken dient wie
ein Mock-Objekt.

Hier ist das Szenario, das wir testen werden: Wir erstellen eine Bibliothek, die
einen Wert anhand eines Maximalwerts verfolgt und Nachrichten basierend darauf
sendet, wie nahe der Maximalwert am aktuellen Wert liegt. Diese Bibliothek kann
verwendet werden, um das Kontingent eines Benutzers für die Anzahl der
API-Aufrufe zu verfolgen, die er beispielsweise ausführen darf.

Unsere Bibliothek bietet nur die Funktionalität, zu verfolgen, wie nahe ein Wert
am Maximum liegt und wie die Nachrichten zu welchen Zeiten sein sollten.
Von Anwendungen, die unsere Bibliothek verwenden wird erwartet, dass sie den
Mechanismus zum Senden der Nachrichten bereitstellen: Die Anwendung könnte eine
Nachricht in der Anwendung anlegen, eine E-Mail senden, eine Textnachricht
senden oder etwas anderes. Die Bibliothek muss dieses Detail nicht kennen.
Alles, was es braucht, ist etwas, das ein von uns bereitgestelltes Merkmal
(trait) namens `Messenger` implementiert. Codeblock 15-20 zeigt den
Bibliothekscode:

<span class="filename">Dateiname: src/lib.rs</span>

```rust
pub trait Messenger {
    fn send(&self, msg: &str);
}

pub struct LimitTracker<'a, T: Messenger> {
    messenger: &'a T,
    value: usize,
    max: usize,
}

impl<'a, T> LimitTracker<'a, T>
where
    T: Messenger,
{
    pub fn new(messenger: &T, max: usize) -> LimitTracker<T> {
        LimitTracker {
            messenger,
            value: 0,
            max,
        }
    }

    pub fn set_value(&mut self, value: usize) {
        self.value = value;

        let percentage_of_max = self.value as f64 / self.max as f64;

        if percentage_of_max >= 1.0 {
            self.messenger.send("Fehler: Du hast dein Kontingent überschritten!");
        } else if percentage_of_max >= 0.9 {
            self.messenger
                .send("Dringliche Warnung: Du hast über 90% deines Kontingents verbraucht!");
        } else if percentage_of_max >= 0.75 {
            self.messenger
                .send("Warnung: Du hast über 75% deines Kontingents verbraucht!");
        }
    }
}
```

<span class="caption">Codeblock 15-20: Eine Bibliothek um zu verfolgen, wie nahe
ein Wert an einem Maximalwert liegt, und um zu warnen, wenn der Wert über
bestimmten Schwellwerten liegt</span>

Ein wichtiger Teil dieses Programmcodes ist, dass das Merkmal `Messenger` eine
Methode namens `send` hat, die eine unveränderliche Referenz auf `self` und den
Text der Nachricht enthält. Dies ist die Schnittstelle, die unser Mock-Objekt
haben muss. Der andere wichtige Teil ist, dass wir das Verhalten der Methode
`set_value` auf dem `LimitTracker` testen möchten. Wir können ändern, was wir
für den Parameter `value` übergeben, aber `set_value` auf dem `LimitTracker`
testen möchten. Wir können ändern, was wir für den Parameter `value` übergeben,
aber `set_value` gibt nichts zurück, worüber wir Aussagen machen können. Wir
möchten sagen können, dass, wenn wir einen `LimitTracker` mit etwas das das
Merkmal `Messenger` implementiert erstellen und einen bestimmten Wert für `max`,
wenn wir unterschiedliche Zahlen für `value` übergeben, der Messenger angewiesen
wird entsprechende Nachrichten zu senden.

Wir benötigen ein Mock-Objekt, das anstelle einer E-Mail oder einer
Textnachricht beim Aufrufen von `send` nur die Nachrichten verfolgt, die
gesendet werden sollen. Wir können eine neue Instanz des Mock-Objekts estellen,
einen `LimitTracker` erstellen, der das Mock-Objekt verwendet, die
`set_value`-Methode für `LimitTracker` aufrufen und dann überprüfen, ob das
Mock-Objekt die erwarteten Nachrichten enthält. Codeblock 15-21 zeigt den
Versuch, ein Mock-Objekt zu implementieren, um genau das zu tun, aber der
Ausleihenprüfer erlaubt dies nicht:

<span class="filename">Dateiname: src/lib.rs</span>

```rust,does_not_compile
# pub trait Messenger {
#     fn send(&self, msg: &str);
# }
# 
# pub struct LimitTracker<'a, T: Messenger> {
#     messenger: &'a T,
#     value: usize,
#     max: usize,
# }
# 
# impl<'a, T> LimitTracker<'a, T>
# where
#     T: Messenger,
# {
#     pub fn new(messenger: &T, max: usize) -> LimitTracker<T> {
#         LimitTracker {
#             messenger,
#             value: 0,
#             max,
#         }
#     }
# 
#     pub fn set_value(&mut self, value: usize) {
#         self.value = value;
# 
#         let percentage_of_max = self.value as f64 / self.max as f64;
# 
#         if percentage_of_max >= 1.0 {
#             self.messenger.send("Fehler: Du hast dein Kontingent überschritten!");
#         } else if percentage_of_max >= 0.9 {
#             self.messenger
#                 .send("Dringliche Warnung: Du hast über 90% deines Kontingents verbraucht!");
#         } else if percentage_of_max >= 0.75 {
#             self.messenger
#                 .send("Warnung: Du hast über 50% deines Kontingents verbraucht!");
#         }
#     }
# }
# 
#[cfg(test)]
mod tests {
    use super::*;

    struct MockMessenger {
        sent_messages: Vec<String>,
    }

    impl MockMessenger {
        fn new() -> MockMessenger {
            MockMessenger {
                sent_messages: vec![],
            }
        }
    }

    impl Messenger for MockMessenger {
        fn send(&self, message: &str) {
            self.sent_messages.push(String::from(message));
        }
    }

    #[test]
    fn it_sends_an_over_75_percent_warning_message() {
        let mock_messenger = MockMessenger::new();
        let mut limit_tracker = LimitTracker::new(&mock_messenger, 100);

        limit_tracker.set_value(80);

        assert_eq!(mock_messenger.sent_messages.len(), 1);
    }
}
```

<span class="caption">Codeblock 15-21: Der Versuch einen `MockMessenger` zu
implementieren, der vom Ausleihenprüfer nicht erlaubt wird</span>

Dieser Testcode definiert eine Struktur `MockMessenger` mit einem
`sent_messages`-Feld mit einem `Vec` von `String`-Werten, um Nachrichten zu
verfolgen, die gesendet werden sollen. Wir definieren auch eine zugehörige
Funktion `new`, um das Erstellen neuer `MockMessenger`-Werte zu vereinfachen,
die mit einer leeren Liste von Nachrichten beginnen. Wir implementieren dann das
Merkmal `Messenger` für `MockMessenger` damit wir einem `LimitTracker` einen
`MockMessenger` übergeben können. Bei der Definition der Methode `send` nehmen wir
die übergebene Nachricht als Parameter und speichern sie in der Liste
`sent_messages` von `MockMessenger`.

Im Test testen wir, was passiert, wenn dem `LimitTracker` gesagt wird, er solle
`value` auf etwas setzen, das mehr als 75 Prozent des `max`-Wertes beträgt.
Zuerst erstellen wir einen neuen `MockMessenger`, der mit einer leeren
Nachrichtenliste beginnt. Dann erstellen wir einen neuen `LimitTracker` und
geben ihm eine Referenz auf den neuen `MockMessenger` und einen `max`-Wert von
100. Wir rufen die Methode `set_value` auf `LimitTracker` mit dem Wert 80 auf,
was mehr als 75 Prozent von 100 ist. Dann stellen wir sicher, dass die
Nachrichtenliste, die der `MockMessenger` verwaltet, nun eine einzige Nachricht
enthalten sollte.

Es gibt jedoch ein Problem mit diesem Test, wie hier gezeigt:

```text
$ cargo test
   Compiling limit-tracker v0.1.0 (file:///projects/limit-tracker)
error[E0596]: cannot borrow `self.sent_messages` as mutable, as it is behind a `&` reference
  --> src/lib.rs:58:13
   |
57 |         fn send(&self, message: &str) {
   |                 ----- help: consider changing this to be a mutable reference: `&mut self`
58 |             self.sent_messages.push(String::from(message));
   |             ^^^^^^^^^^^^^^^^^^ `self` is a `&` reference, so the data it refers to cannot be borrowed as mutable

error: aborting due to previous error

For more information about this error, try `rustc --explain E0596`.
error: could not compile `limit-tracker`.

To learn more, run the command again with --verbose.
```

Wir können den `MockMessenger` nicht ändern, um die Nachrichten zu verfolgen, da
die `send`-Methode eine unveränderliche Referenz auf `self` verwendet. Wir
können auch nicht den Vorschlag aus dem Fehlertext übernehmen, stattdessen 
`&mut self` zu verwenden, da die Signatur von `send`nicht mit der Signatur in 
der Merkmalsdefinition von `Messenger` übereinstimmt (probiere es gerne aus und
schau dir die Fehlermeldung an, die dabei ausgegeben wird).

Dies ist eine Situation, in der innere Veränderlichkeit helfen kann! Wir
speichern die `send_messages` in einer `RefCell<T>` und dann kann die
`send`-Nachricht `sent_messages` ändern, um Nachrichten zu speichern, die wir
gesehen haben. Codeblock 15-22 zeigt, wie das aussieht:

<span class="filename">Dateiname: src/lib.rs</span>

```rust
# pub trait Messenger {
#     fn send(&self, msg: &str);
# }
# 
# pub struct LimitTracker<'a, T: Messenger> {
#     messenger: &'a T,
#     value: usize,
#     max: usize,
# }
# 
# impl<'a, T> LimitTracker<'a, T>
# where
#     T: Messenger,
# {
#     pub fn new(messenger: &T, max: usize) -> LimitTracker<T> {
#         LimitTracker {
#             messenger,
#             value: 0,
#             max,
#         }
#     }
# 
#     pub fn set_value(&mut self, value: usize) {
#         self.value = value;
# 
#         let percentage_of_max = self.value as f64 / self.max as f64;
# 
#         if percentage_of_max >= 1.0 {
#             self.messenger.send("Fehler: Du hast dein Kontingent überschritten!");
#         } else if percentage_of_max >= 0.9 {
#             self.messenger
#                 .send("Dringliche Warnung: Du hast über 90% deines Kontingents verbraucht!");
#         } else if percentage_of_max >= 0.75 {
#             self.messenger
#                 .send("Warnung: Du hast über 50% deines Kontingents verbraucht!");
#         }
#     }
# }
# 
#[cfg(test)]
mod tests {
    use super::*;
    use std::cell::RefCell;

    struct MockMessenger {
        sent_messages: RefCell<Vec<String>>,
    }

    impl MockMessenger {
        fn new() -> MockMessenger {
            MockMessenger {
                sent_messages: RefCell::new(vec![]),
            }
        }
    }

    impl Messenger for MockMessenger {
        fn send(&self, message: &str) {
            self.sent_messages.borrow_mut().push(String::from(message));
        }
    }

    #[test]
    fn it_sends_an_over_75_percent_warning_message() {
        // --abschneiden--

#         let mock_messenger = MockMessenger::new();
#         let mut limit_tracker = LimitTracker::new(&mock_messenger, 100);
# 
#         limit_tracker.set_value(80);
# 
        assert_eq!(mock_messenger.sent_messages.borrow().len(), 1);
    }
}
# 
# fn main() {}
```

<span class="caption">Codeblock 15-22: `RefCell<T>` verwenden, um einen inneren
Wert zu verändern, während der äußere Wert als unveränderlich betrachtet wird</span>

Das Feld `sent_messages` ist jetzt vom Typ `RefCell<Vec<String>>` anstelle von
`Vec<String>`. In der Funktion `new` erstellen wir eine neue 
`RefCell<Vec<Sting>>`-Instanz um den leeren Vektor.

Für die Implementierung der `send`-Methode ist der erste Parameter immer noch
eine unveränderliche Ausleihe von `self`, die der Merkmalsdefinition entspricht.
Wir rufen `borrow_mut` auf der `RefCell<Vec<String>>` in `self.sent_messages` auf,
um eine veränderliche Referenz auf den Wert in der `RefCell<Vec<String>>` zu
erhalten, der der Vektor ist. Dann können wir `push` auf der veränderlichen
Referenz zum Vektor aufrufen, um die während des Tests gesendeten Nachrichten zu
verfolgen.

Die letzte Änderung, die wir vornehmen müssen, betrifft die Behauptung: Um zu
sehen, wie viele Elemente sich im inneren Vektor befinden, rufen wir in der
`RefCell<Vec<String>>` `borrow` auf, um eine unveränderliche Referenz auf den
Vektor zu erhalten.

Nachdem du nun gesehen hast, wie du `RefCell<T>` verwendest, wollen wir uns mit
der Funktionsweise befassen.

#### Mit `RefCell<T>` den Überblick über die Ausleihen zur Laufzeit behalten

Beim Erstellen unveränderlicher und veränderlicher Referenzen verwenden wir die
Syntax `&` bzw. `&mut`. Bei `RefCell<T>` verwenden wir die Methoden `borrow` und
`borrow_mut`, die Teil der sicheren API sind, die zu `RefCell<T>` gehört. Die
Methode `borrow` gibt den intelligenten Zeigertyp `Ref<T>` zurück und
`borrow_mut` den intelligenten Zeigertyp `RefMut<T>`. Beide Typen
implementieren `Deref`, sodass wir sie wie reguläre Referenzen behandeln
können.

Der `RefCell<T>` verfolgt, wie viele intelligente Zeiger `Ref<T>` und `RefMut<T>`
derzeit aktiv sind. Jedes Mal, wenn wir `borrow` aufrufen, erhöht `RefCell<T>`
die Anzahl der aktiven unveränderlichen Ausleihen. Wenn ein `Ref<T>`-Wert
außerhalb des Gültigkeitsbereichs (scope) liegt, sinkt die Anzahl der unveränderlichen
Ausleihen um eins. Genau wie bei den Ausleihregeln zur Kompilierzeit können
wir mit `RefCell<T>` zu jedem Zeitpunkt viele unveränderliche Ausleihen oder eine
veränderliche Ausleihe haben.

Wenn wir versuchen, diese Regeln zu verletzen, erhalten wir keinen
Kompilierfehler wie bei Referenzen, sondern die Implementierung von
`RefCell<T>` wird zur Laufzeit abstürzen. Codeblock 15-23 zeigt eine
Modifikation der Implementierung von `send` in Codeblock 15-22. Wir versuchen
absichtlich, zwei veränderliche Ausleihen zu erstellen, die für denselben
Bereich aktiv sind, um zu veranschaulichen, dass `RefCell<T>` uns daran
hindert, dies zur Laufzeit zu tun.

<span class="filename">Dateiname: src/lib.rs</span>

```rust,panics
# pub trait Messenger {
#     fn send(&self, msg: &str);
# }
# 
# pub struct LimitTracker<'a, T: Messenger> {
#     messenger: &'a T,
#     value: usize,
#     max: usize,
# }
# 
# impl<'a, T> LimitTracker<'a, T>
# where
#     T: Messenger,
# {
#     pub fn new(messenger: &T, max: usize) -> LimitTracker<T> {
#         LimitTracker {
#             messenger,
#             value: 0,
#             max,
#         }
#     }
# 
#     pub fn set_value(&mut self, value: usize) {
#         self.value = value;
# 
#         let percentage_of_max = self.value as f64 / self.max as f64;
# 
#         if percentage_of_max >= 1.0 {
#             self.messenger.send("Fehler: Du hast dein Kontingent überschritten!");
#         } else if percentage_of_max >= 0.9 {
#             self.messenger
#                 .send("Dringliche Warnung: Du hast über 90% deines Kontingents verbraucht!");
#         } else if percentage_of_max >= 0.75 {
#             self.messenger
#                 .send("Warnung: Du hast über 50% deines Kontingents verbraucht!");
#         }
#     }
# }
# 
# #[cfg(test)]
# mod tests {
#     use super::*;
#     use std::cell::RefCell;
# 
#     struct MockMessenger {
#         sent_messages: RefCell<Vec<String>>,
#     }
# 
#     impl MockMessenger {
#         fn new() -> MockMessenger {
#             MockMessenger {
#                 sent_messages: RefCell::new(vec![]),
#             }
#         }
#     }
# 
    impl Messenger for MockMessenger {
        fn send(&self, message: &str) {
            let mut one_borrow = self.sent_messages.borrow_mut();
            let mut two_borrow = self.sent_messages.borrow_mut();

            one_borrow.push(String::from(message));
            two_borrow.push(String::from(message));
        }
    }
# 
#     #[test]
#     fn it_sends_an_over_75_percent_warning_message() {
#         let mock_messenger = MockMessenger::new();
#         let mut limit_tracker = LimitTracker::new(&mock_messenger, 100);
# 
#         limit_tracker.set_value(80);
# 
#         assert_eq!(mock_messenger.sent_messages.borrow().len(), 1);
#     }
# }
```
<span class="caption">Codeblock 15-23: Wir erstellen zwei veränderliche Referenzen im
selben Gültigkeitsbereich, um zu sehen, dass `RefCell<T>` abstürzt</span>

Wir erstellen eine Variable `one_borrow` für den intelligenten Zeiger 
`RefMut<T>`, der von `borrow_mut` zurückgegeben wird. Dann erstellen wir auf die
gleiche Weise eine weitere veränderliche Ausleihe in der Variable `two_borrow`.
Dadurch werden zwei veränderbare Referenzen im selben Bereich erstellt, was
nicht zulässig ist. Wenn wir die Tests für unsere Bibliothek ausführen, wird der
Programmcode in Codeblock 15-23 fehlerfrei kompiliert, aber der Test schlägt
fehl: 

```console
$ cargo test
   Compiling limit-tracker v0.1.0 (file:///projects/limit-tracker)
    Finished test [unoptimized + debuginfo] target(s) in 0.91s
     Running target/debug/deps/limit_tracker-d1b2637139dca6ca

running 1 test
test tests::it_sends_an_over_75_percent_warning_message ... FAILED

failures:

---- tests::it_sends_an_over_75_percent_warning_message stdout ----
thread 'main' panicked at 'already borrowed: BorrowMutError', src/libcore/result.rs:1188:5
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace.


failures:
tests::it_sends_an_over_75_percent_warning_message

test result: FAILED. 0 passed; 1 failed; 0 ignored; 0 measured; 0 filtered out
```
Beachte, dass der Programmcode mit der Meldung `already borrowed:
BorrowMutError` abstürzt. Auf diese Weise behandelt `RefCell<T>` zur
Laufzeit Verstöße gegen die Ausleihregel.

Das Abfangen von Ausleihfehlern zur Laufzeit anstelle der Kompilierzeit
bedeutet, dass man später im Entwicklungsprozess einen Fehler im Programmcode
finden und möglicherweise erst, wenn das Programm für die Produktion
bereitgestellt wurde. Außerdem würde dieser Programmcode eine kleine
Beeinträchtigung der Laufzeitperformanz verursachen, da die Ausleihen zur Laufzeit
und nicht zur Kompilierzeit nachverfolgt werden. Die Verwendung von
`RefCell<T>` ermöglicht es jedoch, ein Mock-Objekt zu schreiben, das sich selbst
ändern kann, um die Nachrichten zu verfolgen, die es gesehen hat, während man es
in einem Kontext verwendet, in dem nur unveränderliche Werte zulässig sind. Man
kann `RefCell<T>` trotz seiner Kompromisse verwenden, um mehr Funktionen zu
erhalten, als reguläre Referenzen bieten.

### Mehrere Eigentümer veränderlicher Daten durch Kombinieren von `Rc<T>` und `RefCell<T>`

Eine übliche Methode zur Verwendung von `RefCell<T>` ist die Kombination mit
`Rc<T>`. Erinnere dich, dass man mit `Rc<T>` mehrere Eigentümer einiger Daten
haben kann, aber nur unveränderlichen Zugriff auf diese Daten erhält. Wenn
man eine `Rc<T>` hat, das eine `RefCell<T>` enthält, kann man einen Wert
erhalten, der mehrere Eigentümer hat *und* veränderlich ist!

Erinnern wir uns beispielsweise an das Beispiel für die Cons-Liste in Codeblock
15-18, in dem wir `Rc<T>` verwendet haben, um mehrere Listen die gemeinsame
Nutzung einer anderen Liste zu ermöglichen. Da `Rc<T>` nur unveränderliche Werte
enthält, können wir keinen der Werte in der Liste ändern, sobald wir sie
erstellt haben. Fügen wir `RefCell<T>` hinzu, um die Werte in den Listen ändern
zu können. Codeblock 15-24 zeigt, dass wir durch Verwendung einer `RefCell<T>`
in der Cons-Definition den in allen Listen gespeicherten Wert ändern können:

<span class="filename">Dateiname: src/main.rs</span>

```rust
#[derive(Debug)]
enum List {
    Cons(Rc<RefCell<i32>>, Rc<List>),
    Nil,
}

use crate::List::{Cons, Nil};
use std::cell::RefCell;
use std::rc::Rc;

fn main() {
    let value = Rc::new(RefCell::new(5));

    let a = Rc::new(Cons(Rc::clone(&value), Rc::new(Nil)));

    let b = Cons(Rc::new(RefCell::new(3)), Rc::clone(&a));
    let c = Cons(Rc::new(RefCell::new(4)), Rc::clone(&a));

    *value.borrow_mut() += 10;

    println!("a after = {:?}", a);
    println!("b after = {:?}", b);
    println!("c after = {:?}", c);
}
```

<span class="caption">Codeblock 15-24: Verwendung von `Rc<RefCell<i32>>` um `List`
zu erstellen, die wir verändern können</span>

Wir erstellen einen Wert, der eine Instanz von `Rc<RefCell<i32>>` ist, und
speichern ihn dann in einer Variable mit dem Namen `value`, damit wir später
direkt darauf zugreifen können. Dann erstellen wir eine Liste in `a` mit einer
`Cons`-Variante, die `value` enthält. Wir müssen `value` klonen, damit sowohl 
`a` als auch `value` Eigentümerschaft am inneren Wert `5` haben, anstatt das
Eigentum von `value` auf `a` zu übertragen oder `a` von `value` auszuleihen.

Wir wickeln die Liste `a` in ein `Rc<T>` ein. Wenn wir also die Listen `b` und
`c` erstellen, können beide auf `a` verweisen, was wir in Codeblock 15-18 getan
haben.

Nachdem wir die Listen `a`, `b` und `c` erstellt haben, addieren wir 10 zum Wert
in `value`. Dazu rufen wir `borrow_mut` für `value` auf, wobei die in Kapitel 5
beschriebene automatische Dereferenzierung verwendet wird 
(siehe Abschnitt [„Wo ist der Operator `->`?“][wheres-the-operator]), um den
`Rc<T>` auf den inneren `RefCell<T>`-Wert zu dereferenzieren. Die
`borrow_mut`-Methode gibt einen intelligenten Zeiger `RefMut<T>` zurück, und wir
verwenden den Dereferenzierungsoperator darauf und ändern den inneren Wert.

Wenn wir `a`, `b` und `c` ausgeben, können wir sehen, dass sie alle den
veränderten Wert 15 anstelle von 5 haben:

```console
$ cargo run
   Compiling cons-list v0.1.0 (file:///projects/cons-list)
    Finished dev [unoptimized + debuginfo] target(s) in 0.63s
     Running `target/debug/cons-list`
a after = Cons(RefCell { value: 15 }, Nil)
b after = Cons(RefCell { value: 3 }, Cons(RefCell { value: 15 }, Nil))
c after = Cons(RefCell { value: 4 }, Cons(RefCell { value: 15 }, Nil))
```

Diese Technik ist ziemlich sauber! Durch die Verwendung von `RefCell<T>` haben
wir einen nach außen unveränderlichen `List`-Wert. Wir können jedoch die
Methoden für `RefCell<T>` verwenden, die den Zugriff auf die innere
Veränderlichkeit ermöglichen, damit wir unsere Daten bei Bedarf ändern können.
Die Laufzeitprüfungen der Ausleihregeln schützen uns vor
Daten-Wettlaufsituationen (data races), und manchmal lohnt es sich, ein wenig
Geschwindigkeit für diese Flexibilität in unseren Datenstrukturen
einzutauschen.

Die Standardbibliothek verfügt über andere Typen, die eine innere
Veränderlichkeit bieten, z.B. `Cell<T>`, die ähnlich ist, mit der Ausnahme, dass
der Wert nicht auf den inneren Wert referenziert, sondern in die `Cell<T>` hinein 
und aus dieser herauskopiert wird. Es gibt auch `Mutex<T>`, das eine innere
Veränderlichkeit bietet, die sicher über Stränge (threads) hinweg verwendet
werden kann. Wir werden die Verwendung in Kapitel 16 erläutern. Weitere
Informationen zu den Unterschieden zwischen diesen Typen findest du in den
Standardbibliotheksdokumenten.

[wheres-the-operator]: ch05-03-method-syntax.html#wo-ist-der-operator--
