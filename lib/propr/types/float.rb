require "bigdecimal"

class << Float
  FLOATMAX = 1.7976931348623157e+308
  FLOATMIN = -1.7976931348623157e+308

  # @return [Float]
  def propr(options = {})
    # @todo: -Infinity, +Infinity, +0.0, -0.0, NaN
    min = options.fetch(:min, FLOATMIN)
    max = options.fetch(:max, FLOATMAX)

    # Careful here to prevent Float overflow
    int = rand(max.to_i - min.to_i + 1)
    big = BigDecimal(int.to_s) + BigDecimal(min.to_s)
    big.to_f + rand
  end
end

class Float
  # @return [Enumerator<Float>]
  def propq
    Enumerator.unfold(self) do |seed|
      seed_ = seed / 2
      (seed != seed_).maybe([self - seed, seed_])
    end
  end
end
