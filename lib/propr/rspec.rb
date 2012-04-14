module Propr

  class RSpecAdapter
    def initialize(group, options, property)
      @options, @group, @property =
        options, group, property

      # Run each property 100 times, allow 50 retries, and
      # start the scale at 0, grow suddenly towards the end
      @runner = Runner.new(100, 50,
      # lambda{|p,s,t,_| (p+s <= t ? p+s : t) / t })
        lambda{|p,s,t,_| (BigDecimal(p+s <= t ? p+s : t) / t) })
    end

    def check(*args, &generator)
      m        = self
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
              raise Falsifiable.new(m.shrink(counterex), passed, skipped)
            end
          end
        end
      else
        @group.example(@property.name, @options) do #.merge(caller: location)) do
          property.call(*args)
        end
      end

      # Return `self` to allow chaining calls to `check`
      self
    end

    def shrink(counterex)
      #uts "shrink: #{counterex.inspect}"

      xs = [Array(counterex)]

      while true
        # Generate simpler counter-examples
        ys = Array.bind(xs) do |args|
          head, *tail = args.map(&:shrink)
          head.product(*tail)
        end.reject{|args| args.empty? or @property.call(*args) }

        if ys.empty?
          return xs.first
        end

        # Prune randomly to maximum size
        if ys.size <= 10
          xs = ys
        else
          xs = 10.times.map { ys.delete_at(rand(ys.length)) }
        end
      end
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
