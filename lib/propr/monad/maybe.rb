module Propr

  class Maybe
    include Monad
  end

  class << Maybe

    # Evaluators
    #############################################
    def run(computation)
      computation
    end

    # Combinators
    #############################################

    def fail(reason)
      None
    end

    def unit(value)
      Some.new(value)
    end

    def bind(f, &g)
      f.fold(f, &g)
    end

  end

  class Some < Maybe
    def initialize(value)
      @value = value
    end

    def map
      Some.new(yield @value)
    end

    def fold(default)
      yield @value
    end

    def some?
      true
    end

    def none?
      false
    end

    def shrink
      [None, Some.new(@value.shrink)]
    end

    def ==(other)
      Maybe === other and other.fold(false){|x| x == @value }
    end

    def eql?(other)
      Maybe === other and other.fold(false){|x| x == @value }
    end

    def hash
      @value.hash
    end
  end

  class None_ < Maybe
    def map
      self
    end

    def fold(default)
      default
    end

    def some?
      false
    end

    def shrink
      []
    end
  end

  # Singleton instance
  None = None_.new

end
