class Range
  def random(options = {})
    # @todo: This won't work for some types, e.g. String.
    min.class.random(options.merge(min: min, max: max))
  end
end

class << Range
  def random(options = {}, m = Propr::Random)
    random =
      if block_given?
        yield
      else
        min = options[:min]
        max = options[:max]
        min or max or raise ArgumentError,
          "must provide min, max, or block"
        (min or max).class.random(options)
      end

    m.bind(random) do |a|
      m.bind(random) do |b|
        if options.fetch(:inclusive?, rand > 0.5)
          m.unit(a..b)
        else
          m.unit(a...b)
        end
      end
    end
  end
end
