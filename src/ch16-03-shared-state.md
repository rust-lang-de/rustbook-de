## Nebenläufigkeit mit gemeinsamem Zustand

Die Nachrichtenübermittlung ist eine gute Methode zur Behandlung von
Nebenläufigkeit, aber sie ist nicht die einzige. Eine andere Methode wäre, dass
mehrere Stränge auf dieselben gemeinsamen Daten zugreifen. Betrachte folgenden
Teil des Slogans aus der Go-Sprachdokumentation noch einmal: „Kommuniziere
nicht, indem du Arbeitsspeicher teilst.“
                                                    
Wie würde Kommunikation durch gemeinsame Nutzung von Arbeitsspeicher aussehen?
Und warum sollten Liebhaber der Nachrichtenübermittlung davor warnen,
gemeinsamen Arbeitsspeicher zu verwenden?

In gewisser Weise ähneln Kanäle in jeder Programmiersprache dem Alleineigentum,
denn sobald du einen Wert in einen Kanal übertragen hast, solltest du diesen
Wert nicht mehr verwenden. Nebenläufigkeit mit gemeinsam genutztem
Arbeitsspeicher ist wie Mehrfacheigentum: Mehrere Stränge können gleichzeitig
auf denselben Speicherplatz zugreifen. Wie du in Kapitel 15 gesehen hast, wo
intelligente Zeiger Mehrfacheigentum ermöglichten, kann Mehrfacheigentum zu
zusätzlicher Komplexität führen, da die verschiedenen Eigentümer verwaltet
werden müssen. Das Typsystem und die Eigentumsregeln von Rust sind eine große
Hilfe, um diese Verwaltung korrekt zu gestalten. Betrachten wir als Beispiel
den Mutex, eines der gebräuchlicheren Nebenläufigkeitsprimitive für gemeinsam
genutzten Speicher.

### Verwenden von Mutex, um Datenzugriff von jeweils einem Strang zu ermöglichen

*Mutex* ist eine Abkürzung für *mutual exclusion* (engl. wechselseitiger
Ausschluss), da ein Mutex zu einem bestimmten Zeitpunkt nur einem Strang
(thread) den Zugriff auf einige Daten erlaubt. Um auf die Daten in einem Mutex
zuzugreifen, muss ein Strang zunächst signalisieren, dass er Zugriff wünscht,
indem er darum bittet, die *Sperre* (lock) des Mutex zu erwerben. Die Sperre
ist eine Datenstruktur, die Teil des Mutex ist, der verfolgt, wer derzeit
exklusiven Zugriff auf die Daten hat. Daher wird der Mutex als *Schutz* der
Daten beschrieben, die er über das Schließsystem hält.

Mutexe haben den Ruf, dass sie schwierig anzuwenden sind, weil man sich zwei
Regeln merken muss:

* Du musst versuchen, die Sperre zu erwerben, bevor du die Daten verwendest.
* Wenn du mit den Daten, die der Mutex schützt, fertig bist, musst du die Daten
  entsperren, damit andere Stränge die Sperre übernehmen können.

Als reale Metapher für einen Mutex stelle dir eine Podiumsdiskussion auf einer
Konferenz mit nur einem Mikrofon vor. Bevor ein Podiumsteilnehmer das Wort
ergreifen kann, muss er fragen oder signalisieren, dass er das Mikrofon
benutzen möchte. Wenn er das Mikrofon erhält, kann er so lange sprechen, wie er
möchte, und das Mikrofon dann dem nächsten Diskussionsteilnehmer übergeben, der
um das Wort bittet. Wenn ein Diskussionsteilnehmer vergisst, das Mikrofon
abzugeben, wenn er damit fertig ist, kann kein anderer mehr sprechen. Wenn die
Verwaltung des gemeinsam genutzten Mikrofons schief geht, funktioniert das
Podium nicht wie geplant!

Das Management von Mutexen kann unglaublich schwierig sein, weshalb so viele
Menschen von Kanälen begeistert sind. Dank des Typsystems und der
Eigentumsregeln von Rust kann man jedoch beim Sperren und Entsperren nichts
falsch machen.

#### Die API von `Mutex<T>`

Als Beispiel für die Verwendung eines Mutex beginnen wir mit der Verwendung
eines Mutex in einem einsträngigen (single-threaded) Kontext, wie in Codeblock
16-12 gezeigt:

