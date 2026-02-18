# Rip

## Overview

A new programming language emphasizing developer ergonomics, consistency and correctness.

## Prior Art And Inspiration

- Ruby
- C#
- TypeScript/JavaScript
- Elixir
- Haskell
- Crystal
- React

## Notable Features

- robust type system with generics and algebraic data types
- compiles to LLVM IR, then to WASM and native code
- everything is an expression/value
- all values are immutable
- binary operators are actually syntax sugar for method invocation (`a + b` is the same as `a.+(b)`)
    - some operators exist, but there aren't many
    - binary "operators" must be surrounded by whitespace to distinguish them from identifiers
- literal syntax for range, date, time, datetime, sql, xml and more

## CLI API

```shell
# no arguments starts a REPL like Ruby's pry
rip

# start REPL explicitly
rip repl

# pass a file to compile and execute it immediately
rip file.rip

# read from standard in to compile and execute immediately
rip -

# the compiler include various tools to inspect the code in different forms
rip compile file.rip

# format file
rip format file.rip

# format current directory recursively while skipping ignored files
rip format .
```

## Literal Expressions

Comments start with an octothorpe and continue to the end of line.

```rip
# this is a comment
```

### Numbers

```rip
# rational number with infinite precision
42

# decimals are also just rational numbers (not floating point!)
3.14159

# numbers may be written with underscores to separate groups of digits
1_234_567_890

# irrational numbers lazily generate as many digits as needed. this needs some work
```

Numbers may optionally be prefixed with a positive or negative sign.

### List

List are expressions surrounded by square brackets and separated by commas. They represent collections of things.

```rip
[1, 2, 3]
```

### Grapheme

Grapheme clusters are normalized as the file is compiled. They represent single Unicode characters. Not all valid grapheme clusters may be used in grapheme literals; only digits and characters allowed in references (below) may be used.

```rip
`g
```

### String

Strings are specialized lists of grapheme clusters. They have three different literal syntaxes: symbol, double-quote, HEREDOC.

Symbolic strings (symbols) are a colon followed by any number of grapheme clusters than may be used for grapheme literals. Symbols are primarily used in source code as hash keys for instance.

```rip
:symbol-string
```

Double quoted strings ("normal" strings) are any number of grapheme clusters (even zero!) surrounded by double quotes. An expression can be interpolated into a string with `#{...}`. Interpolation is just syntax sugar for concatenation.

```rip
"hello world"

"the answer is #{answer}"
```

Double quote strings are great for single lines of text. Use a HEREDOC string for multiple lines.

```rip
<<HERE_DOC
multiple
lines
HERE_DOC

foo(<<POEM).some-method()
here docs are useful
for writing multi-line strings
and also haiku
POEM
```

Some notes about HEREDOCs:

