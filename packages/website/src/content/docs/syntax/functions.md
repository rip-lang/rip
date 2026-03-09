---
title: Functions
---

Functions are units of code that are executed when "called". They are first-class objects, so they may be passed around and to/from other functions.

## Basic Syntax

Functions are defined with the dash rocket (`->`) keyword. This is followed by parenthesis (`(`/`)`) for any parameters. Parenthesis are required even if no parameters are given. Parameters are typed references for binding to arguments when the function is called. The function body is defined by curly braces (`{`/`}`), which are required, even if the body has just one expression.

Functions must always return a value. A function can return a value with the `return` keyword. Otherwise the last expression in a function is what is returned. The signature (type) of a function includes any parameters and a union of all possible return types.

```rip
-> () { return 42 }
```

The `return` keyword is normally not used unless it is required. (For instance if the function needs to return early.)

## Required Parameters

Functions may have values passed to them when they are called. When a function is defined, any number of parameters may be specified. Each parameter has a reference and a type, separated by a colon (`:`). Multiple parameters are separated by comma (`,`).

A function with parameters is called with arguments. Arguments provide the values that are bound to the parameters when the function is executed. Arguments must specify which parameter they are binding to by name. As a syntax shorthand, if a local reference is being bound to a parameter of the same name, the explicit name may be skipped. Otherwise the parameter name is always required.

```rip "a: Rational, b: Rational"
add = -> (a: Rational, b: Rational) { a + b }

add(a: 1, b: 2)
# => 3

a = 1
b = 2
add(a, b)
# => 3
```

Since every argument names the parameter it is bound to, arguments may be written in any order, as long as the same parameter isn't bound more than once.

## Method Invocation

Rip supports a shorthand syntax for calling methods with a single argument. This syntax is inspired by traditional binary operator notation but is available for **any** method that is called with exactly one argument.

### Dot Call

The most explicit form uses dot notation.

```rip
foo.bar(x: 1)
```

This calls the method `bar` on `foo`, binding the argument to parameter `x`. This is how most methods are called.

### Binary Method Call

If a method is called with exactly **one argument**, it _may_ be invoked using binary syntax:

```rip
foo bar 1
```

This desugars to:

```rip
foo.bar(_: 1)
```

The argument is bound to the parameter named `_`.

Binary syntax is available for **any single‑argument method**, not just traditional operators.

### Operator Methods

Operator-looking methods are simply methods whose names are symbols.

```rip
1 + 2
```

This is equivalent to:

```rip
1.+(_: 2)
```

Binary operators are ordinary methods and may be defined on structures. For example, a method may be defined like this:

```rip
Greeter = struct {
  @.greet = -> (_: String) { "Hello #{_}" }
}

g = Greeter.new()

# "normal" dot notation
g.greet(_: :world)
# => "Hello world"

# binary "operator" notation
g greet :world
# => "Hello world"
```

### Left-to-Right Evaluation

Rip intentionally does **not** define operator precedence rules.

Binary method syntax is always evaluated **left to right**.

For example:

```rip
a + b * c
```

is interpreted as:

```rip
(a + b) * c
```

because the expression is parsed as chained binary method calls.

Parentheses may be used to control evaluation order explicitly.

### Readability

Binary syntax is entirely optional. Developers may always use the explicit dot syntax instead:

```rip
foo.bar(_: baz)
```

Binary syntax is generally preferred for operator-like methods, while dot syntax is typically clearer for ordinary method names.

## Optional Parameters

A parameter is considered optional if it is defined with a default expression. A default expression is written after the parameter name/type combo, separated by an equal sign (`=`). The default expression is statically analyzed to infer the parameter's type, therefore the type is typically omitted.

```rip "b = 42"
add = -> (a: Rational, b = 42) { a + b }
```

In this example `b` is inferred to be `Integer`. This may be changed by explicitely writing the type.

```rip "b: Rational"
add = -> (a: Rational, b: Rational = 42) { a + b }

add(a: 21)
# => 63

add(b: 21, a: 13)
# => 34
```

## Splat

The unary splat operator (`*`) may be used to specify multiple arguments at once.

```rip {10,16} "*coords"
Coordinates = struct {
  @.x: Rational
  @.y: Rational
}

Map = struct {
  @.coordinates: List<Coordinates> = []
}

mark-map = -> (map: Map, x: Rational, y: Rational) { ... }

blank-map = Map.new()

coords = Coordinates.new(x: 14, y: 25)

marked-map = mark-map(map: blank-map, *coords)
```

