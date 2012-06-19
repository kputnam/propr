class Hash
  # @return [Array<Hash>]
  def shrink
    return Array.new if empty?

    array = to_a
    array.combination(size - 1).map{|pairs| Hash[pairs] }.tap do |shrunken|
      shrunken << Hash.new

      size.times do |n|
        head = array[0, n]
        tail = array[n+1..-1]
        k, v = array[n]
        shrunken.concat(v.shrink.map{|m| Hash[head + [[k, m]] + tail] })
      end
    end
  end
end
