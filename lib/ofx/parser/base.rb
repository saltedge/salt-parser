module SaltParser
  module OFX
    module Parser
      class Base
        ACCOUNT_TYPES = {
          "CHECKING"   => :checking,
          "SAVINGS"    => :savings,
          "CREDITCARD" => :credit_card,
          "CREDITLINE" => :credit,
          "INVESTMENT" => :investment,
          "MONEYMRKT"  => :savings
        }

        TRANSACTION_TYPES = [
          'ATM', 'CASH', 'CHECK', 'CREDIT', 'DEBIT', 'DEP', 'DIRECTDEBIT', 'DIRECTDEP', 'DIV',
          'FEE', 'INT', 'OTHER', 'PAYMENT', 'POS', 'REPEATPMT', 'SRVCHG', 'XFER'
        ].inject({}) { |hash, tran_type| hash[tran_type] = tran_type.downcase.to_sym; hash }

        attr_reader :headers, :body, :html, :errors, :accounts, :sign_on

        def initialize(options = {})
          @headers  = options[:headers]
          @body     = options[:body]
          @html     = Nokogiri::HTML.parse(body)
          @errors   = []
          build_sign_on
          build_accounts
          check_for_errors
        end

        def to_hash
          {
            :errors => errors,
            :sign_on => sign_on.to_hash,
            :accounts => accounts.to_hash
          }
        end

        def build_accounts
          @accounts = OFX::Accounts.new
          build_bank_account
          build_credit_card_account
          build_investments_account
        end

        private

        def check_for_errors
          statuses = html.search("status").reverse
          statuses.each do |status|
            if status.search("severity").inner_text == "ERROR"
              errors << SaltParser::OFX::RequestError.new(["[#{status.search("code").inner_text}]", status.search("message").inner_text].join(" ").strip)
            end
          end
        end

        def build_bank_account
          html.search("stmttrnrs", "bankacctinfo").each do |account|
            begin
              account_id = account.search("bankacctfrom > acctid").inner_text

              @accounts << SaltParser::OFX::Account.new(
                :bank_id           => account.search("bankacctfrom > bankid").inner_text,
                :id                => account_id,
                :name              => account.parent.search("desc").inner_text,
                :type              => ACCOUNT_TYPES[account.search("bankacctfrom > accttype").inner_text.to_s.upcase],
                :transactions      => build_transactions(account.search("banktranlist > stmttrn"), account_id),
                :balance           => build_balance(account),
                :available_balance => build_available_balance(account),
                :currency          => account.search("stmtrs > curdef").inner_text
              )
            rescue SaltParser::OFX::ParseError => error
              errors << error
            end
          end
        end

        def build_credit_card_account
          html.search("ccstmttrnrs", "acctinfo").each do |account|
            begin
              account_id = account.search("ccacctfrom > acctid").inner_text
              next if account_id.blank?
              @accounts << SaltParser::OFX::Account.new(
                :id           => account_id,
                :name         => account.search("desc").inner_text,
                :type         => ACCOUNT_TYPES["CREDITCARD"],
                :transactions => build_transactions(account.search("banktranlist > stmttrn"), account_id),
                :balance      => build_balance(account),
                :currency     => account.search("curdef").inner_text
              )
            rescue SaltParser::OFX::ParseError => error
              errors << error
            end
          end
        end

        def build_investments_account
          html.search("invstmttrnrs", "acctinfo").each do |account|
            begin
              account_id = account.search("invacctfrom > acctid").inner_text
              broker_id  = account.search("invacctfrom > brokerid").inner_text

              next if broker_id.blank? or account_id.blank?
              @accounts << SaltParser::OFX::Account.new(
                :id           => account_id,
                :broker_id    => broker_id,
                :type         => ACCOUNT_TYPES["INVESTMENT"],
                :transactions => build_investment_transactions(account.search("invtranlist"), account_id),
                :balance      => build_investment_balance(account),
                :currency     => account.search("curdef").inner_text,
                :units        => compute_investment_units(account),
                :unit_price   => compute_investment_unit_price(account)
              )
            rescue OFX::ParseError => error
              errors << error
            end
          end
        end

        def build_transactions(transactions, account_id)
          transactions.each_with_object([]) do |transaction, transactions|
            begin
              transactions << build_transaction(transaction, account_id)
            rescue OFX::ParseError => error
              errors << error
            end
          end
        end

        def build_transaction(transaction, account_id)
          SaltParser::OFX::Transaction.new(
            :amount            => build_amount(transaction),
            :amount_in_pennies => ((build_amount(transaction) * 100).round 2).to_i,
            :fit_id            => transaction.search("fitid").inner_text,
            :memo              => transaction.search("memo").inner_text,
            :name              => transaction.search("name").inner_text,
            :payee             => transaction.search("payee").inner_text,
            :check_number      => transaction.search("checknum").inner_text,
            :ref_number        => transaction.search("refnum").inner_text,
            :posted_at         => build_date(transaction.search("dtposted").inner_text),
            :type              => build_type(transaction),
            :sic               => transaction.search("sic").inner_text,
            :account_id        => account_id
          )
        end

        def build_investment_transactions(transactions_xml, account_id)
          transactions = transactions_xml.search("stmttrn", "invtran")
          transactions.each_with_object([]) do |transaction, transactions|
            begin
              if transaction.name.include?("stmttrn")
                transactions << build_investment_transaction(transaction, account_id)
              else
                transactions << build_investment_transaction(transaction.parent, account_id)
              end
            rescue SaltParser::OFX::ParseError => error
              errors << error
            end
          end
        end

        def build_investment_transaction(transaction, account_id)
          SaltParser::OFX::Transaction.new(
            :amount            => build_investment_amount(transaction),
            :amount_in_pennies => ((build_investment_amount(transaction) * 100).round 2).to_i,
            :fit_id            => transaction.search("fitid").inner_text,
            :memo              => transaction.search("memo").inner_text,
            :name              => transaction.search("name").inner_text,
            :posted_at         => build_date(transaction.search("dtposted", "dttrade").inner_text),
            :type              => build_type(transaction),
            :ref_number        => transaction.search("refnum", "uniqueid").empty? ? "N/A" : transaction.search("refnum", "uniqueid").inner_text,
            :account_id        => account_id,
            :units             => parse_float(transaction.search("units").inner_text),
            :unit_price        => parse_float(transaction.search("unitprice").inner_text)
          )
        end

        def build_sign_on
          @sign_on = SaltParser::OFX::SignOn.new(
            :language          => html.search("signonmsgsrsv1 > sonrs > language").inner_text,
            :fi_id             => html.search("signonmsgsrsv1 > sonrs > fi > fid").inner_text,
            :fi_name           => html.search("signonmsgsrsv1 > sonrs > fi > org").inner_text,
            :code              => html.search("signonmsgsrsv1 > sonrs > status > code").inner_text,
            :severity          => html.search("signonmsgsrsv1 > sonrs > status > severity").inner_text,
            :message           => html.search("signonmsgsrsv1 > sonrs > status > message").inner_text
          )
        end

        def build_balance(account)
          return nil unless account.search("ledgerbal > balamt").size > 0

          if account.search("ledgerbal > balamt").inner_text.match(/[\d]{14}\.[\d]+/)
            SaltParser::OFX::Balance.new(
              :amount => 0.0,
              :amount_in_pennies => 0,
              :posted_at => build_date(account.search("ledgerbal > balamt").inner_text)
            )
          else
            amount = parse_float(account.search("ledgerbal > balamt").inner_text)

            SaltParser::OFX::Balance.new(
              :amount => amount,
              :amount_in_pennies => ((amount * 100).round 2).to_i,
              :posted_at => build_date(account.search("ledgerbal > dtasof").inner_text)
            )
          end
        end

        def build_available_balance(account)
          return nil unless account.search("availbal").size > 0

          if account.search("availbal > balamt").inner_text.match(/[\d]{14}\.[\d]+/)
            SaltParser::OFX::Balance.new(
              :amount => 0.0,
              :amount_in_pennies => 0,
              :posted_at => build_date(account.search("availbal > balamt").inner_text)
            )
          else
            amount = parse_float(account.search("availbal > balamt").inner_text)

            SaltParser::OFX::Balance.new(
              :amount => amount,
              :amount_in_pennies => ((amount * 100).round 2).to_i,
              :posted_at => build_date(account.search("availbal > dtasof").inner_text)
            )
          end
        end

        def build_investment_balance(account)
          if account.search("invbal > availcash").size > 0 && account.search("invpos > mktval").size < 1
            amount = parse_float(account.search("invbal > availcash").inner_text)

          elsif account.search("invbal > availcash").size < 1 && account.search("invpos > mktval").size > 0
            amount = 0
            account.search("invpos > mktval").map do |mktval|
              amount += parse_float(mktval.inner_text)
            end
            amount

          elsif account.search("invbal > availcash").size > 0 && account.search("invpos > mktval").size > 0
            amount = 0
            account.search("invbal > availcash").map do |availcash|
              amount += parse_float(availcash.inner_text)
            end
            account.search("invpos > mktval").map do |mktval|
              amount += parse_float(mktval.inner_text)
            end
            amount

          else
            return nil
          end

          SaltParser::OFX::Balance.new(
            :amount => amount,
            :amount_in_pennies => ((amount * 100).round 2).to_i
          )
        end

        def compute_investment_units(account)
          if account.search("invpos > units").size == 1
            parse_float(account.search("invpos > units").inner_text)
          else
            0.0
          end
        end

        def compute_investment_unit_price(account)
          if account.search("invpos > unitprice").size == 1
            parse_float(account.search("invpos > unitprice").inner_text)
          else
            0.0
          end
        end

        def build_type(element)
          TRANSACTION_TYPES[element.search("trntype", "incometype").inner_text.to_s.upcase]
        end

        def build_amount(element)
          parse_float(element.search("trnamt", "total").inner_text)
        rescue TypeError => error
          raise SaltParser::OFX::ParseError.new(SaltParser::OFX::ParseError::AMOUNT)
        end

        def build_investment_amount(element)
          if element.parent.search("invbuy", "invsell").size > 0
            -1 * parse_float(element.search("total").inner_text)
          else
            build_amount(element)
          end
        rescue TypeError => error
          raise SaltParser::OFX::ParseError.new(SaltParser::OFX::ParseError::AMOUNT)
        end

        def build_date(date)
          _, year, month, day, hour, minutes, seconds = *date.match(/(\d{4})(\d{2})(\d{2})(?:(\d{2})(\d{2})(\d{2}))?/)

          date = "#{year}-#{month}-#{day} "
          date << "#{hour}:#{minutes}:#{seconds}" if hour && minutes && seconds

          Time.parse(date)
        rescue TypeError, ArgumentError => error
          raise SaltParser::OFX::ParseError.new(SaltParser::OFX::ParseError::TIME)
        end

        def parse_float(incoming, options={})
          return incoming if incoming.is_a?(Float)
          string = incoming.dup
          sanitize_float_string!(string)

          if options[:integral]
            string.gsub!(",", "")
            string.gsub!(".", "")
            return string.to_f
          end

          indexes = {
                      "," => string.rindex(","),
                      "." => string.rindex(".")
                    }

          return string.to_f if indexes["."].nil? && indexes[","].nil?

          if indexes["."] == nil
            if string.scan(/,/).size > 1
              string.gsub!(",", "")  # 123,123,123
            else
              string.gsub!(",", ".") # 123,123
            end
            return string.to_f
          end

          if indexes[","] == nil
            string.gsub!(".", "") if string.scan(/\./).size > 1 # 123.123.123
            return string.to_f
          end

          if indexes[","] > indexes["."]
            # comma is decimal separator
            string.gsub!(".", "")
            string.gsub!(",", ".")
          else
            # dot is decimal separator
            string.gsub!(",", "")
          end

          string.to_f
        rescue => error
          raise SaltParser::OFX::ParseError.new(SaltParser::OFX::ParseError::FLOAT)
        end

        def sanitize_float_string!(string)
          # replace weird minus sign with proper minus
          string.gsub!(8211.chr(Encoding::UTF_8), "-")
          # replace an even weirder minus sign with proper minus
          string.gsub!(8722.chr(Encoding::UTF_8), "-")
          # remove everything except digits, dots, commas, '+', '-'
          string.gsub!(/[^0-9\-+.,]/, "")
          # remove trailing non digits
          string.gsub!(/[-+.,]+$/, "")
        end
      end
    end
  end
end
