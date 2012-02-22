class Array
  def random
    if empty?
      raise "no elements"
    else
      self[Integer.random(min: 0, max: length - 1)]
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
    end
  end
end

class << Array
  def random(options = {}, &block)
    min  = options[:min] || 0
    max  = options[:max] || 10
    size = Integer.random(min: min, max: max)
    size.times.map { block.call }
  end
end
