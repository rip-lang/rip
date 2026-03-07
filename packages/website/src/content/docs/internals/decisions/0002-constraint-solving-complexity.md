---
title: 0002 Constraint Solving Complexity
---

Structural typing + generics → constraint solving complexity

Structural typing with generics requires solving:

👉 "Does type `T` satisfy this structural constraint?"

This becomes expensive when nested:

```rip
{ data: List<{ id: Integer }> }
```

This is solvable, but you'll want to define:

- Structural equivalence rules
- Depth limits
- Normalization strategy

Otherwise compile times can explode.

## Response

I'm not _too_ worried about compile times at this point. (I could be naive here.) I think letting developers accept the trade-off of long compile times for super-nested types might be acceptable. If not a depth limit could be introduced. I'd like to see how the problem presents itself in real code.

As far as working out a way to compare structural types, I'm open to suggestions. TypeScript manages to do it, but maybe something more rigorous is required.
