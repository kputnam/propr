class Array
  def propo
    if empty?
      raise "no elements"
    else
      self[Integer.propr(min: 0, max: length - 1)]
    end
  end

  def propq
    return [] if empty?

    Enumerator.new do |yielder|
      size.times do |n|
      end
    end
  end
end

class << Array
  def propr(options = {}, &block)
    min  = options[:min] || 0
    max  = options[:max] || 10
    size = Integer.propr(min: min, max: max)
    size.times.map { block.call }
  end
end
