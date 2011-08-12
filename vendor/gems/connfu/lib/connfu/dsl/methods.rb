module Connfu
  module Dsl
    module Methods
      def say(text)
        send_command Connfu::Commands::Say.new(:text => text, :call_jid => call_jid, :client_jid => client_jid)
        wait_for Connfu::Event::SayComplete
      end

      def ask(options)
        send_command Connfu::Commands::Ask.new(:prompt => options[:prompt], :digits => options[:digits], :client_jid => client_jid, :call_jid => call_jid)
        ask_complete = wait_for Connfu::Event::AskComplete
        ask_complete.captured_input
      end

      def answer
        send_command Connfu::Commands::Answer.new(:call_jid => call_jid, :client_jid => client_jid)
      end

      def reject
        send_command Connfu::Commands::Reject.new(:call_jid => call_jid, :client_jid => client_jid)
      end

      def hangup(jid=call_jid)
        send_command Connfu::Commands::Hangup.new(:call_jid => jid, :client_jid => client_jid)
        wait_for Connfu::Event::Hangup
        @finished = true
      end

      def dial(options)
        options = {
          :to => options[:to],
          :from => options[:from],
          :headers => options[:headers],
          :client_jid => Connfu.connection.jid.to_s,
          :rayo_host => Connfu.connection.jid.domain
        }
        options.delete(:headers) if options[:headers].nil?
        result = send_command Connfu::Commands::Dial.new(options)
        observe_events_for(result.ref_id)
        result
      end

      def redirect(redirect_to)
        send_command Connfu::Commands::Redirect.new(:redirect_to => redirect_to, :call_jid => call_jid, :client_jid => client_jid)
      end

      def transfer(*transfer_to)
        options = transfer_to.last.is_a?(Hash) ? transfer_to.pop : {}
        if options.delete(:mode) == :round_robin
          result = nil
          transfer_to.each do |sip_address|
            result = transfer sip_address, options
            break if result.answered?
          end
          return result
        else
          command_options = {:transfer_to => transfer_to, :call_jid => call_jid, :client_jid => client_jid}
          command_options[:timeout] = options[:timeout] * 1000 if options[:timeout]
          send_command Connfu::Commands::Transfer.new(command_options)
          transfer_event = wait_for Connfu::Event::TransferEvent
          transfer_event.state
        end
      end

      def transfer_using_join(dial_from, dial_to)
        command_options = {
          :call_jid => call_jid,
          :client_jid => client_jid,
          :dial_to => dial_to,
          :dial_from => dial_from,
          :call_id => call_id
        }
        send_command Connfu::Commands::NestedJoin.new(command_options)
        wait_for Connfu::Event::Hangup
        @finished = true
      end
    end
  end
end