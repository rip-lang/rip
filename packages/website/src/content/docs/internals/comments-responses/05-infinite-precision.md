---
title: Infinite precision + irrational numbers
---

You wrote:

> irrational numbers lazily generate digits

This is mathematically elegant but extremely tricky:

Questions you'll need to answer:

- Equality semantics?
- Hashing?
- Determinism?
- Precision context?
- Termination guarantees?

Most languages avoid true irrationals for this reason.

This is a research-level feature.

---

I had the impression that there are libraries for handling infinitely precise rational numbers. I'm pretty sure Ruby had one that I used while building the original REPL/interpreter.

For irrational numbers I was hoping to borrow from Haskell. I'll admit I don't actually know if Haskell solves this problem as I suggested in the document, but if that's not doable, then what do you suggest? At the very least the "famous" irrationals could be hard-coded as rationals with a sufficient number of digits.
