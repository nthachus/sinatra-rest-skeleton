# frozen_string_literal: true

RSpec.describe AdLdapService do
  before :all do
    @ldap_config = Skeleton::Application.settings.ldap_servers.first
  end

  it 'lists LDAP users' do
    fluff = described_class.new @ldap_config
    users = fluff.service_bind { fluff.list_users }

    expect(users).to be_kind_of(Array) & include(have_attributes(uid: ['Administrator']), have_attributes(uid: ['ad1']))
  end
end
