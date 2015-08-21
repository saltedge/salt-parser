require "spec_helper"

describe SaltParser::Qif::Account do
  let(:parser)      { SaltParser::Qif::Builder.new("spec/qif/fixtures/bank_account.qif", "%d/%m/%Y").parser }
  let(:transaction) { parser.accounts.first.transactions.first }

  it "parses available data for transaction" do
    transaction.to_hash.should == {
      :date     => "2010-01-01",
      :amount   => "-1,010.02",
      :status   => nil,
      :number   => nil,
      :payee    => "Description",
      :memo     => "Reference",
      :category => "Debit"
    }
  end
end
