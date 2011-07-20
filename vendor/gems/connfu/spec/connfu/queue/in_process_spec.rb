require "spec_helper"

describe Connfu::Queue::InProcess do

  module Jobs
    class Base
      class << self
        attr_reader :args
        def perform(*args); @args = args; end
      end
    end
    class X < Base
      def self.queue; "x"; end
    end

    class Y < Base
      def self.queue; "y"; end
    end
  end

  before { @queue = Connfu::Queue::InProcess.new }

  subject { @queue }

  context "empty" do
    specify { subject.size(Jobs::X.queue).should == 0 }
    specify { subject.size(Jobs::Y.queue).should == 0 }

    it "should have no jobs available to reserve" do
      job = subject.reserve(Jobs::X.queue)
      job.should be_nil
    end
  end

  context "with one job on the X queue with no arguments" do
    before { @queue.enqueue(Jobs::X) }

    specify { subject.size(Jobs::X.queue).should == 1 }
    specify { subject.size(Jobs::Y.queue).should == 0 }

    it "should make an X job available to reserve" do
      job = subject.reserve(Jobs::X.queue)
      job.should_not be_nil
    end

    it "should not make a Y job available to reserve" do
      job = subject.reserve(Jobs::Y.queue)
      job.should be_nil
    end

    it "should provide a performable X job which has no arguments" do
      job = subject.reserve(Jobs::X.queue)
      job.perform
      Jobs::X.args.should == []
    end

    context "and another job on the X queue with one argument" do
      before { @queue.enqueue(Jobs::X, "x-argument") }

      it "should provide two performable X jobs in the same order in which they were enqueued" do
        first_job = subject.reserve(Jobs::X.queue)
        first_job.perform
        Jobs::X.args.should == []
        second_job = subject.reserve(Jobs::X.queue)
        second_job.perform
        Jobs::X.args.should == ["x-argument"]
      end
    end

    context "and another job on the Y queue with one argument" do
      before { @queue.enqueue(Jobs::Y, "y-argument") }

      specify { subject.size(Jobs::X.queue).should == 1 }
      specify { subject.size(Jobs::Y.queue).should == 1 }

      it "should make the Y job available to reserve" do
        job = subject.reserve(Jobs::Y.queue)
        job.should_not be_nil
      end

      it "should provide a performable Y job which has the one argument" do
        job = subject.reserve(Jobs::Y.queue)
        job.perform
        Jobs::Y.args.should == ["y-argument"]
      end
    end
  end

  context "with one job on the X queue with two arguments" do
    before { @queue.enqueue(Jobs::X, "argument-1", "argument-2") }

    it "should provide a performable job which has the two arguments" do
      job = subject.reserve(Jobs::X.queue)
      job.perform
      Jobs::X.args.should == ["argument-1", "argument-2"]
    end
  end

  context "with one job on the X queue with a hash argument containing symbol keys" do
    before { @queue.enqueue(Jobs::X, { :key1 => :value1, :key2 => :value2 }) }

    it "should provide a performable job which has arguments suitable for serialization (mimicking Resque behaviour)" do
      job = subject.reserve(Jobs::X.queue)
      job.perform
      Jobs::X.args.should == [{ "key1" => "value1", "key2" => "value2" }]
    end
  end

end