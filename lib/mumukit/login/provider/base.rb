class Mumukit::Login::Provider::Base

  def initialize(provider_settings = nil)
    @provider_settings = provider_settings
  end

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

  private

  def create_uri(path, query_values)
    uri = Addressable::URI.heuristic_parse path
    uri.query_values = query_values if query_values.present?
    uri.to_s
  end
end
