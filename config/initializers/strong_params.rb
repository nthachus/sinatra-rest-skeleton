# frozen_string_literal: true

module Skeleton
  # Strong parameters for Sinatra application
  class Application < Sinatra::Base
    # A way to require parameters
    #
    # @example
    #   get '/', needs: [:id, :action] do
    #     ...
    #   end
    #
    set :needs do |*needed|
      condition do
        # IndifferentHash @params doesn't need to symbolize
        missed = needed.select { |key| @params[key].nil_or_empty? }

        bad_request json_error(I18n.t('app.missing_parameters', values: missed.join(', '))) unless missed.empty?
      end
    end

    # Requires the specified Content-Type
    #
    # @example
    #   get '/', media_type: 'text/plain' do
    #     ...
    #   end
    #
    set :media_type do |*needed|
      condition do
        type = request.media_type
        matched = needed.any? { |need| (need.is_a?(Regexp) && type =~ need) || type == need }

        error 415, json_error(I18n.t('app.unsupported_media_type')) unless matched
      end
    end

    # TODO: client_ip
  end
end
