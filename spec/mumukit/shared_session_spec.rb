require_relative '../spec_helper'

class SharedSessionMumukiControllerMock
  attr_accessor :hash

  def initialize
    @hash = {}
  end

  def write_cookie!(key, value)
    hash[key] = value
  end

  def read_cookie(key)
    hash[key][:value]
  end

  def delete_cookie!(key, _)
    hash.delete key
  end
end

describe Mumukit::Login::MucookieSharedSession do
  let(:controller) { SharedSessionMumukiControllerMock.new }
  let(:mucookie) { Mumukit::Login::Mucookie.new controller }
  let(:session) { Mumukit::Login::MucookieSharedSession.new mucookie }

  describe 'uid=' do
    before { session.uid = 'foo@bar.com' }
    it { expect(session.uid).to eq 'foo@bar.com' }
    it { expect(controller.hash.size).to eq 1 }
    it { expect(controller.hash['mucookie_session']).to json_like({path: '/',
                                                                   domain: '.localmumuki.io',
                                                                   httponly: true},
                                                                  except: :value) }
  end

  describe '#profile=' do
    before { session.profile = {name: 'John'} }
    it { expect(session.profile).to json_like name: 'John' }
    it { expect(controller.hash.size).to eq 1 }
    it { expect(controller.hash['mucookie_profile']).to json_like({path: '/',
                                                                   domain: '.localmumuki.io',
                                                                   httponly: false},
                                                                  except: :value) }
  end

  describe '#clear!' do
    before do
      session.uid = 'foo@bar.com'
      session.profile = {name: 'John'}
    end
    before { session.clear! }
    it { expect(controller.hash).to be_empty }
  end
end