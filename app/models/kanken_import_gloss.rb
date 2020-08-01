# frozen_string_literal: true

class KankenImportGloss < ApplicationRecord
  belongs_to :kanken,
             class_name: 'KankenImport',
             foreign_key: :glyph,
             primary_key: :glyph,
             inverse_of: :glosses
end
