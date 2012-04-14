module Propr

  class Random
    include Monad
  end

  class << Random

    # Evaluators
    #############################################

    def run(computation, scale = BigDecimal(1))
      computation.call(bound scale)
    end

    def eval(computation, scale = BigDecimal(1), retries = 0)
      skipped = 0
      scale   = bound(scale)

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

    # When given two arguments, scales a numeric value around a
    # given origin `zero`, using the current scale factor (0..1).
    #
    def scale(number, range, zero)
      lambda do |scale|
        # Shrink range exponentially, and -1 + scale reduces the
        # rng_ to 0 when scale = 0, but rng_ = range when scale = 1.
        rng_ = (range ** scale) - 1 + scale
        pct  = (number - zero) / range
        [zero + rng_ * pct, scale, true]
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

  private

    def bound(scale)
      if scale > 1
        scale.coerce(1)[0]
      elsif scale < 0
        scale.coerce(0)[0]
      else
        scale
      end
    end

  end
end
