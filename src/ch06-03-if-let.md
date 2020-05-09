## Prägnanter Kontrollfluss mit `if let`

Mit der Syntax `if let` kannst du `if` und `let` in einer weniger wortreichen
Weise kombinieren, um mit Werten umzugehen, die einem Muster entsprechen,
während der Rest ignoriert wird. Betrachte das Programm in Codeblock 6-6, das
auf einen `Option<u8>`-Wert passt, aber nur dann Code ausführen soll, wenn der
Wert 3 ist.

```rust
# let some_u8_value = Some(0u8);
match some_u8_value {
    Some(3) => println!("drei"),
    _ => (),
}
```

<span class="caption">Codeblock 6-6: Eine `match`-Ausdruck, der nur dann Code
ausführt, wenn der Wert `Some(3)` ist</span>

Wir wollen etwas bei `Some(3)` machen, aber nichts mit allen anderen
`Some<u8>`-Werten oder dem Wert `None`. Um den `match`-Ausdruck zu
vervollständigen, müssen wir `_ => ()` ergänzen. Nachdem wir nur eine Variante
verarbeiten, bedeutet das relativ viel Code, den wir schreiben müssen.

Stattdessen könnten wir dies in kürzerer Form schreiben, indem wir `if let`
verwenden. Der folgende Code verhält sich genauso wie der `match`-Ausdruck in
Codeblock 6-6:

```rust
# let some_u8_value = Some(0u8);
if let Some(3) = some_u8_value {
    println!("three");
}
```

Die Syntax `if let` nimmt ein Muster und einen Ausdruck, getrennt durch ein
Gleichheitszeichen. Sie funktioniert auf gleiche Weise wie bei `match`, wo der
Ausdruck hinter `match` angegeben wird und das Muster der erste Zweig ist.

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
zur Verwendung in deiner API gewährleistet Typsicherheit: Der Kompilierer wird
sicherstellen, dass deine Funktionen nur Werte jenes Typs erhalten, den die
Funktion erwartet.

Um deinen Nutzern eine gut organisierte API zur Verfügung zu stellen, die
einfach zu benutzen ist und nur genau das offenbart, was deine Nutzer
benötigen, wenden wir uns nun den Modulen von Rust zu.
