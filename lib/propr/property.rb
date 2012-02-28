module Propr
  class Property #< Proc

    # @return [String]
    attr_reader :name

    def initialize(name, body)
      @name, @body =
        name, body || lambda {|*_| raise "no block given to property" }
    end

    # @return [Boolean]
    def check(*args, &block)
      if block_given?
        100.times.all? do
          args = CheckDsl.instance_exec(&block)
        # @propdsl.instance_exec(*args, &@body)
          @body.call(*args)
        end
      else
      # @propdsl.instance_exec(*args, &@body)
        @body.call(*args)
      end
    end

    def arity
      @body.arity
    end

    def call(*args, &block)
    # @propdsl.instance_exec(*args, &@body)
      @body.call(*args)
    end

    def [](*args, &block)
    # @propdsl.instance_exec(*args, &@body)
      @body.call(*args)
    end

  end
end
