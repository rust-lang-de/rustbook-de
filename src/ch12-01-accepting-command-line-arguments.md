## Kommandozeilenargumente entgegennehmen

Lass uns ein neues Projekt, wie immer, mit `cargo new` erstellen. Wir werden
unser Projekt `minigrep` nennen, um es vom `grep`-Werkzeug zu unterscheiden,
das du vielleicht schon auf deinem System hast:

```console
$ cargo new minigrep
     Created binary (application) `minigrep` project
$ cd minigrep
```

Die erste Aufgabe besteht darin, `minigrep` dazu zu bringen, seine beiden
Kommandozeilenargumente entgegennehmen: Den Dateipfad und eine Zeichenkette,
nach der gesucht werden soll. Das heißt, wir wollen in der Lage sein, unser
Programm mit `cargo run`, einer zu suchenden Zeichenkette und einem Pfad zu
einer Datei, in der gesucht werden soll, auszuführen:

```console
$ cargo run -- searchstring example-filename.txt
```

Im Moment kann das von `cargo new` generierte Programm die Argumente, die wir
ihm geben, nicht verarbeiten. Einige vorhandene Bibliotheken auf
[crates.io][crates-io] können beim Schreiben eines Programms, das
Kommandozeilenargumente akzeptiert, helfen, aber da du dieses Konzept gerade
erst erlernst, sollten wir diese Fähigkeit selbst implementieren.

### Lesen der Argumentwerte

Um `minigrep` in die Lage zu versetzen, die Werte der Kommandozeilenargumente
zu lesen, die wir ihm übergeben, benötigen wir die Funktion `std::env::args`,
die in der Standardbibliothek von Rust bereitgestellt wird. Diese Funktion gibt
einen Iterator der Befehlszeilenargumente zurück, die an `minigrep` übergeben
wurden. Iteratoren werden wir in [Kapitel 13][ch13] ausführlich behandeln. Im
Moment brauchst du nur zwei Details über Iteratoren zu wissen: Iteratoren
erzeugen eine Reihe von Werten und wir können die Methode `collect` auf einem
Iterator aufrufen, um ihn in eine Kollektion, z.B. einen Vektor, zu verwandeln,
der alle Elemente enthält, die der Iterator erzeugt.

Der Code in Codeblock 12-1 ermöglicht deinem `minigrep`-Programm, alle ihm
übergebenen Befehlszeilenargumente zu lesen und die Werte dann in einem Vektor
zu sammeln.

<span class="filename">Dateiname: src/main.rs</span>

```rust
use std::env;

fn main() {
    let args: Vec<String> = env::args().collect();
    dbg!(args);
}
```

<span class="caption">Codeblock 12-1: Sammeln der Befehlszeilenargumente in
einem Vektor und Ausgeben dieser Werte</span>

Zuerst bringen wir das Modul `std::env` mit einer `use`-Anweisung in den
Gültigkeitsbereich, damit wir seine Funktion `args` verwenden können. Beachte,
dass die Funktion `std::env::args` in zwei Modulebenen verschachtelt ist. Wie
wir in [Kapitel 7][ch7-idiomatic-use] besprochen haben, haben wir in Fällen, in
denen die gewünschte Funktion in mehreren Modulebenen verschachtelt ist, das
die Funktion enthaltende Modul in den Gültigkeitsbereich gebracht, anstatt nur
die Funktion selbst zu importieren. Auf diese Weise können wir leicht andere
Funktionen aus `std::env` verwenden. Es ist auch nicht so vieldeutig wie beim
Importieren von `use std::env::args` und dem anschließenden Aufrufen der
Funktion nur mit `args`, weil `args` leicht mit einer Funktion verwechselt
werden könnte, die im aktuellen Modul definiert ist.

> ### Die Funktion `args` und ungültiger Unicode
>
> Beachte, dass `std::env::args` abstürzt, wenn ein Argument einen ungültigen
> Unicode enthält. Wenn dein Programm Argumente mit ungültigem Unicode
> akzeptieren muss, verwende stattdessen `std::env::args_os`. Diese Funktion
> gibt einen Iterator zurück, der `OsString`-Werte anstelle von `String`-Werten
> erzeugt. Wir haben uns hier aus Gründen der Einfachheit für die Verwendung
> von `std::env::args` entschieden, weil `OsString`-Werte sich je nach
> Plattform unterscheiden und die Arbeit mit ihnen komplexer ist als mit
> `String`-Werten.

