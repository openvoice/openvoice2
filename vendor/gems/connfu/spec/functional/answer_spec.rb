require "spec_helper"

describe "answering a call" do

  testing_dsl do
    on :offer do |call|
      answer
      do_something
    end
  end

  before :each do
    @call_id = "34209dfiasdoaf"
    @call_jid = "#{@call_id}@server.whatever"
    @client_jid = "usera@127.0.0.whatever/voxeo"
  end

  it "should send an answer command" do
    incoming :offer_presence, @call_jid, @client_jid

    Connfu.connection.commands.last.should == Connfu::Commands::Answer.new(:call_jid => @call_jid, :client_jid => @client_jid)
  end

  it "should continue to execute once the result of the answer is received" do
    dsl_instance.should_receive(:do_something)

    incoming :offer_presence, @call_jid, @client_jid
    incoming :result_iq, @call_id
  end
end