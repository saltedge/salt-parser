module OFX
  module Parser
    class OFX211 < BaseParser
      VERSION = "2.1.1"

      def self.parse_headers(header_text)
        Nokogiri::XML(header_text).children.each do |element|
          if element.name == "OFX"
            headers = element.text.gsub("\"",'')
                             .split(/\s+/)
                             .map { |el| el.split("=") }
                             .flatten
            return Hash[*headers]
          end
        end
      end
    end
  end
end
