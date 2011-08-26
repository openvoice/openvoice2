require 'rubygems'
require 'bundler/setup'
require 'connfu'

CONNFU_CONFIG = {
  'default' => {
    :connfu_uri => 'jid://usera:1@127.0.0.1',
    :redis_url => 'redis://localhost:6379'
  }
}
CONNFU_CONFIG['amazon'] = CONNFU_CONFIG['default'].merge(:connfu_uri => 'jid://usera:1@46.137.85.52')
CONNFU_CONFIG['odin'] = CONNFU_CONFIG['default'].merge(:connfu_uri => 'jid://usera:1@odin.openvoice2.com')
CONNFU_CONFIG['thor'] = CONNFU_CONFIG['default'].merge(:connfu_uri => 'jid://usera:1@thor.openvoice2.com')

CONNFU_ENV = ENV['CONNFU_ENV'] || 'default'

Connfu.config.uri = CONNFU_CONFIG[CONNFU_ENV][:connfu_uri]

logfile = File.expand_path('../../log/connfu.log', __FILE__)
Connfu.io_log = Connfu::Logging::IOLogger.new(logfile)

def update_status(status)
  logfile = File.expand_path('../../log/example_status.log', __FILE__)
  File.open(logfile, "a") { |f| f.puts "#{Time.now}: #{status}" }
end

DIAL_TO = ENV['DIAL_TO']
RECIPIENTS = []

def require_one_recipient!
  unless DIAL_TO
    puts "Specify the destination SIP address by setting the DIAL_TO environment variable"
    exit 1
  end
end

def require_two_recipients!
  unless DIAL_TO and DIAL_TO.split(',').length == 2
    puts "Please specify two recipients by setting DIAL_TO, e.g. DIAL_TO=foo@example.com,bar@example.com"
    exit 1
  end
  RECIPIENTS.push *DIAL_TO.split(',')
end