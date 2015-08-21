module SaltParser
  module Qif
    class Builder
      attr_reader :header
      attr_reader :body
      attr_reader :content
      attr_reader :parser

      def initialize(resource, date_format="%m/%d/%Y")
        resource = open_resource(resource)
        resource.rewind

        @content = convert_to_utf8(resource.read)
        prepare(content)

        @parser = Parser.new(:header => header, :body => body, :date_format => date_format)
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
        # ignore internal Quicken information
        # http://en.wikipedia.org/wiki/Quicken_Interchange_Format#Header_line
        split_content = content.split(/(^!.+)/).reject(&:blank?).map(&:strip)
        split_content.each_slice(2) do |slice|
          if slice.length == 1
            @body   = slice.first
          else
            next if Qif::Accounts::NOT_SUPPORTED_ACCOUNTS.keys.include?(slice.first)
            @header = slice.first
            @body   = slice.last
          end
        end

        if body.nil? or body.match(/(^!.+)/)
          raise SaltParser::Error::EmptyFileBody.new
        end
      end

      def convert_to_utf8(string)
        return string if Kconv.isutf8(string)
        string.encode(Encoding::UTF_8.to_s, Encoding::ISO_8859_1.to_s)
      rescue Exception
        raise SaltParser::Error::InvalidEncoding.new
      end
    end
  end
end
