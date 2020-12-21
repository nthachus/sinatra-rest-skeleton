# frozen_string_literal: true

module Rake
  class Application
    # @!attribute [r] top_level_tasks
    #   @return [Array<String>]

    # @!method rake_require(file_name, paths = [], loaded = [])
    #   @return [true, false]
  end

  # @return [Rake::Application]
  def self.application; end

  def self.application=(*); end
end

module RSpec
  # @return [String]
  def task_name; end
end

module ActiveRecord
  module ConnectionAdapters
    class TableDefinition
      def bigint(*); end
    end
  end
end

module FileUtils
  def self.touch(*); end
end

module Sinatra
  class Base
    # @return [Symbol]
    def self.json_content_type; end
  end
end

class User < ActiveRecord::Base
  # @return [Hash]
  def self.roles; end

  # @return [String]
  def role; end
end

class UserFile < ActiveRecord::Base
  # @return [Integer]
  def user_id; end
end

module Skeleton
  class Application < Sinatra::Base
    # @return [OpenStruct]
    def self.settings; end

    # @return [OpenStruct]
    def settings; end

    def self.not_found(*); end

    # @return [Skeleton::AuthService]
    def auth_service; end

    # @return [Skeleton::UserService]
    def user_service; end

    # @return [Skeleton::LdapAuthService]
    def ldap_auth_service; end

    # @return [Skeleton::UploadService]
    def upload_service; end
  end
end
