module Propr
  autoload :Property,     "propr/property"
  autoload :Dsl,          "propr/dsl"
  autoload :Runner,       "propr/runner"
  autoload :RSpec,        "propr/rspec"
  autoload :RSpecAdapter, "propr/rspec"

  # Monkey patches
  require "propr/unfold"
  require "propr/monad"
  require "propr/instances"

  class GuardFailure < StandardError
  end

  class Falsifiable < StandardError
    attr_reader :counterex, :passed, :skipped

    def initialize(counterex, passed, skipped)
      @counterex, @passed, @skipped =
        counterex, passed, skipped
    end

    def to_s
      "input: #{@counterex.inspect}\n" +
      "after: #{@passed} passed, #{@skipped} skipped\n"
    end
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

        # @todo: raise an error if body isn't given
        scope.send(:define_singleton_method, :property) do |name, options = {}, &body|
          q = Dsl::Property.wrap(body)
          p = Property.new(name, q)
          RSpecAdapter.new(self, options, p)
        end
      end
    end
  end

  RSpec = RSpec(nil, nil)
end
