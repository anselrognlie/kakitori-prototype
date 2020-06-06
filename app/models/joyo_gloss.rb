# frozen_string_literal: true

class JoyoGloss < ApplicationRecord
  belongs_to :kanji, class_name: 'KanjidicMain', foreign_key: :kanjidic_main_id
end
