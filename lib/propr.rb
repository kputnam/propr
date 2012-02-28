module Propr
  autoload :Property,       "propr/property"
  autoload :PropDsl,        "propr/propdsl"
  autoload :CheckDsl,       "propr/checkdsl"
  autoload :RSpec,          "propr/rspec"
  autoload :RSpecProperty,  "propr/rspec"

  # Monkey patches
  require "propr/util"
  require "propr/types"
  require "propr/monad"

  class GuardFailure < StandardError
  end

  class NoMoreTries < StandardError
    # @return [Integer]
    attr_reader :limit

    # @return [Integer]
    attr_reader :tries

    def initialize(limit, tries)
      @limit, @tries = limit, tries
    end

    # @return [String]
    def to_s
      "Exceeded limit #{limit}: #{tries} failed guards"
    end
  end

  def self.RSpec(checkdsl, propdsl)
    Module.new.tap do |m|
      m.send(:define_method, :property) { raise }
      m.send(:define_singleton_method, :rand) { rand }
      m.send(:define_singleton_method, :included) do |scope|
        scope.send(:define_singleton_method, :property) do |name, options = {}, &body|
          RSpecProperty.new(self, name, options, lambda {|*args| propdsl.instance_exec(*args, &body) })
        end

        scope.send(:define_singleton_method, :mproperty) do |name, options = {}, &body|
          RSpecProperty.new(self, name, options, lambda {|*args| Random.eval(propdsl.instance_exec(*args, &body)) })
        end
      end
    end
  end
end
