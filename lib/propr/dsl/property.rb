module Propr
  module Dsl

    class PropDsl
      def fails?(type = Exception)
        begin
          yield
          false
        rescue => e
          e.is_a?(type)
        end
      end

      def bind(f, &g)
        Random.bind(f, &g)
      end

      def unit(value)
        Random.unit(value)
      end
    end

  end
end
