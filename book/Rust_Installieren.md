# Rust installieren

Der erste Schritt um Rust zu nutzen ist es zu installieren. Es gibt eine Reihe
von Möglichkeiten Rust zu installieren, aber die einfachste ist das `rustup`
Skript zu verwenden. Wenn du Linux oder einen Mac verwendest, dann ist alles
was du tun musst dies:

> Hinweis: Du darfst nicht die `$`-Zeichen eintippen, sie dienen nur dazu den
> Anfang eines jeden Befehls anzuzeigen. Du wirst im Internet viele Tutorials
> finden, welche dieser Konvention folgen: `$` für Befehle die als normaler
> Benutzer ausgeführt werden und `#` für Befehle, welche du als Administrator
> ausführen solltest.

```bash
$ curl -sf -L https://static.rust-lang.org/rustup.sh | sh
```

Falls du um die [potenzielle Unsicherheit][insecurity] bezüglich `curl | sh`
besorgt bist, dann lies bitte weiter und schau dir unseren Disclaimer weiter
unten an. Und benutze ruhig die zwei-schritte Version der Installation und
untersuche unser Installationsskript:

```bash
$ curl -f -L https://static.rust-lang.org/rustup.sh -O
$ sh rustup.sh
```

[insecurity]: http://curlpipesh.tumblr.com

Wenn du Windows benutzt, dann lade bitte den passenden
[Installer][install-page] herunter.

**ACHTUNG:** Der Windows Installer fügt Rust standardmäßig **nicht** der
`%PATH%` Systemvariable hinzu. Falls dies die einzige Rust Version ist, die du
installierst, und du sie von der Eingabeaufforderung aufrufen können möchtest,
dann klicke im Installationsdialog auf "Advanced" und stelle sicher, dass auf
der "Product Features" Seite "Add to PATH" auf die Festplatte installiert wird.

[install-page]: https://www.rust-lang.org/install.html

## Deinstallieren

Falls du dich dazu entscheidest Rust nicht mehr haben zu wollen, dann werden
wir ein bisschen traurig sein, aber das ist in Ordnung. Nicht jede
Programmiersprache ist für jeden toll. Führe einfach das uninstall Skript aus:

```bash
$ sudo /usr/local/lib/rustlib/uninstall.sh
```

Falls du den Windows Installer verwendet hast, dann führe einfach die `.msi`
erneut aus und dir wird eine Option zum deinstallieren angezeigt werden.

## Der versprochene Disclaimer

Manche leute werden, ein wenig zurecht, sehr verärgert, wenn man ihnen sagt,
dass sie `curl | sh` ausführen sollen. Im Grunde vertraut man dabei den guten
Leuten, die Rust pflegen, dass sie nicht deinen Computer hacken und böse Dinge
tun. Das ist ein guter Instinkt! Falls du einer dieser Leute bist, dann schau
dir bitte die Dokumentation auf [Rust aus den Quellen erstellen][from-source]
oder auf [der offiziellen Binary Downloadseite][install-page] an.

[from-source]: https://github.com/rust-lang/rust#building-from-source

## Plattformunterstützung

Oh, wir sollten auch die offiziell unterstützten Plattformen erwähnen:

* Windows (7, 8, Server 2008 R2)
* Linux (2.6.18 oder neuer, verschiedene Distributionen), x86 und x86-64
* OSX 10.7 (Lion) oder neuer, x86 und x86-64

Wir testen Rust ausführlich auf diesen Plattformen und ebenfalls auf ein paar
anderen, wie z.B. Android. Aber diese sind jene, die am ehesten funktionieren,
da sie besser getestet sind.

Zuletzt ein Kommentar über Windows. Rust sieht, seit seinem Release, Windows
als eine first class Plattform an, aber wenn wir ehrlich sind, ist das Windows
Erlebnis nicht so integriert wie das Linux/OS X Erlebnis ist. Wir arbeiten
daran! Falls etwas nicht funktioniert ist es ein Bug. Lass es uns bitte wissen,
wenn das passiert. Jeder einzelne Commit wird mit Windows getestet, genau wie
bei jeder anderen Plattform.

## Nach der Installation

Wenn du Rust installiert hast, dann kannst du eine Shell/Eingabeaufforderung
öffnen und dies eingeben:

```bash
$ rustc --version
```

Du solltest eine Versionsnummer, einen Commit Hash und ein Commit Datum sehen.
Wenn du gerade die Version 1.3.0 installiert hast, dann solltest du folgendes
sehen:

```text
rustc 1.3.0 (9a92aaf19 2015-09-15)
```

Falls ja, dann hast du Rust erfolgreich installiert! Gratuliere!

Falls nicht, und du Windows nutzt, dann Prüfe, dass Rust in deiner `%PATH%`
Systemvariable ist. Wenn nicht, dann starte den Installer nochmal und wähle
"Change" auf der "Change, repair, or remove installation" Seite und stelle
sicher, dass "Add to PATH" auf die Festplatte installiert wird.

Dieser Installer installiert auch eine lokale Kopie der Dokumentation, sodass
du sie offline lesen kannst. Auf UNIX Systemen findet man sie in
`/usr/local/share/doc/rust`. Auf Windows ist sie in dem `share/doc` Ordner, wo
auch immer du Rust hin installiert hast.

Falls nicht gibt es eine Reihe von Orten wo du Hilfe bekommen kannst.
Der beste ist
[der englischsprachige #rust IRC Channel auf irc.mozilla.org][irc],
welchen du mittels [Mibbit][mibbit] betreten kannst. Klick auf den Link und
Chattest sofort mit anderen Rustlern. Falls du dich lieber auf deutsch
unterhalten möchtest, dann kannst du auch [#rust-de via Mibbit betreten][mibbit-de].
Andere großartige Ressourcen beinhalten das [Benutzerforum][users] und
[Stack Overflow][stackoverflow].

[irc]: irc://irc.mozilla.org/#rust
[mibbit]: http://chat.mibbit.com/?server=irc.mozilla.org&channel=%23rust
[mibbit-de]: http://chat.mibbit.com/?server=irc.mozilla.org&channel=%23rust-de
[users]: https://users.rust-lang.org/
[stackoverflow]: http://stackoverflow.com/questions/tagged/rust