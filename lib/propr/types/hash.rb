class Hash
  def random
    k, v = keys.random
    [k, self[k]]
  end
end

class << Hash
  def random(options = {}, &block)
    min  = options[:min] || 0
    max  = options[:max] || 10
    size = Integer.random(min: min, max: max)
    hash = {}
    size.times{ k, v = block.call; hash[k] = v }

    # Be sure we created enough *unique* keys
    guard(hash) {|s| s.size >= min }
  end
end
