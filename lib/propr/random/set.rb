class Set
  def random(options = {}, m = Propr::Random)
    m.bind(m.rand(size)) do |index|
      m.unit(self.to_a[index])
    end
  end
end

class << Set
  def random(options = {}, m = Propr::Random)
    min  = options[:min] || 0
    max  = options[:max] || 10
    item = yield

    # @todo: Be sure we created enough *unique* elements
    m.bind(Integer.random(options.merge(min: min, max: max))) do |size|
      m.bind(m.sequence([item]*size)) do |xs|
        m.unit(xs.to_set)
      end
    end
  end
end
