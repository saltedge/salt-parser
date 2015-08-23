module SaltParser
  class Builder
    attr_reader :headers, :body, :content, :parser

    private

    def open_resource(resource)
      if resource.respond_to?(:read)
        resource
      else
        open(resource)
      end
    rescue Exception
      StringIO.new(resource)
    end

    def convert_to_utf8(string)
      return string if Kconv.isutf8(string)
      string.encode(Encoding::UTF_8.to_s, Encoding::ISO_8859_1.to_s)
    rescue Exception
      raise SaltParser::Error::InvalidEncoding
    end
  end
end
