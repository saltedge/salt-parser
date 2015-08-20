require "spec_helper"

describe OFX do
  describe "#OFX" do
    it "should yield an OFX instance" do
      OFX("spec/ofx/fixtures/v102.ofx") do |ofx|
        ofx.class.should == OFX::Parser::OFX102
      end
    end

    it "should be an OFX instance" do
      OFX("spec/ofx/fixtures/v102.ofx") do
        self.class.should == OFX::Parser::OFX102
      end
    end

    it "should return parser" do
      OFX("spec/ofx/fixtures/v102.ofx").class.should == OFX::Parser::OFX102
    end
  end
end
