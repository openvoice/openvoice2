require "spec_helper"

describe "a call reject" do

  testing_dsl do
    on :offer do |call|
      reject
    end
  end

  before :each do
    @call_jid = "call-id@server.whatever"
    @client_jid = "usera@127.0.0.whatever/voxeo"
  end

  it "should send the reject command" do
    incoming :offer_presence, @call_jid, @client_jid

    last_command.should == Connfu::Commands::Reject.new(:call_jid => @call_jid, :client_jid => @client_jid)
  end
end
