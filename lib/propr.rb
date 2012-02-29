module Propr
  autoload :Property,       "propr/property"
  autoload :Dsl,            "propr/dsl"
  autoload :RSpec,          "propr/rspec"
  autoload :RSpecProperty,  "propr/rspec"

  # Monkey patches
  require "propr/unfold"
  require "propr/monad"
  require "propr/instances"

  class GuardFailure < StandardError
  end

  class NoMoreTries < StandardError
    # @return [Integer]
    attr_reader :tries

    def initialize(tries)
      @tries = tries
    end

    # @return [String]
    def to_s
      "Exceeded #{@tries} failed guards"
    end
  end

  def self.RSpec(checkdsl, propdsl)
    Module.new.tap do |m|
      m.send(:define_method, :property) { raise }
      m.send(:define_singleton_method, :rand) { rand }
      m.send(:define_singleton_method, :included) do |scope|
        scope.send(:define_singleton_method, :property) do |name, options = {}, &body|
          RSpecProperty.new(self, name, options, lambda {|*args| Dsl::Check.instance_exec(*args, &body) })
        end

        scope.send(:define_singleton_method, :mproperty) do |name, options = {}, &body|
          RSpecProperty.new(self, name, options, lambda {|*args| Random.eval(Dsl::Check.instance_exec(*args, &body)) })
        end
      end
    end
  end
end
