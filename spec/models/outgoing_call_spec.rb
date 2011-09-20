require 'spec_helper'

describe Jobs::OutgoingCall do

  before do
    setup_connfu(handler_class = nil)
  end

  describe "Initiating call between an openvoice endpoint and a recipient" do
    before do
      @domain = "openvoice.org"
      @call = Factory(:call,
        :endpoint => Factory(:endpoint, :address => "sip:caller@example.com",
          :account => Factory(:account, :username => "my-openvoice-username")
        ),
        :party_address => "sip:recipient@example.com"
      )
      Jobs::OutgoingCall.perform(@call.id)
    end

    it 'should issue a dial command' do
      last_command.class.should == Connfu::Commands::Dial
    end

    it 'should dial from the openvoice2 address' do
      last_command.from.should == "sip:my-openvoice-username@#{Connfu.config.host}"
    end

    it "should dial the openvoice user's endpoint address" do
      last_command.to.should == "sip:caller@example.com"
    end

    describe "when the openvoice endpoint is ringing" do
      before do
        @call_id = "call-id"
        @call_jid = "call-id@#{@domain}"
        incoming :dial_result_iq, "call-id", last_command.id
        incoming :ringing_presence, @call_jid
      end

      it 'should set the Call state to caller ringing' do
        @call.reload.state.should eq Call::CALLER_RINGING
      end

      describe "when the openvoice endpoint answers" do
        before do
          incoming :answered_presence, @call_jid
        end

        it 'should issue a nested join command' do
          last_command.class.should == Connfu::Commands::NestedJoin
          last_command.call_jid.should == @call_jid
        end

        it 'should dial the recipient' do
          last_command.dial_to.should == "sip:recipient@example.com"
        end

        it 'should dial from the openvoice2 address' do
          last_command.dial_from.should == "sip:my-openvoice-username@#{Connfu.config.host}"
        end

        it 'should set the Call state to caller answered' do
          @call.reload.state.should eq Call::CALLER_ANSWERED
        end

        describe "when recipient is ringing" do
          before do
            @joined_call_jid = "joined-call-id@#{@domain}"
            @joined_call_id = "joined-call-id"
            incoming :dial_result_iq, @joined_call_id, last_command.id
            incoming :ringing_presence, @joined_call_jid
          end

          it "should set the state to recipient ringing" do
            @call.reload.state.should eq Call::RECIPIENT_RINGING
          end

          describe "when recipient answers" do
            before do
              incoming :answered_presence, @joined_call_jid
            end

            it 'should not issue the nested join again' do
              Connfu.connection.commands.select{|c| c.class == Connfu::Commands::NestedJoin }.length.should == 1
            end

            it "should set the state to recipient answered" do
              @call.reload.state.should eq Call::RECIPIENT_ANSWERED
            end

            describe "and the recipient hangs up" do
              before do
                incoming :unjoined_presence, @call_jid, @joined_call_id
                incoming :unjoined_presence, @joined_call_jid, @call_id
                incoming :hangup_presence, @joined_call_jid
              end

              it "should hang up the openvoice endpoint" do
                last_command.class.should == Connfu::Commands::Hangup
                last_command.call_jid.should == @call_jid
              end

              it "should set the state to call ended" do
                @call.reload.state.should eq Call::ENDED
              end
            end

            describe "and the openvoice endpoint hangs up" do
              before do
                incoming :unjoined_presence, @call_jid, @joined_call_id
                incoming :unjoined_presence, @joined_call_jid, @call_id
                incoming :hangup_presence, @call_jid
              end

              it "should hang up the recipient" do
                last_command.class.should == Connfu::Commands::Hangup
                last_command.call_jid.should == @joined_call_jid
              end

              it "should set the state to call ended" do
                @call.reload.state.should eq Call::ENDED
              end
            end
          end

          describe "when recipient rejects the call" do
            before do
              incoming :reject_presence, @joined_call_jid
            end

            it "should set the state to call rejected" do
              @call.reload.state.should eq Call::REJECTED
            end

            it "should hang up the openvoice user's endpoint" do
              last_command.class.should == Connfu::Commands::Hangup
              last_command.call_jid.should == @call_jid
            end

            describe "and hangup is confirmed" do
              before do
                incoming :result_iq, @call_jid, last_command.id
                incoming :hangup_presence, @call_jid
              end

              it "should not try to hang up the recipient again" do
                last_command.call_jid.should_not == @joined_call_jid
              end
            end
          end

          describe "when recipient times out" do
            before do
              incoming :timeout_presence, @joined_call_jid
            end

            it "should set the state to call timeout" do
              @call.reload.state.should eq :timeout
            end

            it "should hang up the openvoice user's endpoint" do
              last_command.class.should == Connfu::Commands::Hangup
              last_command.call_jid.should == @call_jid
            end

            describe "and when the hangup is confirmed" do
              before do
                incoming :result_iq, @call_jid, last_command.id
                incoming :hangup_presence, @call_jid
              end

              it "should not try to hang up the recipient again" do
                last_command.call_jid.should_not == @joined_call_jid
              end
            end
          end

          describe "when recipient is busy" do
            before do
              incoming :busy_presence, @joined_call_jid
            end

            it "shold set the state to call recipient busy" do
              @call.reload.state.should eq Call::RECIPIENT_BUSY
            end

            it "should hang up the openvoice user's endpoint" do
              last_command.class.should == Connfu::Commands::Hangup
              last_command.call_jid.should == @call_jid
            end

            describe "and when the hangup is confirmed" do
              before do
                incoming :result_iq, @call_jid, last_command.id
                incoming :hangup_presence, @call_jid
              end

              it "should not try to hang up the recipient again" do
                last_command.call_jid.should_not == @joined_call_jid
              end
            end
          end
        end
      end

      describe "when the openvoice endpoint rejects the call" do
        before :each do
          incoming :reject_presence, @call_jid
        end

        it "should not send any further hangup commands" do
          last_command.should_not be_instance_of(Connfu::Commands::Hangup)
        end

        it "should set the call state to rejected" do
          @call.reload.state.should eq Call::REJECTED
        end

        it "should mark the handler as finished" do
          Connfu.should be_finished
        end
      end
    end
  end
end
