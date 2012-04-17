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
        case block.arity
        when 0; lambda{|| new(block, m).instance_exec(&block) }
        when 1; lambda{|a| new(block, m).instance_exec(a,&block) }
        when 2; lambda{|a,b| new(block, m).instance_exec(a,b,&block) }
        when 3; lambda{|a,b,c| new(block, m).instance_exec(a,b,c,&block) }
        when 4; lambda{|a,b,c,d| new(block, m).instance_exec(a,b,c,d &block) }
        when 5; lambda{|a,b,c,d,e| new(block, m).instance_exec(a,b,c,d,e,&block) }
        when 6; lambda{|a,b,c,d,e,f| new(block, m).instance_exec(a,b,c,d,e,f,&block) }
        when 7; lambda{|a,b,c,d,e,f,g| new(block, m).instance_exec(a,b,c,d,e,f,g,&block) }
        when 8; lambda{|a,b,c,d,e,f,g,h| new(block, m).instance_exec(a,b,c,d,e,f,g,h,&block) }
        else    lambda{|*args| new(block, m).instance_exec(*args,&block) }
        end
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
