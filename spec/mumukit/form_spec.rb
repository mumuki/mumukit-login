require_relative '../spec_helper'

describe Mumukit::Login::Form do
  let(:controller) { double(:controller) }
  let(:login_settings) { Mumukit::Login::Settings.new }
  let(:provider) { Mumukit::Login::Provider::Auth0.new }

  let(:builder) { Mumukit::Login::Form.new(provider, controller, login_settings) }

  before { allow(controller).to receive(:request).and_return(struct path: 'http://localmumuki.io/foo') }

  it { expect(builder.footer_html).to be_html_safe }
  it { expect(builder.header_html).to be_html_safe }
  it { expect(builder.button_html('login', 'clazz')).to be_html_safe }
end