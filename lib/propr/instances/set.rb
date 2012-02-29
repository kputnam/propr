class Set
  def random(options = {}, m = Propr::Random)
    options = {center: 0}
      .merge(options)
      .merge(min: 0, max: size - 1)

    m.bind(Integer.random(options)) do |index|
      m.unit(self.to_a[index])
    end
  end

  def shrink
    array = to_a
    array.combination(size - 1).map(&:to_set).tap do |shrunken|
      shrunken << [].to_set

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
        m.unit(Set.new(xs))
      end
    end
  end
end
