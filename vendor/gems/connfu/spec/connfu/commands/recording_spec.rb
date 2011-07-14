require "spec_helper"

describe Connfu::Commands::Recording do

  describe "generating XMPP iq for a Start command" do
    subject do
      Connfu::Commands::Recording::Start.new(
        :to => 'server-address', :from => 'client-address'
      ).to_iq
    end

    it "should generate a record iq" do
      subject.xpath("//x:record", "x" => "urn:xmpp:ozone:record:1").should_not be_empty
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

    it 'should have correct iq attributes for recording type' do
      node = subject.xpath("//x:record", "x" => "urn:xmpp:ozone:record:1").first
      node.attributes['start-beep'].value.should eq 'true'
    end
  end

  describe "generating XMPP iq for a Stop command" do
    subject do
      Connfu::Commands::Recording::Stop.new(:to => 'server-address', :from => 'client-address', :ref_id => 'abc123').to_iq
    end

    it "should generate a stop record iq" do
      subject.xpath("//x:stop", "x" => "urn:xmpp:ozone:ext:1").should_not be_empty
    end

    it "should be an iq of type 'set'" do
      subject.type.should eq :set
    end

    it "should contain the 'to' address with the ref_id in the iq" do
      subject.xpath("/iq").first.attributes["to"].value.should eq "server-address/abc123"
    end

    it "should contain the 'from' address in the iq" do
      subject.xpath("/iq").first.attributes["from"].value.should eq "client-address"
    end

    it 'should not set any other iq attributes' do
      node = subject.xpath("//x:stop", "x" => "urn:xmpp:ozone:ext:1").first
      node.attributes.size.should eq 0
    end
  end
end