- HEREDOCs can be interpolated like double quoted strings.
- The leading whitespace on each line is trimmed during parsing to line up with the start of line with the opening terminator. This allows the HEREDOC to be indented. All additional whitespace is preserved. (Similar to the way Kotlin's `trimIndent()` works, but without needing to call an extra method.)
- Content starts on the line after the opening terminator.
- Method chaining on a HEREDOC is allowed on the same line as the opening terminator, along with any closing parenthesis. (This is essentially the same as Ruby's HEREDOC syntax, where additional methods may be chained off the leading terminator.)
- The closing terminator _must_ be the only thing on the line, other than indentation whitespace.

### Regular Expression

Regular expressions (regex) are patterns surrounded by forward slashes. They can also be interpolated.

```rip
/pattern/
```

### Reference

Similar to other languages, references (or identifiers) must not start with a digit and must not contain any whitespace. Unlike most other languages, references are allowed to contain most other printable characters and do not need to contain letters at all. References are case sensitive.

```rip
foo
dashes-or_underscores_for-readability
```

Some special references are automatically defined and are globally available.

```rip
System
true
false
```

You can associate a value with a reference with the assignment operator (`=`).

```rip
answer = 42
name = :Fred
```

### Hash

A hash is a collection of key-value pairs surround by curly braces, and separated by a comma. Keys are strings, typically written as a symbol. Values can be any expression. Keys and values are separated by a colon.

```rip
{ :answer: 42, "another key": :hello }
```

### Date, Time, DateTime

Rip has a literal syntax for Date, Time and DateTime objects. A subset of ISO8601 is supported. All dates and times are taken to be in UTC, regardless of the system timezone, unless a timezone is specified.

```rip
2026-01-01

12:34

# NOTE includes a timezone offset
2026-01-01T12:34:00-0400
```

### Range

Ranges are a concise way to represent a large collection. They are evaluated on-demand and otherwise behave like lists.

```rip
21..42

`a..`z
```

### SQL (PLANNED)

This is heavily inspired by C#'s linq and should be able to query arbitrary collections.

```rip
FROM users AS u
WHERE id = "42"
SELECT u.name, u.dob
```

### XML Fragment

```rip
<foo>
  <bar answer={42} />
</foo>
```

## Units

```rip
42cm

# TODO work out a way for units to relate to one another, including custom units developers create
# F# style doesn't work because `inch` would be value
inch = 2.54cm
```

## Blocks

Blocks are marked by curly brackets. They are used for control flow and
function bodies. When a block is executed the final expression is returned as
the block's value. All blocks are considered expressions and evaluate to values, therefore blocks are assignable to references.

### If/Else

If the condition is true, the first block is executed and
returned. Otherwise the `else` block is. An `else` block is required except in
the case of an early return where the compiler can determine the current scope is guaranteed to produce a value further down.

```rip
if (condition) {
  # condition is true
} else {
  # condition is false
}
```

### Switch

The expression is compared with each `when` parameter from top
to bottom. Note that cases do _not_ "fall through" as in some languages! The block associated with the first matching case is executed
and the value is returned. Conceptually all `if`/`else` blocks could be replaced with a `switch` block with a single `when (true)` and an `else`.

```rip
switch (expression) {
  when (:one) {
  }

  when (:two) {
  }

  when (:three) {
  }

  else {
    # else is optional if all branches are exhaustive
  }
}
```

### Pattern Matching

The `expression` is examined and potentiall destructured according to each `when`'s `pattern`. The first matching `when` block is executed and the value is returned. Conceptually all `switch` blocks could be replaced with equivalent `match` blocks.

```rip
match (expression) {
  when (pattern) {
  }

  when (pattern) {
  }

  when (pattern) {
  }

  else {
    # else is optional if all branches are exhaustive for the given expression
  }
}
```

## Functions

```rip
# a function with no arguments. it returns a special number
foo = -> () { return 42 }

# call a function by referencing it and passing any arguments with parenthesis.
# arguments are expressions separated by commas
foo()

# functions can take parameters separated by commas
bar = -> (a, b) { return a + b }

# parameters are optional if a default is provided
baz = -> (a = 1, b = 2) { return a + b }

# returns 3
bar()

# returns 5
bar(3)

# functions bodies are demarcated by curly braces. the return keyword is
# optional, and the final expression will be returned when the function
# is called

# functions can be passed to and returned from other functions
make-foo = -> (get-answer) {
  -> () {
    get-answer()
  }
}

# function arguments are automatically curried if enough required arguments
# aren't given
contrived-greeting = -> (name1, name2) {
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

### Function Overloads

Functions may be overloaded with multiple implementations. Optional parameters
is syntactical sugar for this, where each optional parameter synthesizes an
overload for the function. Functions are defined with the `->` (dash
rocket) keyword.

```rip
overloaded_function = -> (a, b = 10) { a + b }
```

Which compiles to the following example. `self` is a special reference that
refers to the entire overloaded function. Overloaded functions are grouped and
defined with the `=>` keyword followed by a block containing all overloads.

```rip
overloaded_function = => {
  -> (a) { self(a, 10) }
  -> (a, b) { a + b }
}
```

Below are three implementations for calculating `n!`. They show the conceptual transformations a function (technically an overload) goes through during compilation.

The first version is the idomatic code a developer might actually write:

```rip
factorial = -> (n, accumulator = 1) {
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
  -> (n, accumulator = 1) {
    if (n == 0) {
      accumulator
    } else {
      self(n - 1, n * accumulator)
    }
  }
}
```

The compiler also eliminates any optional parameters by synthesizing missing overloads that call the function recursively. Of course developer could write each overload out by hand, but it's usually better to just let the compiler handle it.

```rip
factorial = => {
  -> (n) {
    self(n, 1)
  }

  -> (n, accumulator) {
    if (n == 0) {
      accumulator
    } else {
      self(n - 1, n * accumulator)
    }
  }
}
```

## Structures

Structures are used to build complex data structures. Structures can also define
property methods that have access to the structure.

```rip
User = struct (name, age) {
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

## Module Import/Export

A program can be divided up into multiple modules, which typically map 1:1 with
files. Each module may provide any number of named exports with the `export`
keyword. Imported modules are specified as URLs with strings, and the file
extension doesn't matter.

```rip
# a.rip

question = "What is the meaning of everything?"

export question

export answer = 42
```

Other modules can import these references and use them. Multiple references may
be imported by separating each with commas.

```rip
# b.rip

from "./b.rip" import { answer, question }
```

Instead of listing every reference to import, all references can be imported into a namespace by specifying a single identifier. This namespace identifier is arbitrary and may vary by importing module.

```rip
# c.rip

from "./b.rip" import b
```

When importing as a namespace, the individual members are accessed with the
dot operator.

```rip
# d.rip

from "./b.rip" import b

b.question

export b.answer
```

### Other Module Formats (PLANNED)

The imported module format is assumed to be Rip. Other types of modules may be
imported using the `with` keyword followed by a hash specifying the type. The only restriction is the type must be registered first, though these (and others) may eventually be built-in. Non-Rip imports will likely only support namespaces.

```rip
from "./blog.md" import blog-post with { :type: :markdown }
from "./config.toml" import config with { :type: :toml }
from "./data.csv" import data with { :headers: true, :type: :csv }
from "./data.json" import data with { :type: :json }
from "./data.yml" import data with { :type: :yaml }
from "./index.css" import home-page with { :type: :html }
from "./profile.webp" import avatar with { :type: :webp }
from "./query.sql" import query with { :dialect: :postgres, :type: :sql }
from "./styles.css" import styles with { :type: :css }
```

### Dynamic Imports (PLANNED)

Most imports will be statically known, but it would be nice to support dynamically building the import URL. Such dynamic imports are planned.
