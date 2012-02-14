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
    context "with two arrays xs and ys" do

      # Traditional unit test
      it "has length equal to xs.length + ys.length" do
        xs = [100, "x", :zz]
        ys = [:ww, 200]
        (xs + ys).length.should == xs.length + ys.length
      end

      # Property-based test
      property("has length equal to xs.length + ys.length") do |xs, ys|
        (xs + ys).length == xs.length + ys.length
      end.
      check([100, "x", :zz], [:ww, 200]).
      check{|rand| [rand.array, rand.array] }

    end
  end
end
```

The following example is similar, but contains an error that might not
be revealed by hand-written test cases.

```ruby
describe Array do
  include Propr::Rspec

  describe "#|" do
    context "with two arrays xs and ys" do

      # Traditional unit test
      it "has length equal to x.length + y.length" do
        xs = [100, "x", :zz]
        ys = [:ww, 200]
        (xs | ys).length.should == xs.length + ys.length
      end

      # Property-based test
      property("has length equal to xs.length + ys.length") do |xs, ys|
        (xs | ys).length == xs.length + ys.length
      end.
      check([100, "x", :zz], [:ww, 200])
      check{|rand| [rand.array, rand.array] }

    end
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

    p = Propr::Base.property("name"){|a,b| a + b == b + a }
    p.class.ancestors #=> [Propr::Property, Proc, Object, ...]

You can invoke a property using `#check`. Like any Proc, you can also invoke
them using `#call` or `#[]`.

    p.check(3, 4)     #=> true
    p.check("x", "y") #=> true

But you can also invoke them with a setup function that generates random
arguments. The setup function is passed an instance of `Propr::Base`.

    p.check{|rand| [rand.integer, rand.float] } #=> true
    p.check{|rand| [rand.array, rand.array] }   #=> true

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
    check{|rand| rand.string }.
end
```

Note your property should still return `true` or `false`. You can avoid some
clutter by *not* using `#should` or `#assert`, because the test generator
will generate the assertion for you.

By default, `rand` will be an instance of `Propr::Base`. If you want to use
some other generator you can pass a parameter on the `include` line like so:

    class FooTest < Test::Unit::TestCase
      include Propr::TestUnit(RandomFoos)
    end

This is just a convenience, though. You can call `Propr::Rspec.define` or
`Propr::TestUnit.define` to generate test cases, too.

    Propr::TestUnit.define(Propr::Base.property("length"){|a| a.length >= 0 }).
      check("abc").
      check("xyz").
      check{|rand| rand.string }

## Generating Random Values

    >> p = Propr::Base.new

### Boolean

    >> p.boolean
    => true

### Numeric

#### Integer

Random integer between Propr::INTMIN and Propr::INTMAX

    >> p.integer
    => -1830258881470840048

Random integer between 0 and 10

    >> p.integer(10)
    => 6

Random integer between 10 and 20

    >> p.integer(10..20)
    => 19

#### Float

Random float between Propr::INTMIN and Propr::INTMAX

    >> p.float
    => 1769470177.4186616

Random float between 0 and 10

    >> p.float(10)
    => 8.47034059208399

Random float between 10 and 20

    >> p.float(10..20)
    => 14.58723928680602

#### Rational

    >> p.rational
    => (3419121051897208321/513829382835133827)

    >> Rational(p.integer(-5000..5000), p.integer(0..10))
    => (735/2)

#### BigDecimal

    >> p.bigdecimal.to_s("F")
    => "7936297730318639394.320561703810327716036557741373593518621908133293211327"

    >> p.bigdecimal(10..20).to_s("F")
    => "14.934854011762374703280016489856414847259220844969789892"

#### Bignum

    TODO

#### Complex

    >> Complex(p.integer(-10..10), p.integer(-10..10))
    => (-2+1i)

    >> Complex(p.float(-10..10), p.float(-10..10))
    => (9.806161068637833+7.523520738439842i)

### Character

    >> p.character
    => "2"

