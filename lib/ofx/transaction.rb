module OFX
  class Transaction < Base
    attr_accessor :amount
    attr_accessor :amount_in_pennies
    attr_accessor :check_number
    attr_accessor :fit_id
    attr_accessor :memo
    attr_accessor :name
    attr_accessor :payee
    attr_accessor :posted_at
    attr_accessor :ref_number
    attr_accessor :type
    attr_accessor :sic
    attr_accessor :units
    attr_accessor :unit_price
    attr_accessor :account_id

    def to_hash
      {
        :amount             => amount,
        :amount_in_pennies  => amount_in_pennies,
        :check_number       => check_number,
        :fit_id             => fit_id,
        :memo               => memo,
        :name               => name,
        :payee              => payee,
        :posted_at          => posted_at,
        :ref_number         => ref_number,
        :type               => type,
        :sic                => sic,
        :units              => units,
        :unit_price         => unit_price,
        :account_id         => account_id
      }
    end
  end
end
