## Installation

Der erste Schritt ist, Rust zu installieren. Wir werden Rust mittels `rustup`
herunterladen, einem Kommandozeilenwerkzeug für die Verwaltung von Rust-Versionen
und dazugehörigen Werkzeugen. Du wirst eine Internetverbindung für den Download
benötigen.

> Anmerkung: Falls du `rustup` aus irgendeinem Grund nicht verwenden möchtest,
> schaue bitte auf der Seite [Andere Rust-Installationsmethoden][otherinstall] nach
> anderen Möglichkeiten.

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
$ curl --proto '=https' --tlsv1.3 https://sh.rustup.rs -sSf | sh
```

Dieser Befehl lädt ein Skript herunter und startet die Installation
von `rustup`, welches die neueste stabile Version von Rust installiert.
Du wirst ggf. aufgefordert, dein Passwort einzugeben. Falls die Installation
erfolgreich ist, erscheint die folgende Zeile:

```text
Rust is installed now. Great!
```

Außerdem benötigst su einen Programmbinder (linker), ein Programm, das Rust
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
wirst du eine Meldung erhalten mit der Aufforderung, ebenfalls die
C++-Bauwerkzeuge für Visual Studio 2013 oder neuer zu installieren.
Der leichteste Weg, um an die Bauwerkzeuge zu gelangen, ist die Installation
der [Bauwerkzeuge für Visual Studio 2019][visualstudio]. Sobald du gefragt
wirst, welche Komponenten installiert werden sollen, wähle die „C++ build tools“
und zusätzlich das Windows 10 SDK und das englische Sprachpaket aus.

Der Rest dieses Buchs verwendet Befehle, die sowohl in *cmd.exe* als auch
in der PowerShell funktionieren. Falls es spezifische Unterschiede geben sollte,
werden wir diese erläutern.

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

### Fehlersuche

Um zu überprüfen, ob du Rust erfolgreich installiert hast, führe folgenden
Befehl auf der Kommandozeile aus:

```console
$ rustc --version
```

Du solltest die Versionsnummer, den Hashwert und das Datum der neuesten
stabilen Version in folgendem Format sehen:

```text
rustc x.y.z (abcabcabc yyyy-mm-dd)
```

Falls du diese Information sehen kannst, hast du Rust erfolgreich installiert.
Siehst du sie jedoch nicht und dein Betriebssystem ist Windows, prüfe ob Rust
in deiner Umgebungsvariable `%PATH%` eingetragen ist. Ist dies der Fall und Rust
funktioniert dennoch nicht, dann gibt es einige Orte, wo du Hilfe bekommen kannst.
Der einfachste ist der Kanal #beginners im [offiziellen Rust Discord][discord].
Dort kannst du mit anderen Rustaceans (ein alberner Spitzname, den wir uns selbst
gegeben haben) chatten, die dir gerne weiterhelfen. Andere hilfreiche Quellen
sind [das Benutzerforum][users] and [Stack Overflow][stackoverflow].

### Lokale Dokumentation

Die Rust-Installation enthält auch eine lokale Kopie der Dokumentation, sodass
du sie ohne Internetverbindung lesen kannst. Führe `rustup doc` aus, um die
lokale Dokumentation in deinem Browser zu öffnen.

Falls du dir nicht sicher bist, wie du einen Typ oder eine Funktion aus der
Standardbibliothek verwenden sollst, dann schau in der API-Dokumentation nach!

[discord]: https://discord.gg/rust-lang
[install]: https://www.rust-lang.org/tools/install
[otherinstall]: https://forge.rust-lang.org/infra/other-installation-methods.html
[stackoverflow]: https://stackoverflow.com/questions/tagged/rust
[users]: https://users.rust-lang.org/
[visualstudio]: https://visualstudio.microsoft.com/visual-cpp-build-tools/
