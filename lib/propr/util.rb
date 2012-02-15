module Propr

  class Some
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
  end

  class None
    def map
      self
    end

    def fold(default)
      default
    end

    def some?
      false
    end
  end

  None = None.new

  def self.unfold(seed, &block)
    m = yield(seed)
    m.fold([]){|(item, seed)| [item] + unfold(seed, &block) }
  end

  def self.maybe(bool, value)
    bool ? Some.new(value) : None
  end
end
