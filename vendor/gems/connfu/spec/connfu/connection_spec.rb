require "spec_helper"

describe Connfu::Connection do
  describe '#initialize' do
    subject do
      Connfu::Connection.new(Connfu::Configuration.new)
    end

    it "should register iq handler for offer" do
      iq = mock('incoming_iq')
      Connfu.event_processor = mock('event-processor', :handle_event => true)
      Connfu::Rayo::Parser.should_receive(:parse_event_from).with(iq)
      subject.send :call_handler_for, :iq, iq
    end

    it 'should register presence handler' do
      presence = mock('presence')
      Connfu.event_processor = mock('event-processor', :handle_event => true)
      Connfu::Rayo::Parser.should_receive(:parse_event_from).with(presence)
      subject.send :call_handler_for, :presence, presence
    end
  end

  describe '#send_command' do

    subject { Connfu::Connection.new(Connfu.config) }

    before do
      @blather_client = stub('blather_client')
      @command = stub('command')
      xmpp = stub('xmpp', :attributes => { 'id' => 'some-id' })
      @command.stub(:to_iq).and_return(xmpp)
      subject.stub(:blather_client).and_return(@blather_client)
    end

    it "should write XMPP versions of commands to its underlying connection" do
      @blather_client.should_receive(:write).with(@command.to_iq)
      subject.send_command(@command)
    end

    it "should return id of underlying XMPP command" do
      @blather_client.stub(:write)
      subject.send_command(@command).should eql('some-id')
    end
  end
end