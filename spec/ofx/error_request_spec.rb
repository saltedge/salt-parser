require "spec_helper"

describe "Error request" do
  let(:parser)  { SaltParser::OFX::Builder.new("spec/ofx/fixtures/request_error.ofx").parser }
  let(:parser2) { SaltParser::OFX::Builder.new("spec/ofx/fixtures/request_error2.ofx").parser }
  let(:parser3) { SaltParser::OFX::Builder.new("spec/ofx/fixtures/request_error3.ofx").parser }

  describe "errors" do
    it "should contain SaltParser::Error::RequestError" do
      parser.errors.size.should == 2

      error = parser.errors.first
      error.class.should   == SaltParser::Error::RequestError
      error.message.should == "[2000] Application which you are using is not enabled. Please call customer service."
    end

    it "should contain SaltParser::Error::RequestError" do
      parser2.errors.size.should == 1

      error = parser2.errors.first
      error.class.should   == SaltParser::Error::RequestError
      error.message.should == "[2019] A duplicate request has been entered."
    end

    it "should contain SaltParser::Error::RequestError" do
      parser3.errors.size.should == 2

      error = parser3.errors.first
      error.class.should   == SaltParser::Error::RequestError
      error.message.should == "[15500]"

      second_error = parser3.errors.last
      second_error.class.should   == SaltParser::Error::RequestError
      second_error.message.should == "[2000] Due to an error, we are unable to complete your request; please contact your software support."
    end
  end
end
