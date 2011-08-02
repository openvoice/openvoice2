require "spec_helper"

describe "transfer using join" do

  testing_dsl do
    on :offer do |call|
      transfer_using_join("dial-from", "dial-to")
      $finished = finished?
    end
  end

  before do
    @call_id = "call-id"
    @server_address = "#{@call_id}@server.whatever"
    @client_address = "usera@127.0.0.whatever/voxeo"
  end

  it "should send a nested join when on incoming offer" do
    incoming :offer_presence, @server_address, @client_address

    Connfu.connection.commands.last.should == Connfu::Commands::NestedJoin.new(
      :dial_to => 'dial-to',
      :dial_from => 'dial-from',
      :to => @server_address,
      :from => @client_address,
      :call_id => @call_id
    )
  end

  it "should wait until a hangup is received" do
    incoming :offer_presence, @server_address, @client_address
    incoming :result_iq, @call_id
    incoming :joined_presence, @call_id, "a-new-call-id"
    incoming :joined_presence, "a-new-call-id", @call_id

    $finished.should_not be_true
  end

  it "should continue execution when hangup is received, but mark call as finished" do
    incoming :offer_presence, @server_address, @client_address
    incoming :result_iq, @call_id
    incoming :joined_presence, @call_id, "a-new-call-id"
    incoming :joined_presence, "a-new-call-id", @call_id
    incoming :hangup_presence, @call_id

    $finished.should be_true
  end
end