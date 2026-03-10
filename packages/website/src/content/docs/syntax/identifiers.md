---
title: Identifiers
---

## 1. References

Similar to other languages, references (or identifiers) must not start with a digit and must not contain any whitespace. Unlike most other languages, references are allowed to contain most other printable characters and do not need to contain letters at all. All references are case sensitive.

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

### 1.1. Naming Convensions

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
User = struct { @.name: String }

Result<T>
  = { success: true, data: T }
  | { success: false, error: String }
```

## 2. Assignment

You can associate a value or a type with a reference using the assignment operator (`=`). All references are immutable and "write-once" (single static assignment).

### 2.1. Normal Assignment

The normal assignment syntax is used for both runtime values and compile-time types, depending on the RHS.

```rip
# value
answer = 42

# type
Result = { success: Literal<true>, data: Foo }
```

### 2.2. Destructured Assignment

Value destructured assignment follow the same rules for patterns in `match` expression blocks. If a destructured assignment pattern cannot match the assigned value, it is a runtime error unless the type system can determine the mismatch at compile time.

```rip
# value
[head, *tail] = list
{:two: two} = hash
```

An object's property may be bound to a reference of the same name. Multiple properties may be bound by separating each with a comma.

```rip
# value
{name} = any-value-with-a-name-property
{foo, bar, baz} = quix
```

See [match](/syntax/control-flow/match) for more information about pattern matching.

### 2.3. Generic Assignment

Generic type references need the type parameters listed after the reference. Generic parameters are shared across any unions or intersections.

```rip
# type
Result<T, E>
  = { success: Literal<true>, data: T }
  | { success: Literal<false>, error: E }
```
