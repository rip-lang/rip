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

Generic parameters are instantiated at compile time. Similar to functions, multiple generic type parameters may be listed, separated by commas. Generic parameters may also specify a default type with a comma (`=`). All generic parameters with defaults must be listed after generic parameters without defaults. Later type parameters may refer to earlier type parameters.

```rip
Response<Error, Data, RawData = Data>
  = { success: Literal<true>, data: Data }
  | { success: Literal<false>, error: Error }
```

Generic types may have constrants added to them that must be satisfied. Contraints are written after the generic reference separated by a colon (`:`). A type satisfies a generic constraint if it is a subtype of the constraint type. Unions and intersections may be used to specify multiple constraints.

```rip
ResultSet<T: Interable> = { data: T }
```

If a default is provided for a generic type with a constraint, it must satisfy the constraint.

---

### 2.8 Literal Types

Lteral values may be converted to compile-time singleton types by passing them to the `Literal<V>` generic type. Such literal types participate in structural subtyping where applicable.

```rip
Color
  = Literal<:red>
  | Literal<:green>
  | Literal<:blue>
  | Literal<:yellow>
  | Literal<:magenta>
  | Literal<:cyan>
```

Literal types are available for any type that has a literal syntax. The literal type is understood to be a subtype of the literal value's type.

#### 2.8.1 Literal Refinement

A literal expression `V` has a base type corresponding to its literal kind (e.g., `String`, `Integer`, `Boolean`). Literal values do not automatically acquire the type `Literal<V>`.

However, a literal expression provides a compile-time singleton refinement that may be used when checking compatibility against `Literal<V>`.

A binding is considered _refined to_ `Literal<V>` if and only if it is initialized directly from the literal expression `V`.

```rip
background-color = -> (theme: Literal<:dark> | Literal<:light>) { }
# :dark is typed as String, but is refined to Literal<:dark> in the argument
# position since the parameter's type is literal
background-color(:dark)
```

Literal type refinement does not propagate.

```rip
background-color = -> (theme: Literal<:dark> | Literal<:light>) { }
# :dark is typed as String, and literal refinement is NOT propagated
my-theme = :dark
background-color(my-theme)
```

Use `Exact<V>` if a literal type is needed. `Exact<V>` produces a value whose static type is `Literal<V>`. Normally a literal expression (like `42`) is given a broad base type (`Integer` in this case) that, among other things, does not participate in exhaustiveness checks. Using `Exact` tells the compiler to assign the singleton literal subtype to the value at the binding site, rather than relying on non-propagating literal refinement. The runtime value is unchanged.

```rip
background-color = -> (theme: Literal<:dark> | Literal<:light>) { }
# :dark is typed as Literal<:dark>, and literal refinement is not needed
my-theme = Exact<:dark>
background-color(my-theme)
```

Literal refinement:

- Does not change the inferred or declared type of the binding.
- Does not propagate.
- Is erased by any non-literal expression (including function calls, operators, control flow joins, or other composite expressions).
- Does not participate in general subtyping or normalization.

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

A literal expression `V` (see §2.8.1) is compatible with parameter type `Literal<V>`.

Literal refinement affects compatibility checks only. It does not modify the structural type of a value, does not introduce implicit widening or narrowing, and does not alter overload specificity ordering beyond satisfying `Literal<V>` parameters.

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
