require "spec_helper"

describe SaltParser::OFX::Builder do
  let(:ofx)    { SaltParser::OFX::Builder.new("spec/ofx/fixtures/v102.ofx") }
  let(:ofx2)   { SaltParser::OFX::Builder.new("spec/ofx/fixtures/ms_money.ofx") }
  let(:parser) { ofx.parser }

  describe "initialize" do
    it "does not raise error if valid file given" do
      expect{ SaltParser::OFX::Builder.new("spec/ofx/fixtures/v102.ofx") }.not_to raise_error
      expect{ SaltParser::OFX::Builder.new("spec/ofx/fixtures/v211.ofx") }.not_to raise_error
      expect{ SaltParser::OFX::Builder.new("spec/ofx/fixtures/v202.ofx") }.not_to raise_error
    end

    it "raises error if file has not valid format" do
      expect do
        SaltParser::OFX::Builder.new("spec/ofx/fixtures/missing_headers.ofx").parser
      end.to raise_error(SaltParser::Error::UnsupportedFileError)
    end

    it "parses file without balances" do
      parser = SaltParser::OFX::Builder.new("spec/ofx/fixtures/ms_money.ofx").parser
      parser.accounts.size.should == 1
      parser.accounts.first.transactions.size.should == 1
    end

    it "does not raise errors if parsing gone bad" do
      parser = SaltParser::OFX::Builder.new("spec/ofx/fixtures/date_missing.ofx").parser

      expect {parser.accounts}.to_not raise_error

      parser.accounts.size.should == 1
      # Total 3 transactions, 2 of them raised error during the parsing
      parser.accounts.first.transactions.size.should == 1
      parser.errors.size.should                      == 2

      parser.errors.first.should be_a_kind_of(SaltParser::Error::ParseError)
    end

    it "does not raise errors if transactions list is empty" do
      parser = SaltParser::OFX::Builder.new("spec/ofx/fixtures/transactions_empty.ofx").parser

      expect {parser.accounts}.to_not raise_error

      parser.accounts.size.should == 2
      parser.accounts.first.transactions.should be_empty
      parser.accounts.last.transactions.should be_empty

      parser.errors.should be_empty
    end

    it "returns even partial data" do
      parser = SaltParser::OFX::Builder.new("spec/ofx/fixtures/accounts_partial.ofx").parser

      expect {parser.accounts}.to_not raise_error

      parser.accounts.size.should == 1
      account = parser.accounts.first
      account.balance.amount.should     == 598.44
      account.bank_id.should            be_empty
      account.id.should                 be_empty
      account.name.should               be_empty
      account.currency.should           == "BRL"
      account.transactions.size.should  == 1
      account.type.should               be_nil
      account.available_balance.should  be_nil

      parser.errors.should be_empty
    end

    it "returns even partial data" do
      parser = SaltParser::OFX::Builder.new("spec/ofx/fixtures/creditcards_partial.ofx").parser

      expect {parser.accounts}.to_not raise_error
      parser.accounts.size.should == 3
      account = parser.accounts.last
      account.balance.should            be_nil
      account.bank_id.should            be_nil
      account.id.should                 == "345678901234567"
      account.currency.should           be_empty
      account.transactions.size.should  == 0
      account.type.should               == :credit_card
      account.available_balance.should  be_nil

      parser.errors.should be_empty
    end

    it "returns investment data" do
      parser = SaltParser::OFX::Builder.new("spec/ofx/fixtures/investment_transactions_response.ofx").parser

      expect {parser.accounts}.to_not raise_error

      parser.accounts.size.should == 1
      account = parser.accounts.last
      account.balance.amount.should     == 1308.93
      account.bank_id.should            be_nil
      account.id.should                 == "123456789"
      account.currency.should           == "USD"
      account.transactions.size.should  == 1
      account.type.should               == :investment
      account.available_balance.should  be_nil

      parser.errors.should be_empty
    end

    it "returns investment data" do
      parser = SaltParser::OFX::Builder.new("spec/ofx/fixtures/investment_transactions_response2.ofx").parser

      expect {parser.accounts}.to_not raise_error

      parser.accounts.size.should == 1
      account = parser.accounts.last
      account.balance.amount.should     == 2113.43
      account.bank_id.should            be_nil
      account.id.should                 == "123456"
      account.currency.should           == "USD"
      account.transactions.size.should  == 3
      account.type.should               == :investment
      account.available_balance.should  be_nil

      parser.errors.should be_empty
    end

    it "does not fail if account balance is missing" do
      parser = SaltParser::OFX::Builder.new("spec/ofx/fixtures/empty_balance.ofx").parser

      expect {parser.accounts}.to_not raise_error

      parser.accounts.size.should == 1
      parser.accounts.first.balance.should be_nil


      parser.errors.should be_empty
    end
  end
end
