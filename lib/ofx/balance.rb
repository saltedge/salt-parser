module SaltParser
  module Ofx
    class Balance < SaltParser::Base
      attr_accessor :amount, :amount_in_pennies, :posted_at

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
