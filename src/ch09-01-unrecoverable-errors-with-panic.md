## Nicht behebbare Fehler mit `panic!`

Manchmal passieren schlimme Dinge in deinem Code und du kannst nichts dagegen
tun. Für diese Fälle hat Rust das Makro `panic!`. In der Praxis gibt es zwei
Möglichkeiten, ein Programm abstürzen zu lassen: Durch eine Aktion, die unseren
Code abstürzen lässt (z.B. Zugriff auf ein Array über das Ende hinaus) oder
durch den expliziten Aufruf des Makros `panic!`. In beiden Fällen brechen wir
unser Programm ab. Standardmäßig geben diese Programmabbrüche eine
Fehlermeldung aus, räumen den Stapelspeicher auf und beenden sich. Über eine
Umgebungsvariable kannst du auch festlegen, dass Rust den Stapelspeicher
anzeigt, wenn das Programm abbricht, damit du die Quelle des Abbruchs leichter
aufspüren kannst.

> ### Auflösen des Stapelspeichers oder Abbrechen als Fehlerreaktion
>
> Wenn ein Programmabbruch auftritt, beginnt das Programm standardmäßig mit dem
> *Abwickeln*, was bedeutet, dass Rust den Stapelspeicher wieder nach oben geht
> und die Daten von jeder Funktion, auf die es trifft, bereinigt. Allerdings
> ist dieses Zurückgehen und Aufräumen eine Menge Arbeit. Rust bietet dir als
> Alternative daher an, das Programm sofort *abzubrechen*, wobei das Programm
> beendet wird, ohne aufzuräumen.
>
> Der Speicher, den das Programm benutzt hat, muss dann vom Betriebssystem
> aufgeräumt werden. Wenn du in deinem Projekt die resultierende Binärdatei so
> klein wie möglich machen willst, kannst du für ein vorzeitiges Programmende
> vom Abwickeln zum sofortigen Abbrechen umschalten, indem du `panic = 'abort'`
> in den entsprechenden `[profile]`-Abschnitten in deiner *Cargo.toml*-Datei
> hinzufügst. Wenn du beispielsweise im Freigabemodus (release mode) im
> Fehlerfall sofort abbrechen möchtest, füge dies hinzu:
>
> ```toml
> [profile.release]
> panic = 'abort'
> ```

Versuchen wir `panic!` in einem einfachen Programm aufzurufen:

<span class="filename">Dateiname: src/main.rs</span>

```rust,should_panic,panics
fn main() {
    panic!("abstürzen und verbrennen");
}
```

Wenn du das Programm ausführst, wirst du in etwa das hier sehen:

```console
$ cargo run
   Compiling panic v0.1.0 (file:///projects/panic)
    Finished dev [unoptimized + debuginfo] target(s) in 0.25s
     Running `target/debug/panic`
thread 'main' panicked at src/main.rs:2:5:
abstürzen und verbrennen
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
```

Der Aufruf von `panic!` verursacht die in den letzten beiden Zeilen enthaltene
Fehlermeldung. Die erste Zeile zeigt unsere Fehlermeldung und die Position in
unserem Quellcode, an der der Fehler aufgetreten ist: *src/main.rs:2:5* gibt
an, dass es sich um die zweite Zeile und dem fünften Zeichen in unserer Datei
*src/main.rs* handelt.

In diesem Fall ist die angegebene Zeile Teil unseres Codes und wenn wir uns
diese Zeile ansehen, sehen wir den Makroaufruf `panic!`. In anderen Fällen
könnte der Aufruf von `panic!` in Code erfolgen, den unser Code aufruft, und
der Dateiname und die Zeilennummer in der Fehlermeldung gehören zu Code von
jemand anderen, der das Makro `panic!` aufruft, nicht zu unserem Code, der
schließlich zum Aufruf von `panic!` geführt hat. Wir können die Aufrufhistorie
(backtrace) der Funktionen, von der der `panic!`-Aufruf kam, nutzen, um den
Codeteil zu ermitteln, der das Problem verursacht. Wir werden Aufrufhistorien
im nächsten Abschnitt ausführlicher besprechen.

