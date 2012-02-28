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

    value  = min + rand(max + 1 - min)
    center = options.fetch(:center, :mid)
    center =
      case center
      when :mid then min + (max - min).div(2)
      when :min then min
      when :max then max
      when Numeric
        raise ArgumentError,
          "center < min" if center < min
        raise ArgumentError,
          "center > max" if center > max
        center
      else raise ArgumentError,
        "center must be :min, :mid, :max, or min <= Integer <= max"
      end

    m.bind(m.scale(value, center)) do |n|
      # Round up or down toward center
      m.unit(n > center ? n.floor : n.ceil)
    end
  end
end