<span class="filename">Dateiname: src/main.rs</span>

```rust
use std::sync::Mutex;

fn main() {
    let m = Mutex::new(5);

    {
        let mut num = m.lock().unwrap();
        *num = 6;
    }

    println!("m = {m:?}");
}
```

<span class="caption">Codeblock 16-12: Untersuchen der API von `Mutex<T>` in
einem einsträngigen Kontext zur Vereinfachung</span>

Wie bei vielen Typen erzeugen wir einen `Mutex<T>` mit der zugehörigen Funktion
`new`. Um auf die Daten innerhalb des Mutex zuzugreifen, verwenden wir die
Methode `lock`, um die Sperre zu erhalten. Dieser Aufruf blockiert den
aktuellen Strang, sodass er keine Arbeit verrichten kann, bis wir an der Reihe
sind, die Sperre zu haben.

Der Aufruf von `lock` würde fehlschlagen, wenn ein anderer Strang, der die
Sperre hält, abstürzte. In diesem Fall wäre niemand jemals in der Lage, die
Sperre zu erhalten, also haben wir uns entschieden, `unwrap` zu benutzen und
diesen Strang abstürzen zu lassen, wenn wir uns in dieser Situation befinden.

Nachdem wir die Sperre erworben haben, können wir den Rückgabewert, in diesem
Fall `num` genannt, als veränderbare Referenz auf die darin enthaltenen Daten
verwenden. Das Typsystem stellt sicher, dass wir eine Sperre erwerben, bevor
wir den Wert in `m` verwenden. Der Typ von `m` ist `Mutex<i32>`, nicht `i32`,
also *müssen* wir `lock` aufrufen, um den `i32`-Wert verwenden zu können. Wir
können das nicht vergessen, das Typsystem würde uns sonst keinen Zugriff auf
das innere `i32` erlauben.

Wie du vielleicht vermutest, ist `Mutex<T>` ein intelligenter Zeiger. Genauer
gesagt gibt der Aufruf von `lock` einen intelligenten Zeiger namens
`MutexGuard` zurück, der in ein `LockResult` verpackt ist, das wir mit dem
Aufruf von `unwrap` behandelt haben. Der intelligente Zeiger `MutexGuard`
implementiert `Deref`, um auf unsere inneren Daten zu zeigen; der intelligente
Zeiger hat auch eine `Drop`-Implementierung, die die Sperre automatisch
aufhebt, wenn ein `MutexGuard` den Gültigkeitsbereich verlässt, was am Ende des
inneren Gültigkeitsbereichs geschieht. Dadurch laufen wir nicht Gefahr, zu
vergessen, die Sperre freizugeben und die Verwendung des Mutex durch andere
Stränge zu blockieren, da die Freigabe der Sperre automatisch erfolgt.

Nachdem wir die Sperre aufgehoben haben, können wir den Mutex-Wert ausgeben und
sehen, dass wir den inneren `i32` in 6 ändern konnten.

#### Gemeinsames Nutzen eines `Mutex<T>` von mehreren Strängen

Versuchen wir nun, einen Wert zwischen mehreren Strängen mit `Mutex<T>` zu
teilen. Wir starten 10 Stränge und lassen sie jeweils einen Zählerwert um 1
erhöhen, sodass der Zähler von 0 auf 10 geht. Das nächste Beispiel in Codeblock
16-13 wird einen Kompilierfehler haben und wir werden diesen Fehler verwenden,
um mehr über die Verwendung von `Mutex<T>` zu erfahren und darüber, wie Rust
uns hilft, ihn korrekt zu verwenden.

<span class="filename">Dateiname: src/main.rs</span>

```rust,does_not_compile
use std::sync::Mutex;
use std::thread;

fn main() {
    let counter = Mutex::new(0);
    let mut handles = vec![];

    for _ in 0..10 {
        let handle = thread::spawn(move || {
            let mut num = counter.lock().unwrap();

            *num += 1;
        });
        handles.push(handle);
    }

    for handle in handles {
        handle.join().unwrap();
    }

    println!("Ergebnis: {}", *counter.lock().unwrap());
}
```

<span class="caption">Codeblock 16-13: Zehn Stränge inkrementieren jeweils
einen Zähler, der durch einen `Mutex<T>` geschützt ist</span>

