require 'spec_helper'

describe Connfu::Dsl do
  class DslTest
    include Connfu::Dsl
  end

  before do
    setup_connfu(nil)
    subject.stub(:wait)
  end

  subject {
    DslTest.new(:call_jid => "call-jid", :client_jid => "client-jid", :call_id => "call-id")
  }

  it 'should not allow the call JID to be modified' do
    subject.call_jid = "other-call-jid"
    subject.call_jid.should == "call-jid"
  end

  it 'should not allow the client JID to be modified' do
    subject.client_jid = "other-client-jid"
    subject.client_jid.should == "client-jid"
  end

  it 'should not allow the call ID to be modified' do
    subject.call_id = "other-call-id"
    subject.call_id.should == "call-id"
  end

  context 'where no jids or call id were provided' do
    subject { DslTest.new({}) }

    it 'should allow the call JID to be set' do
      subject.call_jid = "call-jid"
      subject.call_jid.should == "call-jid"
    end

    it 'should allow the client JID to be set' do
      subject.client_jid = "client-jid"
      subject.client_jid.should == "client-jid"
    end

    it 'should allow the call ID to be set' do
      subject.call_id = "call-id"
      subject.call_id.should == "call-id"
    end
  end

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

    it "should store the call id of the event that has fired" do
      event = Connfu::Event::Result.new(:call_id => 'call-id')
      subject.handle_event(event)
      subject.last_event_call_id.should == 'call-id'
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
      subject.send_command(Connfu::Commands::Say.new(:text => '', :client_jid => 'client-jid', :call_jid => 'call-jid'))

      iq = create_iq(result_iq("different-call-id@#{PRISM_HOST}", 'command-id'))
      result = Connfu::Rayo::Parser.parse_event_from(iq)

      subject.can_handle_event?(result).should be_true
    end

    it 'should be able to handle errors with same id but different call id' do
      Connfu.connection.stub(:send_command).and_return('command-id')
      subject.send_command(Connfu::Commands::Say.new(:text => '', :client_jid => 'client-jid', :call_jid => 'call-jid'))

      iq = create_iq(error_iq("different-call-id@#{PRISM_HOST}", 'command-id'))
      error = Connfu::Rayo::Parser.parse_event_from(iq)

      subject.can_handle_event?(error).should be_true
    end
  end

  describe 'say' do
    it 'should send Say command to connection' do
      text = 'connfu is awesome'
      Connfu.connection.should_receive(:send_command).with(Connfu::Commands::Say.new(:text => text, :client_jid => 'client-jid', :call_jid => 'call-jid'))
      catch :waiting do
        subject.say(text)
      end
    end
  end

  describe 'hangup' do
    it 'should send Hangup command to connection' do
      Connfu.connection.should_receive(:send_command).with(Connfu::Commands::Hangup.new(:client_jid => 'client-jid', :call_jid => 'call-jid'))
      subject.hangup
    end

    it 'should send a Hangup command wih the specified call jid' do
      Connfu.connection.should_receive(:send_command).with(Connfu::Commands::Hangup.new(:client_jid => 'client-jid', :call_jid => 'custom-call-jid'))
      subject.hangup 'custom-call-jid'
    end
  end

  describe 'reject' do
    it 'should send Reject command to connection' do
      Connfu.connection.should_receive(:send_command).with(Connfu::Commands::Reject.new(:client_jid => 'client-jid', :call_jid => 'call-jid'))
      subject.reject
    end
  end

  describe 'redirect' do
    it 'should send Redirect command to connection' do
      redirect_to = 'sip:1652@connfu.com'
      Connfu.connection.should_receive(:send_command).with(Connfu::Commands::Redirect.new(:redirect_to => redirect_to, :client_jid => 'client-jid', :call_jid => 'call-jid'))
      subject.redirect(redirect_to)
    end
  end

  describe 'dial' do
    it 'should send Dial command to connection' do
      Connfu.connection.should_receive(:send_command).with(Connfu::Commands::Dial.new(
        :to => "you",
        :from => "me",
        :client_jid => Connfu.connection.jid.to_s,
        :rayo_host => Connfu.connection.jid.domain
      )).and_return("command-id")
      subject.stub(:wait_for).and_return(stub(:ref_id => "call-id"))
      subject.dial(:to => "you", :from => "me")
    end

    it 'should start listening to events for the dialled call' do
      subject.stub(:send_command).and_return(stub(:ref_id => "call-id"))
      subject.dial(:to => "you", :from => "me")

      stanza = create_presence(ringing_presence("call-id@#{PRISM_HOST}"))
      ringing = Connfu::Rayo::Parser.parse_event_from(stanza)

      subject.can_handle_event?(ringing).should be_true
    end

    it 'should return the event for other commands' do
      result_event = stub(:ref_id => "call-id")
      subject.stub(:send_command).and_return(result_event)
      return_value = subject.dial(:to => "you", :from => "me")
      return_value.should == result_event
    end
  end

  describe 'transfer' do
    before :each do
      subject.stub(:wait_for).and_return(Connfu::Event::TransferSuccess.new)
    end

    it 'should send Transfer command to connection' do
      transfer_to = 'sip:1652@connfu.com'
      Connfu.connection.should_receive(:send_command).with(Connfu::Commands::Transfer.new(:transfer_to => [transfer_to], :client_jid => 'client-jid', :call_jid => 'call-jid'))
      catch :waiting do
        subject.transfer(transfer_to)
      end
    end

    it 'should send Transfer command with optional timeout in milliseconds' do
      transfer_to = 'sip:1652@connfu.com'
      timeout_in_seconds = 5
      cmd = Connfu::Commands::Transfer.new(:transfer_to => [transfer_to], :client_jid => 'client-jid', :call_jid => 'call-jid', :timeout => (timeout_in_seconds * 1000))
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
        :client_jid => 'client-jid',
        :call_jid => 'call-jid',
        :call_id => 'call-id'
      ))
      subject.transfer_using_join(dial_from, dial_to)
    end
  end

  describe 'recording' do
    it 'should send a start command to connection' do
      subject.stub(:wait_for).and_return(Connfu::Event::Result.new)
      Connfu.connection.should_receive(:send_command).with(Connfu::Commands::Recording::Start.new(
        :client_jid => 'client-jid', :call_jid => 'call-jid'
      ))
      subject.start_recording
    end

    it 'should send a start command to connection with optional beep parameter' do
      subject.stub(:wait_for).and_return(Connfu::Event::Result.new)
      Connfu.connection.should_receive(:send_command).with(Connfu::Commands::Recording::Start.new(
        :client_jid => 'client-jid', :call_jid => 'call-jid', :beep => false
      ))
      subject.start_recording(:beep => false)
    end

    it 'should send a start command to connection with optional format parameter' do
      subject.stub(:wait_for).and_return(Connfu::Event::Result.new)
      Connfu.connection.should_receive(:send_command).with(Connfu::Commands::Recording::Start.new(
        :client_jid => 'client-jid', :call_jid => 'call-jid', :format => :wav
      ))
      subject.start_recording(:format => :wav)
    end

    it 'should send a start command to connection with optional format and encoding parameters' do
      subject.stub(:wait_for).and_return(Connfu::Event::Result.new)
      Connfu.connection.should_receive(:send_command).with(Connfu::Commands::Recording::Start.new(
        :client_jid => 'client-jid', :call_jid => 'call-jid', :format => :wav, :codec => :mulaw_pcm_64k

      ))
      subject.start_recording(:format => :wav, :codec => :mulaw_pcm_64k)
    end

    it 'should send a start command to connection with optional timeout in milliseconds' do
      max_length_in_seconds = 25
      subject.stub(:wait_for).and_return(Connfu::Event::Result.new, Connfu::Event::RecordingStopComplete.new)
      Connfu.connection.should_receive(:send_command).with(Connfu::Commands::Recording::Start.new(
        :client_jid => 'client-jid', :call_jid => 'call-jid', :max_length => (max_length_in_seconds * 1000)
      ))
      subject.record_for(max_length_in_seconds)
    end

    it 'should send a start command to connection with optional timeout in milliseconds and beep parameter' do
      max_length_in_seconds = 25
      subject.stub(:wait_for).and_return(Connfu::Event::Result.new, Connfu::Event::RecordingStopComplete.new)
      Connfu.connection.should_receive(:send_command).with(Connfu::Commands::Recording::Start.new(
        :client_jid => 'client-jid', :call_jid => 'call-jid', :max_length => (max_length_in_seconds * 1000), :beep => false
      ))
      subject.record_for(max_length_in_seconds, :beep => false)
    end

    it 'should send a start command to connection with optional timeout in milliseconds and format parameter' do
      max_length_in_seconds = 25
      subject.stub(:wait_for).and_return(Connfu::Event::Result.new, Connfu::Event::RecordingStopComplete.new)
      Connfu.connection.should_receive(:send_command).with(Connfu::Commands::Recording::Start.new(
        :client_jid => 'client-jid', :call_jid => 'call-jid', :max_length => (max_length_in_seconds * 1000), :format => :wav
      ))
      subject.record_for(max_length_in_seconds, :format => :wav)
    end

    it 'should send a start command to connection with optional timeout in milliseconds and format parameter and encoding codec' do
      max_length_in_seconds = 25
      subject.stub(:wait_for).and_return(Connfu::Event::Result.new, Connfu::Event::RecordingStopComplete.new)
      Connfu.connection.should_receive(:send_command).with(Connfu::Commands::Recording::Start.new(
        :client_jid => 'client-jid', :call_jid => 'call-jid', :max_length => (max_length_in_seconds * 1000), :format => :wav, :codec => :mulaw_pcm_64k
      ))
      subject.record_for(max_length_in_seconds, :format => :wav, :codec => :mulaw_pcm_64k)
    end

    it 'should send a stop command to connection' do
      subject.stub(:wait_for).and_return(Connfu::Event::RecordingStopComplete.new)
      subject.instance_eval { @ref_id = 'foo' }
      Connfu.connection.should_receive(:send_command).with(Connfu::Commands::Recording::Stop.new(:client_jid => 'client-jid', :call_jid => 'call-jid', :ref_id => 'foo'))
      subject.stop_recording
    end
  end

  describe 'say' do
    it 'should send Ask command to connection and respond with captured input' do
      text = 'enter your pin number'
      digits = 4
      caller_input = "9812"
      subject.stub(:wait_for).and_return(Connfu::Event::AskComplete.new(:call_id => "call-id", :captured_input => caller_input))
      Connfu.connection.should_receive(:send_command).with(Connfu::Commands::Ask.new(:prompt => text, :client_jid => 'client-jid', :call_jid => 'call-jid', :digits => digits))
      catch :waiting do
        captured_input = subject.ask(:prompt => text, :digits => digits)
        captured_input.should eq "9812"
      end
    end
  end

  describe 'wait_for' do
    describe 'without a timeout' do
      it 'should not install a timeout' do
        EM.should_not_receive(:add_timer)
        subject.send(:wait_for, Connfu::Event::Answered)
      end
    end

    describe 'with a timeout' do
      it 'should timeout after the given number of seconds' do
        EM.should_receive(:add_timer).with(5)
        subject.send(:wait_for, Connfu::Event::Answered, :timeout => 5)
      end

      it 'should schedule a timeout event to be given to the handler in the future' do
        EM.stub!(:add_timer).and_yield()
        Connfu.event_processor.should_receive(:handle_event).with do |timeout_event|
          timeout_event.is_a?(Connfu::Dsl::Timeout) &&
          timeout_event.call_id == subject.call_id
        end
        subject.send(:wait_for, Connfu::Event::Answered, :timeout => 10)
      end

      it 'should tell the handler to expect a timeout event' do
        EM.stub!(:add_timer)
        subject.send(:wait_for, Connfu::Event::Answered, :timeout => 10)
        subject.should be_waiting_for(Connfu::Dsl::Timeout.new(subject.call_id))
      end

      it 'should cancel the timer when the pending event is received' do
        EM.stub!(:add_timer).and_return(:timer_signature)
        subject.stub!(:wait).and_return(Connfu::Event::Answered.new)
        EM.should_receive(:cancel_timer).with(:timer_signature)
        subject.send(:wait_for, Connfu::Event::Answered, :timeout => 10)
      end

      it 'should not cancel the timer when no event is received' do
        EM.stub!(:add_timer).and_return(:timer_signature)
        subject.stub!(:wait).and_return(nil)
        EM.should_not_receive(:cancel_timer).with(:timer_signature)
        subject.send(:wait_for, Connfu::Event::Answered, :timeout => 10)
      end
    end
  end
end