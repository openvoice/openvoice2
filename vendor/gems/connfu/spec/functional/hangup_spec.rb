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