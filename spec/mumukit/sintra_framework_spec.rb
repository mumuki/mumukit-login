require_relative '../spec_helper'

describe Mumukit::Platform::WebFramework::Sinatra do
  let(:native) { double(:native) }
  let(:settings) { Mumukit::Login::Settings.new }
  let(:controller) { Mumukit::Login::Controller.new Mumukit::Platform::WebFramework::Sinatra, native }

  describe 'sinatra + auth0' do
    before { allow(native).to receive(:request).and_return dummy_rack_request }
    let(:authentication_request) { Mumukit::Login::Provider::Auth0.new.request_authentication! controller, settings }

    it { expect(authentication_request).to include '<head> <script src="https://cdn.auth0.com/js/lock/10.14.0/lock.min.js"></script>' }
    it { expect(authentication_request).to include '<body>  <script type="text/javascript">' }
    it { expect(authentication_request).to include 'new Auth0Lock' }
  end
end

