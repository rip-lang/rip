# Match

## 1. Overview

A `match` block expression performs ordered pattern matching on a value. The type of a `match` expression is the normalized union of all branch result types.

The `expression` is examined and potentially destructured according to each branch's `pattern` (`when` block). Patterns are matched top to bottom; the first matching `when` block is executed and the value is returned for the entire `match` block.

```rip
match (expression) {
  when (pattern1) { ... }
  when (pattern2) { ... }
  else { ... }
}
```

Since _everything_ in Rip **must** evaluate to a value, it is a compile-time error if a `match` expression is not exhaustive and no `else` branch is provided.

---

## 2. Pattern Forms

Patterns in `when` clauses may be:

- Literal values
- Reference bindings
- List patterns
- Hash patterns
- Structure patterns
- Type patterns
- Intersections of patterns
- Alternate patterns (comma-separated)

---

### 2.1. Literal Patterns

The simplest pattern is a literal value (or a reference). If all patterns are literals, `match` behaves similarly to a traditional `switch` statement.

Literal patterns participate in type narrowing through structural equality.

```rip
match (value) {
  # Rational
  when (42) { }

  # String
  when (:answer) { }

  # List
  when ([]) { }

  # Hash
  when ({}) { }
}
```

See equality.md for how equality is calculated.

---

### 2.2. Reference Patterns

Instead of a literal value, a pattern may consist of a value reference. As with literal patterns, a simple equality check (`==`) will be used.

```rip
answer = 42

match (value) {
  when (answer) { }
}
```

---

### 2.3. Basic Container Patterns (Lists And Hashes)

#### 2.3.1. Destructuring

Lists and hashes may be destructured in patterns, with specific elements being bound to branch-level references.

List:

```rip
match ([1, 2, 3]) {
  when ([one, two, three]) {
    # one = 1
    # two = 2
    # three = 3
  }
}
```

Hash:

```rip
match ({:one: 1, :two: 2, :three: 3}) {
  when ({:one: one, :two: two, :three: three}) {
    # one = 1
    # two = 2
    # three = 3
  }
}
```

---

#### 2.3.2. Slurping

The unary slurp operator `*` captures remaining elements.

If only some items need to be bound, the rest may be slurped into a new list or hash with the slurp operator (`*`). Only one slurp is allowed per pattern. For lists the slurp may appear in any position. For hashes the slurp must be at the end. Multiple slurps are a syntax error.

List:

```rip
match ([1, 2, 3]) {
  when ([head, *tail]) {
    # head = 1
    # tail = [2, 3]
  }
}
```

Hash:

```rip
match ({:one: 1, :two: 2, :three: 3}) {
  when ({:one: one, *rest}) {
    # one = 1
    # rest = {:two: 2, :three: 3}
  }
}
```

---

#### 2.3.3. Discarding

If some items need to be discarded, they may be bound to the special non-binding reference (`_`). The non-binding reference may be used as many times as needed in the pattern. As the name suggests, it is not avaible for reading inside the branch.

List:

```rip
match ([1, 2, 3]) {
  when ([_, two, _]) {
    # two = 2
  }
}
```

Hash:

```rip
match ({:one: 1, :two: 2, :three: 3}) {
  when ({:two: _, *rest}) {
    # rest = { :one: 1, :three: 3 }
  }
}
```

---

### 2.4. Hash Patterns Notes

Patterns for a hash look similar to hash literal syntax. Keys are specified as strings and are matched literally. Values are references that are assigned the value of the given key.

The slurp operator works similarly to list patterns in that it creates a new hash of any unmatched keys while the non-binding reference may be used to match a key without creating a reference for it.

```rip
match ({:one: 1, :two: 2, :three: 3}) {
  when ({:two: two, *rest}) {
    # two = 2
    # rest = { :one: 1, :three: 3 }
  }
}
```

`*` and `_` may be combined to discard unwanted keys without creating a new hash in the branch.

```rip
match ({:one: 1, :two: 2, :three: 3}) {
  when ({:two: two, *_}) {
    # two = 2
  }
}
```

---

### 2.5. Type Patterns

