require 'spec_helper'

describe Jobs::OutgoingCall do

  before do
    setup_connfu(handler_class = nil)
  end
  
  describe "Initiating call between two endpoints" do
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
    
    it 'should dial from the openvoice2 username' do
      last_command.from.should == "sip:my-openvoice-username@#{Connfu.config.host}"
    end
    
    it "should dial to the caller endpoint address" do
      last_command.to.should == "sip:caller@example.com"
    end
    
    describe "when caller is ringing" do
      before do
        incoming :outgoing_call_result_iq, "call-id", last_command.id
        incoming :outgoing_call_ringing_presence, "call-id"
      end
      
      it 'should set the Call state to caller ringing' do
        @call.reload.state.should eq :caller_ringing
      end
      
      describe "when caller answers" do
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

        it 'should dial from the openvoice2 username' do
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
          
          describe "when callee answers" do
            before do
              incoming :outgoing_call_answered_presence, "joined-call-id"
            end

            it 'should not issue the nested join again' do
              Connfu.connection.commands.select{|c| c.class == Connfu::Commands::NestedJoin }.length.should == 1
            end

            describe "and the callee hangs up" do
              before do
                incoming :unjoined_presence, "call-id", "joined-call-id"
                incoming :unjoined_presence, "joined-call-id", "call-id"
                incoming :hangup_presence, "joined-call-id"
              end

              it "should hang up the caller" do
                last_command.class.should == Connfu::Commands::Hangup
                last_command.call_jid.should == 'call-id@127.0.0.1'
              end
            end

            describe "and the caller hangs up" do
              before do
                incoming :unjoined_presence, "call-id", "joined-call-id"
                incoming :unjoined_presence, "joined-call-id", "call-id"
                incoming :hangup_presence, "call-id"
              end

              it "should hang up the callee" do
                last_command.class.should == Connfu::Commands::Hangup
                last_command.call_jid.should == 'joined-call-id@openvoice.org'
              end
            end


            it "should set the state to recipient answered" do
              @call.reload.state.should eq :recipient_answered
            end
            
            describe "when callee hangups" do
              before do
                incoming :hangup_presence, "call-id"
              end
              
              it "should set the state to call ended" do
                @call.reload.state.should eq :call_ended
              end
            end
          end
        end
      end
    end
  end
end