Create a character matching the given character class

    => p.character(:alnum)
    => "Q"

    => p.character(:alpha)
    => "E"

    => p.character(:blank)
    => "\t"

    => p.character(:cntrl)
    => "\x17"

    => p.character(:digit)
    => "2"

    => p.character(:graph)
    => "("

    => p.character(:lower)
    => "t"

    => p.character(:print)
    => "]"

    => p.character(:punct)
    => "\\"

    => p.character(:space)
    => "\r"

    => p.character(:upper)
    => "R"

    => p.character(:xdigit)
    => "1"

    => p.character(:ascii)
    => "\x12"

    => p.character(:any)
    => " "

### Date

    => p.date
    >> #<Date: 3388-04-30 (5917243/2,0,2299161)>

    => p.date.to_s
    >> "2925-12-15"

### Time

    => p.time
    >> 3099-12-23 20:00:53 -0600

### DateTime

    TODO

### Sized-Values

    >> p.size
    => 6

    >> p.with(size: 10) { p.size }
    => 10

### String

    >> p.string
    => " BW05a"

    >> p.with(size: 4) { p.string }
    => "b`R{"

Create a string matching the given character class

    >> p.string(:alnum)
    => "dX8PzV"

    >> p.string(:alpha)
    => "yaTCXP"

    >> p.string(:blank)
    => " \t  \t\t"

    >> p.string(:cntrl)
    => "\x00\x0F\x04\x12\x1C\x02"

    >> p.string(:digit)
    => "500961"

    >> p.string(:graph)
    => "i;NAb!"

    >> p.string(:lower)
    => "llrqzi"

    >> p.string(:print)
    => ":zER**"

    >> p.string(:punct)
    => "=&{%_("

    >> p.string(:space)
    => " \f\t\n\v\r"

    >> p.string(:upper)
    => "TSLVVO"

    >> p.string(:xdigit)
    => "54fEe7"

    >> p.string(:ascii)
    => "zS9l.@"

    >> p.string(:any)
    => "\nx\xC0\xE1\xB3\x86"

    >> p.string(/[A-z]/)
    => "hQEVyV"

### Array

Create an element of random values with the default size

    >> p.array
    => ["#", "ocvyUQ", true, "-b~M;:", 0.22744564047913196, true]

Create a 4-element array of 4-character strings

    >> p.with(size: 4) { p.array { p.string }}
    => ["2n #", "UZ1d", "0vF,", "cV_{"]

Create a 4-element array of 2-character strings

    >> p.with(size: 4) { p.array { p.with(size: 2) { p.string }}}
    => [":t", "u9", "K#", "_O"]

### Hash

    TODO

### Constant

    >> p.literal(400)
    => 400

## Evaluation

Randomly selects a value

    >> p.oneof(["a", "b", "x", "y"])
    => "x"

Call the given generator

    >> p.call(:integer)
    => 6375782241601633756

Call the given generator with arguments

    >> p.call(:integer, 0..20)
    => 4

Call the given generator with arguments

    >> p.call([:integer, 0..20])
    => 18

Randomly choose a generator and `call` it

    >> p.branch([:integer, :character])
    => "H"

Weighted branches: character 10 times more probable than integer

    >> p.freq([1, :integer], [10, :character])
    => "a"

## Guards

Throws Propr::GuardFailure

    >> p.guard 111.even?

Retries, max 10 times, until guard passes

    >> p.value { x = integer; guard x.even?; x }
    => 12339491166734657382

Using Object#tap

    >> p.value { integer.tap{|x| guard x.even? }}
    => 12277061243321644106

Retries, max 99 times, until guard passes

    >> p.value(99) { integer.tap{|x| guard x.even? }}
    => 13232541365560615358

## Related Projects

* [Rantly](https://github.com/hayeah/rantly)
* [QuviQ](http://www.quviq.com/documents/QuviqFlyer.pdf)
* [QuickCheck](http://www.haskell.org/haskellwiki/Introduction_to_QuickCheck)
