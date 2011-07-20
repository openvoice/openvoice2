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
    @server_address = "#{@call_id}@server.whatever"
    @client_address = "usera@127.0.0.whatever/voxeo"
  end

  it "should send an answer command" do
    incoming :offer_presence, @server_address, @client_address

    Connfu.adaptor.commands.last.should == Connfu::Commands::Answer.new(:to => @server_address, :from => @client_address)
  end

  it "should continue to execute once the result of the answer is received" do
    dsl_instance.should_receive(:do_something)

    incoming :offer_presence, @server_address, @client_address
    incoming :result_iq, @call_id
  end
end