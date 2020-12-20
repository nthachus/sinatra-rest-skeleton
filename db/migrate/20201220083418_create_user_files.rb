# frozen_string_literal: true

class CreateUserFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :user_files do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade, on_update: :cascade }
      t.string :name, limit: 255, null: false

      t.bigint :size, null: false
      t.string :media_type, limit: 120
      t.string :encoding, limit: 50

      t.bigint :last_modified # Unix timestamp in milliseconds
      t.string :checksum, limit: 100
      t.jsonb :extra, null: false, default: {}

      t.timestamps
      t.datetime :deleted_at
      t.bigint :created_by, :updated_by, :deleted_by

      t.index %i[user_id name], unique: true
    end
  end
end
