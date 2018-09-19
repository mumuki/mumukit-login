require_relative '../spec_helper'

describe Mumukit::Login::Provider do
  let(:controller) { double(:controller) }
  let(:provider) { Mumukit::Login.provider }
  let(:login_settings) { Mumukit::Login::Settings.new }

  before { allow(controller).to receive(:request).and_return(struct path: '/foo', params: params) }
  let(:params) { {} }

  describe 'providers listings' do
    it { expect(Mumukit::Login::Provider::PROVIDERS.count).to eq 5 }

    describe '.default_enabled_providers' do
      context 'when on test env' do
        it { expect(Mumukit::Login::Provider.default_enabled_providers.count).to eq 5 }
      end

      context 'when on prod env' do
        before { ENV['RAILS_ENV'] = 'production' }
        after { ENV['RAILS_ENV'] = 'test' }
        it { expect(Mumukit::Login::Provider.default_enabled_providers).to_not include('developer') }
      end
    end

    describe '.enabled_providers' do
      context 'when enabled providers not specified' do
        it { expect(Mumukit::Login::Provider.enabled_providers.count).to eq 5 }
      end

      context 'when enabled providers specified' do
        before { ENV['MUMUKI_ENABLED_LOGIN_PROVIDERS'] = 'google,cas' }
        after { ENV['MUMUKI_ENABLED_LOGIN_PROVIDERS'] = nil }
        it { expect(Mumukit::Login::Provider.enabled_providers.count).to eq 2 }
      end
    end
  end

  describe Mumukit::Login::Provider::Developer do
    let(:provider) { Mumukit::Login::Provider::Developer.new }

    it { expect(provider.button_html(controller, 'login', 'clazz')).to eq '<a class="clazz" href="/login?organization=orga&origin=%2Ffoo">login</a>' }
    it { expect(provider.header_html(controller)).to be_blank }
    it { expect(provider.footer_html(controller)).to be_blank }

    describe "with querystring" do
      let(:params) { { embed: true } }

      it { expect(provider.button_html(controller, 'login', 'clazz')).to eq '<a class="clazz" href="/login?organization=orga&origin=%2Ffoo%3Fembed%3Dtrue">login</a>' }
    end
  end

  describe Mumukit::Login::Provider::Auth0 do
    let(:provider) { Mumukit::Login::Provider::Auth0.new }


    before { allow(controller).to receive(:url_for).with('/auth/auth0/callback').and_return('http://localmumuki.io/auth/auth0/callback') }

    it { expect(provider.button_html(controller, 'login', 'clazz')).to eq '<a class="clazz" href="/login?organization=orga&origin=%2Ffoo">login</a>' }
    it { expect(provider.header_html(controller, login_settings)).to be_present }
    it { expect(provider.header_html(controller, login_settings)).to include 'https://cdn.auth0.com/js/lock/11.5.2/lock.min.js' }
    it { expect(provider.header_html(controller, login_settings)).to_not include 'http://localmumuki.io/auth/auth0/callback' }

    it { expect(provider.footer_html(controller)).to be_present }
    it { expect(provider.footer_html(controller)).to include '//cdn.auth0.com/oss/badges/a0-badge-light.png' }

  end

  describe Mumukit::Login::Provider::Saml do
    let(:provider) { Mumukit::Login::Provider::Saml.new }

    it { expect(provider.button_html(controller, 'login', 'clazz')).to eq '<a class="clazz" href="/login?organization=orga&origin=%2Ffoo">login</a>' }
    it { expect(provider.header_html(controller)).to be_blank }
    it { expect(provider.footer_html(controller)).to be_blank }
  end
end
