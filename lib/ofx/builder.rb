module SaltParser
  module OFX
    class Builder
      attr_reader :headers
      attr_reader :body
      attr_reader :content
      attr_reader :parser

      def initialize(resource)
        resource = open_resource(resource)
        resource.rewind
        begin
          @content        = convert_to_utf8(resource.read)
          @headers, @body = prepare(content)
        rescue Exception
          raise SaltParser::Error::UnsupportedFileError
        end

        case headers["VERSION"]
        when /102|103/ then
          @parser = SaltParser::OFX::Parser::OFX102.new(:headers => headers, :body => body)
        when /200|202|211/ then
          @parser = SaltParser::OFX::Parser::OFX211.new(:headers => headers, :body => body)
        else
          raise SaltParser::Error::UnsupportedFileError
        end
      end

      def open_resource(resource)
        if resource.respond_to?(:read)
          resource
        else
          open(resource)
        end
      rescue Exception
        StringIO.new(resource)
      end

      private

      def prepare(content)
        # split headers & body
        header_text, body_text = content.dup.split(/<OFX>/, 2)
        header_text.gsub!("encoding=\"USASCII\"", "encoding=\"US-ASCII\"") if header_text.include?("encoding=\"USASCII\"")

        raise SaltParser::Error::UnsupportedFileError unless body_text

        headers = extract_headers(header_text)
        body    = extract_body(body_text)

        [headers, body]
      end

      def extract_headers(header_text)
        # Header format is different between versions. Give each
        # parser a chance to parse the headers.
        headers = nil

        SaltParser::OFX::Parser.constants.grep(/OFX/).each do |name|
          headers = SaltParser::OFX::Parser.const_get(name).parse_headers(header_text)
          break if headers
        end

        raise SaltParser::Error::UnsupportedFileError if headers.empty?
        headers
      end

      def extract_body(body_text)
        # Replace body tags to parse it with Nokogiri
        body_text.gsub!(/>\s+</m, "><")
        body_text.gsub!(/\s+</m, "<")
        body_text.gsub!(/>\s+/m, ">")
        body_text.gsub!(/<(\w+?)>([^<]+)/m, '<\1>\2</\1>')
      end

      def convert_to_utf8(string)
        return string if Kconv.isutf8(string)
        string.encode(Encoding::UTF_8.to_s, Encoding::ISO_8859_1.to_s)
      end
    end
  end
end
