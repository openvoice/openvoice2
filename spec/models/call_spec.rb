require 'spec_helper'

describe Call do
  describe "#update_state!(state)" do
    subject do
      Factory(:call)
    end

    it "persists state to given value" do
      subject.update_state!(Call::REJECTED)
      subject.reload
      subject.state.should eql(Call::REJECTED)
    end
  end
end