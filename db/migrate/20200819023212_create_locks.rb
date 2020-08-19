# frozen_string_literal: true

class CreateLocks < ActiveRecord::Migration[6.0]
  def change
    create_table :locks do |t|
      t.string :name
      t.timestamps
    end

    add_index :locks, :name, unique: true
  end
end
