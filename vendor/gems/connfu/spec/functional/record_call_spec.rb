require 'spec_helper'

describe "Recording a call" do

  testing_dsl do
    on :offer do
      start_recording
      stop_recording
      hangup
    end
  end

  before :each do
    @call_id = "34209dfiasdoaf"
    @server_address = "#{@call_id}@server.whatever"
    @client_address = "usera@127.0.0.whatever/voxeo"
  end

  it "should send first record start command" do
    incoming :offer_presence, @server_address, @client_address

    Connfu.adaptor.commands.last.should == Connfu::Commands::Recording::Start.new(:to => @server_address, :from => @client_address)
  end

  it "should send the stop recording command with the recording ID when start recording has been sent" do
    recording_ref_id = "abc123"
    incoming :offer_presence, @server_address, @client_address
    incoming :recording_result_iq, @call_id, recording_ref_id

    Connfu.adaptor.commands.last.should == Connfu::Commands::Recording::Stop.new(:to => @server_address, :from => @client_address, :ref_id => recording_ref_id)
  end

  it "should hangup once we know the recording was complete" do
    recording_ref_id = "abc123"
    recording_path = "file:///tmp/recording.mp3"
    incoming :offer_presence, @server_address, @client_address
    incoming :recording_result_iq, @call_id, recording_ref_id
    incoming :result_iq, @call_id
    incoming :recording_stop_presence, @call_id, recording_ref_id, recording_path

    Connfu.adaptor.commands.last.should == Connfu::Commands::Hangup.new(:to => @server_address, :from => @client_address)
  end
end