require "spec_helper"

describe Connfu::Commands::Say do

  describe "generating XMPP iq" do
    subject do
      Connfu::Commands::Say.new(:to => 'server-address', :from => 'client-address', :text => "Hello").to_iq
    end

    it "should generate say iq" do
      subject.xpath("//x:say", "x" => "urn:xmpp:ozone:say:1").should_not be_empty
    end

    it "should be an iq of type 'set'" do
      subject.type.should eq :set
    end

    it "should send the attribute 'to' in the iq" do
      subject.xpath("/iq").first.attributes["to"].value.should eq "server-address"
    end

    it "should send the attribute 'from' in the iq" do
      subject.xpath("/iq").first.attributes["from"].value.should eq "client-address"
    end

    it "should include the text to be spoken" do
      subject.xpath("//x:say", "x" => "urn:xmpp:ozone:say:1").first.inner_text.should eq "Hello"
    end
  end

  describe "generating XMPP iq with a url" do
    subject do
      @url = "http://www.phono.com/audio/troporocks.mp3"
      Connfu::Commands::Say.new(:to => 'server-address', :from => 'client-address', :text => @url).to_iq
    end

    it "should contain the 'audio' node with the correct src" do
      audio_node = subject.xpath('//x:audio', 'x' => 'urn:xmpp:ozone:say:1').first
      audio_node.should_not be_nil
      audio_node.attributes['src'].should_not be_nil
      audio_node.attributes['src'].value.should eq @url
    end
  end
end