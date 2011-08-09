require "spec_helper"

describe Connfu::Commands::Redirect do

  describe "generating XMPP iq" do
    subject do
      @redirect_to = 'sip:1324@connfu.com'
      Connfu::Commands::Redirect.new(:redirect_to => @redirect_to, :call_jid => 'call-jid', :client_jid => 'client-jid').to_iq
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

    it "should generate redirect iq" do
      subject.xpath("//x:redirect", "x" => rayo('1')).should_not be_empty
    end

    it "should contain a 'redirect_to' attribute" do
      redirect_node = subject.xpath("//x:redirect", "x" => rayo('1')).first
      redirect_node.attributes['to'].value.should eq @redirect_to
    end
  end
end