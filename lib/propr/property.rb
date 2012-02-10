class Propr

  module Macro

    def self.included(exgroup)
      exgroup.extend(ClassMethods)
    end

    module ClassMethods
      def property(*args, &setup)
        # Due to late-binding, `self` is the current RSpec example group
        Propr.property(self, *args, &setup)
      end
    end

  end

  class << self
    def property(exgroup, *args, &setup)
      Propr::Property.new(exgroup, new, *args, &setup)
    end
  end

  class Property

    # @return [String]
    attr_reader :name

    # @return [Class<Propr>]
    attr_reader :propr

    # @return [Class]
    attr_reader :exgroup

    # @return [Proc]
    attr_reader :setup

    def initialize(exgroup, propr, *args, &setup)
      @exgroup, @propr, @args, @setup =
        exgroup, propr, args, setup
    end

    def check(cases = 100, limit = 10, &block)
      if @args.last.is_a?(Hash)
        args = @args.slice(0..-2)
        hash = @args.last
        hash[:random] = true

        args << hash
      else
        args = @args
        args << Hash[:random => true]
      end

      property = self

      @exgroup.specify(*args) do
        if property.setup.nil?
          pending
          return
        end

        count = 0

        if block.nil?
          begin
            property.propr.generate(cases, limit, property.setup) do
              count += 1
              property.progress(count, cases)
            end
          rescue
            seed = srand # Get the previous seed by setting it
            srand(seed)  # But immediately restore it

            $!.message << " -- with srand #{seed} after #{count} successes"
            raise $!
          end
        elsif block.arity == 1
          property.propr.generate(cases, limit, property.setup) do |input|
            begin
              instance_exec(input, &block)

              count += 1
              property.progress(count, cases)
            rescue
              seed = srand # Get the previous seed by setting it
              srand(seed)  # But immediately restore it

              $!.message << " -- with srand #{seed} after #{count} successes, input: #{input.inspect}"
              raise $!
            end
          end

        else
          property.propr.generate(cases, limit, property.setup) do |input|
            begin
              instance_exec(*input, &block)

              count += 1
              property.progress(count, cases)
            rescue
              seed = srand # Get the previous seed by setting it
              srand(seed)  # But immediately restore it

              $!.message << " -- with srand #{seed} after #{count} successes, input: #{input.inspect}"
              raise $!
            end
          end

        end
      end
    end

    PROGRESS = %w(% $ @ # &)

    if $stdout.tty?
      def progress(completed, total)
        print((completed == total) ? "" : "#{PROGRESS[completed % 4]}\010")
      end
    else
      def progress(completed, total)
      end
    end

  end
end
