# frozen_string_literal: true

class KanjidicMain < ApplicationRecord
  has_many :readings, class_name: 'KanjidicReading', foreign_key: :kanjidic_main_id
  has_many :meanings, class_name: 'KanjidicMeaning', foreign_key: :kanjidic_main_id
  has_one :level, class_name: 'JoyoImport', foreign_key: :kanjidic_main_id
  has_many :glosses, class_name: 'JoyoGloss', foreign_key: :kanjidic_main_id
end
