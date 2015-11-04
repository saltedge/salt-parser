module SaltParser
  module Swift
    SUPPORTED_FIELDS = {
      "25" => { "type" => "account_identification" },
      "62" => { "type" => "closing_balance"        },
      "61" => { "type" => "transaction"            },
      "86" => { "type" => "transaction_info"       }
    }
  end
end