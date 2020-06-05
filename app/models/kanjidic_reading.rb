# frozen_string_literal: true

class KanjidicReading < ApplicationRecord
  belongs_to :kanji, class_name: 'KanjidicMain', foreign_key: :kanjidic_main_id

  self.inheritance_column = 'not_sti'
end
