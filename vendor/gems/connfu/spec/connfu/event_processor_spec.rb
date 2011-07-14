require 'spec_helper'

describe Connfu::EventProcessor do
  subject do
    Connfu::EventProcessor.new(stub('handler'))
  end

  describe '#handle_event' do
    it 'should ignore nil events' do
      subject.handle_event(nil)
    end
          
    it 'should ignore events without call_id' do
      subject.handle_event(stub('event_without_call_id'))
    end
  end
end
