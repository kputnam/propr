class Boolean
  def self.propr
    Kernel.rand > 0.5
  end
end

class TrueClass
  def propq
    [false]
  end
end

class FalseClass
  def propq
    []
  end
end
