require "spec_helper"

describe SaltParser::Ofx::Balance do
  let(:ofx)     { SaltParser::Ofx::Builder.new("spec/ofx/fixtures/v102.ofx") }
  let(:parser)  { ofx.parser }
  let(:account) { parser.accounts.first }
  let(:balance) { account.balance }
  let(:hash)    { balance.to_hash }

  describe "balance" do
    it "should return amount" do
      balance.amount.should == 598.44
      hash[:amount].should == balance.amount
    end

    it "should return amount_in_pennies" do
      balance.amount_in_pennies.should == 59844
      hash[:amount_in_pennies].should == balance.amount_in_pennies
    end

    it "should return posted_at" do
      balance.posted_at.should == Time.parse("2009-11-01")
      hash[:posted_at].should == balance.posted_at
    end

    context "#to_hash" do
      it "should return Hash" do
        hash.should be_a_kind_of(Hash)
      end
    end
  end
end
