---
title: CLI API
---

No arguments starts a REPL like Ruby's pry:

```shell
rip
```

Start REPL explicitly:

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

Format file:

```shell
rip format file.rip
```

Format current directory recursively while skipping ignored files:

```shell
rip format .
```
