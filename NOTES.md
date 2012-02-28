## Property DSL

Properties are basically just functions. They look like this:

    property{|a,b,c| ... }

Some features that are useful for defining properties include:

* `error?(ex) { ... }`
* `guard(cond)`
* `label(str)`

## Random DSL

* `guard(cond)`
* `scale(n, zero)`
* `rand(limit)`
