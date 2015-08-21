require "spec_helper"

describe SaltParser::Qif::Account do
  let(:parser)  { SaltParser::Qif::Builder.new("spec/qif/fixtures/bank_account.qif", "%d/%m/%Y").parser }
  let(:account) { parser.accounts.first }

  it "creates an account with default data" do
    account.to_hash.should == {
      :name         => "Bank account",
      :type         => "bank_account",
      :transactions => [
        {
          :date     => "2010-01-01",
          :amount   => "-1,010.02",
          :status   => nil,
          :number   => nil,
          :payee    => "Description",
          :memo     => "Reference",
          :category => "Debit"
        },
        {
          :date     => "2010-06-01",
          :amount   => "-30,020.00",
          :status   => nil,
          :number   => nil,
          :payee    => "Description",
          :memo     => "Reference",
          :category => "Debit"
        },
        {
          :date     => "2010-12-29",
          :amount   => "1234.12",
          :status   => nil,
          :number   => nil,
          :payee    => "Description",
          :memo     => "Reference",
          :category => "Credit"
        }
      ]
    }
  end
end
