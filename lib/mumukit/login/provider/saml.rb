class Mumukit::Login::Provider::Saml < Mumukit::Login::Provider::Base

  def configure_omniauth!(omniauth)
    omniauth.provider :saml, setup: setup_proc
  end

  private


  def default_settings
    saml = Mumukit::Login.config.saml
    # TODO: change the :assertion_consumer_service_url, the :issuer and the :slo_default_relay_state:
    # =>  1. we can not call any Organization method since there is none instantiated yet and
    # =>  2. we must use the absolut path to generate the right SAML metadata to set up the federation with the IdP
    {
      idp_cert: File.read('./saml_idp.crt'),
      certificate: File.read('./saml.crt'),
      private_key: File.read('./saml.key'),
      idp_sso_target_url: saml.idp_sso_target_url,
      idp_slo_target_url: saml.idp_slo_target_url,
      slo_default_relay_state: saml.base_url,
      attribute_service_name: 'Mumuki',
      request_attributes: [
        {name: 'email', name_format: 'urn:oasis:names:tc:SAML:2.0:attrname-format:basic', friendly_name: 'Email address'},
        {name: 'name', name_format: 'urn:oasis:names:tc:SAML:2.0:attrname-format:basic', friendly_name: 'Full name'},
        {name: 'image', name_format: 'urn:oasis:names:tc:SAML:2.0:attrname-format:basic', friendly_name: 'Avatar image'}
      ],
      attribute_statements: {
        name: [saml.translation_name],
        email: [saml.translation_email],
        image: [saml.translation_image]
      }
    }
  end

  def computed_settings(saml)
    {
      assertion_consumer_service_url: "#{saml.base_url}#{callback_path}",
      single_logout_service_url: "#{saml.base_url}#{auth_path}/slo",
      issuer: "#{saml.base_url}#{auth_path}"
    }
  end

  def logout_redirection_path
    "#{auth_path}/spslo"
  end
end
