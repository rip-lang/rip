---
title: Overview
sidebar: { order: 1 }
---

A new programming language emphasizing developer ergonomics, consistency and correctness.

ChatGPT summarized Rip for the computer science nerds as follows:

> The language uses a locally inferred, constraint-based type system with parametric polymorphism implemented via monomorphization.

## Prior Art And Inspiration

- Ruby
- C#
- TypeScript/JavaScript
- Elixir
- Haskell
- Crystal
- React

## Notable Features

- robust type system with generics and algebraic data types
- compiles to LLVM IR, then to WASM and native code
- everything is an expression/value
- all values are immutable
- binary operators are actually syntax sugar for method invocation (`a + b` is the same as `a.+(b)`)
  - some operators exist, but there aren't many
  - binary "operators" must be surrounded by whitespace to distinguish them from identifiers
- literal syntax for range, date, time, datetime, sql, xml and more
