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
