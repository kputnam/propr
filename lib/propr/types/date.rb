class Date
end

class << Date
  def random(options = {}, m = Propr::Random)
    # These would be constants but `jd` is only defined
    # after `require "date"`.
    @min ||= Date.jd(1721058) # 0000-01-01
    @max ||= Date.jd(5373484) # 9999-12-31

    min = (options[:min] || @min).jd
    max = (options[:max] || @max).jd

    m.bind(Integer.random(options.merge(min: min, max: max))) do |n|
      m.unit(jd(n))
    end
  end
end
