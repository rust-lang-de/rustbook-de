## Installation

Der erste Schritt ist, Rust zu installieren. Wir werden Rust mittels `rustup`
herunterladen, einem Kommandozeilenwerkzeug für die Verwaltung von Rust-Versionen
und dazugehörigen Werkzeugen. Du wirst eine Internetverbindung für den Download
benötigen.

> Anmerkung: Falls du `rustup` aus irgendeinem Grund nicht verwenden möchtest,
> schaue bitte auf der Seite [Andere Rust-Installationsmethoden][otherinstall]
> nach anderen Möglichkeiten.

Die folgenden Schritte installieren die neueste stabile Version des
Rust-Compilers. Rust garantiert Stabilität und stellt somit sicher,
dass alle kompilierbaren Beispiele in diesem Buch auch mit neueren
Rust-Versionen kompilierbar bleiben werden. Die Konsolenausgabe
der Beispiele kann sich zwischen Versionen leicht unterscheiden,
weil Rust oft Fehlermeldungen und Warnungen verbessert.
Anders ausgedrückt, jede neuere stabile Version von Rust, die du
mithilfe dieser Schritte installierst, sollte wie erwartet mit dem
Inhalt dieses Buches funktionieren.

> ### Kommandozeilen-Schreibweise
>
> In diesem Kapitel und im ganzen Buch werden wir einige Befehle auf der
> Konsole zeigen. Alle Zeilen, die du in die Konsole eingeben sollst,
> beginnen mit `$`. Du brauchst das `$`-Zeichen nicht einzugeben;
> es weist nur auf den Beginn jedes Befehls hin. Zeilen, die nicht mit
> `$` beginnen, zeigen normalerweise die Ausgabe eines vorherigen Befehls.
> PowerShell-spezifische Beispiele werden außerdem `>` anstelle von `$`
> verwenden.

### Die Installation von `rustup` in Linux und macOS

Falls du Linux oder macOS verwendest, öffne ein Konsolenfenster und gib den
folgenden Befehl ein:

```console
$ curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
```

Dieser Befehl lädt ein Skript herunter und startet die Installation
von `rustup`, welches die neueste stabile Version von Rust installiert.
Du wirst ggf. aufgefordert, dein Passwort einzugeben. Nach erfolgreicher
Installation erscheint folgende Zeile:

```text
Rust is installed now. Great!
```

Außerdem benötigst du einen Programmbinder (linker), ein Programm, das Rust
verwendet, um die kompilierten Ausgaben in eine Datei zusammenzuführen.
Wahrscheinlich hast du bereits einen. Wenn du Linker-Fehler erhältst, solltest
du einen C-Compiler installieren, der in der Regel auch einen Linker enthält.
Ein C-Compiler ist auch deshalb nützlich, weil einige gängige Rust-Pakete von
C-Code abhängen und daher einen C-Compiler benötigen.

Unter macOS erhältst du einen C-Compiler, indem du folgendes ausführst:

```console
$ xcode-select --install
```

Linux-Benutzer sollten in der Regel GCC oder Clang installieren, je nach
Dokumentation ihrer Distribution. Wenn du zum Beispiel Ubuntu verwendest,
kannst du das Paket `build-essential` installieren.

### Die Installation von `rustup` in Windows

Rufe [https://www.rust-lang.org/tools/install][install] auf und folge
den Anweisungen, um Rust in Windows zu installieren. Während der Installation
wirst du eine Meldung erhalten, dass du auch die MSVC Bauwerkzeuge für Visual
Studio 2013 oder höher benötigst.

Um die Bauwerkzeuge zu erhalten, musst du [Visual Studio 2022][visualstudio]
installieren. Wenn du gefragt wirst, welche Komponenten installiert werden
sollen, gib folgendes an:

* „Desktop Development with C++“
* Das Windows 10 oder 11 SDK
* Das englische Sprachpaket zusammen mit einem beliebigen anderen Sprachpaket
  deiner Wahl.

Der Rest dieses Buchs verwendet Befehle, die sowohl in *cmd.exe* als auch
in der PowerShell funktionieren. Falls es spezifische Unterschiede geben sollte,
werden wir diese erläutern.

### Fehlersuche

Um zu überprüfen, ob du Rust korrekt installiert hast, öffne eine
Kommandozeile und gib folgende Zeile ein:

```console
$ rustc --version
```

Du solltest die Versionsnummer, den Commit-Hash und das Commit-Datum für die
letzte stabile Version, die veröffentlicht wurde, in folgendem Format sehen:

```text
rustc x.y.z (abcabcabc jjjj-mm-tt)
```

Wenn du diese Information siehst, hast du Rust erfolgreich installiert! Wenn du
diese Information nicht siehst, überprüfe, ob Rust in deiner Systemvariable
`%PATH%` wie folgt enthalten ist.

In Windows CMD verwende:

```console
> echo %PATH%
```

In PowerShell verwende:

```powershell
> echo $env:Path
```

In Linux und macOS verwende:

```console
$ echo $PATH
```

Wenn das alles korrekt ist und Rust immer noch nicht funktioniert, gibt es
mehrere Stellen, an denen du Hilfe bekommen kannst. Wie du mit anderen
Rust-Entwicklern in Kontakt treten kannst, erfährst du auf der
[Gemeinschafts-Seite][community].

### Aktualisieren und Deinstallieren

Nachdem du Rust mithilfe von `rustup` installiert hast, ist es einfach,
auf die neueste Version zu aktualisieren. Führe folgenden Befehl auf der
Kommandozeile aus:

```console
$ rustup update
```

Um Rust und `rustup` zu deinstallieren, führe folgenden Befehl aus:

```console
$ rustup self uninstall
```

### Lokale Dokumentation

Die Rust-Installation enthält auch eine lokale Kopie der Dokumentation, sodass
du sie ohne Internetverbindung lesen kannst. Führe `rustup doc` aus, um die
lokale Dokumentation in deinem Browser zu öffnen.

Falls du dir nicht sicher bist, wie du einen Typ oder eine Funktion aus der
Standardbibliothek verwenden sollst, dann schau in der API-Dokumentation nach!

[community]: https://www.rust-lang.org/community
[install]: https://www.rust-lang.org/tools/install
[otherinstall]: https://forge.rust-lang.org/infra/other-installation-methods.html
[visualstudio]: https://visualstudio.microsoft.com/downloads/
