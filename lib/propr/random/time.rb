class << Time
# MIN = Time.at(0)            # 1969-12-31 00:00:00 UTC
  MIN = Time.at(-30610224000) # 1000-01-01 00:00:00 UTC
  MAX = Time.at(253402300799) # 9999-12-31 23:59:59 UTC

  def random(options = {}, m = Propr::Random)
    min = (options[:min] || MIN).to_f
    max = (options[:max] || MAX).to_f

    m.bind(Float.random(options.merge(min: min, max: max))) do |ms|
      m.unit(at(ms))
    end
  end
end
