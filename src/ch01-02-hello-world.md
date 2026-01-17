## Hallo Welt

Nachdem du Rust installiert hast, lass uns dein erstes Rust-Programm schreiben.
Wenn man eine neue Sprache lernt, ist es üblich, ein kleines Programm zu
schreiben, das den Text `Hallo Welt!` auf dem Bildschirm ausgibt, also werden
wir hier das gleiche tun!

> Hinweis: Dieses Buch setzt grundlegende Vertrautheit mit der Kommandozeile
> voraus. Rust stellt keine besonderen Anforderungen an deine Textbearbeitung
> oder Werkzeuge oder an den Ort, an dem dein Code lebt. Wenn du also lieber
> eine IDE statt der Kommandozeile verwenden möchtest, kannst du deine
> bevorzugte IDE verwenden. Viele IDEs bieten mittlerweile einen gewissen Grad
> an Rust-Unterstützung; Einzelheiten findest du in der Dokumentation der IDE.
> Das Rust-Team hat sich darauf konzentriert, eine großartige IDE-Unterstützung
> mittels `rust-analyzer` zu ermöglichen. Siehe [Anhang D][devtools] für
> weitere Details.

### Projektverzeichniss aufsetzen

Du beginnst damit, ein Verzeichnis zum Speichern deines Rust-Codes zu
erstellen. Es ist Rust egal, wo dein Code lebt, aber für die Übungen und
Projekte in diesem Buch schlagen wir vor, ein Verzeichnis _projects_ in deinem
Hauptverzeichnis anzulegen und all deine Projekte dort abzulegen.

Öffne ein Terminal und gib die folgenden Befehle ein, um ein Verzeichnis
_projects_ und ein Verzeichnis für das Projekt „Hallo Welt!“ innerhalb des
Verzeichnisses _projects_ zu erstellen.

Gib dies bei Linux, macOS und PowerShell unter Windows ein:

```console
$ mkdir ~/projects
$ cd ~/projects
$ mkdir hello_world
$ cd hello_world
```

Bei Windows CMD gib dies ein:

```cmd
> mkdir "%USERPROFILE%\projects"
> cd /d "%USERPROFILE%\projects"
> mkdir hello_world
> cd hello_world
```

### Grundlagen eines Rust-Programms

Als nächstes erstelle eine neue Quelldatei und nenne sie _main.rs_.
Rust-Dateien enden immer mit der Erweiterung _.rs_. Wenn du mehr als ein Wort
in deinem Dateinamen verwendest, verwende einen Unterstrich, um sie zu trennen.
Verwende zum Beispiel _hello_world.rs_ statt _helloworld.rs_.

Öffne nun die Datei _main.rs_, die du gerade erstellt hast, und gib den Code in
Codeblock 1-1 ein.

<span class="filename">Dateiname: main.rs</span>

```rust
fn main() {
    println!("Hallo Welt!");
}
```

<span class="caption">Codeblock 1-1: Ein Programm, das `Hallo Welt!`
ausgibt</span>

Speichere die Datei und gehe zurück zu deinem Terminalfenster im Verzeichnis
_~/projects/hello_world_. Gib unter Linux oder MacOS die folgenden Befehle ein,
um die Datei zu kompilieren und auszuführen:

```console
$ rustc main.rs
$ ./main
Hallo Welt!
```

Unter Windows gib den Befehl `.\main` anstelle von `./main` ein:

```powershell
> rustc main.rs
> .\main
Hallo Welt!
```

Unabhängig von deinem Betriebssystem sollte die Zeichenkette `Hallo Welt!` im
Terminal ausgegeben werden. Wenn du diese Ausgabe nicht siehst, lies im
Abschnitt [„Fehlersuche“][troubleshooting] des Installationsabschnitts nach,
wie du Hilfe erhalten kannst.

Wenn `Hallo Welt!` ausgegeben wurde, herzlichen Glückwunsch! Du hast offiziell
ein Rust-Programm geschrieben. Das macht dich zu einem Rust-Programmierer
&ndash; willkommen!

### Die Anatomie eines Rust-Programms

Lass uns im Detail Revue passieren, was gerade in deinem „Hallo Welt!“-Programm
passiert ist. Hier ist das erste Teil des Puzzles:

```rust
fn main() {

}
```

Diese Zeilen definieren eine Funktion namens `main` in Rust. Die Funktion
`main` ist eine Besonderheit: Sie ist immer der erste Code, der in jedem
ausführbaren Rust-Programm ausgeführt wird. In diesem Fall deklariert die erste
Zeile eine Funktion mit dem namen `main`, die keine Parameter hat und nichts
zurückgibt. Wenn es Parameter gäbe, würden sie innerhalb der Klammern `()`
stehen.

Der Funktionsrumpf in geschweifte Klammern `{}` eingehüllt. Rust erfordert
diese um alle Funktionsrümpfe. Es ist guter Stil, die öffnende geschweifte
Klammer in dieselbe Zeile wie die Funktionsdeklaration zu platzieren und
dazwischen ein Leerzeichen einzufügen.