Wir erstellen eine Variable `counter`, um ein `i32` innerhalb eines `Mutex<T>`
zu halten, wie wir es in Codeblock 16-12 getan haben. Als Nächstes erstellen
wir 10 Stränge, indem wir über einen Zahlenbereich iterieren. Wir verwenden
`thread::spawn` und geben allen Strängen den gleichen Funktionsabschluss
(closure), der den Zähler in den Strang verschiebt, eine Sperre auf dem
`Mutex<T>` durch Aufrufen der `lock`-Methode erwirbt und dann 1 zum Wert im
Mutex addiert. Wenn ein Strang die Ausführung seines Funktionsabschlusses
beendet hat, verlässt `num` den Gültigkeitsbereich und gibt die Sperre frei,
sodass ein anderer Strang sie erwerben kann.

Im Hauptstrang sammeln wir alle `JoinHandle`. Dann rufen wir, wie wir es in
Codeblock 16-2 getan haben, `join` auf jedem Strang auf, um sicherzustellen,
dass alle Stränge beendet sind. An diesem Punkt erhält der Hauptstrang die
Sperre und gibt das Ergebnis dieses Programms aus.

Wir haben angedeutet, dass sich dieses Beispiel nicht kompilieren lässt. Jetzt
wollen wir herausfinden, warum!

```console
$ cargo run
   Compiling shared-state v0.1.0 (file:///projects/shared-state)
error[E0382]: borrow of moved value: `counter`
  --> src/main.rs:21:29
   |
5  |     let counter = Mutex::new(0);
   |         ------- move occurs because `counter` has type `Mutex<i32>`, which does not implement the `Copy` trait
...
8  |     for _ in 0..10 {
   |     -------------- inside of this loop
9  |         let handle = thread::spawn(move || {
   |                                    ------- value moved into closure here, in previous iteration of loop
...
21 |     println!("Result: {}", *counter.lock().unwrap());
   |                             ^^^^^^^ value borrowed here after move
   |
help: consider moving the expression out of the loop so it is only moved once
   |
8  ~     let mut value = counter.lock();
9  ~     for _ in 0..10 {
10 |         let handle = thread::spawn(move || {
11 ~             let mut num = value.unwrap();
   |

For more information about this error, try `rustc --explain E0382`.
error: could not compile `shared-state` (bin "shared-state") due to 1 previous error
```

Die Fehlermeldung besagt, dass der Wert `counter` in der vorherigen Iteration
der Schleife verschoben wurde. Rust sagt uns, dass wir die Eigentümerschaft von
`counter` nicht in mehrere Stränge verschieben können. Lass uns den
Kompilierfehler mit einer Mehrfacheigentums-Methode beheben, die wir in Kapitel
15 besprochen haben.

#### Mehrfacheigentum mit mehreren Strängen

In Kapitel 15 gaben wir einen Wert mit mehreren Eigentümern an, indem wir den
intelligenten Zeiger `Rc<T>` verwendeten, um einen Referenzzählwert zu
erstellen. Lass uns hier das Gleiche tun und sehen, was passiert. Wir packen
den `Mutex<T>` in `Rc<T>` in Codeblock 16-14 ein und klonen den `Rc<T>`, bevor
wir die Eigentümerschaft an den Strang übertragen.

<span class="filename">Dateiname: src/main.rs</span>

```rust,does_not_compile
use std::rc::Rc;
use std::sync::Mutex;
use std::thread;

fn main() {
    let counter = Rc::new(Mutex::new(0));
    let mut handles = vec![];

    for _ in 0..10 {
        let counter = Rc::clone(&counter);
        let handle = thread::spawn(move || {
            let mut num = counter.lock().unwrap();

            *num += 1;
        });
        handles.push(handle);
    }

    for handle in handles {
        handle.join().unwrap();
    }

    println!("Ergebnis: {}", *counter.lock().unwrap());
}
```

<span class="caption">Codeblock 16-14: Versuch, `Rc<T>` zu verwenden, um
mehreren Strängen zu erlauben, den `Mutex<T>` zu besitzen</span>

Wir kompilieren nochmal und bekommen ... verschiedene Fehler! Der Compiler
lehrt uns eine Menge.

