require "spec_helper"

shared_examples_for "3 record files" do
  it "should not have any errors" do
    expect { parser }.not_to raise_error
  end

  it "should have 3 records" do
    transactions.size.should == 3
  end

  it "should have a debit of $10 on the 1st of January 2010" do
    transaction = transactions[0]
    transaction.date.should     == "2010-01-01"
    transaction.category.should == "Debit"
    transaction.amount.should   == "-10.00"
    transaction.payee.should    == "Description"
    transaction.memo.should     == "Reference"
  end

  it "should have a debit of $20 on the 1st of June 1020" do
    transaction = transactions[1]
    transaction.date.should     == "2010-06-01"
    transaction.category.should == "Debit"
    transaction.amount.should   == "-20.00"
    transaction.payee.should    == "Description"
    transaction.memo.should     == "Reference"
  end

  it "should have a credit of $30 on the 29th of December 2010" do
    transaction = transactions[2]
    transaction.date.should     == "2010-12-29"
    transaction.category.should == "Credit"
    transaction.amount.should   == "30.00"
    transaction.payee.should    == "Description"
    transaction.memo.should     == "Reference"
  end
end

describe SaltParser::Qif::Builder do
  {
    "dd/mm/yy"    => "%d/%m/%y",
    "dd/mm/yyyy"  => "%d/%m/%Y",
    "d/m/yy"      => "%d/%m/%y",
    "m/d/yy"      => "%m/%d/%y",
    "mm/dd/yy"    => "%m/%d/%y",
    "mm/dd/yyyy"  => "%m/%d/%Y"
  }.each do |name, format|
    context "when format is #{format}" do
      it_behaves_like "3 record files" do
        let(:parser)       { SaltParser::Qif::Builder.new("spec/qif/fixtures/3_records_%s.qif" % name.gsub("/", ""), format).parser }
        let(:transactions) { parser.accounts.first.transactions }
      end
    end
  end

  context "when format has spaces" do
    it_behaves_like "3 record files" do
      let(:parser) { SaltParser::Qif::Builder.new("spec/qif/fixtures/3_records_spaced.qif").parser }
      let(:transactions) { parser.accounts.first.transactions }
    end
  end

  context "it should still work when the record header is followed by an invalid transaction terminator" do
    it_behaves_like "3 record files" do
      let(:parser) { SaltParser::Qif::Builder.new("spec/qif/fixtures/3_records_invalid_header.qif").parser }
      let(:transactions) { parser.accounts.first.transactions }
    end
  end

  context "when there are various date formats" do
    let(:parser) { SaltParser::Qif::Builder.new("spec/qif/fixtures/various_date_format.qif", "%m/%d/%y").parser }
    let(:transactions) { parser.accounts.first.transactions }

    it "should still work" do
      transactions.size.should  == 3
      transactions.map(&:date).should == ["2010-12-13", "2010-01-01", "2006-12-25"]
    end
  end

  context "when file contains wrong date" do
    it "should fail" do
      expect {
        SaltParser::Qif::Builder.new("spec/qif/fixtures/invalid_date_format.qif").parser
      }.to raise_error(SaltParser::Error::UnsupportedDateFormat)
    end
  end

  context "file with unknown account type" do
    let(:parser) { SaltParser::Qif::Builder.new("spec/qif/fixtures/unknown_account.qif", "%m/%d/%y").parser }
    let(:transactions) { parser.accounts.first.transactions }

    it "should still work" do
      parser.accounts.first.name.should == "account"
      parser.accounts.first.type.should == "account"
      transactions.size.should  == 2
    end
  end

  context "with categories" do
    let(:parser) { SaltParser::Qif::Builder.new("spec/qif/fixtures/with_categories_list.qif", "%d/%m/%y").parser }
    let(:transactions) { parser.accounts.first.transactions }

    it "should ignore categories records" do
      parser.accounts.first.name.should == "Bank account"
      parser.accounts.first.type.should == "bank_account"
      transactions.size.should  == 1098
    end
  end

  context "file without header" do
    let(:parser) { SaltParser::Qif::Builder.new("spec/qif/fixtures/empty_header.qif", "%m/%d/%y").parser }
    let(:transactions) { parser.accounts.first.transactions }

    it "should still work" do
      parser.accounts.first.name.should == "account"
      parser.accounts.first.type.should == "account"
      transactions.size.should  == 3
    end
  end

  context "not a qif format" do
    let(:parser) { SaltParser::Qif::Builder.new("spec/qif/fixtures/not_a_QIF_file.txt").parser }
    let(:transactions) { parser.accounts.first.transactions }

    it "should still work" do
      parser.accounts.first.name.should == "account"
      parser.accounts.first.type.should == "account"
      transactions.size.should  == 0
    end
  end

  it "should reject the file without valid body" do
    expect{ SaltParser::Qif::Builder.new("spec/qif/fixtures/empty_body.qif").parser }.to raise_error(SaltParser::Error::EmptyFileBody)
  end

  it "should reject the file with wrong encoding" do
    Kconv.should_receive(:isutf8).and_raise(StandardError)
    expect{ SaltParser::Qif::Builder.new("spec/qif/fixtures/3_records_ddmmyyyy.qif").parser }.to raise_error(SaltParser::Error::InvalidEncoding)
  end

  it "should reject the file with unparsable date" do
    Chronic.should_receive(:parse).and_return(nil)
    expect{ SaltParser::Qif::Builder.new("spec/qif/fixtures/3_records_ddmmyyyy.qif").parser }.to raise_error(SaltParser::Error::UnsupportedDateFormat)
  end

  it "should initialize with an IO object" do
    parser = SaltParser::Qif::Builder.new(open("spec/qif/fixtures/3_records_ddmmyyyy.qif")).parser
    parser.accounts.first.transactions.size.should == 3
  end

  it "should initialize with data in a string" do
    parser = SaltParser::Qif::Builder.new(File.read("spec/qif/fixtures/3_records_ddmmyyyy.qif")).parser
    parser.accounts.first.transactions.size.should == 3
  end
end
