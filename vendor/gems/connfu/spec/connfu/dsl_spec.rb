require 'spec_helper'

describe Connfu::Dsl do
  class DslTest
    include Connfu::Dsl
  end

  before do
    Connfu.connection = TestConnection.new
    subject.stub(:wait)
  end

  subject {
    DslTest.new(:from => "server-address", :to => "client-address", :call_id => "call-id")
  }

  describe 'handle_event' do
    it 'should log unhandled event for debugging purposes' do
      unrecognised_event = Class.new(Connfu::Event::Presence).new
      subject.logger.should_receive(:warn)
      subject.handle_event(unrecognised_event)
    end

    it "should handle the event for another call id" do
      event_for_another_call = Connfu::Event::Result.new(:call_id => 'another-call-id', :command_id => 'the-command-id')
      subject.observe_events_for("another-call-id")
      subject.can_handle_event?(event_for_another_call).should be_true
    end
  end

  describe 'on' do
    it 'should raise an exception if context is unexpected' do
     lambda do
       DslTest.on(:goobledegook)
     end.should raise_error
    end
  end

  describe 'send_command' do
    it 'should be able to handle results with same id but different call id' do
      Connfu.connection.stub(:send_command).and_return('command-id')
      subject.send_command(Connfu::Commands::Say.new(:text => '', :from => 'client-address', :to => 'server-address'))
      result = Connfu::Event::Result.new(:call_id => 'different-call-id', :command_id => 'command-id')
      subject.can_handle_event?(result).should be_true
    end

    it 'should be able to handle errors with same id but different call id' do
      Connfu.connection.stub(:send_command).and_return('command-id')
      subject.send_command(Connfu::Commands::Say.new(:text => '', :from => 'client-address', :to => 'server-address'))
      error = Connfu::Event::Error.new(:call_id => 'different-call-id', :command_id => 'command-id')
      subject.can_handle_event?(error).should be_true
    end
  end

  describe 'say' do
    it 'should send Say command to connection' do
      text = 'connfu is awesome'
      Connfu.connection.should_receive(:send_command).with(Connfu::Commands::Say.new(:text => text, :from => 'client-address', :to => 'server-address'))
      catch :waiting do
        subject.say(text)
      end
    end
  end

  describe 'hangup' do
    it 'should send Hangup command to connection' do
      Connfu.connection.should_receive(:send_command).with(Connfu::Commands::Hangup.new(:from => 'client-address', :to => 'server-address'))
      subject.hangup
    end
  end

  describe 'reject' do
    it 'should send Reject command to connection' do
      Connfu.connection.should_receive(:send_command).with(Connfu::Commands::Reject.new(:from => 'client-address', :to => 'server-address'))
      subject.reject
    end
  end

  describe 'redirect' do
    it 'should send Redirect command to connection' do
      redirect_to = 'sip:1652@connfu.com'
      Connfu.connection.should_receive(:send_command).with(Connfu::Commands::Redirect.new(:redirect_to => redirect_to, :from => 'client-address', :to => 'server-address'))
      subject.redirect(redirect_to)
    end
  end

  describe 'transfer' do
    before :each do
      subject.stub(:wait_for).and_return(Connfu::Event::TransferSuccess.new)
    end

    it 'should send Transfer command to connection' do
      transfer_to = 'sip:1652@connfu.com'
      Connfu.connection.should_receive(:send_command).with(Connfu::Commands::Transfer.new(:transfer_to => [transfer_to], :from => 'client-address', :to => 'server-address'))
      catch :waiting do
        subject.transfer(transfer_to)
      end
    end

    it 'should send Transfer command with optional timeout in milliseconds' do
      transfer_to = 'sip:1652@connfu.com'
      timeout_in_seconds = 5
      cmd = Connfu::Commands::Transfer.new(:transfer_to => [transfer_to], :from => 'client-address', :to => 'server-address', :timeout => (timeout_in_seconds * 1000))
      Connfu.connection.should_receive(:send_command).with(cmd)
      catch :waiting do
        subject.transfer(transfer_to, :timeout => timeout_in_seconds)
      end
    end
  end

  describe "transfer using join" do
    it 'should send NestedJoin command to connection' do
      dial_to = 'sip:dial-to@example.com'
      dial_from = 'sip:dial-from@example.com'
      Connfu.connection.should_receive(:send_command).with(Connfu::Commands::NestedJoin.new(
        :dial_to => dial_to,
        :dial_from => dial_from,
        :from => 'client-address',
        :to => 'server-address',
        :call_id => 'call-id'
      ))
      subject.transfer_using_join(dial_from, dial_to)
    end
  end

  describe 'recording' do
    it 'should send a start command to connection' do
      subject.stub(:wait_for).and_return(Connfu::Event::Result.new)
      Connfu.connection.should_receive(:send_command).with(Connfu::Commands::Recording::Start.new(
        :from => 'client-address', :to => 'server-address'
      ))
      subject.start_recording
    end

    it 'should send a start command to connection with optional beep parameter' do
      subject.stub(:wait_for).and_return(Connfu::Event::Result.new)
      Connfu.connection.should_receive(:send_command).with(Connfu::Commands::Recording::Start.new(
        :from => 'client-address', :to => 'server-address', :beep => false
      ))
      subject.start_recording(:beep => false)
    end

    it 'should send a start command to connection with optional format parameter' do
      subject.stub(:wait_for).and_return(Connfu::Event::Result.new)
      Connfu.connection.should_receive(:send_command).with(Connfu::Commands::Recording::Start.new(
        :from => 'client-address', :to => 'server-address', :format => :wav
      ))
      subject.start_recording(:format => :wav)
    end

    it 'should send a start command to connection with optional format and encoding parameters' do
      subject.stub(:wait_for).and_return(Connfu::Event::Result.new)
      Connfu.connection.should_receive(:send_command).with(Connfu::Commands::Recording::Start.new(
        :from => 'client-address', :to => 'server-address', :format => :wav, :codec => :mulaw_pcm_64k

      ))
      subject.start_recording(:format => :wav, :codec => :mulaw_pcm_64k)
    end

    it 'should send a start command to connection with optional timeout in milliseconds' do
      max_length_in_seconds = 25
      subject.stub(:wait_for).and_return(Connfu::Event::Result.new, Connfu::Event::RecordingStopComplete.new)
      Connfu.connection.should_receive(:send_command).with(Connfu::Commands::Recording::Start.new(
        :from => 'client-address', :to => 'server-address', :max_length => (max_length_in_seconds * 1000)
      ))
      subject.record_for(max_length_in_seconds)
    end

    it 'should send a start command to connection with optional timeout in milliseconds and beep parameter' do
      max_length_in_seconds = 25
      subject.stub(:wait_for).and_return(Connfu::Event::Result.new, Connfu::Event::RecordingStopComplete.new)
      Connfu.connection.should_receive(:send_command).with(Connfu::Commands::Recording::Start.new(
        :from => 'client-address', :to => 'server-address', :max_length => (max_length_in_seconds * 1000), :beep => false
      ))
      subject.record_for(max_length_in_seconds, :beep => false)
    end

    it 'should send a start command to connection with optional timeout in milliseconds and format parameter' do
      max_length_in_seconds = 25
      subject.stub(:wait_for).and_return(Connfu::Event::Result.new, Connfu::Event::RecordingStopComplete.new)
      Connfu.connection.should_receive(:send_command).with(Connfu::Commands::Recording::Start.new(
        :from => 'client-address', :to => 'server-address', :max_length => (max_length_in_seconds * 1000), :format => :wav
      ))
      subject.record_for(max_length_in_seconds, :format => :wav)
    end

    it 'should send a start command to connection with optional timeout in milliseconds and format parameter and encoding codec' do
      max_length_in_seconds = 25
      subject.stub(:wait_for).and_return(Connfu::Event::Result.new, Connfu::Event::RecordingStopComplete.new)
      Connfu.connection.should_receive(:send_command).with(Connfu::Commands::Recording::Start.new(
        :from => 'client-address', :to => 'server-address', :max_length => (max_length_in_seconds * 1000), :format => :wav, :codec => :mulaw_pcm_64k
      ))
      subject.record_for(max_length_in_seconds, :format => :wav, :codec => :mulaw_pcm_64k)
    end

    it 'should send a stop command to connection' do
      subject.stub(:wait_for).and_return(Connfu::Event::RecordingStopComplete.new)
      subject.instance_eval { @ref_id = 'foo' }
      Connfu.connection.should_receive(:send_command).with(Connfu::Commands::Recording::Stop.new(:from => 'client-address', :to => 'server-address', :ref_id => 'foo'))
      subject.stop_recording
    end
  end

  describe 'say' do
    it 'should send Ask command to connection and respond with captured input' do
      text = 'enter your pin number'
      digits = 4
      caller_input = "9812"
      subject.stub(:wait_for).and_return(Connfu::Event::AskComplete.new(:call_id => "call-id", :captured_input => caller_input))
      Connfu.connection.should_receive(:send_command).with(Connfu::Commands::Ask.new(:prompt => text, :from => 'client-address', :to => 'server-address', :digits => digits))
      catch :waiting do
        captured_input = subject.ask(:prompt => text, :digits => digits)
        captured_input.should eq "9812"
      end
    end
  end
end