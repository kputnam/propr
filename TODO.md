Priorities

1. Write unit tests
2. Write property tests
3. Write example properties and subclasses (markup)
4. API documentation
5. User documentation
6. Optimization (drop Ruby 1.8)
7. Publish as rubygem
8. Update Stupidedi

Specifics

* Organization of common properties

```ruby
module ShrinkSpecs
  def self
    # must hold for all implementations
    property("no value is smaller than itself"){|x| not x.shrink.member?(x) }
  end
end

describe String, "#shrink" do
  # property holds for all implementations
  ShrinkSpecs.self
    .check { String.random ... }

  # property of the String#shrink implementation
  property("empty"){|s| s.shrink.member?("") }
    .check { String.random ... }

  # property of the String#shrink implementation
  property("shorter"){|s| s.shrink.all?{|x| x.length < s.length }}
    .check { String.random ... }
end

describe Integer, "#shrink" do
  # property holds for all implementations
  ShrinkSpecs.self
    .check { Integer.random ... }

  # property of the Integer#shrink implementation
  property("smaller"){|n| n.shrink.all?{|m| m.abs < n.abs }}
    .check { Integer.random ... }
end
```

* Stateful random generation
  * <del>Re-consider sized values (magntitude, center) or range?</del>
  * <del>Re-implement sized values</del>
* Steal `collect` and `classify` from QuickCheck

```ruby
property("foo") { ... }
  .check{|rand| rand.integer.tap{|n| classify(n < 0, "negative") }
                            .tap{|n| classify(n > 0, "positive") }}

property("bar") { ... }
  check{|rand| rand.array.tap{|xs| collect xs.length }}
```

* <del>Shrink input with breadth first</del>
* See also: smallcheck, deepcheck
