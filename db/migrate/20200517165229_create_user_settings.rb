# frozen_string_literal: true

class CreateUserSettings < ActiveRecord::Migration[6.0]
  def change
    create_table :user_settings do |t|
      t.bigint :user_id, null: false
      t.string :key, null: false
      t.string :value
      t.timestamps
    end

    add_foreign_key :user_settings, :users, on_delete: :cascade
    add_index :user_settings, %i[user_id key], unique: true
  end
end
