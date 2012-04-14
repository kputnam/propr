require "bigdecimal"

class BigDecimal
  # @return [Array<BigDecimal>]
  def shrink
    limit = 10

    Array.unfold(self) do |seed|
      limit -= 1
      zero   = 0
      seed_  = zero + (seed - zero) / 2

      (limit > 0 && (seed - seed_).abs > 1e-5)
        .maybe([self + zero - seed, seed_])
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

    min_ = if min.finite? then min else BigDecimal(-Float::MAX, 0) end
    max_ = if max.finite? then max else BigDecimal( Float::MAX, 0) end

    range  = max_ - min_
    center = options.fetch(:center, :mid)
    center =
      case center
      when :mid then min_ + (max_ - min_).div(2)
      when :min then min_
      when :max then max_
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
    m.bind(m.rand(range)) do |a|
      m.bind(m.rand(max_ - min_)) do |b|
        c  = BigDecimal(a) + BigDecimal(min_, 0)
        c += c / BigDecimal(b) # not 0..1
        c  = max if c > max
        c  = min if c < min
        m.scale(c, range, center)
      end
    end
  end
end
