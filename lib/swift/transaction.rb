module SaltParser
  module Swift
    class Transaction
      attr_accessor :info
      attr_reader :date, :entry_date, :funds_code, :amount,
                  :swift_code, :reference, :transaction_description

      FUNDS_CORE = {
        "C"  => :credit,
        "D"  => :debit,
        "RC" => :return_credit,
        "RD" => :return_debit
      }

      def initialize(options)
        match_data = options[:content].match(/^(?<raw_date>\d{6})(?<raw_entry_date>\d{4})?(?<funds_code>C|D|RC|RD)\D?(?<amount>\d{1,12},\d{0,2})(?<swift_code>(?:N|F).{3})(?<reference>NONREF|.{0,16})($|\/\/)(?<transaction_description>.*)/) || {}

        @funds_code              = FUNDS_CORE[match_data[:funds_code]]
        @amount                  = match_data[:amount].gsub(',', '').to_i # amount in cents
        @swift_code              = match_data[:swift_code]
        @reference               = match_data[:reference]
        @transaction_description = match_data[:transaction_description]

        @date       = parse_date(match_data[:raw_date])
        @entry_date = parse_entry_date(match_data[:raw_entry_date], @date) if match_data[:raw_entry_date]
      end

      def to_hash
        {
          :date                    => date,
          :entry_date              => entry_date,
          :funds_code              => funds_code,
          :amount                  => amount,
          :swift_code              => swift_code,
          :reference               => reference,
          :transaction_description => transaction_description,
          :info                    => info.try(:to_hash)
        }
      end

      private

      def parse_date(date)
        match_data = date.match(/(?<year>\d{2})(?<month>\d{2})(?<day>\d{2})/)
        Date.new(2000 + match_data[:year].to_i, match_data[:month].to_i, match_data[:day].to_i)
      end

      def parse_entry_date(raw_entry_date, value_date)
        match_data = raw_entry_date.match(/(?<month>\d{2})(?<day>\d{2})/)
        Date.new(value_date.year, match_data[:month].to_i, match_data[:day].to_i)
      end
    end
  end
end