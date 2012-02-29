module Propr

  class Random
    include Monad
  end

  class << Random

    # Evaluators
    #############################################

    def run(computation, scale = BigDecimal(1), retries = 0)
      while true
        value, scale, success = computation.call(scale)
        if success || (retries -= 1) < 0
          return [value, scale, success]
        end
      end
    end

    def eval(computation, scale = BigDecimal(1), retries = 0)
      while true
        value, scale, success = computation.call(scale)
        return value if success
        raise NoMoreTries, "unknown" if (retries -= 1) < 0
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

    def guard(condition)
      lambda do |scale|
        [nil, scale, condition]
      end
    end

    # When given zero arguments, returns the current scale factor
    #
    # When given one argument, sets the current scale factor to
    # the given value, bounded between 0..1.
    #
    # When given two arguments, scales a numeric value towards a
    # given origin `zero`, using the current scale factor (0..1).
    #
    def scale(number = nil, zero = nil)
      if zero.nil?
        if number.nil?
          lambda do |scale|
            [scale, scale, true]
          end
        else
          # Set scale factor 0..1
          lambda do |scale|
            scale = scale.coerce(1)[0] if scale > 1
            scale = scale.coerce(0)[0] if scale < 0
            [nil, scale, true]
          end
        end
      else
        # Scale given number towards zero
        lambda do |scale|
          [zero + scale * (number - zero), scale, true]
        end
      end
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
