# This class is designed to be subclassed, to avoid polluting the minimal
# base class. Subclasses can add parameters with the macro "has_parameter",
# and parameters are inherited when subclassing.
class Propr
  autoload :Characters, "propr/characters"
  autoload :Property,   "propr/property"
  autoload :Macro,      "propr/property"
  autoload :Values,     "propr/values"

  def initialize
    @bindings = []
  end
end

class << Propr
  # Generate `count` values, returning nil
  def each(count, limit = 10, &block)
    new.each(count, limit, &block)
  end

  # Generate an array of `count` values
  def map(count, limit = 10, &block)
    new.map(count, limit, &block)
  end

  # Generate a single value
  def value(limit = 10,  &block)
    new.value(limit, &block)
  end

  def generate(count, limit, setup, &block)
    new.generate(count, limit, setup, &block)
  end

  # @return [Class]
  def default
    @default ||= (superclass == Object) ?
      Class.new.new :
      Class.new(superclass).new
  end

  # @return [void]
  def has_parameter(name, value)
    scope = self
    define_method(name) { instance_variable_get("@_parameter_#{name}") || scope.default.send(name) }
    default.class.send(:define_method, name) { value }
  end
end

class Propr
  include Propr::Values

  class GuardFailure < StandardError; end

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

  # Controls the size of sized generators: array, string
  has_parameter :size, 6

  # Generate `count` values, returning nil
  def each(count, limit = 10, &setup)
    generate(count, limit, setup)
  end

  # Generate an array of `count` values
  def map(count, limit = 10, &setup)
    acc = []; generate(count, limit, setup) {|x| acc << x }; acc
  end

  # Generate a single value
  def value(limit = 10, &setup)
    generate(1, limit, setup) {|x| return x }
  end

  def generate(count, limit, setup, &block)
    retries  = count * limit
    failures = successes = 0

    @bindings.push(eval("self", block.binding))

    while successes < count
      raise NoMoreTries.new(count * limit, failures) if retries < 0

      begin
        retries -= 1
        value    = instance_eval(&setup)
      rescue GuardFailure
        failures += 1
      else
        successes += 1
        yield(value) if block_given?
      end
    end

    @bindings.pop
  end

  def guard(condition)
    raise GuardFailure unless condition
  end

  # Called with a block, sets `parameters` temporarily while evaluating the
  # block, and returns the value of the block. Without a block, this
  # permanently sets `parameters`
  def with(*parameters)
    parameters = Hash[*parameters]

    if block_given?
      # Copy current parameters to a safe place
      prev = instance_variables.grep(/@_parameter/).inject({}) do |hash, name|
        hash.update(name => instance_variable_get(name))
      end

      # Update the given parameters
      parameters.each{|name, value| instance_variable_set("@_parameter_#{name}", value) }

      begin
        yield
      ensure
        # Remove all the parameters
        instance_variables.each do |name|
          next unless /^@_parameter_/ =~ name
          remove_instance_variable(name)
        end

        # Restore previous parameters from the copy
        prev.each{|name, value| instance_variable_set(name, value) }
      end
    else
      parameters.each{|name, value| instance_variable_set("@_parameter_#{name}", value) }
    end
  end

  # Generate a weighted value by calling the tail of each element
  #
  # @example
  #   freq [1, :literal, "one"],
  #        [2, :string],
  #        [3, :string, :alpha],
  #        [4, [:string, :alpha]],
  #        [5, lambda{ with(:size, 2) { string }}],
  #        [6, lambda{|x| with(:size, x) { string }}, 2]
  def freq(*pairs)
    total = 0
    pairs = pairs.map do |p|
      case p
      when Symbol, String, Proc
        total += 1; [1, p]
      when Array
        total += p.first; p
      end
    end

    index = between(1, total)
    pairs.each do |p|
      weight, generator, *args = p
      if index <= weight
        return call(generator, *args)
      else
        index -= weight
      end
    end
  end

  # Generates an element from the given array of values
  def choose(values)
    values[between(0, values.length - 1)]
  end

  # Executes `call` on a random element from the given array of values
  def branch(generators)
    call(choose(generators))
  end

  # Executes the given generator
  #
  # @example
  #   call(:integer)
  #   call(:choose, [1,2,3])
  #   call([:choose, [1,2,3]])
  #   call(lambda { choose([1,2,3]) }
  def call(generator, *args)
    case generator
    when Symbol, String
      send(generator, *args)
    when Array
      send(generator.first, *generator.slice(1..-1))
    when Proc
      @bindings.push(eval("self", generator.binding))

      instance_eval { generator.call(*args) }.tap do
        @bindings.pop
      end
    else
      raise ArgumentError, "unrecognized generator type #{generator.inspect}"
    end
  end

private

  def method_missing(name, *args, &block)
    unless @bindings.empty?
      @bindings.last.__send__(name, *args, &block)
    else
      super
    end
  end
end
