---
title: Modules + structural typing
---

Structural typing across modules requires a canonical type identity model.

Otherwise:

```rip
type Foo = { x: Int }
```

in two modules — are they identical?

You'll need to define:

- Structural identity
- Type alias transparency
- Exported type canonicalization

---

I'd expect two modules that independently define identical types to be considered interchangable, like TypeScript. The exact details of structural identity need to be worked out.
