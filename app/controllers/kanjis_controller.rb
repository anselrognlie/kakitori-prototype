# frozen_string_literal: true

class KanjisController < ApplicationController
  # before_action :require_account

  def index
    @records = Kanji.all.includes(:jlpt_level, :joyo_level).order(glyph: :asc).limit(10)
  end
end
