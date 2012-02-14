module Propr
  module Macro
    def self.included(base)
      base.extend(ClassMethods)
    end
  end

  module ClassMethods
    def property(name = "", &body)
      Propr.property(name, &body)
    end
  end
end
