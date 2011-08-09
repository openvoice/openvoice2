require "spec_helper"

describe "say something on a call" do

  testing_dsl do
    on :offer do |call|
      say('hello, this is connfu')
      say('http://www.phono.com/audio/troporocks.mp3')
    end
  end

  before :each do
    @call_id = "34209dfiasdoaf"
    @call_jid = "#{@call_id}@server.whatever"
    @client_jid = "usera@127.0.0.whatever/voxeo"
  end

  it "should send first say command" do
    incoming :offer_presence, @call_jid, @client_jid

    Connfu.connection.commands.last.should == Connfu::Commands::Say.new(:text => 'hello, this is connfu', :call_jid => @call_jid, :client_jid => @client_jid)
  end

  it "should not send the second say command if the first command's success hasn't been received" do
    incoming :offer_presence, @call_jid, @client_jid
    incoming :result_iq, @call_id

    Connfu.connection.commands.last.should == Connfu::Commands::Say.new(:text => 'hello, this is connfu', :call_jid => @call_jid, :client_jid => @client_jid)
  end

  it "should send the second say command once the first say command has completed" do
    incoming :offer_presence, @call_jid, @client_jid
    incoming :result_iq, @call_id
    incoming :say_complete_success, @call_id

    Connfu.connection.commands.last.should == Connfu::Commands::Say.new(:text => 'http://www.phono.com/audio/troporocks.mp3', :call_jid => @call_jid, :client_jid => @client_jid)
  end
end