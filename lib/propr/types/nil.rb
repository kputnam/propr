class NilClass
  def shrink
    []
  end
end

class << NilClass
  def random(m = Propr::Random)
    m.unit(nil)
  end
end
