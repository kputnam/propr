class String
  # @return [Array<String>]
  def shrink
    case size
    when 0 then []
    when 1
      shrunken = []
      shrunken << downcase if self =~ /[[:upper:]]/
      shrunken << " " if self =~ /(?! )\s/
      shrunken << "a" if self =~ /[b-z]/
      shrunken << "A" if self =~ /[B-Z]/
      shrunken << "0" if self =~ /[1-9]/
      shrunken << ""
      shrunken
    else
      split(//).shrink.map(&:join)
    end
  end
end
