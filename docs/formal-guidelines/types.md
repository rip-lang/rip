# Types

## 1. Core Principles

1.  Everything is structural
    Types are defined by shape and behavior, not by nominal identity.
2.  Everything is immutable
    All values are immutable. Types describe immutable structures.
3.  Everything is an expression
    All constructs evaluate to values with types.
4.  Static typing with inference
    Types are inferred locally using parameter annotations and expression analysis.
5.  Monomorphized generics
    Generic functions are specialized at compile time for concrete type combinations.
6.  Multiple dispatch
    Function overload resolution is based on argument types using a specificity ordering.

---

## 2. Type Categories

Rip has the following categories of types:

### 2.1 Primitive Types

Examples include:

- Integer
- Rational
- Decimal (if introduced)
- Boolean
- String
- Date / Time / DateTime
- Regex

Primitive types participate in structural subtyping where applicable.

---

### 2.2 Structural Record Types

A record type is defined by a set of named fields.

```rip
{ name: String, age: Integer }
```

A value satisfies a record type if it contains at least those fields with compatible types.

---

### 2.3 Function Types

Function types are structural.

```rip
(a: Integer, b: Integer) -> Integer
```

A function value satisfies a function type if at least one overload matches the signature.

---

### 2.4 Union Types

```rip
A | B
```

Represents values that may be either type. Union members are normalized structurally. Any members whose normalized structural forms are identical collapse into a single member. Unions therefore represent sets of structurally distinct types. Nested unions are flattened during normalization.

Exhaustiveness checking in pattern matching operates over the structurally distinct members of the normalized union.

---

### 2.5 Intersection Types

```rip
A & B
```

Represents values satisfying both types. Intersections are distributed across union members.

---

### 2.6 Reduction Rules

```
(A | B) & C = (A & C) | (B & C)
(A | B) & A = A
(A & B) | A = A
```

Any member whose intersection becomes impossible is removed.

Reduction operates purely structurally. When intersections distribute across a union, each resulting branch is normalized independently. Any branch whose intersection becomes impossible (i.e., reduces to an uninhabited type) is removed from the resulting union. If only one structurally distinct member remains after normalization, the union reduces to that member.

---

### 2.7 Generic Types

```rip
List<T>
Foo<T> = { data: T }
```

Generic parameters are instantiated at compile time.

---

## 3. Structural Subtyping

Type A is a subtype of type B if A satisfies all requirements of B.

### 3.1 Width Subtyping

A record with more fields is a subtype.

```
{ name, age } <: { name }
```

---

### 3.2 Depth Subtyping

Fields are compatible if their types are subtypes.

```
{ x: Integer } <: { x: Number }
```

---

### 3.3 Function Subtyping

Functions are:

- Contravariant in parameters
- Covariant in return type

---

### 3.4 Union Rules

```
A <: A | B
B <: A | B
```

---

### 3.5 Intersection Rules

```
A & B <: A
A & B <: B
```

---

## 4. Structural Type Identity

Two types are considered equivalent if their normalized structural forms are identical.

Normalization includes:

- Field order canonicalization
- Recursive type expansion with cycle detection
- Alias elimination

Types defined in separate modules are interchangeable if structurally identical.

---

## 5. Function Overloads and Dispatch

### 5.1 Overload Groups

A function value contains one or more overloads.

---

### 5.2 Compatibility

An overload is compatible with a call if argument types are subtypes of parameter types.

---

### 5.3 Specificity Ordering

An overload A is more specific than B if:

- All parameter types of A are subtypes of those in B
- At least one parameter type is strictly more specific

---

### 5.4 Dispatch Rule

1. Collect all compatible overloads
2. Select most specific
3. If multiple equally specific → compile error

---

### 5.5 Currying

Partial application produces a new overload with bound arguments removed from the parameter list.

Synthesized overloads participate in dispatch normally.

---

## 6. Function Type Satisfaction

A function satisfies a function type if at least one overload matches the signature.

---

## 7. Generic Constraint Satisfaction

A type satisfies a generic constraint if it is a subtype of the constraint type.

Structural matching is used.

---

## 8. Numeric Model

### 8.1 Numeric Types

Initial numeric hierarchy:

```
Integer <: Rational
```

(Additional types may extend hierarchy)

---

### 8.2 Arithmetic

Operations produce the least upper bound numeric type.

Example:

```
Integer + Rational → Rational
```

---

### 8.3 Equality

Numeric equality is exact for rational values.

Non-exact numeric types must define comparison semantics explicitly.

---

## 9. Equality Semantics

### 9.1 Structural Equality

Two values are equal if:

- Same type
- All fields equal recursively

---

### 9.2 Function Equality

Functions are equal only by identity.

---

## 10. Pattern Matching

### 10.1 Structural Matching

Patterns match based on structural compatibility.

---

### 10.2 Exhaustiveness

Exhaustiveness checking is guaranteed only for unions whose normalized members are structurally distinct and fully enumerated in the match.

---

## 11. Module Boundary Rules

Types exported across modules are treated structurally.

Type aliases are transparent.

---

## 12. Type Inference

Inference is local and bidirectional.

The compiler infers:

- Return types
- Local bindings
- Generic instantiations

Explicit parameter types define inference boundaries.

---

## 13. Recursion and Cycles

Structural comparison must use memoization to avoid infinite recursion.

---

## 14. Ambiguity

Any type resolution ambiguity results in a compile-time error.

The compiler must not guess.
