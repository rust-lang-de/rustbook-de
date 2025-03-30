## Programmcode beim Aufräumen ausführen mit dem Merkmal (trait) `Drop`

Das zweite wichtige Merkmal für intelligente Zeiger ist `Drop`, mit dem man
anpassen kann, was passiert, wenn ein Wert den Gültigkeitsbereich verlässt. Man
kann eine Implementierung für das Merkmal (trait) `Drop` für jeden Typ
bereitstellen, und der angegebene Programmcode kann zum Freigeben von
Ressourcen wie Dateien oder Netzwerkverbindungen verwendet werden.

Wir führen `Drop` im Kontext von intelligenten Zeigern ein, da die
Funktionalität des Merkmals `Drop` fast immer bei der Implementierung eines
intelligenten Zeigers verwendet wird. Wenn beispielsweise eine `Box<T>`
aufgeräumt wird, wird der Speicherplatz auf dem Haldenspeicher freigegeben, auf
den die Box zeigt.

In einigen Programmiersprachen muss der Programmierer für manche Datentypen
den Speicher oder die Ressourcen manuell freigeben, wenn die jeweiligen
Instanzen nicht mehr benötigt werden. Beispiele hierfür sind Dateiressourcen,
Sockets und Sperren. Wenn er das vergisst, kann das System überlastet werden
und abstürzen. In Rust kannst du festlegen, dass ein bestimmter Programmcode
ausgeführt wird, sobald ein Wert seinen Gültigkeitsbereich verlässt. Der
Compiler fügt dann diesen Programmcode automatisch ein. Infolgedessen muss man
sich nicht darum kümmern, an allen relevanten Stellen Aufräumcode zu
platzieren, und verschwendet trotzdem keine Ressourcen!

Du schreibst den Programmcode, der ausgeführt wird, wenn ein Wert den
Gültigkeitsbereich verlässt, durch Implementieren des Merkmals `Drop`. Für das
Merkmal `Drop` muss man eine Methode `drop` implementieren, die eine 
veränderbare Referenz auf `self` enthält. Um zu sehen, wann Rust `drop`
aufruft, implementieren wir `drop` zunächst mit `println!`-Anweisungen.

Codeblock 15-14 zeigt eine Struktur (struct) `CustomSmartPointer`, deren
einzige benutzerdefinierte Funktionalität darin besteht, `CustomSmartPointer
mit Daten aufräumen` auszugegeben, sobald die Instanz den Gültigkeitsbereich
verlässt.

<span class="filename">Dateiname: src/main.rs</span>

```rust
struct CustomSmartPointer {
    data: String,
}

impl Drop for CustomSmartPointer {
    fn drop(&mut self) {
        println!("CustomSmartPointer mit Daten aufräumen: `{}`!", self.data);
    }
}

fn main() {
    let c = CustomSmartPointer {
        data: String::from("meine Sache"),
    };
    let d = CustomSmartPointer {
        data: String::from("andere Sachen"),
    };
    println!("CustomSmartPointers erzeugt.");
}
```
<span class="caption">Codeblock 15-14: Eine Struktur `CustomSmartPointer`, die
das Merkmal `Drop` implementiert, wo wir unseren Programmcode für das Aufräumen
platzieren würden</span>

Das Merkmal `Drop` ist im Präludium (prelude) enthalten, daher müssen wir es
nicht in den Gültigkeitsbereich bringen. Wir implementieren das Merkmal `Drop`
in `CustomSmartPointer` und stellen eine Implementierung für die Methode `drop`
bereit, die `println!` aufruft. Im Hauptteil der Methode `drop` kannst du jede
Logik platzieren, die du ausführen möchtest, wenn eine Instanz deines Typs den
Gültigkeitsbereich verlässt. Wir geben hier einen Text aus, um visuell zu
zeigen, wann Rust `drop` aufruft.

