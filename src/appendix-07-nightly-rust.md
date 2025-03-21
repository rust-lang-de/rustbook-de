## Anhang G: Wie Rust erstellt wird und „nächtliches Rust“

In diesem Anhang geht es darum, wie Rust erstellt wird und wie sich das auf
dich als Rust-Entwickler auswirkt.

### Stabilität ohne Stillstand

Als Sprache kümmert sich Rust _viel_ um die Stabilität deines Codes. Wir
wollen, dass Rust ein felsenfestes Fundament ist, auf dem du aufbauen kannst,
und wenn sich die Dinge ständig ändern würden, wäre das unmöglich. Gleichzeitig
werden wir, wenn wir nicht mit neuen Funktionen experimentieren können,
wichtige Mängel vielleicht erst nach ihrer Veröffentlichung entdecken, wenn wir
die Dinge nicht mehr ändern können.

Unsere Lösung für dieses Problem ist das, was wir „Stabilität ohne Stillstand“
nennen, und unser Leitsatz lautet: Du solltest niemals Angst vor einem Upgrade
auf eine neue Version des stabilen Rust haben müssen. Jedes Upgrade sollte
schmerzlos sein, aber auch neue Funktionalitäten, weniger Fehler und schnellere
Kompilierzeiten mit sich bringen.

### Tüff, tüff! Veröffentlichungs-Kanäle und Zugfahren

Die Rust-Entwicklung erfolgt nach einem _Zugfahrplan_ (train schedule). Das
bedeutet, dass die gesamte Entwicklung auf dem `master`-Zweig der
Rust-Versionsverwaltung durchgeführt wird. Die Veröffentlichungen folgen einem
Software-Veröffentlichungs-Zugmodell, das von Cisco IOS und anderen
Softwareprojekten verwendet wurde. Es gibt drei _Veröffentlichungskanäle_
(release channels) für Rust:

- Nächtlich (nightly)
- Beta
- Stabil (stable)

Die meisten Rust-Entwickler verwenden in erster Linie den stabilen Kanal, aber
diejenigen, die experimentelle neue Funktionen ausprobieren wollen, können
nächtlich oder beta verwenden.
 
Hier ist ein Beispiel dafür, wie der Entwicklungs- und Veröffentlichungsprozess
funktioniert: Nehmen wir an, das Rust-Team arbeitet an der Veröffentlichung von
Rust 1.5. Diese Veröffentlichung erfolgte im Dezember 2015, aber sie wird uns
realistische Versionsnummern liefern. Eine neue Funktionalität wird zu Rust
hinzugefügt: Eine neue Änderung (commit) kommt in den `master`-Zweig. Jede
Nacht wird eine neue nächtliche Version von Rust produziert. Jeder Tag ist ein
Veröffentlichungs-Tag und diese Veröffentlichungen werden automatisch von
unserer Veröffentlichungs-Infrastruktur erstellt. Mit der Zeit sehen unsere
Veröffentlichungen also so aus, einmal pro Nacht:

```text
nächtlich: * - - * - - *
```

Alle sechs Wochen ist es an der Zeit, eine neue Version vorzubereiten! Der
`beta`-Zweig der Rust-Versionsverwaltung verzweigt vom `master`-Zweig, der von
„nächtlich“ benutzt wird. Jetzt gibt es zwei Versionen:

```text
nächtlich: * - - * - - *
                       |
beta:                  *
```

Die meisten Rust-Nutzer verwenden Beta-Versionen nicht aktiv, sondern testen
gegen die Beta-Version in ihrem CI-System, um Rust bei der Entdeckung möglicher
Regressionen zu unterstützen. In der Zwischenzeit gibt es immer noch jede Nacht
eine nächtliche Veröffentlichung:

```text
nächtlich: * - - * - - * - - * - - *
                       |
beta:                  *
```

Sagen wir, es wird eine Regression gefunden. Gut, dass wir etwas Zeit hatten,
die Beta-Version zu testen, bevor sich die Regression in eine stabile Version
eingeschlichen hat! Die Fehlerkorrektur wird auf `master` angewendet, sodass
„nächtlich“ korrigiert wird, und dann wird die Fehlerkorrektur in den
`beta`-Zweig zurückportiert und eine neue Version der Beta erzeugt:

```text
nächtlich: * - - * - - * - - * - - * - - *
                       |
beta:                  * - - - - - - - - *
```

