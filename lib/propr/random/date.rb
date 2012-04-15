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

class << Date
  MIN = Date.jd(1721058) # 0000-01-01
  MAX = Date.jd(5373484) # 9999-12-31

  def random(options = {}, m = Propr::Random)
    # These would be constants but `jd` is only defined
    # after `require "date"`.
    min = (options[:min] || MIN).jd
    max = (options[:max] || MAX).jd

    m.bind(Integer.random(options.merge(min: min, max: max))) do |n|
      m.unit(jd(n))
    end
  end
end
