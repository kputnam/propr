class Date
end

class << Date
  def random(options = {})
    # These would be constants but `jd` is only defined
    # after `require "date"`.
    @min ||= Date.jd(1721058) # 0000-01-01
    @max ||= Date.jd(5373484) # 9999-12-31

    min = options[:min] || @min
    max = options[:max] || @max
    jd(Integer.random(min: min.jd, max: max.jd))
  end
end
