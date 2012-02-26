module Propr

  class << Maybe

    # Evaluators
    #############################################
    def run(computation)
      computation
    end

    # Combinators
    #############################################

    def fail(reason)
      None
    end

    def unit(value)
      Some.new(value)
    end

    def bind(f, &g)
      f.fold(f, &g)
    end

  end
end
