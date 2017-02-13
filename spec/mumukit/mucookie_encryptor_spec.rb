require_relative '../spec_helper'

describe Mumukit::Login::Mucookie::Encryptor do
  subject { Mumukit::Login::Mucookie::Encryptor }
  it { expect(subject.encrypt('foo')).to_not be_empty }
  it { expect(subject.decrypt subject.encrypt('foo')).to eq 'foo' }
  it { expect(subject.decrypt nil).to be nil }
end