Sechs Wochen nachdem die erste Beta-Version erstellt wurde, ist es Zeit für
eine stabile Veröffentlichung! Der `stable`-Zweig wird aus dem `beta`-Zweig
erstellt:

```text
nächtlich: * - - * - - * - - * - - * - - * - * - *
                       |
beta:                  * - - - - - - - - *
                                         |
stabil:                                  *
```

Hurra! Rust 1.5 ist geschafft! Eines haben wir jedoch vergessen: Da die sechs
Wochen vergangen sind, brauchen wir auch eine neue Beta der _nächsten_ Version,
Rust 1.6. Nachdem also `stable` von `beta` abzweigt, zweigt die nächste Version
von `beta` wieder von `nightly` ab:

```text
nächtlich: * - - * - - * - - * - - * - - * - * - *
                       |                         |
beta:                  * - - - - - - - - *       *
                                         |
stabil:                                  *
```

Dies wird als „Zugmodell“ (train model) bezeichnet, weil alle sechs Wochen eine
Veröffentlichung „den Bahnhof verlässt“, aber immer noch eine Reise durch den
Betakanal machen muss, bevor sie als stabile Version ankommt.

Alle sechs Wochen veröffentlicht Rust eine Version, wie ein Uhrwerk. Wenn du
das Datum einer Rust-Veröffentlichung kennst, kennst du auch das Datum der
nächsten: Sie ist sechs Wochen später. Ein schöner Aspekt der alle sechs Wochen
geplanten Veröffentlichungen ist, dass der nächste Zug bald kommt. Wenn eine
Funktionalität eine bestimmte Veröffentlichung verpasst, brauchst du dir keine
Sorgen zu machen: In kurzer Zeit kommt die nächste! Dies trägt dazu bei, den
Druck zu verringern, bevor sich möglicherweise unausgefeilte Funktionalitäten
kurz vor Ablauf der Veröffentlichungsfrist einschleichen.

Dank dieses Prozesses kannst du jederzeit die nächste Rust-Version ausprobieren
und dich selbst davon überzeugen, dass ein Upgrade leicht möglich ist: Wenn
eine Beta-Version nicht wie erwartet funktioniert, kannst du dies dem Team
melden und sie vor der nächsten stabilen Version korrigieren lassen! Ein Bruch
in einer Beta-Version ist relativ selten, aber `rustc` ist immer noch ein Stück
Software und es gibt Fehler.

### Wartungsdauer

Das Rust-Projekt unterstützt die neueste stabile Version. Wenn eine neue
stabile Version veröffentlicht wird, erreicht die alte Version ihr
Lebensende (engl. end of life, EOL). Das bedeutet, dass jede Version
sechs Wochen lang unterstützt wird.

### Instabile Funktionalitäten

Bei diesem Veröffentlichungsmodell gibt es noch einen weiteren Haken: Instabile
Funktionalitäten. Rust verwendet eine Technik namens „Funktionalitäts-Schalter“
(feature flags), um festzulegen, welche Funktionalitäten in einer bestimmten
Version aktiviert sind. Wenn eine neue Funktionalität aktiv entwickelt wird,
landet sie auf dem `master` und damit in „nächtlich“, aber hinter einem
_Funktionalitäts-Schalter_. Wenn du als Nutzer eine in Entwicklung befindliche
Funktionalität ausprobieren möchtest, kannst du dies tun, aber du musst eine
nächtliche Version von Rust verwenden und deinen Quellcode mit dem
entsprechenden Schalter versehen, um sie nutzen zu können.

Wenn du eine Beta- oder stabile Version von Rust verwendest, kannst du keine
Funktionalitäts-Schalter verwenden. Dies ist der Schlüssel, der es uns
ermöglicht, neue Funktionen praktisch zu nutzen, bevor wir sie für immer für
stabil erklären. Diejenigen, die sich für das Allerneueste entscheiden wollen,
können dies tun, und diejenigen, die eine felsenfeste Erfahrung machen wollen,
können bei der stabilen Version bleiben und wissen, dass ihr Code nicht brechen
wird. Stabilität ohne Stillstand.

