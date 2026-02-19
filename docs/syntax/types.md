# Types And Generics

Rip uses structural typing and heavily relies on type inference. We can declare free-standing types for use in function paramters with the `type` keyword.

Note that I'm not super-thrilled with the type syntax for describing a function. Also a syntax for inferring/reading the type of an expression is probably needed.

```rip
# any structure with a `color` member that is a `String` will satisfy Foo
Foo = type { color: String }

get-color = -> (thing: Foo) {
  thing.color
}
```

We can also define the type directly where it's used.

```rip
get-color = -> (thing: type { color: String }) {
  thing.color
}
```

Another way to make a new type is to combine other types.

```rip
# Custom is a String or a Number, but it isn't both
Custom = String | Integer

Foo = type { color: String }
Bar = type { shape: String }

# Baz is type { color: String, shape: String }
Baz = Foo & Bar
```

Types can also be generic. Think of it as similar to a function parameter, but at the type level.

```rip
# the exact type of ResultSet depends on the type passed to it
ResultSet = type <T> { count: Integer, data: List<T> }

ThingResultSet = ResultSet<type { name: String }>

OtherResultSet = ResultSet<type { country: String }>
```

Rip does it's best to properly infer the correct type based on usage, but sometimes this isn't enough.

```rip
date = Date.now

# structures are types. User is typed as type { name: String, birthday: Date }
User = struct (name: String, birthday: Date) {}

# infers return type is DateSpan
get-age = -> (now: Date, u: User) {
  now - u.birthday
}

# user is type { name: String, birthday: Date }
user = User.new(:Ginny, 2000-03-15)

ginny-age = get-age(date, user)

# Pet is typed as type { name: String, birthday: Date, species: String }
Pet = struct (name: String, birthday: Date, species: String) {}

# Pet isn't a User, but it overlaps with User, so it works
cat = Pet.new(:Socks, 2026-01-28, :cat)

socks-age = get-age(date, cat)
```
