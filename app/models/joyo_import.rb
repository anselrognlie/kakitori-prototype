# frozen_string_literal: true

class JoyoImport < ApplicationRecord
  belongs_to :kanji, class_name: 'KanjidicMain', foreign_key: :kanjidic_main_id
end
