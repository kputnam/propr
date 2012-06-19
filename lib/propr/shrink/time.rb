class Time
  def shrink
    Array.unfold(to_f) do |seed|
      zero  = 0 # 1969-12-31 00:00:00 UTC
      seed_ = zero + (seed - zero) / 2
      ((seed - seed_).abs > 1e-2).maybe([self + zero - seed, seed_])
    end
  end
end
