# frozen_string_literal: true

class AuthenticationController < Skeleton::Application
  # Route prefix
  map '/auth'

  # @!method user_service
  #   @return [Skeleton::UserService]

  post '/login_ssl' do
    ssl_client = env[settings.ssl_client_env_key]
    bad_request json_error(I18n.t('app.missing_parameters', values: 'SSL Client')) if ssl_client.blank?

    ssl_client = unescape_ssl_cert ssl_client
    begin
      client_cert = parse_ssl_client ssl_client

      user = user_service.find_user client_cert['CN'], client_cert['emailAddress']
      json jwt: auth_service.do_login(user)
    rescue OpenSSL::OpenSSLError, ActiveRecord::RecordNotFound => e
      logger.warn e.stacktrace(0)
      bad_request json_error(I18n.t('app.invalid_ssl_client'), e.to_s)
    end
  end

  private

  # @param [String] ssl_client
  # @return [String]
  def unescape_ssl_cert(ssl_client)
    logger.debug "Login with SSL client: #{ssl_client}"

    ssl_client = URI.decode_www_form_component(ssl_client, settings.default_encoding) if ssl_client.include? '%'
    ssl_client.gsub(/(---)\s+/, "\\1\n").gsub(/\s+(---)/, "\n\\1")
  end

  # @param [String] ssl_client
  # @return [Hash] Certificate subject
  def parse_ssl_client(ssl_client)
    require 'openssl'

    client_cert = OpenSSL::X509::Certificate.new ssl_client
    # Client certificate verification
    verify_client_cert client_cert

    Hash[client_cert.subject.to_a.map { |entry| entry[0..1] }]
  end

  # @param [OpenSSL::X509::Certificate] client_cert
  # @raise [OpenSSL::PKey::PKeyError]
  def verify_client_cert(client_cert)
    logger.info "Parsed client SSL: #{client_cert&.subject}"

    signer_key = OpenSSL::PKey.read settings.ssl_signer_pub_key
    verified = client_cert.verify signer_key

    raise OpenSSL::PKey::PKeyError, 'Verification failed' unless verified
  end
end
