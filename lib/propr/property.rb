module Propr
  class Property < Proc

    # @return [String]
    attr_reader :name

    # @return [Propr::Base]
    attr_reader :rand

    def initialize(name, rand, body)
      super(&body)
      @name, @rand = name, rand
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

  end
end
