require "spec_helper"

describe Connfu::Commands::Accept do

  describe "generating XMPP iq" do
    subject do
      Connfu::Commands::Accept.new(:to => 'server-address', :from => 'client-address').to_iq
    end

    it "should generate accept iq from Accept command" do
      subject.xpath("//x:accept", "x" => "urn:xmpp:ozone:1").should_not be_empty
    end

    it "should be an iq of type 'set'" do
      subject.type.should eq :set
    end

    it "should send the command 'to' the server" do
      subject.xpath("/iq").first.attributes["to"].value.should eq "server-address"
    end

    it "should send the command 'from' the client" do
      subject.xpath("/iq").first.attributes["from"].value.should eq "client-address"
    end
  end

end