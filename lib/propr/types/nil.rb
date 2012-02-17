class NilClass
  def propq
    []
  end
end

class << NilClass
  def propr
    self
  end
end
