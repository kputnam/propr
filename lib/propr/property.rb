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
        iterations.all? { @body.call(*yield(@rand)) }
      else
        @body.call(*args)
      end
    end

    def arity
      @body.arity
    end

    def call(*args, &block)
      @body.call(*args, &block)
    end

    def [](*args, &block)
      @body[*args, &block]
    end

  end
end
