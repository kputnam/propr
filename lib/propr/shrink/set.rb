class Set
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
