require 'spec_helper'

describe "Recording a call" do

  before :each do
    @call_jid = "call-id@server.whatever"
    @client_jid = "usera@127.0.0.whatever/voxeo"
    @recording_component_id = "abc123"
    @component_jid = "#{@call_jid}/#{@recording_component_id}"
    @recording_path = "file:///tmp/recording.mp3"
  end

  describe "with explicit stop command" do

    testing_dsl do
      on :offer do |call|
        answer
        start_recording
        stop_recording
        do_something(recordings)
        hangup
      end
    end

    it "should send first record start command" do
      incoming :offer_presence, @call_jid, @client_jid
      incoming :answer_result_iq, @call_jid

      last_command.should == Connfu::Commands::Recording::Start.new(:call_jid => @call_jid, :client_jid => @client_jid)
    end

    it "should send the stop recording command with the recording ID when start recording has been sent" do
      incoming :offer_presence, @call_jid, @client_jid
      incoming :answer_result_iq, @call_jid
      incoming :recording_result_iq, @call_jid, @recording_component_id

      last_command.should == Connfu::Commands::Recording::Stop.new(:call_jid => @call_jid, :client_jid => @client_jid, :component_id => @recording_component_id)
    end

    it "should be able to access the recording URI once the recording is complete" do
      dsl_instance.should_receive(:do_something).with([@recording_path])

      incoming :offer_presence, @call_jid, @client_jid
      incoming :answer_result_iq, @call_jid
      incoming :recording_result_iq, @call_jid, @recording_component_id
      incoming :recording_stop_result_iq, @call_jid, @recording_component_id
      incoming :recording_stop_presence, @component_jid, @recording_path
    end

    it "should hangup once we know the recording was complete" do
      dsl_instance.stub(:do_something)

      incoming :offer_presence, @call_jid, @client_jid
      incoming :answer_result_iq, @call_jid
      incoming :recording_result_iq, @call_jid, @recording_component_id
      incoming :recording_stop_result_iq, @call_jid, @recording_component_id
      incoming :recording_stop_presence, @component_jid, @recording_path

      last_command.should == Connfu::Commands::Hangup.new(:call_jid => @call_jid, :client_jid => @client_jid)
    end
  end

  describe "when the caller hangs up during recording" do
    testing_dsl do
      on :offer do |call|
        answer
        record_for 5
        say "very interesting"
      end
    end

    it "should not send any commands after the hangup is detected" do
      incoming :offer_presence, @call_jid, @client_jid
      incoming :answer_result_iq, @call_jid
      incoming :recording_result_iq, @call_jid, @recording_component_id
      incoming :recording_hangup_presence, @component_jid

      last_command.should_not be_instance_of(Connfu::Commands::Say)
    end
  end

  describe "without explicit stop command" do

    testing_dsl do
      on :offer do |call|
        answer
        record_for 5
        do_something(recordings)
      end
    end

    context "when recording reaches maximum length" do
      it "should be able to access the recording URI once the recording is complete" do
        dsl_instance.should_receive(:do_something).with([@recording_path])

        incoming :offer_presence, @call_jid, @client_jid
        incoming :answer_result_iq, @call_jid
        incoming :recording_result_iq, @call_jid, @recording_component_id
        incoming :recording_stop_presence, @component_jid, @recording_path
      end
    end

    context "when recording hangs up before reaching maximum length" do
      it "should be able to access the recording URI once the recording is complete" do
        dsl_instance.should_receive(:do_something).with([@recording_path])

        incoming :offer_presence, @call_jid, @client_jid
        incoming :answer_result_iq, @call_jid
        incoming :recording_result_iq, @call_jid, @recording_component_id
        incoming :recording_hangup_presence, @component_jid, @recording_path
      end
    end
  end
end

