# Hallo Welt!

Nun, da du Rust installiert hast, lass uns dein erstes Rust Programm schreiben.
Es ist traditionell sein erstes Programm in einer neuen Sprache den Text
"Hallo Welt!" auf dem Bildschirm ausgeben zu lassen. Die tolle Sache an so
einem einfachen Programm ist, dass du überprüfen kannst, dass dein Compiler
nicht einfach nur installiert ist, sondern auch ordnungsgemäß funktioniert.
Und Informationen auf dem Bildschirm auszugeben ist eine ziemlich häufige Sache.

Das erste, was wir tun müssen, ist eine Datei erstellen, in der wir den Code
packen. Ich mag es ein `projekte` Verzeichnis in meinem Heimverzeichnis zu
erstellen und alle meine Projekte dort aufzubewahren. Rust ist es egal wo dein
Code liegt.

Dies führt sogar zu einer anderen Angelegenheit, welche wir behandeln sollten:
Diese Anleitung wird annehmen, dass du grundlegendend mit der Kommandozeile
vertraut bist. Rust selbst stellt keine besonderen Anforderungen an deine
Editierwerkzeuge oder wo dein Code liegt. Falls du eine IDE der Kommandozeile
vorziehst, dann möchtest du vielleicht [SolidOak][solidoak] oder Plugins für
deine bevorzugte IDE ausprobieren. Es existieren eine Reihe von Erweiterungen
von unterschiedlicher Qualität, welche von der Community entwickelt werden.
Das Rust Team liefert auch [Plugins für verschiedene Editoren][plugins].
Deine IDE einzurichten sprengt den Rahmen dieses Tutorials, also schau in die
Dokumentation für dein spezielles Setup.

[solidoak]: https://github.com/oakes/SolidOak
[plugins]: https://github.com/rust-lang/rust/blob/master/src/etc/CONFIGS.md

Da dies nun aus dem Raum ist, lass uns damit anfangen ein Verzeichnis in unserem
Projekte Verzeichnis anzulegen.

```bash
$ mkdir ~/projekte
$ cd ~/projekte
$ mkdir hallo_welt
$ cd hallo_welt
```

Wenn Windows und nicht die Powershell benuzt, dann wird `~` wohl nicht
funktionieren. Für mehr Details, schaue in die Dokumentation für deine Shell.

Lass uns als nächstes eine neue Quelltextdatei anlegen. Wir werden unsere Datei
`main.rs` nennen. Rust Dateien haben immer eine `.rs` Endung. Wenn du mehr
als ein Wort in deinem Dateinamen verwendest, dann benutze einen Unterstrich:
`hallo_welt.rs` anstatt `hallowelt.rs`.

Nun, da wir unsere Datei offen haben, tippen wir folgendes ein:

```rust
fn main() {
    println!("Hallo Welt!");
}
```

Speichere die Datei und tippe dann in die Kommandozeile:

```bash
$ rustc main.rs
$ ./main # oder main.exe unter Windows
Hallo Welt!
```

Erfolg! Lass uns durchgehen was gerade im Detail passiert ist.

```rust
fn main() {

}
```

Diese Zeilen definieren eine *Funktion* in Rust. Die `main` Funktion ist
besonders: Sie ist der Anfang eines jeden Rust Programmes. Die erste Zeile sagt
"Ich deklariere eine Funktion namens `main`, welche keine Argumente entgegen
nimmt und nichts zurückgibt". Falls es Argumente gäbe, dann würden sie zwischen
den Klammern (`(` und `)`) stehen, und, weil wir nichts von dieser Funktion
zurückgeben, können wir den Rückgabetyp koomplett weglassen. Darauf gehen
wir später ein.

Du wirst auch feststellen, dass die Funktion von geschweiften Klammern (`{` und
`}`) umgeben ist. Rust benötigt diese um jeden Funktionskörper herum. Es gilt
als guten Stil die geöffnete Klammer in die selbe Zeile wie die
Funktionsdeklaration, mit einem Leerzeichen dazwischen, zu setzen.

Als nächstes kommt diese Zeile:

```rust
    println!("Hallo Welt");
```

Diese Zeile macht die ganze Arbeit in unserem kleinen Programm. Es gibt eine
Zahl von Details die hier wichtig sind. Das erste ist, dass die Zeile mit
vier Leerzeichen anstatt mit Tabs eingerückt ist. Bitte stelle den Editor
deiner Wahl so ein, dass mit der Tab-Taste vier Leerzeichen eingefügt werden.
Wir bieten ein paar [Beispieleinstellungen für verschiedene Editoren][configs]
an.

