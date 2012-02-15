class << Integer
  INTMAX = 2 ** (0.size * 8 - 2) - 1
  INTMIN = -INTMAX + 1

  # @return [Integer]
  def propr(options = {})
    min = options.fetch(:min, INTMIN)
    max = options.fetch(:max, INTMAX)
    rand(max + 1 - min) + min
  end
end

class Integer
  # @return [Array<Integer>]
  def propq
    Propr.unfold(self) do |seed|
      seed_ = seed / 2
      Propr.maybe(seed != seed_, [self - seed, seed_])
    end
  end
end
