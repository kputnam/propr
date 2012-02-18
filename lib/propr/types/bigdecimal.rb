require "bigdecimal"

class BigDecimal
  # @return [Enumerator<BigDecimal>]
  def propq
    Enumerator.unfold(self) do |seed|
      seed_ = seed / 2
      ((seed - seed_).abs > Float::MIN).maybe([self - seed, seed_])
    end
  end
end

class << BigDecimal
  INF = BigDecimal('Infinity')
  NAN = BigDecimal('NaN')

  # @return [BigDecimal]
  def propr(options = {})
    min = (options[:min] || -INF).to_f
    max = (options[:max] ||  INF).to_f

    min_ = if min.finite? then min else -Float::MAX end
    max_ = if max.finite? then max else  Float::MAX end

    a = rand(max_.to_i - min_.to_i + 1)
    b = rand(max_.to_i - min_.to_i + 1)

    c  = BigDecimal(a.to_s) + BigDecimal(min_.to_s)
    c += c/BigDecimal(b.to_s)

    # @todo: -INF, +INF, -0.0, NAN
  end
end
