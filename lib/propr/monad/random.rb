module Propr

  class Random
    include Monad
  end

  class << Random

    # Evaluators
    #############################################

    def run(computation, scale = BigDecimal(1))
      computation.call(scale)
    end

    def eval(computation, scale = BigDecimal(1), retries = 0)
      skipped = 0

      while true
        value, _, success = computation.call(scale)

        if success
          return value
        elsif (skipped += 1) > retries
          raise NoMoreTries, retries
        end
      end
    end

    # Combinators
    #############################################

    def unit(value)
      lambda do |scale|
        [value, scale, true]
      end
    end

    def bind(f, &g)
      lambda do |scale|
        value, scale, success = f.call(scale)

        success ?
          g.call(value).call(scale) :
          [value, scale, success]
      end
    end

    # Actions
    #############################################

    def guard(*conditions)
      lambda do |scale|
        [nil, scale, conditions.all?]
      end
    end

    # When given zero arguments, returns the current scale factor
    #
    # When given one argument, sets the current scale factor to
    # the given value, bounded between 0..1.
    #
    # When given two arguments, scales a numeric value around a
    # given origin `ref`, using the current scale factor (0..1).
    #
    def scale(number = nil, range = nil, ref = nil)
    # if range.nil?
    #   if number.nil?
    #     lambda do |scale|
    #       # Get scale factor
    #       [scale, scale, true]
    #     end
    #   else
    #     # Set scale factor 0..1
    #     lambda do |scale|
    #       scale = scale.coerce(1)[0] if scale > 1
    #       scale = scale.coerce(0)[0] if scale < 0
    #       [nil, scale, true]
    #     end
    #   end
    # else
        lambda do |scale|
          pct  = (number - ref) / range
          rng_ = (range ** scale) - 1 + scale
          [ref + rng_* pct, scale, true]
        end
    # end
    end

    # Generate psuedo-random number normally distributed between
    # 0 <= x < 1. This distribution is not weighted using `scale`.
    #
    def rand(limit = nil)
      lambda do |scale|
        [Kernel.rand(limit), scale, true]
      end
    end

  end
end
