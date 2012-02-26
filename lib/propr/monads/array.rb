class << Array

  # Evaluators
  #############################################

  def run(computation)
    computation
  end

  # Combinators
  #############################################

  def fail(reason)
    []
  end

  def unit(value)
    [value]
  end

  def bind(f, &g)
    f.map(&g).inject([], &:concat)
  end

end
