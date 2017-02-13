require_relative '../spec_helper'

describe Mumukit::Login::OriginRedirector do
  let(:session) { {} }
  let(:controller) { double(:controller) }
  let(:redirector) { Mumukit::Login::OriginRedirector.new(controller) }
  before { allow(controller).to receive(:session).and_return(session) }

  context 'when relative redirection url saved' do
    before { expect(controller).to receive(:redirect!).with('/foo') }

    before { allow(controller).to receive(:request).and_return(struct params: {'origin' => '/foo'}) }
    before { redirector.save_after_login_location! }
    before { redirector.redirect_after_login! }

    it { expect(session[:redirect_after_login]).to be nil }
  end

  context 'when absolute redirection url saved' do
    before { expect(controller).to receive(:redirect!).with('http://baz.com/foo') }

    before { allow(controller).to receive(:request).and_return(struct params: {'origin' => 'http://baz.com/foo'}) }
    before { redirector.save_after_login_location! }
    before { redirector.redirect_after_login! }

    it { expect(session[:redirect_after_login]).to be nil }
  end

  context 'when redirection not saved' do
    before { expect(controller).to receive(:redirect!).with('/') }
    before { redirector.redirect_after_login! }

    it { expect(session[:redirect_after_login]).to be nil }
  end

  context 'when origin logout redirect' do
    before { expect(controller).to receive(:redirect!).with('/foo') }
    before { allow(controller).to receive(:request).and_return(struct params: {'origin' => '/foo'}) }

    it { expect { redirector.redirect_after_logout! }.to_not raise_error }

  end

  context 'when logout redirect without origin' do
    before { expect(controller).to receive(:redirect!).with('/') }
    before { allow(controller).to receive(:request).and_return(struct params: {}) }

    it { expect { redirector.redirect_after_logout! }.to_not raise_error }

  end
end