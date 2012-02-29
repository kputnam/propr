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
        value, _, success =
          Random.run(wrapped, @scale.call(passed, skipped, @minpass, @maxskip))

        if success
          begin
            if property.check(value)
              passed += 1
            else
              # Falsifiable
              return [false, passed, skipped, value]
            end
          rescue GuardFailure => e
            skipped += 1
          end
        else
          skipped += 1
        end
      end

      # Might have not passed enough tests
      [passed >= @minpass, passed, skipped, nil]
    end
  end
end
