# frozen_string_literal: true

class KanjidicImport < ApplicationRecord
  has_many :readings, class_name: 'KanjidicImportReading', foreign_key: :glyph, primary_key: :glyph
  has_many :meanings, class_name: 'KanjidicImportMeaning', foreign_key: :glyph, primary_key: :glyph
end
