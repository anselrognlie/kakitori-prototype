# frozen_string_literal: true

class CreateKankenImports < ActiveRecord::Migration[6.0]
  # rubocop: disable Metrics/MethodLength
  def change
    create_table :kanken_imports do |t|
      t.string :glyph, null: false
      t.string :level, null: false
      t.timestamps
    end

    create_table :kanken_import_glosses do |t|
      t.string :glyph, null: false
      t.string :gloss, null: false
      t.string :normalized, null: false
      t.timestamps
    end

    add_index :kanken_imports, :glyph, unique: true
    add_index :kanken_import_glosses, :glyph
    add_foreign_key :kanken_import_glosses, :kanken_imports, column: :glyph, primary_key: :glyph
  end
  # rubocop: enable Metrics/MethodLength
end