In `main` erstellen wir zwei Instanzen von `CustomSmartPointer` und geben dann
`CustomSmartPointers erzeugt` aus. Am Ende von `main` verlassen unsere
Instanzen von `CustomSmartPointer` den Gültigkeitsbereich und Rust ruft den
Programmcode auf, den wir in der Methode `drop` angegeben haben, und gibt
schließlich unsere Nachricht aus. Beachte, dass wir die Methode `drop` nicht
explizit aufrufen mussten.

Wenn wir das Programm ausführen, erhalten wir folgende Ausgabe:

```console
$ cargo run
   Compiling drop-example v0.1.0 (file:///projects/drop-example)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.60s
     Running `target/debug/drop-example`
CustomSmartPointers erzeugt.
CustomSmartPointer mit Daten aufräumen: `andere Sachen`!
CustomSmartPointer mit Daten aufräumen: `meine Sache`!
```
Rust hat für uns automatisch `drop` und den von uns angegebenen Programmcode 
aufgerufen, als unsere Instanzen den Gültigkeitsbereich verlassen haben.
Variablen werden in umgekehrter Reihenfolge ihrer Erstellung aufgeräumt, daher
wurde `d` vor `c` aufgeräumt. Der Zweck dieses Beispiels ist, dir eine visuelle
Anleitung zur Funktionsweise der Methode `drop` zu geben. Normalerweise
schreibst du den Aufräumcode, der für deinen Typ nötig ist, anstatt einen Text
auszugeben.

Leider ist es nicht einfach, die automatische `drop`-Funktionalität zu
deaktivieren. Für gewöhnlich ist es auch nicht erforderlich; der wesentliche
Punkt des Merkmals `Drop` ist, dass es automatisch erledigt wird. Gelegentlich
möchte man jedoch möglicherweise einen Wert frühzeitig aufräumen. Ein Beispiel
ist die Verwendung intelligenter Zeiger, die Sperren verwalten: Möglicherweise
möchtest du den Aufruf der Methode `drop` erzwingen, um die Sperre sofort
freizugegeben, damit ein anderer Programmcode im selben Gültigkeitsbereich die
Sperre erhalten kann. Mit Rust kann man die Methode `drop` des Merkmals `Drop`
nicht manuell aufrufen. Stattdessen muss man die von der Standardbibliothek
bereitgestellte Funktion `std::mem::drop` aufrufen, wenn man das Aufräumen
eines Werts vor dem Ende seines ültigkeitsbereichs erzwingen möchte.

Wenn wir versuchen die Methode `drop` des Merkmals `Drop` manuell aufzurufen,
indem wir die Funktion `main` aus Codeblock 15-14 ändern, wie im Codeblock
15-15, gezeigt, erhalten wir einen Kompilierfehler.

<span class="filename">Dateiname: src/main.rs</span>

```rust,does_not_compile
# struct CustomSmartPointer {
#     data: String,
# }
#
# impl Drop for CustomSmartPointer {
#     fn drop(&mut self) {
#         println!("CustomSmartPointer mit Daten aufräumen: `{}`!", self.data);
#     }
# }
#
fn main() {
    let c = CustomSmartPointer {
        data: String::from("Daten"),
    };
    println!("CustomSmartPointer erzeugt.");
    c.drop();
    println!("CustomSmartPointer vor dem Ende von main aufgeräumt.");
}
```

<span class="caption">Codeblock 15-15: Der Versuch, die Methode `drop` des
Merkmals `Drop` manuell aufzurufen, um frühzeitig aufzuräumen</span>

Wenn wir versuchen, diesen Programmcode zu kompilieren, erhalten wir folgende
Fehlermeldung:

```console
$ cargo run
   Compiling drop-example v0.1.0 (file:///projects/drop-example)
error[E0040]: explicit use of destructor method
  --> src/main.rs:16:7
   |
16 |     c.drop();
   |       ^^^^ explicit destructor calls not allowed
   |
help: consider using `drop` function
   |
16 |     drop(c);
   |     +++++ ~

For more information about this error, try `rustc --explain E0040`.
error: could not compile `drop-example` (bin "drop-example") due to 1 previous error
```

