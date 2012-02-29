module Propr
  module Dsl

    class Check
      def eval(*args)
        Random.eval(*args)
      end

      def bind(*args, &block)
        Random.bind(*args, &block)
      end

      def guard(*args, &block)
        Random.guard(*args, &block)
      end
    end

  end
end
