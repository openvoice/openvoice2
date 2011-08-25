require "spec_helper"

describe "say something on a call" do

  testing_dsl do
    on :offer do |call|
      say('hello, this is connfu')
      say('http://www.phono.com/audio/troporocks.mp3')
    end
  end

  before :each do
    @call_id = "call-id"
    @call_jid = "#{@call_id}@server.whatever"
    @client_jid = "usera@127.0.0.whatever/voxeo"
  end

  it "should send first say command" do
    incoming :offer_presence, @call_jid, @client_jid

    last_command.should == Connfu::Commands::Say.new(:text => 'hello, this is connfu', :call_jid => @call_jid, :client_jid => @client_jid)
  end

  it "should not send the second say command if the first command's success hasn't been received" do
    incoming :offer_presence, @call_jid, @client_jid
    incoming :say_result_iq, @call_jid

    last_command.should == Connfu::Commands::Say.new(:text => 'hello, this is connfu', :call_jid => @call_jid, :client_jid => @client_jid)
  end

  it "should send the second say command once the first say command has completed" do
    incoming :offer_presence, @call_jid, @client_jid
    incoming :say_result_iq, @call_jid
    incoming :say_success_presence, @call_jid

    last_command.should == Connfu::Commands::Say.new(:text => 'http://www.phono.com/audio/troporocks.mp3', :call_jid => @call_jid, :client_jid => @client_jid)
  end
end

describe "stopping a say command" do
  testing_dsl do
    on :offer do |call|
      answer
      send_command Connfu::Commands::Say.new(:text => 'hello world', :call_jid => 'call-jid', :client_jid => 'client-jid')
      dial :to => "anyone", :from => "anyone else"
      send_command Connfu::Commands::Stop.new(:ref_id => 'component-id', :call_jid => 'call-jid', :client_jid => 'client-jid')
    end
  end

  let(:stop_command) { Connfu::Commands::Stop.new(:ref_id => 'component-id', :call_jid => 'call-jid', :client_jid => 'client-jid') }
  let(:call_jid) { "call-id@#{PRISM_HOST}" }

  it 'should send the stop command to an active say component' do
    incoming :offer_presence, call_jid
    incoming :result_iq, call_jid, last_command.id
    incoming :say_result_iq, call_jid
    incoming :dial_result_iq, "dummy-call-so-we-can-wait-id", last_command.id

    last_command.should == stop_command
  end

  it 'should not send the stop command if the say component has already finished' do
    incoming :offer_presence, call_jid
    incoming :result_iq, call_jid, last_command.id
    incoming :say_result_iq, call_jid, 'component-id'
    incoming :say_success_presence, "#{call_jid}/component-id"
    incoming :dial_result_iq, "dummy-call-so-we-can-wait-id", last_command.id

    last_command.should_not == stop_command
  end
end