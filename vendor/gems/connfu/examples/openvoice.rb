#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

class OpenVoice
  include Connfu::Dsl

  on :offer do |call|
    answer
    say "Welcome to Zhao's Open Voice communication center"
    unless caller.recorded_name.exists?
      ask "Please record your name before we transfer your call" do |caller|
        on_complete do |recording|
          caller.update_recorded_name recording
        end
      end
    end

    transfer user.phone_numbers do |answered|
      on_answer do
        menu "press 1 to connect to the caller, press 2 to send caller to voicemail"do |option|
          case option
            when 1
              answered.join
            when 2
              voicemail.start_recording(:announcement => "Please leave a message after the beep", :terminator => "#") do
                on_complete do |transcription|
                  send_text :to => mobile_number, :text => transcription
                  send_email :to => email_address, :body => transcription
                end
              end
            else
              logger.debug 'probably should not be here'
          end
        end
      end
    end
  end
end

Connfu.start OpenVoice