# frozen_string_literal: true

RSpec.shared_context 'rake' do
  # noinspection RubyResolve
  require 'rake'

  let(:task_name) { self.class.top_level_description.sub(/^Rake\s+/i, '') }
  subject { Rake.application[task_name] }

  before do
    task_path = "lib/tasks/#{task_name.gsub(/^app:|:.*$/, '')}.rake"
    $LOADED_FEATURES.delete_if { |f| f == task_path }

    Rake.application = nil
    Rake.application.rake_require task_path[0..-6], [File.expand_path('../..', __dir__)]
  end
end
