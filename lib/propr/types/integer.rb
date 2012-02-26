class Integer
  # @return [Enumerator<Integer>]
  def shrink
    Array.unfold(self) do |seed|
      seed_ = seed / 2
      (seed != seed_).maybe([self - seed, seed_])
    end
  end
end

class << Integer
  INTMAX = 2 ** (0.size * 8 - 2) - 1
  INTMIN = -INTMAX + 1

  # @return [Integer]
  def random(options = {})
    min = options[:min] || INTMIN
    max = options[:max] || INTMAX

    raise ArgumentError,
      "min > max" if min > max

    rand(max + 1 - min) + min
  end
end
