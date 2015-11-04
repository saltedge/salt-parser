module SaltParser
  module Swift
    class Parser
      attr_reader :accounts, :errors

      def initialize(options = {})
        @accounts = SaltParser::Swift::Accounts.new
        @errors   = []
        parse(options[:data])
      end

      def parse(text)
        new_text = text.strip
        new_text << "\r\n" if new_text[-1,1] == "-"

        accounts_rows = new_text.split(/^-\r\n/)
        accounts_rows.map do |row|
          account   = SaltParser::Swift::Account.new
          raw_sheet = row.gsub(/\r\n(?!:)/, "")
          parse_sheet(account, raw_sheet)
          @accounts << account
        end
      end

      private

      def parse_sheet(account, sheet)
        lines = sheet.split("\r\n").reject(&:empty?)
        lines.map do |line|
          if match_data = line.match(/^:(?<tag>\d{2})(?<modifier>\w)?:(?<content>.*)$/)
            begin
              next unless item = SaltParser::Swift::SUPPORTED_FIELDS[match_data[:tag]]
              options = {:content => match_data[:content], :modifier => match_data[:modifier]}

              case item["type"]
              when "closing_balance"
                account.parse_closing_balance(options)
              when "account_identification"
                account.parse_account_identification(options)
              when "transaction"
                account.transactions.push(SaltParser::Swift::Transaction.new(options))
              when "transaction_info"
                account.transactions.last.try("info=".to_sym, SaltParser::Swift::TransactionInfo.new(options))
              end
            rescue SaltParser::Error => error
              errors << error
              next
            end
          else
            errors << SaltParser::Error::WrongLineFormat
          end
        end
      end
    end
  end
end
