class Array
  def propo
    if empty?
      raise "no elements"
    else
      self[Integer.propr(min: 0, max: length - 1)]
    end
  end
end

class << Array
  def propr(options = {})
  end
end
