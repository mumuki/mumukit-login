require_relative '../spec_helper'

describe Mumukit::Login do
  let(:provider) { Mumukit::Login.config.provider }

  it { expect(provider).to be_a Mumukit::Login::Provider::Developer }
  it { expect(provider.name).to eq 'developer' }

  it 'has a version number' do
    expect(Mumukit::Login::VERSION).not_to be nil
  end
end