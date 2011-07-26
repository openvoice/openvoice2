require 'spec_helper'

describe "Dialing a single number from within the DSL" do
  testing_dsl do
    # intentionally left blank
  end

  before do
    Connfu::Queue.clear
    @dsl_class.dial(:to => 'sip-to', :from => 'sip-from')
  end

  it 'should add a dial job in the dial queue' do
    Connfu::Queue.size(Connfu::Jobs::Dial.queue).should == 1
  end

  it "should pass the to & from options to the command" do
    job = Connfu::Queue.reserve(Connfu::Jobs::Dial.queue)
    job.args.first['to'].should == 'sip-to'
    job.args.first['from'].should == 'sip-from'
  end

  it "should send dial command with the supplied options" do
    job = Connfu::Queue.reserve(Connfu::Jobs::Dial.queue)
    Connfu.connection.should_receive(:send_command).with(Connfu::Commands::Dial.new(:to => 'sip-to', :from => 'sip-from'))
    job.perform
  end
end

describe 'Dialing a single number from within the DSL passing custom headers' do
  testing_dsl do
    # intentionally left blank
  end

  before do
    Connfu::Queue.clear
    @dsl_class.dial(:to => 'sip-to', :from => 'sip-from', :headers => { 'foo' => 'bar' })
  end

  it "should pass the supplied headers to the command" do
    job = Connfu::Queue.reserve(Connfu::Jobs::Dial.queue)
    job.args.first['headers'].should == { 'foo' => 'bar' }
  end
end

describe "Handling any outgoing call" do
  testing_dsl do
    def ringing_happened
    end
    def hangup_happened
    end

    on :outgoing_call do |call|
      call.on_ringing do
        ringing_happened
      end
      call.on_answer do
        say 'something'
        say 'another thing'
      end
      call.on_hangup do
        hangup_happened
      end
    end
  end

  before :each do
    @call_id = 'outbound_call_id'
  end

  it 'should run the ringing behaviour when the call starts ringing' do
    dsl_instance.should_receive(:ringing_happened)

    incoming :outgoing_call_ringing_presence, @call_id
  end

  it 'should send a say command when the call is answered' do
    incoming :outgoing_call_ringing_presence, @call_id
    incoming :outgoing_call_answered_presence, @call_id

    Connfu.connection.commands.last.should == Connfu::Commands::Say.new(:text => 'something', :to => "#{@call_id}@#{PRISM_HOST}", :from => "#{PRISM_JID}/voxeo")
  end

  it 'should only invoke the second say once the first has completed' do
    incoming :outgoing_call_ringing_presence, @call_id
    incoming :outgoing_call_answered_presence, @call_id
    incoming :result_iq, @call_id
    incoming :say_complete_success, @call_id

    Connfu.connection.commands.last.should == Connfu::Commands::Say.new(:text => 'another thing', :to => "#{@call_id}@#{PRISM_HOST}", :from => "#{PRISM_JID}/voxeo")
  end

  it 'should run the hangup behaviour when the call is hung up' do
    dsl_instance.should_receive(:hangup_happened)

    incoming :outgoing_call_ringing_presence, @call_id
    incoming :hangup_presence, @call_id
  end
end

describe "Dialing when no behaviour is specified" do
  testing_dsl do
    # intentionally left blank
  end

  before :each do
    @call_id = 'outbound_call_id'
    Connfu::Queue.clear
    @dsl_class.dial :to => "someone-remote", :from => "my-number"
    job = Connfu::Queue.reserve(Connfu::Jobs::Dial.queue)
    job.perform
  end

  it 'should not crash when receiving a ringing event' do
    lambda {
      incoming :outgoing_call_ringing_presence, @call_id
    }.should_not raise_error
  end

  it 'should not crash when receiving an answered event' do
    lambda {
      incoming :outgoing_call_ringing_presence, @call_id
      incoming :outgoing_call_answered_presence, @call_id
    }.should_not raise_error
  end

  it 'should not crash when receiving a hangup event' do
    lambda {
      incoming :outgoing_call_ringing_presence, @call_id
      incoming :hangup_presence, @call_id
    }.should_not raise_error
  end
end