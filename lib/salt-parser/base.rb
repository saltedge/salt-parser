module SaltParser
  class Base
    def initialize(attrs)
      attrs.each do |key, value|
        send("#{key}=", value)
      end
    end
  end
end