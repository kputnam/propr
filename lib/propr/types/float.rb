require "bigdecimal"

class Float
  # @return [Enumerator<Float>]
  def shrink
    Enumerator.unfold(self) do |seed|
      seed_ = seed / 2
      (seed != seed_).maybe([self - seed, seed_])
    end
  end
end

class << Float
  # @return [Float]
  def random(options = {}, m = Propr::Random)
    min = (options[:min] || -Float::INFINITY).to_f
    max = (options[:max] ||  Float::INFINITY).to_f

    min_ = if min.finite? then min else -Float::MAX end
    max_ = if max.finite? then max else  Float::MAX end
    mid  = min_ + (max_ - min_).fdiv(2)

    # Reduce range by 1.0 to account for +rand below
    int  = rand(max_.to_i - min_.to_i)

    # Take care to prevent Float overflow
    value  = BigDecimal(int.to_s) + BigDecimal(min_.to_s)
    value += rand

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

    # @todo: -Float::INFINITY, +Float::INFINITY, -0.0, Float::NAN
    m.scale(value, center)
  end
end
