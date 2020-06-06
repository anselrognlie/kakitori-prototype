# frozen_string_literal: true

class CreateKanjidicMains < ActiveRecord::Migration[6.0]
  # rubocop: disable Metrics/MethodLength, Metrics/AbcSize
  def change
    create_table :kanjidic_mains do |t|
      t.string :glyph, null: false
      t.integer :grade, null: false, default: 0
      t.integer :strokes, null: false
      t.timestamps
    end

    create_table :kanjidic_readings do |t|
      t.string :reading, null: false
      t.string :normalized, null: false
      t.integer :type, null: false
    end

    create_table :kanjidic_meanings do |t|
      t.string :meaning, null: false
      t.string :normalized, null: false
    end

    add_index :kanjidic_mains, :glyph, unique: true
    add_reference :kanjidic_readings, :kanjidic_main, foreign_key: true
    add_reference :kanjidic_meanings, :kanjidic_main, foreign_key: true
  end
  # rubocop: enable Metrics/MethodLength, Metrics/AbcSize
end
