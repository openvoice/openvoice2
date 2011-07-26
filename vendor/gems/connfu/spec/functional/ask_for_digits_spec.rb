require "spec_helper"

describe "ask a caller for 4 digits" do

  testing_dsl do
    on :offer do |call|
      result = ask(:prompt => "please enter a 4 digit pin", :digits => 4)
      say("you entered #{result}")
    end
  end

  before :each do
    @call_id = "34209dfiasdoaf"
    @server_address = "#{@call_id}@server.whatever"
    @client_address = "usera@127.0.0.whatever/voxeo"
  end

  it "should send an ask command" do
    incoming :offer_presence, @server_address, @client_address

    Connfu.connection.commands.last.should == Connfu::Commands::Ask.new(
      :to => @server_address,
      :from => @client_address,
      :prompt => "please enter a 4 digit pin",
      :digits => 4
    )
  end

  it "should continue when ask was successful" do
    incoming :offer_presence, @server_address, @client_address
    incoming :result_iq, @call_id
    incoming :ask_complete_success, @call_id, "1234"

    Connfu.connection.commands.last.should == Connfu::Commands::Say.new(
      :text => 'you entered 1234', :to => @server_address, :from => @client_address
    )
  end
end