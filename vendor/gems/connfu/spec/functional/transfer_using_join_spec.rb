require "spec_helper"

describe "transfer using join" do

  testing_dsl do
    on :offer do |call|
      transfer_using_join("dial-from", "dial-to")
    end
  end

  before do
    @call_id = "call-id"
    @call_jid = "#{@call_id}@server.whatever"
    @client_jid = "usera@127.0.0.whatever/voxeo"
  end

  it "should send a nested join when on incoming offer" do
    incoming :offer_presence, @call_jid, @client_jid

    last_command.should == Connfu::Commands::NestedJoin.new(
      :dial_to => 'dial-to',
      :dial_from => 'dial-from',
      :call_jid => @call_jid,
      :client_jid => @client_jid,
      :call_id => @call_id
    )
  end

  it "should wait until a hangup is received" do
    incoming :offer_presence, @call_jid, @client_jid
    incoming :result_iq, @call_id
    incoming :joined_presence, @call_id, "a-new-call-id"
    incoming :joined_presence, "a-new-call-id", @call_id

    Connfu.should_not be_finished
  end

  it "should continue execution when hangup is received, but mark call as finished" do
    incoming :offer_presence, @call_jid, @client_jid
    incoming :result_iq, @call_id
    incoming :joined_presence, @call_id, "a-new-call-id"
    incoming :joined_presence, "a-new-call-id", @call_id
    incoming :hangup_presence, @call_id

    Connfu.should be_finished
  end
end