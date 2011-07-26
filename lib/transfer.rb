require 'connfu'

Connfu.config.uri = ENV['CONNFU_JABBER_URI']

Connfu.start do
  on :offer do |call|
    answer
    say 'please wait while we transfer your call'
    result = transfer 'sip:jasoncale@iptel.org', 'sip:floehopper@iptel.org'
    puts "The call was answered, and has finished" if result.answered?
  end
end
