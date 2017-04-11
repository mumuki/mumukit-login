require_relative '../spec_helper'

describe Mumukit::Login::Provider do
  let(:controller) { double(:controller) }
  let(:provider) { Mumukit::Login.config.provider }
  let(:login_settings) { Mumukit::Login::Settings.new }

  before { allow(controller).to receive(:request).and_return(struct path: '/foo') }

  describe Mumukit::Login::Provider::Developer do
    let(:provider) { Mumukit::Login::Provider::Developer.new }

    it { expect(provider.button_html(controller, 'login', 'clazz')).to eq '<a class="clazz" href="/login?origin=/foo">login</a>' }
    it { expect(provider.header_html(controller)).to be_blank }
    it { expect(provider.footer_html(controller)).to be_blank }
  end

  describe Mumukit::Login::Provider::Auth0 do
    let(:provider) { Mumukit::Login::Provider::Auth0.new }


    before { allow(controller).to receive(:url_for).with('/auth/auth0/callback').and_return('http://localmumuki.io/auth/auth0/callback') }

    it { expect(provider.button_html(controller, 'login', 'clazz')).to eq '<a class="clazz" href="/login?origin=/foo">login</a>' }
    it { expect(provider.send(:auth0_script_html, controller, login_settings)).to be_present }
    it { expect(provider.send(:auth0_script_html, controller, login_settings)).to include 'https://cdn.auth0.com/js/lock/10.14.0/lock.min.js' }
    it { expect(provider.send(:auth0_script_html, controller, login_settings)).to include 'http://localmumuki.io/auth/auth0/callback' }

    it { expect(provider.footer_html(controller)).to be_present }
    it { expect(provider.footer_html(controller)).to include '//cdn.auth0.com/oss/badges/a0-badge-light.png' }

  end

  describe Mumukit::Login::Provider::Saml do
    let(:provider) { Mumukit::Login::Provider::Saml.new }

    it { expect(provider.button_html(controller, 'login', 'clazz')).to eq '<a class="clazz" href="/login?origin=/foo">login</a>' }
    it { expect(provider.header_html(controller)).to be_blank }
    it { expect(provider.footer_html(controller)).to be_blank }
  end
end
