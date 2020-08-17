# frozen_string_literal: true

class SettingsController < ApplicationController
  def index
    service = SettingsRetrievalService.new(
      self,
      SubscriptionSummarySerializer.new,
      DataInjector.new
    )
    service.call
  end

  # rubocop: disable Metrics/MethodLength
  def update
    api_builder = WkApiBuilder.new
    registration = WkRegistration.new
    retrieval_service = SettingsRetrievalService.new(
      self,
      SubscriptionSummarySerializer.new,
      DataInjector.new
    )
    service = SettingsUpdateService.new(
      self,
      registration,
      retrieval_service,
      api_builder
    )
    service.call
  end
  # rubocop: enable Metrics/MethodLength
end
