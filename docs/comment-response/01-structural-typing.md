# Biggest architectural tension: structural typing + overloads + monomorphization

You have:

- Structural typing
- Function overloads
- Currying
- Generics
- Inference
- Method syntax sugar
- Pattern matching

That combination is one of the hardest spaces in language design because it creates overload resolution ambiguity.

Example of the problem

```rip
Foo = type { color: String }
Bar = type { color: String, shape: String }

f = -> (x: Foo) { ... }
f = -> (x: Bar) { ... }
```

If you pass a { color: String, shape: String }, both match structurally.

👉 Which overload wins?

You’ll need a formal rule:

- Most specific wins?
- Ambiguous = error?
- Structural depth comparison?

This must be defined early or the type system becomes unpredictable.

---

We could say the most specific type wins. If it's still ambiguous, it should throw a compiler error. I haven't considered deeply nested structures, but there will have to be a limit at some point. I wouldn't expect it to be a practical problem in nearly all cases, but the devil is in the details.
