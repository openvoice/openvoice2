require "spec_helper"

describe "hangup a call" do

  testing_dsl do
    on :offer do |call|
      hangup
    end
  end

  before :each do
    @call_id = '34209dfiasdoaf'
    @server_address = "#{@call_id}@server.whatever"
    @client_address = "usera@127.0.0.whatever/voxeo"
  end

  it "should send the hangup command" do
    incoming :offer_presence, @server_address, @client_address

    Connfu.adaptor.commands.last.should == Connfu::Commands::Hangup.new(:to => @server_address, :from => @client_address)
  end

  it "should handle the hangup event that will come back from the server" do
    incoming :offer_presence, @server_address, @client_address
    incoming :hangup_presence, @call_id
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
    @call_id = '34209dfiasdoaf'
    @server_address = "#{@call_id}@server.whatever"
    @client_address = "usera@127.0.0.whatever/voxeo"
  end

  it "should not send any commands after the hangup" do
    incoming :offer_presence, @server_address, @client_address
    incoming :result_iq, @call_id # from the answer command
    incoming :result_iq, @call_id # from the hangup command
    incoming :hangup_presence, @call_id

    Connfu.adaptor.commands.last.should == Connfu::Commands::Hangup.new(:to => @server_address, :from => @client_address)
  end
end