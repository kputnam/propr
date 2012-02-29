class Hash
  def random(m = Propr::Random)
    m.bind(keys.random) do |k|
      m.unit([k, self[k]])
    end
  end

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

class << Hash

  # @example
  #   Hash.random do
  #     m.bind(Integer.random){|k| m.bind(String.random){|v| m.unit([k,v]) }}
  #   end
  #
  def random(options = {}, m = Propr::Random)
    min = options[:min] || 0
    max = options[:max] || 10

    # @todo: Be sure we created enough *unique* keys
    #
    #   Hash.random(min: 10) do
    #     # key space could have at most 6 elements
    #     m.sequence([Integer.random(min: 0, max: 5), String.random])
    #   end
    #
    m.bind(Integer.random(options.merge(min: min, max: max))) do |size|
      m.bind(m.sequence(size.times.map { yield })) do |pairs|
        m.unit(Hash[pairs])
      end
    end
  end
end
