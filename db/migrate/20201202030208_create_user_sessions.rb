# frozen_string_literal: true

class CreateUserSessions < ActiveRecord::Migration[5.2]
  def change
    create_table :user_sessions do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade, on_update: :cascade }

      t.string :key, limit: 50, null: false, index: { unique: true }
      t.jsonb :value, null: false, default: {}

      t.timestamps
    end
  end
end
