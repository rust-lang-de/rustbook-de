## Programmcode beim Aufräumen ausführen mit dem Merkmal (trait) Drop

Das zweite wichtige Merkmal für intelligente Zeiger ist `Drop`, mit dem man
anpassen kann, was passiert, wenn ein Wert den Gültigkeitsbereich verlässt. Man
kann eine Implementierung für das Merkmal (trait) `Drop` für jeden Typ bereitstellen,
und der angegebene Programmcode kann zum Freigeben von Ressourcen wie Dateien
oder Netzwerkverbindungen verwendet werden. Wir führen `Drop` im Kontext von
intelligenten Zeigern ein, da sie Funktionalität des Merkmals `Drop` fast immer
bei der Implementierung eines intelligenten Zeigers verwendet verwendet wird.
Wenn beispielsweise eine `Box<T>` gelöscht wird, wird der Speicherplatz auf dem
Haldenspeicher freigegeben, auf den die Box zeigt.

In einigen Programmiersprachen muss der Programmierer bei jeder Verwendung einer
Instanz eines intelligenten Zeigers Programmcode aufrufen, um Speicher oder
Ressourcen freizugeben. Wenn sie es vergessen, kann das System überlastet werden
und abstürzen. In Rust kann man festlegen, dass ein bestimmter Programmcode
ausgeführt wird, wenn ein Wert seinen Gültigkeitsbereich verlässt, und der
Compiler fügt diesen Programmcode automatisch ein. Infolgedessen muss man nicht
vorsichtig sein, wenn man Bereinigungscode überall in einem Programm platziert,
mit dem eine Instanz eines bestimmten Typs fertig ist, man wird dennoch keine
Ressourcen verlieren!

Der Programmcode der ausgeführt wird, wenn ein Wert den Gültigkeitsbereich
verlässt, wird durch implementieren des Merkmals `Drop` angegeben. Für das
Merkmal `Drop` muss man eine Methode `drop` implementieren, die eine 
veränderliche Referenz auf `self` enthält. Um zu sehen, wann Rust `drop`
aufruft, implementieren wir `drop` zunächst mit `println!`-Anweisungen.

Codeblock 15-14 zeigt eine `CustomSmartPointer` Struktur (struct), deren einzige 
benutzerdefinierte Funktionalität darin besteht, dass `Lösche
CustomSmartPointer!` ausgegeben wird, wenn die Instanz den Gültigkeitsbereich
verlässt. Dieses Beispiel zeigt, wann Rust die `drop`-Funktion ausführt.

<span class="filename">Dateiname: src/main.rs</span>

