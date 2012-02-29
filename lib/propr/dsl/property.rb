module Propr
  module Dsl

    class Property

      # Properties shouldn't be monadic, as all random data is generated
      # elsewhere and passed as arguments to the property. However, this
      # provides a workaround: m.eval, m.unit, m.bind, etc where `m` is
      # given as an argument to `wrap`.
      attr_reader :m

      # Generates a new function, which should return a Boolean
      def self.wrap(block, m = Propr::Random)
        lambda{|*args| new(block, m).instance_exec(*args, &block) }
      end

      def initialize(block, m)
        @context, @m =
          Kernel.eval("self", block.binding), m
      end

      def error?(type = Exception)
        begin
          yield
          false
        rescue => e
          e.is_a?(type)
        end
      end

      def guard(*conditions)
        if index = conditions.index{|x| not x }
          raise GuardFailure,
            "guard condition #{index} was false"
        end
      end

      def label(value)
        # @todo
      end

    private

      def method_missing(name, *args, &block)
        @context.__send__(name, *args, &block)
      end

    end

  end
end
