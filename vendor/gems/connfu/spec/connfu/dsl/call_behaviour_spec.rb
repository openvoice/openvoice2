require 'spec_helper'

describe Connfu::Dsl::CallBehaviour do
  describe "#state" do

    class TestClass
      include Connfu::Dsl
    end

    before do
      setup_connfu(handler_class = nil)
      @call_id = "call-id"
      @call_jid = "#{@call_id}@#{PRISM_HOST}"
    end

    context 'on_start' do
      it 'should be in started state' do
        TestClass.dial :to => 'to', :from => 'from' do |call_behaviour|
          call_behaviour.on_start do
            call_behaviour.state.should == :started
          end
        end

        incoming :dial_result_iq, @call_id, last_command.id
      end
    end

    context 'on_ringing' do
      it 'should be in ringing state' do
        TestClass.dial :to => 'to', :from => 'from' do |call_behaviour|
          call_behaviour.on_ringing do
            call_behaviour.state.should == :ringing
          end
        end

        incoming :dial_result_iq, @call_id, last_command.id
        incoming :ringing_presence, @call_jid
      end
    end

    context 'on_answer' do
      it 'should be in answered state' do
        TestClass.dial :to => 'to', :from => 'from' do |call_behaviour|
          call_behaviour.on_answer do
            call_behaviour.state.should == :answered
          end
        end

        incoming :dial_result_iq, @call_id, last_command.id
        incoming :ringing_presence, @call_jid
        incoming :answered_presence, @call_jid
      end
    end

    context 'on_hangup' do
      it 'should be in hangup state' do
        TestClass.dial :to => 'to', :from => 'from' do |call_behaviour|
          call_behaviour.on_hangup do
            call_behaviour.state.should == :hangup
          end
        end

        incoming :dial_result_iq, @call_id, last_command.id
        incoming :ringing_presence, @call_jid
        incoming :answered_presence, @call_jid
        incoming :hangup_presence, @call_jid
      end
    end

    context 'on_reject' do
      it 'should be in reject state' do
        TestClass.dial :to => 'to', :from => 'from' do |call_behaviour|
          call_behaviour.on_reject do
            call_behaviour.state.should == :rejected
          end
        end

        incoming :dial_result_iq, @call_id, last_command.id
        incoming :ringing_presence, @call_jid
        incoming :reject_presence, @call_jid
      end
    end

    context 'on_timeout' do
      it 'should be in timeout state' do
        TestClass.dial :to => 'to', :from => 'from' do |call_behaviour|
          call_behaviour.on_timeout do
            call_behaviour.state.should == :timeout
          end
        end

        incoming :dial_result_iq, @call_id, last_command.id
        incoming :ringing_presence, @call_jid
        incoming :timeout_presence, @call_jid
      end
    end

    context 'on_busy' do
      it 'should be in busy state' do
        TestClass.dial :to => 'to', :from => 'from' do |call_behaviour|
          call_behaviour.on_busy do
            call_behaviour.state.should == :busy
          end
        end

        incoming :dial_result_iq, @call_id, last_command.id
        incoming :ringing_presence, @call_jid
        incoming :busy_presence, @call_jid
      end
    end

  end
end
