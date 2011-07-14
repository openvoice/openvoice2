require 'spec_helper'

describe Connfu do
  describe "#setup" do
    before do
      @host = 'foo@bar.com'
      @password = 'password'
      Connfu.setup(@host, @password)
    end

    it "should create a connection to server" do
      @connection = Connfu.connection
      @connection.should be_instance_of(Blather::Client)
      @connection.should be_setup
    end

    it "should register iq handler for offer" do
      iq = mock('incoming_iq')
      Connfu.event_processor = mock('event-processor', :handle_event => true)
      Connfu::Ozone::Parser.should_receive(:parse_event_from).with(iq)
      Connfu.connection.send :call_handler_for, :iq, iq
    end

    it 'should register presence handler' do
      presence = mock('presence')
      Connfu.event_processor = mock('event-processor', :handle_event => true)
      Connfu::Ozone::Parser.should_receive(:parse_event_from).with(presence)
      Connfu.connection.send :call_handler_for, :presence, presence
    end
  end

  describe "#start" do
    it "should start the EventMachine" do
      EM.should_receive(:run)
      Connfu.start(MyTestClass)
    end
  end
end