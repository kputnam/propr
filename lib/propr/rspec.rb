module Propr

  class RSpecAdapter
    def initialize(group, options, property)
      @options, @group, @property =
        options, group, property

      @runner = Runner.new(100, 50, lambda{|p,s,*_| BigDecimal(p + s) / 100 })
    end

    def check(*args, &generator)
      runner   = @runner
      property = @property

      if block_given?
        @group.example(@property.name, @options) do #.merge(caller: location)) do
          success, passed, skipped, counterex =
            runner.run(property, generator)

          unless success
            if skipped >= runner.maxskip
              raise NoMoreTries.new(runner.maxskip)
            else
              raise Falsifiable.new(counterex, passed, skipped)
            end
          end
        end
      else
        @group.example(@property.name, @options) do #.merge(caller: location)) do
          property.call(*args)
        end
      end

      # Return `self` so users can chain calls to `check`
      self
    end

  private

    def error(message, location)
      raise ::RSpec::Expectations::ExpectationNotMetError,
        message, location
    end

    def location(data)
      case data
      when Proc
        ["#{data.source_location.join(":")}:0"]
      when Array
        [data.first]
      end
    end
  end

end