Patterns may reference declared or global types, as well as type literals. Type patterns use normal type syntax. A type pattern matches when the matched value's type is structurally compatible with the pattern type.

```rip
match (value) {
  when (String) { }

  when (type { name: String }) { }

  when (A & type { active: Boolean })
}
```

Type patterns narrow using intersection as defined below.

Note: Structure patterns operate on runtime values; type patterns operate on static type compatibility. Consider:

```rip
match (foo) {
  when ({:name: n}) { }
  when ({:name: String}) { }
  when (type { name: String }) { }
}
```

The first pattern matches a _Hash_ with only one key (no other matched keys and no slurp). That key must be `:name`. The value of `foo[:name]` is bound to reference `n`.

The second pattern matches a _Hash_ with only one key (no other matched keys and no slurp). That key must be `:name`. The type of `foo[:name]` must be compatible with type `String`. The value of `foo[:name]` is not bound.

The third pattern matches a _type literal_ describing a `name` property. The `name` property must have type `String`.

---

## 3. Evaluation Order

Branch patterns are tested in source order. The first matching branch is selected.

If a branch's narrowed type is uninhabited after accounting for previous branches, it is unreachable and is a compile-time error.

---

## 4. Type Narrowing

Inside a `when (P)` branch, the matched value is narrowed using intersection:

```rip
NarrowedType = OriginalType & P
```

The result is normalized using standard union and intersection reduction rules.

Example:

```rip
A = type { name: String, color: String }
B = type { name: String, age: Rational }
C = A | B

match (c) {
  when (A) { ... }
}
```

Narrowing:

```
(A | B) & A
= (A & A) | (B & A)
= A | ∅
= A
```

Inside the branch, the value has type `A`.

Narrowing is purely structural.

---

## 5. Alternate Patterns (OR)

Multiple patterns may be passed to `when` by separating each pattern with a comma. This is syntactic sugar for multiple ordered branches with identical bodies. These two `match` blocks are identical (the first compiles into the second).

```rip
match (value) {
  when (0, 1) {
    # do work for zero or one
  }
}

match (value) {
  when (0) {
    # do work for zero or one
  }

  when (1) {
    # do work for zero or one
  }
}
```

Alternate patterns are evaluated left to right. Each pattern participates in reachability analysis.

---

## 6. Guard Clauses

An optional guard clause (`if (condition)`) may be added to further refine the match. Guard conditions are only considered if the pattern matches. Conditions have access to any bound references from the pattern.

```rip
match (value) {
  when ([x, *tail]) if (x > 0) { }

  when (n) if (n < 0) { }
}
```

The guard is evaluated only if the pattern matches.

Guarded branches are treated as if their pattern(s) are absent for purposes of exhaustiveness analysis. Exhaustiveness is determined only by unguarded patterns.

```rip
match (n) {
  when (Rational) if (x > 0) {
    # n is positive
  }

  when (Rational) if (x < 0) {
    # n is negative
  }

  # could also be an else block
  when (Rational) {
    # x = 0
  }
}
```

Note that because the first two branches are removed from exhaustive requirement checks, the third branch must do more that match against literal `0`. **Even if guarded branches appear to logically cover all possible runtime values, they do not satisfy structural exhaustiveness requirements.**

---

## 7. Exhaustiveness

Exhaustiveness checking operates over the normalized union members of the matched expression's type. A branch covers a union member if the intersection of that member and the branch pattern is not uninhabited.

For container types, coverage is determined by the structural shapes permitted by the type.

Union members are normalized structurally. Structurally identical members collapse into one.

A `match` expression is exhaustive if all normalized union members are covered by preceding `when` clauses.

If not exhaustive, an `else` branch is required.

---

## 8. Else Branch

If present, `else` matches all remaining values not captured by earlier branches.

The type inside `else` is the remaining portion of the original type after removing all previously matched members.

If all members are already covered, `else` is unreachable and is a compile-time error.

---

## 9. Determinism

- Matching is ordered.
- Narrowing is structural.
- Exhaustiveness operates over normalized union members.
- Unreachable branches are compile-time errors.
- The compiler must not guess.
