module Propr
  class Random
    # Create a property which can be checked with random data generated
    # by this instance. Doesn't need to be overridden in subclasses of
    # `Random`, as `this` is late-binding.
    #
    # @return [Propr::Property]
    def self.property(name, &body)
      Property.new(name, new, body)
    end

    # Throw a GuardFailure if predicate is not satisfied, or return the
    # given value. When no predicate is given, throws GuardFailure if
    # the given value is not truthy.
    def guard(value)
      if block_given?
        if yield(*value)
          value
        else
          raise GuardFailure
        end
      else
        value or raise GuardFailure
      end
    end

    def fails?(type = Exception)
      begin
        yield
        false
      rescue => e
        e.is_a?(type)
      end
    end

  end
end
