require "spec_helper"

describe Connfu::Commands::Redirect do

  describe "generating XMPP iq" do
    subject do
      @redirect_to = 'sip:1324@connfu.com'
      Connfu::Commands::Redirect.new(:redirect_to => @redirect_to, :to => 'server-address', :from => 'client-address').to_iq
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

    it "should generate redirect iq" do
      subject.xpath("//x:redirect", "x" => "urn:xmpp:ozone:1").should_not be_empty
    end

    it "should contain a 'redirect_to' attribute" do
      redirect_node = subject.xpath("//x:redirect", "x" => "urn:xmpp:ozone:1").first
      redirect_node.attributes['to'].value.should eq @redirect_to
    end
  end
end