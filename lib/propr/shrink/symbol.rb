class Symbol
  def shrink
    to_s.shrink.map(&:to_sym)
  end
end
