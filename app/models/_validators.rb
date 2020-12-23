# frozen_string_literal: true

require 'active_model/validator'

class NotNullValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, :empty, options) if value.nil?
  end
end

class NotEmptyValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, :empty, options) if value.nil? || (value.respond_to?(:empty?) && value.empty?)
  end
end
