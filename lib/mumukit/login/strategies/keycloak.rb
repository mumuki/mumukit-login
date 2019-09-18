require 'omniauth-oauth2'
require 'json/jwt'

module OmniAuth
  module Strategies
    class Keycloak < OmniAuth::Strategies::OAuth2
      def setup_phase
        super
        @cert = options.client_options[:cert]
      end

      def build_access_token
        client.auth_code.get_token(request.params['code'],
                                   { redirect_uri: callback_url.gsub(/\?.+\Z/, '') }
                                       .merge(token_params.to_hash(symbolize_keys: true)),
                                   deep_symbolize(options.auth_token_params))
      end

      uid { raw_info['sub'] }

      info do
        {
            name: raw_info['name'],
            email: raw_info['email'],
            first_name: raw_info['given_name'],
            last_name: raw_info['family_name']
        }
      end

      extra do
        {
            raw_info: raw_info
        }
      end

      def raw_info
        JSON::JWT.decode(access_token.token, JSON::JWK.new(@cert))
      end
    end
  end
end

