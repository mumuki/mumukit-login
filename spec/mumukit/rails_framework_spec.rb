require_relative '../spec_helper'

describe Mumukit::Platform::WebFramework::Rails do
  let(:native) { double(:native) }
  let(:settings) { Mumukit::Login::Settings.new }
  let(:controller) { Mumukit::Login::Controller.new Mumukit::Platform::WebFramework::Rails, native }

  describe 'rails + auth0' do
    before { allow(native).to receive(:request).and_return dummy_rack_request }
    before { expect(native).to receive :render }

    it { Mumukit::Login::Provider::Auth0.new.request_authentication! controller, settings }
  end
end