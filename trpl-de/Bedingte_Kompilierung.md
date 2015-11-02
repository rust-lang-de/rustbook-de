% Bedingte Kompilierung

Rust hat ein spezielles Attribut, `#[cfg]`,
welches es uns erlaubt Code nur dann kompilieren zu lassen wenn ein bestimmtes Flag an den Compiler übergeben wird. Davon gibt es zwei Formen:

```rust
#[cfg(foo)]
# fn foo() {}

#[cfg(bar = "baz")]
# fn bar() {}
```

Dann gibt es noch Zusätze wie `any()`, `all()` oder `not()`:

```rust
#[cfg(any(unix, windows))]
# fn foo() {}

#[cfg(all(unix, target_pointer_width = "32"))]
# fn bar() {}

#[cfg(not(foo))]
# fn not_foo() {}
```

Und diese können wiederum beliebig geschachtelt werden:

```rust
#[cfg(any(not(unix), all(target_os="macos", target_arch = "powerpc")))]
# fn foo() {}
```

Um diese Schalter an und auszuschalten, benutzt du in deiner `Cargo.toml` die [`[features]` Sektion][features] (englisch):

[features]: http://doc.crates.io/manifest.html#the-%5Bfeatures%5D-section

```toml
[features]
# no features by default
default = []

# The “secure-password” feature depends on the bcrypt package.
secure-password = ["bcrypt"]
```

Wenn das passiert ist übergibt Cargo die Flags auf diese Weise an `rustc`:

```text
--cfg feature="${feature_name}"
```

Die Summe dieser `cfg` Flags bestimmt welche aktiviert und damit kompiliert werden.
Hier am Beispiel:


```rust
#[cfg(feature = "foo")]
mod foo {
}
```

Wenn wir jetzt mit `cargo build --features "foo"` kompilieren,
wird das Flag `--cfg feature="foo"` an `rustc` gesendet und das Ergebnis wird `mod foo` enthalten.
Wenn wir allerdings normal mit `cargo build` kompiliren, ohne extra Flags, gibt es kein `foo`.

# cfg_attr

Man kann auch andere Attribute basierend auf `cfg` Variablen mit `cfg_attr` setzen:

```rust
#[cfg_attr(a, b)]
# fn foo() {}
```

Das ist das selbe wie `#[b]` wenn `a` vom `cfg` Attribut gesetzt ist.
Sonst nichts.


# cfg!

Das `cfg!` Macro ist eine [Syntax Erweiterung](Compiler_Plugins.md) die dich diese Flags an beliebigen Stellen im Code verwenden lässt:


```rust
if cfg!(target_os = "macos") || cfg!(target_os = "ios") {
    println!("Think Different!");
}
```

Das wird zur beim Kompilieren durch `true` oder `false` ersetzt,
je nach Konfiguration.

