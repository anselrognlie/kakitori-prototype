# frozen_string_literal: true

class KanjidicMeaning < ApplicationRecord
  belongs_to :kanji, class_name: 'KanjidicMain', foreign_key: :kanjidic_main_id
end
