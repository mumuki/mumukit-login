module Mumukit::Login::AuthorizationHelpers
  def authorize_for!(role, slug)
    if current_user?
      current_user.protect! role, slug
    else
      authenticate!
    end
  end

  def authorize!(role)
    authorize_for!(role, authorization_slug)
  end

  def has_permission?(role)
    current_user.has_permission? role, authorization_slug
  end

  required :authorization_slug
end