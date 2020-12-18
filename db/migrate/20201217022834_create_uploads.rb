# frozen_string_literal: true

class CreateUploads < ActiveRecord::Migration[5.2]
  def change
    # noinspection RubyResolve
    create_table :uploads do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade, on_update: :cascade }
      t.string :key, limit: 50, null: false, index: { unique: true }

      t.string :name, limit: 255, null: false
      t.bigint :size, null: false

      t.string :mime_type, limit: 255
      t.bigint :last_modified # Unix timestamp in milliseconds
      t.jsonb :extra, null: false, default: {}

      t.timestamps
      t.bigint :created_by, :updated_by

      # t.index %i[user_id name], unique: true
    end
  end
end
