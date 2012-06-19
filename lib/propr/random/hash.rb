class Hash
  def random(m = Propr::Random)
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
  # @example
  #   Hash.random do
  #     m.sequence([Integer.random, String.random])
  #   end
  #
  def random(options = {}, m = Propr::Random)
    min  = options[:min] || 0
    max  = options[:max] || 10
    pair = yield

    # @todo: Be sure we created enough *unique* keys
    #
    #   Hash.random(min: 10) do
    #     # key space could have at most 6 elements
    #     m.sequence([Integer.random(min: 0, max: 5), String.random])
    #   end
    #
    m.bind(Integer.random(options.merge(min: min, max: max))) do |size|
      m.bind(m.sequence([pair]*size)) do |pairs|
        m.unit(Hash[pairs])
      end
    end
  end

  # @example
  #   Hash.random_vals \
  #     name:   String.random,
  #     count:  Integer.random(min: 0),
  #     weight: Float.random
  #
  def random_vals(hash, m = Propr::Random)
    # Convert hash of key => generator to a list of pair-generators,
    # where the pairs correspond to the original set of [key, value]
    pairs = hash.map{|k,v| m.bind(v){|v| m.unit([k, v]) }}

    m.bind(m.sequence(pairs)) do |pairs|
      m.unit(Hash[pairs])
    end
  end
end
