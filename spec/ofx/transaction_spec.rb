require "spec_helper"

describe SaltParser::Ofx::Transaction do
  let(:ofx)     { SaltParser::Ofx::Builder.new("spec/ofx/fixtures/v102.ofx") }
  let(:parser)  { ofx.parser }
  let(:account) { parser.accounts.first }

  context "debit" do
    let(:transaction) { account.transactions[0] }
    let(:hash)        { transaction.to_hash }

    it "should set amount" do
      transaction.amount.should == -35.34
      hash[:amount].should == -35.34
    end

    it "should cast amount to Float" do
      transaction.amount.class.should == Float
      hash[:amount].class.should == Float
    end

    it "should set amount in pennies" do
      transaction.amount_in_pennies.should == -3534
      hash[:amount_in_pennies].should == -3534
    end

    it "should set fit id" do
      transaction.fit_id.should == "200910091"
      hash[:fit_id].should == "200910091"
    end

    it "should set memo" do
      transaction.memo.should == "COMPRA VISA ELECTRON"
      hash[:memo].should == "COMPRA VISA ELECTRON"
    end

    it "should set check number" do
      transaction.check_number.should == "0001223"
      hash[:check_number].should == "0001223"
    end

    it "should have date" do
      transaction.posted_at.should == Time.parse("2009-10-09 08:00:00")
      hash[:posted_at].should == Time.parse("2009-10-09 08:00:00")
    end

    it "should have type" do
      transaction.type.should == :debit
      hash[:type].should == :debit
    end

    it "should have sic" do
      transaction.sic.should == "5072"
      hash[:sic].should == "5072"
    end

    context "#to_hash" do
      it "should return Hash" do
        hash.should be_a_kind_of(Hash)
      end
    end
  end

  context "credit" do
    let(:transaction) { account.transactions[1] }

    it "should set amount" do
      transaction.amount.should == 60.39
    end

    it "should set amount in pennies" do
      transaction.amount_in_pennies.should == 6039
    end

    it "should set fit id" do
      transaction.fit_id.should == "200910162"
    end

    it "should set memo" do
      transaction.memo.should == "DEPOSITO POUP.CORRENTE"
    end

    it "should set check number" do
      transaction.check_number.should == "0880136"
    end

    it "should have date" do
      transaction.posted_at.should == Time.parse("2009-10-16 08:00:00")
    end

    it "should have type" do
      transaction.type.should == :credit
    end

    it "should have empty sic" do
      transaction.sic.should == ''
    end
  end

  context "with more info" do
    let(:transaction) { account.transactions[2] }

    it "should set payee" do
      transaction.payee.should == "Pagto conta telefone"
    end

    it "should set check number" do
      transaction.check_number.should == "000000101901"
    end

    it "should have date" do
      transaction.posted_at.should == Time.parse("2009-10-19 12:00:00")
    end

    it "should have type" do
      transaction.type.should == :other
    end

    it "should have reference number" do
      transaction.ref_number.should == "101.901"
    end
  end

  context "with name" do
    let(:transaction) { account.transactions[3] }

    it "should set name" do
      transaction.name.should == "Pagto conta telefone"
    end
  end

  context "with other types" do
    let(:ofx)     { SaltParser::Ofx::Builder.new("spec/ofx/fixtures/bb.ofx") }
    let(:parser)  { ofx.parser }
    let(:account) { parser.accounts.first }

    it "should return dep" do
      transaction = account.transactions[9]
      transaction.type.should == :dep
    end

    it "should return xfer" do
      transaction = account.transactions[18]
      transaction.type.should == :xfer
    end

    it "should return cash" do
      transaction = account.transactions[45]
      transaction.type.should == :cash
    end

    it "should return check" do
      transaction = account.transactions[0]
      transaction.type.should == :check
    end
  end
end
