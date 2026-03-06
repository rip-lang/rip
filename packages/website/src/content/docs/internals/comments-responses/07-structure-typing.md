---
title: Structural typing of structs
---

You show:

> Pet isn't a User, but it overlaps with User, so it works ￼

This implies width subtyping.

But then:

👉 Are structs nominal at all?

Because if they're fully structural, struct is just syntax sugar for record types.

If they're nominal + structural compatible, you'll need to define:

- Identity vs compatibility
- Equality semantics
- Pattern matching behavior

This is a key philosophical decision.

---

I had to look up "width subtyping". My intension in that example is to show that a `Pet` type is acceptable for the `get-age` function because it satisfies the type contraints that the `User` type imposes.

_Everything_ is fully structural. Functions can be properties on structures like anything else.
