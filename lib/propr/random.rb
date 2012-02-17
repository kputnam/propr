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
