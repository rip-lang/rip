# Pattern Matching

The `expression` is examined and potentiall destructured according to each `when`'s `pattern`. The first matching `when` block is executed and the value is returned. Conceptually all `switch` blocks could be replaced with equivalent `match` blocks.

```rip
match (expression) {
  when (pattern) {
  }

  when (pattern) {
  }

  when (pattern) {
  }

  else {
    # else is optional if all branches are exhaustive for the given expression
  }
}
```
