module SaltParser
  module OFX
    class Transaction < SaltParser::Base
      attr_accessor :amount, :amount_in_pennies, :check_number, :fit_id,
                    :memo, :name, :payee, :posted_at, :ref_number, :type,
                    :sic, :units, :unit_price, :account_id

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
end
