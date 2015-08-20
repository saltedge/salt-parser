require "spec_helper"

describe SaltParser::OFX::SignOn do
  let(:ofx)     { SaltParser::OFX::Builder.new("spec/ofx/fixtures/creditcard.ofx") }
  let(:parser)  { ofx.parser }
  let(:sign_on) { parser.sign_on }
  let(:hash)    { sign_on.to_hash }

  describe "sign_on" do
    it "should return language" do
      sign_on.language.should == "ENG"
      hash[:language].should == sign_on.language
    end

    it "should return Financial Institution ID" do
      sign_on.fi_id.should == "24909"
      hash[:fi_id].should == sign_on.fi_id
    end

    it "should return Financial Institution Name" do
      sign_on.fi_name.should == "Citigroup"
      hash[:fi_name].should == sign_on.fi_name
    end

    context "#to_hash" do
      it "should return Hash" do
        hash.should be_a_kind_of(Hash)
      end
    end

    context "#status" do
      let(:sign_on) { SaltParser::OFX::Builder.new("spec/ofx/fixtures/request_error.ofx").parser.sign_on }
      it "should return status code" do
        sign_on.code.should == "2000"
        hash[:code].should  == sign_on.code
      end

      it "should return status severity" do
        sign_on.severity.should == "ERROR"
        hash[:severity].should  == sign_on.severity
      end

      it "should return status message" do
        sign_on.message.should == "Application which you are using is not enabled. Please call customer service."
        hash[:message].should  == sign_on.message
      end
    end
  end
end
