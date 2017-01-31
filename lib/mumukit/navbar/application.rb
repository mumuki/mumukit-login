class Mumukit::Navbar::Application
  attr_accessor :url

  def initialize(url)
    ensure_present! url

    @url = url
  end

  def uri
    URI(@url)
  end

  def subdominated_uri(subdomain)
    uri.subdominate(subdomain)
  end

  def subdominated_url(subdomain)
    subdominated_uri(subdomain).to_s
  end

  def url_for(subdomain, path)
    URI.join(subdominated_uri(subdomain), path).to_s
  end

  def domain
    uri.domain
  end

  def self.[](name)
    APPS[name]
  end

  APPS = %w(laboratory classroom office bibliotheca).map do |app|
    [app, new(Rails.configuration.send("#{app}_url"))]
  end.to_h.with_indifferent_access
end