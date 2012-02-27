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
  MAX = 2 ** (0.size * 8 - 2) - 1
  MIN = -MAX + 1

  def random(options = {}, m = Propr::Random)
    min = (options[:min] || MIN).to_i
    max = (options[:max] || MAX).to_i

    raise ArgumentError,
      "min > max" if min > max

    mid = min + (max - min).div(2)
    rnd = min + rand(max + 1 - min)

    m.bind(m.scale(rnd, mid)) do |n|
      # Round up or down toward mid
      m.unit(n > mid ? n.floor : n.ceil)
    end
  end
end
