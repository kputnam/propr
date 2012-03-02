## Introduction

The usual approach to testing software is to describe a set of test inputs
and their corresponding expected outputs. The program is run with these
inputs and the actual outputs are compared with the expected outputs to
ensure the program behaves as expected. This methodology is simple to
implement and automate, but suffers from problems like:

* Writing test cases is tedious.
* Non-obvious edge cases aren't tested.
* Code coverage tools alone don't provide much assurance.

Property-based testing is an alternative, and complementary, approach in
which the general relationships between program inputs and desired output
are expressed, rather than enumerating particular inputs and outputs. The
properties specify things like, "assuming the program is correct, when its
run with any valid inputs, the inputs and the program output are related by
`f(input, output)`". The test framework produces random (valid) inputs,
searching for a counterexample.

## Examples

The following example demonstrates testing a property with a specific input,
then generalizing the test for any input.

```ruby
describe Array do
  include Propr::Rspec

  describe "#+" do
    # Traditional unit test
    it "sums lengths" do
      xs = [100, 200, 300]
      ys = [500, 200]
      (xs + ys).length.should == xs.length + ys.length
    end

    # Property-based test
    property("sums lengths"){|xs, ys| (xs + ys).length == xs.length + ys.length }
      .check([100, 200, 300], [500, 200])
      .check{ sequence [Array.random { Integer.random }, Array.random { Integer.random }] }
  end
end
```

The following example is similar, but contains an error that might not
be revealed by hand-written test cases.

```ruby
describe Array do
  include Propr::Rspec

  describe "#|" do
    # Traditional unit test
    it "sums lengths" do
      xs = [100, 200, 300]
      ys = [500, 200]
      (xs | ys).length.should == xs.length + ys.length
    end

    # Property-based test
    property("sums lengths"){|xs, ys| (xs | ys).length == xs.length + ys.length }
      .check([100, 200, 300], [500, 200])
      .check{ sequence [Array.random { Integer.random }, Array.random { Integer.random }] }
  end
end
```

When this specification is executed, the following error is reported.

    $ rake spec
    .F

    Failures:

      1) Array#| with two arrays x and y has length equal to x.length + y.length
         Propr::Falsifiable:
           input: [[224, -11, 62], [84, 241, -11]]
           after: 307 passed, 0 skipped

    Finished in 0.02185 seconds
    2 examples, 1 failure

You may have figured out the error is that `|` removes duplicate elements
from the result. We might not have caught the mistake by writing individual
test cases. The output indicates Propr generated 25 sets of input before
finding one that failed.

Now that a failing test case has been identified, you might write another
`check` with those specific inputs to prevent regressions. You could also
call `srand 317419430220052582439642446331757152805` like this to regenerate
the same inputs for the entire test suite:

    RSpec.configure do |config|
      srand 317419430220052582439642446331757152805
    end

## Just Plain Functions

Properties are basically just functions, they should return `true` or `false`.

    p = Propr::Property.new("name", lambda{|a,b| a + b == b + a })

You can invoke a property using `#check`. Like lambdas and procs, you can also
invoke them using `#call` or `#[]`.

    p.check(3, 4)     #=> true
    p.check("x", "y") #=> true

But you can also invoke them with a setup function that generates random
arguments.

    p.check { Propr::Random.eval(sequence [Integer.random, Float.random]) } #=> true
    p.check { Propr::Random.eval(sequence [Array.random, Array.random]) }   #=> true

When invoked with a block, `check` will run `p` with 100 random inputs by
default, but you can also pass an argument to `check` indicating how many
examples `p` should be tested against.

## Using Propr + Test Frameworks

Mixing in a module magically defines the `property` singleton method, so
you can use it to generate test cases.

```ruby
describe "foo" do
  include Propr::RSpec

  # This defines three test cases, one per each `check`
  property("length"){|a| a.length >= 0 }
    check("abc").
    check("xyz").
    check{ String.random }
end
```

Note your property should still return `true` or `false`. You can avoid some
clutter by *not* using `#should` or `#assert`, because the test generator
will generate the assertion for you.

### Property DSL

The code block inside `property { ... }` has an extended scope that defines
a few helpful methods:

* Skip this iteration unless all the given conditions are met. This can be used,
  for instance, to define a property only on even integers.  
  `property{|x| guard(x.even?); x & 1 == 0 }`

* True if the code block throws an exception of the given type.  
  `property{|x| error? { x / 0 }}`

* Short alias for `Propr::Random`, used to generate random data as described
  below.  
  `property{|x| m.eval(m.sequence([m.unit 0] * x)).length == x }`

### Check DSL

The code block inside `check { ... }` should return a generator value. The code
block's scope is extended with a few combinators to compose generators.

* Create a generator that returns the given value. For instance, to yield `3` as
  an argument to the property,  
  `check { unit(3) }`

* Chain the value yielded by one generator into another. For instance, to yield
  two integers as arguments to a property,  
  `check { bind(Integer.random){|a| bind(Integer.random){|b| unit([a,b]) }}}`

* Short-circuit the chain if the given condition is false. The entire chain will
  be re-run until the guard passes. For instance, to generate two distinct numbers,  
  `check { bind(Integer.random){|a| bind(Integer.random){|b| guard(a != b){ unit([a,b]) }}}}`

* Remove one level of generator nesting. If you have a generator `x` that yields a
  number generator, then `join x` is a string generator. For instance, to yield
  either a number or a string,  
  `check { join([Integer.random, String.random]) }`

