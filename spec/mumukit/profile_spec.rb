require_relative '../spec_helper'

describe Mumukit::Login::Profile do
  describe '.profile_hash' do
    let(:omniauth_hash) {
      {
        provider: :developer,
        info: {
          email: 'some@email.com',
          first_name: 'some first name',
          last_name: 'some last name',
          image: 'https://some.image/url'
        }.to_struct,
        uid: 'some_uid'
      }.to_struct
    }

    context 'for a full, normal profile hash' do
      it { expect(Mumukit::Login::Profile.profile_hash omniauth_hash).to json_like provider: :developer,
                                                                                   first_name: 'some first name',
                                                                                   last_name: 'some last name',
                                                                                   social_id: 'some_uid',
                                                                                   email: 'some@email.com',
                                                                                   uid: 'some@email.com',
                                                                                   image_url: 'https://some.image/url' }
    end

    context 'missing keys are removed from resulting hash' do
      before { omniauth_hash.info.image = nil }

      it { expect(Mumukit::Login::Profile.profile_hash omniauth_hash).to json_like provider: :developer,
                                                                                   first_name: 'some first name',
                                                                                   last_name: 'some last name',
                                                                                   social_id: 'some_uid',
                                                                                   email: 'some@email.com',
                                                                                   uid: 'some@email.com' }
    end

    context 'when no email present uid is used as uid' do
      before { omniauth_hash.info.email = nil }

      it { expect(Mumukit::Login::Profile.profile_hash omniauth_hash).to json_like provider: :developer,
                                                                                   first_name: 'some first name',
                                                                                   last_name: 'some last name',
                                                                                   social_id: 'some_uid',
                                                                                   uid: 'some_uid',
                                                                                   image_url: 'https://some.image/url' }
    end

    context 'when image_url is too long it is ignored' do
      before { omniauth_hash.info.image = 'a' * 256 }

      it { expect(Mumukit::Login::Profile.profile_hash omniauth_hash).to json_like provider: :developer,
                                                                                   first_name: 'some first name',
                                                                                   last_name: 'some last name',
                                                                                   social_id: 'some_uid',
                                                                                   email: 'some@email.com',
                                                                                   uid: 'some@email.com' }
    end
  end
end