### Verwenden einer `panic!`-Aufrufhistorie

Sehen wir uns ein weiteres Beispiel an, bei dem der `panic!`-Aufruf von einer
Bibliothek kommt, weil wir einen Fehler in unserem Code haben, anstatt das
Makro direkt aufzurufen. Codeblock 9-1 enthält einen Code, der versucht, auf
einen Index in einem Vektor zuzugreifen, der außerhalb des Bereichs gültiger
Indizes liegt.

<span class="filename">Dateiname: src/main.rs</span>

```rust,should_panic,panics
fn main() {
    let v = vec![1, 2, 3];

    v[99];
}
```

<span class="caption">Codeblock 9-1: Versuch, auf ein Element jenseits des
Endes eines Vektors zuzugreifen, was einen Aufruf von `panic!` auslöst</span>

Hier versuchen wir, auf das 100. Element unseres Vektors zuzugreifen (das bei
Index 99 liegt, weil die Indexierung bei Null beginnt), der Vektor hat aber nur
3 Elemente. In dieser Situation wird Rust das Programm abbrechen. Das Verwenden
von `[]` soll ein Element zurückgeben, aber wenn du einen ungültigen Index
übergibst, gibt es kein Element, das Rust hier korrekterweise zurückgeben
könnte.

In C ist der Versuch, über das Ende einer Datenstruktur hinaus zu lesen, ein
undefiniertes Verhalten. Möglicherweise erhältst du den Wert im Speicher an der
der Datenstruktur entsprechenden Stelle, selbst wenn der Speicher nicht zu
dieser Struktur gehört. Dies wird als *Hinauslesen über den Puffer* (buffer
overread) bezeichnet und kann zu Sicherheitslücken führen, wenn ein Angreifer
in der Lage ist, den Index so zu manipulieren, dass er unerlaubterweise Daten
lesen kann, die nach der Datenstruktur gespeichert sind.

Um dein Programm vor dieser Art Verwundbarkeit zu schützen, wird Rust beim
Versuch, ein Element an einem Index zu lesen, der nicht existiert, die
Ausführung stoppen und die Fortsetzung verweigern. Versuchen wir es und sehen,
was passiert:

```console
$ cargo run
   Compiling panic v0.1.0 (file:///projects/panic)
    Finished dev [unoptimized + debuginfo] target(s) in 0.27s
     Running `target/debug/panic`
thread 'main' panicked at src/main.rs:4:6:
index out of bounds: the len is 3 but the index is 99
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
```

Dieser Fehler weist auf Zeile 4 in unserer `main.rs` hin, wo wir versuchen, auf
den Index 99 zuzugreifen. Die nächste Hinweiszeile sagt uns, dass wir die
Umgebungsvariable `RUST_BACKTRACE` setzen können, um einen Backtrace zu
erhalten, was genau passiert ist, das den Fehler verursacht hat. Ein
*Backtrace* ist eine Liste aller Funktionen, die aufgerufen wurden, um an
diesen Punkt zu gelangen. Backtraces in Rust funktionieren wie in anderen
Sprachen: Der Schlüssel zum Lesen des Backtraces ist, von oben zu beginnen und
zu lesen, bis du Dateien siehst, die du geschrieben hast. Das ist die Stelle,
an der das Problem entstanden ist. Die Zeilen darüber sind Code, den dein Code
aufgerufen hat; die Zeilen darunter sind Code, der deinen Code aufgerufen hat.
Diese Zeilen können Core-Rust-Code, Code der Standardbibliothek oder Kisten,
enthalten, die du verwendest. Versuchen wir, einen Backtrace zu erhalten, indem
wir die Umgebungsvariable `RUST_BACKTRACE` auf einen beliebigen Wert außer 0
setzen. Codeblock 9-2 zeigt eine ähnliche Ausgabe wie die, die du sehen wirst.

