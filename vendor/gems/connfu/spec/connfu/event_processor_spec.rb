require 'spec_helper'

describe Connfu::EventProcessor do
  subject do
    Connfu::EventProcessor.new(stub('handler-class'))
  end

  describe '#handle_event' do
    it 'should pass event to first known handler that will accept it' do
      event = stub('event')
      handler = stub('handler', :finished? => true, :can_handle_event? => true)
      handler.should_receive(:handle_event).with(event)
      subject.handlers << handler
      subject.handle_event(event)
    end

    it 'should remove finished handlers' do
      subject.handlers << stub('finished-handler', :finished? => true, :can_handle_event? => false)
      subject.handle_event(nil)
      subject.handlers.should be_empty
    end
  end
end