Arguments may be splattered as long as the object being splatted has compatible fields and types. Arguments are bound in source order (left-to-right, so explicitly named arguments that appear after may override splatted bindings will take precedent.

## Recursion

Functions have a special reference (`self`) available in the body that allows the function to call itself.

```rip {5} "self"
factorial = -> (n: Integer, accumulator = 1) {
  if (n == 0) {
    accumulator
  } else {
    self(n: n - 1, accumulator: n * accumulator)
  }
}
```

## Overloads

Functions may be defined with multiple implementations called overloads. Each overload defines its own parameters and function body. Functions with overloads are defined with the fat rocket (`=>`) keyword. They have a collection of anonymous overloads inside a pair of curly braces (`{`/`}`).

```rip "=>" "->"
overloaded_function = => {
  -> (a: Integer) { self(a, b: 10) }
  -> (a: Integer, b: Integer) { a + b }
}
```

A function with optional parameters is syntactical sugar for this, where each optional parameter synthesizes an overload for the function.

### Wrapping

So far we've called two different things "functions", but this isn't quite accurate. Technically a _function_ is defined with `=>`, and an _overload_ is defined with `->`. The difference might be subtle, but in Rip, a function is a wrapper around one or more overloads. Practically speaking though, overloads may be considered functions because the compiler automatically wraps any "naked" overload.

Consider the following example. This is what a developer might actually write:

```rip
factorial = -> (n: Integer, accumulator = 1) {
  if (n == 0) {
    accumulator
  } else {
    self(n: n - 1, accumulator: n * accumulator)
  }
}
```

During compilation the compiler wraps any naked overloads with full function syntax. A developer could write this, but single overloads are typically written without the function wrapper.

```rip {1,9}
factorial = => {
  -> (n: Integer, accumulator = 1) {
    if (n == 0) {
      accumulator
    } else {
      self(n: n - 1, accumulator: n * accumulator)
    }
  }
}
```

The compiler also eliminates any optional parameters by synthesizing missing overloads that call the function recursively. Again a developer could write out each overload by hand, but it's usually better to just let the compiler handle it.

```rip {2-4}
factorial = => {
  -> (n: Integer) {
    self(n, accumulator: 1)
  }

  -> (n: Integer, accumulator: Integer) {
    if (n == 0) {
      accumulator
    } else {
      self(n: n - 1, accumulator: n * accumulator)
    }
  }
}
```

## Automatic Curry

Function arguments are automatically curried if enough arguments aren't given to satisfy all required parameters. If a call does not bind all required parameters, the result is a new function expecting the remaining parameters. Parameters may not be bound more than once.

```rip {5-7}
foo = -> (a: Integer, b: Integer, c: Integer) {
  a + b + c
}

foo(a: 1, b: 2, c: 3)
foo(c: 3)(a: 1, b: 2)
foo(b: 2)(c: 3)(a: 1)
```

For the case where some parameters have defaults:

```rip {5-7}
bar = -> (a: Integer, b: Integer, c = 3) {
  a + b + c
}

bar(a: 1, b: 2)
bar(b: 2, a: 1)
bar(b: 2)(a: 1)
```

## Generic Parameter Types

Functions can take generic type parameters separated by commas. Type parameters are surrounded by angled brackets (`<`/`>`) between the `=>` or `->` and the value parameters.

The angle brackets must be omitted if no type parameters are accepted.

```rip "<T>"
foo = -> <T> (x: { ok: T } | { error: String }) { ... }
```

For functions written with the fat rocket keyword, type parameters are placed after the fat rocket instead of the dash rocket. For such "wrapped" functions, type parameters may not be specified for a particular overload; **type parameters are shared across all overloads**.

Note that to keep generic signatures concise, generic type arguments are positional, not named. Type parameters may refer to previously-defined type parameters in the same list. Type parameters may be used throughout the function, including as types for value parameters.

See [Types](/syntax/types#27-generic-types) for more information about generics.

If an argument is syntactically a literal `V`, and the parameter type includes `Literal<V>`, the argument is considered compatible.

## Literal Types And Dispatch

A literal expression `V` is compatible with a parameter of type `Literal<V>` via [literal refinement](/syntax/types/#281-literal-refinement). This refinement applies only at the call site and does not change the static type of the argument.

If a value is bound and later passed to a function, literal refinement does not propagate.

To create a value whose static type is `Literal<V>`, use `Exact<V>`. Values constructed with `Exact` participate fully in overload specificity and union exhaustiveness.

```rip
foo = => {
  -> (x: Literal<42>) { :exact }
  -> (x: Integer) { :integer }
}

foo(x: 42)
# => :exact (via refinement)

n = 42
foo(x: n)
# => :integer

m = Exact<42>
foo(x: m)
# => :exact
```