* Convert a list of generator values to a generator of a list of values. For
  instance, to yield three integers to a property,  
  `check { sequence [Integer.property]*3 }`

## Generating Random Values

Propr defines a `random` method on most standard Ruby types that returns a
generator. You can run the generator using the `eval` method.

    >> m = Propr::Random
    => ...
    
    >> m.eval(Boolean.random)
    => false
    
Note that the second parameter is a `scale` value between `0` and `1` that
is used to exponentially scale the domain of generators that have `min` and
`max` parameters.

### Boolean

    >> m.eval Boolean.random
    => true


### Date

Options
* `min:` minimum value, defaults to 0001-01-01
* `max:` maximum value, defaults to 9999-12-31
* `center:` defaults to the midpoint between min and max

    >> m.eval(Date.random(min: Date.today - 10, max: Date.today + 10)).to_s
    => "2012-03-01"

### Time

Options
* `min:` minimum value, defaults to 1000-01-01 00:00:00 UTC
* `max:` maximum value, defaults to 9999-12-31 12:59:59 UTC
* `center:` defaults to the midpoint between min and max

    >> m.eval Time.random(min: Time.now, max: Time.now + 3600)
    => 2012-02-20 13:47:57 -0600

### String

Options
* `min:` minimum size, defaults to 0
* `max:` maximum size, defaults to 10
* `center:` defaults to the midpoint between min and max
* `charset:` regular expression character class, defaults to /[[:print]]/

    >> m.eval String.random(min: 5, max: 10, charset: :lower)
    => "rqyhw"

### Numbers

#### Integer

Options
* `min:` minimum value, defaults to Integer::MIN
* `max:` maximum value, defaults to Integer::MAX
* `center:` defaults to the midpoint between min and max.

    >> m.eval Integer.random(min: -500, max: 500)
    => -382

#### Float

Options
* `min:` minimum value, defaults to -Float::MAX
* `max:` maximum value, defaults to Float::MAX
* `center:` defaults to the midpoint between min and max.

    >> m.eval Float.random(min: -500, max: 500)
    => 48.252030464134364

#### Rational

Not implemented, as there isn't a nice way to ensure a `min` works. Instead,
generate two numeric values and combine them:

    >> m.eval m.bind(Integer.random){|a| m.bind(Integer.random){|b| unit Rational(a,b) }}
    => (3419121051897208321/513829382835133827)

#### BigDecimal

Options
* `min:` minimum value, defaults to -Float::MAX
* `max:` maximum value, defaults to Float::MAX
* `center:` defaults to the midpoint between min and max

    >> m.eval(BigDecimal.random(min: 10, max: 20)).to_s("F")
    => "14.934854011762374703280016489856414847259220844969789892"

#### Bignum

There's no constructor specifically for Bignum. You can use `Integer.random`
and specify `min: Integer::MAX + 1` and some larger `max` value. Ruby will
automatically handle Integer overflow by coercing to Bignum.

#### Complex

Not implemented, as there's no simple way to implement min and max, nor the types
of the components. Instead, generate two numeric values and combine them:

    >> m.eval(m.bind(m.sequence [Float.random(min:-10, max:10)]*2){|a,b| m.unit Complex(a,b) })
    => (9.806161068637833+7.523520738439842i)

### Collections

#### Array

Expects a block parameter that yields a generator for elements.

Options
* `min:` minimum size, defaults to 0
* `max:` maximum size, defaults to 10
* `center:` defaults to the midpoint between min and max

    >> m.eval Array.random(min:4, max:4) { String.random(min:4, max:4) }
    => ["2n #", "UZ1d", "0vF,", "cV_{"]

#### Hash

Expects a block parameter that yields generator of [key, value] pairs.

Options
* `min:` minimum size, defaults to 0
* `max:` maximum size, defaults to 10
* `center:` defaults to the midpoint between min and max

    >> m.eval Hash.random(min:2, max:4) { m.sequence [Integer.random, m.unit(nil)] }
    => {564854752=>nil, -1065292239=>nil, 830081146=>nil}

#### Set

Expects a block parameter that yields a generator for elements.

Options
* `min:` minimum size, defaults to 0
* `max:` maximum size, defaults to 10
* `center:` defaults to the midpoint between min and max

    >> m.eval Set.random(min:4, max:4) { String.random(min:4, max:4) }
    => #<Set: {"2n #", "UZ1d", "0vF,", "cV_{"}>

### Range

Expects _either_ a block parameter or one or both of min and max.

Options
* `min:` minimum element
* `max:` maximum element
* `inclusive?:` defaults to true, meaning Range includes max element

    >> m.eval Range.random(min: 0, max: 100)
    => 81..58

    >> m.eval Range.random { Integer.random(min: 0, max: 100) }
    => 9..80

### Elements from a collection

The `#random` instance method is defined on the above types. It takes no parameters.

    >> m.eval [1,2,3,4,5].random
    => 4
    
    >> m.eval({a: 1, b: 2, c: 3, d: 4}.random)
    => [:b, 2]
    
    >> m.eval (0..100).random
    => 12
    
    >> m.eval Set.new([1,2,3,4]).random
    => 4

## More Reading

* [Presentation at KC Ruby Meetup Group](https://github.com/kputnam/presentations/raw/master/Property-Based-Testing.pdf)

## Related Projects

* [Rantly](https://github.com/hayeah/rantly)
* [PropER](https://github.com/manopapad/proper)
* [QuviQ](http://www.quviq.com/documents/QuviqFlyer.pdf)
* [QuickCheck](http://www.haskell.org/haskellwiki/Introduction_to_QuickCheck)
