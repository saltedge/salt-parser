module SaltParser
  module Qif
    class Parser
      attr_reader :header, :body, :accounts, :date_format

      def initialize(options = {})
        @header      = options[:header].try(:chomp)
        @body        = options[:body]
        @date_format = options[:date_format]
        @accounts    = Qif::Accounts.new
        parse_account
      end

      def to_hash
        { :accounts => accounts.to_hash }
      end

      def parse_account
        @accounts << Qif::Account.new({
          :name         => Qif::Accounts::SUPPORTED_ACCOUNTS[header]["name"],
          :type         => Qif::Accounts::SUPPORTED_ACCOUNTS[header]["type"],
          :transactions => build_transactions
        })
      end

      def build_transactions
        transactions_array = body.split("^").reject(&:blank?)
        check_dates(transactions_array)

        transactions_array.each_with_object([]) do |transaction, transactions|
          transaction_hash = build_transaction_hash(transaction.split("\n"))
          transactions << Qif::Transaction.new(transaction_hash) unless transaction_hash.empty?
        end
      end

      def build_transaction_hash(rows)
        hash = {}
        rows.map do |row|
          type = Qif::Transaction::SUPPORTED_FIELDS[row[0].try(:upcase)]
          next unless type
          hash[type] = type == :date ? parse_date(row[1..-1]) : row[1..-1].strip
        end
        hash[:date].nil? ? {} : hash
      end

      def parse_date(row)
        date = Date.strptime(row, date_format)
        raise ArgumentError if date.year < 1900
        date.as_json
      rescue ArgumentError => error
        Chronic.parse(row, :endian_precedence => [:middle, :little]).to_date.as_json
      end

      def check_dates(transactions_array)
        dates = transactions_array.map{ |transaction| transaction.split("\n") }
                                  .flatten
                                  .select{ |line| line.match(/^D/) }
                                  .map{ |line| line[1..-1] }

        dates.each do |row|
          unless Chronic.parse(row)
            raise Qif::Error.new(Qif::Error::UnsupportedDateFormat % { :format => row })
          end
        end
      end
    end
  end
end
