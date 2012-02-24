module Propr

  class State
    attr_reader :state
    attr_reader :value

    def initialize(state, value)
      @state, @value = state, value
    end
  end

  class << State

    # Evaluators
    #############################################

    def run(computation, state)
      computation.call(state)
    end

    def eval(computation, state)
      computation.call(state).value
    end

    def exec(computation, state)
      computation.call(state).state
    end

    # Combinators
    #############################################

    def unit(value)
      lambda do |state|
        new(state, value)
      end
    end

    def bind(f, &g)
      lambda do |state|
        wrapper = f.call(state)
        g.call(wrapper.value).call(wrapper.state)
      end
    end

    # Actions
    #############################################

    def put(n)
      lambda do |state|
        new(n, nil)
      end
    end

    def get
      lambda do |state|
        new(state, state)
      end
    end

  end
end
