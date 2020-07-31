# frozen_string_literal: true

class KanjidicImportMeaning < ApplicationRecord
  belongs_to :kanji,
             class_name: 'KanjidicImport',
             foreign_key: :glyph,
             primary_key: :glyph,
             inverse_of: :meanings
end
