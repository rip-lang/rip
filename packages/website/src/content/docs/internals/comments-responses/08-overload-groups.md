---
title: Overload groups as values (self)
---

This is interesting and powerful:

```rip
self(n - 1, ...)
```

But introduces questions:

- Can overload groups be passed as values?
- Can they be partially applied?
- Can they be generic?
- Are they first-class?

If yes → you're building multi-methods.
If no → restrict explicitly.

---

"Bare" overloads are just syntax sugar for a single overload wrapped in a a function.

```rip
a = -> () { ... }
b = => { -> () { ... } }
```

`a` and `b` are exactly equivelant. A function (`=>`) always has one or more overloads (`->`). Functions are somewhat dynamic when it comes to auto-currying, as the curried function has a new overload that wasn't part of the original function.

I'm actually not sure what the concern is here. Please elaborate.
