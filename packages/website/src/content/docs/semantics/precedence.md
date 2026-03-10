---
title: Precedence
---

Expressions are evaluated strictly **from left to right**. Rip intentionally does not define precedent rules for binary operators, because [binary operator syntax](/syntax/functions/#32-binary-method-call) is actually sugar for [chained method syntax](/syntax/functions/#31-dot-call).

For example:

```rip
a + b * c
```

is interpreted as:

```rip
(a + b) * c
```

Parentheses may be used to control evaluation order explicitly.
