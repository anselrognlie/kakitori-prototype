# frozen_string_literal: true

class CreateKanjidicImports < ActiveRecord::Migration[6.0]
  # rubocop: disable Metrics/MethodLength, Metrics/AbcSize
  def change
    create_table :kanjidic_imports do |t|
      t.string :glyph, null: false
      t.string :codepoint, null: false
      t.integer :grade, null: true
      t.integer :strokes, null: false
      t.integer :frequency, null: true
      t.integer :jlpt_old, null: true
      t.timestamps
    end

    create_table :kanjidic_import_readings do |t|
      t.string :glyph, null: false
      t.string :reading, null: false
      t.string :normalized, null: false
      t.string :type, null: false
      t.timestamps
    end

    create_table :kanjidic_import_meanings do |t|
      t.string :glyph, null: false
      t.string :meaning, null: false
      t.string :normalized, null: false
      t.timestamps
    end

    add_index :kanjidic_imports, :glyph, unique: true
    add_index :kanjidic_import_readings, :glyph
    add_index :kanjidic_import_meanings, :glyph
    add_foreign_key :kanjidic_import_readings, :kanjidic_imports,
                    column: :glyph, primary_key: :glyph
    add_foreign_key :kanjidic_import_meanings, :kanjidic_imports,
                    column: :glyph, primary_key: :glyph
  end
  # rubocop: enable Metrics/MethodLength, Metrics/AbcSize
end
