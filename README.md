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
      xs = [100, "x", :zz]
      ys = [:ww, 200]
      (xs + ys).length.should == xs.length + ys.length
    end

    # Property-based test
    property("sums lengths"){|xs, ys| (xs + ys).length == xs.length + ys.length }
      .check([100, "x", :zz], [:ww, 200])
      .check{ [Array.propr, Array.propr] }
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
      xs = [100, "x", :zz]
      ys = [:ww, 200]
      (xs | ys).length.should == xs.length + ys.length
    end

    # Property-based test
    property("sums lengths"){|xs, ys| (xs | ys).length == xs.length + ys.length }
      .check([100, "x", :zz], [:ww, 200])
      .check{ [Array.propr, Array.propr] }
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
arguments. The setup function is passed an instance of `Propr::Random`.

    p.check{|rand| [Integer.propr, Float.propr] } #=> true
    p.check{|rand| [Array.propr, Array.propr] }   #=> true

When invoked with a block, `check` will run `p` with 100 random inputs by
default, but you can also pass an argument to `check` indicating how many
times `p` should be run.

## Using Propr + Test Frameworks

Mixing in a module magically defines the `property` singleton method, so
you can use it to generate test cases.

```ruby
class FooTest < Test::Unit::TestCase
  include Propr::TestUnit

  # This defines four test cases, one per each `check`
  property("length"){|a| a.length >= 0 }
    check("abc").
    check("xyz").
    check{ String.propr }.
end
```

Note your property should still return `true` or `false`. You can avoid some
clutter by *not* using `#should` or `#assert`, because the test generator
will generate the assertion for you.

This is just a convenience, though. You can call `Propr::Rspec.define` or
`Propr::TestUnit.define` to generate test cases, too.

    Propr::TestUnit.define(Propr::Random.property("length"){|a| a.length >= 0 }).
      check("abc").
      check("xyz").
      check{ String.propr }

## Generating Random Values

Propr defines a `propr` constructor method on most standard Ruby types.

### Boolean

    >> Boolean.propr
    => true

### Numeric

#### Integer

Random integer between Integer::MIN and Integer::MAX

    >> Integer.propr
    => -1830258881470840048

Random integer between 0 and 10

    >> Integer.prop(max: 0, min: 10)
    => 6

#### Float

Random float between -Float::MAX and Float::MAX

    >> Float.propr
    => 1769470177.4186616

Random float between 0 and 10

    >> Float.propr(min: 0, max: 10)
    => 8.47034059208399

#### Rational

    >> Rational.new(Integer.propr, Integer.propr)
    => (3419121051897208321/513829382835133827)

#### BigDecimal

    >> BigDecimal.propr.to_s("F")
    => "7936297730318639394.320561703810327716036557741373593518621908133293211327"

    >> BigDecimal.propr(min: 10, max: 20).to_s("F")
    => "14.934854011762374703280016489856414847259220844969789892"

#### Bignum

There's no constructor specifically for `Bignum`, but you can use `Integer.propr`
and provide a `min: n` larger than INTMAX.

#### Complex

    >> Complex(Integer.propr(min:-10, max:10), Integer.propr(min:-10, max:10))
    => (-2+1i)

    >> Complex(Float.propr(min:-10, max:10), Float.propr(min:-10, max:10))
    => (9.806161068637833+7.523520738439842i)

### Character

    >> String.propr(min: 1, max: 1)
    => "2"

### Date

    => Date.propr
    >> #<Date: 3388-04-30 (5917243/2,0,2299161)>

    => Date.propr(min: Date.today - 10, max: Date.today + 10).to_s
    >> "2012-03-01"

### Time

    => Time.propr
    >> 3099-12-23 20:00:53 -0600

    => Time.propr(min: Time.now, max: Time.now + 3600)
    => 2012-02-20 13:47:57 -0600

### String

    >> String.propr
    => " BW05a"

    >> String.propr(min: 2, max: 4)
    => "b`R{"

Create a string matching the given character class

    >> String.propr(charset: :alnum)
    => "dX8PzV"

    >> String.propr(charset: :alpha)
    => "yaTCXP"

    >> String.propr(charset: :blank)
    => " \t  \t\t"

    >> String.propr(charset: :cntrl)
    => "\x00\x0F\x04\x12\x1C\x02"

    >> String.propr(charset: :digit)
    => "500961"

    >> String.propr(charset: :graph)
    => "i;NAb!"

    >> String.propr(charset: :lower)
    => "llrqzi"

    >> String.propr(charset: :print)
    => ":zER**"

    >> String.propr(charset: :punct)
    => "=&{%_("

    >> String.propr(charset: :space)
    => " \f\t\n\v\r"

    >> String.propr(charset: :upper)
    => "TSLVVO"

    >> String.propr(charset: :xdigit)
    => "54fEe7"

    >> String.propr(charset: :ascii)
    => "zS9l.@"

    >> String.propr(charset: :any)
    => "\nx\xC0\xE1\xB3\x86"

    >> String.propr(charset: /[w-z]/)
    => "wxxzwwx"

### Array

Create a 4-element array of 4-character strings

    >> Array.propr(min:4, max:4) { String.propr(min:4, max:4) }
    => ["2n #", "UZ1d", "0vF,", "cV_{"]

### Hash

    TODO

## Guards

Throws Propr::GuardFailure

    >> guard(111, &:even?)

Returns `112`

    >> guard(112, &:even?)
    => 112

## Related Projects

* [Rantly](https://github.com/hayeah/rantly)
* [QuviQ](http://www.quviq.com/documents/QuviqFlyer.pdf)
* [QuickCheck](http://www.haskell.org/haskellwiki/Introduction_to_QuickCheck)
