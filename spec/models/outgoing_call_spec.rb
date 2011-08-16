require 'spec_helper'

describe Jobs::OutgoingCall do

  before do
    setup_connfu(handler_class = nil)
  end
  
  describe "Initiating call between two endpoints" do
    before do
      Jobs::OutgoingCall.perform("caller", "recipient", "openvoice-number")
    end
    
    it 'should issue a dial command' do
      Connfu.connection.commands.last.class.should == Connfu::Commands::Dial
    end
    
    it 'should dial from the openvoice2 username' do
      Connfu.connection.commands.last.from.should == "openvoice-number"
    end
    
    describe "when caller answers" do
      before do
        incoming :outgoing_call_result_iq, "call-id", Connfu.connection.commands.last.id
        incoming :outgoing_call_ringing_presence, "call-id"
        incoming :outgoing_call_answered_presence, "call-id"
      end
      
      it 'should issue a nested join command' do
        Connfu.connection.commands.last.class.should == Connfu::Commands::NestedJoin
        Connfu.connection.commands.last.call_jid.should == "call-id@#{PRISM_HOST}"
      end
      
      it 'should dial the recipient' do
        Connfu.connection.commands.last.dial_to.should == 'recipient'
      end
      
      it 'should dial from the openvoice2 username' do
        Connfu.connection.commands.last.dial_from.should == 'openvoice-number'
      end
      
      describe "when callee answers" do
        before do
          incoming :outgoing_call_result_iq, "joined-call-id", Connfu.connection.commands.last.id
          incoming :outgoing_call_ringing_presence, "joined-call-id"
          incoming :outgoing_call_answered_presence, "joined-call-id"
        end
        
        it 'should not issue the nested join again' do
          Connfu.connection.commands.select{|c| c.class == Connfu::Commands::NestedJoin }.length.should == 1
        end
      end
    end
  end
end
