require "bigdecimal"

class BigDecimal
  # @return [Array<BigDecimal>]
  def shrink
    Array.unfold(self) do |seed|
      seed_ = seed / 2
      ((seed - seed_).abs > Float::MIN).maybe([self - seed, seed_])
    end
  end
end

class << BigDecimal
  INF = BigDecimal("Infinity")
  NAN = BigDecimal("NaN")

  # @return [BigDecimal]
  def random(options = {}, m = Propr::Random)
    min = BigDecimal(options[:min] || -INF)
    max = BigDecimal(options[:max] ||  INF)

    min_ = if min.finite? then min else BigDecimal(-Float::MAX.to_s) end
    max_ = if max.finite? then max else BigDecimal( Float::MAX.to_s) end

    # @todo: -INF, +INF, -0.0, NAN
    center = options.fetch(:center, :mid)
    center =
      case center
      when :mid then min_ + (max_ - min_).div(2)
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

    # @todo: -INF, +INF, -0.0, NAN

    m.bind(m.rand(max_ - min_)) do |a|
      m.bind(m.rand(max_ - min_)) do |b|
        c  = BigDecimal(a) + BigDecimal(min_.to_s)
        c += c / BigDecimal(b) # not 0..1
        c  = max if c > max
        c  = min if c < min
        m.scale(c, center)
      end
    end
  end
end
