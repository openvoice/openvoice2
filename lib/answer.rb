require 'connfu'

Connfu.setup "usera@127.0.0.1", "1"
Connfu.redis_uri = "redis://localhost:6379"
#Connfu.setup "usera@127.0.0.1", "1"

class AnswerExample
  include Connfu::Dsl

  handle_any_outgoing_call do |call|
    call.on_answer do
      p "Answered call"
      # check call number to see if I dialled it, or has already got voicemail message recorded....
      say('please record your greeting')
      start_recording

      sleep 5

      p stop_recording

      hangup
    end

    call.on_ringing do
      p "Call is ringing"
    end
  end
end

Connfu.start AnswerExample
