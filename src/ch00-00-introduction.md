# Einführung

Willkommen bei _Die Programmiersprache Rust_, einem einführenden Buch über
Rust. Die Programmiersprache Rust hilft dir, schnellere und zuverlässigere
Software zu schreiben. Ergonomie und systemnahe Kontrolle stehen beim Entwurf
von Programmiersprachen oft im Widerspruch &ndash; Rust stellt sich diesem
Konflikt. Durch den Ausgleich zwischen leistungsstarken, technischen
Möglichkeiten und einer großartigen Entwicklererfahrung bietet dir Rust die
Möglichkeit, Details systemnah (z.B. Speichernutzung) zu kontrollieren, ohne
den ganzen Ärger, der damit typischerweise einhergeht.

## Für wen Rust ist

Rust ist für viele Menschen aus einer Vielzahl von Gründen ideal. Schauen wir
uns einige der wichtigsten Nutzergruppen an.

### Entwicklerteams

Rust erweist sich als produktives Werkzeug in der Zusammenarbeit großer
Entwicklerteams mit unterschiedlichem Kenntnisstand in der
Systemprogrammierung. Systemnaher Code ist anfällig für eine Vielzahl subtiler
Fehler, die in den meisten anderen Sprachen nur durch ausgiebige Tests und
sorgfältige Überprüfung des Codes durch erfahrene Entwickler erkannt werden
können. In Rust spielt der Compiler eine Art Pförtnerrolle, indem er Code
mit diesen schwer fassbaren Fehlern verweigert zu kompilieren, darunter auch
Nebenläufigkeitsfehler. Mit der Arbeit an der Seite des Compilers kann sich
das Team auf die Programmlogik konzentrieren, anstatt Fehler zu suchen.

Rust bringt auch zeitgemäße Entwicklerwerkzeuge in die Welt der
Systemprogrammierung:

- Cargo, das mitgelieferte Abhängigkeitsmanagement- und Bau-Werkzeug, macht das
  Hinzufügen, Kompilieren und Verwalten von Abhängigkeiten im gesamten
  Rust-Ökosystem schmerzlos und konsistent.
- Das Formatierungstool `rustfmt` sorgt für einen einheitlichen Codierstil bei
  den Entwicklern.
- Der Rust-Sprachserver (Rust Language Server) ermöglicht Codevervollständigung
  und im Code angezeigte Fehlermeldungen innerhalb der Entwicklungsumgebung
  (IDE).

Durch den Einsatz dieser und anderer Werkzeuge des Rust-Ökosystems können
Entwickler produktiv arbeiten, während sie Code auf Systemebene schreiben.

### Studenten

Rust ist für Studenten und alle, die sich für Systemkonzepte interessieren. Mit
Rust haben viele Menschen etwas über Themen wie die Entwicklung von
Betriebssystemen gelernt. Die Gemeinschaft ist sehr einladend und beantwortet
gerne Fragen der Studenten. Durch Bemühungen wie dieses Buch will das Rust-Team
Systemkonzepte mehr Menschen zugänglich machen, insbesondere denen, die neu in
der Programmierung sind.

### Unternehmen

Hunderte von Unternehmen, große und kleine, setzen Rust für eine Vielzahl von
Aufgaben in der Produktion ein, dazu gehören Kommandozeilenwerkzeuge,
Webdienste, DevOps-Werkzeuge, eingebettete Geräte, Audio- und Videoanalyse und
-transkodierung, Kryptowährungen, Bioinformatik, Suchmaschinen, Anwendungen für
das Internet der Dinge, maschinelles Lernen und sogar wesentliche Teile des
Webbrowsers Firefox.

### Open-Source-Entwickler

Rust ist für Menschen, die die Programmiersprache Rust, die Gemeinschaft,
Entwickler-Werkzeuge und Bibliotheken aufbauen möchten. Wir würden uns freuen,
wenn du zur Programmiersprache Rust beiträgst.

### Menschen, die Geschwindigkeit und Stabilität schätzen

Rust ist für Menschen, die sich nach Geschwindigkeit und Stabilität einer
Sprache sehnen. Mit Geschwindigkeit meinen wir sowohl die Geschwindigkeit, mit
der Rust-Code ausgeführt werden kann, als auch die Geschwindigkeit, mit der du
mit Rust Programme schreiben kannst. Die Prüfungen des Rust-Compilers
gewährleisten Stabilität während du neue Funktionen hinzufügst und deinen Code
änderst. Dies steht im Gegensatz zu brüchigen Code-Altlasten in Sprachen ohne
diese Prüfungen, die Entwickler sich oft scheuen zu verändern. Durch das
Streben nach kostenneutralen Abstraktionen, also Funktionalität auf höherer
Ebene, die zu genauso schnellem Code wie manuell geschriebener Code auf
niedrigerer Ebene kompiliert, bemüht sich Rust, sicheren Code auch zu schnellem
Code zu machen.

