module Propr
  autoload :Property,     "propr/property"
  autoload :Dsl,          "propr/dsl"
  autoload :Runner,       "propr/runner"
  autoload :RSpec,        "propr/rspec"
  autoload :RSpecAdapter, "propr/rspec"

  require "fr"
  require "propr/random"

  class GuardFailure < StandardError
  end

  class Falsifiable < StandardError
    attr_reader :counterex, :shrunken, :passed, :skipped

    def initialize(counterex, shrunken, passed, skipped)
      @counterex, @shrunken, @passed, @skipped =
        counterex, shrunken, passed, skipped
    end

    def to_s
      if @shrunken.nil?
        ["input: #{Array(@counterex).map(&:inspect).join(", ")}",
         "after: #{@passed} passed, #{@skipped} skipped"].join("\n")
      else
        ["input:    #{Array(@counterex).map(&:inspect).join(", ")}",
         "shrunken: #{Array(@shrunken).map(&:inspect).join(", ")}",
         "after: #{@passed} passed, #{@skipped} skipped"].join("\n")
      end
    end
  end

  class Failure < StandardError
    attr_reader :counterex, :shrunken, :passed, :skipped

    def initialize(exception, counterex, shrunken, passed, skipped)
      @exception, @counterex, @shrunken, @passed, @skipped =
        exception, counterex, shrunken, passed, skipped
    end

    def class
      @exception.class
    end

    def backtrace
      @exception.backtrace
    end

    def to_s
      if @shrunken.nil?
        [@exception.message,
         "input: #{Array(@counterex).map(&:inspect).join(", ")}",
         "after: #{@passed} passed, #{@skipped} skipped"].join("\n")
      else
        [@exception.message,
         "input:    #{Array(@counterex).map(&:inspect).join(", ")}",
         "shrunken: #{Array(@shrunken).map(&:inspect).join(", ")}",
         "after: #{@passed} passed, #{@skipped} skipped"].join("\n")
      end
    end

    alias_method :message, :to_s
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
