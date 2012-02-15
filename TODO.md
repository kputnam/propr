Priorities

1. Write unit tests
2. Write property tests
3. Write example properties and subclasses (markup)
4. API documentation
5. User documentation
6. Optimization (drop Ruby 1.8)
6. Publish as rubygem
7. Update Stupidedi

Specifics

* Re-implement guards
* Re-consider sized values (magntitude,center) or range?
* Re-implement sized values (array, string, hash)
* Steal `collect` and `classify` from QuickCheck

    property("foo") { ... }
      .check{|rand| rand.integer.tap{|n| classify(n < 0, "negative") }
                                .tap{|n| classify(n > 0, "positive") }}

    property("bar") { ... }
      check{|rand| rand.array.tap{|xs| collect xs.length }}

* Shrink input with alt. algorithms: hill climbing, breadth first
* See also: smallcheck, deepcheck
