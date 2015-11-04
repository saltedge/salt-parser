module SaltParser
  module Swift
    class TransactionInfo
      attr_reader :code, :transaction_description, :prima_nota, :details,
                  :bank_code, :account_number, :account_holder,
                  :text_key_extension, :not_implemented_fields

      def initialize(options)
        match_data = options[:content].match(/^(?<code>\d{3})(?<sub_fields>(?<seperator>.).*)$/)
        if match_data
          @code = match_data[:code].to_i
          details, account_holder = [], []

          if seperator = match_data[:seperator]
            sub_fields = match_data[:sub_fields].scan(/#{Regexp.escape(seperator)}(\d{2})([^#{Regexp.escape(seperator)}]*)/)

            sub_fields.each do |(code, content)|
              case code.to_i
                when 0
                  @transaction_description = content
                when 10
                  @prima_nota = content
                when 20..29, 60..63
                  details << content
                when 30
                  @bank_code = content
                when 31
                  @account_number = content
                when 32..33
                  account_holder << content
                when 34
                  @text_key_extension = content
              else
                @not_implemented_fields ||= []
                @not_implemented_fields << [code, content]
              end
            end
          end

          @details        = details.join("\n")
          @account_holder = account_holder.join("\n")
        else
          @details = options[:content]
        end
      end

      def to_hash
        {
          :code                     => code,
          :transaction_description  => transaction_description,
          :prima_nota               => prima_nota,
          :details                  => details,
          :bank_code                => bank_code,
          :account_number           => account_number,
          :account_holder           => account_holder,
          :text_key_extension       => text_key_extension,
          :not_implemented_fields   => not_implemented_fields
        }
      end
    end
  end
end