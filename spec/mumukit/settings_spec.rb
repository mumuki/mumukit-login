require_relative '../spec_helper'

describe Mumukit::Login::Settings do
  let(:defaults) { Mumukit::Login::Settings.default_methods }
  let(:facebook_and_user_pass) { [:facebook, :user_pass] }

  describe '#lock_json_spec' do
    let(:settings) { Mumukit::Login::Settings.new }
    let(:spec) { settings.lock_json_spec }

    it { expect(spec[:theme]).to eq logo: "https://mumuki.io/static/logo.png",
                                                       primaryColor: "#FF5B81" }
    context 'es locale' do
      before { I18n.locale = :es }
      it { expect(spec[:language]).to eq :es }
    end

    context 'pt locale' do
      before { I18n.locale = :pt }
      it { expect(spec[:language]).to eq 'pt-br' }
    end
  end

  describe '#social_methods' do
    context 'with few methods' do
      let(:settings) { Mumukit::Login::Settings.new(facebook_and_user_pass) }
      it { expect(settings.social_login_methods.size).to eq 1 }
      it { expect(settings.many_methods?).to eq false }
    end

    context 'with many methods' do
      let(:settings) { Mumukit::Login::Settings.new Mumukit::Login::Settings.login_methods }
      it { expect(settings.login_methods.size).to eq 5 }
      it { expect(settings.social_login_methods.size).to eq 4 }
      it { expect(settings.many_methods?).to eq true }
    end

    context 'without user_pass' do
      let(:settings) { Mumukit::Login::Settings.new([:facebook, :twitter]) }
      it { expect(settings.social_login_methods.size).to eq 2 }
      it { expect(settings.many_methods?).to eq false }
    end
  end
end
