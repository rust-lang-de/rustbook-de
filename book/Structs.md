# Structs

Mithilfe von *Structs* ist es möglich komplexere Datentypen zu erstellen.
Als Beispiel betrachten wir einen Gegenstand in einem 2D Raum. Um seine Position zu beschrieben, 
sind die zwei Koordinaten `x` und `y` von Nöten.

```rust
let x_position = 0;
let y_position = 0;
```
Allerdings sind zwei eigene Variablen für die beiden Koordinaten nicht gerade praktisch im Handling.
Mit einem *Struct* können beide Werte in einem Datentyp zusammengefasst werden. 

```rust
struct Position {
	x: i32,
	y: i32,
}
```
Dieses *Struct* umfasst nun die beiden Variablen `x` und `y` vom Typen `i32`. 
Das Schlüsselwort `struct` leitet die Deklaration eines *Structs* ein. Der Konvention folgend,
beginnt der Bezeichner eines *Structs* mit einem Großbuchstaben. Auch werden die Worte von Bezeichnern mit mehreren Worten zusammengezogen und nicht mit Unterstrichen (_) getrennt. Dabei beginnt jedes Wort mit einem Großbuchstaben. 
Beispiele:
`struct PositionInSpace` : korrekt
`struct Position_in_Space`: nach der Konvention nicht korrekt
`struct PositioninSpace` : nach der Konvention nicht korrekt


Ein *Struct* zu initialisieren und auf seine Inhalte zuzugreifen ist nicht weiter problematisch.

```rust
struct Position {
	x: i32,
	y: i32,
}

fn main() {
	let start = Position { x: 0, y: 0.5 };

	println!("The start of Race is at ({},{})", start.x, start.y);
}
```
Wie gewohnt wird mit `let` die Instanz des *Structs* erzeugt. Die einzelnen Felder des *Structs* werden mit der `key: value` Syntax gesetzt.
Dabei ist es nicht relevant, in welcher Reihenfolge die Felder gesetzt werden. 

```rust
let start = Position { x: 0, y: 0.5 };
let start = Position { y: 0.5, x: 0 }; 
```
Beide Aufrufe sind korrekt und füllen die Felder mit den ihnen zugewiesenen Werten. 
Da auch die Felder innerhalb eines *Structs* Bezeichner tragen, ist es möglich diese über `Structbezeichner.Feldbezeichner` anzusprechen. 

Standardmäßig sind die Felder innerhalb eines *Structs* schreibgeschützt. Aber wie bei anderen Bindungen in Rust,
kann auch bei *Structs* das Schlüsselwort `mut` die Felder als beschreibbar markieren. 

```rust
struct Position {
	x: i32,
	y: i32,
}

fn main() {

	let mut start = Position { x: 0, y: 0.5 };
	let end = Position { x: 0.5, y: 0 };

	start.x = 10; 	// Dies ist korrekt da start 
			   	//als beschreibbar gekennzeichnet ist.
	end.x = 1; 	// Dies wird einen Fehler erzeugen 
				//da end schreibgeschützt ist.
}
```

Innerhalb des *Structs* ist es nicht möglich die definierten Felder/Variablen als beschreibbar zu setzen. 

```rust 
strcut Position {
	mut x: i32,  // Das ist nicht möglich!
	y: i32,
}
```
Dieser Umstand ist darin begründet, dass beschreibbar und unbeschreibbar Eigenschaften von Bindungen und nicht der Variablen und Werte an sich selbst sind. Jedoch ist es möglich die Felder des *Structs* nur für eine kurze Zeit als beschreibbar zu kennzeichnen. 

```rust 
struct Position {
	x: i32,
	y: i32,
}

fn main() {

	let mut start = Position { x: 0 , y: 0.5 };
	
	start.x = 10; // Hier ist eine Zuweisung noch möglich.
	
	let start = start;
	
	start.x = 0 ; // Diese Zuweisung wirft einen Fehler.
}
```
## Updating Syntax 
Es gibt eine weitere Möglichkeit die Felder eines *Structs* zu modifizieren. Mit `..` kann Rust darüber informiert werden, das eine Kopie von Werten eines anderen *Structs* übernommen werden sollen. 