```console
$ cargo run
   Compiling shared-state v0.1.0 (file:///projects/shared-state)
error[E0277]: `Rc<Mutex<i32>>` cannot be sent between threads safely
  --> src/main.rs:11:36
   |
11 |           let handle = thread::spawn(move || {
   |                        ------------- ^------
   |                        |             |
   |  ______________________|_____________within this `{closure@src/main.rs:11:36: 11:43}`
   | |                      |
   | |                      required by a bound introduced by this call
12 | |             let mut num = counter.lock().unwrap();
13 | |
14 | |             *num += 1;
15 | |         });
   | |_________^ `Rc<Mutex<i32>>` cannot be sent between threads safely
   |
   = help: within `{closure@src/main.rs:11:36: 11:43}`, the trait `Send` is not implemented for `Rc<Mutex<i32>>`
note: required because it's used within this closure
  --> src/main.rs:11:36
   |
11 |         let handle = thread::spawn(move || {
   |                                    ^^^^^^^
note: required by a bound in `spawn`
  --> /rustc/07dca489ac2d933c78d3c5158e3f43beef/library/std/src/thread/mod.rs:678:1

For more information about this error, try `rustc --explain E0277`.
error: could not compile `shared-state` (bin "shared-state") due to 1 previous error
```

Toll, diese Fehlermeldung ist sehr wortreich! Hier ist der wichtige Teil, auf
den wir uns konzentrieren müssen: `Rc<Mutex<i32>>` kann nicht sicher zwischen
Strängen gesendet werden. Der Compiler teilt uns auch den Grund dafür mit: Das
Merkmal (trait) `Send` ist für `Rc<Mutex<i32>>` nicht implementiert. Wir werden
im nächsten Abschnitt über `Send` sprechen: Es ist eines der Merkmale, das
sicherstellt, dass die Typen, die wir mit Strängen verwenden, für die
Verwendung in nebenläufigen Situationen gedacht sind.

Leider ist es nicht sicher, `Rc<T>` über verschiedene Stränge hinweg gemeinsam
zu nutzen. Wenn `Rc<T>` den Referenzzähler verwaltet, inkrementiert es den
Zähler bei jedem Aufruf von `clone` und dekrementiert den Zähler bei jedem
Klon, der aufgeräumt wird. Es werden jedoch keine Nebenläufigkeitsprimitive
verwendet, um sicherzustellen, dass Änderungen am Zähler nicht durch einen
anderen Strang unterbrochen werden können. Dies könnte zu falschen Zählungen
führen &ndash; subtile Fehler, die wiederum zu Speicherlecks (memory leaks)
oder zum Aufräumen eines Wertes führen könnten, obwohl wir ihn noch nutzen
wollen. Was wir brauchen, ist ein Typ genau wie `Rc<T>`, aber einer, der
Änderungen am Referenzzähler auf Strang-sichere Weise vornimmt.

#### Atomare Referenzzählung mit `Arc<T>`

Glücklicherweise ist `Arc<T>` ein Typ wie `Rc<T>`, der in nebenläufigen
Situationen sicher zu verwenden ist. Das *a* steht für *atomar*, d.h. es
handelt sich um einen *atomar referenzgezählten* (atomically reference
counted) Typ. Atomare Typen (atomics) sind eine zusätzliche Art von
Nebenläufigkeitsprimitiven, die wir hier nicht im Detail behandeln werden:
Weitere Einzelheiten findest du in der Standardbibliotheksdokumentation für
[`std::sync::atomic`][atomic]. An dieser Stelle musst du nur wissen, dass
atomare Typen wie primitive Typen funktionieren, aber sicher über Stränge
hinweg gemeinsam genutzt werden können.

Du wirst dich dann vielleicht fragen, warum nicht alle primitiven Typen atomar
sind und warum Standardbibliothekstypen nicht so implementiert sind, dass sie
standardmäßig `Arc<T>` verwenden. Der Grund dafür ist, dass Strang-Sicherheit
mit Performanzeinbußen verbunden ist, die du nur dann zahlen willst, wenn du
sie wirklich brauchst. Wenn du nur Operationen an Werten innerhalb eines
einzelnen Strangs durchführst, kann dein Code schneller laufen, wenn er nicht
die Garantien erzwingen muss, die atomare Typen bieten.

Kehren wir zu unserem Beispiel zurück: `Arc<T>` und `Rc<T>` haben die gleiche
API, also reparieren wir unser Programm, indem wir die `use`-Zeile, den Aufruf
von `new` und den Aufruf von `clone` ändern. Der Code in Codeblock 16-15 wird
schließlich kompilieren und laufen:

