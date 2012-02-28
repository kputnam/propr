module Propr
  module Monad

    # Poor man's polymorphism
    def self.included(base)
      methods = [:sequence, :join]
      methods.each do |name|
        base.define_singleton_method(name) do |*args, &block|
          Propr::Monad.send(name, base, *args, &block)
        end
      end
    end

    # Perform each action, from left to right
    # :: (Monad m) => [m a] -> m [a]
    def self.sequence(m, actions)
      actions.inject(m.unit []) do |prev, curr|
        m.bind(prev) do |xs|
          m.bind(curr) do |x|
            m.unit(xs + [x])
          end
        end
      end
    end

    # Remove one level of monadic structure
    # :: (Monad m) => m (m a) -> m a
    def self.join(m, action)
      m.bind(action){|x| x }
    end

  end
end

require "propr/monad/array"
require "propr/monad/maybe"
require "propr/monad/state"
require "propr/monad/random"
