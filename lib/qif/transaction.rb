module SaltParser
  module Qif
    class Transaction < SaltParser::Base
      SUPPORTED_FIELDS = {
        "D" => :date     , # Date
        "T" => :amount   , # Amount
        "C" => :status   , # Cleared status
        "N" => :number   , # Num (check or reference number)
        "P" => :payee    , # Payee
        "M" => :memo     , # Memo
        "L" => :category   # Category (Category/Subcategory/Transfer/Class)
      }
      SUPPORTED_FIELDS.values.each{ |field| attr_accessor field }

      def to_hash
        {
          :date     => date,
          :amount   => amount,
          :status   => status,
          :number   => number,
          :payee    => payee,
          :memo     => memo,
          :category => category
        }
      end
    end
  end
end
