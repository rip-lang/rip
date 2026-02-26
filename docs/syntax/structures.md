# Structures

Structures are used to build complex data structures. Structures can also define property methods that have access to the structure.

```rip
User = struct (name: String, age: Integer) {
  # note the swerve rocket (`~>`) keyword
  @.greet = ~> {
    "Hello #{@.name}!"
  }
}

user = User.new(:Frank, 21)

user.name
# => "Frank"

user.age
# => 21

user.greet
# => "Hello Frank!"
```

Structures may be used as types.

```rip
Foo = struct (color: String) {}

get-color = -> (foo: Foo) {
  foo.color
}

get-color(Foo.new(:red))
# => :red
```

Structures have a prototype `@` which may be decorated with instance methods. These instance methods have access to the instance (`self` in other languages) through the bound prototype (`@`). Take a closer look at the `User` example above.

```rip
User = struct (name: String, age: Integer) {
  @.greet = ~> {
    "Hello #{@.name}!"
  }
}
```

`greet` is defined on the `User` prototype as a dynamic property. It is created with the swerve rocket keyword, and it cannot take parameters.

Other values can be assigned to the prototype, including functions.

```rip
Item = struct (sku: String, price: Rational) {
  @.+ = -> (other: Item) {
    @.price + other.price
  }
}
```

Structures may also have properties assigned directly to them.

```rip
Fruit = struct (color: String) {
  partition-by-color = -> (fruits: List<Fruit>) {
    fruits.reduce(-> (memo, fruit) {
      {
        ...memo,
        fruit.color: memo.key?(fruit.color)
          ? [...memo[fruit.color], fruit]
          : [fruit]
      }
    }, {})
  }
}
```
