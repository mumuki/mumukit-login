module Mumukit::Login::AuthorizationHelpers
  def authorize!(role)
    if current_user?
      current_user.protect! role, authorization_slug
    else
      authenticate!
    end
  end

  def has_permission?(role)
    current_user.has_permission? role, authorization_slug
  end

  required :authorization_slug
end