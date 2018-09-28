class Mumukit::Login::Provider::Cas < Mumukit::Login::Provider::Base
  def configure_omniauth!(omniauth)
    omniauth.provider :cas, setup: setup_proc
  end

  private

  def default_settings
    Mumukit::Login.config.cas
  end
end

# Monkey-patching to support phpCAS implementation
# where the first time the 'ticket' param is not sent.
module OmniAuth
  module Strategies
    class CAS
      alias_method :__callback_phase__, :callback_phase

      def callback_phase
        if !on_sso_path? && !request.params['ticket']
          return request_phase
        end

        __callback_phase__
      end
    end
  end
end

module OmniAuth
  module Strategies
    class CAS
      class ServiceTicketValidator
        def get_service_response_body
          result = ''
          http = Net::HTTP.new(@uri.host, @uri.port)
          http.use_ssl = @uri.port == 443 || @uri.instance_of?(URI::HTTPS)
          if http.use_ssl?
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE if @options.disable_ssl_verification?
            http.cert = OpenSSL::X509::Certificate.new @options.ssl_certificate
          end
          http.start do |c|
            response = c.get "#{@uri.path}?#{@uri.query}", VALIDATION_REQUEST_HEADERS.dup
            result = response.body
          end
          result
        end
      end
    end
  end
end
