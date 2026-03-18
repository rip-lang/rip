---
title: 0003 Function Semantics
---

Function overloads + currying interaction

You allow:

- Automatic currying
- Overloads
- Optional parameters

This is a dangerous trio because partial application can change overload selection.

Example:

```rip
f = -> (x: Integer, y: Integer)
f = -> (x: String, y: String)

g = f(x: 10)
```

What is `g`'s type?

You must define whether overload resolution happens:

1. Before currying
2. After currying
3. Lazily

Each choice has big implications.

## Response

Your example is actually a bit ambiguous because `f` can't be re-assigned.

```rip
f = -> (x: Integer, y: Integer)
f = -> (x: String, y: String)

g = f(x: 10)
```

Let's assume you meant something like this:

```rip
f = => {
  -> (x: Integer, y: Integer) { ... }
  -> (x: String, y: String) { ... }
}

g = f(x: 10)
```

In that case `g` is a function that would be equivelant to the following:

```rip
g = => {
  # -> (x: Integer, y: Integer) { ... }
  # -> (x: String, y: String) { ... }
  -> (y: Integer) { self(x: 10, y) }
}
```

I think we can assume eager evaluation for now, but lazy evaluation (especially for collections) is very interesting.

To hopefully clarify `g` has an arity of 1. The "shadow" overloads from `f` aren't accessible except through `g`'s `self` reference.
