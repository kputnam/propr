# require "date"
# require "complex"
# require "rational"
# require "bigdecimal"

module Propr
  class Random
    include Propr::Base

    # Create a property which can be checked with random data generated
    # by this instance. Doesn't need to be overridden in subclasses of
    # `Random`, as `this` is late-binding.
    #
    # @return [Propr::Property]
    def property(name, &body)
      Property.new(name, self, body)
    end

    # Returns the given value
    #
    # @return [Object]
    def literal(value)
      value
    end

    # Throw a GuardFailure if condition is false
    def guard(condition)
      condition or raise GuardFailure
    end

    # Generates an element from the given sequence or range of values.
    def oneof(values)
      case values
      when Array
        values[integer(0...values.length)]
      when Range
        case values.first
        when Integer
          integer(values)
        when Float
          float(values)
        when BigDecimal
          decimal(values)
        when Date
          date(values)
        when Time
          time(values)
        else
          oneof(values.to_a)
        end
      when Hash
        oneof(values.keys).tap{|k| [k, values[k]] }
      else
        oneof(values.to_a)
      end
    end

    # Execute `call` on a random element from the given sequence
    def branch(generators)
      call(oneof(generators))
    end

    def call(generator, *args)
      case generator
      when Symbol, String
        send(generator, *args)
      when Array
        send(generator[0], *generator[1..-1])
      when Proc
        generator.call(self)
      else
        raise ArgumentError, "unrecognized generator type #{generator.inspect}"
      end
    end
  end
end
