module SaltParser
  module Qif
    class Builder < SaltParser::Builder

      def initialize(resource, date_format="%m/%d/%Y")
        resource = open_resource(resource)
        resource.rewind

        @content = convert_to_utf8(resource.read)
        prepare(content)

        @parser = Parser.new(:headers => headers, :body => body, :date_format => date_format)
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
            @headers = slice.first
            @body    = slice.last
          end
        end

        if body.nil? or body.match(/(^!.+)/)
          raise SaltParser::Error::EmptyFileBody
        end
      end
    end
  end
end
