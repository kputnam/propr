class Boolean
  def self.random(m = Propr::Random)
    m.bind(m.rand) do |n|
      m.unit(n > 0.5)
    end
  end
end
