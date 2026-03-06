---
title: Strings
---

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
