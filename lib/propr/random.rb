module Propr
  module Random

    # Returns the given parameter
    #
    # @return [Object]
    def literal(x); x end

    def value
      branch [:date,
              :time,
              :hash,
              :array,
              :float,
              :string,
              :complex,
              :decimal,
              :integer,
              :boolean,
              :rational,
              :character]
    end

    INTMAX = 2 ** (0.size * 8 - 2) - 1
    INTMIN = -INTMAX + 1

    # Generates an integer value
    #
    # @return [Integer]
    def integer(range = nil)
      lo, hi = case range
               when Range
                 if range.exclude_end?
                   [range.first, range.last]
                 else
                   [range.first, range.last + 1]
                 end
               when Integer
                 [0, range.last + 1]
               end || [INTMIN, INTMAX]

      rand(hi - lo) + lo
    end

    FLOATMAX =  100000000000
    FLOATMIN = -100000000000

    # Generates a float value
    #
    # @return [Float]
    def float(range = nil)
      case range
      when Range
        integer(range.begin..range.end - 1)
      when Numeric
        integer(0..range - 1)
      else
        between(FLOATMIN..FLOATMAX)
      end + rand
    end

    # Generates a rational number
    #
    # @return [Rational]
    def rational
      Rational(integer, integer(0..INTMAX))
    end

    # Generates a complex number
    #
    # @return [Complex]
    def complex
      Complex(float, float)
    end

    # Generates a decimal value
    #
    # @return [BigDecimal]
    def decimal(range = nil)
      frac = (BigDecimal(integer.to_s) / integer).frac

      case range
      when Range
        between(range.first, range.last)
      when Numeric
        between(0, range - 1)
      else
        between(INTMAX, INTMIN)
      end + frac
    end

    # Generates true or false
    #
    # @return [TrueClass, FalseClass]
    def boolean
      rand(2).zero?
    end

    DATEMIN = 1721058 # 0000-01-01
    DATEMAX = 5373484 # 9999-12-31

    # Generates a date value
    #
    # @return [Date]
    def date(range = nil)
      range = case range
              when Range
                case range.first
                when Date
                  if range.exclude_end?
                    range.first.jd..range.last.jd
                  else
                    range.first.jd...range.last.jd
                  end
                end
              end || DATEMIN..DATEMAX

      Date.jd(integer(range))
    end

    #IMEMIN = 0            # 1969-12-31 00:00:00 UTC
    TIMEMIN = -30610224000 # 1000-01-01 00:00:00 UTC
    TIMEMAX = 253402300799 # 9999-12-31 23:59:59 UTC

    # Generates a time value
    #
    # @return [Time]
    def time(range = nil)
      range = case range
              when Range
                case range.first
                when Time
                  if range.exclude_end?
                    range.first.to_f...range.last.to_f
                  else
                    range.first.to_f..range.last.to_f
                  end
                end
              end || TIMEMIN..TIMEMAX

      Time.at(float(range))
    end

    # Generates a character the given character class
    #
    # @return [String]
    def character(type = :print)
      chars = case type
              when Regexp
                Characters.of(type)
              when Symbol
                Characters::CLASSES[type]
              end or raise ArgumentError,
                "unrecognized character type #{type.inspect}"

      choose(chars)
    end

    # Generates a sized array by iteratively evaluating `block`
    #
    # @return [Array]
    def array(&block)
      if block_given?
        [].tap{|a| size.times { a << yield }}
      else
        array { value }
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
              when Regexp
                Characters.of(type)
              when Symbol
                Characters::CLASSES[type]
              end or raise ArgumentError,
                "unrecognized character type #{type.inspect}"

      "".tap{|s| size.times { s << choose(chars) }}
    end

  end
end
