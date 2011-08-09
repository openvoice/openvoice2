require "spec_helper"

describe "handling a call offer" do
  testing_dsl do
    on :offer do |offer|
      do_something_with(
        :from => offer.from,
        :to => offer.to
      )
    end
  end

  it "exposes who the call is from" do
    dsl_instance.should_receive(:do_something_with).with(
      hash_including(:from => "James Adam <sip:james@127.0.0.1>")
    )

    incoming :offer_presence, @call_jid, @client_jid, :from => "James Adam <sip:james@127.0.0.1>"
  end

  it "exposes who the call is being routed to" do
    parsed_hash = {
      :address => "sip:usera@127.0.0.1",
      :scheme => "sip",
      :username => "usera",
      :host => "127.0.0.1"
    }

    dsl_instance.should_receive(:do_something_with).with(
      hash_including(:to => parsed_hash)
    )

    incoming :offer_presence, @call_jid, @client_jid, :to => "<sip:usera@127.0.0.1>"
  end

  it "implicitly hangs up once handling is complete" do
    handler_instance = Connfu.event_processor.handler_class.new({})
    Connfu.event_processor.stub(:build_handler).and_return(handler_instance)
    handler_instance.should_receive(:do_something_with).ordered
    handler_instance.should_receive(:hangup).ordered
    incoming :offer_presence, @call_jid, @client_jid
  end
end

describe "offer which is hungup by the DSL" do
  testing_dsl do
    on :offer do |call|
      answer
      hangup
    end
  end

  before :each do
    @call_id = '34209dfiasdoaf'
    @call_jid = "#{@call_id}@server.whatever"
    @client_jid = "usera@127.0.0.whatever/voxeo"
  end

  it "should not issue another hangup after it has been called in the DSL" do
    handler_instance = Connfu.event_processor.handler_class.new({})
    Connfu.event_processor.stub(:build_handler).and_return(handler_instance)
    incoming :offer_presence, @call_jid, @client_jid
    incoming :result_iq, @call_id # from the answer command
    handler_instance.should_receive(:hangup).never
    incoming :result_iq, @call_id # from the hangup within DSL
    incoming :hangup_presence, @call_id
  end
end
