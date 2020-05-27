## Nicht behebbare Fehler mit `panic!`

Manchmal passieren schlimme Dinge in deinem Code und du kannst nichts dagegen
tun. Für diese Fälle hat Rust das Makro `panic!`. Wenn das Makro `panic!`
ausgeführt wird, wird dein Programm eine Fehlermeldung ausgeben, den
Stapelspeicher abwickeln und aufräumen und sich dann beenden. Dies tritt am
häufigsten dann auf, wenn ein Fehler irgendeiner Art entdeckt wurde und dem
Programmierer nicht klar ist, wie er mit dem Fehler umgehen soll.

> ### Auflösen des Stapelspeichers oder Abbrechen als Fehlerreaktion
>
> Wenn ein Programmabbruch auftritt, beginnt das Programm standardmäßig mit dem
> *Abwickeln*, was bedeutet, dass Rust den Stapelspeicher wieder nach oben geht
> und die Daten von jeder Funktion, auf die es trifft, bereinigt. Aber dieses
> Zurückgehen und Aufräumen ist eine Menge Arbeit. Die Alternative ist der
> sofortige *Abbruch* (abort), der das Programm ohne aufzuräumen beendet. Der
> Speicher, den das Programm benutzt hat, muss dann vom Betriebssystem
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

```text
$ cargo run
   Compiling panic v0.1.0 (file:///projects/panic)
    Finished dev [unoptimized + debuginfo] target(s) in 0.25s
     Running `target/debug/panic`
thread 'main' panicked at 'abstürzen und verbrennen', src/main.rs:2:5
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace.
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
Codeteil zu ermitteln, der das Problem verursacht. Im Folgenden sehen wir uns
genauer an, was eine Aufrufhistorie ist.

### Verwenden einer `panic!`-Aufrufhistorie

Sehen wir uns ein weiteres Beispiel an, bei dem der `panic!`-Aufruf von einer
Bibliothek kommt, weil wir einen Fehler in unserem Code haben, anstatt das
Makro direkt aufzurufen. Codeblock 9-1 enthält einen Code, der versucht, auf
ein Element per Index in einem Vektor zuzugreifen.

<span class="filename">Dateiname: src/main.rs</span>

```rust,should_panic,panics
fn main() {
    let v = vec![1, 2, 3];

    v[99];
}
```

<span class="caption">Codeblock 9-1: Versuch, auf ein Element jenseits des
Endes eines Vektors zuzugreifen, was einen Aufruf von `panic!` auslöst</span>

Hier versuchen wir, auf das 100. Element unseres Vektors zuzugreifen (das bei Index 99
liegt, weil die Indexierung bei Null beginnt), der aber nur 3 Elemente hat. In dieser
Situation wird Rust das Programm abbrechen. Das Verwenden von `[]` soll ein Element
zurückgeben, aber wenn du einen ungültigen Index übergibst, gibt es kein Element, das
Rust hier korrekterweise zurückgeben könnte.

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

```text
$ cargo run
   Compiling panic v0.1.0 (file:///projects/panic)
    Finished dev [unoptimized + debuginfo] target(s) in 0.27s
     Running `target/debug/panic`
thread 'main' panicked at 'index out of bounds: the len is 3 but the index is 99', /rustc/5e1a799842ba6ed4a57e91f7ab9435947482f7d8/src/libcore/slice/mod.rs:2806:10
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace.
```

Dieser Fehler weist auf eine Datei hin, die wir nicht geschrieben haben:
*libcore/slice/mod.rs*. Das ist die Implementierung von `slice` im
Rust-Quellcode. Der Code, der ausgeführt wird, wenn wir `[]` auf unserem Vektor
`v` anwenden, befindet sich in *libcore/slice/mod.rs*, und das ist der Ort, an
dem `panic!` tatsächlich aufgerufen wird.

Die nächste Hinweiszeile sagt uns, dass wir die Umgebungsvariable
`RUST_BACKTRACE` setzen können, um eine Aufrufhistorie zur Fehlerursache zu
erhalten. Eine *Aufrufhistorie* ist eine Liste aller Funktionen, die aufgerufen
wurden, um an diesen Punkt zu gelangen. Aufrufhistorien in Rust funktionieren
wie in anderen Sprachen: Der Schlüssel zum Lesen der Aufrufhistorie liegt
darin, diese von oben beginnend zu lesen, bis du von dir geschriebene Dateien
siehst. Das ist die Stelle, an der das Problem entstanden ist. Die Zeilen
darüber sind Code, den dein Code aufgerufen hat; die Zeilen darunter sind Code,
der deinen Code aufgerufen hat. Diese Zeilen können Kern-Rust-Code,
Standard-Bibliothekscode oder Kisten (crates), die du verwendest, sein. Lass
uns versuchen, eine Aufrufhistorie zu erhalten, indem wir die Umgebungsvariable
`RUST_BACKTRACE` auf einen beliebigen Wert außer 0 setzen. Codeblock 9-2 zeigt
eine Ausgabe, wie du sie in etwa sehen wirst.

```text
$ RUST_BACKTRACE=1 cargo run
thread 'main' panicked at 'index out of bounds: the len is 3 but the index is 99', /rustc/5e1a799842ba6ed4a57e91f7ab9435947482f7d8/src/libcore/slice/mod.rs:2806:10
stack backtrace:
   0: backtrace::backtrace::libunwind::trace
             at /Users/runner/.cargo/registry/src/github.com-1ecc6299db9ec823/backtrace-0.3.40/src/backtrace/libunwind.rs:88
   1: backtrace::backtrace::trace_unsynchronized
             at /Users/runner/.cargo/registry/src/github.com-1ecc6299db9ec823/backtrace-0.3.40/src/backtrace/mod.rs:66
   2: std::sys_common::backtrace::_print_fmt
             at src/libstd/sys_common/backtrace.rs:84
   3: <std::sys_common::backtrace::_print::DisplayBacktrace as core::fmt::Display>::fmt
             at src/libstd/sys_common/backtrace.rs:61
   4: core::fmt::ArgumentV1::show_usize
   5: std::io::Write::write_fmt
             at src/libstd/io/mod.rs:1426
   6: std::sys_common::backtrace::_print
             at src/libstd/sys_common/backtrace.rs:65
   7: std::sys_common::backtrace::print
             at src/libstd/sys_common/backtrace.rs:50
   8: std::panicking::default_hook::{{closure}}
             at src/libstd/panicking.rs:193
   9: std::panicking::default_hook
             at src/libstd/panicking.rs:210
  10: std::panicking::rust_panic_with_hook
             at src/libstd/panicking.rs:471
  11: rust_begin_unwind
             at src/libstd/panicking.rs:375
  12: core::panicking::panic_fmt
             at src/libcore/panicking.rs:84
  13: core::panicking::panic_bounds_check
             at src/libcore/panicking.rs:62
  14: <usize as core::slice::SliceIndex<[T]>>::index
             at /rustc/5e1a799842ba6ed4a57e91f7ab9435947482f7d8/src/libcore/slice/mod.rs:2806
  15: core::slice::<impl core::ops::index::Index<I> for [T]>::index
             at /rustc/5e1a799842ba6ed4a57e91f7ab9435947482f7d8/src/libcore/slice/mod.rs:2657
  16: <alloc::vec::Vec<T> as core::ops::index::Index<I>>::index
             at /rustc/5e1a799842ba6ed4a57e91f7ab9435947482f7d8/src/liballoc/vec.rs:1871
  17: panic::main
             at src/main.rs:4
  18: std::rt::lang_start::{{closure}}
             at /rustc/5e1a799842ba6ed4a57e91f7ab9435947482f7d8/src/libstd/rt.rs:67
  19: std::rt::lang_start_internal::{{closure}}
             at src/libstd/rt.rs:52
  20: std::panicking::try::do_call
             at src/libstd/panicking.rs:292
  21: __rust_maybe_catch_panic
             at src/libpanic_unwind/lib.rs:78
  22: std::panicking::try
             at src/libstd/panicking.rs:270
  23: std::panic::catch_unwind
             at src/libstd/panic.rs:394
  24: std::rt::lang_start_internal
             at src/libstd/rt.rs:51
  25: std::rt::lang_start
             at /rustc/5e1a799842ba6ed4a57e91f7ab9435947482f7d8/src/libstd/rt.rs:67
  26: panic::main
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
Programm abbricht, um zu demonstrieren, wie man Aufrufhistorien liest, lässt
sich der Abbruch beheben, indem kein Element mit Index 99 von einem Vektor mit
nur 3 Elementen gelesen wird. Wenn dein Code in Zukunft abbricht, musst du
herausfinden, bei welcher Aktion der Code mit welchen Werten abbricht und was
der Code stattdessen tun sollte.

In Abschnitt [„Wann `panic!` verwenden und wann
nicht?“][to-panic-or-not-to-panic] später in diesem Kapitel kommen wir noch
einmal auf `panic!` zurück und wann wir `panic!` verwenden sollten und wann
nicht, um Fehlerfälle zu behandeln. Als Nächstes schauen wir uns an, wie man
sich mit `Result` von einem Fehler erholt.

[to-panic-or-not-to-panic]:
ch09-03-to-panic-or-not-to-panic.html#to-panic-or-not-to-panic
