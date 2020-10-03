# Furchtlose Nebenläufigkeit

Der sichere und effiziente Umgang mit nebenläufiger Programmierung ist ein
weiteres wichtiges Ziel von Rust. Die *nebenläufige Programmierung* (concurrent
programming), bei der verschiedene Teile eines Programms unabhängig voneinander
ausgeführt werden, und die *parallele Programmierung* (parallel programming),
bei der verschiedene Teile eines Programms gleichzeitig ausgeführt werden,
werden immer wichtiger, da immer mehr Computer die Vorteile mehrerer
Prozessoren nutzen. In der Vergangenheit war die Programmierung in diesen
Bereichen schwierig und fehleranfällig: Rust hofft, das ändern zu können.

Ursprünglich dachte das Rust-Team, dass das Gewährleisten von
Speichersicherheit (memory safety) und das Verhindern von
Nebenläufigkeitsproblemen (concurrency problems) zwei separate
Herausforderungen seien, die mit unterschiedlichen Methoden gelöst werden
müssten. Im Laufe der Zeit entdeckte das Team, dass Eigentümerschaft
(ownership) und Typsysteme ein leistungsstarkes Instrumentarium zur Bewältigung
von Speichersicherheits- *und* Nebenläufigkeitsproblemen sind! Durch das Nutzen
der Eigentümerschaft und Typprüfung werden viele Nebenläufigkeitsfehler zu
Kompilierzeitfehlern in Rust anstatt Laufzeitfehlern. Anstatt dass du viel Zeit
damit verbringen musst, die genauen Umstände zu reproduzieren, unter denen ein
Laufzeit-Nebenläufigkeitsfehler auftritt, wird der fehlerhafte Code nicht
kompilieren und einen Fehler anzeigen, der das Problem erklärt. Dadurch kannst
du deinen Code reparieren, während du daran arbeitest, und nicht möglicherweise
erst, nachdem er in Produktion ausgeliefert wurde. Wir haben diesem Aspekt von
Rust den Spitznamen *furchtlose Nebenläufigkeit* (fearless concurrency)
gegeben. Die furchtlose Nebenläufigkeit ermöglicht es dir, Code zu schreiben,
der frei von subtilen Fehlern ist und leicht zu refaktorieren ist, ohne neue
Fehler zu erzeugen.

> Anmerkung: Der Einfachheit halber werden wir viele der Probleme als
> *nebenläufig* bezeichnen, anstatt präziser zu sein, indem wir *nebenläufig
> und/oder gleichzeitig* sagen. Wenn es in diesem Buch um Nebenläufigkeit
> und/oder Gleichzeitigkeit ginge, wären wir präziser. Bitte ersetze dieses
> Kapitel gedanklich durch *nebenläufig und/oder gleichzeitig*, wenn wir
> *nebenläufig* verwenden.

Viele Sprachen sind dogmatisch, was die Lösungen betrifft, die sie zur
Behandlung von Nebenläufigkeitsproblemen anbieten. Beispielsweise verfügt
Erlang über elegante Funktionen für die nachrichtenübermittelnde
Nebenläufigkeit, hat aber nur obskure Möglichkeiten, einen gemeinsamen Status
mit mehreren Strängen (threads) zu teilen. Die Unterstützung nur einer
Teilmenge möglicher Lösungen ist eine vernünftige Strategie für Hochsprachen,
da eine Hochsprache Vorteile verspricht, wenn sie eine gewisse Kontrolle
aufgibt, um Abstraktionen zu erhalten. Es wird jedoch erwartet, dass Sprachen
auf niedrigeren Ebenen in jeder Situation die Lösung mit der besten Performanz
bieten und weniger Abstraktionen der Hardware haben. Daher bietet Rust eine
Vielzahl von Werkzeugen zur Modellierung von Problemen in der Art und Weise,
die für deine Situation und deine Anforderungen geeignet ist.

Hier sind die Themen, die wir in diesem Kapitel behandeln werden:

* Wie man Stränge erstellt, um mehrere Code-Stücke gleichzeitig auszuführen.
* *Nachrichtenübermittelnde* Nebenläufigkeit, bei der Kanäle Nachrichten
  zwischen Strängen senden.
* Nebenläufigkeit mit *gemeinsamem Zustand*, bei der mehrere Stränge Zugriff
  auf bestimmte Daten haben.
* Die Merkmale (traits) `Sync` und `Send`, die Rusts Nebenläufigkeitsgarantien
  sowohl auf benutzerdefinierte Typen als auch auf von der Standardbibliothek
  bereitgestellte Typen erweitern.
