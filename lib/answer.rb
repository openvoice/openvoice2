require 'connfu'

Connfu.setup "usera@46.137.85.52", "1"
#Connfu.setup "usera@127.0.0.1", "1"

class AnswerExample
  include Connfu::Dsl

  on :offer do |offer|
    answer
    say('hello, this is openvoice powered by connfu')
    say('http://www.phono.com/audio/troporocks.mp3')
    hangup
  end
end

Connfu.start AnswerExample
