require "spec_helper"

describe Connfu::Commands::NestedJoin do

  describe "generating XMPP iq" do
    subject do
      Connfu::Commands::NestedJoin.new(
        :call_jid => 'call-jid',
        :client_jid => 'client-jid',
        :call_id => 'call-id',
        :dial_to => 'dial-to',
        :dial_from => 'dial-from').to_iq
    end

    it "should generate dial iq containing a nested join" do
      subject.xpath("//x:dial", "x" => rayo('1')).should_not be_empty
      subject.xpath("//x:dial/y:join", "x" => rayo('1'), "y" => rayo('join:1')).should_not be_empty
    end

    it "should be an iq of type 'set'" do
      subject.type.should eq :set
    end

    it "should send the attribute 'to' in the iq" do
      subject.xpath("/iq").first.attributes["to"].value.should eq "call-jid"
    end

    it "should send the attribute 'from' in the iq" do
      subject.xpath("/iq").first.attributes["from"].value.should eq "client-jid"
    end

    it "should contain the dial 'to' and 'from' in the dial iq element" do
      element = subject.xpath("//x:dial", "x" => rayo("1")).first
      element.attributes["to"].value.should eq "dial-to"
      element.attributes["from"].value.should eq "dial-from"
    end

    it "should contain a nested join with the correct attributes" do
      element = subject.xpath("//x:dial/y:join", "x" => rayo('1'), "y" => rayo('join:1')).first
      element.attributes["call-id"].value.should eq "call-id"
      element.attributes["media"].value.should eq "bridge"
      element.attributes["direction"].value.should eq "duplex"
    end
  end

end