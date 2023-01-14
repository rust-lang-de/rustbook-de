## Bauvorgang anpassen mit Freigabeprofilen (release profiles)

In Rust sind *Freigabeprofile* vordefinierte, anpassbare Profile mit
unterschiedlichen Konfigurationen, durch die ein Programmierer mehr Kontrolle
über verschiedene Optionen zum Kompilieren von Programmcode hat. Jedes Profil
wird von den anderen unabhängig konfiguriert.

Cargo hat zwei Hauptprofile: Das Profil `dev`, das von Cargo verwendet wird, wenn
du `cargo build` ausführst, und das Profil `release`, das Cargo verwendet, wenn
`cargo build --release` ausgeführt wird. `dev` ist mit guten
Standardeinstellungen für die Entwicklung (development) definiert und `release`
hat gute Standardeinstellungen für Releasebuilds. [^1]

Profilnamen die dir möglicherweise aus der Ausgabe beim Bauvorgang bekannt sind:

```console
$ cargo build
    Finished dev [unoptimized + debuginfo] target(s) in 0.0s
$ cargo build --release
    Finished release [optimized] target(s) in 0.0s
```

Die Angaben `dev` und `release` sind diese verschiedenen Profile, die vom
Compiler verwendet werden.

Cargo hat Standardeinstellungen für jedes der Profile, die verwendet werden,
wenn du keine expliziten Abschnitte `[profile.*]` in der Datei *Cargo.toml* des
Projekts hast. Durch Hinzufügen eines Abschnitts `[profile.*]` für Profile, die
du anpassen möchtest, überschreibst du Teile der Standardeinstellungen. Hier
sind zum Beispiel die Standardwerte für die Einstellung `opt-level` der Profile
`dev` und `release`:

<span class="filename">Dateiname: Cargo.toml</span>

```toml
[profile.dev]
opt-level = 0

[profile.release]
opt-level = 3
```

Die Einstellung `opt-level` steuert die Anzahl der Optimierungen, die Rust auf
den Programmcode anwendet, in einem Bereich 0 bis 3. Das Anwenden zusätzlicher
Optimierungen verlängert die Kompilierzeit. Wenn man in der Entwicklung häufig
den Programmcode kompiliert, wünscht man zumeist weniger Optimierungen, um
schneller zu kompilieren, auch wenn dadurch der resultierende Programmcode
langsamer ausgeführt wird. Das Standard-`opt-level` für `dev` ist daher `0`.
Wenn du bereit bist, deinen Programmcode zu veröffentlichen, ist es besser,
wenn das Kompilieren mehr Zeit benötigt, man wird nur einmal im Releasemodus
kompilieren, aber das Programm oft ausführen, daher tauscht der Releasemodus
eine längere Kompilierzeit gegen Programmcode, der schneller ausgeführt wird.
Aus diesem Grund ist das standardmäßige `opt-level` für das Profil `release`
`3`.

Du kannst eine Standardeinstellung überschreiben, indem du dafür in
*Cargo.toml* einen anderen Wert hinzufügst. Wenn wir zum Beispiel die
Optimierungsstufe 1 im Entwicklungsprofil verwenden möchten, können wir diese
beiden Zeilen in die Datei *Cargo.toml* unseres Projekts hinzufügen:

<span class="filename">Dateiname: Cargo.toml</span>

```toml
[profile.dev]
opt-level = 1
```

Dieser Code überschreibt die Standardeinstellung von `0`. Wenn wir nun `cargo
build` ausführen, verwendet Cargo die Standardeinstellung für das Profil `dev`
sowie unsere Anpassung `1` für `opt-level`. Cargo wird mehr Optimierungen
vornehmen als mit Standardeinstellungen, aber weniger als bei einem
Releasebuild.

Eine vollständige Liste der Konfigurationsoptionen und Standardeinstellungen für
jedes Profil findest du in [Cargos Dokumentation][cargo1].

[^1]: **Release**: Veröffentlichung, **Build**: Kompilierter Quelltext

[cargo1]: https://doc.rust-lang.org/cargo/reference/profiles.html
