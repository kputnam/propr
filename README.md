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

    describe Array do
      include Propr::Macro

      describe "#+" do
        context "with two arrays x and y" do
          it "has length equal to x.length + y.length" do
            xs = [100, "x", :zz]
            ys = [:ww, 200]
            xs.concat(ys).length.should == xs.length + ys.length
          end

          property("has length equal to x.length + y.length") do
            # Generate two arrays
            [with(:size, between(0..25) { array },
             with(:size, between(0..25) { array }]
          end.check do |xs,ys|
            (xs + ys).length.should == xs.length + ys.length
            (ys + xs).length.should == xs.length + ys.length
          end
        end
      end
    end

The following example is similar, but contains an error that might not
be revealed by hand-written test cases.

    describe Array do
      include Propr::Macro

      describe "#|" do
        context "with two arrays x and y" do
          it "has length equal to x.length + y.length" do
            xs = [100, "x", :zz]
            ys = [:ww, 200]
            (xs | ys).length.should == xs.length + ys.length
          end

          property("has length equal to x.length + y.length") do
            # Generate two arrays
            [with(:size, between(0..5)) { array },
             with(:size, between(0..5)) { array }]
          end.check do |xs,ys|
            (xs | ys).length.should == xs.length + ys.length
            (ys | xs).length.should == xs.length + ys.length
          end
        end
      end
    end

When this specification is executed, the following error is reported.

    $ rake spec
    .F

    Failures:

      1) Array#| with two arrays x and y has length equal to x.length + y.length
         Failure/Error: instance_exec(*input, &block)
         expected: 4,
              got: 3 (using ==) -- with srand 317419430220052582439642446331757152805 after 25 successes, input: [[false, "`~~", false], [-187294205]]
         # spec/examples/failure.example:17:in `block (4 levels) in <main>'
         # ./lib/propr/property.rb:76:in `instance_exec'
         # ./lib/propr/property.rb:76:in `block (2 levels) in check'
         # ./lib/propr.rb:119:in `generate'
         # ./lib/propr/property.rb:74:in `block in check'

    Finished in 0.02185 seconds
    2 examples, 1 failure

You may have figured out the error is that `|` removes duplicate elements
from the result, but if that `|` was buried elsewhere in our application,
we probably wouldn't have caught it by writing individual test cases. The
output indicates Propr generated 25 sets of input before finding one that
failed.

Now that a failing test case has been identified, you might write a one-off
test case with those specific inputs to prevent regressions. You could also
call `srand 317419430220052582439642446331757152805` like this to regenerate
the same inputs for the entire test suite:

    RSpec.configure do |config|
      srand 317419430220052582439642446331757152805
    end


## Generating Random Values

    >> p = Propr.new

### Boolean

    >> p.boolean
    => true

### Numeric

#### Integer

    # Random integer between Propr::INTMIN and Propr::INTMAX
    >> p.integer
    => -1830258881470840048

    # Random integer between 0 and 10
    >> p.integer(10)
    => 6

    # Random integer between 10 and 20
    >> p.integer(10..20)
    => 19

#### Float

    # Random float between Propr::INTMIN and Propr::INTMAX
    >> p.float
    => 1769470177.4186616

    # Random float between 0 and 10
    >> p.float(10)
    => 8.47034059208399

    # Random float between 10 and 20
    >> p.float(10..20)
    => 14.58723928680602

#### Rational

    TODO

#### BigDecimal

    TODO

#### Bignum

    TODO

#### Complex

    TODO

### Character

    >> p.character
    => "2"

### Date

    TODO

### Time

    TODO

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

### Array

    >> p.array
    => ["#", "ocvyUQ", true, "-b~M;:", 0.22744564047913196, true]

### Hash

    TODO

## Guards

    # Throws Propr::GuardFailure
    p.guard 111.even?

    # Retries, max 10 times, until guard passes
    p.value { x = integer; guard x.even?; x }

    # Using Object#tap
    p.value { integer.tap{|x| guard x.even? }}

    # Retries, max 99 times, until guard passes
    p.value(99) { integer.tap{|x| guard x.even? }}

## Related Projects

* [Rantly](https://github.com/hayeah/rantly)
* [QuickCheck](http://www.haskell.org/haskellwiki/Introduction_to_QuickCheck)
