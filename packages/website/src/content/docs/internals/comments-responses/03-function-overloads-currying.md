---
title: Function overloads + currying interaction
---

You allow:

- Automatic currying
- Overloads
- Optional parameters

This is a dangerous trio because partial application can change overload selection.

Example:

```rip
f = -> (x: Integer, y: Integer)
f = -> (x: String, y: String)

g = f(10)
```

What is `g`'s type?

You must define whether overload resolution happens:

1️⃣ Before currying
2️⃣ After currying
3️⃣ Lazily

Each choice has big implications.

---

Your example is actually a bit ambiguous because `f` can't be re-assigned.

```rip
f = -> (x: Integer, y: Integer)
f = -> (x: String, y: String)

g = f(10)
```

Let's assume you meant something like this:

```rip
f = => {
  -> (x: Integer, y: Integer) { ... }
  -> (x: String, y: String) { ... }
}

g = f(10)
```

In that case `g` is a function that would be equivelant to the following:

```rip
g = => {
  # -> (x: Integer, y: Integer) { ... }
  # -> (x: String, y: String) { ... }
  -> (y: Integer) { self(10, y) }
}
```

I think we can assume eager evaluation for now, but lazy evaluation (especially for collections) is very interesting.

To hopefully clarify `g` has an arity of 1. The "shadow" overloads from `f` aren't accessible except through `g`'s `self` reference.
