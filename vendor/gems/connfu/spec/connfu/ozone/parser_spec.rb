require 'spec_helper'

describe Connfu::Ozone::Parser do
  describe "#parse_event_from" do
    context 'an offer iq' do
      before do
        @node = create_presence(offer_presence('from-value', 'to-value', :from => "offer-from", :to => "offer-to"))
        @event = Connfu::Ozone::Parser.parse_event_from(@node)
      end

      it "should create an offer event" do
        @event.should be_instance_of Connfu::Event::Offer
      end

      it "should determine the from value of the presence" do
        @event.presence_from.should eq 'from-value'
      end

      it "should determine the to value of the presence" do
        @event.presence_to.should eq 'to-value'
      end

      it "should determine the call_id value of the offer" do
        @event.call_id.should eq @node.from.node
      end

      it "should determine the from value of the offer" do
        @event.from.should eq "offer-from"
      end

      it "should determine the to value of the offer" do
        @event.to.should eq "offer-to"
      end
    end

    context 'a recording result iq' do
      before do
        @node = create_presence(recording_result_iq('call-id', 'ref-id'))
        @event = Connfu::Ozone::Parser.parse_event_from(@node)
      end

      it "should create a result event that contains the id from ref node" do
        @event.should be_instance_of Connfu::Event::Result
        @event.ref_id.should == 'ref-id'
      end
    end

    context "a recording stop complete presence" do
      before do
        @node = create_presence(recording_stop_presence('call-id', 'ref-id', 'file:///tmp/recording.mp3'))
        @event = Connfu::Ozone::Parser.parse_event_from(@node)
      end

      it "should be an instance of RecordingStopComplete" do
        @event.should be_instance_of Connfu::Event::RecordingStopComplete
      end

      it "should create an event that contains the uri of the recording" do
        @event.uri.should == "file:///tmp/recording.mp3"
      end
    end

    context "a normal result iq" do
      before do
        @node = create_presence(result_iq)
        @event = Connfu::Ozone::Parser.parse_event_from(@node)
      end

      it "should create a result event" do
        @event.should be_instance_of Connfu::Event::Result
      end
    end

    context "an error iq" do
      before do
        @node = create_presence(error_iq)
        @event = Connfu::Ozone::Parser.parse_event_from(@node)
      end

      it "should create an error event" do
        @event.should be_instance_of Connfu::Event::Error
      end
    end

    context "a say complete iq" do
      before do
        @node = create_presence(say_complete_success)
        @event = Connfu::Ozone::Parser.parse_event_from(@node)
      end

      it "should create a SayComplete event" do
        @event.should be_instance_of Connfu::Event::SayComplete
      end

      it "should determine the call_id value of say complete" do
        @event.call_id.should eq @node.from.node
      end
    end

    context "an ask complete iq" do
      before do
        @node = create_presence(ask_complete_success)
        @event = Connfu::Ozone::Parser.parse_event_from(@node)
      end

      it "should create an AskComplete event" do
        @event.should be_instance_of Connfu::Event::AskComplete
      end

      it "should determine the call_id value" do
        @event.call_id.should eq @node.from.node
      end

      it "should determine the result digits" do
        @event.captured_input.should eq "1234"
      end
    end

    context "a transfer success presence" do
      before do
        @node = create_presence(transfer_success_presence)
        @event = Connfu::Ozone::Parser.parse_event_from(@node)
      end

      it "should create a TransferSuccess event" do
        @event.should be_instance_of Connfu::Event::TransferSuccess
      end

      it "should determine the call_id value of the transfer success iq" do
        @event.call_id.should eq @node.from.node
      end
    end

    context "a transfer timeout presence" do
      before do
        @node = create_presence(transfer_timeout_presence)
        @event = Connfu::Ozone::Parser.parse_event_from(@node)
      end

      it "should create a TransferTimeout event" do
        @event.should be_instance_of Connfu::Event::TransferTimeout
      end

      it "should determine the call_id value of the transfer timeout iq" do
        @event.call_id.should eq @node.from.node
      end
    end

    context "a transfer busy presence" do
      before do
        @node = create_presence(transfer_busy_presence)
        @event = Connfu::Ozone::Parser.parse_event_from(@node)
      end

      it "should create a TransferBusy event" do
        @event.should be_instance_of Connfu::Event::TransferBusy
      end

      it "should determine the call_id value of the transfer busy presence" do
        @event.call_id.should eq @node.from.node
      end
    end

    context "an outgoing call ringing presence" do
      before do
        @node = create_presence(outgoing_call_ringing_presence("call-id"))
        @event = Connfu::Ozone::Parser.parse_event_from(@node)
      end

      it "should create a Ringing event" do
        @event.should be_instance_of Connfu::Event::Ringing
      end

      it "should determine the call_id value of a Ringing event" do
        @event.call_id.should eq "call-id"
      end
    end

    context "an outgoing call answered presence" do
      before do
        @node = create_presence(outgoing_call_answered_presence("call-id"))
        @event = Connfu::Ozone::Parser.parse_event_from(@node)
      end

      it "should create a Ringing event" do
        @event.should be_instance_of Connfu::Event::Answered
      end

      it "should determine the call_id value of a Answered event" do
        @event.call_id.should eq "call-id"
      end
    end

  end

end