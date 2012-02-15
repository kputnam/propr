module Propr

  class RSpecProperty < Property
    def initialize(group, name, options, rand, body)
      super(name, rand, body)

      @options, @group =
        options, group
    end

    def check(*input, &block)
      # This is to work around RSpec's magic dynamic scoping
      property = self
      location = location(block || caller)

      if block_given?
        @group.example(@name, @options.merge(caller: location)) do
          begin
            100.times do |n|
              input = yield(property.rand)
              property.call(*input) \
                or property.error("Falsifiable after #{n} tests", location)
            end
          rescue => e
            e.message << "\n    with: #{input.inspect}"
            e.message << "\n    seed: #{srand}"
            raise e
          end
        end
      else
        @group.example(@name, @options.merge(caller: location)) do
          begin
            property.call(*input) \
              or property.error("Falsifiable", location)
          rescue => e
            e.message << "\n    with: #{input.inspect}"
            e.message << "\n    seed: #{srand}"
            raise e
          end
        end
      end

      self
    end

    def error(message, location)
      raise ::RSpec::Expectations::ExpectationNotMetError,
        message, location
    end

  private

    def location(data)
      case data
      when Proc
        ["#{data.source_location.join(":")}:0"]
      when Array
        [data.first]
      end
    end
  end

  # Constants and methods live in separate namespaces, so this
  # is one way to memoize the method with a default arg (Random).
  RSpec = RSpec(Random.new)
end
