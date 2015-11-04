module SaltParser
  module Error
    class EmptyFileBody         < StandardError; end
    class InvalidEncoding       < StandardError; end
    class ParseError            < StandardError
      AMOUNT = "Error while parsing numeric field."
      TIME   = "Error while parsing time field."
      FLOAT  = "Error while parsing float field."
    end
    class RequestError          < StandardError; end
    class UnsupportedTag        < StandardError; end
    class WrongLineFormat       < StandardError; end
    class UnsupportedDateFormat < StandardError; end
    class UnsupportedFileError  < StandardError; end
  end
end