Die Sprache Rust hofft, auch viele andere Nutzer zu unterstützen; die hier
genannten sind nur einige der größten Interessensgruppen. Insgesamt ist es
Rusts größtes Bestreben, den Zielkonflikt zu beseitigen, den Programmierer
jahrzehntelang hingenommen haben, wenn sie Sicherheit _und_ Produktivität bzw.
Geschwindigkeit _und_ Ergonomie erreichen wollten. Versuche es mit Rust und
finde heraus, ob dessen Möglichkeiten für dich geeignet sind.

## Für wen dieses Buch gedacht ist

In diesem Buch wird davon ausgegangen, dass du bereits Code in einer anderen
Programmiersprache geschrieben hast, es spielt aber keine Rolle in welcher. Wir
haben versucht, das Material einem breiten Publikum mit unterschiedlichem
Programmierhintergrund zugänglich zu machen. Wir verbringen nicht viel Zeit
damit, darüber zu sprechen, was Programmieren _ist_ oder wie man darüber denkt.
Wenn Programmieren für dich ganz neu ist, wäre es besser, wenn du ein Buch
speziell zur Einführung in die Programmierung liest.

## Wie man dieses Buch verwendet

Im Allgemeinen geht dieses Buch davon aus, dass du es der Reihe nach von vorne
nach hinten liest. Spätere Kapitel bauen auf den Konzepten früherer Kapitel
auf. Frühere Kapitel gehen möglicherweise nicht auf die Einzelheiten eines
Themas ein, denn in der Regel werden wir es in einem späteren Kapitel erneut
aufgreifen.

Du findest in diesem Buch zwei Kapitelarten: Konzeptkapitel und
Projektkapitel. In Konzeptkapiteln erfährst du etwas über einen Aspekt von
Rust. In Projektkapiteln schreiben wir gemeinsam kleine Programme und wenden
das bisher Gelernte an. Die Kapitel 2, 12 und 21 sind Projektkapitel; die
übrigen sind Konzeptkapitel.

**Kapitel 1** erklärt, wie man Rust installiert, wie man ein „Hallo
Welt“-Programm schreibt und wie man Cargo, den Paketmanager und das Bauwerkzeug
von Rust, benutzt. **Kapitel 2** ist eine praktische Einführung in die Sprache
Rust. Hier werden Konzepte auf hohem Niveau behandelt, spätere Kapitel werden
zusätzliche Einzelheiten liefern. Wenn du dir schon jetzt die Hände schmutzig
machen willst, dann ist Kapitel 2 der richtige Ort dafür. Wenn du ein besonders
akribischer Lerner bist, der es vorzieht, jedes Detail zu lernen, bevor er zum
nächsten übergeht, solltest du vielleicht Kapitel 2 überspringen und direkt zu
**Kapitel 3** übergehen, das Rust-Funktionen behandelt, die denen anderer
Programmiersprachen ähneln. Anschließend kannst du zu Kapitel 2 zurückkehren,
wenn du an einem Projekt arbeiten möchtest, bei dem du die gelernten Details
anwenden kannst.

In **Kapitel 4** lernst du den Eigentümerschaftsansatz von Rust kennen.
**Kapitel 5** bespricht Strukturen und Methoden, und **Kapitel 6** behandelt
Aufzählungen, `match`-Ausdrücke und die Kontrollflusskonstrukte `if let` und
`let...else`. Du wirst Strukturen und Aufzählungen verwenden, um
benutzerdefinierte Typen zu erstellen.

In **Kapitel 7** erfährst du mehr über das Modulsystem von Rust und über die
Datenschutzregeln zum Organisieren deines Codes und dessen öffentlich
zugängliche Programmierschnittstelle (API). In **Kapitel 8** werden einige
gängige Kollektionsdatenstrukturen, die die Standardbibliothek zur Verfügung
stellt, behandelt: Vektoren, Zeichenketten und Hashtabellen. **Kapitel 9**
befasst sich mit Rusts Philosophie und Techniken der Fehlerbehandlung.

**Kapitel 10** vertieft generische Datentypen, Merkmale und Lebensdauern, die
dir die Möglichkeit geben, Code zu schreiben, der für mehrere Typen passt. In
**Kapitel 11** dreht sich alles um das Testen, das selbst mit den
Sicherheitsgarantien von Rust erforderlich ist, um eine korrekte Logik deines
Programms sicherzustellen. In **Kapitel 12** werden wir unsere eigene
Implementierung für eine Teilfunktionalität des Kommandozeilenwerkzeugs `grep`
schreiben, das nach Text in Dateien sucht. Dazu werden wir viele Konzepte
anwenden, die wir in den vorangegangenen Kapiteln kennengelernt haben.

