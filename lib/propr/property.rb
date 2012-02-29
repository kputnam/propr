module Propr
  class Property #< Proc

    # @return [String]
    attr_reader :name

    def initialize(name, body)
      @name, @body =
        name, body
    end

    # @return [Boolean]
    def check(*args)
      if block_given?
        count = args.first || 100
        count.times.all? { true == @body.call(*yield) }
      else
        true == @body.call(*args)
      end
    end

    def arity
      @body.arity
    end

    def call(*args, &block)
      @body.call(*args)
    end

    def [](*args, &block)
      @body.call(*args)
    end

  end
end
