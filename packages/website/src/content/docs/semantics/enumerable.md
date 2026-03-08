---
title: Enumerable
sidebar: { order: 2 }
---

## Overview

An `Enumerable<T>` represents a sequence of values that are produced lazily.

Unlike normal collections, which contain all of their values immediately, an enumerable produces values one at a time when they are requested. This allows pipelines to operate on very large collections efficiently and also enables infinite sequences.

Lazy enumerable pipelines are constructed with the `||>` operator.

An enumerable pipeline does **not** execute when it is defined. Instead, it builds a new enumerable that describes how values should be produced. The pipeline executes only when a consumer requests values.

---

## The Enumerable Protocol

Conceptually, an enumerable exposes a `next()` method that produces the next value in the sequence.

```rip
Some<T> = { value: T }
None = {}

Option<T> = Some<T> | None

Enumerable<T> = {
  next: () -> Option<T>
}
```

Calling `next()` returns either:

- `Some<T>` – another value is available
- `None` – the sequence has finished

Each call to `next()` advances the enumerable forward by one item.

---

## Lazy Pipelines

The `||>` operator creates a **lazy pipeline stage**.

Each stage receives a `value` parameter representing the item produced by the previous stage. The stage may transform the value, remove it, or expand it into multiple values.

A pipeline stage may return:

| Return value    | Meaning             |
| --------------- | ------------------- |
| `T`             | emit a single value |
| `None`          | emit no value       |
| `Enumerable<T>` | emit many values    |
| `Collection<T>` | emit many values    |

The pipeline automatically flattens multi-value results.

This allows `||>` to express the behavior of common enumerable operations such as:

- transformation (`map`)
- conditional emission (`filter`)
- expansion (`flatMap`)

---

## Examples

### Map

```rip
1..5
  ||> -> (value: Integer) { value * 2 }
  |> List.collect
# => [2, 4, 6, 8, 10]
```

---

### Filter

Returning `None` removes a value from the stream.

```rip
1..10
  ||> -> (value: Integer) {
    if (value % 2 == 0) { value } else { None }
  }
  |> List.collect
# => [2, 4, 6, 8, 10]
```

---

### Flat Map

Returning a collection expands the stream.

```rip
1..3
  ||> -> (value: Integer) { [value, value * 10] }
  |> List.collect
# => [1, 10, 2, 20, 3, 30]
```

---

## Infinite Enumerables

Because enumerables produce values on demand, they may represent infinite sequences.

For example:

```rip
NaturalNumbers
  ||> -> (value: Integer) { value * 2 }
  ||> -> (value: Integer) {
    if (value % 3 == 0) { value } else { None }
  }
  |> List.take(count: 3)
# => [6, 12, 18]
```

The pipeline runs only until the consumer (`List.take`) has received enough values.

---

## Consuming Enumerables

Enumerables do not execute until a consumer requests values.

Common consumers include:

- `List.collect`
- `List.take`
- `List.first`
- `List.count`
- other collection-producing functions

For example:

```rip
1..5
  ||> -> (value: Integer) { value * 2 }
  |> List.collect
```

`List.collect` repeatedly calls `next()` on the enumerable until the sequence finishes, producing a list of the resulting values.

---

## Relationship to `|>`

`||>` builds **lazy enumerable pipelines**, while `|>` performs **eager single-value pipelines**.

A typical flow looks like this:

```rip
collection
  ||> transform
  ||> filter
  |> List.collect
```

Here:

1. `||>` builds the lazy pipeline
2. `List.collect` consumes the enumerable
3. The pipeline executes as values are requested

This separation allows large or infinite sequences to be processed efficiently.
