## PLANNED FEATURES
* lazy evaluation
* tail call optimization
* immutable variables by default (minimal side effects)
* first-class classes and lambdas (classes and lambdas may be passed around just like any other object)
* multiple inheritence
* last statement in any block or file is implicitly returned
* variable variables
* multiple assignment
* qualified imports via Kernel.require (uses load path)
* warn on variable reassignment
* no built-in operator precedence (use parenthesis to specify precedence)

## KEYWORDS
* class - define a class
* lambda, λ - define a function or method
* public, protected, private - visibility (default is public)
* if, unless, elseif, else, switch, case - branching (if and unless may be used post-fix)
* for, in, while, until - looping (while and until may be used post-fix)
* throw, try, catch, finally - exception handling
* next, break - used in switches and loops for flow control (consider making these lambdas on switches and loops)
* return - exit a block without executing the remaining statements (consider making this a property on lambdas) also return value for required files

## SPECIAL VARIABLES
* base - refers to a parent class's implementation of a lambda
* self - refers to the current receiver and is usually implied (inside a lambda, self refers to the lambda; inside a class, self refers to the class)
* scope - refers to the class or lambda that encloses the current self
* receiver - refers to the object the is currently receiving the currently-executing message (lambda)
* true, false, nil - pre-defined instances of classes True, False, Nil respectively

## OTHER
* comments start with # and continue to the end of the line
* names are strings of any valid unicode character except whitespaces not starting with a digit
* namespaces can be created by nesting classes
* subclasses and lambdas are accessed with a period
* subclasses may re-implement base class members
* operators are implemented as regular lambdas
* lambda and λ are exactly the same; both specify a block of code with an optional name
* λ is meant as a shortcut for anonymous blocks
* lambdas are invoked with ()


1. parse tree - generated from source code by parser generator (treetop)
   parse_tree = Treetop.load('input.rip').new
   ast = extract_ast(parse_tree)
2. abstract syntax tree - parse tree converted by calling :to_ast on parse tree recursively returned - this discards unnecessary nodes from the parse tree and normalizes remaning nodes (http://rubini.us/doc/en/bytecode-compiler/ast/)
   * #initialize(line, args) - called by various process_* methods in the previous stage
   * #bytecode(g) - called by the Generator in the next stage
   * #to_sexp - used to represent the AST node as a symbolic expression
3. create a generator object
4. pass generator to every :bytecode method in ast

  object
    simple_object
      nil
      boolean
        true
        false
      numeric
        decimal
        integer
      character
      string
        simple_string
          symbol_string
          single_quoted_string
          double_quoted_string
        here_doc
      regular_expression
      date
      time
      datetime
      version
    recursive_object
      hash
      key_value_pair
      list
      range
    structural_object
      class
      lambda
    name
