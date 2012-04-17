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
        location = location(generator)

        @group.example(@property.name, @options.merge(caller: location)) do
          success, passed, skipped, counterex =
            runner.run(property, generator)

          unless success
            if skipped >= runner.maxskip
              raise NoMoreTries.new(runner.maxskip), nil, location
            else
              raise Falsifiable.new(counterex, m.shrink(counterex), passed, skipped), nil, location
            end
          end
        end
      else
        location = location(caller)

        @group.example(@property.name, @options.merge(caller: location)) do
          unless property.call(*args)
            raise Falsifiable.new(args, m.shrink(args), 0, 0), nil, location
          end
        end
      end

      # Return `self` to allow chaining calls to `check`
      self
    end

    def shrink(counterex)
      xs = [Array(counterex)]

      while true
        # Generate simpler examples
        ys = Array.bind(xs) do |args|
          head, *tail = args.map(&:shrink)
          head.product(*tail)
        end

        zs = []

        # Collect counter examples
        until ys.empty? or zs.length >= 10
          args = ys.delete_at(rand(ys.size))

          unless @property.call(*args)
            zs.push(args)
          end
        end

        if zs.empty?
          # No simpler counter examples
          return xs.first
        else
          # Try to further simplify these
          xs = zs
        end
      end
    end

  private

    def location(data)
      case data
      when Proc
        ["#{data.source_location.join(":")}"]
      when Array
        [data.first]
      end
    end
  end

end
