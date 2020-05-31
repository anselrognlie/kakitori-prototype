# frozen_string_literal: true

class KanjisController < ApplicationController
  # before_action :require_account

  def index
    @records = Kanji.where('jlpt_level_id <> 0 and joyo_level_id <> 0')
                    .order(joyo_level_id: :asc, glyph: :asc)
  end
end
