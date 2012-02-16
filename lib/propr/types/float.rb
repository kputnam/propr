require "bigdecimal"

class Float
  # @return [Enumerator<Float>]
  def propq
    Enumerator.unfold(self) do |seed|
      seed_ = seed / 2
      (seed != seed_).maybe([self - seed, seed_])
    end
  end
end

class << Float
  # @return [Float]
  def propr(options = {})
    min = options.fetch(:min, -Float::INFINITY).to_f
    max = options.fetch(:max,  Float::INFINITY).to_f

    min_ = if min.finite? then min else -Float::MAX end
    max_ = if max.finite? then max else  Float::MAX end

    # Taking care to prevent Float overflow
    int  = rand(max_.to_i - min_.to_i + 1)
    big  = BigDecimal(int.to_s) + BigDecimal(min_.to_s)
    big += rand

    # @todo: This is not a useful distribution
    #hoices = [big]
    #hoices.push(-Float::INFINITY)  unless max.finite?
    #hoices.push(Float::INFINITY)   unless max.finite?
    #hoices.push(-0.0)       if min <= 0 and max >= 0
    #hoices.push(Float::NAN) if options.fetch(:nan, true)
    #hoices.propo
  end
end
