# frozen_string_literal: true

class WkController < ApplicationController
  def register
    api_builder = WkApiBuilder.new
    registration = WkRegistration.new
    WkRegistrationService.new(self, registration, api_builder).call
  end
end
