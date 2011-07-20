require "spec_helper"

describe Connfu::Commands::Hangup do

  describe "generating XMPP iq" do
    subject do
      Connfu::Commands::Hangup.new(:to => 'server-address', :from => 'client-address').to_iq
    end

    it "should generate hangup iq" do
      subject.xpath("//x:hangup", "x" => "urn:xmpp:ozone:1").should_not be_empty
    end

    it "should be an iq of type 'set'" do
      subject.type.should eq :set
    end

    it "should contain the 'to' address in the iq" do
      subject.xpath("/iq").first.attributes["to"].value.should eq "server-address"
    end

    it "should contain the 'from' address in the iq" do
      subject.xpath("/iq").first.attributes["from"].value.should eq "client-address"
    end
  end
end