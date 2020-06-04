# frozen_string_literal: true

class CreateKanjis < ActiveRecord::Migration[6.0]
  # rubocop: disable Metrics/MethodLength
  def change
    create_table :kanjis do |t|
      t.string :glyph, null: false, default: ''
      t.string :gloss, null: false, default: ''
      t.string :mnemonic, null: false, default: ''
      t.string :readings, null: false, default: ''
      t.string :meanings, null: false, default: ''
      t.integer :joyo_level_id, null: false, default: 0
      t.integer :jlpt_level_id, null: false, default: 0
      t.integer :grade, null: false, default: 0
      t.integer :strokes, null: false, default: 0
      t.timestamps
    end

    add_index :kanjis, :glyph, unique: true
  end
  # rubocop: enable Metrics/MethodLength
end
