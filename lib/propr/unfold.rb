class << Array
  # @return [Array]
  def unfold(seed, &block)
    m = yield(seed)
    m.fold([]){|(item, seed)| [item] + unfold(seed, &block) }
  end
end

class << Hash
  # @return [Array]
  def unfold(seed, &block)
    m = yield(seed)
    m.fold({}){|(k, v, seed)| unfold(seed, &block).update(k => v) }
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
