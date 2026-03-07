---
title: 0009 Exhaustiveness
---

Pattern matching exhaustiveness

You say:

> else optional if exhaustive ￼

With structural typing, exhaustiveness checking becomes very hard unless:

- Types are closed
- ADTs are sealed

Otherwise the compiler cannot know all possible shapes.

You'll need a rule like:

👉 Exhaustiveness only guaranteed for ADTs

Otherwise developers will expect guarantees you can't provide.

## Response

Structures don't have inheritance. They are immutable, so they can't be added to or otherwise modified after they are defined. I think I need more details about "types are closed" and "adts are sealed" before I can fully respond.
