module Propr
  autoload :Characters, "propr/characters"
  autoload :Property,   "propr/property"
  autoload :Values,     "propr/values"
  autoload :Macro,      "propr/macro"
  autoload :Base,       "propr/base"

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
end

class << Propr
  # Generate `count` values, returning nil
  def each(count, limit = 10, &block)
    instance.each(count, limit, &block)
  end

  # Generate an array of `count` values
  def map(count, limit = 10, &block)
    instance.map(count, limit, &block)
  end

  # Generate a single value
  def value(limit = 10,  &block)
    instance.value(limit, &block)
  end

  def generate(count, limit, setup, &block)
    instance.generate(count, limit, setup, &block)
  end

  def instance
    Base.new
  end

  def property(name = "", &body)
    Propr::Property.new(self, name, body)
  end
end