```rust
struct Position {
	x: i32,
	y: i32,
	z: i32,
}

fn main() {

	let mut start = Position { x: 0 , y: 0.5, z: 1 };
	start = Position { y : 2, .. start }
}
```
Durch die Zuweisung erhält `start` einen neuen `y` Wert. Alle anderen Werte werden aus der alten Wertebelegung von `start` kopiert bevor `start` überschrieben wird. Dabei ist es möglich die Syntax nicht nur auf dasselbe *Struct* anzuwenden, aus dem auch gelesen wird. Es besteht auch die Möglichkeit eine neues *Struct* damit zu initialisieren. 

```rust 
fn main() {

	let start = Position {x: 0, y: 0.5, z: 1};
	let example_1 = Position {z: 3, y: 2, .. start }; 
	// Wie bereits erwähnt, kommt es bei dieser 
	//Schreibweise nicht auf die Reihenfolge
	//der Variablen an. 
	//Nur die spezielle Updatesyntax muss am Ende stehen. 
}
```
## Tuple - Structs
In Rust existiert ein Datentyp, der einer Art Hybrid aus einem *Struct* und aus einem [Tuple][tupel] bildet. Doch ist es empfohlen auf den normalen *Struct* - Datentyp zurückzugreifen. 
[tupel]: Primitive_Typen.md#tupel

```rust
struct Color (i32, i32, i32)
struct Position (i32, i32, i32) 

fn main(){
	let black = Color(0, 0, 0);
	let start = Position (0, 0, 0);
	// Diese beiden Belgungen sind nicht identisch,
	//auch wenn es sich um die selben Werte
	//innerhalb der Strucs handelt.
}
```

Die *Structs* weisen einen Bezeichner auf. Color oder Position.
Die Werte innerhalb der *Structs* haben allerdings keine Bezeichnungen.
Daher ist es besser die *Tuple - Structs* in die Syntax normaler *Structs* zu überführen.  

```rust
struct Color {
    red: i32,
    blue: i32,
    green: i32,
}

struct Position {
    x: i32,
    y: i32,
    z: i32,
}

```
Es gibt einen Fall, in dem es sinnvoll ist ein *Tuple - Struct* zu verwenden. 
Es handelt sich um das Entwicklungsmuster (engl.: pattern) *newtype*. Dieses Muster erlaubt es einen neuen Typen zu erschaffen, welcher verschieden zu dem Typ des Wertes ist, welchen er beinhaltet. 

```rust
struct Meter(i32); 

fn main() {
	let meter = Meter(10); 
	let Meter(value) = meter;
	println!("value is {} meter", value);
}

```
Die Variable `meter` ist vom Typen `Meter`. Um an den Inhalt, also den Wert des Datentypen innerhalb von Meter heran zu kommen, kann das [*Patternmatching*][muster] verwendet werden. 
`value` ist vom primitiven Typen `i32`. Auch ist es eine copy des Wertes in Meter und nicht eine Referenz. 
[muster]: book/Muster.md

## Einheitstyp (engl.: unit-like structs)
Es kann ein *Struct* definiert werden, welches keinen Inhalt aufweist. 

```rust
struct Unicorn;
```
Solch ein *Struct* wird als Einheit (engl.: unit-like) betrachtet. Es ähnelt stark dem leeren [Tuple][tupel]. Wie ein *Tuple - Struct* definiert dieser Einheitstyp einen neuen Typen. 
Der Einheitstyp ist für sich selbst genommen bereits sehr nützlich. Er kann beispielsweise als Markierung verwendet werden. In der Kombination mit anderen Funktionen entfaltet der Einheitstyp seine volles Potenzial. Wenn das Interesse nicht an den Werten besteht sondern nur an dem Typen beispielsweise. Ein Interface erwartet, ein *Struct* welches verschiedene `trait`s implementiert, um Ereignisse (engl.: Event) zu behandeln.