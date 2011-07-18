require "spec_helper"

describe "a call transfer" do

  testing_dsl do
    on :offer do |call|
      answer
      result = transfer('sip:userb@127.0.0.1')
      say('transfer was successful') if result.answered?
      say('sorry nobody is available at the moment') if result.timeout?
    end
  end

  before do
    @call_id = "34209dfiasdoaf"
    @server_address = "#{@call_id}@server.whatever"
    @client_address = "usera@127.0.0.whatever"
  end

  it "should send a transfer command" do
    incoming :offer_presence, @server_address, @client_address
    incoming :result_iq, @call_id

    Connfu.adaptor.commands.last.should == Connfu::Commands::Transfer.new(:transfer_to => ['sip:userb@127.0.0.1'], :to => @server_address, :from => @client_address)
  end

  it "should indicate that the call has been transferred successfully" do
    incoming :offer_presence, @server_address, @client_address
    incoming :result_iq, @call_id
    incoming :result_iq, @call_id
    incoming :transfer_success_presence, @call_id

    Connfu.adaptor.commands.last.should == Connfu::Commands::Say.new(:text => 'transfer was successful', :to => @server_address, :from => @client_address)
  end

  it "should indicate that the call transfer has been timed out" do
    incoming :offer_presence, @server_address, @client_address
    incoming :result_iq, @call_id
    incoming :result_iq, @call_id
    incoming :transfer_timeout_presence, @call_id

    Connfu.adaptor.commands.last.should == Connfu::Commands::Say.new(:text => 'sorry nobody is available at the moment', :to => @server_address, :from => @client_address)
  end
end

describe "a round-robin call transfer" do

  testing_dsl do
    on :offer do |call|
      answer
      result = transfer('sip:userb@127.0.0.1', 'sip:userc@127.0.0.1', :mode => :round_robin)
      say('transfer was successful') if result.answered?
      say('sorry nobody is available at the moment') if result.timeout?
    end
  end

  before do
    @call_id = "34209dfiasdoaf"
    @server_address = "#{@call_id}@server.whatever"
    @client_address = "usera@127.0.0.whatever"
  end

  it "should send a transfer command for the first sip address" do
    incoming :offer_presence, @server_address, @client_address
    incoming :result_iq, @call_id

    Connfu.adaptor.commands.last.should == Connfu::Commands::Transfer.new(:transfer_to => ['sip:userb@127.0.0.1'], :to => @server_address, :from => @client_address)
  end

  it "should continue to execute the next command if transfer to first sip address is successful" do
    incoming :offer_presence, @server_address, @client_address
    incoming :result_iq, @call_id
    incoming :result_iq, @call_id
    incoming :transfer_success_presence, @call_id

    Connfu.adaptor.commands.last.should == Connfu::Commands::Say.new(:text => 'transfer was successful', :to => @server_address, :from => @client_address)
  end

  it "should send a transfer command for the second sip address if the first one times out" do
    incoming :offer_presence, @server_address, @client_address
    incoming :result_iq, @call_id
    incoming :result_iq, @call_id
    incoming :transfer_timeout_presence, @call_id

    Connfu.adaptor.commands.last.should == Connfu::Commands::Transfer.new(:transfer_to => ['sip:userc@127.0.0.1'], :to => @server_address, :from => @client_address)
  end

  it "should indicate second transfer was successful" do
    incoming :offer_presence, @server_address, @client_address
    incoming :result_iq, @call_id
    incoming :result_iq, @call_id
    incoming :transfer_timeout_presence, @call_id
    incoming :result_iq, @call_id
    incoming :transfer_success_presence, @call_id

    Connfu.adaptor.commands.last.should == Connfu::Commands::Say.new(:text => 'transfer was successful', :to => @server_address, :from => @client_address)
  end

  it "should indicate both transfers time out" do
    incoming :offer_presence, @server_address, @client_address
    incoming :result_iq, @call_id
    incoming :result_iq, @call_id
    incoming :transfer_timeout_presence, @call_id
    incoming :result_iq, @call_id
    incoming :transfer_timeout_presence, @call_id

    Connfu.adaptor.commands.last.should == Connfu::Commands::Say.new(:text => 'sorry nobody is available at the moment', :to => @server_address, :from => @client_address)
  end

end

describe "A transfer that was rejected" do

  testing_dsl do
    on :offer do |call|
      answer
      result = transfer('sip:userb@127.0.0.1')
      if result.rejected?
        say "transfer was rejected"
      end
    end
  end

  before do
    @call_id = "34209dfiasdoaf"
    @server_address = "#{@call_id}@server.whatever"
    @client_address = "usera@127.0.0.whatever"
  end

  it "should indicate that the transfer was rejected by the end-point" do
    incoming :offer_presence, @server_address, @client_address
    incoming :result_iq, @call_id
    incoming :result_iq, @call_id
    incoming :transfer_rejected_presence, @call_id

    Connfu.adaptor.commands.last.should == Connfu::Commands::Say.new(:text => 'transfer was rejected', :to => @server_address, :from => @client_address)
  end
end

describe "A transfer that was rejected because far end is busy" do

  testing_dsl do
    on :offer do |call|
      answer
      result = transfer('sip:userb@127.0.0.1')
      if result.busy?
        say "transfer was rejected because far-end is busy"
      end
    end
  end

  before do
    @call_id = "34209dfiasdoaf"
    @server_address = "#{@call_id}@server.whatever"
    @client_address = "usera@127.0.0.whatever"
  end

  it "should indicate that the transfer was rejected because far-end is busy" do
    incoming :offer_presence, @server_address, @client_address
    incoming :result_iq, @call_id
    incoming :result_iq, @call_id
    incoming :transfer_busy_presence, @call_id

    Connfu.adaptor.commands.last.should == Connfu::Commands::Say.new(:text => 'transfer was rejected because far-end is busy', :to => @server_address, :from => @client_address)
  end
end