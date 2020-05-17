# Eigentümerschaft (ownership) verstehen

Eigentümerschaft (ownership) ist das wichtigste Alleinstellungsmerkmal von
Rust, und sie ermöglicht es Rust, Speichersicherheitsgarantien ohne Einsatz
einer automatischen Speicherbereinigung (garbage collector) zu geben. Deshalb
ist es wichtig zu verstehen, wie Eigentümerschaft in Rust funktioniert. In
diesem Kapitel werden wir uns neben der Eigentümerschaft weitere diesbezügliche
Funktionalitäten ansehen: Ausleihen (borrowing), Anteilstypen (slices) und wie
Rust Daten im Speicher anordnet.
