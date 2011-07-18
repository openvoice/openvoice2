require 'spec_helper'

describe Connfu::Continuation do
  describe "A dsl using continuation" do
    class MyTrivialDSLExample
      include Connfu::Continuation

      def method_which_waits
        wait
      end

      def first_method
      end

      def second_method
      end

      def run
        wait
        first_method
        wait
        second_method
      end
    end

    subject do
      MyTrivialDSLExample.new
    end

    it "should return after starting without calling first_method" do
      subject.should_not_receive(:first_method)
      subject.start
    end

    it "should call first_method when continued once" do
      subject.should_receive(:first_method).once
      subject.start
      subject.continue
    end

    it "should not call second_method when continued once" do
      subject.should_not_receive(:second_method)
      subject.start
      subject.continue
    end

    it "should only call second_method when continued twice" do
      subject.should_receive(:second_method).once
      subject.start
      subject.continue
      subject.continue
    end

    it "should only call first_method and second_method once, no matter how many times continued" do
      subject.should_receive(:first_method).once
      subject.should_receive(:second_method).once

      subject.start
      50.times { subject.continue }
    end

    it "should return execution to after #continue when #continue called" do
      subject.should_receive(:first_method).once
      called_count = 0
      subject.start
      # If wait/continue are handled incorrectly, calling continue will
      # resume control here, executing the line below twice!
      called_count = called_count + 1
      subject.continue
      called_count.should eql(1)
    end
  end
end