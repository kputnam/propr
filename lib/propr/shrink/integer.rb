class Integer
  # @return [Enumerator<Integer>]
  def shrink
    Array.unfold(self) do |seed|
      zero  = 0
      seed_ = zero + (seed - zero) / 2
      (seed != seed_).maybe([zero + self - seed, seed_])
    end
  end
end
