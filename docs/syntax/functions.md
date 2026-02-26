# Functions

Here is a function with no parameters. It returns a special number.

```rip
foo = -> () { return 42 }
```

Call a function by referencing it and passing any arguments with parenthesis. Arguments are expressions separated by commas.

```rip
foo()
```

Functions can take parameters separated by commas.

```rip
bar = -> (a: Integer, b: Integer) { return a + b }

# parameters are optional if a default is provided
baz = -> (a: Integer = 1, b: Integer = 2) { return a + b }

# returns 3
bar()

# returns 5
bar(3)
```

Functions bodies are demarcated by curly braces. The return keyword is optional, and the final expression will be returned when the function is called.

```rip
# functions can be passed to and returned from other functions
make-foo = -> (get-answer: () -> Integer) {
  -> () {
    get-answer()
  }
}

foo = make-foo(-> () { 42 })

foo()
# => 42
```

Function arguments are automatically curried if enough arguments aren't given to satisfy all required parameters.

```rip
contrived-greeting = -> (name1: String, name2: String) {
  "Hello #{name1} and #{name2}!"
}

# the following are both equivelant function call expressions
contrived-greeting(:Sam, :Jane)
contrived-greeting(:Sam)(:Jane)

# this means that silly things like calling a function with required parameters
# without any arguments are possible. the call just returns a new function with
# the same required/optional parameters
contrived-greeting()(:Sam)()(:Jane)
```

## Function Overloads

Functions may be overloaded with multiple implementations. Optional parameters is syntactical sugar for this, where each optional parameter synthesizes an overload for the function. Functions are defined with the `=>` (fat rocket) keyword.

```rip
# parameter b type is inferred as Integer because it has a default
overloaded_function = -> (a: Integer, b = 10) { a + b }
```

Which compiles to the following example. `self` is a special reference that refers to the entire overloaded function. Overloaded functions are grouped and defined with the `=>` keyword followed by a block containing all overloads.

```rip
overloaded_function = => {
  -> (a: Integer) { self(a, 10) }
  -> (a: Integer, b: Integer) { a + b }
}
```

Below are three implementations for calculating `n!`. They show the conceptual transformations a function (technically an overload) goes through during compilation.

The first version is the idomatic code a developer might actually write:

```rip
factorial = -> (n: Integer, accumulator = 1) {
  if (n == 0) {
    accumulator
  } else {
    self(n - 1, n * accumulator)
  }
}
```

During compilation the compiler wraps any "naked" overloads with function:

```rip
factorial = => {
  -> (n: Integer, accumulator = 1) {
    if (n == 0) {
      accumulator
    } else {
      self(n - 1, n * accumulator)
    }
  }
}
```

The compiler also eliminates any optional parameters by synthesizing missing overloads that call the function recursively. Of course a developer could write each overload out by hand, but it's usually better to just let the compiler handle it.

```rip
factorial = => {
  -> (n: Integer) {
    self(n, 1)
  }

  -> (n: Integer, accumulator: Integer) {
    if (n == 0) {
      accumulator
    } else {
      self(n - 1, n * accumulator)
    }
  }
}
```
