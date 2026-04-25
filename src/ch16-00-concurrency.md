# Furchtlose Nebenläufigkeit

Der sichere und effiziente Umgang mit nebenläufiger Programmierung ist ein
weiteres wichtiges Ziel von Rust. Die _nebenläufige Programmierung_ (concurrent
programming), bei der verschiedene Teile eines Programms unabhängig voneinander
ausgeführt werden, und die _parallele Programmierung_ (parallel programming),
bei der verschiedene Teile eines Programms gleichzeitig ausgeführt werden,
werden immer wichtiger, da immer mehr Computer die Vorteile mehrerer
Prozessoren nutzen. In der Vergangenheit war die Programmierung in diesen
Bereichen schwierig und fehleranfällig: Rust hofft, das ändern zu können.

Ursprünglich dachte das Rust-Team, dass das Gewährleisten von Speichersicherheit
(memory safety) und das Verhindern von Nebenläufigkeitsproblemen (concurrency
problems) zwei separate Herausforderungen seien, die mit unterschiedlichen
Methoden gelöst werden müssten. Im Laufe der Zeit entdeckte das Team, dass
Eigentümerschaft (ownership) und Typsysteme ein leistungsstarkes Instrumentarium
zur Bewältigung von Speichersicherheits- _und_ Nebenläufigkeitsproblemen sind!
Durch das Nutzen der Eigentümerschaft und Typprüfung werden viele
Nebenläufigkeitsfehler zu Kompilierzeitfehlern in Rust anstatt Laufzeitfehlern.
Anstatt dass du viel Zeit damit verbringen musst, die genauen Umstände zu
reproduzieren, unter denen ein Laufzeit-Nebenläufigkeitsfehler auftritt, wird
der fehlerhafte Code nicht kompilieren und einen Fehler anzeigen, der das
Problem erklärt. Dadurch kannst du deinen Code reparieren, während du daran
arbeitest, und nicht möglicherweise erst, nachdem er in Produktion ausgeliefert
wurde. Wir haben diesem Aspekt von Rust den Spitznamen _furchtlose
Nebenläufigkeit_ (fearless concurrency) gegeben. Die furchtlose Nebenläufigkeit
ermöglicht es dir, Code zu schreiben, der frei von subtilen Fehlern und mittels
Refactoring leicht zu ändern ist, ohne neue Fehler zu erzeugen.

> Anmerkung: Der Einfachheit halber werden wir viele der Probleme als
> _nebenläufig_ bezeichnen, anstatt präziser zu sein, indem wir _nebenläufig
> und/oder gleichzeitig_ sagen. Wenn es in diesem Buch um Nebenläufigkeit
> und/oder Gleichzeitigkeit ginge, wären wir präziser. Bitte ersetze dieses
> Kapitel gedanklich durch _nebenläufig und/oder gleichzeitig_, wenn wir
> _nebenläufig_ verwenden.

Viele Sprachen sind dogmatisch, was die Lösungen betrifft, die sie zur
Behandlung von Nebenläufigkeitsproblemen anbieten. Beispielsweise verfügt Erlang
über elegante Funktionen für die Nebenläufigkeit mit Nachrichtenaustausch
(message-passing concurrency), hat aber nur obskure Möglichkeiten, einen
gemeinsamen Status mit mehreren Threads zu teilen. Die Unterstützung nur einer
Teilmenge möglicher Lösungen ist eine vernünftige Strategie für Hochsprachen, da
eine Hochsprache Vorteile verspricht, wenn sie auf einen Teil der Kontrolle
verzichtet, um Abstraktionen zu erhalten. Es wird jedoch erwartet, dass Sprachen
auf niedrigeren Ebenen in jeder Situation die Lösung mit der besten Performanz
bieten und weniger Abstraktionen der Hardware haben. Daher bietet Rust eine
Vielzahl von Werkzeugen zur Modellierung von Problemen in der Art und Weise, die
für deine Situation und deine Anforderungen geeignet ist.

Hier sind die Themen, die wir in diesem Kapitel behandeln werden:

- Wie man Threads erstellt, um mehrere Code-Abschnitte gleichzeitig auszuführen.
- _Nachrichtenübermittelnde_ Nebenläufigkeit, bei der Kanäle Nachrichten
  zwischen Threads senden.
- Nebenläufigkeit mit _gemeinsamem Zustand_ (shared-state), bei der mehrere
  Threads Zugriff auf bestimmte Daten haben.
- Die Traits `Sync` und `Send`, die Rusts Nebenläufigkeitsgarantien sowohl auf
  benutzerdefinierte Typen als auch auf von der Standardbibliothek
  bereitgestellte Typen erweitern.
