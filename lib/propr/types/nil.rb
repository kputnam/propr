class NilClass
  def shrink
    []
  end
end

class << NilClass
  def random
    self
  end
end
