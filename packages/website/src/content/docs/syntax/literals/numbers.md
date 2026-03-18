---
title: Numbers
sidebar: { order: 1 }
---

## 1. Rational Numbers

Rip strives to represent numbers accurately, so all numbers are Rational with unbounded precision. Floating point numbers are not available in Rip.

Numbers may optionally be prefixed with a positive or negative sign.

```rip
# decimals are just rational numbers (not floating point!)
3.14159
```

A leading zero is required for decimal numbers less than `1`.

```rip
# correct
0.3

# syntax error
.3
```

## 2. Whole Numbers

Whole numbers (type `Integer`) are a sub-type of `Rational` numbers.

```rip
42
```

Mathmatical methods that operate on numbers define multiple overloads so `Rational` and `Integer` numbers may be mixed and matched naturally.

```rip
42 + 3.14159
```

## 3. Signed Numbers

Number literals may be prefixed by positive (`+`) and negative (`-`) unary operators.

```rip
+42

-3.14
```

### 3.1. Signed Zero

Positive and negative zero exactly the same. They are syntactically allowed, but are semantically identical.

```rip
+0 == -0
```

## 4. Readability

Large (or small) number literals may be written with underscores (`_`) to separate groups of digits. This is intended to improve readability. At least one digit is required to be given before _and_ after each underscore. Underscores may othewise be used anywhere in a number literal.

```rip
1_234_567_890
```

## 5. Irrational Numbers

Irrational numbers were originally intended to be represented by a special type of function that could lazily generate the infinite sequence of digits they require. Until that exact mechanism is worked out, irrational numbers are represented by rational numbers with a large number of decimal points.

## 6. Complex Numbers (PLANNED)

In the future it might be nice to explore modeling numbers as two dimensional entities. Numbers would mostly work as they currently do. However:

- number literals would implicitly be _real numbers_
- number literals would allow `r` or `i` suffix directly after the last digit
- real and imaginary numbers could be added together
- real numbers would have an implicit imaginary part and vise versa

This is how numbers were originally meant to work in Rip. It might be interesting to revisit in the future.
