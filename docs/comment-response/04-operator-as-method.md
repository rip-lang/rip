# Operator-as-method + structural typing

Since operators are methods (a.+(b)), structural typing implies:

👉 Any type with a + method supports +

This is consistent — but creates issues with numeric tower + inference.

Example:

```
Integer + Rational
Rational + Irrational
```

You’ll need a numeric promotion lattice or results become ambiguous.

---

I'm actually not clear about what "numeric tower" and "numeric promotion lattice" means. What I intend if for numbers to be mathmatically correct, even if it makes the language slower.
