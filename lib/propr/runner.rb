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

        if success
          begin
            result = property.arity == 1 ?
              property.call(input) : property.call(*input)

            if result
              passed += 1
            else
              # Falsifiable
              return [false, passed, skipped, value]
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
