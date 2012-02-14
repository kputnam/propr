module Propr
  def self.RSpec(rand)
    Module.new.tap do |m|
      m.send(:define_method, :property) { raise }
      m.send(:define_singleton_method, :rand) { rand }
      m.send(:define_singleton_method, :included) do |scope|
        scope.send(:define_singleton_method, :property) do |name, &body|
          RSpecProperty.new(self, name, rand, body)
        end
      end
    end
  end

  class RSpecProperty < Property
    def initialize(group, name, rand, body)
      super(name, rand, body)
      @group = group
    end

    def check(*args)
      # Restore access to lexical scope, despite RSpec
      property = self

      if block_given?
        @group.it(@name) do
          begin
            args       = nil
            iterations = 0..100
            iterations.all? { property.call(*(args = yield(property.rand))).should be_true }
          rescue => e
            e.message << "\n    with: #{args.inspect}"
            e.message << "\n    seed: #{srand}"
            raise e
          end
        end
      else
        @group.it(@name) do
          begin
            property.call(*args).should be_true
          rescue => e
            e.message << "\n    with: #{args.inspect}"
            e.message << "\n    seed: #{srand}"
            raise e
          end
        end
      end

      self
    end
  end

  # Constants and methods live in separate namespaces, so this
  # is one way to memoize the method with a default arg (Base).
  # RSpec = RSpec(Base)
end