```rust
struct CustomSmartPointer {
    data: String,
}

impl Drop for CustomSmartPointer {
    fn drop(&mut self) {
        println!("Lösche CustomSmartPointer und Daten `{}`!", self.data);
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
<span class="caption">Codeblock 15-14: Eine `CustomSmartPointer` Struktur die
das `Drop`-Merkmal dort implementiert wo wir unseren Programmcode für das
Aufräumen platzieren würden</span>

Das Merkmal `Drop` ist im Vorspiel enthalten, daher müssen wir es nicht in den
Gültigkeitsbereich bringen. Wir implementieren das Merkmal `Drop` in
`CustomSmartPointer` und stellen eine Implementierung für die Methode `drop`
bereit, die `println!` aufruft. Im Hauptteil der `drop`-Funktion kannst du jede
Logik platzieren, die du ausführen möchtest, wenn deine Instanz deines Typs
ihren Gültigkeitsbereich verlässt. Wir geben hier einen Text aus, um zu zeigen,
wann Rust `drop` aufruft.

In `main` erstellen wir zwei Instanzen von `CustomSmartPointer` und geben dann 
`CustomSmartPointers erzeugt` aus. Am Ende von `main` werden unsere Instanzen
von `CustomSmartPointer` nicht mehr gültig sein, und Rust ruft den Programmcode
auf, den wir in die `drop`-Methode eingegeben haben, und gibt unsere endgültige
Nachricht aus. Beachte, dass wir die `drop`-Methode nicht explizit aufrufen
mussten.

Wenn wir das Programm ausführen, erhalten wir folgende Ausgabe:

```console
$ cargo run
   Compiling drop-example v0.1.0 (file:///projects/drop-example)
    Finished dev [unoptimized + debuginfo] target(s) in 0.60s
     Running `target/debug/drop-example`
CustomSmartPointers erzeugt.
Lösche CustomSmartPointer und Daten `andere Sachen`!
Lösche CustomSmartPointer und Daten `meine Sache`!
```
Rust hat für uns automatisch `drop` und den von uns angegebenen Programmcode 
aufgerufen, sobald unsere Instanzen den Gültigkeitsbereich verlassen haben. 
Variablen werden in umgekehrter Reihenfolge ihrer Erstellung gelöscht, daher
wurde `d` vor `c` gelöscht. Dieses Beispiel gibt dir eine visuelle Anleitung zur
Funktionsweise der `drop`-Methode. Normalerweise gibst du den Bereinigungscode
an, den dein Typ ausführen muss, anstatt einen Text auszugeben.

### Einen Wert mit `std::mem::drop` frühzeitig löschen

Unglücklicherweise ist es nicht einfach, die automatische `drop`-Funktionalität
zu deaktivieren, für gewöhnlich ist es auch nicht erforderlich. Der wesentliche
Punkt des `Drop`-Merkmals ist, dass es automatisch erledigt wird. Gelegentlich
möchte man jedoch möglicherweise einen Wert frühzeitig bereinigen. Ein Beispiel
ist die Verwendung intelligenter Zeiger, die Sperren verwalten: Möglicherweise
möchtest du die `drop`-Methode erzwingen, mit der die Sperre freigegeben wird,
damit andere Programmcodes im Gültigkeitsbereich die Sperre erhalten können. Mit
Rust kann man die `drop`-Methode des `Drop`-Merkmals nicht manuell aufrufen.
Stattdessen muss man die von der Standardbibliothek bereitgestellte Funktion
`std::mem::drop` aufrufen, wenn man das Löschen eines Werts vor dem Ende seines
Gültigkeitsbereich erzwingen möchte.

Wenn wir versuchen die `drop`-Methode des `drop`-Merkmals manuell aufzurufen,
indem wir die `main`-Funktion aus Codeblock 15-14 ändern, wie im Codeblock 15-15,
gezeigt, erhalten wir folgenden Fehler beim Kompilieren:

<span class="filename">Dateiname: src/main.rs</span>

```rust,ignore,does_not_compile
# struct CustomSmartPointer {
#     data: String,
# }
# 
# impl Drop for CustomSmartPointer {
#     fn drop(&mut self) {
#         println!("Lösche CustomSmartPointer und Daten `{}`!", self.data);
#     }
# }
# 
#  
fn main() {
    let c = CustomSmartPointer {
        data: String::from("Daten"),
    };
    println!("CustomSmartPointer erzeugt.");
    c.drop();
    println!("CustomSmartPointer vor dem Ende von main gelöscht.");
}
```

<span class="caption">Codeblock 15-15: Der Versuch, die `drop`-Methode 
manuell aus dem `Drop`-Merkmal aufzurufen um den Programmcode frühzeitig zu
bereinigen</span>

Wenn wir versuchen, diesen Programmcode zu kompilieren, wird folgende
Fehlermeldung ausgegeben:

```console
$ cargo run
   Compiling drop-example v0.1.0 (file:///projects/drop-example)
error[E0040]: explicit use of destructor method
  --> src/main.rs:16:7
   |
16 |     c.drop();
   |       ^^^^ explicit destructor calls not allowed

error: aborting due to previous error

For more information about this error, try `rustc --explain E0040`.
error: could not compile `drop-example`.

To learn more, run the command again with --verbose.
```
Diese Fehlermeldung besagt, dass wir `drop` nicht explizit aufrufen dürfen. Die
Fehlermeldung verwendet den Begriff *Destruktor* (destructor), der der allgemeine
Programmierbegriff für eine Funktion ist, die eine Instanz bereinigt. Ein
*Destruktor* ist analog zu einem *Konstruktor* (constructor), der eine Instanz
erstellt. Die `drop`-Funktion in Rust ist ein bestimmter *Destruktor*.

Rust lässt uns `drop` nicht explizit aufrufen, da Rust immer noch automatisch
für den Wert am Ende von `main` `drop` aufruft. Dies wäre ein *double free*
Fehler, da Rust versuchen würde, den gleichen Wert zweimal aufzuräumen.

Die `std::mem::drop`-Funktion unterscheidet sich von der Methode `drop` im
Merkmal `Drop`. Wir rufen es auf, indem wir den Wert dessen vorzeitige Löschung
wir erzwingen möchten, der Funktion als Argument mitgeben. Die Funktion befindet
sich im Vorspiel, daher können wir `main` in Codeblock 15-15 ändern, um die
`drop`-Funktion wie in Codeblock 15-16 gezeigt aufzurufen:

<span class="filename">Dateiname: src/main.rs</span>

```rust
# struct CustomSmartPointer {
#     data: String,
# }
# 
# impl Drop for CustomSmartPointer {
#     fn drop(&mut self) {
#         println!("Lösche CustomSmartPointer und Daten `{}`!", self.data);
#     }
# }
# 
fn main() {
    let c = CustomSmartPointer {
        data: String::from("Daten"),
    };
    println!("CustomSmartPointer erzeugt.");
    drop(c);
    println!("CustomSmartPointer vor dem Ende von main gelöscht.");
}
```

<span class="caption">Codeblock 15-16: `std::mem::drop` aufrufen um einen Wert
explizit zu löschen bevor er den Gültigkeitsbereich verlässt</span>

Wenn wir den Programmcode aufrufen, wird folgendes ausgegeben:


```console
$ cargo run
   Compiling drop-example v0.1.0 (file:///projects/drop-example)
    Finished dev [unoptimized + debuginfo] target(s) in 0.73s
     Running `target/debug/drop-example`
CustomSmartPointer erzeugt.
Lösche CustomSmartPointer und Daten `Daten`!
CustomSmartPointer vor dem Ende von main gelöscht.
```

Der Text ```Lösche CustomSmartPointer und Daten `Daten`!```  Wird zwischen dem 
`CustomSmartPointer erzeugt` und `CustomSmartPointer vor dem Ende von main gelöscht.`
ausgegeben und zeigt, dass der `drop`-Methodencode aufgerufen wird um `c` an
diesem Punkt zu löschen.

Sie können den Programmcode, der in einer Implementierung des `Drop`-Merkmals
angegeben ist, auf viele Arten verwenden, um die Bereinigung bequem und sicher
zu gestalten, du kannst ihn beispielsweise dazu verwnden, um deinen eigenen
Speicherzuweiser (memory allocator) zu erstellen! Mit dem Merkmal `Drop` und dem 
Besitzsystem von Rust musst du nicht daran denken den Programmcode zu
bereinigen, da Rust dies automatisch tut.

Man muss sich auch keine Sorgen über Probleme machen, die sich aus der
versehentlicher Bereinigung noch verwendeter Werte ergeben: Das Besitzersystem,
das sicherstellt, das Referenzen immer gültig sind, stellt auch sicher, dass
`drop` nur einmal aufgerufen wird, wenn der Wert nicht mehr verwendet wird.

Nachdem wir nun `Box<T>` und einige der Merkmale von intelligenten Zeigern
untersucht haben, schauen wir uns einige andere intelligente Zeiger an, die in
der Standardbibliothek definiert sind.


