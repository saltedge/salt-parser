module SaltParser
  module Qif
    class Account < SaltParser::Base
      attr_accessor :name, :type, :transactions

      def identifier
        name
      end

      def to_hash
        {
          :name         => name,
          :type         => type,
          :transactions => transactions.map(&:to_hash)
        }
      end
    end
  end
end
