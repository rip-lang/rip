---
title: Structures
---

Structures are used to build complex, typed data structures. Structures define fields on their prototype. A field may contain a value (including functions) or a computed expression.

## Basic Syntax

The `@` is the structure's prototype. Decorating it determines the shape of the structure and how it can be used. `@` refers to the structure's prototype during declaration and to the instance when accessed inside computed fields or methods.

```rip "@"
User = struct {
  @.name: String
  @.birthday: Date
}
```

## Instantiation

A structure needs to be instantiated to be used. This creates a new object that matches the type described by the structure's prototype. Call the `.new()` function on the structure to create an instance.

Every structure automatically defines a `.new()` function whose parameters correspond to the instance fields defined on the structure's prototype. Required fields (fields with no default value) become required parameters, and optional fields (fields with default values) become optional parameters. Computed fields are not converted to parameters at all. Fields are initialized in source order.

```rip ".new(" ")"
User = struct {
  @.name: String
  @.birthday: Date
}

user = User.new(name: :Frank, birthday: 2000-01-01)
```

Now you can read `user.name` to get the string `:Frank`.

## Optional Fields

Sometimes it makes sense to provide a default for a field. In this case the field type is inferred.

```rip {5} {10-11} {16} {19-20}
User = struct {
  @.name: String
  @.birthday: Date

  @.color = :orange
}

user = User.new(name: :Frank, birthday: 2000-01-01)

user.color
# => :orange

user2 = User.new(
  name: :Mary,
  birthday: 1991-03-14,
  color: :blue
)

user2.color
# => :blue
```

## Computed Fields

Structures can also define computed fields that have access to the rest of the structure. Create a computed field with the swerve rocket keyword (`~>`) followed by a body wrapped in curly braces (`{`/`}`).

```rip {7} "~>"
User = struct {
  @.first: String
  @.last: String

  @.color = :orange

  @.full-name = ~> { "#{@.first} #{@.last}" }
}

user = User.new(first: :Frank, last: :Smith)

user.full-name
# => "Frank Smith"
```

Notice that inside the computed field, `@` refers to the structure instance.

Computed fields behave like read-only functions. They are lazy-evaluated on first access and return value is cached for the life of the instance. They don't need parenthesis to be called. (Adding parenthesis would actually be an error unless the computed field evaluates to a function.)

## Function Fields

Functions may also be added as normal fields. They also have access to the instance via `@`. Otherwise they behave like ordinary functions. Such "instance functions" may be passed around, and overload and automatic currying work as they would with any other function.

```rip {10}
User = struct {
  @.first: String
  @.last: String
  @.birthday: Date

  @.color = :orange

  @.full-name = ~> { "#{@.first} #{@.last}" }

  @.oldest = -> (other: User) {
    if (other.birthday < @.birthday) {
      other
    } else {
      @
    }
  }
}

john = User.new(name: :John, birthday: 2000-01-01)
mary = User.new(name: :Mary, birthday: 1991-03-14)

john.oldest(mary)
# => mary
```

Functions are treated like regular fields.

## Splat

Structures may be splatted into function calls. This allows structures to act as argument bundles when their fields match the function's parameter names.

If a new instance is needed with only a small number of changes, another instance may be used with the splat operator (`*`).

```rip "*fred"
User = struct {
  @.first: String
  @.last: String
  @.birthday: Date

  @.color = :orange

  @.full-name = ~> { "#{@.first} #{@.last}" }
}

fred = User.new(
  first: :Fred,
  last: :Wesley,
  birthday: 2000-02-02,
  color: :red
)

george = User.new(*fred, first: :George, color: :green)
```

A structure instance may splat into another structure, as long as the types match.

```rip "Person" "User" "*fred"
Person = struct {
  @.full-name: String

  @.first = ~> { @.full-name.split(" ")[0] }
  @.last = ~> { @.full-name.split(" ")[1] }
}

User = struct {
  @.first: String
  @.last: String
  @.birthday: Date

  @.color = :orange

  @.full-name = ~> { "#{@.first} #{@.last}" }
}

fred = Person.new(full-name: "Fred Wesley" )

george = User.new(
  *fred,
  first: :Geore,
  birthday: 2000-02-02
)
```

Generally an instance `a` may splat into structure `B`'s initializer if `a`'s type is a sub-type of `B`. Computed fields may be used to splat into a compatible structure, but fields do not overwrite computed fields.

## Static Fields

Structures may have static fields. Static fields are not attached to the prototype, so they aren't accessed from any instance. Instead they are accessed directly from the structure.

```rip {4,7,12}
Error = struct {
  @.message: String

  code = Exact<42>
}

Error.code
# => Exact<42>

error = Error.new(message: "something broke")

error.code
# => compiler error
```

## Generic Fields

Structures and fields may be declared with generic types. Generic type parameters may be accessed inside the structure anywhere a regular type is allowed.

```rip {3} "TRole"
User = struct <TRole: Literal<:editor> | Literal<:admin>> {
  @.email: String
  @.role: TRole
}
```

See [Types](/syntax/types#27-generic-types) for more information about generics.
