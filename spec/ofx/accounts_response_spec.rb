require "spec_helper"

describe "Bank accounts response" do
  let(:ofx)      { SaltParser::OFX::Builder.new("spec/ofx/fixtures/accounts_response.ofx") }
  let(:parser)   { ofx.parser }
  let(:accounts) { parser.accounts }

  describe "accounts" do
    it "should parse bank account from bank response" do
      accounts.size.should          == 5
      accounts.first.to_hash.should == {
        :bank_id           => "123456789",
        :id                => "1234567890",
        :name              => "SILVERWIZ SAVINGS",
        :broker_id         => nil,
        :type              => :savings,
        :units             => nil,
        :unit_price        => nil,
        :currency          => "",
        :balance           => nil,
        :transactions      => [],
        :available_balance => nil
      }
    end
  end

  describe "sign_on" do
    it "should parse sign_on data from bank response" do
      parser.sign_on.to_hash.should == {
        :language => "ENG",
        :fi_id    => "10898",
        :fi_name  => "B1",
        :code     => "0",
        :severity => "INFO",
        :message  => "SUCCESS"
      }
    end
  end

  describe "errors" do
    it "should not have any errors" do
      parser.errors.size.should be_zero
    end
  end
end
