class Boolean
  def self.random(m = Propr::Random)
    m.bind(m.rand) do |n|
      m.unit(n > 0.5)
    end
  end
end

class TrueClass
  def shrink
    [false]
  end
end

class FalseClass
  def shrink
    []
  end
end
