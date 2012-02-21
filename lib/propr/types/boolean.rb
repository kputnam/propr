class Boolean
  def self.random
    Kernel.rand > 0.5
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
