require "spec_helper"

describe OFX::Accounts do
  let(:ofx)      { OFX::Parser::Base.new("spec/ofx/fixtures/v211.ofx") }
  let(:accounts) { ofx.parser.accounts }
  let(:hash)     { accounts.to_hash }

  describe "accounts" do
    it "should return multiple accounts" do
      accounts.size.should == 2
    end

    describe "#find" do
      it "returns first by id" do
        accounts.find("123456").class.should == OFX::Account
      end
    end

    describe "#find_by_transaction" do
      it "returns first by transaction's account_id and it's currency code" do
        account = accounts.first
        transaction = account.transactions.first
        accounts.find_by_transaction(transaction).should == account
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
