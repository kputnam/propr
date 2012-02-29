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

    center = options.fetch(:center, :mid)
    center =
      case center
      when :min then min
      when :max then max
      when :mid
        if (max_ - min_).finite?
          min_ + (max_ - min_).fdiv(2)
        else
          (min_ + max_).fdiv(2)
        end
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

    # Reduce range by 1.0 to account for +rand below
    m.bind(m.rand(max_.to_i - min_.to_i)) do |whole|
      m.bind(m.rand) do |fraction|
        # Take care to prevent Float overflow
        m.scale(BigDecimal(min_.to_s) + whole + fraction, center)
      end
    end
  end
end
