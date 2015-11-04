module SaltParser
  module Swift
    class Builder < SaltParser::Builder
      def initialize(resource)
        resource = open_resource(resource)
        resource.rewind

        @parser  = SaltParser::Swift::Parser.new(:data => convert_to_utf8(resource.read))
      end
    end
  end
end
