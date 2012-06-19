class Array
  def random(options = {}, m = Propr::Random)
    m.bind(m.rand(size)) do |index|
      m.unit(self[index])
    end
  end
end

class << Array
  def random(options = {}, m = Propr::Random)
    min  = options[:min] || 0
    max  = options[:max] || 10
    item = yield

    m.bind(Integer.random(min: min, max: max, center: min)) do |size|
      m.sequence([item]*size)
    end
  end
end
