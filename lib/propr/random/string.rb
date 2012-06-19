class << String
  module Characters
    ASCII = (0..127).inject("", &:<<)
    ALL   = (0..255).inject("", &:<<)

    def self.of(regexp, set = Characters::ALL)
      CLASSES[regexp] || set.scan(regexp)
    end

    CLASSES = Hash.new
    CLASSES.update \
      :any    => ALL.split(//),
      :ascii  => ASCII.split(//),
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
    min     = options[:min] || 0
    max     = options[:max] || 10
    options = Hash[center: min].merge(options)
    charset = Characters.of(options.fetch(:charset, :print))

    m.bind(Integer.random(options.merge(min: min, max: max))) do |size|
      m.bind(m.sequence(size.times.map { charset.random })) do |chars|
        m.unit(chars.join)
      end
    end
  end
end
