require "bigdecimal"

class Float
  # @return [Array<Float>]
  def shrink
    Array.unfold(self) do |seed|
      zero  = 0
      seed_ = zero + (seed - zero) / 2
      ((seed - seed_).abs > 1e-10).maybe([self + zero - seed, seed_])
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

    range  = max_ - min_
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

    m.bind(m.rand(range)) do |whole|
      m.bind(m.rand) do |fraction|
        value = BigDecimal(min_.to_s) + whole + fraction
        m.scale(value, range, center)
      end
    end
  end
end
