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

    Enumerator.unfold(self) do |seed|
      # Remove each element, one-at-a-time
      # Shrink each element, one-at-a-time
    end
  end
end

class << Array
  def propr(options = {}, &block)
    min  = options.fetch(:min, 0)
    max  = options.fetch(:max, 10)
    size = Integer.propr(min: min, max: max)
    size.times.map { block.call }
  end
end
