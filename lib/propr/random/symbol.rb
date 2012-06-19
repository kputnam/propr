class << Symbol
  # @note: Beware of memory consumption. Symbols are never garbage
  # collected, and we're generating them at random!
  #
  def random(options = {}, m = Propr::Random)
    min = options[:min] || 0
    max = options[:max] || 10
    options = Hash[charset: /[a-z_]/]
    m.bind(String.random(options)) do |s|
      m.unit(s.to_sym)
    end
  end
end
