## Anhang E: Editionen

In Kapitel 1 hast du gesehen, dass `cargo new` Metadaten zur Edition
in deiner Datei _Cargo.toml_ hinzufügt. Dieser Anhang erläutert, was das
bedeutet!

Die Sprache Rust und der Compiler haben einen sechswöchigen
Veröffentlichungszyklus, was bedeutet, dass die Nutzer einen konstanten Strom
neuer Funktionen erhalten. Andere Programmiersprachen geben weniger oft größere
Änderungen heraus; Rust gibt häufiger kleinere Aktualisierungen heraus. Nach
einer Weile summieren sich all diese kleinen Änderungen. Aber von
Veröffentlichung zu Veröffentlichung kann es schwierig sein, zurückzublicken
und zu sagen: "Wow, zwischen Rust 1.10 und Rust 1.31 hat sich Rust sehr
verändert!

Etwa alle drei Jahre gibt das Rust-Team eine neue _Rust-Edition_
heraus. Jede Edition fasst die neuen Funktionalitäten in einem übersichtlichen
Paket mit vollständig aktualisierter Dokumentation und Werkzeugausstattung
zusammen. Neue Editionen werden im Rahmen des üblichen sechswöchigen
Freigabeprozesses ausgeliefert.

Editionen dienen unterschiedlichen Zwecken für verschiedene Menschen:

- Für aktive Rust-Nutzer fasst eine neue Edition inkrementelle Änderungen in
  einem leicht verständlichen Paket zusammen.
- Für Nicht-Nutzer signalisiert eine neue Edition, dass einige wichtige
  Fortschritte hinzugekommen sind, sodass sich ein erneuter Blick auf Rust
  lohnen könnte.
- Für diejenigen, die Rust entwickeln, stellt eine neue Edition einen
  Treffpunkt für das gesamte Projekt dar.

Zum Verfassungszeitpunkt dieses Artikels sind vier Rust-Editionen verfügbar:
Rust 2015, Rust 2018, Rust 2021 und Rust 2024. Dieses Buch wurde unter
Verwendung der Rust-Edition 2024 geschrieben.

Der Schlüssel `edition` in _Cargo.toml_ gibt an, welche Edition der Compiler
für deinen Code verwenden soll. Wenn der Schlüssel nicht existiert, verwendet
Rust aus Gründen der Abwärtskompatibilität die Edition `2015`.

Jedes Projekt kann sich für eine Edition abweichend von der Standard-Edition
2015 entscheiden. Editionen können inkompatible Änderungen enthalten, z.B. die
Aufnahme eines neuen Schlüsselworts, das mit Bezeichnern im Code in Konflikt
steht. Selbst wenn du dich nicht für diese Änderungen entscheidest, wird dein
Code weiterhin kompilieren, auch wenn du die verwendete
Rust-Compiler-Version aktualisierst.

Alle Rust-Compiler-Versionen unterstützen jede Edition, die vor der
Veröffentlichung dieses Compilers existierte, und es können Kisten (crates)
aller unterstützten Editionen miteinander verknüpft werden. Editionsänderungen
wirken sich nur auf die Art und Weise aus, wie der Compiler anfangs den Code
analysiert. Wenn du also Rust 2015 verwendest und eine deiner Abhängigkeiten
Rust 2018 verwendet, wird dein Projekt diese Abhängigkeit kompilieren und
nutzen können. Die umgekehrte Situation, in der dein Projekt Rust 2018
und eine Abhängigkeit Rust 2015 verwendet, funktioniert ebenfalls.

Um es klar zu sagen: Die meisten Funktionen werden in allen Editionen verfügbar
sein. Entwickler, die eine beliebige Rust-Edition verwenden, werden auch
weiterhin Verbesserungen sehen, wenn neue stabile Versionen erstellt werden. In
einigen Fällen, vor allem wenn neue Schlüsselwörter hinzugefügt werden, sind
einige neue Funktionalitäten jedoch möglicherweise erst in späteren Editionen
verfügbar. Du wirst die Edition wechseln müssen, wenn du die Vorteile solcher
Funktionalitäten nutzen möchtest.

Für weitere Einzelheiten schaue in den [*Editions-Leitfaden* (Edition
Guide)][edition-guide], einem vollständigen Buch über die Rust-Editionen, das
die Unterschiede zwischen den Editionen auflistet und erläutert, wie du deinen
Code automatisch per `cargo fix` auf eine neue Edition aktualisieren kannst.

[edition-guide]: https://doc.rust-lang.org/stable/edition-guide/
