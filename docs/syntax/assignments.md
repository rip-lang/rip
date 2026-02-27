# References And Assignments

Similar to other languages, references (or identifiers) must not start with a digit and must not contain any whitespace. Unlike most other languages, references are allowed to contain most other printable characters and do not need to contain letters at all. References are case sensitive.

```rip
foo
dashes-or_underscores_for-readability
```

Some special references are automatically defined and are globally available.

```rip
System
true
false
```

You can associate a value with a reference with the assignment operator (`=`). All references are immutable and "write-once".

```rip
answer = 42
name = :Fred
```

## Destructured Assignments

List and hash destructured assignment follow the same rules for patterns in `match` expression blocks. If a destructured assignment pattern cannot match the assigned value, it is a runtime error unless the type system can determine the mismatch at compile time.

```rip
[head, *tail] = list
{:two: two} = hash
```

An object's property may be bound to a reference of the same name. Multiple properties may be bound by separating each with a comma.

```rip
{name} = any-value-with-a-name-property
{foo, bar, baz} = quix
```

See blocks/match.md for more information about pattern matching.

## Naming Convensions

References for "normal" values (variables in other languages) and properties generally follow `lower-kebab-case` or `lower_snake_case`. Both are fine, but kebab is preferred since it's easier to write.

```rip
user-handle = "@ghostmaster"
```

References for "constant" values and properties generally follow `UPPER_SNAKE_CASE`.

```rip
ANSWER = 42
SYSTEM_EMAIL = "no-reply@example.com"
```

References for types and structures generally follow `UpperCamelCase`.

```rip
User = struct (name: String) { }

Result
  = type <T> { success: true, data: T }
  | type { success: false, error: String }
```
