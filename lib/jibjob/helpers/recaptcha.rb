module Recaptcha
  RECAPTCHA_API_SERVER = 'http://api.recaptcha.net'
  RECAPTCHA_API_SECURE_SERVER = 'https://api-secure.recaptcha.net'
  RECAPTCHA_VERIFY_SERVER = 'api-verify.recaptcha.net'
  
  class RecaptchaError < Exception
  end
  
  module ClientHelper
    def recaptcha_tags(options={})
      # Default options
      key   = options[:public_key] ||= self.class.recaptcha_pubkey
      error = options[:error] ||= session[:recaptcha_error]
      uri   = options[:ssl] ? RECAPTCHA_API_SECURE_SERVER : RECAPTCHA_API_SERVER
      html  = ""
      if options[:display]
        html << %{<script type="text/javascript">\n}
        html << %{  var RecaptchaOptions = #{options[:display].to_json};\n}
        html << %{</script>\n}
      end
      if options[:ajax]
        html << %{<div id="dynamic_recaptcha"></div>}
        html << %{<script type="text/javascript">\n}
        html << %{  Recaptcha.create('#{key}', document.getElementById('dynamic_recaptcha')#{options[:display] ? '' : ',RecaptchaOptions'});}
        html << %{</script>\n}
      else
        html << %{<script type="text/javascript" src="#{uri}/challenge?k=#{key}}
        html << %{#{error ? "&error=#{::CGI::escape(error)}" : ""}"></script>\n}
        unless options[:noscript] == false
          html << %{<noscript>\n }
          html << %{<iframe src="#{uri}/noscript?k=#{key}" }
          html << %{height="#{options[:iframe_height] ||= 300}" }
          html << %{width="#{options[:iframe_width]   ||= 500}" }
          html << %{frameborder="0"></iframe><br/>\n  }
          html << %{<textarea name="recaptcha_challenge_field" }
          html << %{rows="#{options[:textarea_rows] ||= 3}" }
          html << %{cols="#{options[:textarea_cols] ||= 40}"></textarea>\n  }
          html << %{<input type="hidden" name="recaptcha_response_field" value="manual_challenge">}
          html << %{</noscript>\n}
        end
      end
      raise RecaptchaError, "No public key specified." unless key
      html
    end # recaptcha_tags
  end # ClientHelper
  
  module Verify
    def verify_recaptcha(options={})
      private_key = options[:private_key] if options.is_a?(Hash)
      private_key ||= self.class.recaptcha_privkey
      raise RecaptchaError, "No private key specified." unless private_key
      begin
        recaptcha = nil
        Timeout::timeout(options[:timeout] || 3) do
          recaptcha = Net::HTTP.post_form URI.parse("http://#{RECAPTCHA_VERIFY_SERVER}/verify"), {
            "privatekey" => private_key,
            "remoteip"   => request.ip,
            "challenge"  => params[:recaptcha_challenge_field],
            "response"   => params[:recaptcha_response_field]
          }
        end
        answer, error = recaptcha.body.split.map { |s| s.chomp }
        unless answer == 'true'
          #session[:recaptcha_error] = error
          return false
        else
          #session[:recaptcha_error] = nil
          return true
        end
      rescue Timeout::Error 
        #session[:recaptcha_error] = "recaptcha-not-reachable"
        return false
      rescue Exception => e
        raise RecaptchaError, e.message, e.backtrace
      end
    end # verify_recaptcha
  end # Verify
end # Recaptcha