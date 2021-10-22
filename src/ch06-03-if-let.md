## Prägnanter Kontrollfluss mit `if let`

Mit der Syntax `if let` kannst du `if` und `let` in einer weniger wortreichen
Weise kombinieren, um mit Werten umzugehen, die einem Muster entsprechen,
während der Rest ignoriert wird. Betrachte das Programm in Codeblock 6-6, das
auf einen `Option<u8>`-Wert in der Variable `config_max` passt, aber nur dann
Code ausführen soll, wenn der Wert die `Some`-Variante ist.

```rust
let config_max = Some(3u8);
match config_max {
    Some(max) => println!("Das Maximum ist mit {} konfiguriert", max),
    _ => (),
}
```

<span class="caption">Codeblock 6-6: Eine `match`-Ausdruck, der nur dann Code
ausführt, wenn der Wert `Some` ist</span>

Wenn der Wert `Some` ist, wollen wir den Wert in der Variante `Some` ausgeben,
wofür wir den Wert an die Variable `max` im Muster binden. Wir wollen nichts
mit dem Wert `None` machen. Um den Ausdruck `match` zu erfüllen, müssen wir
nach der Verarbeitung nur einer Variante `_ => ()` hinzufügen, was lästiger
Codeballast ist.

Stattdessen könnten wir dies in kürzerer Form schreiben, indem wir `if let`
verwenden. Der folgende Code verhält sich genauso wie der `match`-Ausdruck in
Codeblock 6-6:

```rust
let config_max = Some(3u8);
if let Some(max) = config_max {
    println!("Das Maximum ist mit {} konfiguriert", max);
}
```

Die Syntax `if let` nimmt ein Muster und einen Ausdruck, getrennt durch ein
Gleichheitszeichen. Sie funktioniert auf gleiche Weise wie bei `match`, wo der
Ausdruck hinter `match` angegeben wird und das Muster der erste Zweig ist. In
diesem Fall ist das Muster `Some(max)` und das `max` ist an den Wert innerhalb
von `Some` gebunden. Wir können dann `max` im Rumpf des `if let`-Blocks auf die
gleiche Weise verwenden, wie `max` im entsprechenden `match`-Zweig. Der Code im
`if let`-Block wird nicht ausgeführt, wenn der Wert nicht zum Muster passt.

Die Verwendung von `if let` bedeutet weniger Tipparbeit, weniger Einrückung und
weniger Codeanteil. Du verlierst jedoch die Prüfung auf Vollständigkeit, die
`match` erzwingt. Die Wahl zwischen `match` und `if let` hängt davon ab, was
du in der speziellen Situation machst, und davon, ob ein Gewinn an Prägnanz ein
angemessener Kompromiss für den Verlust einer Prüfung auf Vollständigkeit ist.

Anders gesagt kannst du dir `if let` als syntaktischen Zucker für einen
`match`-Ausdruck vorstellen, der Code nur bei Übereinstimmung mit einem Muster
ausführt und alle anderen Werte ignoriert.

Wir können ein `else` an ein `if let` anhängen. Der Code-Block, der zum `else`
gehört, ist der gleiche wie der Code-Block, der zum `_`-Zweig im
`match`-Ausdruck gehören würde. Erinnere dich an die Aufzählung `Coin` in
Codeblock 6-4, wo die Variante `Quarter` auch einen `UsState`-Wert enthielt.
Wenn wir alle Nicht-25-Cent-Münzen zählen wollten, während wir die Eigenschaft
der 25-Cent-Münzen ausgeben, könnten wir das mit einem `match`-Ausdruck wie
diesem tun:

```rust
# #[derive(Debug)]
# enum UsState {
#     Alabama,
#     Alaska,
#     // --abschneiden--
# }
# 
# enum Coin {
#     Penny,
#     Nickel,
#     Dime,
#     Quarter(UsState),
# }
#
# fn main() {
#     let coin = Coin::Penny;
    let mut count = 0;
    match coin {
        Coin::Quarter(state) => println!("25-Cent-Münze aus {:?}!", state),
        _ => count += 1,
    }
# }
```

Oder wir könnten einen Ausdruck mit `if let` und `else` wie diesen verwenden:

```rust
# #[derive(Debug)]
# enum UsState {
#     Alabama,
#     Alaska,
#     // --abschneiden--
# }
#
# enum Coin {
#     Penny,
#     Nickel,
#     Dime,
#     Quarter(UsState),
# }
#
# fn main() {
#     let coin = Coin::Penny;
    let mut count = 0;
    if let Coin::Quarter(state) = coin {
        println!("25-Cent-Münze aus {:?}!", state);
    } else {
        count += 1;
    }
# }
```

Wenn du eine Situation hast, in der dein Programm über eine Logik verfügt, die
mit einem `match`-Ausdruck zu wortreich auszudrücken wäre, denke daran, dass
`if let` ebenfalls in deinem Rust-Werkzeugkasten enthalten ist.

## Zusammenfassung

Wir haben uns damit befasst, wie man Aufzählungen verwendet, um
benutzerdefinierte Typen zu erstellen, die zu einem Satz von Aufzählungswerten
gehören können. Wir haben gezeigt, wie der Typ `Option<T>` der
Standardbibliothek dir dabei hilft, das Typsystem zu verwenden, um Fehler zu
vermeiden. Wenn Aufzählungswerte Daten enthalten, kannst du diese Werte mit
`match` oder `if let` extrahieren und verwenden, je nachdem, wie viele Fälle du
behandeln musst.

Deine Rust-Programme können nun Konzepte in deiner Domäne mit Hilfe von
Strukturen und Aufzählungen ausdrücken. Das Erstellen benutzerdefinierter Typen
zur Verwendung in deiner API gewährleistet Typsicherheit: Der Compiler wird
sicherstellen, dass deine Funktionen nur Werte jenes Typs erhalten, den die
Funktion erwartet.

Um deinen Nutzern eine gut organisierte API zur Verfügung zu stellen, die
einfach zu benutzen ist und nur genau das offenbart, was deine Nutzer
benötigen, wenden wir uns nun den Modulen von Rust zu.
