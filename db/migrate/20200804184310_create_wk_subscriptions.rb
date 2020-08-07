# frozen_string_literal: true

class CreateWkSubscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :wk_subscriptions do |t|
      t.string :username, null: false
      t.string :token, null: false
      t.boolean :active, null: false
      t.string :type, null: false
      t.integer :max_level, null: false
      t.date :end_of_subscription
      t.timestamps
    end
  end
end
