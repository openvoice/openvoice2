require 'spec_helper'
require 'incoming_call'

shared_examples "recording a voicemail" do
  it 'should stop playing the hold music' do
    last_command.should == Connfu::Commands::Stop.new(
      :call_jid => @call_jid,
      :client_jid => @client_jid,
      :component_id => "hold-music-component-id"
    )
  end

  it 'should ask the caller to leave a message' do
    incoming :result_iq, @call_jid # stop music

    last_command.should == Connfu::Commands::Say.new(
      :call_jid => @call_jid,
      :client_jid => @client_jid,
      :text => "Please leave a message"
    )
  end

  it 'should start recording a message' do
    incoming :result_iq, @call_jid # stop music
    incoming :result_iq, @call_jid, last_command.id # say 'please leave a message'
    incoming :say_success_presence, @call_jid

    last_command.should == Connfu::Commands::Recording::Start.new(
      :call_jid => @call_jid,
      :client_jid => @client_jid,
      :max_length => 60_000, # milliseconds
      :beep => true
    )
  end

  context 'when taking the message' do
    before do
      incoming :result_iq, @call_jid # stop music
      incoming :result_iq, @call_jid, last_command.id # say 'please leave a message'
      incoming :say_success_presence, @call_jid
      incoming :result_iq, @call_jid, last_command.id # recording started
    end

    it 'should not play a message if the caller hangs up during the recording' do
      incoming :recording_hangup_presence, @call_jid
      incoming :hangup_presence, @call_jid

      last_command.should_not be_instance_of(Connfu::Commands::Say)
    end

    it 'should play a message at the end of the message recording' do
      incoming :recording_stop_presence, @call_jid # recording finished

      last_command.should == Connfu::Commands::Say.new(
        :call_jid => @call_jid,
        :client_jid => @client_jid,
        :text => "Message complete"
      )
    end

    it 'should hangup the caller when the message is complete' do
      incoming :recording_stop_presence, @call_jid # recording finished
      incoming :result_iq, @call_jid # 'message complete' say
      incoming :say_success_presence, @call_jid

      last_command.should == Connfu::Commands::Hangup.new(
        :call_jid => @call_jid,
        :client_jid => @client_jid
      )
    end
  end
end