> Hinweis: Wenn du einen Standardstil für alle Rust-Projekte verwenden
> möchtest, kannst du ein automatisches Formatierungswerkzeug namens `rustfmt`
> verwenden, um deinen Code in einem bestimmten Stil zu formatieren (mehr über
> `rustfmt` im [Anhang D][devtools]). Das Rust-Team hat dieses Tool wie `rustc`
> in die Standard-Rust-Distribution aufgenommen, es sollte also bereits auf
> deinem Computer installiert sein!

Innerhalb der Funktion `main` befindet sich der folgende Code:

```rust
println!("Hallo Welt!");
```

Diese Zeile erledigt die ganze Arbeit in diesem kleinen Programm: Sie gibt Text
auf dem Bildschirm aus. Hier gibt es drei wichtige Details zu beachten.

Erstens ruft `println!` ein Rust-Makro auf. Wenn es stattdessen eine Funktion
aufrufte, würde diese als `println` (ohne `!`) angegeben werden. Rust-Makros
sind eine Möglichkeit, Code zu schreiben, der Code zur Erweiterung der
Rust-Syntax generiert. Wir werden sie in [Kapitel 20][ch20-macros] näher
erläutern. Im Moment musst du nur wissen, dass die Verwendung eines `!`
bedeutet, dass du ein Makro anstelle einer normalen Funktion aufrufst und dass
Makros nicht immer denselben Regeln folgen wie Funktionen.

Zweitens siehst du die Zeichenkette `"Hallo Welt!"`. Wir übergeben diese
Zeichenkette als Argument an `println!`, und die Zeichenkette wird auf dem
Bildschirm ausgegeben.

Drittens beenden wir die Zeile mit einem Semikolon (`;`), was anzeigt, dass
dieser Ausdruck beendet ist und der nächste beginnen kann. Die meisten Zeilen
eines Rust-Codes enden mit einem Semikolon.

### Compilierung und Ausführung

Du hast gerade ein neu erstelltes Programm ausgeführt, also lass uns jeden
Schritt in diesem Prozess untersuchen.

Bevor du ein Rust-Programm ausführst, musst du es mit dem Rust-Compiler
kompilieren, indem du den Befehl `rustc` eingibst und ihm den Namen deiner
Quelldatei übergibst, so wie hier:

```console
$ rustc main.rs
```

Wenn du einen C- oder C++-Hintergrund hast, wirst du feststellen, dass dies
ähnlich wie `gcc` oder `clang` ist. Nach erfolgreicher Kompilierung gibt Rust
eine ausführbare Binärdatei aus.

Unter Linux, MacOS und PowerShell unter Windows kannst du die ausführbare Datei
sehen, indem du den Befehl `ls` in deinem Terminal eingibst:

```console
$ ls
main  main.rs
```

Unter Linux und MacOS siehst du zwei Dateien. Mit PowerShell unter Windows
siehst du die gleichen drei Dateien, die du mit CMD sehen würdest. Bei CMD
unter Windows würdest du folgendes eingeben:

```cmd
> dir /B %= die Option /B bewirkt, dass nur die Dateinamen angezeigt werden =%
main.exe
main.pdb
main.rs
```

Dies zeigt die Quellcodedatei mit der Erweiterung _.rs_, die ausführbare Datei
(_main.exe_ unter Windows, aber _main_ auf allen anderen Plattformen) und, bei
Verwendung von Windows, eine Datei mit Debugging-Informationen mit der
Erweiterung _.pdb_. Von hier aus führst du die Datei _main_ oder _main.exe_
aus, so wie hier:

```console
$ ./main # oder .\main unter Windows
```

Wenn _main.rs_ dein „Hallo Welt!“-Programm wäre, würde diese Zeile „Hallo
Welt!“ in deinem Terminal ausgeben.

Wenn du mit einer dynamischen Sprache wie Ruby, Python oder JavaScript besser
vertraut bist, bist du es möglicherweise nicht gewohnt, ein Programm in
getrennten Schritten zu kompilieren und auszuführen. Rust ist eine _vorab
kompilierte_ (ahead-of-time compiled) Sprache, d.h. du kannst ein Programm
kompilieren und die ausführbare Datei an jemand anderen weitergeben, und dieser
kann das Programm auch ohne Installation von Rust ausführen. Wenn du jemandem
eine _.rb_-, _.py_- oder _.js_-Datei gibst, muss er eine Ruby-, Python- bzw.
JavaScript-Implementierung installiert haben. Aber in diesen Sprachen benötigst
du nur einen Befehl, um dein Programm zu kompilieren und auszuführen. Beim
Sprachdesign ist alles ein Kompromiss.

Einfach mit `rustc` zu kompilieren ist für einfache Programme in Ordnung, aber
wenn dein Projekt wächst, wirst du alle Optionen verwalten und es einfach
machen wollen, deinen Code weiterzugeben. Als Nächstes stellen wir dir das
Cargo-Tool vor, das dir beim Schreiben von Rust-Programmen aus der realen Welt
helfen wird.

[ch20-macros]: ch20-05-macros.html
[devtools]: appendix-04-useful-development-tools.html
[troubleshooting]: ch01-01-installation.html#fehlersuche
