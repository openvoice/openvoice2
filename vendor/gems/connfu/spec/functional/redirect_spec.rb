require "spec_helper"

describe "a call redirect" do

  testing_dsl do
    on :offer do |call|
      redirect('sip:another@connfu.com')
    end
  end

  before :each do
    @server_address = "34209dfiasdoaf@server.whatever"
    @client_address = "usera@127.0.0.whatever/voxeo"

    @redirect_to = 'sip:another@connfu.com'
  end

  it "should send the redirect command" do
    incoming :offer_presence, @server_address, @client_address

    Connfu.connection.commands.last.should == Connfu::Commands::Redirect.new(:redirect_to => @redirect_to, :to => @server_address, :from => @client_address)
  end
end
