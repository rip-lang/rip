## What is Rip

Rip is a general purpose programming language. It is a functional language with an object-oriented syntax. All objects are immutable, so it might help to think of objects as collections of partially-applied functions.

## Development Status

In progress. Use at your own risk. **Nothing works yet!**

## License

Rip is released under the MIT license. Please see LICENSE.markdown for more details.

## (Planned) Features

* no globals (except for a short list of pre-defined references)
* robust object literal syntax for many constructs, including date/time and unit values
* lexical scoping
* type inference
* static name resolution
* tail call optimization
* lazy iteration
* first-class classes and lambdas (classes and lambdas may be passed around and assigned to references just like any other object)
* multiple inheritence
* implicit returns from last statement in a block or module
* qualified imports via System.require (uses load path)
* exception handling

## Getting Started

Rip is implemented as a front-end for [LLVM](http://llvm.org/). The compiler is written in [Ruby](http://www.ruby-lang.org/). You will need both installed.

Quick start:

0. Install Ruby 2. I use [rbenv](https://github.com/sstephenson/rbenv) and [ruby-build](https://github.com/sstephenson/ruby-build), but use whatever floats your boat.
0. `$ git clone git://github.com/rip-lang/rip.git`
0. `$ cd rip`
0. `$ bundle install`
0. `$ ./bin/rip help`

## Getting Help

If you find a bug or have any other issue, please open a [ticket](https://github.com/rip-lang/rip/issues). You should include as many details as reasonably possible, such as operating system, Ruby version (`ruby --version`), LLVM version (`llvm-gcc --version`).

## Contributing

Patches are most welcome! Please make changes in a feature branch that merges into master cleanly. Existing tests should not break, and new code needs new tests.

## Code Status

[![Build Status](https://travis-ci.org/rip-lang/rip.png)](https://travis-ci.org/rip-lang/rip)
[![Dependency Status](https://gemnasium.com/rip-lang/rip.png)](https://gemnasium.com/rip-lang/rip)
