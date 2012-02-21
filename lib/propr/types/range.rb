class Range
  def random
    min.class.random(min: min, max: max)
  end
end

class << Range
  def random(options = {})
    a, b =
      if block_given?
        [yield, yield]
      else
        min = options[:min]
        max = options[:max]

        min or max or raise ArgumentError,
          "must provide min, max, or block"

        [(min or max).class.random(min: min, max: max),
         (min or max).class.random(min: min, max: max)]
      end

    if options.fetch(:inclusive?, rand > 0.5)
      a..b
    else
      a...b
    end
  end
end
