require "bigdecimal"

class << Float
  # @return [Float]
  def random(options = {}, m = Propr::Random)
    min = (options[:min] || -Float::INFINITY).to_f
    max = (options[:max] ||  Float::INFINITY).to_f

    min_ = if min.finite? then min else -Float::MAX end
    max_ = if max.finite? then max else  Float::MAX end

    range  = max_.to_i - min_.to_i
    center = options.fetch(:center, :mid)
    center =
      case center
      when :min then min
      when :max then max
      when :mid
        if (max_ - min_).finite?
          min_ + (max_ - min_).fdiv(2)
        else
          (min_ + max_).fdiv(2)
        end
      when Numeric
        raise ArgumentError,
          "center < min" if center < min
        raise ArgumentError,
          "center > max" if center > max
        center
      else raise ArgumentError,
        "center must be :min, :mid, :max, or min <= Integer <= max"
      end

    # @todo: -Float::INFINITY, +Float::INFINITY, -0.0, Float::NAN

    # One approach is to count all `n` possible Float values inside
    # the [min, max] interval (n <= 2^64 for double precision), then
    # generate a Fixnum inside [0, n] and map it back to the nth
    # Float value in [min, max].
    #
    # Instead, this method just counts the `n` possible whole values
    # inside [min, max], generates a Fixnum inside [0, n - 1], then
    # maps that back to the nth whole value inside [min, max - 1].
    # Next we tack on a random fractional value inside [0, 1).
    m.bind(m.rand(range)) do |whole|
      m.bind(m.rand) do |fraction|
        # Need to perform scaling on BigDecimal to prevent floating
        # point underflow and overflow (e.g., BIG / HUGE == 0.0, and
        # BIG + small == BIG).
        value  = BigDecimal(min_, 15) + whole
        value += BigDecimal(fraction, 0)
        center = BigDecimal(center, 0)

        m.bind(m.scale(value, range, center)) do |d|
          m.unit(d.to_f)
        end
      end
    end
  end
end
