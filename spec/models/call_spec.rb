require 'spec_helper'

describe Call do
  describe "#update_state!(state)" do
    subject do
      Factory(:call)
    end

    it "persists state to given value" do
      subject.update_state!(:rejected)
      subject.reload
      subject.state.should eql(Connfu::Dsl::CallBehaviour::REJECTED)
    end
  end
end