module Mumukit::Login::AuthorizationHelpers
  def authorize!(role)
    current_user.protect! role, authorization_slug
  end

  def has_permission?(role)
    current_user.has_permission? role, authorization_slug
  end

  required :authorization_slug
end