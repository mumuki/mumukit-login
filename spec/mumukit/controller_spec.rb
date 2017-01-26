require_relative '../spec_helper'

describe Mumukit::Login::Controller do
  let(:framework) { double(:framework) }
  let(:controller) { Mumukit::Login::Controller.new framework, nil }

  before { allow(framework).to receive(:env).and_return('HTTP_HOST' => 'localmumuki.io',
                                                        'rack.url_scheme' => 'http',
                                                        'SERVER_PORT' => '80') }

  it { expect(controller.request).to be_a Rack::Request }
  it { expect(controller.url_for('/foo/bar')).to eq 'http://localmumuki.io/foo/bar' }
end
