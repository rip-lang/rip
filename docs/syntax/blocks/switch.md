# Switch

The expression is compared with each `when` parameter from top
to bottom. Note that cases do _not_ "fall through" as in some languages! The block associated with the first matching case is executed
and the value is returned. Conceptually all `if`/`else` blocks could be replaced with a `switch` block with a single `when (true)` and an `else`.

```rip
switch (expression) {
  when (:one) {
  }

  when (:two) {
  }

  when (:three) {
  }

  else {
    # else is optional if all branches are exhaustive
  }
}
```
