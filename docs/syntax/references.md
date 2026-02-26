# References

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
