---
title: Structure Syntax
---

Let's break this down into two parts: defining a structure and instantiating it. (Structures are closed by the way. Also structures already have a syntax for derived fields: `@.foo = ~> {}`)

I really like your suggested syntax for defining structures, but with a minor adjustment.

```rip
User = struct {
  # instance fields are declared/assigned to the structure's prototype (`@`)
  @.name: String
  @.birthday: Date
  # color is optional when creating a new instance
  @.color = :orange

  # static fields are assigned to the structure
  code = Exact<42>
}

user = User.new(...)

user.name
# => String

User.code
# => Literal<42>
```

Instantiating a structure should feel like calling any other function and getting a result. I did consider passing a Hash to `.new()`, but I think this will make tracking types difficult. Hashes are planned to be typed as generics where the union of all declared values is the type argument. At the very least, Rip would have to add extra plumbing to track types for individual keys.

```rip
# User defined in previous example
user = User.new({
  :name: :Sam,
  :birthday: 2000-01-01,
  :color: :chartreuse
})
```

It feels strange that the Hash should participate in the `User` typing. What if the hash is defined in a different file?

Another approach is to create a hybrid value/type syntax. I'm not sure what to call the object passed to `.new()`; maybe an anonymous struct literal?

```rip
# User defined in previous example
user = User.new({
  name: :Sam,
  birthday: 2000-01-01,
  color: :chartreuse
})
```

Tracking types with anonymous struct literals might be easier, but there's still the locality issue that using hashes has. Also users will be tempted to just use anonymous struct literals instead of creating a struct, and Rip would have to support this.

The last option is to introduce named parameters.

```rip
# User defined in previous example
user = User.new(
  name: :Sam,
  birthday: 2000-01-01,
  color: :chartreuse
)
```

This solves the locality problem (I think) and doesn't introduce anonymous struct literals. The question is whether to allow named parameters for any/all functions or just limit them to structure instantiation? I actually want to limit it, but `.new()` is meant to look and behave like an ordinary function (from the developer's perspecitve). I don't think I can get away with that big of a break in immersion.

One potential work-around is to drop `.new()` as you suggested. In that case I think named parameters (only for structure instantiation) could fit, but personally this syntax makes me sad.

```rip
# User defined in previous example
user = User(
  name: :Sam,
  birthday: 2000-01-01,
  color: :chartreuse
)
```

What are the downsides of named parameters, especially as it relates to Rip's function syntax? I don't have a ton of exerience working with languages that have structs, except for Ruby, and that don't quite count. By the way no matter what the solution is, I'm afraid commas will be required, even on multi-line source.
