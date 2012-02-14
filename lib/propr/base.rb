module Propr
  class Base
    include Propr::Values

    def guard(condition)
      condition or raise GuardFailure
    end

    # Generates an element from the given sequence of values
    def choose(values)
      values[between(0, values.length - 1)]
    end

    # Executes `call` on a random element from the given sequence
    def branch(generators)
      call(choose(generators))
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
