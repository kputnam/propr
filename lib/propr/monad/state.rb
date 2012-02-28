module Propr

  class State
    include Monad
  end

  class << State

    # Evaluators
    #############################################

    def run(computation, state)
      computation.call(state)
    end

    def eval(computation, state)
      computation.call(state)[:value]
    end

    def exec(computation, state)
      computation.call(state)[:state]
    end

    # Combinators
    #############################################

    def unit(value)
      lambda do |state|
        Hash[state: state, value: value]
      end
    end

    def bind(f, &g)
      lambda do |state|
        result = f.call(state)
        g.call(result[:value]).call(result[:state])
      end
    end

    # Actions
    #############################################

    def put(n)
      lambda do |state|
        Hash[state: n, value: nil]
      end
    end

    def get
      lambda do |state|
        Hash[state: state, value: state]
      end
    end

    def update
      lambda do |state|
        Hash[state: yield(state), value: nil]
      end
    end

  end
end
