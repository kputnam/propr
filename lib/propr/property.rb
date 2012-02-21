module Propr
  class Property #< Proc

    # @return [String]
    attr_reader :name

    # @return [Propr::Random]
    attr_reader :rand

    def initialize(name, rand, body)
      @name, @rand, @body =
        name, rand, body || lambda {|*_| raise "default property" }
    end

    # @return [Boolean]
    def check(*args)
      if block_given?
        iterations = 0..100
        iterations.all? do
          args = yield(rand)
          @rand.instance_exec(*args, &@body)
        end
      else
        @rand.instance_exec(*args, &@body)
      end
    end

    def arity
      @body.arity
    end

    def call(*args, &block)
      @rand.instance_exec(*args, &@body)
    end

    def [](*args, &block)
      @rand.instance_exec(*args, &@body)
    end

  end
end
