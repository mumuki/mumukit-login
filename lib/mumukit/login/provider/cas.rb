class Mumukit::Login::Provider::Cas < Mumukit::Login::Provider::Base
  def configure_omniauth!(omniauth)
    omniauth.provider :cas, setup: setup_proc
  end

  private

  def default_settings
    Mumukit::Login.config.cas
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
            http.cert = @options.ssl_certificate.try { |it| OpenSSL::X509::Certificate.new it }
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
