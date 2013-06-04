## What is Rip

Rip is a general purpose programming language. It is a functional language with an object-oriented syntax. All objects are immutable, so it might help to think of objects as collections of partially-applied functions.

## Development Status

In progress. Use at your own risk. **Nothing works yet!**

## License

Rip is released under the MIT license. Please see LICENSE.markdown for more details.

## (Planned) Features

* no globals (except for a short list of pre-defined references)
* robust object literal syntax for many constructs, including date/time and unit values
* tail call optimization
* lazy iteration
* first-class classes and lambdas (classes and lambdas may be passed around and assigned to references just like any other object)
* multiple inheritence
* implicit returns from last statement in a block or module
* qualified imports via System.require (uses load path)
* exception handling

## Getting Started

Rip is implemented as a front-end for [LLVM](http://llvm.org/). The compiler is written in [Ruby](http://www.ruby-lang.org/). You will need both installed.

  $ git clone git://github.com/rip-lang/rip.git

## Getting Help

If you find a bug or have any other issue, please open a [ticket](https://github.com/rip-lang/rip/issues). You should include as many details as reasonably possible, such as operating system, Ruby version (`ruby --version`), LLVM version (`llvm-gcc --version`).

## Contributing

Patches are most welcome!
