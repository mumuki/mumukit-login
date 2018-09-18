class Mumukit::Login::Provider::Cas < Mumukit::Login::Provider::Base
  def configure_omniauth!(omniauth)
    omniauth.provider :cas,
                      url: cas_config.url,
                      host: cas_config.host,
                      ca_path: '.',
                      disable_ssl_verification: true # FIXME this is big security issue
  end

  private

  def cas_config
    Mumukit::Login.config.cas
  end
end

# ---

module OmniAuth
  module Strategies
    class CAS
      def callback_phase
        # Monkey-patching to support phpCAS implementation
        # where the first time the 'ticket' param is not sent.
        if !on_sso_path? && !request.params['ticket']
          return request_phase
        end

        # Original method
        if on_sso_path?
          single_sign_out_phase
        else
          @ticket = request.params['ticket']
          fail!(:no_ticket, MissingCASTicket.new('No CAS Ticket')) unless @ticket
          fetch_raw_info(@ticket)
          return fail!(:invalid_ticket, InvalidCASTicket.new('Invalid CAS Ticket')) if raw_info.empty?
          super
        end
      end
    end
  end
end
