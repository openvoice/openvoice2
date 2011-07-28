module Connfu
  module Commands
    module Recording
      FORMATS = {
        :gsm => {
          :name => "GSM",
          :codecs => [:gsm]
        },
        :wav => {
          :name => "WAV",
          :codecs => [
            :linear_16bit_128k, :linear_16bit_256k, :alaw_pcm_64k, :mulaw_pcm_64k,
            :adpcm_32k, :adpcm_32k_oki, :g723_1b, :amr, :amr_wb, :g729_a, :evrc
          ]
        },
        :raw => {
          :name => "RAW",
          :codecs => [
            :linear_16bit_128k, :linear_16bit_256k, :alaw_pcm_64k, :mulaw_pcm_64k,
            :adpcm_32k, :adpcm_32k_oki
          ]
        },
        :mp3 => {
          :name => "MP3"
        }
      }

      class InvalidEncoding < StandardError; end

      class Start
        include Connfu::Commands::Base

        def to_iq
          attributes = { "xmlns" => rayo("record:1"), "start-beep" => "true" }
          attributes["max-length"] = @params[:max_length] if @params[:max_length]
          attributes["start-beep"] = @params[:beep] if @params.has_key?(:beep)
          attributes.merge!(valid_encoding_attributes)

          build_iq(attributes)
        end

        def command
          "record"
        end

        def valid_encoding_attributes
          valid_attributes = {}
          if @params.has_key?(:codec) && !@params.has_key?(:format)
            raise InvalidEncoding, "Please supply :format when specifying :codec"
          end

          if @params.has_key?(:format)
            if format = FORMATS[@params[:format]]
              valid_attributes["format"] = format[:name]

              if @params.has_key?(:codec)
                if format[:codecs].include?(@params[:codec])
                  valid_attributes["codec"] = @params[:codec].to_s.upcase
                else
                  raise InvalidEncoding, "Codec #{@params[:codec]} not supported for #{@params[:format]} format"
                end
              end

            else
              raise InvalidEncoding, "Format #{@params[:format]} not supported"
            end
          end

          return valid_attributes
        end

      end

      class Stop
        include Connfu::Commands::Base

        def to
          super + "/" + @params[:ref_id]
        end

        def to_iq
          build_iq "xmlns" => rayo("ext:1")
        end
      end
    end
  end
end