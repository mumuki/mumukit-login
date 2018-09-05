require_relative '../spec_helper'

describe Mumukit::Login::Provider do
  let(:controller) { double(:controller) }
  let(:provider) { Mumukit::Login.provider }
  let(:login_settings) { Mumukit::Login::Settings.new }

  before { allow(controller).to receive(:request).and_return(struct path: '/foo', params: params) }
  let(:params) { {} }

  describe Mumukit::Login::Provider::Developer do
    let(:provider) { Mumukit::Login::Provider::Developer.new }

    it { expect(provider.button_html(controller, 'login', 'clazz')).to eq '<a class="clazz" href="/login?origin=%2Ffoo">login</a>' }
    it { expect(provider.header_html(controller)).to be_blank }
    it { expect(provider.footer_html(controller)).to be_blank }

    describe "with querystring" do
      let(:params) { { embed: true } }

      it { expect(provider.button_html(controller, 'login', 'clazz')).to eq '<a class="clazz" href="/login?origin=%2Ffoo%3Fembed%3Dtrue">login</a>' }
    end
  end

  describe Mumukit::Login::Provider::Auth0 do
    let(:provider) { Mumukit::Login::Provider::Auth0.new }


    before { allow(controller).to receive(:url_for).with('/auth/auth0/callback').and_return('http://localmumuki.io/auth/auth0/callback') }

    it { expect(provider.button_html(controller, 'login', 'clazz')).to eq '<a class="clazz" href="/login?origin=%2Ffoo">login</a>' }
    it { expect(provider.header_html(controller, login_settings)).to be_present }
    it { expect(provider.header_html(controller, login_settings)).to include 'https://cdn.auth0.com/js/lock/11.5.2/lock.min.js' }
    it { expect(provider.header_html(controller, login_settings)).to_not include 'http://localmumuki.io/auth/auth0/callback' }

    it { expect(provider.footer_html(controller)).to be_present }
    it { expect(provider.footer_html(controller)).to include '//cdn.auth0.com/oss/badges/a0-badge-light.png' }

  end

  describe Mumukit::Login::Provider::Saml do
    let(:provider) { Mumukit::Login::Provider::Saml.new }

    it { expect(provider.button_html(controller, 'login', 'clazz')).to eq '<a class="clazz" href="/login?origin=%2Ffoo">login</a>' }
    it { expect(provider.header_html(controller)).to be_blank }
    it { expect(provider.footer_html(controller)).to be_blank }
  end
end
