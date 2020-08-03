# frozen_string_literal: true

class CreateJlptImports < ActiveRecord::Migration[6.0]
  def change
    create_table :jlpt_imports do |t|
      t.string :glyph, null: false
      t.string :level, null: false
      t.timestamps
    end
  end
end
