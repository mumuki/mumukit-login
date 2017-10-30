$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'mumukit/login'
require 'mumukit/core/rspec'

class DemoUser
end

Mumukit::Platform.configure do |config|
  config.web_framework = Mumukit::Platform::WebFramework::Rails
end

Mumukit::Auth.configure do |config|
  config.clients.default = {id: 'testId', secret: 'testSecret'}
end

Mumukit::Login.configure do |config|
  # User class must understand
  #     find_by_uid!
  #     for_profile
  config.user_class = DemoUser

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

RSpec::Matchers.define :json_like do |expected, options={}|
  except = options[:except] || []

  def __as_json(json, except)
    json.as_json.with_indifferent_access.as_json(except: except)
  end

  match do |actual|
    __as_json(actual, except) == __as_json(expected, except)
  end

  failure_message_for_should do |actual|
    <<-EOS
    expected: #{__as_json(expected, except)} (#{expected.class})
         got: #{__as_json(actual, except)} (#{actual.class})
    EOS
  end

  failure_message_for_should_not do |actual|
    <<-EOS
    expected: value != #{__as_json(expected, except)} (#{expected.class})
         got:          #{__as_json(actual, except)} (#{actual.class})
    EOS
  end
end

