module Propr
  class Property
    # @return [String]
    attr_reader :name

    # @return [Proc]
    attr_reader :body

    def initialize(name, base, body)
      @name, @base, @body = name, base, body
    end

    def check(*args, &setup)
      self
    end

    PROGRESS = %w(% $ @ # &)

    def progress(completed, total)
    end

  if $stdout.tty?
    def progress(completed, total)
      print((completed == total) ? "" : "#{PROGRESS[completed % 4]}\010")
    end
  end

  end
end
