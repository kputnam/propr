module Propr
  autoload :Characters, "propr/characters"
  autoload :Property,   "propr/property"
  autoload :Random,     "propr/random"
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

require "propr/rspec"
require "propr/testunit"
