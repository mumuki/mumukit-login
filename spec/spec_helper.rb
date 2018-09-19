ENV['RAILS_ENV'] ||= 'test'
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'mumukit/login'
require 'mumukit/core/rspec'

class DemoUser
end

class DemoOrganization
  include Mumukit::Platform::Organization::Helpers

  attr_accessor :name, :profile, :settings

  def initialize
    @name = 'orga'
    @profile =  Mumukit::Platform::Organization::Profile.new community_link: 'http://link/to/community',
                                                             terms_of_service: 'The TOS',
                                                             description: 'the description'
    @settings = Mumukit::Platform::Organization::Settings.new
  end
end

DemoOrganization.new.switch!

Mumukit::Platform.configure do |config|
  # User class must understand
  #     find_by_uid!
  #     for_profile
  config.user_class = DemoUser
  config.web_framework = Mumukit::Platform::WebFramework::Rails
end

Mumukit::Auth.configure do |config|
  config.clients.default = {id: 'testId', secret: 'testSecret'}
end

Mumukit::Login.configure do |config|
  config.mucookie_domain = '.localmumuki.io'
  config.mucookie_secret_key = 'abcde1213456123456'
  config.mucookie_secret_salt = 'mucookie test secret salt'
  config.mucookie_sign_salt = 'mucookie test sign salt'
end


def dummy_rack_request
  struct env: {
      'HTTP_HOST' => 'localmumuki.io',
      'rack.url_scheme' => 'http',
      'SERVER_PORT' => '80'}
end
