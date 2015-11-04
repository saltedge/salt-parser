module SaltParser
  module Swift
    class Account < SaltParser::Base
      attr_accessor :account_identification, :closing_balance, :transactions

      BALANCE_TYPE = {
        "F" => :start,
        "M" => :intermediate
      }
      SIGN = {
        "C" => :credit,
        "D" => :debit
      }

      def initialize
        @transactions = []
      end

      def to_hash
        {
          :account_identification => account_identification,
          :closing_balance        => closing_balance,
          :transactions           => transactions.map(&:to_hash)
        }
      end

      def parse_account_identification(options)
        @account_identification = options[:content]
      end

      def parse_closing_balance(options)
        match_data = options[:content].match(/^(?<sign>C|D)(?<raw_date>\w{6})(?<currency>\w{3})(?<amount>\d{1,12},\d{0,2})$/) || {}
        hash                = {}
        hash[:balance_type] = BALANCE_TYPE[options[:modifier]]
        hash[:sign]         = SIGN[match_data[:sign]]
        hash[:currency]     = match_data[:currency]
        hash[:amount]       = match_data[:amount].gsub(',', '').to_i #amount in cents

        date = match_data[:raw_date].match(/(?<year>\d{2})(?<month>\d{2})(?<day>\d{2})/) rescue nil
        hash[:date] = Date.new(2000 + date[:year].to_i, date[:month].to_i, date[:day].to_i) rescue nil

        @closing_balance = hash
      end
    end
  end
end