<span class="filename">Dateiname: src/main.rs</span>

```rust
use std::sync::{Arc, Mutex};
use std::thread;

fn main() {
    let counter = Arc::new(Mutex::new(0));
    let mut handles = vec![];

    for _ in 0..10 {
        let counter = Arc::clone(&counter);
        let handle = thread::spawn(move || {
            let mut num = counter.lock().unwrap();

            *num += 1;
        });
        handles.push(handle);
    }

    for handle in handles {
        handle.join().unwrap();
    }

    println!("Ergebnis: {}", *counter.lock().unwrap());
}
```

<span class="caption">Codeblock 16-15: Verwenden von `Arc<T>`, um den `Mutex<T>`
einzupacken, um die Eigentümerschaft mit mehreren Strängen teilen zu
können</span>

Dieser Code gibt folgendes aus:

```text
Ergebnis: 10
```

Wir haben es geschafft! Wir zählten von 0 bis 10, was nicht sehr beeindruckend
erscheinen mag, aber wir haben viel über `Mutex<T>` und Strangsicherheit
gelernt. Du kannst die Struktur dieses Programms auch dazu benutzen,
kompliziertere Operationen durchzuführen als nur einen Zähler zu
inkrementieren. Mit dieser Strategie kannst du eine Berechnung in unabhängige
Teile aufteilen, diese Teile auf Stränge aufteilen und dann `Mutex<T>`
verwenden, damit jeder Strang das Endergebnis mit seinem Teil aktualisiert.

Beachte, dass es für einfache numerische Operationen einfachere Typen als
`Mutex<T>` gibt, die durch das [Modul `std::sync::atomic` der
Standardbibliothek][atomic] bereitgestellt werden. Diese Typen bieten sicheren,
gleichzeitigen, atomaren Zugriff auf primitive Typen. Wir haben uns
entschieden, `Mutex<T>` mit einem primitiven Typ für dieses Beispiel zu
verwenden, damit wir uns darauf konzentrieren können, wie `Mutex<T>`
funktioniert.

### Ähnlichkeiten zwischen `RefCell<T>`/`Rc<T>` und `Mutex<T>`/`Arc<T>`

Du hast vielleicht bemerkt, dass `counter` unveränderbar (immutable) ist, aber
wir könnten eine veränderbare (mutable) Referenz auf den Wert in seinem
Inneren erhalten; das bedeutet, dass `Mutex<T>` innere Veränderbarkeit
(interior mutability) bietet, wie es die `Cell`-Familie tut. Auf die gleiche
Weise, wie wir `RefCell<T>` in Kapitel 15 benutzt haben, um uns zu erlauben,
Inhalte innerhalb eines `Rc<T>` zu mutieren, benutzen wir `Mutex<T>`, um
Inhalte innerhalb eines `Arc<T>` zu mutieren.

Ein weiteres zu beachtendes Detail ist, dass Rust dich nicht vor allen Arten
von Logikfehlern schützen kann, wenn du `Mutex<T>` verwendest. Erinnere dich in
Kapitel 15 daran, dass die Verwendung von `Rc<T>` mit dem Risiko verbunden war,
Referenzzyklen zu erzeugen, bei denen zwei `Rc<T>` Werte aufeinander
referenzieren und dadurch Speicherlecks verursachen. In ähnlicher Weise ist
`Mutex<T>` mit dem Risiko verbunden, *Deadlocks* zu schaffen. Diese treten auf,
wenn eine Operation zwei Ressourcen sperren muss und zwei Stränge jeweils eine
der Sperren erworben haben, was dazu führt, dass sie ewig aufeinander warten.
Wenn du an Deadlocks interessiert bist, versuche, ein Programm in Rust zu
erstellen, das einen Deadlock hat; dann recherchiere Strategien zur Minderung
von Deadlocks für Mutexe in einer Sprache und versuche, sie in Rust zu
implementieren. Die Standardbibliotheks-API-Dokumentation für `Mutex<T>` und
`MutexGuard` bietet nützliche Informationen.

Wir runden dieses Kapitel ab, indem wir über die Merkmale `Send` und `Sync`
sprechen und wie wir sie mit benutzerdefinierten Typen verwenden können.

[atomic]: https://doc.rust-lang.org/std/sync/atomic/index.html
