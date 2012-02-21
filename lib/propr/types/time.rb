class Time
end

class << Time
  #IN = Time.at(0)            # 1969-12-31 00:00:00 UTC
  MIN = Time.at(-30610224000) # 1000-01-01 00:00:00 UTC
  MAX = Time.at(253402300799) # 9999-12-31 23:59:59 UTC

  def random(options = {})
    min = options[:min] || MIN
    max = options[:max] || MAX
    at(Float.random(min: min.to_f, max: max.to_f))
  end
end
