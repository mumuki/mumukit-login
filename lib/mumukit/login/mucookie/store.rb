require 'action_dispatch'

class Mumukit::Login::Mucookie::Store < ActionDispatch::Session::CookieStore
  def set_cookie(request, session_id, cookie)
    cookie.merge! same_site: :none if on_embeddable_organization?(request)
    super
  end

  private

  def on_embeddable_organization?(request)
    Mumukit::Platform::Organization.find_by_name!(request.cookies['mucookie_login_organization']).embeddable? rescue false
  end
end
