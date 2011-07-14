require "spec_helper"

describe "discriminating based on the caller" do
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
      hash_including(:from => %{"James Adam <sip:james@127.0.0.1>"})
    )

    incoming :offer_presence, @server_address, @client_address, :from => %{"James Adam <sip:james@127.0.0.1>"}
  end

  it "exposes who the call is being routed to" do
    dsl_instance.should_receive(:do_something_with).with(
      hash_including(:to => %{"<sip:usera@127.0.0.1>"})
    )

    incoming :offer_presence, @server_address, @client_address, :to => %{"<sip:usera@127.0.0.1>"}
  end
end