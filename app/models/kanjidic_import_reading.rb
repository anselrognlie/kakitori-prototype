# frozen_string_literal: true

class KanjidicImportReading < ApplicationRecord
  belongs_to :kanji,
             class_name: 'KanjidicImport',
             foreign_key: :glyph,
             primary_key: :glyph,
             inverse_of: :readings

  self.inheritance_column = 'not_sti'
end
