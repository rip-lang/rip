---
title: If/Else
---

If the condition is true, the first block is executed and last value is returned. Otherwise the `else` block is. An `else` block is required except in the case of an early return where the compiler can determine the current scope is guaranteed to produce a value further down.

```rip
if (condition) {
  # consequence (condition is true)
} else {
  # alternative (condition is false)
}
```

Note that unlike many other languages, Rip doesn't support chaining `if` directly after `else`. Chained conditional logic can be expressed with `match`.

`if`/`else` blocks are expressions, so they may be assigned to a reference.

```rip
age-bracket = if (age >= 18) {
  :adult
} else {
  :child
}
```

## Condition Semantics

An `if` condition may be either:

1. A value expression
2. A pattern assignment (`pattern = value`)

### 1. Value Conditions

When a value expression is used, the condition is evaluated as follows:

- If the value has type `Boolean`, its value is used directly
- If the value is `nil`, the condition is `false`
- Otherwise, the condition is `true`

This means that `nil` is the only non-Boolean value treated as false.

Examples:

```rip
if (nil) {
  # not executed
}

if (false) {
  # not executed
}

if (true) {
  # executed
}

if (42) {
  # executed
}
```

This behavior is defined as part of `if` semantics and does not rely on implicit method calls or coercion.

### 2. Pattern Conditions

When using pattern assignment:

```rip
if (pattern = value) { ... }
```

The condition is `true` if the pattern matches and `false` otherwise.

If the pattern matches, any bound references are available inside the consequence block, and the value is narrowed according to the pattern.

Pattern conditions do not use value truthiness rules.

## Destructured Assignment Conditions

You can pattern match in the condition. Patterns and matching follows the same rules as `match`/`when` branches. Bound references are available inside the consequence block. If the pattern doesn't match, the alternative block (`else`) is executed. Inside the consequence block, the matched value is narrowed using the same intersection rules as in `match`.

See [match](/syntax/control-flow/match) for more information about pattern matching.

See [identifiers](/syntax/identifiers) for more information about destructured assignments.

```rip
if (pattern = value) {
  # value is matched by pattern. if pattern includes any bound references,
  # those are available here
} else {
  # value is not matched by pattern
}
```

Type references are valid type patterns in `match` and `if` constructs.