**Kapitel 13** befasst sich mit Funktionsabschlüssen und Iteratoren, also
Sprachmerkmalen, die von funktionalen Programmiersprachen stammen. In **Kapitel
14** werden wir einen genaueren Blick auf Cargo werfen und über bewährte
Vorgehensweisen beim Bereitstellen deiner Bibliotheken für andere sprechen. In
**Kapitel 15** werden intelligente Zeiger, die die Standardbibliothek
bereitstellt, und Merkmale, die ihre Funktionalität ermöglichen, erörtert.

In **Kapitel 16** gehen wir durch verschiedene Modelle der nebenläufigen
Programmierung und sprechen darüber, wie Rust dir hilft, furchtlos mit mehreren
Strängen zu programmieren. In **Kapitel 17** bauen wir darauf auf, indem wir
die async- und await-Syntax von Rust zusammen mit Aufgaben (tasks), Futures und
Strömen (streams) und dem leichtgewichtigen Nebenläufigkeitsmodell, das sie
ermöglichen, untersuchen.

**Kapitel 18** befasst sich mit dem Vergleich von Rust-Idiomen mit
objektorientierten Programmierprinzipien, mit denen du vielleicht vertraut
bist. **Kapitel 19** ist ein Nachschlagewerk zu Muster und Musterabgleich,
einem mächtigen Mittel zum Ausdrücken von Ideen in Rust-Programmen. **Kapitel
20** enthält ein Sammelsurium an interessanten fortgeschrittenen Themen,
darunter unsicheres Rust, Makros und mehr zu Lebensdauer, Merkmalen, Typen,
Funktionen und Funktionsabschlüssen.

In *Kapitel 21* werden wir ein Projekt abschließen, bei dem wir einen
systemnahen, nebenläufigen Webdienst implementieren!

Schließlich enthalten einige Anhänge nützliche Informationen über die Sprache
in einem eher referenzartigen Format. **Anhang A** enthält die Schlüsselwörter
von Rust, **Anhang B** die Operatoren und Symbole von Rust, **Anhang C**
ableitbare Merkmalen, die von der Standardbibliothek mitgebracht werden,
**Anhang D** nützliche Entwicklungswerkzeuge und **Anhang E** erläutert die
Rust-Editionen. In **Anhang F** findest du Übersetzungen des Buches, und in
**Anhang G* erfährst du, wie Rust erstellt wird und was nächtliches (nightly)
Rust ist.

Es gibt keinen falschen Weg, dieses Buch zu lesen: Wenn du was überspringen
willst, nur zu! Möglicherweise musst du zu früheren Kapiteln zurückkehren, wenn
du irritiert bist. Aber tue, was immer für dich passt.

<span id="ferris"></span>

Ein wichtiger Teil beim Lernen von Rust ist das Verstehen der Fehlermeldungen,
die der Compiler anzeigt: Diese leiten dich zum funktionierenden Code. Daher
werden wir viele Beispiele bringen, die nicht kompilieren, zusammen mit der
jeweiligen Fehlermeldung des Compilers. Wenn du also ein zufälliges Beispiel
eingibst und ausführen willst, lässt es sich möglicherweise nicht kompilieren!
Stelle sicher, dass du den umgebenden Text liest, um zu wissen, ob das
Beispiel, das du ausführen willst, einen Fehler zeigen soll. In den meisten
Fällen führen wir dich von einem Code, der nicht kompiliert, zur
funktionierenden Codeversion. Ferris gibt dir einen Hinweis bei Code, der nicht
funktionieren soll:

| Ferris     | Bedeutung                                    |
|------------|----------------------------------------------|
| <img src="img/ferris/does_not_compile.svg" class="ferris-explain" alt="Ferris mit Fragezeichen" /> | Dieser Code lässt sich nicht kompilieren! |
| <img src="img/ferris/panics.svg" class="ferris-explain" alt="Ferris reißt die Hände hoch" /> | Dieser Code bricht ab (panic)! |
| <img src="img/ferris/not_desired_behavior.svg" class="ferris-explain" alt="Ferris mit einer Kralle nach oben, achselzuckend" /> | Dieser Code liefert nicht das gewünschte Verhalten. |

In den meisten Situationen führen wir dich zu einer funktionierenden
Codeversion, wenn er sich nicht kompilieren lässt.

## Quellcode

Die Quelldateien, aus denen dieses Buch generiert wird, findest du unter
[GitHub][book-de].

[book-de]: https://github.com/rust-lang-de/rustbook-de/
