# frozen_string_literal: true

module Skeleton
  class Application < Sinatra::Base
    # @return [LdapAuthService]
    def ldap_auth_service
      @ldap_auth_service ||= LdapAuthService.new self
    end
  end

  class LdapAuthService
    def initialize(app)
      # @type [Skeleton::Application]
      @app = app
    end

    # @return [Array<Hash>]
    # @raise [ActiveRecord::ConfigurationError]
    def list_auth_servers
      list = @app.settings.ldap_servers.reject { |v| v[:disabled] || v['disabled'] }
      # LDAP settings found?
      raise ActiveRecord::ConfigurationError, 'Invalid AD/LDAP settings' if list.blank?

      list
    end

    # @param [String] username
    # @param [String] password
    # @return [User]
    def authenticate(username, password)
      list_auth_servers.each do |auth_server|
        # Authenticate with LDAP server
        # @type [Net::LDAP::Entry] ldap_user
        ldap_user, uid, groups, config = do_authenticate username, password, auth_server
        next unless ldap_user

        # Is AD/LDAP Administrator?
        is_admin = groups&.any? { |s| s =~ /\bAdmin(istrator)?s?\b/i }

        # Store user info if login successful
        return save_on_authenticated(uid || username, ldap_user, config, is_admin)
      end

      nil
    end

    private

    # @param [String] username
    # @param [String] password
    # @param [Hash] auth_server
    # @return [Array<Net::LDAP::Entry, String, Array<String>, Hash>]
    # @raise [Net::LDAP::Error]
    def do_authenticate(username, password, auth_server)
      fluff = AdLdapService.new auth_server

      user = fluff.authenticate username, password
      return nil unless user

      uid = fluff.get_user_login user
      groups = uid ? fluff.find_user_groups(user, uid) : nil
      # DEBUG
      @app.logger.debug "LDAP authenticated for: #{uid.inspect} - #{groups.inspect}"

      [user, uid, groups, fluff.config]
    rescue AdLdapService::UserNotFoundError => e
      # If user not found?
      @app.logger.warn e.inspect
    end

    # @param [String] username
    # @param [Net::LDAP::Entry] ldap_user
    # @param [Hash] config
    # @param [#nil?] is_admin
    # @return [User]
    def save_on_authenticated(username, ldap_user, config, is_admin)
      # If LDAP user has been stored?
      user = User.find_by username: username
      return sync_with_ldap_user(user, ldap_user, config, username) if user&.id

      # Try to find stored LDAP user by email
      email = get_ldap_user_email ldap_user, config, username
      user = User.find_by email: email
      return sync_with_ldap_user(user, ldap_user, config, username) if user&.id
      return nil unless config[:allow_auto_create]

      # Store user if login successful
      model = { username: username, email: email }
      model[:role] = Constants::Roles::ADMIN if is_admin
      model[:name], model[:profile] = get_ldap_user_info ldap_user, config, username
      User.create! model
    end

    # @param [User] user
    # @param [Net::LDAP::Entry] ldap_user
    # @param [Hash] config
    # @param [String] username
    # @return [User]
    def sync_with_ldap_user(user, ldap_user, config, username)
      return user unless config[:allow_auto_sync]

      # TODO: Update email?
      user.name, user.profile = get_ldap_user_info ldap_user, config, username
      user.save!

      user
    end

    # @param [Net::LDAP::Entry] ldap_user
    # @param [Hash] config
    # @param [String] username
    # @return [String]
    def get_ldap_user_email(ldap_user, config, username)
      ldap_user.first(config[:attribute_mail] || 'mail') ||
        config[:email_pattern]&.sub(/%[A-Za-z]/, username) ||
        "#{username}@#{config[:hostname]}"
    end

    LDAP_USER_PROFILE_MAP = {
      phone: %i[mobile homePhone telephoneNumber],
      address: %i[homePostalAddress postalAddress]
    }.freeze

    # @param [Net::LDAP::Entry] ldap_user
    # @param [Hash] config
    # @param [String] username
    # @return [Array<String, Hash>]
    def get_ldap_user_info(ldap_user, config, username)
      name = ldap_user.first(config[:attribute_name] || 'displayName') || ldap_user.first(:cn) || username

      info = {}
      LDAP_USER_PROFILE_MAP.each do |prop, attributes|
        val = nil
        attributes.each { |attr| break if (val = ldap_user.first(attr)) }

        info[prop] = val if val
      end

      [name, info]
    end
  end
end