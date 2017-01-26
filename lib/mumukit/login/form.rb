
class Mumukit::Login::Form

  #######################
  ## Visual components ##
  #######################

  # This object will configure the login button using the given login settings
  # customizations, if possible
  #
  # @param [Mumukit::Login::Controller] controller a Mumukit::Login::Controller
  # @param [Mumukit::Login::Settings] login_settings customizations for the login UI
  def initialize(provider, controller, login_settings)
    @provider = provider
    @controller = controller
    @login_settings = login_settings
  end

  # HTML <HEAD> customizations. Send this message
  # in order to add login provider-specific code - like CSS and JS -
  # to your page header.
  #
  def header_html
    @provider.header_html(@controller, @login_settings)&.html_safe
  end

  def button_html(title, clazz)
    @provider.button_html(@controller, title, clazz)&.html_safe
  end

  def footer_html
    @provider.footer_html(@controller)&.html_safe
  end

  ###############################
  ## Triggering Authentication ##
  ###############################

  # Ask the user for authentication, by either rendering
  # the login form or redirecting to it
  #
  # This method should be called from a controller action
  # or action filter.
  #
  def show!
    @controller.redirect! @provider.login_path(@controller)
  end
end
