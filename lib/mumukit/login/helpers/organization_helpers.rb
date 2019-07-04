module Mumukit::Login::OrganizationHelpers
  def login_provider_object
    @login_provider_object ||= login_provider.try { |it| Mumukit::Login::Provider.parse_login_provider it }
  end
end
