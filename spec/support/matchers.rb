# frozen_string_literal: true

module RSpec
  Matchers.define_negated_matcher :exclude, :include
  Matchers.define_negated_matcher :not_match, :match
end
