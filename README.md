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
      .check{ [Array.random { Integer.random }, Array.random { Integer.random }] }
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
      .check{ [Array.random { Integer.random }, Array.random { Integer.random }] }
  end
end
```

When this specification is executed, the following error is reported.

    $ rake spec
    .F

    Failures:

      1) Array#| with two arrays x and y has length equal to x.length + y.length
         Failure/Error:
         expected: 4,
              got: 3 (using ==)
         after 25 successes
         with [[false, "!~w", false], [-187294205]]
         with srand 317419430220052582439642446331757152805

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

    p = Propr::Random.property("name"){|a,b| a + b == b + a }

You can invoke a property using `#check`. Like lambdas and procs, you can also
invoke them using `#call` or `#[]`.

    p.check(3, 4)     #=> true
    p.check("x", "y") #=> true

But you can also invoke them with a setup function that generates random
arguments.

    p.check{ [Integer.random, Float.random] } #=> true
    p.check{ [Array.random, Array.random] }   #=> true

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

## Generating Random Values

Propr defines a `random` constructor method on most standard Ruby types. Some
generators require some implicit state, so when generating data outside of the
body of `property { ... }` or the body of a `check { ... }` you must wrap the
code with `Propr::Random.generate { ... }`. For instance,

    Propr::Random.generate { Boolean.random }

### Boolean

    >> Boolean.random
    => true

### Numeric

#### Integer

Random integer between Integer::MIN and Integer::MAX

    >> Integer.random
    => -1830258881470840048

Random integer between 0 and 10

    >> Integer.prop(max: 0, min: 10)
    => 6

#### Float

Random float between -Float::MAX and Float::MAX

    >> Float.random
    => 1769470177.4186616

Random float between 0 and 10

    >> Float.random(min: 0, max: 10)
    => 8.47034059208399

#### Rational

    >> Rational.new(Integer.random, Integer.random)
    => (3419121051897208321/513829382835133827)

#### BigDecimal

    >> BigDecimal.random.to_s("F")
    => "7936297730318639394.320561703810327716036557741373593518621908133293211327"

    >> BigDecimal.random(min: 10, max: 20).to_s("F")
    => "14.934854011762374703280016489856414847259220844969789892"

#### Bignum

There's no constructor specifically for Bignum, but you can use `Integer.random`
and provide a large `min: n`. Ruby will automatically handle integer overflow by
coercing to Bignum.

#### Complex

    >> Complex(Integer.random(min:-10, max:10), Integer.random(min:-10, max:10))
    => (-2+1i)

    >> Complex(Float.random(min:-10, max:10), Float.random(min:-10, max:10))
    => (9.806161068637833+7.523520738439842i)

### Character

    >> String.random(min: 1, max: 1)
    => "2"

### Date

    => Date.random
    >> #<Date: 3388-04-30 (5917243/2,0,2299161)>

    => Date.random(min: Date.today - 10, max: Date.today + 10).to_s
    >> "2012-03-01"

### Time

    => Time.random
    >> 3099-12-23 20:00:53 -0600

    => Time.random(min: Time.now, max: Time.now + 3600)
    => 2012-02-20 13:47:57 -0600

### String

    >> String.random
    => " BW05a"

    >> String.random(min: 2, max: 4)
    => "b`R{"

Create a string matching the given character class

    >> String.random(charset: :alnum)
    => "dX8PzV"

    >> String.random(charset: :alpha)
    => "yaTCXP"

    >> String.random(charset: :blank)
    => " \t  \t\t"

    >> String.random(charset: :cntrl)
    => "\x00\x0F\x04\x12\x1C\x02"

    >> String.random(charset: :digit)
    => "500961"

    >> String.random(charset: :graph)
    => "i;NAb!"

    >> String.random(charset: :lower)
    => "llrqzi"

    >> String.random(charset: :print)
    => ":zER**"

    >> String.random(charset: :punct)
    => "=&{%_("

    >> String.random(charset: :space)
    => " \f\t\n\v\r"

    >> String.random(charset: :upper)
    => "TSLVVO"

    >> String.random(charset: :xdigit)
    => "54fEe7"

    >> String.random(charset: :ascii)
    => "zS9l.@"

    >> String.random(charset: :any)
    => "\nx\xC0\xE1\xB3\x86"

    >> String.random(charset: /[w-z]/)
    => "wxxzwwx"

### Array

Create a 4-element array of 4-character strings

    >> Array.random(min:4, max:4) { String.random(min:4, max:4) }
    => ["2n #", "UZ1d", "0vF,", "cV_{"]

### Hash

    TODO

## Guards

Many properties have some kind of precondition, like the property holds
for all even numbers, but we're not interested on checking the property
on odd numbers. We can specify these quickly using `guard`:

The `guard` method throws an exception if the condition isn't satisfied,
and normally the caller knows to retry sum fixed number of times before
finally giving up.

    >> guard(111, &:even?)
    Propr::GuardFailure
      from ...
      from ...

    >> guard(false)
    Propr::GuardFailure
      from ...
      from ...

If the property holds, the original value is simply returned.

    >> guard(112, &:even?)
    => 112

    >> guard(0 < 10)
    => true

## More Reading

* [Presentation at KC Ruby Meetup Group](https://github.com/kputnam/presentations/raw/master/Property-Based-Testing.pdf)

## Related Projects

* [Rantly](https://github.com/hayeah/rantly)
* [PropER](https://github.com/manopapad/proper)
* [QuviQ](http://www.quviq.com/documents/QuviqFlyer.pdf)
* [QuickCheck](http://www.haskell.org/haskellwiki/Introduction_to_QuickCheck)
