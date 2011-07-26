require 'spec_helper'

describe Connfu::Queue::Worker do
  subject { Connfu::Queue::Worker.new(Connfu::Jobs::Dial.queue) }

  it "should grab the next job from the dial queue" do
    Connfu::Queue.should_receive(:reserve).with(Connfu::Jobs::Dial.queue)
    subject.call
  end

  it "should process the next job from the dial queue" do
    job = Connfu::Jobs::Dial
    job.should_receive(:perform)
    Connfu::Queue.stub(:reserve).and_return(job)
    subject.call
  end

  it 'should not error if there are no jobs to be processed' do
    Connfu::Queue.stub(:reserve).and_return(nil)
    lambda { subject.call }.should_not raise_error
  end
end