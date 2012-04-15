class Fr::Maybe::Some
  def shrink
    [Fr.none, map(&:shrink)]
  end
end

class Fr::Maybe::None_
  def shrink
    []
  end
end