In der ersten Zeile von `main` rufen wir `env::args` auf und wir verwenden
sofort `collect`, um den Iterator in einen Vektor zu verwandeln, der alle vom
Iterator erzeugten Werte enthält. Wir können die Funktion `collect` verwenden,
um viele Arten von Kollektionen zu erstellen, also vermerken wir explizit den
Typ von `args`, um anzugeben, dass wir einen Vektor mit Zeichenketten wollen.
Obwohl du in Rust nur sehr selten Typen mit Annotationen versehen musst, ist
`collect` eine Funktion, die du häufig mit Annotationen versehen musst, da Rust
nicht in der Lage ist, auf die Art der gewünschten Kollektion zu schließen.

Zum Schluss geben wir den Vektor mit dem Debug-Makro aus. Versuchen wir, den
Code zuerst ohne Argumente und dann mit zwei Argumenten laufen zu lassen:

```console
$ cargo run
   Compiling minigrep v0.1.0 (file:///projects/minigrep)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.61s
     Running `target/debug/minigrep`
[src/main.rs:5:5] args = [
    "target/debug/minigrep",
]
```

```console
$ cargo run -- Nadel Heuhaufen
   Compiling minigrep v0.1.0 (file:///projects/minigrep)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 1.57s
     Running `target/debug/minigrep Nadel Heuhaufen`
[src/main.rs:5:5] args = [
    "target/debug/minigrep",
    "Nadel",
    "Heuhaufen",
]
```

Beachte, dass der erste Wert im Vektor `"target/debug/minigrep"` ist, was der
Name unserer Binärdatei ist. Dies entspricht dem Verhalten der Argumentliste in
C, sodass Programme bei ihrer Ausführung den Namen verwenden können, unter dem
sie aufgerufen wurden. Es ist oft praktisch, Zugriff auf den Programmnamen zu
haben, falls du ihn in Meldungen ausgeben oder das Verhalten des Programms
ändern möchtest, je nachdem, welcher Befehlszeilen-Alias zum Aufruf des
Programms verwendet wurde. Aber für die Zwecke dieses Kapitels ignorieren wir
ihn und speichern nur die beiden Argumente, die wir brauchen.

### Speichern der Argumentwerte in Variablen

Das Programm ist derzeit in der Lage, auf die als Kommandozeilenargumente
angegebenen Werte zuzugreifen. Jetzt müssen wir die Werte der beiden Argumente
in Variablen speichern, damit wir die Werte im restlichen Programm verwenden
können. Das tun wir in Codeblock 12-2.

<span class="filename">Dateiname: src/main.rs</span>

```rust,noplayground
use std::env;

fn main() {
    let args: Vec<String> = env::args().collect();

    let query = &args[1];
    let file_path = &args[2];

    println!("Suche nach {query}");
    println!("In Datei {file_path}");
}
```

<span class="caption">Codeblock 12-2: Erstellen von Variablen zur Aufnahme des
Such-Arguments und des Dateipfad-Arguments</span>

Wie wir gesehen haben, als wir den Vektor ausgegeben haben, nimmt der
Programmname den ersten Wert im Vektor bei `args[0]` ein, also beginnen wir
beim Index `1`. Das erste Argument, das `minigrep` annimmt, ist die
Zeichenkette, nach der wir suchen, also setzen wir eine Referenz auf das erste
Argument in die Variable `query`. Das zweite Argument wird der Dateipfad sein,
also setzen wir eine Referenz auf das zweite Argument in die Variable
`file_path`.

Wir geben vorübergehend die Werte dieser Variablen aus, um zu belegen, dass der
Code so funktioniert, wie wir es beabsichtigen. Lassen wir dieses Programm mit
den Argumenten `test` und `sample.txt` noch einmal laufen:

```console
$ cargo run test sample.txt
   Compiling minigrep v0.1.0 (file:///projects/minigrep)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.0s
     Running `target/debug/minigrep test sample.txt`
Suche nach test
In Datei sample.txt
```

Toll, das Programm funktioniert! Die Werte der Argumente, die wir brauchen,
werden in den richtigen Variablen gespeichert. Später fügen wir eine
Fehlerbehandlung hinzu, um mit bestimmten potentiellen Fehlersituationen
umzugehen, z.B. wenn der Benutzer keine Argumente angibt; für den Moment
ignorieren wir diese Situation und arbeiten stattdessen daran, die
Datei-Lesefunktion hinzuzufügen.

[ch13]: ch13-00-functional-features.html
[ch7-idiomatic-use]:
ch07-04-bringing-paths-into-scope-with-the-use-keyword.html#idiomatische-use-pfade-erstellen
[crates-io]: https://crates.io/
