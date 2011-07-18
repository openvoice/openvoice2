require "spec_helper"

describe Connfu::Commands::Transfer do

  describe "generating XMPP iq" do
    subject do
      @transfer_to = ['sip:1324@connfu.com']
      Connfu::Commands::Transfer.new(:to => 'server-address', :from => 'client-address', :transfer_to => @transfer_to).to_iq
    end

    it "should generate transfer iq" do
      subject.xpath("//x:transfer", "x" => "urn:xmpp:ozone:transfer:1").should_not be_empty
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

    it 'should not contain a timeout attribute' do
      transfer_node = subject.xpath("x:transfer", "x" => "urn:xmpp:ozone:transfer:1").first
      transfer_node.attributes['timeout'].should be_nil
    end

    context 'with a timeout parameter' do
      subject do
        @transfer_to = ['sip:1324@connfu.com']
        Connfu::Commands::Transfer.new(:to => 'server-address', :from => 'client-address', :transfer_to => @transfer_to, :timeout => 5000).to_iq
      end

      it 'should contain a timeout attribute when it is passed in as an option' do
        transfer_node = subject.xpath("x:transfer", "x" => "urn:xmpp:ozone:transfer:1").first
        transfer_node.attributes['timeout'].value.should eq "5000"
      end
    end

    context 'when transfer to a single end-point' do
      it "should contain a 'transfer_to' node" do
        transfer_to_node = subject.xpath("//x:to", "x" => "urn:xmpp:ozone:transfer:1").first
        transfer_to_node.name.should eq 'to'
        transfer_to_node.text.should eq @transfer_to.first
      end
    end

    context 'when transfer to multiple end-points' do
      subject do
        @transfer_to = ['sip:1324@connfu.com', 'sip:3432@connfu.com']
        Connfu::Commands::Transfer.new(:to => 'server-address', :from => 'client-address', :transfer_to => @transfer_to).to_iq
      end

      it "should contain correct number of 'transfer_to' nodes" do
        transfer_to_nodes = subject.xpath("//x:to", "x" => "urn:xmpp:ozone:transfer:1")
        transfer_to_nodes.size.should eq @transfer_to.length
        transfer_to_nodes.each_with_index do |n, i|
          n.name.should eq 'to'
          n.text.should eq @transfer_to[i]
        end
      end
    end
  end
end