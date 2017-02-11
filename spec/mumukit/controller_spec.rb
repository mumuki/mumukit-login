require_relative '../spec_helper'

describe Mumukit::Login::Controller do
  let(:native) { nil }
  let(:framework) { double(:framework) }
  let(:controller) { Mumukit::Login::Controller.new framework, native }

  describe '#request' do
    before { allow(framework).to receive(:env).and_return('HTTP_HOST' => 'localmumuki.io',
                                                          'rack.url_scheme' => 'http',
                                                          'SERVER_PORT' => '80') }

    it { expect(controller.request).to be_a Rack::Request }
    it { expect(controller.url_for('/foo/bar')).to eq 'http://localmumuki.io/foo/bar' }
  end

  describe '#mucookie' do
    it { expect(controller.mucookie).to be_a Mumukit::Login::Mucookie }
  end

  describe '#shared_session' do
    context 'when there is an AUTHORIZATION header' do
      let(:header) { Mumukit::Auth::Token.encode_header('tomson24', {}) }
      before { allow(framework).to receive(:env).and_return('HTTP_AUTHORIZATION' => header) }

      it { expect(controller.shared_session).to be_a Mumukit::Login::TokenSharedSession }
    end

    context 'when there is no AUTHORIZATION header' do
      before { expect(framework).to receive(:env).and_return({}) }
      it { expect(controller.shared_session).to be_a Mumukit::Login::MucookieSharedSession }
    end
  end
end
