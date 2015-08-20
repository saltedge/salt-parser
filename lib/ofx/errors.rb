module OFX
  class UnsupportedFileError < StandardError; end
  class RequestError         < StandardError; end
  class ParseError           < StandardError
    AMOUNT = "Error while parsing numeric field."
    TIME   = "Error while parsing time field."
    FLOAT  = "Error while parsing float field."
  end
end
