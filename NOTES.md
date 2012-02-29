## Property DSL

Properties are basically just functions. They look like this:

    lambda{|a,...| ... }

## Property DSL

* `error?(ex) { ... }`  
  True if code block throws an exception

* `guard(cond)`  
  Skip test for inputs that don't meet the condition

* `label(str)`  
  Classify each invocation of the property

## Random DSL

* `scale(n, zero)`  
  Scale the numeric value closer to zero, using current factor 0..1

* `guard(cond)`  
  Supress the generated value unless a condition is met

* `rand(limit)`  
  Generate a random number using `Kernel.rand`

## Wiring

Define boolean property

    >> f = lambda{|a,b,c| a + (b + c) == (a + b) + c }
    => #<Proc:...>

    >> p = Propr::Property.new("assoc", Propr::Dsl::Property.new(f))
    => #<Propr::Property:...>

Define generator of random data

    >> c = lambda do
         bind(Integer.random) do |a|
         bind(Integer.random) do |b|
         bind(Integer.random) do |c|
           unit([a, b, c]);
         end; end; end; end
    => #<Proc:...>

    >> c = Propr::Dsl::Check.wrap(r)
    => #<Proc:...>

Generating a random input

    >> Propr::Random.eval r
    => [-1473273057635678493, 3003717222078111739, -4075345202237457298]

Simple API for testing the property with random data

    >> p.check { Propr::Random.eval c }
    => true


