class Propr
  module Characters

    ASCII = (0..127).inject("", &:<<)
    ALL   = (0..255).inject("", &:<<)

    class << self
      def of(regexp, set = Characters::ALL)
        set.scan(regexp)
      end
    end

    CLASSES = Hash[
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
      :xdigit => Characters.of(/[[:xdigit:]]/),
      :ascii  => ASCII,
      :any    => ALL]

  end
end
