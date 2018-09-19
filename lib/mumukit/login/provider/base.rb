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

  def setup_proc
    proc do |env|
      options = env['omniauth.strategy'].options

      effective_settings = default_settings.to_h.merge(Mumukit::Platform::Organization.current.login_provider_settings)
      options.merge(effective_settings)
      options.merge(computed_settings(effective_settings.to_struct))
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

  private

  def create_uri(path, query_values)
    uri = Addressable::URI.heuristic_parse path
    uri.query_values = query_values if query_values.present?
    uri.to_s
  end
end
