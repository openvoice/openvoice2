require "spec_helper"

describe "hangup a call" do

  testing_dsl do
    on :offer do |call|
      hangup
    end
  end

  before :each do
    @call_jid = "call-id@server.whatever"
    @client_jid = "usera@127.0.0.whatever/voxeo"
  end

  it "should send the hangup command" do
    incoming :offer_presence, @call_jid, @client_jid

    last_command.should == Connfu::Commands::Hangup.new(:call_jid => @call_jid, :client_jid => @client_jid)
  end

  it "should handle the hangup event that will come back from the server" do
    incoming :offer_presence, @call_jid, @client_jid
    incoming :hangup_presence, @call_jid
  end
end

describe "defining behaviour after a hangup" do
  testing_dsl do
    on :offer do |call|
      answer
      hangup
      say "I'm talking to the space *between* phonecalls"
    end
  end

  before :each do
    @call_jid = "call-id@server.whatever"
    @client_jid = "usera@127.0.0.whatever/voxeo"
  end

  it "should not send any commands after the hangup" do
    incoming :offer_presence, @call_jid, @client_jid
    incoming :result_iq, @call_jid # from the answer command
    incoming :result_iq, @call_jid # from the hangup command
    incoming :hangup_presence, @call_jid

    last_command.should == Connfu::Commands::Hangup.new(:call_jid => @call_jid, :client_jid => @client_jid)
  end
end

describe "hanging up an observed call" do
  testing_dsl do
    on :offer do |call|
      answer
      result = dial :to => "a", :from => "b"
      other_call_id = result.ref_id
      wait_for Connfu::Event::Answered
      hangup other_call_id
      say "Phew, glad he's gone"
    end
  end

  before :each do
    @call_jid = "call-id@server.whatever"
    @other_call_id = "call-2-id"
    @other_call_jid = "#{@other_call_id}@server.whatever"
    @client_jid = "usera@127.0.0.whatever/voxeo"
  end

  it "should still send commands once the other call is hung up" do
    incoming :offer_presence, @call_jid, @client_jid
    incoming :result_iq, @call_jid # from the answer command
    incoming :dial_result_iq, @other_call_id, last_command.id # from the dial command
    incoming :ringing_presence, @other_call_jid
    incoming :answered_presence, @other_call_jid
    incoming :result_iq, @other_call_jid # from the hangup command
    incoming :hangup_presence, @other_call_jid

    last_command.should == Connfu::Commands::Say.new(:text => "Phew, glad he's gone", :call_jid => @call_jid, :client_jid => @client_jid)
  end
end

describe "receiving hangup from a caller" do
  testing_dsl do
    on :offer do |call|
      answer
      say "a very long story"
    end
  end

  before :each do
    @call_jid = "call-id@server.whatever"
    @client_jid = "usera@127.0.0.whatever/voxeo"
  end

  it "should not send an implicit hangup command" do
    incoming :offer_presence, @call_jid, @client_jid
    incoming :result_iq, @call_jid # from the answer command
    incoming :result_iq, @call_jid # from the say command
    incoming :hangup_presence, @call_jid # via the user hanging up
    incoming :say_success_presence, @call_jid

    last_command.should_not be_instance_of(Connfu::Commands::Hangup)
  end
end