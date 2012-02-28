class Array
  def random(m = Propr::Random)
    if empty?
      m.fail "no elements"
    else
      m.bind(Integer.random(min: 0, max: size - 1, center: 0)) do |index|
        m.unit(self[index])
      end
    end
  end

  def shrink
    if empty?
      return []
    end

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
  def random(options = {}, m = Propr::Random)
    min  = options[:min] || 0
    max  = options[:max] || 10

    m.bind(Integer.random(min: min, max: max, center: min)) do |size|
      m.sequence(size.times.map { yield })
    end
  end
end