```console
$ RUST_BACKTRACE=1 cargo run
thread 'main' panicked at src/main.rs:4:6:
index out of bounds: the len is 3 but the index is 99
stack backtrace:
   0: rust_begin_unwind
             at /rustc/07dca489ac2d933c78d3c5158e3f43beefeb02ce/library/std/src/panicking.rs:645:5
   1: core::panicking::panic_fmt
             at /rustc/07dca489ac2d933c78d3c5158e3f43beefeb02ce/library/core/src/panicking.rs:72:14
   2: core::panicking::panic_bounds_check
             at /rustc/07dca489ac2d933c78d3c5158e3f43beefeb02ce/library/core/src/panicking.rs:208:5
   3: <usize as core::slice::index::SliceIndex<[T]>>::index
             at /rustc/07dca489ac2d933c78d3c5158e3f43beefeb02ce/library/core/src/slice/index.rs:255:10
   4: core::slice::index::<impl core::ops::index::Index<I> for [T]>::index
             at /rustc/07dca489ac2d933c78d3c5158e3f43beefeb02ce/library/core/src/slice/index.rs:18:9
   5: <alloc::vec::Vec<T,A> as core::ops::index::Index<I>>::index
             at /rustc/07dca489ac2d933c78d3c5158e3f43beefeb02ce/library/alloc/src/vec/mod.rs:2770:9
   6: panic::main
             at ./src/main.rs:4:6
   7: core::ops::function::FnOnce::call_once
             at /rustc/07dca489ac2d933c78d3c5158e3f43beefeb02ce/library/core/src/ops/function.rs:250:5
note: Some details are omitted, run with `RUST_BACKTRACE=full` for a verbose backtrace.
```

<span class="caption">Codeblock 9-2: Aufrufhistorie, erzeugt durch einen Aufruf
von `panic!`, wenn die Umgebungsvariable `RUST_BACKTRACE` gesetzt ist</span>

Das ist eine lange Ausgabe! Die genaue Ausgabe kann je nach Betriebssystem und
Rust-Version unterschiedlich sein. Um Aufrufhistorien mit diesen Informationen
zu erhalten, müssen Fehlersuchinfos (debug symbols) aktiviert sein.
Fehlersuchinfos sind standardmäßig aktiviert, wenn du `cargo build` oder
`cargo run` ohne Flag `--release` verwendest, wie wir es hier haben.

In der Ausgabe in Codeblock 9-2 zeigt Zeile 17 der Aufrufhistorie auf die Zeile
in unserem Projekt, die das Problem verursacht: Zeile 4 in *src/main.rs*. Wenn
wir nicht wollen, dass unser Programm abbricht, sollten wir bei der ersten
Zeile, die auf eine von uns geschriebenen Datei verweist, mit der Untersuchung
beginnen. In Codeblock 9-1, wo wir absichtlich Code geschrieben haben, der das
Programm abbricht, besteht die Möglichkeit das Problem zu beheben darin, kein
Element außerhalb des Bereichs der Vektorindizes anzufordern. Wenn dein Code in
Zukunft abbricht, musst du herausfinden, bei welcher Aktion der Code mit
welchen Werten abbricht und was der Code stattdessen tun sollte.

In Abschnitt [„Wann `panic!` verwenden und wann
nicht?“][to-panic-or-not-to-panic] später in diesem Kapitel kommen wir noch
einmal auf `panic!` zurück und wann wir `panic!` verwenden sollten und wann
nicht, um Fehlerfälle zu behandeln. Als Nächstes schauen wir uns an, wie man
Fehler mit `Result` abfangen kann.

[to-panic-or-not-to-panic]: ch09-03-to-panic-or-not-to-panic.html
