---
title: CLI API
---

No arguments starts a REPL like Ruby's pry:

```shell
rip
```

Start a REPL explicitly:

```shell
rip repl
```

Pass a file to compile and execute it immediately:

```shell
rip file.rip
```

Read from standard in to compile and execute immediately:

```shell
rip -
```

The compiler include various tools to inspect the code in different forms:

```shell
rip compile file.rip
```

Format a single file:

```shell
rip format file.rip
```

Format the current directory recursively while skipping (git) ignored files:

```shell
rip format .
```
