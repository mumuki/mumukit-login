module Mumukit::Navbar::MenuBarHelper
  def link_to_classroom
    link_to_application 'graduation-cap', :classroom, :teacher?, subdominated_uri: true
  end

  def link_to_laboratory
    link_to_application :flask, :laboratory, :student?, subdominated_uri: true
  end

  def link_to_bibliotheca
    link_to_application :book, :bibliotheca, :writer?
  end

  def link_to_office
    link_to_application :clipboard, :office, :janitor?
  end

  def link_to_application(icon, app_name, minimal_permissions, options={})
    return unless current_user&.send(minimal_permissions)

    app = Mumukit::Navbar::Application[app_name]
    url = options[:subdominated_uri] ? app.subdominated_url(current_organization.name) : app.url

    link_to fa_icon(icon, text: t(app_name), class: 'fa-fw fixed-icon'), url
  end
end
