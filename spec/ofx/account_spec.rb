require "spec_helper"

describe SaltParser::Ofx::Account do
  let(:ofx)     { SaltParser::Ofx::Builder.new("spec/ofx/fixtures/v102.ofx") }
  let(:parser)  { ofx.parser }
  let(:account) { parser.accounts.first }
  let(:hash)    { account.to_hash }

  describe "account" do
    context "Bank account" do
      it "should return currency" do
        account.currency.should == "BRL"
        hash[:currency].should == account.currency
      end

      it "should return bank id" do
        account.bank_id.should == "0356"
        hash[:bank_id].should == account.bank_id
      end

      it "should return id" do
        account.id.should == "03227113109"
        hash[:id].should == account.id
      end

      it "should return type" do
        account.type.should == :checking
        hash[:type].should == account.type
      end

      it "should return transactions" do
        account.transactions.should be_a_kind_of(Array)
        account.transactions.size.should == 36
        hash[:transactions].should be_a_kind_of(Array)
        hash[:transactions].size.should == account.transactions.size
        hash[:transactions].first.should == account.transactions.first.to_hash
      end

      it "should return balance" do
        account.balance.amount.should == 598.44
        hash[:balance][:amount].should == account.balance.amount
      end

      it "should return balance in pennies" do
        account.balance.amount_in_pennies.should == 59844
        hash[:balance][:amount_in_pennies].should == account.balance.amount_in_pennies
      end

      it "should return balance date" do
        account.balance.posted_at.should == Time.parse("2009-11-01")
        hash[:balance][:posted_at].should == Time.parse("2009-11-01")
      end

      context "available_balance" do
        it "should return available balance" do
          account.available_balance.amount.should == 1555.99
          hash[:available_balance][:amount].should == account.available_balance.amount
        end

        it "should return available balance in pennies" do
          account.available_balance.amount_in_pennies.should == 155599
          hash[:available_balance][:amount_in_pennies].should == account.available_balance.amount_in_pennies
        end

        it "should return available balance date" do
          account.available_balance.posted_at.should == Time.parse("2009-11-01")
          hash[:available_balance][:posted_at].should == account.available_balance.posted_at
        end

        it "should return nil if AVAILBAL not found" do
          ofx     = SaltParser::Ofx::Builder.new("spec/ofx/fixtures/utf8.ofx")
          account = ofx.parser.accounts.first
          account.available_balance.should be_nil
        end
      end
    end

    context "Credit Card" do
      let(:ofx)     { SaltParser::Ofx::Builder.new("spec/ofx/fixtures/v211.ofx") }
      let(:account) { parser.accounts.last }

      it "should return id" do
        account.id.should == "123412341234"
      end

      it "should return currency" do
        account.currency.should == "USD"
      end
    end

    context "#to_hash" do
      it "should return Hash" do
        hash.should be_a_kind_of(Hash)
      end
    end
  end
end
