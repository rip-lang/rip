---
title: Grapheme Clusters
sidebar: { order: 2 }
---

Grapheme clusters are normalized as the file is compiled. They represent single Unicode characters. Not all valid grapheme clusters may be used in grapheme literals; only digits and characters allowed in references (below) may be used. In practice this means that every valid grapheme cluster is allowed to be expressed as a grapheme literal _except_ any whitespace and a few special characters used for other syntax mechanisms.

```rip
`g
```

See [this Unicode technical report](https://www.unicode.org/reports/tr29/) for more information about grapheme normalization.
