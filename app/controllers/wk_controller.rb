# frozen_string_literal: true

class WkController < ApplicationController
  def register
    token = register_param
    api = WkApi.new(token)
    WkRegistrationService.new(self, api).call
  end

  private

  def register_param
    params.require(:token)
  end
end
