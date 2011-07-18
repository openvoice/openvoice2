require 'spec_helper'

describe Connfu::App do
  describe 'App.dial' do
    it 'should add a dial job in the dial queue' do
      lambda {
        Connfu::App.dial(:to => 'sip-to', :from => 'sip-from')
      }.should change {Resque.size(Connfu::Jobs::Dial.queue)}.by(1)
    end
  end
end

describe Connfu::Jobs do
  before do
    Resque.redis.flushall
    Connfu.setup('foo', 'bar')
  end

  describe 'Jobs.perform' do
    it 'should send a dial command to the server' do
      to, from = 'to', 'from'
      Connfu::App.dial(:to => to, :from => from)
      Connfu.adaptor.should_receive(:send_command).with(Connfu::Commands::Dial.new(:to => to, :from => from))
      job = Resque::Job.reserve(Connfu::Jobs::Dial.queue)
      job.perform
    end
  end
end