require "spec_helper"

describe Connfu::Commands::Join do

  describe "generating XMPP iq" do
    describe "for the Dial command" do
      before do
        @connection = TestConnection.new
        Connfu.stub(:connection).and_return(@connection)
      end

      subject do
        Connfu::Commands::Join.new(
          :call_jid => 'call-jid-of-call-in-progress',
          :client_jid => 'client-jid',
          :call_id => 'call-id'
        ).to_iq
      end

      it "should be an iq of type 'set'" do
        subject.type.should eq :set
      end

      it "should contain the 'to' address in the iq" do
        subject.xpath("/iq").first.attributes["to"].value.should eq 'call-jid-of-call-in-progress'
      end

      it "should contain the 'from' address in the iq" do
        subject.xpath("/iq").first.attributes["from"].value.should eq 'client-jid'
      end

      describe 'join node' do
        before(:each) do
          @node = subject.xpath("//x:join", "x" => rayo('1')).first
        end

        it 'should exist' do
          @node.should_not be_nil
        end

        it 'should set the direction as duplex' do
          @node.attributes['direction'].value.should eq 'duplex'
        end

        it 'should set the media to bridge as direct does not work' do
          @node.attributes['media'].value.should eq 'bridge'
        end

        it 'should set the call_id of the call we wish to join' do
          @node.attributes['call-id'].value.should eq 'call-id'
        end
      end
    end
  end

end