require "spec_helper"

describe "receiving an error from the server" do

  testing_dsl do
    on :offer do |call|
      begin
        answer
        do_something
      rescue Object => e
        error_caught!
      end
    end
  end

  it "should raise an exception if the server responds with an error" do
    dsl_instance.should_receive(:error_caught!)

    incoming :offer_presence
    incoming :error_iq
  end
end