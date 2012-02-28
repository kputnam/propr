class String
  # @return [Array<String>]
  def shrink
    case size
    when 0 then []
    when 1
      shrunken = []
      shrunken << downcase if self =~ /[[:upper:]]/
      shrunken << " " if self > " "
      shrunken << "a" if self > "a"
      shrunken << "A" if self > "A"
      shrunken << "0" if self > "0"
      shrunken << ""
      shrunken
    else
      split(//).shrink.map(&:join)
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
  def random(options = {}, m = Propr::Random)
    min     = options.fetch(:min, 0)
    max     = options.fetch(:max, 10)
    charset = Characters.of(options.fetch(:charset, :print))

    m.bind(Integer.random(min: min, max: max, center: min)) do |size|
      m.bind(m.sequence(size.times.map{|_| charset.random })) do |chars|
        m.unit(chars.join)
      end
    end
  end
end
