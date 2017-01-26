$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'mumukit/login'
require 'mumukit/core/rspec'

class DemoUser
end

Mumukit::Login.configure do |config|
  # User class must understand
  #     find_by_uid!
  #     for_profile
  config.user_class = DemoUser
  config.framework = Mumukit::Login::Framework::Rails
end
