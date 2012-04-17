module Propr
  class Property
    # @return [Proc]
    def self.new(name, body)
      body.instance_variable_set(:@name, name)

      # @return [String]
      body.define_singleton_method(:name) { @name }

      # @return [Boolean]
      body.define_singleton_method(:check) do |*args, &block|
        if block.nil?
          true == call(*args)
        else
          count = args.first || 100
          count.times.all? { true == call(*block.call) }
        end
      end

      body
    end
  end
end
