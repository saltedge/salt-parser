module OFX
  module Parser
    class OFX102 < BaseParser
      VERSION = "1.0.2"

      def self.parse_headers(header_text)
        # TODO: refactor
        # Change single CR's to LF's to avoid issues with some banks
        header_text.gsub!(/\r(?!\n)/, "\n")

        # Parse headers. When value is NONE, convert it to nil.
        headers = header_text.to_enum(:each_line).inject({}) do |memo, line|
          _, key, value = *line.match(/^(.*?):(.*?)\s*(\r?\n)*$/)

          unless key.nil?
            memo[key] = value == "NONE" ? nil : value
          end

          memo
        end

        return headers unless headers.empty?
      end
    end
  end
end
