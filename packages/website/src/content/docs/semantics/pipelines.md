---
title: Pipelines
sidebar: { order: 1 }
---

Data can be processed with a chained binary method called "pipe" (`|>`). Chaining multiple together creates a "pipeline". Pipelines create readable data transformation flows that operate left-to-right. Each pipeline stage receives the result of the previous stage as a `value` argument. To participate in pipelines, functions must provide an overload with a `value` parameter of the appropriate type.

## 1. Eager Evaluation Over Single Value

The pipe operator `|>` binds the piped value to a parameter named `value`. If the value is a collection, it binds the entire collection, not the individual items.

```rip "|>"
:cat
  |> String.uppercase # => :CAT
  |> String.pad(length: 10, fill: "&") # => "&&&&&&&CAT"
  |> String.count # => 10
```

Conceptually, every value supports a `|>` method. The core runtime provides this method for all values. This method takes a function with the named parameter `value`. The last example could be rewritten as the following:

```rip
String.count(
  value: String.pad(
    length: 10,
    fill: "&"
  )(
    value: String.uppercase(value: :cat)
  )
)
# => 10
```

Or more canonically as:

```rip
String.count(
  value: String.pad(
    length: 10,
    fill: "&",
    value: String.uppercase(value: :cat)
  )
)
# => 10
```

The advantage of the pipeline approach is the code reads in the same order it executes.

The rule is that `a |> f(b: 1)` is exactly equal to `f(b: 1)(value: a)`, which is semantically equal to `f(b: 1, value: a)`. `f(b: 1)` produces an automatically-curried function with `b` partially applied. This new anonymous function is passed to `|>`, which applies the `value` argument, which executes the original `f` function.

## 2. Overload Resolution

After the pipeline binds the `value` argument, normal overload resolution selects the most specific overload.

```rip
foo = => {
  -> (value: Integer) { ... }
  -> (value: String) { ... }
}

42 |> foo
```

### 2.1. Behind The Scenes

The pipe "operator" takes advantage of Rip's binary operator method invocation. `|>` isn't actually an operator at all. It's just a method that is available on all values.

```rip
:cat
  .|>(fn: String.uppercase) # => :CAT
  .|>(fn: String.pad(length: 10, fill: "&")) # => "&&&&&&&CAT"
  .|>(fn: String.count) # => 10
```

`|>` is a method that takes a function parameter (`fn`). It calls `fn` with `@` passed as `value`.

Conceptually `|>` might be thought of as being defined in a "global" struct. The `|>` method is defined by the core runtime for all values.

```rip
Object = struct {
  @.|> = -> <T, R> (fn: (value: T) -> R) {
    fn(value: @)
  }
}
```

### 2.2. Partial Application

Suppose `String.pad()` is meant to be called with two required arguments: `value` (the string to pad) and `length` (minimum number of characters the final result should be). (We can ignore an optional `fill` parameter for now.)

```rip
String.pad(length: 10, value: :cat)
# => "       cat"
```

Pipelines work nicely with Rip's partial function application and automatic currying.

```rip
:cat |> String.pad(length: 10)
# => "       cat"
```

But if `length` is required, a pipeline may still be used to produce a function that's been bound to `:cat`. Calling this function with `length` will produce the final string.

```rip
multi-length = :cat |> String.pad
# => (length: Integer) -> String

multi-length(length: 5)
# => "  cat"

multi-length(length: 7)
# => "    cat"
```

Because not all required parameters are provided, the result is a [partially applied function](/syntax/functions/#automatic-curry).
