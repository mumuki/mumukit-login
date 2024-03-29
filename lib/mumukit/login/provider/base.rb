class Mumukit::Login::Provider::Base

  def name
    @name ||= self.class.name.demodulize.downcase
  end

  required :configure_omniauth!

  def request_authentication!(controller, _login_settings)
    controller.redirect! auth_path
  end

  def login_path(controller)
    create_uri '/login', login_path_params(controller)
  end

  def login_path_params(controller)
    {
        origin: create_uri(controller.request.path, controller.request.params),
        organization: Mumukit::Platform::Organization.current.name
    }
  end

  def auth_path
    "/auth/#{name}"
  end

  def callback_path
    "/auth/#{name}/callback"
  end

  def logout_redirection_path
    '/'
  end

  def button_html(controller, title, clazz)
    %Q{<a class="#{clazz}" href="#{login_path(controller)}">#{title}</a>}
  end

  def footer_html(*)
    nil
  end

  def header_html(*)
    nil
  end

  def logout_current_user!(controller)
    controller.redirect_after_logout!
  end

  def setup_proc
    proc do |env|
      options = env['omniauth.strategy'].options
      effective_settings = default_settings.to_h.merge(setup_phase_login_settings(env))
      options.merge!(effective_settings)
      options.merge!(computed_settings(effective_settings.to_struct))
    end
  end

  # Default provider settings that come from the environment
  #
  # Override this method in order to read ENV and in order to provide default settings
  #
  # These setting can be overriden by organization's `provider_settings`
  # and by the provider's `computed_settings`
  def default_settings
    {}
  end

  # Provider settings that are computed based on effective settings - that is,
  # the default settings merged with the organizations settings.
  #
  # Override this method in order to provide settings that depend not only on the organization
  # or defaults, but also commputed expressions.
  #
  # These settings can not be overriden.
  def computed_settings(effective_settings)
    {}
  end

  def finalize_user_creation!(_user)
  end

  def finalize_user_destruction!(_user)
  end

  def uid_for_profile(omniauth)
    omniauth.info.email || omniauth.uid
  end

  private

  def setup_phase_login_settings(env)
    organization_login_settings_for setup_phase_login_organization_name(env)
  end

  def setup_phase_login_organization_name(env)
    Rack::Request.new(env).cookies['mucookie_login_organization']
  end

  def organization_login_settings_for(name)
    Mumukit::Platform::Organization.find_by_name!(name).login_provider_settings || {}
  end

  def create_uri(path, query_values)
    uri = Addressable::URI.heuristic_parse path
    uri.query_values = query_values if query_values.present?
    uri.to_s
  end
end
