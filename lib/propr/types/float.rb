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
    rnd  = BigDecimal(int.to_s) + BigDecimal(min_.to_s)
    rnd += rand

    # @todo: -Float::INFINITY, +Float::INFINITY, -0.0, Float::NAN
    m.scale(rnd, mid)
  end
end
