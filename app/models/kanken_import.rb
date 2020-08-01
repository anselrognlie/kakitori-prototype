# frozen_string_literal: true

class KankenImport < ApplicationRecord
  has_many :glosses, class_name: 'KankenImportGloss', foreign_key: :glyph, primary_key: :glyph
end
