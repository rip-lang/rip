# If/Else

If the condition is true, the first block is executed and returned. Otherwise the `else` block is. An `else` block is required except in the case of an early return where the compiler can determine the current scope is guaranteed to produce a value further down.

```rip
if (condition) {
  # consequence (condition is true)
} else {
  # alternative (condition is false)
}
```

Note that unlike many other languages, Rip doesn't support chaining `if` directly after `else`. Chained conditional logic can be expressed with `match`.

## Destructured Assignment Conditions

You can pattern match in the condition. Patterns and matching follows the same rules as `match`/`when` branches. Bound references are available inside the consequence block. If the pattern doesn't match, the alternative block (`else`) is executed. Inside the consequence block, the matched value is narrowed using the same intersection rules as in `match`.

See match.md for more information about pattern matching.

See syntax/assignments.md for more information about destructured assignments.

```rip
if (pattern = value) {
  # value is matched by pattern. if pattern includes any bound references,
  # those are available here
} else {
  # value is not matched by pattern
}
```

Type references are valid type patterns in `match` and `if` constructs.
