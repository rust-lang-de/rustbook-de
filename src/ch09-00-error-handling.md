# Fehlerbehandlung

Fehler sind Gegebenheiten in Software, deshalb enthält Rust eine Reihe von
Funktionalitäten zur Behandlung von Situationen, in denen etwas schiefgeht. In
vielen Fällen verlangt Rust von dir, dass du die Möglichkeit eines Fehlers
anerkennst und Vorkehrungen ergreifst, damit dein Code kompiliert werden kann.
Diese Anforderung macht dein Programm robuster, da sichergestellt wird, dass du
Fehler entdeckst und diese angemessen behandelst, bevor dein Code in Produktion
gebracht wird!

Rust gruppiert Fehler in zwei Hauptkategorien: *Behebbare* (recoverable) und
*nicht behebbare* (unrecoverable) Fehler. Bei einem behebbaren Fehler, z.B.
„Datei nicht gefunden“, wollen wir das Problem wahrscheinlich dem Benutzer
melden und den Vorgang erneut versuchen. Nicht behebbare Fehler sind immer
Symptome von Programmierfehlern, z.B. der Versuch, auf eine Stelle hinter dem
Ende eines Arrays zuzugreifen, und deshalb wollen wir das Programm sofort
anhalten.

Die meisten Sprachen unterscheiden nicht zwischen diesen beiden Fehlerarten und
behandeln beide auf die gleiche Weise, indem sie Mechanismen wie die
Ausnahmebehandlung verwenden. Rust hat keine Ausnahmebehandlung. Stattdessen
hat es den Typ `Result<T, E>` für behebbare Fehler und das Makro `panic!`, das
die Ausführung stoppt, wenn das Programm auf einen nicht behebbaren Fehler
stößt. Dieses Kapitel behandelt zuerst das Aufrufen von `panic!` und spricht
dann über die Rückgabe von `Result<T, E>`-Werten. Darüber hinaus werden wir
Überlegungen anstellen, wann wir besser versuchen sollten, uns von einem Fehler
zu erholen, und wann die Ausführung zu stoppen.
