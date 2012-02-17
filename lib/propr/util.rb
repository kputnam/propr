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

  class None_
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

  None = None_.new

end

# @note: Beware of monkey patches below!

class TrueClass
  def maybe(value)
    Propr::Some.new(value)
  end
end

class FalseClass
  def maybe(value)
    Propr::None
  end
end

class << Array
  # @return [Array]
  def unfold(seed, &block)
    m = yield(seed)
    m.fold([]){|(item, seed)| [item] + unfold(seed, &block) }
  end
end

class << Enumerator
  # @return [Enumerator]
  def unfold(seed, &block)
    Enumerator.new do |yielder|
      while true
        yield(seed).fold(false) do |(item,seed_)|
          yielder.yield item
          seed = seed_
          true
        end || break
      end
    end
  end
end
