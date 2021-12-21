# Eigentümerschaft (ownership) verstehen

Eigentümerschaft (ownership) ist das wichtigste Alleinstellungsmerkmal von
Rust und hat tiefgreifende Auswirkungen auf den Rest der Sprache. Sie
ermöglicht es Rust, Speichersicherheitsgarantien ohne Einsatz
einer automatischen Speicherbereinigung (garbage collector) zu geben, deshalb
ist es wichtig zu verstehen, wie Eigentümerschaft in Rust funktioniert. In
diesem Kapitel werden wir uns neben der Eigentümerschaft weitere diesbezügliche
Funktionalitäten ansehen: Ausleihen (borrowing), Anteilstypen (slices) und wie
Rust Daten im Speicher anordnet.
