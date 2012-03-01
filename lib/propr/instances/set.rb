class Set
  def random(options = {}, m = Propr::Random)
    m.bind(m.rand(size)) do |index|
      m.unit(self.to_a[index])
    end
  end

  # @return [Array<Set>]
  def shrink
    return Array.new if empty?

    array = to_a
    array.combination(size - 1).map(&:to_set).tap do |shrunken|
      shrunken << Set.new

      size.times do |n|
        head = array[0, n]
        tail = array[n+1..-1]
        item = array[n]
        shrunken.concat(item.shrink.map{|m| (head + [m] + tail).to_set })
      end
    end
  end
end

class << Set
  def random(options = {}, m = Propr::Random)
    min  = options[:min] || 0
    max  = options[:max] || 10

    # @todo: Be sure we created enough *unique* elements
    m.bind(Integer.random(options.merge(min: min, max: max))) do |size|
      m.bind(m.sequence(size.times.map { yield })) do |xs|
        m.unit(xs.to_set)
      end
    end
  end
end
