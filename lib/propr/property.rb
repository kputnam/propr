module Propr
  class Property #< Proc

    # @return [String]
    attr_reader :name

    # @return [Propr::Base]
    attr_reader :rand

    def initialize(name, rand, body)
      @name, @rand, @body = name, rand, body
    end

    # @return [Boolean]
    def check(*args)
      if block_given?
        iterations = 0..100
        iterations.all? { call(*yield(@rand)) }
      else
        call(*args)
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
