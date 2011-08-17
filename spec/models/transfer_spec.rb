require "spec_helper"
require 'transfer'

describe "transfer" do

  before :each do
    domain = 'server.whatever'
    setup_connfu(Transfer, domain)

    @call_id = "34209dfiasdoaf"
    @joined_call_id = "joined-call-id"
    @unanswered_joined_call_id = "unanswered-joined-call-id"

    @call_jid = "#{@call_id}@#{domain}"
    @client_jid = "usera@127.0.0.whatever/voxeo"
    @unanswered_joined_call_jid = "#{@unanswered_joined_call_id}@#{domain}"

    @account = Factory(:account, :username =>"known-user")
    @endpoint_one = Factory(:endpoint, :account => @account)
    @endpoint_two = Factory(:endpoint, :account => @account)
  end

  it 'should not answer if incoming call is for an unknown user' do
    incoming :offer_presence, @call_jid, @client_jid, :to => "<sip:unknown-user@example.com>"

    Connfu.connection.commands.none? { |c| c.instance_of?(Connfu::Commands::Answer) }.should be_true
  end

  context 'when incoming call is for a known user' do
    before do
      incoming :offer_presence, @call_jid, @client_jid, :to => "<sip:known-user@example.com>"
    end

    it 'should answer' do
      Connfu.connection.commands.last.should == Connfu::Commands::Answer.new(:call_jid => @call_jid, :client_jid => @client_jid)
    end

    it 'should then say "please wait while we transfer your call" to the caller' do
      incoming :result_iq, @call_id, Connfu.connection.commands.last.id

      Connfu.connection.commands.last.should == Connfu::Commands::Say.new(:text => "please wait while we transfer your call", :call_jid => @call_jid, :client_jid => @client_jid)
    end

    it 'should then play music to the caller' do
      incoming :result_iq, @call_id, Connfu.connection.commands.last.id
      incoming :result_iq, @call_id, Connfu.connection.commands.last.id
      incoming :say_complete_success, @call_id

      Connfu.connection.commands.last.should == Connfu::Commands::Say.new(:text => "http://www.phono.com/audio/troporocks.mp3", :call_jid => @call_jid, :client_jid => @client_jid)
    end

    it 'should immediately ring both endpoints without waiting for the music to finish' do
      incoming :result_iq, @call_id, Connfu.connection.commands.last.id
      incoming :result_iq, @call_id, Connfu.connection.commands.last.id
      incoming :say_complete_success, @call_id
      incoming :result_iq, @call_id, Connfu.connection.commands.last.id

      Connfu.connection.commands.last.should == Connfu::Commands::NestedJoin.new(
        :dial_to => @endpoint_one.address,
        :call_jid => @call_jid,
        :client_jid => @client_jid,
        :dial_from => "sip:known-user@example.com",
        :call_id => @call_id
      )

      incoming :result_iq, @call_id, Connfu.connection.commands.last.id

      Connfu.connection.commands.last.should == Connfu::Commands::NestedJoin.new(
        :dial_to => @endpoint_two.address,
        :call_jid => @call_jid,
        :client_jid => @client_jid,
        :dial_from => "sip:known-user@example.com",
        :call_id => @call_id
      )
    end

    it 'should wait for one of the legs to be answered' do
      incoming :result_iq, @call_id, Connfu.connection.commands.last.id
      incoming :result_iq, @call_id, Connfu.connection.commands.last.id
      incoming :say_complete_success, @call_id
      incoming :result_iq, @call_id, Connfu.connection.commands.last.id
      incoming :result_iq, @call_id, Connfu.connection.commands.last.id
      incoming :outgoing_call_result_iq, @joined_call_id, Connfu.connection.commands.last.id
      incoming :outgoing_call_result_iq, @unanswered_joined_call_id, Connfu.connection.commands.last.id

      Connfu.connection.commands.last.should_not be_instance_of(Connfu::Commands::Hangup)
    end

    it 'should hang up the unanswered leg when the other leg is answered' do
      incoming :result_iq, @call_id, Connfu.connection.commands.last.id
      incoming :result_iq, @call_id, Connfu.connection.commands.last.id
      incoming :say_complete_success, @call_id
      incoming :result_iq, @call_id, Connfu.connection.commands.last.id
      incoming :outgoing_call_result_iq, @joined_call_id, Connfu.connection.commands.last.id
      incoming :outgoing_call_result_iq, @unanswered_joined_call_id, Connfu.connection.commands.last.id
      incoming :outgoing_call_answered_presence, @joined_call_id

      Connfu.connection.commands.last.should == Connfu::Commands::Hangup.new(:call_jid => @unanswered_joined_call_jid, :client_jid => @client_jid)
    end

    it 'should wait for one of the parties to hang up' do
      incoming :result_iq, @call_id, Connfu.connection.commands.last.id
      incoming :result_iq, @call_id, Connfu.connection.commands.last.id
      incoming :say_complete_success, @call_id
      incoming :result_iq, @call_id, Connfu.connection.commands.last.id
      incoming :outgoing_call_result_iq, @joined_call_id, Connfu.connection.commands.last.id
      incoming :outgoing_call_result_iq, @unanswered_joined_call_id, Connfu.connection.commands.last.id
      incoming :outgoing_call_answered_presence, @joined_call_id
      incoming :result_iq, @unanswered_joined_call_id, Connfu.connection.commands.last.id
      incoming :hangup_presence, @unanswered_joined_call_id

      Connfu.event_processor.handlers.all?(&:finished?).should be_false
    end

    it 'should finish when one of the parties hangs up' do
      incoming :result_iq, @call_id, Connfu.connection.commands.last.id
      incoming :result_iq, @call_id, Connfu.connection.commands.last.id
      incoming :say_complete_success, @call_id
      incoming :result_iq, @call_id, Connfu.connection.commands.last.id
      incoming :outgoing_call_result_iq, @joined_call_id, Connfu.connection.commands.last.id
      incoming :outgoing_call_result_iq, @unanswered_joined_call_id, Connfu.connection.commands.last.id
      incoming :outgoing_call_answered_presence, @joined_call_id
      incoming :result_iq, @unanswered_joined_call_id, Connfu.connection.commands.last.id
      incoming :hangup_presence, @unanswered_joined_call_id
      incoming :hangup_presence, @call_id

      Connfu.event_processor.handlers.all?(&:finished?).should be_true
    end
  end

end