[configs]: https://github.com/rust-lang/rust/tree/master/src/etc/CONFIGS.md

Der Zweite Punkt ist der `println!()` Teil. Dieser ruft ein Rust
[Makro][macro] (so wird Metaprogramierung in Rust gemacht) auf. Wenn es eine
Funktion wäre, dann wüde es so aussehen: `println()`. Für unsere Zwecke
brauchen wir uns nicht um diesen Unterschied kümmern. Merk dir einfach, dass du
manchmal ein `!` sehen wirst und es bedeutet, dass du ein Makro, anstatt eine
normalen Funktion, aufrufst. Rust implementiert aus einem guten Grund
`println!` als Makro anstatt als normale Funktion, aber das ist ein
fortgeschrittenes Thema. Eine letzte Sache noch: Rusts Makros sind bedeutend
anders als C Makros, falls du die mal benutzt hast. Hab keine Angst Makros zu
benutzen. Wir werden die Details später noch behandeln, aber für den Moment
musst du uns vertrauen.

[macro]: book/Makros.md

Weiter gehts. "Hallo World" ist ein ‘String’. Strings sind ein überraschend
kompliziertes Thema in einer Systemprogrammiersprache, und dies ist ein
‘statisch allokierter’ String. Falls du mehr über Allokierung lesen möchtest,
dann schau dir [der Stack und der Heap][allocation], aber du musst es nicht
unbedingt wenn du nicht möchtest. Wir übergeben den String als Argument an
`println!`, was dann den String auf dem Bildschirm ausgibt. Leicht genug!

[allocation]: book/Der_Stack_Und_Der_Heap.md

Weiterhin endet die Zeile mit einem Semikolon (`;`). Rust ist eine
[‘Ausdrucksorientierte’ Sprache][expression-oriented language], was bedeuted,
dass die meisten Dinge Ausdrücke anstatt Anweisungen sind. Das `;` wird
benutzt um anzuzeigen, dass der Ausdruck zuende ist und der nächste beginnen
kann. Die meisten Zeilen in Rust Code enden mit einem `;`.

[expression-oriented language]: Glossar.md#ausdrucksorientierte-sprache

Und zum Schluss natürlich kompilieren wir unser Programm und lassen es laufen.
Wir können mit unserem Compiler `rustc` kompilieren, indem wir den Namen
unserer Quelltextdatei angeben:

```bash
$ rustc main.rs
```

Dies ist ähnlich wie bei `gcc` oder `clang`, falls du einen C oder C++
Hintegrund hast. Rust wird eine eine binäre asuführbare Datei ausgeben.
Du kannst sie mittels `ls` sehen:

```bash
$ ls
main  main.rs
```

Oder unter Windows:

```bash
$ dir
main.exe  main.rs
```

Es existieren nun zwei Dateien: Unser Quellcode mit der `.rs` Endung und eine
ausführbare Datei (`main.exe` unter Window, `main` überall sonst).

```bash
$ ./main  # or main.exe on Windows
```

Dies gibt nun unseren `Hallo Welt!` text in unserer Kommandozeile aus.

Falls du von dynamischen Sprachen wie Ruby, Python oder JavaScript kommst, dann
bist du vielleicht nicht daran gewöhnt, dass diese zwei Schritte getrennt sind.
Rust ist eine ‘ahead-of-time compiled language’, was bedeutet, dass man ein
Programm kompilieren und dann jemand anderem geben kann ohne, dass diese
Person Rust zur Ausführung benötigt. Wenn man jemandem eine `.rb`, `.py` oder
`.js` gibt, dann benötigt dieser Jemand eine installierte
Ruby/Python/JavaScript Implementierung, aber man braucht nur einen Befehl um
zu kompilieren und auszuführen. Im Sprachendesign ist alles ein Kompromiss und
Rust hat seine Entscheidung getroffen.

Gratuliere! Du hast nun offiziell ein Rust Programm geschrieben. Das macht dich
nun zu einem Rust Programmier! Willkommen.

Als nächstes würde ich dich gerne mit einem anderen Werkzeug bekanntmachen, 
nämlich mit Cargo, welches benutzt wird um realitätsnahe Programme zu
schreiben. Nur `rustc` zu benutzen ist nett für simple Sachen, aber während 
dein Projekt wächst wirst du etwas haben wollen, was dir hilft alle
Möglichkeiten die dir `rustc` bietet, zu managen und es dir leicht macht
code mit anderen Leuten und Projekten zu teilen.
