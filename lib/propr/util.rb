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

class Range
  def empty?
    (first == last and exclude_end?) or first > last
  end
end
