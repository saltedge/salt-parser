module SaltParser
  module OFX
    class Balance < SaltParser::Base
      attr_accessor :amount
      attr_accessor :amount_in_pennies
      attr_accessor :posted_at

      def to_hash
        {
          :amount            => amount,
          :amount_in_pennies => amount_in_pennies,
          :posted_at         => posted_at
        }
      end
    end
  end
end
