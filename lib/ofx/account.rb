module OFX
  class Account < Base
    attr_accessor :balance
    attr_accessor :bank_id
    attr_accessor :broker_id
    attr_accessor :currency
    attr_accessor :id
    attr_accessor :name
    attr_accessor :transactions
    attr_accessor :type
    attr_accessor :units
    attr_accessor :unit_price
    attr_accessor :available_balance

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
