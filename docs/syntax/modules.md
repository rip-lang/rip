# Module Import/Export

A program can be divided up into multiple modules, which typically map 1:1 with
files. Each module may provide any number of named exports with the `export`
keyword. Imported modules are specified as URLs with strings, and the file
extension doesn't matter.

```rip
# a.rip

question = "What is the meaning of everything?"

export question

export answer = 42
```

Other modules can import these references and use them. Multiple references may
be imported by separating each with commas.

```rip
# b.rip

from "./b.rip" import { answer, question }
```

Instead of listing every reference to import, all references can be imported into a namespace by specifying a single identifier. This namespace identifier is arbitrary and may vary by importing module.

```rip
# c.rip

from "./b.rip" import b
```

When importing as a namespace, the individual members are accessed with the
dot operator.

```rip
# d.rip

from "./b.rip" import b

b.question

export b.answer
```

## Other Module Formats (PLANNED)

The imported module format is assumed to be Rip. Other types of modules may be
imported using the `with` keyword followed by a hash specifying the type. The only restriction is the type must be registered first, though these (and others) may eventually be built-in. Non-Rip imports will likely only support namespaces.

```rip
from "./blog.md" import blog-post with { :type: :markdown }
from "./config.toml" import config with { :type: :toml }
from "./data.csv" import data with { :headers: true, :type: :csv }
from "./data.json" import data with { :type: :json }
from "./data.yml" import data with { :type: :yaml }
from "./index.css" import home-page with { :type: :html }
from "./profile.webp" import avatar with { :type: :webp }
from "./query.sql" import query with { :dialect: :postgres, :type: :sql }
from "./styles.css" import styles with { :type: :css }
```

## Dynamic Imports (PLANNED)

Most imports will be statically known, but it would be nice to support dynamically building the import URL. Such dynamic imports are planned.
