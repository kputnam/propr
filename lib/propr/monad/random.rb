module Propr

  class Random
    include Monad
  end

  class << Random

    # Evaluators
    #############################################

    def run(computation, scale)
      computation.call(scale)
    end

    def eval(computation, scale)
      computation.call(scale)[0]
    end

    # Combinators
    #############################################

    def unit(value)
      lambda do |scale|
        [value, scale]
      end
    end

    def bind(f, &g)
      lambda do |scale|
        value, scale = f.call(scale)
        g.call(value).call(scale)
      end
    end

    # Actions
    #############################################

    def guard(condition)
      lambda do |scale|
        # [value, scale]
      end
    end

    def scale(number, zero = nil)
      if zero.nil?
        # Set scale factor
        lambda do |scale|
          [nil, scale]
        end
      else
        # Scale given number towards zero
        lambda do |scale|
          [zero + scale * (number - zero), scale]
        end
      end
    end

    def rand(limit = nil)
      lambda do |scale|
        [Kernel.rand(limit), scale]
      end
    end

  end
end
