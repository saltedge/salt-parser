module SaltParser
  module Ofx
    class Account < SaltParser::Base
      attr_accessor :balance, :bank_id, :broker_id, :currency, :id, :name,
                    :transactions, :type, :units, :unit_price, :available_balance

      def identifier
        id
      end

      def to_hash
        {
          :balance           => balance ? balance.to_hash : nil,
          :bank_id           => bank_id,
          :broker_id         => broker_id,
          :currency          => currency,
          :id                => id,
          :name              => name,
          :transactions      => transactions.map(&:to_hash),
          :type              => type,
          :units             => units,
          :unit_price        => unit_price,
          :available_balance => available_balance ? available_balance.to_hash : nil
        }
      end
    end
  end
end