describe IncomingCall do

  before do
    @domain = 'server.whatever'
    setup_connfu(IncomingCall, @domain)
    EM.stubs(:add_timer)

    @call_id = "34209dfiasdoaf"
    @call_jid = "#{@call_id}@#{@domain}"
    @client_jid = Connfu.connection.jid

    @account = Factory(:account, :username =>"known-user")
  end

  context 'when incoming call is for an unknown user' do
    before do
      incoming :offer_presence, @call_jid, @client_jid, :to => "<sip:unknown-user@example.com>"
    end

    it 'should not answer' do
      Connfu.connection.commands.none? { |c| c.instance_of?(Connfu::Commands::Answer) }.should be_true
    end
  end

  context 'when incoming call is for a known openvoice number' do
    before do
      @openvoice_number = Factory(:phone_number)
      @account.update_attribute(:number, @openvoice_number)
    end

    it 'should answer' do
      incoming :offer_presence, @call_jid, @client_jid, :to => "<sip:#{@openvoice_number}@example.com>"
      last_command.should == Connfu::Commands::Answer.new(:call_jid => @call_jid, :client_jid => @client_jid)
    end

  end

  context 'when incoming call is for a known openvoice address' do
    it 'should answer' do
      incoming :offer_presence, @call_jid, @client_jid, :to => "<sip:known-user@example.com>", :from => "tel:+44790012345"
      last_command.should == Connfu::Commands::Answer.new(:call_jid => @call_jid, :client_jid => @client_jid)
    end

    it 'should log the incoming call' do
      incoming :offer_presence, @call_jid, @client_jid, :to => "<sip:known-user@example.com>", :from => "tel:+44790012345"
      logged_call = @account.calls.last
      logged_call.incoming.should be_true
      logged_call.party_address.should eql("tel:+44790012345")
    end

    context 'when openvoice user has not recorded a greeting' do
      before do
        incoming :offer_presence, @call_jid, @client_jid, :to => "<sip:known-user@example.com>", :from => "tel:+44790012345"
        incoming :result_iq, @call_jid, last_command.id
      end

      it 'should then say "please wait while we transfer your call" to the caller' do
        last_command.should == Connfu::Commands::Say.new(:text => "please wait while we transfer your call", :call_jid => @call_jid, :client_jid => @client_jid)
      end
    end

    it 'should then play music to the caller' do
      incoming :offer_presence, @call_jid, @client_jid, :to => "<sip:known-user@example.com>", :from => "tel:+44790012345"
      incoming :result_iq, @call_jid, last_command.id
      incoming :result_iq, @call_jid, last_command.id
      incoming :say_success_presence, @call_jid

      last_command.should == Connfu::Commands::Say.new(:text => "http://www.phono.com/audio/troporocks.mp3", :call_jid => @call_jid, :client_jid => @client_jid)
    end

    context 'with one endpoint' do
      before do
        @joined_call_id = "joined-call-id"
        @joined_call_jid = "joined-call-id@#{@domain}"

        @endpoint_one = Factory(:endpoint, :account => @account)

        incoming :offer_presence, @call_jid, @client_jid, :to => "<sip:known-user@example.com>"
        incoming :result_iq, @call_jid, last_command.id
        incoming :result_iq, @call_jid, last_command.id
        incoming :say_success_presence, @call_jid
        incoming :result_iq, @call_jid, last_command.id
      end

      it 'should immediately ring the endpoint without waiting for the music to finish' do
        last_command.should == Connfu::Commands::NestedJoin.new(
            :dial_to => @endpoint_one.address,
            :call_jid => @call_jid,
            :client_jid => @client_jid,
            :dial_from => "sip:known-user@example.com",
            :call_id => @call_id
        )
      end

      describe "once the dial has happened" do
        before do
          incoming :dial_result_iq, @joined_call_id, last_command.id
        end

        it 'should wait for the leg to be answered' do
          Connfu.should_not be_finished
        end

        it 'should hangup the caller if the openvoice endpoint rejects the call' do
          incoming :reject_presence, @joined_call_jid

          last_command.should == Connfu::Commands::Hangup.new(:call_jid => "#{@call_id}@#{@domain}", :client_jid => @client_jid)
        end

        it 'should wait for one of the parties to hang up' do
          incoming :ringing_presence, @joined_call_jid

          Connfu.should_not be_finished
        end

        describe "and the call openvoice endpoint has answered" do
          before do
            incoming :answered_presence, @joined_call_jid # openvoice endpoint answers
          end

          it 'should log the call as answered by the endpoint' do
            logged_call = @account.calls.last
            logged_call.endpoint.should eql(@endpoint_one)
            logged_call.state.should eql(Call::ANSWERED)
          end

          it 'should hangup the caller when the openvoice endpoint hangs up' do
            incoming :hangup_presence, @joined_call_jid # openvoice endpoint hangs up
            incoming :result_iq, @call_jid, last_command.id # server responds to expected Hangup command for the caller
            incoming :hangup_presence, @call_jid # caller hangs up

            last_command.should == Connfu::Commands::Hangup.new(:call_jid => @call_jid, :client_jid => @client_jid)
            Connfu.should be_finished
          end

          it 'should hangup the openvoice endpoint when the caller hangs up' do
            incoming :hangup_presence, @call_jid
            incoming :result_iq, @joined_call_jid, last_command.id # server responds to expected Hangup command for the openvoice user
            incoming :hangup_presence, @joined_call_jid

            last_command.should == Connfu::Commands::Hangup.new(:call_jid => @joined_call_jid, :client_jid => @client_jid)
            Connfu.should be_finished
          end
        end
      end
    end

    context 'with two endpoints' do
      before do
        @joined_call_id = 'joined-call-id'
        @joined_call_jid = "joined-call-id@#{@domain}"

        @unanswered_joined_call_id = "unanswered-joined-call-id"
        @unanswered_joined_call_jid = "#{@unanswered_joined_call_id}@#{@domain}"

        @endpoint_one = Factory(:endpoint, :account => @account, :address => "sip:endpoint-one@server.whatever")
        @endpoint_two = Factory(:endpoint, :account => @account, :address => "sip:endpoint-two@server.whatever")
      end

      context 'and using the parallel dial strategy' do
        before do
          @account.update_attribute(:parallel_dial, true)

          incoming :offer_presence, @call_jid, @client_jid, :to => "<sip:known-user@example.com>"
          incoming :result_iq, @call_jid, last_command.id # answer
          incoming :result_iq, @call_jid, last_command.id # say 'please wait...'
          incoming :say_success_presence, @call_jid       # end of say 'please wait...'
          incoming :result_iq, @call_jid, last_command.id # play music
        end

        it 'should immediately ring both endpoints without waiting for the music to finish' do
          last_command.should == Connfu::Commands::NestedJoin.new(
              :dial_to => @endpoint_one.address,
              :call_jid => @call_jid,
              :client_jid => @client_jid,
              :dial_from => "sip:known-user@example.com",
              :call_id => @call_id
          )

          incoming :result_iq, @call_jid, last_command.id # nested join

          last_command.should == Connfu::Commands::NestedJoin.new(
              :dial_to => @endpoint_two.address,
              :call_jid => @call_jid,
              :client_jid => @client_jid,
              :dial_from => "sip:known-user@example.com",
              :call_id => @call_id
          )
        end

        context 'having dialed both endpoints' do
          before do
            incoming :dial_result_iq, @joined_call_id, last_command.id
            incoming :dial_result_iq, @unanswered_joined_call_id, last_command.id
          end

          it 'should wait for one of the legs to be answered' do
            last_command.should_not be_instance_of(Connfu::Commands::Hangup)
          end

          it 'should hang up the unanswered leg when the other leg is answered' do
            incoming :answered_presence, @joined_call_jid

            last_command.should == Connfu::Commands::Hangup.new(:call_jid => @unanswered_joined_call_jid, :client_jid => @client_jid)
          end

          it 'should wait for one of the parties to hang up' do
            incoming :answered_presence, @joined_call_jid
            incoming :result_iq, @unanswered_joined_call_jid, last_command.id
            incoming :hangup_presence, @unanswered_joined_call_jid

            Connfu.should_not be_finished
          end

          it 'should hangup the caller when both openvoice endpoints reject the call' do
            incoming :reject_presence, @joined_call_jid
            incoming :reject_presence, @unanswered_joined_call_jid

            incoming :result_iq, @call_jid
            incoming :hangup_presence, @call_jid

            last_command.should == Connfu::Commands::Hangup.new(:call_jid => @call_jid, :client_jid => @client_jid)
            Connfu.should be_finished
          end

          it 'should allow one to reject and another openvoice number to answer' do
            incoming :reject_presence, @joined_call_jid

            incoming :answered_presence, @unanswered_joined_call_jid
            incoming :result_iq, @unanswered_joined_call_jid, last_command.id

            last_command.should_not be_instance_of(Connfu::Commands::Hangup)
            Connfu.should_not be_finished
          end

          it 'should hangup the caller when the openvoice endpoint hangs up' do
            incoming :answered_presence, @joined_call_jid
            incoming :result_iq, @unanswered_joined_call_jid, last_command.id
            incoming :hangup_presence, @unanswered_joined_call_jid

            incoming :hangup_presence, @joined_call_jid

            last_command.should == Connfu::Commands::Hangup.new(:call_jid => @call_jid, :client_jid => @client_jid)
          end

          it 'should hangup the openvoice endpoint when the caller hangs up' do
            incoming :answered_presence, @joined_call_jid
            incoming :result_iq, @unanswered_joined_call_jid, last_command.id
            incoming :hangup_presence, @unanswered_joined_call_jid

            incoming :hangup_presence, @call_jid

            last_command.should == Connfu::Commands::Hangup.new(:call_jid => @joined_call_jid, :client_jid => @client_jid)
          end
        end
      end

      context 'and using the round-robin dial strategy' do
        before do
          @account.update_attribute(:parallel_dial, false)

          incoming :offer_presence, @call_jid, @client_jid, :to => "<sip:known-user@example.com>"
          incoming :result_iq, @call_jid, last_command.id # answer
          incoming :result_iq, @call_jid, last_command.id # say 'please wait...'
          incoming :say_success_presence, @call_jid       # end of say 'please wait...'
          incoming :say_result_iq, @call_jid, "hold-music-component-id" # play music
        end

        it 'should dial the first endpoint' do
          last_command.should == Connfu::Commands::Dial.new(
              :to => @endpoint_one.address,
              :from => "sip:known-user@example.com",
              :client_jid => @client_jid,
              :rayo_host => Connfu.connection.jid.domain
          )
        end

        it 'should not immediately dial the second endpoint' do
          incoming :dial_result_iq, "endpoint-one-call-id", last_command.id # first dial

          last_command.should be_instance_of(Connfu::Commands::Dial)
          last_command.to.should_not == @endpoint_two.address
        end

        context 'and the first endpoint answers' do
          before do
            incoming :dial_result_iq, "endpoint-one-call-id", last_command.id # first dial
            incoming :answered_presence, "endpoint-one-call-id@server.whatever"
          end

          it 'should not dial the second endpoint' do
            last_command.should_not be_instance_of(Connfu::Commands::Dial)
          end

          it 'should log the call as answered by the endpoint' do
            logged_call = @account.calls.last
            logged_call.endpoint.should eql(@endpoint_one)
            logged_call.state.should eql(Call::ANSWERED)
          end
        end

        context 'and the first endpoint does not answer' do
          before do
            incoming :dial_result_iq, "endpoint-one-call-id", last_command.id # first dial
            timeout @call_id
          end

          it 'should hangup the call to the first endpoint' do
            last_command.should == Connfu::Commands::Hangup.new(
              :client_jid => @client_jid,
              :call_jid => "endpoint-one-call-id@server.whatever"
            )
          end

          it 'should dial the second endpoint' do
            incoming :result_iq, "endpoint-one-call-id@server.whatever", last_command.id # hangup of first call
            incoming :hangup_presence, "endpoint-one-call-id@server.whatever" # hangup complete

            last_command.should == Connfu::Commands::Dial.new(
                :to => @endpoint_two.address,
                :from => "sip:known-user@example.com",
                :client_jid => @client_jid,
                :rayo_host => "server.whatever"
            )
          end

          context 'and the second endpoint does not answer either' do
            before do
              incoming :result_iq, "endpoint-one-call-id@server.whatever", last_command.id # hangup of first call
              incoming :hangup_presence, "endpoint-one-call-id@server.whatever" # hangup complete
              incoming :dial_result_iq, "endpoint-two-call-id", last_command.id # second dial
              timeout @call_id
            end

            it 'should hangup the call to the second endpoint' do
              last_command.should == Connfu::Commands::Hangup.new(
                :client_jid => @client_jid,
                :call_jid => "endpoint-two-call-id@server.whatever"
              )
            end

            context 'and after hanging up the second call' do
              before do
                incoming :result_iq, "endpoint-two-call-id@server.whatever" # hangup
                incoming :hangup_presence, "endpoint-two-call-id@server.whatever"
              end

              it_behaves_like 'recording a voicemail'
            end
          end
        end

        context 'and the first endpoint rejects' do
          before do
            incoming :dial_result_iq, "endpoint-one-call-id", last_command.id # first dial
            incoming :reject_presence, "endpoint-one-call-id@#{Connfu.connection.jid.domain}"
          end

          it_behaves_like 'recording a voicemail'
        end

        context 'once an endpoint answers' do
          before do
            incoming :dial_result_iq, "answering-endpoint-call-id", last_command.id # whichever dial
            incoming :answered_presence, "answering-endpoint-call-id@server.whatever"
            incoming :result_iq, @call_id, last_command.id # join
          end

          it 'should join the incoming call to the answered leg' do
            last_command.should == Connfu::Commands::Join.new(
              :call_jid => @call_jid,
              :client_jid => @client_jid,
              :call_id => "answering-endpoint-call-id"
            )
          end

          context 'and the call is joined' do
            before do
              incoming :joined_presence, @call_jid, "answering-endpoint-call-id" # join complete to original call
              incoming :joined_presence, "answering-endpoint-call-id@server.whatever", @call_id # join complete to new call
            end

            it 'should not hang up the call' do
              last_command.should_not be_instance_of(Connfu::Commands::Hangup)
            end

            it 'should hangup the openvoice leg when the incoming caller hangs up' do
              incoming :hangup_presence, @call_jid # hangup from incoming leg

              last_command.should == Connfu::Commands::Hangup.new(
                :call_jid => "answering-endpoint-call-id@server.whatever",
                :client_jid => @client_jid
              )
            end

            it 'should hangup the incoming leg when the answered endpoint hangs up' do
              incoming :hangup_presence, "answering-endpoint-call-id@server.whatever" # hangup from answering endpoint

              last_command.should == Connfu::Commands::Hangup.new(
                :call_jid => @call_jid,
                :client_jid => @client_jid
              )
            end
          end
        end
      end
    end
  end

  context 'when incoming call is for a known openvoice user with a recorded greeting' do
    before do
      @account.update_attribute(:greeting_path, "path-to-greeting")
      incoming :offer_presence, @call_jid, @client_jid, :to => "<sip:known-user@example.com>"
    end

    it 'should then play recording greeting to the caller' do
      incoming :result_iq, @call_jid, last_command.id

      last_command.should == Connfu::Commands::Say.new(:text => @account.greeting_path, :call_jid => @call_jid, :client_jid => @client_jid)
    end
  end
end