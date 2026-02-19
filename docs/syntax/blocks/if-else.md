# If/Else

If the condition is true, the first block is executed and
returned. Otherwise the `else` block is. An `else` block is required except in
the case of an early return where the compiler can determine the current scope is guaranteed to produce a value further down.

```rip
if (condition) {
  # condition is true
} else {
  # condition is false
}
```
