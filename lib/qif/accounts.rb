module SaltParser
  module Qif
    class Accounts < SaltParser::Accounts
      SUPPORTED_ACCOUNTS = {
        "!Type:Bank"  => {
          "type"        => "bank_account",
          "name"        => "Bank account"
        },
        "!Type:Cash"  => {
          "type"        => "cash",
          "name"        => "Cash account"
        },
        "!Type:CCard" => {
          "type"        => "credit_card",
          "name"        => "Credit card account"
        },
        "!Type:Oth A" => {
          "type"        => "asset",
          "name"        => "Asset account"
        },
        "!Type:Oth L" => {
          "type"        => "liability_account",
          "name"        => "Liability account"
        }
      }
      SUPPORTED_ACCOUNTS.default = {
        "type"        => "account",
        "name"        => "account"
      }
      NOT_SUPPORTED_ACCOUNTS = {
        "!Account"   => {
          "type"        => "account_list",
          "name"        => "Account list or which account follows"
        },
        "!Type:Cat"  => {
          "type"        => "category_list",
          "name"        => "Category list"
        },
        "!Type:Class"  => {
          "type"        => "class_list",
          "name"        => "Class list"
        },
        "!Type:Memorized" => {
          "type"        => "memorized_transaction_list",
          "name"        => "Memorized transaction list"
        },
        "!Type:Invoice" => {
          "type"        => "invoice",
          "name"        => "Invoice (Quicken for Business only)"
        }
      }
    end
  end
end
