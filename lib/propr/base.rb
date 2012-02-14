module Propr
  class Base
    include Propr::Random

    # @return [Propr::Property]
    def property(name, &body)
      Property.new(name, self, body)
    end

    # Throw a GuardFailure if condition is false
    def guard(condition)
      condition or raise GuardFailure
    end

    # Generates an element from the given sequence of values
    def oneof(values)
      values[integer(0...values.length)]
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
