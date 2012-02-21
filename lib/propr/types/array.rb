class Array
  def random
    if empty?
      raise "no elements"
    else
      self[Integer.random(min: 0, max: length - 1)]
    end
  end

  def shrink
    return [] if empty?

    Enumerator.new do |yielder|
      size.times do |n|
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
