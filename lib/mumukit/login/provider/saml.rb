class Mumukit::Login::Provider::Saml < Mumukit::Login::Provider::Base
  def saml_config
    Mumukit::Login.config.saml
  end

  def configure_omniauth!(omniauth)
    omniauth.provider :saml,
                      # TODO: change the :assertion_consumer_service_url, the :issuer and the :slo_default_relay_state:
                      # =>  1. we can not call any Organization method since there is none instantiated yet and
                      # =>  2. we must use the absolut path to generate the right SAML metadata to set up the federation with the IdP
                      assertion_consumer_service_url: "#{saml_config.base_url}#{callback_path}",
                      single_logout_service_url: "#{saml_config.base_url}#{auth_path}/slo",
                      issuer: "#{saml_config.base_url}#{auth_path}",
                      idp_sso_target_url: saml_config.idp_sso_target_url,
                      idp_slo_target_url: saml_config.idp_slo_target_url,
                      slo_default_relay_state: saml_config.base_url,
                      attribute_service_name: 'Mumuki',
                      request_attributes: [
                          {name: 'email', name_format: 'urn:oasis:names:tc:SAML:2.0:attrname-format:basic', friendly_name: 'Email address'},
                          {name: 'name', name_format: 'urn:oasis:names:tc:SAML:2.0:attrname-format:basic', friendly_name: 'Full name'},
                          {name: 'image', name_format: 'urn:oasis:names:tc:SAML:2.0:attrname-format:basic', friendly_name: 'Avatar image'}
                      ],
                      attribute_statements: {
                          name: [saml_config.translation_name],
                          email: [saml_config.translation_email],
                          image: [saml_config.translation_image]
                      },
                      setup: lambda { |env|
                        options = env['omniauth.strategy'].options
                        options[:idp_cert] = File.read('./saml_idp.crt')  # This is just a quickfix to avoid breaking if there are no saml configuration files.
                        options[:certificate] = File.read('./saml.crt')   # It could also serve to parametrize these files by organization
                        options[:private_key] = File.read('./saml.key')   # and have multiple organizations with different saml providers though.
                      }
  end

  def configure_rails_forgery_protection!(_controller_class)
    # FIXME this is big security issue
    # Do nothing (do not protect): the IdP calls the assertion_url via POST and without the CSRF token
  end

  def logout_redirection_path
    "#{auth_path}/spslo"
  end
end
