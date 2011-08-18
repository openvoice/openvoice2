require 'spec_helper'

describe Jobs::OutgoingCall do

  before do
    setup_connfu(handler_class = nil)
  end
  
  describe "Initiating call between an openvoice endpoint and a recipient" do
    before do
      @call = Factory(:call,
        :endpoint => Factory(:endpoint, :address => "sip:caller@example.com",
          :account => Factory(:account, :username => "my-openvoice-username")
        ),
        :recipient_address => "sip:recipient@example.com"
      )
      Jobs::OutgoingCall.perform(@call.id)
    end
    
    it 'should issue a dial command' do
      last_command.class.should == Connfu::Commands::Dial
    end
    
    it 'should dial from the openvoice2 number' do
      last_command.from.should == "sip:my-openvoice-username@#{Connfu.config.host}"
    end
    
    it "should dial the openvoice user's endpoint address" do
      last_command.to.should == "sip:caller@example.com"
    end
    
    describe "when the openvoice endpoint is ringing" do
      before do
        incoming :outgoing_call_result_iq, "call-id", last_command.id
        incoming :outgoing_call_ringing_presence, "call-id"
      end
      
      it 'should set the Call state to caller ringing' do
        @call.reload.state.should eq :caller_ringing
      end
      
      describe "when the openvoice endpoint answers" do
        before do
          incoming :outgoing_call_answered_presence, "call-id"
        end

        it 'should issue a nested join command' do
          last_command.class.should == Connfu::Commands::NestedJoin
          last_command.call_jid.should == "call-id@#{PRISM_HOST}"
        end

        it 'should dial the recipient' do
          last_command.dial_to.should == "sip:recipient@example.com"
        end

        it 'should dial from the openvoice2 number' do
          last_command.dial_from.should == "sip:my-openvoice-username@#{Connfu.config.host}"
        end
        
        it 'should set the Call state to caller answered' do
          @call.reload.state.should eq :caller_answered
        end
        
        describe "when recipient is ringing" do
          before do
            incoming :outgoing_call_result_iq, "joined-call-id", last_command.id
            incoming :outgoing_call_ringing_presence, "joined-call-id"
          end
          
          it "should set the state to recipient ringing" do
            @call.reload.state.should eq :recipient_ringing
          end
          
          describe "when recipient answers" do
            before do
              incoming :outgoing_call_answered_presence, "joined-call-id"
            end

            it 'should not issue the nested join again' do
              Connfu.connection.commands.select{|c| c.class == Connfu::Commands::NestedJoin }.length.should == 1
            end

            it "should set the state to recipient answered" do
              @call.reload.state.should eq :recipient_answered
            end

            describe "and the recipient hangs up" do
              before do
                incoming :unjoined_presence, "call-id", "joined-call-id"
                incoming :unjoined_presence, "joined-call-id", "call-id"
                incoming :hangup_presence, "joined-call-id"
              end

              it "should hang up the openvoice endpoint" do
                last_command.class.should == Connfu::Commands::Hangup
                last_command.call_jid.should == 'call-id@127.0.0.1'
              end

              it "should set the state to call ended" do
                @call.reload.state.should eq :call_ended
              end
            end

            describe "and the openvoice endpoint hangs up" do
              before do
                incoming :unjoined_presence, "call-id", "joined-call-id"
                incoming :unjoined_presence, "joined-call-id", "call-id"
                incoming :hangup_presence, "call-id"
              end

              it "should hang up the recipient" do
                last_command.class.should == Connfu::Commands::Hangup
                last_command.call_jid.should == 'joined-call-id@openvoice.org'
              end

              it "should set the state to call ended" do
                @call.reload.state.should eq :call_ended
              end
            end
          end

          describe "when recipient rejects the call" do
            before do
              incoming :reject_presence, "joined-call-id"
            end

            it "should set the state to call rejected" do
              @call.reload.state.should eq :call_rejected
            end

            it "should hang up the openvoice user's endpoint" do
              last_command.class.should == Connfu::Commands::Hangup
              last_command.call_jid.should == 'call-id@openvoice.org'
            end

            describe "and hangup is confirmed" do
              before do
                incoming :result_iq, "call-id", last_command.id
                incoming :hangup_presence, "call-id"
              end

              it "should not try to hang up the recipient again" do
                last_command.call_jid.should_not == "joined-call-id@openvoice.org"
              end
            end
          end
        end
      end

      describe "when the openvoice endpoint rejects the call" do
        before :each do
          incoming :reject_presence, "call-id"
        end

        it "should not send any further hangup commands" do
          last_command.should_not be_instance_of(Connfu::Commands::Hangup)
        end

        it "should set the call state to rejected" do
          @call.reload.state.should eq :call_rejected
        end

        it "should mark the handler as finished" do
          Connfu.should be_finished
        end
      end

    end
  end
end
