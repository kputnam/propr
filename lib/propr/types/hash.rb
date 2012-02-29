class Hash
  def random(m = Propr::Random)
    # @todo: Shouldn't skew key selection with scale
    m.bind(keys.random) do |k|
      m.unit([k, self[k]])
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
    min  = options[:min] || 0
    max  = options[:max] || 10

    # @todo: Be sure we created enough *unique* keys
    #
    #   Hash.random(min: 10) do
    #     # key space has only 6 elements
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
