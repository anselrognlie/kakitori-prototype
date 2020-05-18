# frozen_string_literal: true

class Kanji < ApplicationRecord
  belongs_to :joyo_level
  belongs_to :jlpt_level
end
