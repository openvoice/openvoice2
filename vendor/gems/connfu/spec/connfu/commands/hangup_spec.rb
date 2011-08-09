require "spec_helper"

describe Connfu::Commands::Hangup do

  describe "generating XMPP iq" do
    subject do
      Connfu::Commands::Hangup.new(:call_jid => 'call-jid', :client_jid => 'client-jid').to_iq
    end

    it "should generate hangup iq" do
      subject.xpath("//x:hangup", "x" => rayo('1')).should_not be_empty
    end

    it "should be an iq of type 'set'" do
      subject.type.should eq :set
    end

    it "should contain the 'to' address in the iq" do
      subject.xpath("/iq").first.attributes["to"].value.should eq "call-jid"
    end

    it "should contain the 'from' address in the iq" do
      subject.xpath("/iq").first.attributes["from"].value.should eq "client-jid"
    end
  end
end