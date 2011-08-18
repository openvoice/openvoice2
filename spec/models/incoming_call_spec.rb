require 'spec_helper'
require 'incoming_call'

describe IncomingCall do

  before do
    @domain = 'server.whatever'
    setup_connfu(IncomingCall, @domain)

    @call_id = "34209dfiasdoaf"
    @call_jid = "#{@call_id}@#{@domain}"
    @client_jid = "usera@127.0.0.whatever/voxeo"

    @account = Factory(:account, :username =>"known-user")
  end

  context 'when incoming call is for an uknown user' do
    before do
      incoming :offer_presence, @call_jid, @client_jid, :to => "<sip:unknown-user@example.com>"
    end

    it 'should not answer' do
      Connfu.connection.commands.none? { |c| c.instance_of?(Connfu::Commands::Answer) }.should be_true
    end
  end

  context 'when incoming call is for a known user' do
    before do
      incoming :offer_presence, @call_jid, @client_jid, :to => "<sip:known-user@example.com>"
    end

    it 'should answer' do
      last_command.should == Connfu::Commands::Answer.new(:call_jid => @call_jid, :client_jid => @client_jid)
    end

    it 'should then say "please wait while we transfer your call" to the caller' do
      incoming :result_iq, @call_id, last_command.id

      last_command.should == Connfu::Commands::Say.new(:text => "please wait while we transfer your call", :call_jid => @call_jid, :client_jid => @client_jid)
    end

    it 'should then play music to the caller' do
      incoming :result_iq, @call_id, last_command.id
      incoming :result_iq, @call_id, last_command.id
      incoming :say_complete_success, @call_id

      last_command.should == Connfu::Commands::Say.new(:text => "http://www.phono.com/audio/troporocks.mp3", :call_jid => @call_jid, :client_jid => @client_jid)
    end

    context 'with one endpoint' do
      before do
        @joined_call_id = "joined-call-id"

        @endpoint_one = Factory(:endpoint, :account => @account)
      end

      it 'should immediately ring the endpoint without waiting for the music to finish' do
        incoming :result_iq, @call_id, last_command.id
        incoming :result_iq, @call_id, last_command.id
        incoming :say_complete_success, @call_id
        incoming :result_iq, @call_id, last_command.id

        last_command.should == Connfu::Commands::NestedJoin.new(
          :dial_to => @endpoint_one.address,
          :call_jid => @call_jid,
          :client_jid => @client_jid,
          :dial_from => "sip:known-user@example.com",
          :call_id => @call_id
        )
      end

      it 'should wait for the leg to be answered' do
        incoming :result_iq, @call_id, last_command.id
        incoming :result_iq, @call_id, last_command.id
        incoming :say_complete_success, @call_id
        incoming :result_iq, @call_id, last_command.id
        incoming :outgoing_call_result_iq, @joined_call_id, last_command.id

        Connfu.should_not be_finished
      end

      it 'should wait for one of the parties to hang up' do
        incoming :result_iq, @call_id, last_command.id
        incoming :result_iq, @call_id, last_command.id
        incoming :say_complete_success, @call_id
        incoming :result_iq, @call_id, last_command.id
        incoming :outgoing_call_result_iq, @joined_call_id, last_command.id
        incoming :outgoing_call_answered_presence, @joined_call_id

        Connfu.should_not be_finished
      end

      it 'should hangup the caller when the openvoice endpoint hangs up' do
        incoming :result_iq, @call_id, last_command.id
        incoming :result_iq, @call_id, last_command.id
        incoming :say_complete_success, @call_id
        incoming :result_iq, @call_id, last_command.id
        incoming :outgoing_call_result_iq, @joined_call_id, last_command.id
        incoming :outgoing_call_answered_presence, @joined_call_id
        incoming :hangup_presence, @joined_call_id

        incoming :result_iq, @call_id, last_command.id # server responds to expected Hangup command for the caller
        incoming :hangup_presence, @call_id

        last_command.should == Connfu::Commands::Hangup.new(:call_jid => "#{@call_id}@#{@domain}", :client_jid => @client_jid)
        Connfu.should be_finished
      end

      it 'should hangup the openvoice endpoint when the caller hangs up' do
        incoming :result_iq, @call_id, last_command.id
        incoming :result_iq, @call_id, last_command.id
        incoming :say_complete_success, @call_id
        incoming :result_iq, @call_id, last_command.id
        incoming :outgoing_call_result_iq, @joined_call_id, last_command.id
        incoming :outgoing_call_answered_presence, @joined_call_id
        incoming :hangup_presence, @call_id
        
        incoming :result_iq, @joined_call_id, last_command.id # server responds to expected Hangup command for the openvoice user
        incoming :hangup_presence, @joined_call_id

        last_command.should == Connfu::Commands::Hangup.new(:call_jid => "#{@joined_call_id}@#{@domain}", :client_jid => @client_jid)
        Connfu.should be_finished
      end
    end

    context 'with two endpoints' do
      before do
        @joined_call_id = 'joined-call-id'
        @unanswered_joined_call_id = "unanswered-joined-call-id"
        @unanswered_joined_call_jid = "#{@unanswered_joined_call_id}@#{@domain}"

        @endpoint_one = Factory(:endpoint, :account => @account)
        @endpoint_two = Factory(:endpoint, :account => @account)
      end

      it 'should immediately ring both endpoints without waiting for the music to finish' do
        incoming :result_iq, @call_id, last_command.id
        incoming :result_iq, @call_id, last_command.id
        incoming :say_complete_success, @call_id
        incoming :result_iq, @call_id, last_command.id

        last_command.should == Connfu::Commands::NestedJoin.new(
          :dial_to => @endpoint_one.address,
          :call_jid => @call_jid,
          :client_jid => @client_jid,
          :dial_from => "sip:known-user@example.com",
          :call_id => @call_id
        )

        incoming :result_iq, @call_id, last_command.id

        last_command.should == Connfu::Commands::NestedJoin.new(
          :dial_to => @endpoint_two.address,
          :call_jid => @call_jid,
          :client_jid => @client_jid,
          :dial_from => "sip:known-user@example.com",
          :call_id => @call_id
        )
      end

      it 'should wait for one of the legs to be answered' do
        incoming :result_iq, @call_id, last_command.id
        incoming :result_iq, @call_id, last_command.id
        incoming :say_complete_success, @call_id
        incoming :result_iq, @call_id, last_command.id
        incoming :outgoing_call_result_iq, @joined_call_id, last_command.id
        incoming :outgoing_call_result_iq, @unanswered_joined_call_id, last_command.id

        last_command.should_not be_instance_of(Connfu::Commands::Hangup)
      end

      it 'should hang up the unanswered leg when the other leg is answered' do
        incoming :result_iq, @call_id, last_command.id
        incoming :result_iq, @call_id, last_command.id
        incoming :say_complete_success, @call_id
        incoming :result_iq, @call_id, last_command.id
        incoming :outgoing_call_result_iq, @joined_call_id, last_command.id
        incoming :outgoing_call_result_iq, @unanswered_joined_call_id, last_command.id
        incoming :outgoing_call_answered_presence, @joined_call_id

        last_command.should == Connfu::Commands::Hangup.new(:call_jid => @unanswered_joined_call_jid, :client_jid => @client_jid)
      end

      it 'should wait for one of the parties to hang up' do
        incoming :result_iq, @call_id, last_command.id
        incoming :result_iq, @call_id, last_command.id
        incoming :say_complete_success, @call_id
        incoming :result_iq, @call_id, last_command.id
        incoming :outgoing_call_result_iq, @joined_call_id, last_command.id
        incoming :outgoing_call_result_iq, @unanswered_joined_call_id, last_command.id
        incoming :outgoing_call_answered_presence, @joined_call_id
        incoming :result_iq, @unanswered_joined_call_id, last_command.id
        incoming :hangup_presence, @unanswered_joined_call_id

        Connfu.should_not be_finished
      end

      it 'should hangup the caller when the openvoice endpoint hangs up' do
        incoming :result_iq, @call_id, last_command.id
        incoming :result_iq, @call_id, last_command.id
        incoming :say_complete_success, @call_id
        incoming :result_iq, @call_id, last_command.id

        incoming :outgoing_call_result_iq, @joined_call_id, last_command.id
        incoming :outgoing_call_result_iq, @unanswered_joined_call_id, last_command.id

        incoming :outgoing_call_answered_presence, @joined_call_id
        incoming :result_iq, @unanswered_joined_call_id, last_command.id
        incoming :hangup_presence, @unanswered_joined_call_id

        incoming :hangup_presence, @joined_call_id

        last_command.should == Connfu::Commands::Hangup.new(:call_jid => "#{@call_id}@#{@domain}", :client_jid => @client_jid)
      end

      it 'should hangup the openvoice endpoint when the caller hangs up' do
        incoming :result_iq, @call_id, last_command.id
        incoming :result_iq, @call_id, last_command.id
        incoming :say_complete_success, @call_id
        incoming :result_iq, @call_id, last_command.id

        incoming :outgoing_call_result_iq, @joined_call_id, last_command.id
        incoming :outgoing_call_result_iq, @unanswered_joined_call_id, last_command.id

        incoming :outgoing_call_answered_presence, @joined_call_id
        incoming :result_iq, @unanswered_joined_call_id, last_command.id
        incoming :hangup_presence, @unanswered_joined_call_id

        incoming :hangup_presence, @call_id

        last_command.should == Connfu::Commands::Hangup.new(:call_jid => "#{@joined_call_id}@#{@domain}", :client_jid => @client_jid)
      end
    end
  end
end