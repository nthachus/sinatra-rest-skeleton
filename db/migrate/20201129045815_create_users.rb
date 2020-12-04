# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.integer :role, limit: 1, null: false, default: 0
      t.string :username, limit: 255, null: false, index: { unique: true }
      t.string :password_digest, limit: 100

      t.string :name, limit: 255, null: false
      t.string :email, limit: 255
      t.jsonb :profile, null: false, default: {}

      t.timestamps
      t.datetime :deleted_at
      t.bigint :created_by, :updated_by, :deleted_by

      t.index 'lower(email)', unique: true
    end
  end
end
