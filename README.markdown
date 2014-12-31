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
* first-class types and lambdas (types and lambdas may be passed around and assigned to references/properties just like any other object)
* multiple inheritance (super types are flattened into a simple list of ancestors when a new type is defined)
* implicit returns from last statement in a block or module
* qualified imports via System.require (uses load path)
* exception handling
* pattern matching

## Getting Started

Rip is currently implemented as an interpreter written in [Ruby](http://www.ruby-lang.org/). Likely any recent version will due. Eventually Rip will be implemented as a front-end for [LLVM](http://llvm.org/) (implemented in itself).

### Quick start (users):

0. Download an appropriate prepackaged executable from the [release page](http://www.rip-lang.org/downloads).
   0. If a download isn't available for your platform, try following the contributer instructions below.
0. Extract the archive somewhere, like `~/bin/rip`.
0. The `rip` executable will be in `~/bin/rip`, so you'll want to add that directory to your `$PATH`.
0. `$ rip help`

### Quick start (contributers):

0. Install Ruby 2. I use [rbenv](https://github.com/sstephenson/rbenv) and [ruby-build](https://github.com/sstephenson/ruby-build), but use whatever floats your boat.
   0. Rip uses [Traveling Ruby](https://phusion.github.io/traveling-ruby/) to provide all-in-one packages, so you should install the version specified in `.ruby-version`.
0. `$ git clone git://github.com/rip-lang/rip.git`
0. `$ cd rip`
0. `$ bundle install`
0. `$ ./bin/rip help`

## Getting Help

If you find a bug or have any other issue, please open a [ticket](https://github.com/rip-lang/rip/issues). You should include as many details as reasonably possible, such as operating system, Ruby version (`ruby --version`), the Rip source code that broke et cetera.

## Contributing

Patches are most welcome! Please make changes in a feature branch that merges into master cleanly. Existing tests should not break, and new code needs new tests.

## Badges!

[![Code Climate GPA](http://img.shields.io/codeclimate/github/rip-lang/rip.svg?style=flat-square)](https://codeclimate.com/github/rip-lang/rip)
[![Coveralls Coverage Status](http://img.shields.io/coveralls/rip-lang/rip/master.svg?style=flat-square)](https://coveralls.io/r/rip-lang/rip)
[![Gemnasium Dependency Status](http://img.shields.io/gemnasium/rip-lang/rip.svg?style=flat-square)](https://gemnasium.com/rip-lang/rip)
[![Travis Build Status](http://img.shields.io/travis/rip-lang/rip/master.svg?style=flat-square)](https://travis-ci.org/rip-lang/rip)
[![MIT License](http://img.shields.io/badge/license-MIT-green.svg?style=flat-square)](http://opensource.org/licenses/MIT)
