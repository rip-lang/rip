```
         _            _          _
        /\ \         /\ \       /\ \
       /  \ \        \ \ \     /  \ \
      / /\ \ \       /\ \_\   / /\ \ \
     / / /\ \_\     / /\/_/  / / /\ \_\
    / / /_/ / /    / / /    / / /_/ / /
   / / /__\/ /    / / /    / / /__\/ /
  / / /_____/    / / /    / / /_____/
 / / /\ \ \  ___/ / /__  / / /
/ / /  \ \ \/\__\/_/___\/ / /
\/_/    \_\/\/_________/\/_/
```

## What is Rip

Rip is a new general purpose programming language emphasizing developer ergonomics, consistency and correctness.

## Development Status

In progress. Use at your own risk. **Nothing works yet!**

## License

Rip is released under the Apache 2.0 license. Please see LICENSE.txt for more details.

## (Planned) Features

- no globals (except for a short list of pre-defined references)
- robust object literal syntax for many constructs, including date/time and unit values
- lexical scoping
- structural typing
- type inference
- static name resolution
- tail call optimization
- lazy iteration
- first-class types and functions (types and functions may be passed around and assigned to references/properties just like anything else)
- implicit returns from last statement in a block
- exception handling
- pattern matching

## Getting Help

If you find a bug or have any other issue, please open a [ticket](https://github.com/rip-lang/rip/issues). You should include as many details as reasonably possible, such as your operating system and the Rip source code that broke et cetera.

## Contributing

Patches are most welcome! Please make changes in a feature branch that merges into `master` cleanly. Existing tests should not break, and new code needs new tests.
