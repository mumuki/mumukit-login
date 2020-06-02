require 'active_support/key_generator'

class Mumukit::Login::Mucookie
  def initialize(controller)
    @controller = controller
  end

  def write!(key, value, options={})
    do_write! cookie_name(key),
              spec.merge(
                value: value.to_s,
                httponly: !!options[:httponly])
  end

  def encrypt_and_write!(key, value, options={})
    write! key, Encryptor.encrypt(value), options
  end

  def encode_and_write!(key, value, options={})
    write! key, Base64.encode64(value), options
  end

  def read(key)
    do_read!(cookie_name(key))
  end

  def decrypt_and_read(key)
    Encryptor.decrypt read(key)
  end

  def decode_and_read(key)
    Base64.decode64 read(key)
  end

  def delete!(key)
    do_delete! cookie_name(key), Mumukit::Login.config.mucookie_domain
  end

  def spec
    {
      path: '/',
      expires: Mumukit::Login.config.mucookie_duration.days.since,
      domain: Mumukit::Login.config.mucookie_domain
    }
  end

  def self.cookie_same_site
    if %w(RACK_ENV RAILS_ENV).any? { |it| ENV[it] == 'production' }
      :none
    else
      :lax
    end
  end

  private

  # Support for legacy browsers
  # Duplicate write / read / delete cookies without samesite for old browsers that do not allow for SameSite=None attribute
  def do_write!(cookie_name, spec)
    @controller.write_cookie! cookie_name, spec.merge(same_site: self.class.cookie_same_site)
    @controller.write_cookie! "#{cookie_name}_legacy", spec
  end

  def do_delete!(cookie_name, domain)
    @controller.delete_cookie! cookie_name, domain
    @controller.delete_cookie! "#{cookie_name}_legacy", domain
  end

  def do_read!(cookie_name)
    @controller.read_cookie(cookie_name) || @controller.read_cookie("#{cookie_name}_legacy")
  end

  def cookie_name(key)
    "mucookie_#{key}"
  end

  module Encryptor
    # message encryptor requires a 32-byte key
    MESSAGE_ENCRYPTOR_SECRET_SIZE = 32

    def self.key_generator
      @key_generator ||= begin
        secret_key = Mumukit::Login.config.mucookie_secret_key

        raise 'missing Mumukit::Login.config.mucookie_secret_key' unless secret_key

        ActiveSupport::CachingKeyGenerator.new(ActiveSupport::KeyGenerator.new(secret_key, iterations: 1000))
      end
    end

    def self.encryptor
      @encryptor ||= begin
        mucookie_secret_salt = Mumukit::Login.config.mucookie_secret_salt
        mucookie_sign_salt = Mumukit::Login.config.mucookie_sign_salt

        raise 'missing Mumukit::Login.config.mucookie_secret_salt' unless mucookie_secret_salt
        raise 'missing Mumukit::Login.config.mucookie_sign_salt' unless mucookie_sign_salt

        secret = key_generator.generate_key(mucookie_secret_salt, MESSAGE_ENCRYPTOR_SECRET_SIZE)
        signature = key_generator.generate_key(mucookie_sign_salt)
        ActiveSupport::MessageEncryptor.new(secret, signature)
      end
    end

    def self.encrypt(value)
      encryptor.encrypt_and_sign value
    end

    def self.decrypt(value)
      value.try { |it| encryptor.decrypt_and_verify it }
    end
  end
end

require_relative 'mucookie/store'
