class Set
  def random
    if empty?
      raise "no elements"
    else
      to_a[Integer.random(min: 0, max: size - 1)]
    end
  end

  def shrink
    combination(size - 1).to_a.tap do |shrunken|
      shrunken << []
      size.times do |n|
        head = self[0, n]
        tail = self[n+1..-1]
        item = self[n]
        shrunken.concat(item.shrink.map{|m| head + [m] + tail })
      end
    end.to_set
  end
end

class << Set
  def random(options = {}, &block)
    min  = options[:min] || 0
    max  = options[:max] || 10
    size = Integer.random(min: min, max: max)

    # Be sure we created enough *unique* elements
    guard(size.times.map { block.call }.to_set) {|s| s.size >= min }
  end
end
