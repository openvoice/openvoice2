require "spec_helper"

describe Connfu::Commands::Ask do

  describe "generating XMPP iq" do
    subject do
      Connfu::Commands::Ask.new(
        :to => 'server-address',
        :from => 'client-address',
        :prompt => "enter your pin",
        :digits => 4
      ).to_iq
    end

    it "should generate ask iq" do
      subject.xpath("//x:ask", "x" => tropo('ask:1')).should_not be_empty
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

    it "should set the mode to default dtmf" do
      subject.xpath("//x:ask", "x" => tropo('ask:1')).first.attributes["mode"].value.should eq "dtmf"
    end

    it "should set the terminator to hash by default" do
      subject.xpath("//x:ask", "x" => tropo('ask:1')).first.attributes["terminator"].value.should eq "#"
    end

    it "should include the prompt to be spoken as an element within the ask" do
      prompt_elements = subject.xpath("//x:ask/x:prompt", "x" => tropo('ask:1'))
      prompt_elements.should_not be_empty
      prompt_elements.first.inner_text.should eq "enter your pin"
    end

    it "should include the number of digits in the choices element" do
      choices = subject.xpath("//x:ask/x:choices", "x" => tropo('ask:1'))
      choices.should_not be_empty
      choices.first.attributes["content-type"].value.should eq "application/grammar+voxeo"
      choices.first.inner_text.should eq "[4 DIGITS]"
    end
  end
end