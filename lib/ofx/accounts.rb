module SaltParser
  module OFX
    class Accounts < SaltParser::Accounts
      def find_by_transaction(transaction)
        find(transaction.account_id)
      end
    end
  end
end
