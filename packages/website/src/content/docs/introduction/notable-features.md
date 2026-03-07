---
title: Notable Features
---

- robust type system with generics and algebraic data types
- compiles to LLVM IR, then to WASM and native code
- everything is an expression/value
- all values are immutable
- binary operators are actually syntax sugar for method invocation (`a + b` is the same as `a.+(_: b)`)
  - some operators exist, but there aren't many
  - binary "operators" must be surrounded by whitespace to distinguish them from identifiers (`a+b` is parsed as a single identifier)
- literal syntax for range, date, time, datetime, sql, xml and more
