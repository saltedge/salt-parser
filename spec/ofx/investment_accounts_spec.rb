require "spec_helper"

describe SaltParser::OFX::Accounts do
  let(:sample_ofx)            { SaltParser::OFX::Builder.new("spec/ofx/fixtures/sample_examples/sample_investment.qfx") }
  let(:hewitt_ofx)            { SaltParser::OFX::Builder.new("spec/ofx/fixtures/investments_with_mkval.ofx") }
  let(:merrill_lynch_ofx)     { SaltParser::OFX::Builder.new("spec/ofx/fixtures/investment_transactions_response3.ofx") }
  let(:vanguard_ofx)          { SaltParser::OFX::Builder.new("spec/ofx/fixtures/investment_transactions_response4.ofx") }
  let(:sample_accounts)       { sample_ofx.parser.accounts }
  let(:hewitt_accounts)       { hewitt_ofx.parser.accounts }
  let(:merrill_lynch_accounts){ merrill_lynch_ofx.parser.accounts }
  let(:vanguard_accounts)     { vanguard_ofx.parser.accounts }
  let(:hash)                  { sample_accounts.to_hash }

  describe "accounts" do
    it "should return sample account" do
      sample_accounts.size.should == 1

      account = sample_accounts.first
      account.broker_id.should == "Intuit.com"
      account.currency.should  == "USD"
      account.id.should        == "1234567890"
      account.type.should      == SaltParser::OFX::Parser::Base::ACCOUNT_TYPES["INVESTMENT"]

      account.balance.amount.should == 100295.69
    end

    it "should return hewitt account" do
      hewitt_accounts.size.should == 1

      account = hewitt_accounts.first
      account.broker_id.should      == "hewitt.com"
      account.currency.should       == "USD"
      account.id.should             == "1234-12345678"
      account.type.should           == SaltParser::OFX::Parser::Base::ACCOUNT_TYPES["INVESTMENT"]
      account.units.should          == 337.502827
      account.unit_price.should     == 1.157869
      account.balance.amount.should == 390.78

      transaction = account.transactions.first
      transaction.amount.to_f.should       == 64.85
      transaction.amount_in_pennies.should == 6485
      transaction.fit_id.should            == "CT12345678901234567890123456789012"
      transaction.memo.should              == "Contribution"
      transaction.ref_number.should        == "123456789"
      transaction.units.should             == 56.355139
      transaction.unit_price.should        == 1.150738
    end

    describe "#find" do
      it "returns first by id" do
        sample_accounts.find("1234567890").class.should == SaltParser::OFX::Account
      end
    end

    describe "#find_by_transaction" do
      it "returns first by transaction's account_id and it's currency code" do
        account = sample_accounts.first
        transaction = account.transactions.first
        sample_accounts.find_by_transaction(transaction).should == account
      end
    end

    context "#to_hash" do
      it "should return array of Hashes" do
        hash.should be_a_kind_of(Array)
        hash.first.should be_a_kind_of(Hash)
      end
    end
  end
end
