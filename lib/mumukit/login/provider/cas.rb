class Mumukit::Login::Provider::Cas < Mumukit::Login::Provider::Base
  def configure_omniauth!(omniauth)
    omniauth.provider :cas,
                      url: cas_config.url,
                      host: cas_config.host,
                      disable_ssl_verification: cas_config.disable_ssl_verification,
                      ca_path: '.'
  end

  private

  def cas_config
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
