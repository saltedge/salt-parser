require "spec_helper"

describe SaltParser::Swift::Builder do
  context "parsing" do
    it "parses text file with data in mt940(SWIFT) format with barclays bank export" do
      parser = SaltParser::Swift::Builder.new("spec/swift/fixtures/barclays.txt").parser
      parser.accounts.size.should == 1
      parser.accounts.first.to_hash.except(:transactions).should == {
        :account_identification => "USD:555:7777777",
        :closing_balance => {
          :balance_type => :start,
          :sign         => :credit,
          :currency     => "USD",
          :amount       => 3011433,
          :date         => Date.new(2012,4,24)
        }
      }
      parser.accounts.first.transactions.size.should == 11
      parser.accounts.first.transactions.first.to_hash.should == {
        :date                     => Date.new(2012,1,25),
        :entry_date               => Date.new(2012,1,25),
        :funds_code               => :debit,
        :amount                   => 2500,
        :swift_code               => "FTRF",
        :reference                => "SUB FEE BI//0",
        :transaction_description  => "",
        :info                     => nil
      }
    end

    it "parses text file with data in mt940 format (SWIFT)" do
      parser = SaltParser::Swift::Builder.new("spec/swift/fixtures/sepa_mt9401.txt").parser
      parser.accounts.size.should == 2

      parser.accounts.first.to_hash.except(:transactions).should == {
        :account_identification => "55555555/8888888888888",
        :closing_balance => {
          :balance_type => :start,
          :sign         => :debit,
          :currency     => "EUR",
          :amount       => 123762823,
          :date         => Date.new(2007,9,4)
        }
      }
      parser.accounts.map(&:transactions).flatten.size.should == 14
      parser.accounts.first.transactions.first.to_hash.should == {
        :date                     => Date.new(2007,9,4),
        :entry_date               => Date.new(2007,9,4),
        :funds_code               => :credit,
        :amount                   => 300,
        :swift_code               => "NTRF",
        :reference                => "TFNr 40005 MSGID",
        :transaction_description  => "0724710345313905",
        :info =>
        {
          :code                     => 159,
          :transaction_description  => "RETOURE",
          :prima_nota               => "0399",
          :details                  => "EREF+TFNR 40005 00005\nMTLG:Grund nicht spezifizie\nrt Reject aus SEPA-Ueberwei\nsungsauftrag",
          :bank_code                => nil,
          :account_number           => nil,
          :account_holder           => "",
          :text_key_extension       => "914",
          :not_implemented_fields   => nil
        }
      }
    end
  end

  context "initialize" do
    it "should initialize with file path" do
      parser = SaltParser::Swift::Builder.new("spec/swift/fixtures/test.txt").parser
      parser.accounts.size.should == 3
    end

    it "should initialize with an IO object" do
      parser = SaltParser::Swift::Builder.new(open("spec/swift/fixtures/test.txt")).parser
      parser.accounts.size.should == 3
    end

    it "should initialize with data in a string" do
      parser = SaltParser::Swift::Builder.new(File.read("spec/swift/fixtures/test.txt")).parser
      parser.accounts.size.should == 3
    end
  end

  context "exceptional situations" do
    it "does not fail if file has empty line" do
      expect { SaltParser::Swift::Builder.new("spec/swift/fixtures/empty_line.txt").parser }.to_not raise_error
    end

    it "raise error if have unknown data" do
      parser = SaltParser::Swift::Builder.new("spec/swift/fixtures/unknown_data.txt").parser
      expect { parser }.to_not raise_error

      parser.errors.size.should == 1
    end

    it "should not fail if :86: tag has no :61: predecessor" do
      parser = SaltParser::Swift::Builder.new("spec/swift/fixtures/empty_86.txt").parser
      parser.accounts.first.transactions.should be_empty
    end

    it "does not fail if file has unusual characters" do
      parser = SaltParser::Swift::Builder.new("spec/swift/fixtures/with_binary_character.txt").parser
      parser.accounts.size.should == 2
      parser.accounts.last.transactions.last.info.details
            .should == "Belegloser Zahlungsauftrag\nÜberweisung:19.03.2010\nAnzahl Posten :7\nAnw-Nr.: 69725663086"
    end

    it "should reject the file with wrong encoding" do
      Kconv.should_receive(:isutf8).and_raise(StandardError)
      expect do
        SaltParser::Swift::Builder.new("spec/swift/fixtures/test.txt").parser
      end.to raise_error(SaltParser::Error::InvalidEncoding)
    end
  end
end
