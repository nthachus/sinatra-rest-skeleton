# frozen_string_literal: true

module Skeleton
  # Strong parameters for Sinatra application
  class Application < Sinatra::Base
    # A way to require parameters
    #
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
  end
end
