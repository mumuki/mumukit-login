class Mumukit::Login::OriginRedirector
  def initialize(controller)
    @controller = controller
  end

  def redirect!
    location = @controller.session[:redirect_after_login]
    @controller.session[:redirect_after_login] = nil
    @controller.redirect!(location || '/')
  end

  def save_location!
    @controller.session[:redirect_after_login] = Addressable::URI.heuristic_parse(origin).path
  end

  private

  def origin
    @controller.request.params['origin'] || '/'
  end
end