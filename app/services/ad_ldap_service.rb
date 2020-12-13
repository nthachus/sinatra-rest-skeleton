# frozen_string_literal: true

require 'net/ldap'

# Active Directory / LDAP service
class AdLdapService # rubocop:disable Metrics/ClassLength
  DEFAULT_CONFIG = {
    default: {
      hostname: 'localhost',
      port: 389,
      # use_ssl: false,
      auth_method: 'LDAP',

      search_subtree: true
      # group_search_subtree: false,
    },
    active_directory: {
      # username: 'DOMAIN\\Administrator',
      # search_base: 'DC=domain',
      search_filter_formula: '(sAMAccountName=%u)',
      list_search_filter: '(objectClass=user)',

      search_group: false,
      # group_search_base: 'CN=Groups,DC=domain',
      group_search_filter: '(member=%u)'
      # attribute_group_name: 'CN',
    },
    # TODO: FreeIPA
    posix: {
      # username: 'uid=admin,ou=Users,dc=domain',
      # search_base: 'dc=domain',
      search_filter_formula: '(uid=%u)',
      list_search_filter: '(objectClass=posixAccount)',

      search_group: true,
      # group_search_base: 'ou=Groups,dc=domain',
      group_search_filter: '(memberuid=%u)'
    }
  }.freeze

  # @return [Hash]
  attr_reader :config

  # @param [Hash] config
  def initialize(config)
    type = server_type(config[:auth_method] || config['auth_method'])
    @config = DEFAULT_CONFIG[:default].with_indifferent_access.merge!(DEFAULT_CONFIG[type]).merge!(config)
  end

  # @param [String] type
  # @return [Symbol]
  def server_type(type = config[:auth_method])
    return :active_directory if type =~ /\bA(ctive)?\W*D(irectory)?\b/i
    return :free_ipa if type =~ /\b(Free)?IPA\b/i

    :posix
  end

  # @return [Net::LDAP]
  def ldap_client
    @ldap_client ||= Net::LDAP.new(
      host: config[:hostname],
      port: config[:port],
      base: config[:search_base],
      encryption: config[:use_ssl] ? ssl_options : nil
    )
  end

  # @raise [AuthorizationError]
  def service_bind
    ldap_client.auth config[:username], config[:password]
    raise AuthorizationError, "Could not bind to #{config[:auth_method]} user: #{config[:username]}" unless ldap_client.bind

    yield if block_given?
  end

  # @param [String] uid
  # @param [String] password
  # @return [Net::LDAP::Entry]
  # @raise [UserNotFoundError]
  def authenticate(uid, password)
    service_bind
    user = bind_dn_test.match?(uid) ? find_by_dn(uid) : find_user(uid)

    ldap_client.auth user.dn, password
    ldap_client.bind ? user : nil
  end

  # @param [String] uid
  # @return [Net::LDAP::Entry]
  # @raise [UserNotFoundError]
  def find_user(uid)
    # @type [Array<Net::LDAP::Entry>]
    users = ldap_client.search filter: name_filter(uid), size: 1, attributes: user_attrs
    raise UserNotFoundError, uid if users.blank?

    users.first
  end

  # @param [String] uid
  # @return [Net::LDAP::Entry]
  # @raise [UserNotFoundError]
  def find_by_dn(uid)
    # @type [Array<Net::LDAP::Entry>]
    users = ldap_client.search base: uid, scope: Net::LDAP::SearchScope_BaseObject, attributes: user_attrs
    raise UserNotFoundError, uid if users.blank?

    users.first
  end

  # @return [Array<String>]
  def user_attrs
    return @user_attrs if instance_variable_defined?(:@user_attrs)

    @user_attrs = config[:search_group] || server_type == :active_directory ? nil : ['*', attr_group]
  end

  # @return [String]
  def attr_group
    config[:attribute_group] || 'memberOf'
  end

  # @return [String]
  def attr_group_name
    config[:attribute_group_name] || 'cn'
  end

  # @param [Net::LDAP::Entry] user
  # @param [String] uid
  # @return [Array<String>]
  def find_user_groups(user, uid = nil)
    return find_groups_by_member(uid, user.dn) if config[:search_group]

    first_level = user[attr_group]
    return [] if first_level.blank?

    total_groups, = walk_group_ancestry(first_level, first_level)
    groups = first_level + total_groups

    pattern = /.*?\b#{attr_group_name}=([^,]*).*/i
    groups.map { |g| g.sub(pattern, '\1') }.uniq
  end

  # @return [Array<Net::LDAP::Entry>]
  # @raise [UserNotFoundError]
  def list_users
    # @type [Array<Net::LDAP::Entry>]
    list = ldap_client.search filter: search_filter, scope: search_scope(config[:search_subtree]), attributes: user_attrs
    raise UserNotFoundError if list.blank?

    list
  end

  # @param [Net::LDAP::Entry, String] user
  # @return [String]
  def get_user_login(user)
    return nil unless user
    return user.sub(/^.*?\w+=([^,]*).*|(.*?)@.*|.*\\(.*?)$/, '\1\2\3') if user.is_a? String

    user[attr_login].first
  end

  # @return [String]
  def attr_login
    return @attr_login if instance_variable_defined?(:@attr_login)

    @attr_login = parse_attribute_name(config[:search_filter_formula])
  end

  # @return [String]
  def attr_member
    return @attr_member if instance_variable_defined?(:@attr_member)

    @attr_member = parse_attribute_name(config[:group_search_filter])
  end

  # @return [Net::LDAP::Filter]
  def search_filter
    return @search_filter if instance_variable_defined?(:@search_filter)

    @search_filter = config[:list_search_filter].blank? ? nil : Net::LDAP::Filter.construct(config[:list_search_filter])
  end

  # @param [String] uid
  # @return [Net::LDAP::Filter]
  def name_filter(uid)
    filter = Net::LDAP::Filter.eq attr_login, uid
    search_filter ? (filter & search_filter) : filter
  end

  # @param [String] uid
  # @param [String] fdn
  # @return [Net::LDAP::Filter]
  def group_filter(uid, fdn = nil)
    if attr_member =~ /^(unique)?Member$/i
      fdn ||= "*=#{uid},*"
    else
      fdn = uid
    end

    Net::LDAP::Filter.eq attr_member, fdn
  end

  private

  # @return [Hash]
  def ssl_options
    { method: :simple_tls, tls_options: { verify_mode: OpenSSL::SSL::VERIFY_NONE } } # verify_hostname: false
  end

  # @return [Regexp]
  def bind_dn_test
    @bind_dn_test ||= server_type == :active_directory ? /(?<!\\),|\\[\w-]|[\w-]@/ : /(?<!\\),/
  end

  # @param [String] uid
  # @param [String] fdn
  # @return [Array<String>]
  def find_groups_by_member(uid, fdn = nil)
    # @type [Array<Net::LDAP::Entry>]
    groups = ldap_client.search(
      filter: group_filter(uid, fdn),
      scope: search_scope(config[:group_search_subtree]),
      base: config[:group_search_base]
    )
    return [] if groups.blank?

    attr = attr_group_name
    groups.map { |g| g.first attr }
  end

  # Recursively loop over the parent list
  #
  # @param [Array<String>] group_dns
  # @param [Array<String>] known_groups
  # @return [Array<Array<String>>]
  def walk_group_ancestry(group_dns = [], known_groups = []) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    set = []

    group_dns.each do |group_dn|
      # @type [Array<Net::LDAP::Entry>]
      entry = ldap_client.search base: group_dn, scope: Net::LDAP::SearchScope_BaseObject, attributes: [attr_group]

      groups = entry.respond_to?(:first) ? entry.first[attr_group] : nil
      next if groups.blank?

      groups -= known_groups
      known_groups += groups
      next_level, = walk_group_ancestry(groups, known_groups) # new_known_groups

      set += next_level + groups
      known_groups += next_level
    end

    [set, known_groups]
  end

  # @return [Integer]
  def search_scope(subtree)
    subtree ? Net::LDAP::SearchScope_WholeSubtree : Net::LDAP::SearchScope_SingleLevel
  end

  # @param [String]
  # @return [String]
  def parse_attribute_name(filter_formula)
    filter_formula&.sub(/^.*?([\w-]+)\s*=.*/, '\1')
  end

  class AuthorizationError < Net::LDAP::Error
  end

  class UserNotFoundError < Net::LDAP::Error
  end
end
