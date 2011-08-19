require "spec_helper"

describe "Dialing" do
  class Dialer
    include Connfu::Dsl
    class << self; attr_accessor :stash; end
  end

  before do
    setup_connfu(handler_class = nil)
  end

  it "should send a dial command" do
    Dialer.dial :to => "recipient", :from => "caller" do |call|
    end
    last_command.should == Connfu::Commands::Dial.new(:to => "recipient", :from => "caller", :client_jid => Connfu.connection.jid.to_s, :rayo_host => Connfu.connection.jid.domain)
  end

  it "should pass any headers to the dial command" do
    Dialer.dial :to => "to", :from => "from", :headers => {"foo" => "bar"} do |call|
    end
    last_command.should == Connfu::Commands::Dial.new(:to => "to", :from => "from", :client_jid => Connfu.connection.jid.to_s, :rayo_host => Connfu.connection.jid.domain, :headers => {"foo" => "bar"})
  end

  it "should not run the start behaviour before the call has begun" do
    Dialer.any_instance.should_not_receive(:start_happened)

    Dialer.dial :to => "to", :from => "from" do |c|
      c.on_start { start_happened }
    end
  end

  it "should run the start behaviour when the call has begun" do
    Dialer.any_instance.should_receive(:start_happened)

    Dialer.dial :to => "to", :from => "from" do |c|
      c.on_start { start_happened }
    end

    incoming :outgoing_call_result_iq, "call-id", last_command.id
  end

  it 'should not run the ringing behaviour before the call starts ringing' do
    Dialer.any_instance.should_not_receive(:ringing_happened)

    Dialer.dial :to => "to", :from => "from" do |c|
      c.on_ringing { ringing_happened }
    end

    incoming :outgoing_call_result_iq, "call-id", last_command.id
  end

  it 'should run the ringing behaviour when the call starts ringing' do
    Dialer.any_instance.should_receive(:ringing_happened)

    Dialer.dial :to => "to", :from => "from" do |c|
      c.on_ringing { ringing_happened }
    end

    incoming :outgoing_call_result_iq, "call-id", last_command.id
    incoming :outgoing_call_ringing_presence, "call-id"
  end

  it 'should run the reject behaviour when the call is rejected' do
    Dialer.any_instance.should_receive(:reject_happened)

    Dialer.dial :to => "to", :from => "from" do |c|
      c.on_reject { reject_happened }
    end

    incoming :outgoing_call_result_iq, "call-id", last_command.id
    incoming :outgoing_call_ringing_presence, "call-id"
    incoming :reject_presence, "call-id"
  end

  it 'should run the timeout behaviour when the call is timed out' do
    Dialer.any_instance.should_receive(:timeout_happened)

    Dialer.dial :to => "to", :from => "from" do |c|
      c.on_timeout { timeout_happened }
    end

    incoming :outgoing_call_result_iq, "call-id", last_command.id
    incoming :outgoing_call_ringing_presence, "call-id"
    incoming :timeout_presence, "call-id"
  end

  it 'should not run the answer behaviour before the call is answered' do
    Dialer.any_instance.should_not_receive(:answer_happened)

    Dialer.dial :to => "to", :from => "from" do |c|
      c.on_answer { answer_happened }
    end

    incoming :outgoing_call_result_iq, "call-id", last_command.id
    incoming :outgoing_call_ringing_presence, "call-id"
  end

  it 'should run the answer behaviour when the call is answered' do
    Dialer.any_instance.should_receive(:answer_happened)

    Dialer.dial :to => "to", :from => "from" do |c|
      c.on_answer { answer_happened }
    end

    incoming :outgoing_call_result_iq, "call-id", last_command.id
    incoming :outgoing_call_ringing_presence, "call-id"
    incoming :outgoing_call_answered_presence, "call-id"
  end

  it 'should not run the hangup behaviour before the call is hung up' do
    Dialer.any_instance.should_not_receive(:hangup_happened)

    Dialer.dial :to => "to", :from => "from" do |c|
      c.on_hangup { hangup_happened }
    end

    incoming :outgoing_call_result_iq, "call-id", last_command.id
    incoming :outgoing_call_ringing_presence, "call-id"
    incoming :outgoing_call_answered_presence, "call-id"
  end

  it 'should run the hangup behaviour when the call is hung up' do
    Dialer.any_instance.should_receive(:hangup_happened)

    Dialer.dial :to => "to", :from => "from" do |c|
      c.on_hangup { hangup_happened }
    end

    incoming :outgoing_call_result_iq, "call-id", last_command.id
    incoming :outgoing_call_ringing_presence, "call-id"
    incoming :outgoing_call_answered_presence, "call-id"
    incoming :hangup_presence, "call-id"
  end

  it 'should run all behaviours that are defined' do
    Dialer.any_instance.should_receive(:start_happened)
    Dialer.any_instance.should_receive(:ringing_happened)
    Dialer.any_instance.should_receive(:answer_happened)
    Dialer.any_instance.should_receive(:hangup_happened)

    Dialer.dial :to => "to", :from => "from" do |c|
      c.on_start   { start_happened }
      c.on_ringing { ringing_happened }
      c.on_answer  { answer_happened }
      c.on_hangup  { hangup_happened }
    end

    incoming :outgoing_call_result_iq, "call-id", last_command.id
    incoming :outgoing_call_ringing_presence, "call-id"
    incoming :outgoing_call_answered_presence, "call-id"
    incoming :hangup_presence, "call-id"
  end

  it "should make the call id available when the on_start block is triggered" do
    Dialer.dial :to => "to", :from => "from" do |c|
      c.on_start { Dialer.stash = call_id }
    end

    incoming :outgoing_call_result_iq, "call-id", last_command.id

    Dialer.stash.should == "call-id"
  end

  context "when no behaviour is specified" do
    before do
      Dialer.dial :to => "someone-remote", :from => "my-number"
    end

    it 'should not crash when receiving a ringing event' do
      lambda {
        incoming :outgoing_call_result_iq, "call-id", last_command.id
        incoming :outgoing_call_ringing_presence, "call-id"
      }.should_not raise_error
    end

    it 'should not crash when receiving an answered event' do
      lambda {
        incoming :outgoing_call_result_iq, "call-id", last_command.id
        incoming :outgoing_call_ringing_presence, "call-id"
        incoming :outgoing_call_answered_presence, "call-id"
      }.should_not raise_error
    end

    it 'should not crash when receiving a hangup event' do
      lambda {
        incoming :outgoing_call_result_iq, "call-id", last_command.id
        incoming :outgoing_call_ringing_presence, "call-id"
        incoming :hangup_presence, "call-id"
      }.should_not raise_error
    end
  end

  context "behaviour blocks" do
    before do
      Dialer.dial :to => "to", :from => "from" do |c|
        c.on_answer do
          say "hello"
          say "is it me you're looking for?"
        end
      end
    end

    it "should allow running commands" do
      incoming :outgoing_call_result_iq, "call-id", last_command.id
      incoming :outgoing_call_ringing_presence, "call-id", "client-jid"
      incoming :outgoing_call_answered_presence, "call-id"

      say_command = last_command
      say_command.should be_instance_of Connfu::Commands::Say
      say_command.text.should == "hello"
      say_command.call_jid.should == "call-id@#{PRISM_HOST}"
      say_command.client_jid.should == "client-jid"
    end

    it "should not execute next command until the previous is completed" do
      incoming :outgoing_call_result_iq, "call-id", last_command.id
      incoming :outgoing_call_ringing_presence, "call-id"
      incoming :outgoing_call_answered_presence, "call-id"
      incoming :result_iq, "call-id"

      last_command.should be_instance_of Connfu::Commands::Say
      last_command.text.should == "hello"
    end

    it "should continue executing next command when the previous has completed" do
      incoming :outgoing_call_result_iq, "call-id", last_command.id
      incoming :outgoing_call_ringing_presence, "call-id"
      incoming :outgoing_call_answered_presence, "call-id"
      incoming :result_iq, "call-id"
      incoming :say_complete_success, "call-id"

      last_command.should be_instance_of Connfu::Commands::Say
      last_command.text.should == "is it me you're looking for?"
    end
  end
end

describe "dialing with instance-specific call behaviour" do
  class DiallerWithInstanceSpecificBehaviour
    include Connfu::Dsl

    class << self
      def execute(instance_specific_argument)
        dial :to => "recipient", :from => "caller" do |call|
          call.on_answer { say instance_specific_argument }
        end
      end
    end
  end

  before do
    setup_connfu(handler_class = nil)
  end

  it "should retain the specific behaviour for each dial statement" do
    DiallerWithInstanceSpecificBehaviour.execute "first behaviour"
    first_dial_command_id = last_command.id
    DiallerWithInstanceSpecificBehaviour.execute "second behaviour"

    incoming :outgoing_call_result_iq, "call-1", first_dial_command_id
    incoming :outgoing_call_ringing_presence, "call-1"
    incoming :outgoing_call_answered_presence, "call-1"

    last_command.should be_instance_of Connfu::Commands::Say
    last_command.text.should == "first behaviour"
  end
end