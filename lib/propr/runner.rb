module Propr
  class Runner
    attr_reader :minpass, :maxskip

    def initialize(minpass, maxskip, scale)
      @minpass, @maxskip, @scale =
        minpass, maxskip, scale || lambda {|*_| 1 }
    end

    def run(property, generator)
      passed  = 0
      skipped = 0
      wrapped = Dsl::Check.wrap(generator)

      until passed >= @minpass or skipped >= @maxskip
        input, _, success =
          Random.run(wrapped, @scale.call(passed, skipped, @minpass, @maxskip))

        # Generator should've returned an argument list. Except, for convenience,
        # single-argument properties should have generators which return a single
        # value, not an argument list, and we'll make it an argument list *here*.
        input = property.arity == 1 ?
          [input] : input

        if success
          begin
            result = property.call(*input)
            # result = property.arity == 1 ?
            #   property.call(input) : property.call(*input)

            if result
              passed += 1
            else
              # Falsifiable
              return [false, passed, skipped, input]
            end
          rescue GuardFailure => e
            # GuardFailure in property
            skipped += 1
          rescue
            raise Failure.new($!, input, nil, passed, skipped)#, nil, location
          end
        else
          # GuardFailure in generator
          skipped += 1
        end
      end

      # Might have not passed enough tests
      [passed >= @minpass, passed, skipped, nil]
    end
  end
end
