# frozen_string_literal: true

class SettingsController < ApplicationController
  def index
    service = SettingsRetrievalService.new(controller: self)
    service.call
  end

  def update
    service = SettingsUpdateService.new(controller: self)
    service.call
  end
end
