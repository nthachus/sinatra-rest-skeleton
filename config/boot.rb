# frozen_string_literal: true

require 'active_support'
require 'sinatra/base'

# Prevent Sinatra module methods to disable classic style application
module Sinatra
  def self.register(*); end

  def self.helpers(*); end

  def self.use(*); end
end