Dieses Buch enthält nur Informationen über stabile Funktionalitäten, da sich in
Entwicklung befindliche Funktionalitäten noch ändern, und sicherlich werden sie
sich zwischen dem Zeitpunkt, an dem dieses Buch geschrieben wurde, und dem
Zeitpunkt, an dem sie in stabilen Versionen aktiviert werden, unterscheiden.
Die Dokumentation für die nur nächtlich verfügbaren Funktionalitäten findest du
online.

### Rustup und die Rolle des nächtlichen Rust

Rustup macht es einfach, zwischen verschiedenen Veröffentlichungskanälen von
Rust zu wechseln, auf globaler oder projektbezogener Basis. Standardmäßig hast
du stabiles Rust installiert. Um die nächtliche Version zu installieren, mache
folgenden Aufruf:

```console
$ rustup toolchain install nightly
```

Du kannst auch alle _Werkzeugketten_ (toolchains) (Versionen von Rust und
zugehörigen Komponenten) sehen, die du mit `rustup` installiert hast. Hier ist
ein Beispiel auf dem Windows-Rechner einer deiner Autoren:

```powershell
> rustup toolchain list
stable-x86_64-pc-windows-msvc (default)
beta-x86_64-pc-windows-msvc
nightly-x86_64-pc-windows-msvc
```

Wie du sehen kannst, ist die stabile Werkzeugkette die Standardeinstellung. Die
meisten Rust-Nutzer verwenden meistens die stabile Version. Vielleicht möchtest
du die meiste Zeit die stabile Version verwenden, aber für ein bestimmtes
Projekt mit der nächtlichen Version arbeiten, weil dir eine innovative
Funktionalität wichtig ist. Um dies zu tun, kannst du `rustup override` im
Verzeichnis dieses Projekts benutzen, um die nächtliche Werkzeugkette als
diejenige zu setzen, die `rustup` benutzen soll, wenn du dich in diesem
Verzeichnis befindest:

```console
$ cd ~/projects/needs-nightly
$ rustup override set nightly
```

Jedes Mal, wenn du nun `rustc` oder `cargo` innerhalb von
_~/projects/needs-nightly_ aufrufst, stellt `rustup` sicher, dass du das
nächtliche Rust verwendest und nicht dein standardmäßiges, stabiles Rust. Das
ist praktisch, wenn du viele Rust-Projekte hast!

### Der RFC-Prozess und die Teams

Wie erfährst du also von diesen neuen Funktionalitäten? Das Entwicklungsmodell
von Rust folgt einem _Bitte-um-Kommentare-Prozess_ (Request For Comments, RFC). 
Wenn du eine Verbesserung von Rust wünschst, kannst du einen Vorschlag
schreiben, einen sogenannten RFC.

Jeder kann RFCs zur Verbesserung von Rust schreiben und die Vorschläge werden
vom Rust-Team, das aus vielen thematischen Unterteams besteht, geprüft und
diskutiert. Es gibt eine vollständige Liste der Teams auf der
[Rust-Website][rust-website], in der die Teams für jeden Projektbereich
aufgeführt sind: Sprachdesign, Compiler-Implementierung, Infrastruktur,
Dokumentation und weitere. Das zuständige Team liest den Vorschlag und die
Kommentare, schreibt einige eigene Kommentare und schließlich gibt es einen
Konsens, die Funktionalität anzunehmen oder abzulehnen.

Wenn die Funktionalität angenommen wird, wird ein Ticket (issue) in der
Rust-Versionsverwaltung eröffnet, und jemand kann es implementieren. Die
Person, die es sehr gut umsetzt, ist möglicherweise nicht die Person, die die
Funktionalität ursprünglich vorgeschlagen hat! Wenn die Implementierung fertig
ist, landet sie auf dem `master`-Zweig hinter einem Funktionalitäts-Schalter,
wie wir im Abschnitt [„Instabile
Funktionalitäten“](#instabile-funktionalitäten) besprochen haben.

Nach einiger Zeit, in der Rust-Entwickler die neue Funktionalität in den
nächtlichen Veröffentlichungen ausprobieren konnten, werden die Teammitglieder
die Ausarbeitung der Funktionalität im nächtlichen Zweig diskutieren und
entscheiden, ob sie ins stabile Rust kommen soll oder nicht. Wenn die
Entscheidung positiv ist, wird das Funktionalitätstor (feature gate) entfernt
und die Funktionalität gilt jetzt als stabil! Sie fährt mit den Zügen in eine
neue stabile Version von Rust.

[rust-website]: https://www.rust-lang.org/governance
