require 'spec_helper'

describe Connfu::Rayo::Parser do
  describe "#parse_event_from" do
    context 'an offer iq' do
      before do
        @from_jid = "call-id@#{PRISM_HOST}"
        @node = create_presence(offer_presence(@from_jid, 'to-value', :from => "offer-from", :to => "<sip:username@example.com>"))
        @event = Connfu::Rayo::Parser.parse_event_from(@node)
      end

      it "should create an offer event" do
        @event.should be_instance_of Connfu::Event::Offer
      end

      it "should determine the from value of the presence" do
        @event.presence_from.should eq @from_jid
      end

      it "should determine the to value of the presence" do
        @event.presence_to.should eq 'to-value'
      end

      it "should determine the call_id value of the offer" do
        @event.call_id.should eq 'call-id'
      end

      it "should determine the from value of the offer" do
        @event.from.should eq "offer-from"
      end

      it "should determine the to value of the offer" do
        @event.to[:address].should eq "sip:username@example.com"
        @event.to[:username].should eq "username"
        @event.to[:host].should eq "example.com"
        @event.to[:scheme].should eq "sip"
      end
    end

    context "a stop complete presence" do
      before do
        @node = create_presence(component_stop_presence("call-id@#{PRISM_HOST}/23399310-4590-499d-8917-a0642965a096"))
        @event = Connfu::Rayo::Parser.parse_event_from(@node)
      end

      it "should create a stop complete event" do
        @event.should be_instance_of Connfu::Event::StopComplete
      end
    end

    context 'a recording result iq' do
      before do
        @node = create_iq(recording_result_iq("call-id@#{PRISM_HOST}", 'ref-id'))
        @event = Connfu::Rayo::Parser.parse_event_from(@node)
      end

      it "should create a result event that contains the id from ref node" do
        @event.should be_instance_of Connfu::Event::Result
        @event.ref_id.should == 'ref-id'
      end

      it "should determine the command id of the originating event" do
        @event.command_id.should eq @node.attributes['id'].value
      end
    end

    context "a recording stop complete presence" do
      before do
        @node = create_presence(recording_stop_presence("call-id@#{PRISM_HOST}/ref-id", 'file:///tmp/recording.mp3'))
        @event = Connfu::Rayo::Parser.parse_event_from(@node)
      end

      it "should be an instance of RecordingStopComplete" do
        @event.should be_instance_of Connfu::Event::RecordingStopComplete
      end

      it "should create an event that contains the uri of the recording" do
        @event.uri.should == "file:///tmp/recording.mp3"
      end
    end

    context "a recording hangup complete presence" do
      before do
        @node = create_presence(recording_hangup_presence("call-id@#{PRISM_HOST}/ref-id", 'file:///tmp/recording.mp3'))
        @event = Connfu::Rayo::Parser.parse_event_from(@node)
      end

      it "should be an instance of RecordingHangupComplete" do
        @event.should be_instance_of Connfu::Event::RecordingHangupComplete
      end

      it "should create an event that contains the uri of the recording" do
        @event.uri.should == "file:///tmp/recording.mp3"
      end
    end

    context "a normal result iq" do
      before do
        @node = create_iq(result_iq)
        @event = Connfu::Rayo::Parser.parse_event_from(@node)
      end

      it "should create a result event" do
        @event.should be_instance_of Connfu::Event::Result
      end

      it "should determine the command id of the originating event" do
        @event.command_id.should eq @node.attributes['id'].value
      end
    end

    context "an error iq" do
      before do
        @node = create_iq(error_iq)
        @event = Connfu::Rayo::Parser.parse_event_from(@node)
      end

      it "should create an error event" do
        @event.should be_instance_of Connfu::Event::Error
      end

      it "should determine the command id of the originating event" do
        @event.command_id.should eq @node.attributes['id'].value
      end
    end

    context "a say complete iq" do
      before do
        @node = create_presence(say_success_presence("call-id@#{PRISM_HOST}"))
        @event = Connfu::Rayo::Parser.parse_event_from(@node)
      end

      it "should create a SayComplete event" do
        @event.should be_instance_of Connfu::Event::SayComplete
      end

      it "should determine the call_id value of say complete" do
        @event.call_id.should eq "call-id"
      end
    end

    context "an ask complete iq" do
      before do
        @node = create_presence(ask_success_presence("call-id@#{PRISM_HOST}"))
        @event = Connfu::Rayo::Parser.parse_event_from(@node)
      end

      it "should create an AskComplete event" do
        @event.should be_instance_of Connfu::Event::AskComplete
      end

      it "should determine the call_id value" do
        @event.call_id.should eq "call-id"
      end

      it "should determine the result digits" do
        @event.captured_input.should eq "1234"
      end
    end

    context "a transfer success presence" do
      before do
        @node = create_presence(transfer_success_presence("call-id@#{PRISM_HOST}"))
        @event = Connfu::Rayo::Parser.parse_event_from(@node)
      end

      it "should create a TransferSuccess event" do
        @event.should be_instance_of Connfu::Event::TransferSuccess
      end

      it "should determine the call_id value of the transfer success iq" do
        @event.call_id.should eq "call-id"
      end
    end

    context "a transfer timeout presence" do
      before do
        @node = create_presence(transfer_timeout_presence("call-id@#{PRISM_HOST}"))
        @event = Connfu::Rayo::Parser.parse_event_from(@node)
      end

      it "should create a TransferTimeout event" do
        @event.should be_instance_of Connfu::Event::TransferTimeout
      end

      it "should determine the call_id value of the transfer timeout iq" do
        @event.call_id.should eq "call-id"
      end
    end

    context "a transfer busy presence" do
      before do
        @node = create_presence(transfer_busy_presence("call-id@#{PRISM_HOST}"))
        @event = Connfu::Rayo::Parser.parse_event_from(@node)
      end

      it "should create a TransferBusy event" do
        @event.should be_instance_of Connfu::Event::TransferBusy
      end

      it "should determine the call_id value of the transfer busy presence" do
        @event.call_id.should eq "call-id"
      end
    end

    context "an outgoing call ringing presence" do
      before do
        @node = create_presence(ringing_presence("call-id@#{PRISM_HOST}", "client-jid"))
        @event = Connfu::Rayo::Parser.parse_event_from(@node)
      end

      it "should create a Ringing event" do
        @event.should be_instance_of Connfu::Event::Ringing
      end

      it "should determine the call_id value" do
        @event.call_id.should eq "call-id"
      end

      it "should determine the presence_to value" do
        @event.presence_to.should eq "client-jid"
      end

      it "should determine the presence_from value" do
        @event.presence_from.should eq "call-id@#{PRISM_HOST}"
      end
    end

    context "an outgoing call answered presence" do
      before do
        @node = create_presence(answered_presence("call-id@#{PRISM_HOST}"))
        @event = Connfu::Rayo::Parser.parse_event_from(@node)
      end

      it "should create a Ringing event" do
        @event.should be_instance_of Connfu::Event::Answered
      end

      it "should determine the call_id value of a Answered event" do
        @event.call_id.should eq "call-id"
      end
    end

    context "a joined presence" do
      before do
        @node = create_presence(joined_presence("call-id@#{PRISM_HOST}", "other-call-id"))
        @event = Connfu::Rayo::Parser.parse_event_from(@node)
      end

      it "should create a Joined event" do
        @event.should be_instance_of Connfu::Event::Joined
      end

      it "should determine the call_id value of a Joined event" do
        @event.call_id.should eq "call-id"
      end

      it "should determine the joined call id" do
        @event.joined_call_id.should eq "other-call-id"
      end
    end

    context "an unjoined presence" do
      before do
        @node = create_presence(unjoined_presence("call-id@#{PRISM_HOST}", 'other-call-id'))
        @event = Connfu::Rayo::Parser.parse_event_from(@node)
      end

      it "should create an Unjoined event" do
        @event.should be_instance_of Connfu::Event::Unjoined
      end

      it "should determine the call_id value of an Unjoined event" do
        @event.call_id.should eq "call-id"
      end

      it "should determine the unjoined call id" do
        @event.unjoined_call_id.should eq "other-call-id"
      end
    end

    context "an unknown stanza" do
      before do
        @node = create_presence(%{<presence from="abc@127.0.0.1/123" to="userb@127.0.0.1/voxeo">
          <garbage xmlns="#{rayo('ext:1')}">
            <trash xmlns="#{rayo('ext:rubbish:1')}"/>
          </garbage>
        </presence>})
      end

      it "should raise an exception" do
        lambda do
          Connfu::Rayo::Parser.parse_event_from(@node)
        end.should raise_error
      end
    end

    context "a presence hangup" do
      before do
        @node = create_presence(hangup_presence("call-id@#{PRISM_HOST}"))
        @event = Connfu::Rayo::Parser.parse_event_from(@node)
      end

      it "should create a Hangup event" do
        @event.should be_instance_of Connfu::Event::Hangup
      end

      it "should determine the call_id" do
        @event.call_id.should eq 'call-id'
      end

      it "should determine the presence_from" do
        @event.presence_from.should eq "call-id@#{PRISM_HOST}"
      end
    end

    context "a presence reject" do
      before do
        @node = create_presence(reject_presence("call-id@#{PRISM_HOST}"))
        @event = Connfu::Rayo::Parser.parse_event_from(@node)
      end

      it "should create a Rejected event" do
        @event.should be_instance_of Connfu::Event::Rejected
      end

      it "should determine the call_id" do
        @event.call_id.should eq 'call-id'
      end
    end

    context "a presence timeout" do
      before do
        node = create_presence(timeout_presence("call-id@#{PRISM_HOST}"))
        @event = Connfu::Rayo::Parser.parse_event_from(node)
      end

      it "should create a Timeout event" do
        @event.should be_instance_of Connfu::Event::Timeout
      end

      it "should determine the call_id" do
        @event.call_id.should eq 'call-id'
      end
    end

    context "a presence busy" do
      before do
        node = create_presence(busy_presence("call-id@#{PRISM_HOST}"))
        @event = Connfu::Rayo::Parser.parse_event_from(node)
      end

      it "should create a Busy event" do
        @event.should be_instance_of Connfu::Event::Busy
      end

      it "should determine the call_id" do
        @event.call_id.should eq 'call-id'
      end
    end

    context "a component hangup" do
      before do
        node = create_presence(component_hangup_presence("call-id@#{PRISM_HOST}/3b1d199c-39af-4256-9a49-97293a530ac6"))
        @event = Connfu::Rayo::Parser.parse_event_from(node)
      end

      it "should create a Hangup event" do
        @event.should be_instance_of Connfu::Event::Hangup
      end

      it "should determine the call_id" do
        @event.call_id.should eq 'call-id'
      end
    end
  end

end