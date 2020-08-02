## Anhang E - Ausgaben

In Kapitel 1 hast du gesehen, dass `cargo new` Metadaten zur Ausgabe (edition)
in deiner Datei *Cargo.toml* hinzufügt. Dieser Anhang erläutert, was das
bedeutet!

Die Sprache Rust und der Compiler haben einen sechswöchigen
Veröffentlichungs-Zyklus, was bedeutet, dass die Nutzer einen konstanten Strom
neuer Funktionen erhalten. Andere Programmiersprachen geben weniger oft größere
Änderungen heraus; Rust gibt häufiger kleinere Aktualisierungen heraus. Nach
einer Weile summieren sich all diese kleinen Änderungen. Aber von
Veröffentlichung zu Veröffentlichung kann es schwierig sein, zurückzublicken
und zu sagen: "Wow, zwischen Rust 1.10 und Rust 1.31 hat sich Rust sehr
verändert!

Alle zwei oder drei Jahre gibt das Rust-Team eine neue *Rust-Ausgabe* (edition)
heraus. Jede Ausgabe fasst die neuen Funktionalitäten in einem übersichtlichen
Paket mit vollständig aktualisierter Dokumentation und Werkzeugausstattung
zusammen. Neue Ausgaben werden im Rahmen des üblichen sechswöchigen
Freigabeprozesses ausgeliefert.

Ausgaben dienen unterschiedlichen Zwecken für verschiedene Menschen:

* Für aktive Rust-Nutzer fasst eine neue Ausgabe inkrementelle Änderungen in
  einem leicht verständlichen Paket zusammen.
* Für Nicht-Nutzer signalisiert eine neue Ausgabe, dass einige wichtige
  Fortschritte hinzugekommen sind, sodass sich ein erneuter Blick auf Rust
  lohnen könnte.
* Für diejenigen, die Rust entwickeln, stellt eine neue Ausgabe einen
  Treffpunkt für das gesamte Projekt dar.

Zum Verfassungszeitpunkt dieses Artikels sind zwei Rust-Ausgaben verfügbar:
Rust 2015 und Rust 2018. Dieses Buch wurde unter Verwendung der Rust-Ausgabe
2018 geschrieben.

Der Schlüssel `edition` in *Cargo.toml* gibt an, welche Ausgabe der Compiler
für deinen Code verwenden soll. Wenn der Schlüssel nicht existiert, verwendet
Rust aus Gründen der Abwärtskompatibilität die Edition `2015`.

Jedes Projekt kann sich für eine Ausgabe abweichend von der Standardausgabe
2015 entscheiden. Ausgaben können inkompatible Änderungen enthalten, z.B. die
Aufnahme eines neuen Schlüsselworts, das mit Bezeichnern im Code in Konflikt
steht. Selbst wenn du dich nicht für diese Änderungen entscheidest, wird dein
Code weiterhin kompilieren, auch wenn du die verwendete
Rust-Compiler-Version aktualisierst.

Alle Rust-Compiler-Versionen unterstützen jede Ausgabe, die vor der
Veröffentlichung dieses Compilers existierte, und es können Kisten (crates)
aller unterstützten Ausgaben miteinander verknüpft werden. Ausgabenänderungen
wirken sich nur auf die Art und Weise aus, wie der Compiler anfangs den Code
analysiert. Wenn du also Rust 2015 verwendest und eine deiner Abhängigkeiten
Rust 2018 verwendet, wird dein Projekt diese Abhängigkeit kompilieren und
nutzen können. Die umgekehrte Situation, in der dein Projekt Rust 2018
und eine Abhängigkeit Rust 2015 verwendet, funktioniert ebenfalls.

Um es klar zu sagen: Die meisten Funktionen werden in allen Ausgaben verfügbar
sein. Entwickler, die eine beliebige Rust-Ausgabe verwenden, werden auch
weiterhin Verbesserungen sehen, wenn neue stabile Versionen erstellt werden. In
einigen Fällen, vor allem wenn neue Schlüsselwörter hinzugefügt werden, sind
einige neue Funktionalitäten jedoch möglicherweise erst in späteren Ausgaben
verfügbar. Du wirst die Ausgabe wechseln müssen, wenn du die Vorteile solcher
Funktionalitäten nutzen möchtest.

Für weitere Einzelheiten schaue in den [*Ausgabe-Leitfaden* (Edition
Guide)][edition-guide], einem vollständigen Buch über Ausgaben, das die
Unterschiede zwischen den Ausgaben aufzählt und erklärt, wie du deinen Code
automatisch per `cargo fix` auf eine neue Ausgabe aktualisieren kannst.

[edition-guide]: https://doc.rust-lang.org/stable/edition-guide/
