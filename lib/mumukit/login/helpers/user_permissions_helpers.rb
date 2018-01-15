module Mumukit::Login::UserPermissionsHelpers
  delegate :has_role?,
           :add_permission!,
           :remove_permission!,
           :has_permission?,
           :has_permission_delegation?,
           :protect!,
           :protect_delegation!,
           :protect_permissions_assignment!, to: :permissions

  def merge_permissions!(new_permissions)
    self.permissions = permissions.merge(new_permissions)
  end
end
