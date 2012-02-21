class String
  # @return [Enumerator<String>]
  def shrink
    Enumerator.unfold(self) do |seed|
    end
  end
end

class << String
  module Characters
    ASCII = (0..127).inject("", &:<<)
    ALL   = (0..255).inject("", &:<<)

    def self.of(regexp, set = Characters::ALL)
      CLASSES[regexp] || set.scan(regexp)
    end

    CLASSES = Hash.new
    CLASSES.update \
      :any    => ALL,
      :ascii  => ASCII,
      :alnum  => Characters.of(/[[:alnum:]]/),
      :alpha  => Characters.of(/[[:alpha:]]/),
      :blank  => Characters.of(/[[:blank:]]/),
      :cntrl  => Characters.of(/[[:cntrl:]]/),
      :digit  => Characters.of(/[[:digit:]]/),
      :graph  => Characters.of(/[[:graph:]]/),
      :lower  => Characters.of(/[[:lower:]]/),
      :print  => Characters.of(/[[:print:]]/),
      :punct  => Characters.of(/[[:punct:]]/),
      :space  => Characters.of(/[[:space:]]/),
      :upper  => Characters.of(/[[:upper:]]/),
      :xdigit => Characters.of(/[[:xdigit:]]/)
  end

  # @return [String]
  def random(options = {})
    min     = options.fetch(:min, 0)
    max     = options.fetch(:max, 10)
    size    = Integer.random(min: min, max: max)
    charset = Characters.of(options.fetch(:charset, :print))
    size.times.map{|_| charset.random }.join
  end
end
