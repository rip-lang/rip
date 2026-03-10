---
title: Hash
sidebar: { order: 5 }
---

A hash is a collection of key-value pairs surround by curly braces, and separated by a comma. Keys are strings, typically written with symbol syntax. Values can be any expression. Keys and values are separated by a colon.

```rip
{ :answer: 42, "another key": :hello }
```

## Syntax

Hash literal syntax requires keys be literal string expressions. Strings must be static and may not use interpolation. "Symbol" strings are commonly used as keys in source code.

```rip
{ "fruit": "banana", :color: "yellow" }
```

If a dynamic key is needed, including a string with interpolation, the key must be wrapped with square braces (`[`/`]`). The expression inside the square braces must evaluate to a `String`.

```rip
dynamic-key: "foo"
{ [dynamic-key]: :whatever }
```

Hashes allow any type of expression to be written as values in literal syntax. The type of a hash is written as `Hash<T>`, where `T` is a union of the types of all values in the hash.
