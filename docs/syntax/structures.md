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
