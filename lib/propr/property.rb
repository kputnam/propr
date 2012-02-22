module Propr
  class Property #< Proc

    # @return [String]
    attr_reader :name

    # @return [Propr::Random]
    attr_reader :rand

    def initialize(name, rand, body)
      @name, @rand, @body =
        name, rand, body || lambda {|*_| raise "no block given to property" }
    end

    # @return [Boolean]
    def check(*args, &block)
      if block_given?
        100.times.all? do
          args = @rand.instance_exec(&block)
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
