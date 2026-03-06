---
title: CLI API
---

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
