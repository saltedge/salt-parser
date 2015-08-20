module SaltParser
  module Qif
    class Error < StandardError
      EmptyFileBody         = "File body is blank."
      InvalidEncoding       = "Invalid file encoding, expected: '%{encoding}'."
      UnsupportedDateFormat = "Could not parse date with format: '%{format}'."
    end
  end
end
