class Mumukit::Login::Provider::Auth0 < Mumukit::Login::Provider::Base
  def configure_omniauth!(omniauth)
    omniauth.provider :auth0,
                      auth0_config.client_id,
                      auth0_config.client_secret,
                      auth0_config.domain,
                      callback_path: callback_path
  end

  def request_authentication!(controller, login_settings)
    controller.render_html! auth0_script_html(controller, login_settings)
  end

  def header_html(*)
    ''
  end

  def footer_html(*)
    '<a href="https://auth0.com/" target="_blank">
        <img height="40" alt="JWT Auth for open source projects" src="//cdn.auth0.com/oss/badges/a0-badge-light.png"/>
     </a>'
  end

  private

  def auth0_config
    Mumukit::Login.config.auth0
  end

  def lock_settings(controller, login_settings, options)
    login_settings.to_lock_json(controller.url_for(callback_path), options)
  end

  def auth0_script_html(controller, login_settings)
    settings = lock_settings(controller, login_settings, {closable: false})
    <<HTML
 <script src="https://cdn.auth0.com/js/lock-9.min.js"></script>
 <script type="text/javascript">
      new Auth0Lock('#{auth0_config.client_id}', '#{auth0_config.domain}').show(#{settings});
  </script>
HTML
  end
end
