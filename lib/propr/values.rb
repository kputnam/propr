class Propr
  module Values

    INTMAX = 2 ** (0.size * 8 - 2) - 1
    INTMIN = -INTMAX + 1

    FLOATMAX =  100000000000
    FLOATMIN = -100000000000

    # Returns the given parameter
    #
    # @return [Object]
    def literal(x); x end

    # Generates a numeric value within `lo`..`hi`
    #
    # @return [Numeric]
    def between(lo, hi)
      rand(hi + 1 - lo) + lo
    end

    # Generates an integer value
    #
    # @return [Integer]
    def integer(range = nil)
      case range
      when Range
        between(range.begin, range.end)
      when Integer
        between(0, range)
      else
        between(INTMAX, INTMIN)
      end
    end

    # Generates a float value
    #
    # @return [Float]
    def float(range = nil)
      case range
      when Range
        between(range.begin, range.end - 1) + rand
      when Numeric
        between(0, range - 1) + rand
      else
        between(FLOATMIN, FLOATMAX) + rand
      end
    end

    # Generates a rational number
    #
    # @return [Rational]
    def rational
      Rational(integer, integer(0..INTMAX))
    end

    # Generates a decimal value
    #
    # @return [BigDecimal]
    def decimal(range = nil)
      decimal = (BigDecimal(integer.to_s) / integer).frac

      case range
      when Range
        between(range.begin, range.end) + decimal
      when Numeric
        between(0, range - 1) + decimal
      else
        between(INTMAX, INTMIN) + decimal
      end
    end

    # Generates true or false
    #
    # @return [TrueClass, FalseClass]
    def boolean
      rand(2) == 0
    end

    DATEMIN = 1721058 # 0000-01-01
    DATEMAX = 5373484 # 9999-12-31

    # Generates a date value
    #
    # @return [Date]
    def date
      Date.jd(integer(DATEMIN..DATEMAX))
    end

    TIMEMIN = 0            # 1969-12-31 00:00:00 UTC
    TIMEMAX = 253402300799 # 9999-12-31 23:59:59 UTC

    # Generates a time value
    #
    # @return [Time]
    def time
      Time.at(integer(0..TIMEMAX))
    end

    # Generates a character the given character class
    #
    # @return [String]
    def character(type = :print)
      chars = case type
              when Regexp then Characters.of(type)
              when Symbol then Characters::CLASSES[type] end

      raise ArgumentError, "unrecognized character type #{type.inspect}" unless chars
      choose(chars)
    end

    # Generates a sized array by iteratively evaluating `block`
    #
    # @return [Array]
    def array(&block)
      if block_given?
        @bindings.push(eval("self", block.binding))

        (1..size).inject([]) {|a,_| a << instance_eval(&block) }.tap do
          @bindings.pop
        end
      else
        array { branch [:string, :integer, :float, :character, :boolean] }
      end
    end

    # @return [Hash]
    def hash(&block)
      # @todo
    end

    # Generates a sized string of the given character class
    #
    # @return [String]
    def string(type = :print)
      chars = case type
              when Regexp then Characters.of(type)
              when Symbol then Characters::CLASSES[type] end

      raise ArgumentError, "unrecognized character type #{type.inspect}" unless chars
      acc = ""; size.times { acc << choose(chars) }; acc
    end

  end
end
