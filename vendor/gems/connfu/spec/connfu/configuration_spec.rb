require 'spec_helper'

describe Connfu::Configuration do
  describe '.new(options = {})' do
    before do
      ENV['CONNFU_JABBER_URI'] = 'jid://env-user:env-password@example.com'
    end

    subject do
      Connfu::Configuration.new
    end

    describe 'called without a uri' do
      it 'sets uri to value of ENV["CONNFU_JABBER_URI"]' do
        subject.uri.should eql('jid://env-user:env-password@example.com')
        subject.user.should eql('env-user')
        subject.password.should eql('env-password')
        subject.host.should eql('example.com')
      end
    end

    describe 'called with a uri' do
      subject do
        Connfu::Configuration.new :uri => 'jid://graham:greene@example.com'
      end

      it 'sets uri to given value' do
        subject.uri.should eql('jid://graham:greene@example.com')
        subject.user.should eql('graham')
        subject.password.should eql('greene')
        subject.host.should eql('example.com')
      end
    end
  end

  describe '#uri=(uri)' do
    subject do
      Connfu::Configuration.new
    end

    it 'takes uri, user, password and host from provided uri' do
      subject.uri = 'jid://tom:jerry@example.com'
      subject.user.should eql('tom')
      subject.password.should eql('jerry')
      subject.host.should eql('example.com')
    end

    it 'sets user, password, and host to nil when passed nil' do
      subject.uri = 'jid://tom:jerry@example.com'
      subject.uri = nil
      subject.user.should be_nil
      subject.password.should be_nil
      subject.host.should be_nil
    end
  end
end