Diese Fehlermeldung besagt, dass wir `drop` nicht explizit aufrufen dürfen. Die
Fehlermeldung verwendet den Begriff _Destruktor_ (destructor), der der
allgemeine Programmierbegriff für eine Funktion ist, die eine Instanz aufräumt.
Ein _Destruktor_ ist analog zu einem _Konstruktor_ (constructor), der eine
Instanz erstellt. Die Funktion `drop` in Rust ist so ein _Destruktor_.

Rust lässt uns `drop` nicht explizit aufrufen, da Rust immer noch automatisch
für den Wert am Ende von `main` `drop` aufruft. Dies würde einen
_Doppel-Freigabe-Fehler_ (double free error) verursachen, da Rust versuchen
würde, den gleichen Wert zweimal aufzuräumen.

Wir können das automatische Einfügen von `drop` am Ende des Gültigkeitsbereichs
nicht deaktivieren und wir können die Methode `drop` nicht explizit aufrufen.
Wenn wir also erzwingen wollen, dass ein Wert frühzeitig aufgeräumt wird,
verwenden wir die Funktion `std::mem::drop`.

Die Funktion `std::mem::drop` unterscheidet sich von der Methode `drop` im
Merkmal `Drop`. Wir rufen sie auf, indem wir den Wert, dessen vorzeitiges
Aufräumen wir erzwingen möchten, der Funktion als Argument mitgeben. Die
Funktion befindet sich im Präludium, daher können wir `main` in Codeblock 15-15
ändern, um die Funktion `drop` wie in Codeblock 15-16 gezeigt aufzurufen.

<span class="filename">Dateiname: src/main.rs</span>

```rust
# struct CustomSmartPointer {
#     data: String,
# }
# 
# impl Drop for CustomSmartPointer {
#     fn drop(&mut self) {
#         println!("CustomSmartPointer mit Daten aufräumen: `{}`!", self.data);
#     }
# }
# 
fn main() {
    let c = CustomSmartPointer {
        data: String::from("Daten"),
    };
    println!("CustomSmartPointer erzeugt.");
    drop(c);
    println!("CustomSmartPointer vor dem Ende von main aufgeräumt.");
}
```

<span class="caption">Codeblock 15-16: `std::mem::drop` aufrufen, um einen Wert
explizit aufzuräumen, bevor er den Gültigkeitsbereich verlässt</span>

Wenn wir den Programmcode aufrufen, wird folgendes ausgegeben:

```console
$ cargo run
   Compiling drop-example v0.1.0 (file:///projects/drop-example)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.73s
     Running `target/debug/drop-example`
CustomSmartPointer erzeugt.
CustomSmartPointer mit Daten aufräumen: `Daten`!
CustomSmartPointer vor dem Ende von main aufgeräumt.
```

Der Text ``CustomSmartPointer mit Daten aufräumen: `Daten`!`` wird zwischen
`CustomSmartPointer erzeugt` und `CustomSmartPointer vor dem Ende von main
aufgeräumt` ausgegeben und zeigt, dass der Methodencode von `drop` aufgerufen
wird, um `c` an diesem Punkt aufzuräumen.

Du kannst den Programmcode, der in einer Implementierung des Merkmals `Drop`
angegeben ist, auf viele Arten verwenden, um das Aufräumen bequem und sicher
zu gestalten. Du kannst ihn beispielsweise dazu verwenden, deine eigene
Speicherverwaltung (memory allocator) zu erstellen! Mit dem Merkmal `Drop` und
dem Eigentümerschaftssystem von Rust musst du nicht ans Aufräumen denken, da
Rust dies automatisch tut.

Man muss sich auch keine Sorgen über Probleme machen, die sich aus dem
versehentlichen Aufräumen noch verwendeter Werte ergeben: Das
Eigentümerschaftssystem, das sicherstellt, das Referenzen immer gültig sind,
stellt auch sicher, dass `drop` nur einmal aufgerufen wird, wenn der Wert nicht
mehr verwendet wird.

Nachdem wir nun `Box<T>` und einige der Merkmale von intelligenten Zeigern
untersucht haben, schauen wir uns einige andere intelligente Zeiger an, die in
der Standardbibliothek definiert sind.
