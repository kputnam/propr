require "date"

class Date
  # @return [Array<Date>]
  def shrink
    Array.unfold(jd) do |seed|
      zero  = 2415021 # 1900-01-01
      seed_ = zero + (seed - zero) / 2
      (seed != seed_).maybe([self + zero - seed, seed_])
    end
  end
end
