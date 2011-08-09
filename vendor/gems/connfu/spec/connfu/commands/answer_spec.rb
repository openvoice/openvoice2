require "spec_helper"

describe Connfu::Commands::Answer do
  describe "generating XMPP iq" do
    subject do
      Connfu::Commands::Answer.new(:call_jid => 'call-jid', :client_jid => 'client-jid').to_iq
    end

    it "should generate answer iq from Answer command" do
      subject.xpath("//x:answer", "x" => rayo('1')).should_not be_empty
    end

    it "should be an iq of type 'set'" do
      subject.type.should eq :set
    end

    it "should send the command 'to' the server" do
      subject.xpath("/iq").first.attributes["to"].value.should eq "call-jid"
    end

    it "should send the command 'from' the client" do
      subject.xpath("/iq").first.attributes["from"].value.should eq "client-jid"
    end
  end
end